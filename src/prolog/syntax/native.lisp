;;; Ground functional modes of pure predicates, with guarded VM fallback.
;;; Ported from cons-prolog revision 6da5c8e4ff692fb1da887835452fd625b33f2731
;;; (src/syntax/native.lisp), MIT; see licenses/cons-prolog-MIT.txt.
(uiop:define-package #:ooparts/prolog/syntax/native
  (:use #:cl)
  (:import-from #:ooparts/prolog/kernel/model
    #:database-execution-mode #:database-generation #:database-native-cache
    #:database-predicates #:database-tabled #:database-term-model #:disjunction-goal-p
    #:host-goal-p #:logic-var-p #:machine-args #:machine-database #:machine-delays
    #:machine-native-calls #:machine-native-deopts #:machine-native-disabled #:machine-slg
    #:machine-slg-worker #:predicate-clauses #:scoped-goals-p #:sequence-goals-goals
    #:sequence-goals-p #:*term-model*)
  (:import-from #:ooparts/prolog/kernel/engine
    #:*database* #:backtrack #:deref #:map-term #:record-cell #:restore-continuation #:unify)
  (:import-from #:ooparts/prolog/kernel/protocol
    #:execute-term-instruction #:iso-atomic-equal #:iso-predicate-name #:iso-primitive-p
    #:iso-syntax-p #:maybe-collect #:provider-symbol #:register-provider)
  (:import-from #:ooparts/prolog/kernel/runtime
    #:iso-resolve-name)
  (:import-from #:ooparts/prolog/adapters/term-ops
    #:iso-acyclic-p #:iso-atom-name #:iso-list-from-host)
  ;; Dependency only: the baseline dispatcher identity must be captured after
  ;; the provider is installed, and instrumentation compares its function cell.
  (:import-from #:ooparts/prolog/kernel/wam)
  (:import-from #:ooparts/prolog/syntax/compiler
    #:anonymous-p #:variable-symbol-p)
  (:import-from #:ooparts/prolog/syntax/dcg
    #:finite-list-p)
  (:export #:native-call #:*native-enabled*))
(in-package #:ooparts/prolog/syntax/native)

;;; Execution policy. The process-level switch selects a complete WAM oracle.
(defvar *native-enabled*
  (not (equal (uiop:getenv "OOPARTS_PROLOG_DISABLE_NATIVE") "1")))

;;; Conservative bounds keep the host stack and speculative work finite. Tests
;;; may lower these; generated code reads them only through the attempt budget.
(defvar *native-fuel-limit* 1000000)
(defvar *native-depth-limit* 256)
(defvar *native-answer-limit* 65536)
;;; The explicit-stack tier keeps activations in a heap arena, so its bound is
;;; the arena size in slots rather than the host stack depth.
(defvar *native-stack-slot-limit* 1048576)
(defvar *native-arity-limit*
  (min 64 (- call-arguments-limit 4) (- lambda-parameters-limit 4)
       (1- multiple-values-limit)))

(defvar *compiling-modes* nil)
(defvar *compile-work* nil)
(defvar *constants* nil)
(defvar *constant-index* nil)

;;; Slot accessors are deliberately absent: CMUCL treats an INLINE
;;; proclamation of a structure accessor as a redefinition and signals a
;;; continuable error while loading the fasl, and the other compilers already
;;; inline accessors of a known structure type.
(declaim (inline native-integer native-budget-check native-stack-entry-check))

(defstruct (native-mode (:constructor make-native-mode (function constants stack-template)))
  function constants stack-template
  ;; :UNCOMPILED, :READY or :REJECTED for the explicit-stack tier.
  (stack-state :uncompiled) stack-function)
(defstruct (native-budget (:constructor make-native-budget
                                        (fuel depth-limit answers-left stack-slot-limit)))
  fuel (depth-limit 0 :read-only t) answers-left (stack-slot-limit 0 :read-only t))
(defun native-integer (value)
  (unless (integerp value) (throw 'native-bailout nil)) value)
(defun native-budget-check (budget depth)
  "Fail the whole attempt once its logical depth or fuel is exhausted.
A depth overflow is reported separately so the caller may retry the identical
attempt on the explicit-stack tier without replenishing fuel or answers."
  (when (> depth (native-budget-depth-limit budget)) (throw 'native-bailout :depth))
  (when (minusp (decf (native-budget-fuel budget))) (throw 'native-bailout nil)))
(defun native-stack-entry-check (budget)
  "Charge one generated entry on the explicit-stack tier; depth is heap bound."
  (when (minusp (decf (native-budget-fuel budget))) (throw 'native-bailout nil)))

(defun accepted-generated-function (function failure)
  "Return the host result of compiling generated code, or NIL to reject it.
CMUCL sets the failure flag for warnings, and its optimizer warns about
constant folding of arithmetic that the generated runtime guard makes
unreachable -- for example a literal division by zero. It still returns a
callable function whose guard bails out first, so the warning alone must not
reject an otherwise usable mode group."
  #+cmucl
  (declare (ignore failure))
  #+cmucl
  function
  #-cmucl
  (and (not failure) function))

(defun native-fresh-graph (term)
  "Copy a ground cons graph into a private host graph, preserving sharing."
  (map-term term #'identity (lambda () (cons nil nil))))

(defun intern-constant (object)
  (or (gethash object *constant-index*)
      (let ((index (fill-pointer *constants*)))
        (vector-push-extend object *constants*)
        (setf (gethash object *constant-index*) index))))
(defun constant-ref (object)
  "Emit a reference to OBJECT in the mode's runtime constants vector."
  `(svref constants ,(intern-constant object)))

;;; Source analysis.
(defun flatten-body (body)
  "Flatten transparent conjunctions and SEQUENCE-GOALS into source order."
  (let ((work (copy-list body)) (result nil) (steps 0))
    (loop while work do
      (let ((goal (pop work)))
        (when (> (incf steps) 10000) (throw 'not-functional nil))
        (cond ((sequence-goals-p goal)
               (setf work (append (copy-list (sequence-goals-goals goal)) work)))
              ((and (consp goal) (symbolp (car goal)) (finite-list-p goal)
                    (= (length goal) 3)
                    (string= (iso-predicate-name (car goal) 2) ","))
               (push (third goal) work) (push (second goal) work))
              (t (push goal result)))))
    (nreverse result)))

(defun cut-goal-p (goal)
  (let ((name (if (and (consp goal) (null (cdr goal))) (car goal) goal)))
    (and (symbolp name) (string= (iso-predicate-name name 0) "!"))))

(defun disjoint-patterns-p (left right)
  "True when the two source patterns cannot match one common term.
Symbols overlap by canonical atom name, not by host symbol identity."
  (let ((work (list (cons left right))))
    (loop while work do
      (let* ((pair (pop work)) (a (car pair)) (b (cdr pair)))
        (cond ((or (variable-symbol-p a) (variable-symbol-p b)) nil)
              ((and (consp a) (consp b))
               (push (cons (car a) (car b)) work) (push (cons (cdr a) (cdr b)) work))
              ((or (consp a) (consp b)) (return-from disjoint-patterns-p t))
              ((and (symbolp a) (symbolp b))
               (unless (string= (iso-atom-name a) (iso-atom-name b))
                 (return-from disjoint-patterns-p t)))
              ((not (eql a b)) (return-from disjoint-patterns-p t)))))
    nil))

(defun ground-equal (left right)
  "Iterative equality under the live atom-bridge relation."
  (let ((work (list left right)))
    (loop while work do
      (let ((a (pop work)) (b (pop work)))
        (cond ((eq a b))
              ((and (consp a) (consp b))
               (push (cdr b) work) (push (cdr a) work)
               (push (car b) work) (push (car a) work))
              ((not (iso-atomic-equal a b)) (return-from ground-equal nil)))))
    t))

(defun check-template (term seen &optional (depth 0))
  "Reject shared, cyclic, over-deep or non-representable source templates."
  (let ((work (list (cons term depth))))
    (loop while work do
      (let* ((item (pop work)) (x (car item)) (d (cdr item)))
        (cond ((consp x)
               (when (> d 64) (throw 'not-functional nil))
               (when (gethash x seen) (throw 'not-functional nil))
               (setf (gethash x seen) t)
               (push (cons (car x) (1+ d)) work) (push (cons (cdr x) (1+ d)) work))
              ((logic-var-p x) (throw 'not-functional nil)))))))

(defun check-clause (clause seen)
  "Validate the source clause graph before any recursive mode is emitted."
  (dolist (argument (cdr (car clause))) (check-template argument seen))
  (dolist (goal (flatten-body (cdr clause)))
    (cond ((or (variable-symbol-p goal) (logic-var-p goal)) (throw 'not-functional nil))
          ((symbolp goal))
          ((consp goal)
           (unless (and (symbolp (car goal)) (finite-list-p goal))
             (throw 'not-functional nil))
           (dolist (argument (cdr goal)) (check-template argument seen)))
          (t (throw 'not-functional nil)))))

(defun contains-variable-p (tree variable)
  (let ((seen (make-hash-table :test 'eq)) (work (list tree)) (steps 0))
    (loop while work do
      (let ((x (pop work)))
        (when (> (incf steps) 100000) (return-from contains-variable-p t))
        (cond ((eq x variable) (return-from contains-variable-p t))
              ((and (consp x) (not (gethash x seen)))
               (setf (gethash x seen) t)
               (push (car x) work) (push (cdr x) work))))))
  nil)

(defun free-outputs-p (terms)
  (let ((seen nil))
    (every (lambda (term)
             (and (variable-symbol-p term)
                  (or (anonymous-p term)
                      (unless (member term seen :test #'eq) (push term seen) t))))
           terms)))

(defun ground-template-p (term &optional (depth 0))
  "True when a source template contains no variables."
  (when (> depth 64) (throw 'not-functional nil))
  (cond ((variable-symbol-p term) nil)
        ((consp term) (and (ground-template-p (car term) (1+ depth))
                           (ground-template-p (cdr term) (1+ depth))))
        ((logic-var-p term) (throw 'not-functional nil))
        (t t)))

(defun native-index-key (value)
  "Coarse relation key; callers always recheck with GROUND-EQUAL."
  (cond ((symbolp value) (list :atom (iso-atom-name value)))
        ((consp value) (list :compound))
        (t (list :value value))))

;;; Mode-group compilation.
(defun emit-mode (database name arity mask enumeratep function request)
  "Emit one fixed-arity Lisp definition for the requested closed call mode."
  (let* ((predicate (gethash (cons name arity) (database-predicates database)))
         (clauses (and predicate (predicate-clauses predicate)))
         (inputs (loop for index below arity when (logbitp index mask) collect index))
         (outputs (loop for index below arity unless (logbitp index mask) collect index))
         (parameters (loop for index in inputs collect (gensym "ARG")))
         (seen-templates (make-hash-table :test 'eq))
         (done (gensym "DONE"))
         (forms nil))
    (unless clauses (throw 'not-functional nil))
    (dolist (clause clauses) (check-clause clause seen-templates))
    ;; A ground fact relation is indexed by its available scalar inputs.
    (when (and (every (lambda (clause) (null (cdr clause))) clauses)
               (every (lambda (clause)
                        (let ((arguments (cdar clause)))
                          (and (every #'ground-template-p arguments)
                               (every (lambda (position)
                                        (not (consp (nth position arguments))))
                                      inputs))))
                      clauses))
      (let ((index (make-hash-table :test 'equal)))
        (dolist (clause (reverse clauses))
          (let ((arguments (cdar clause)))
            (push arguments
                  (gethash (loop for position in inputs collect (native-index-key (nth position arguments)))
                           index))))
        (unless (or enumeratep
                    (loop for rows being the hash-values of index always (null (cdr rows))))
          (throw 'not-functional nil))
        (return-from emit-mode
          `(,function (depth ,@parameters ,@(when enumeratep '(callback)))
             (declare (optimize (speed 3) (safety 1) (debug 0)) (ignorable depth))
             (native-budget-check budget depth)
             (dolist (row (gethash (list ,@(loop for parameter in parameters
                                                 collect `(native-index-key ,parameter)))
                                   ,(constant-ref index)))
               (when (and ,@(loop for position in inputs for parameter in parameters
                                  collect `(ground-equal (nth ,position row) ,parameter)))
                 ,(if enumeratep
                      `(funcall callback (1+ depth)
                                ,@(loop for position in outputs
                                        collect `(native-fresh-graph (nth ,position row))))
                      `(return-from ,function
                         (values t ,@(loop for position in outputs
                                           collect `(native-fresh-graph (nth ,position row))))))))
             (values nil)))))
    ;; Ordinary calls must be deterministic; prove disjointness on known inputs.
    (unless enumeratep
      (loop for rest on clauses do
        (unless (some #'cut-goal-p (flatten-body (cdar rest)))
          (dolist (later (cdr rest))
            (unless (some (lambda (index)
                            (disjoint-patterns-p (nth index (cdaar rest))
                                                 (nth index (cdar later))))
                          inputs)
              (throw 'not-functional nil))))))
    (dolist (clause clauses)
      (let* ((env (make-hash-table :test 'eq))
             (failed (gensym "CLAUSE")) (committed (gensym "CUT"))
             (failure `(return-from ,failed nil)))
        (labels
            ((value-form (term env &optional (depth 0))
               (when (> depth 64) (throw 'not-functional nil))
               (cond ((variable-symbol-p term)
                      (multiple-value-bind (value present) (gethash term env)
                        (unless present (throw 'not-functional nil)) value))
                     ((consp term)
                      `(cons ,(value-form (car term) env (1+ depth))
                             ,(value-form (cdr term) env (1+ depth))))
                     ((logic-var-p term) (throw 'not-functional nil))
                     (t (constant-ref term))))
             (known-p (term env &optional (depth 0))
               (when (> depth 64) (throw 'not-functional nil))
               (cond ((variable-symbol-p term) (nth-value 1 (gethash term env)))
                     ((consp term)
                      (and (known-p (car term) env (1+ depth))
                           (known-p (cdr term) env (1+ depth))))
                     ((logic-var-p term) (throw 'not-functional nil))
                     (t t)))
             (match-form (pattern value env k failure &optional (depth 0))
               (when (> depth 64) (throw 'not-functional nil))
               (cond ((anonymous-p pattern) (funcall k))
                     ((variable-symbol-p pattern)
                      (multiple-value-bind (old present) (gethash pattern env)
                        (if present
                            `(if (ground-equal ,old ,value) ,(funcall k) ,failure)
                            (progn (setf (gethash pattern env) value) (funcall k)))))
                     ((consp pattern)
                      (let ((a (gensym "CAR")) (b (gensym "CDR")))
                        `(if (consp ,value)
                             (let ((,a (car ,value)) (,b (cdr ,value)))
                               ,(match-form (car pattern) a env
                                            (lambda ()
                                              (match-form (cdr pattern) b env k failure (1+ depth)))
                                            failure (1+ depth)))
                             ,failure)))
                     ((logic-var-p pattern) (throw 'not-functional nil))
                     (t `(if (iso-atomic-equal ,(constant-ref pattern) ,value)
                             ,(funcall k) ,failure))))
             (match-many (patterns values env k failure)
               (if (null patterns) (funcall k)
                   (match-form (car patterns) (car values) env
                               (lambda () (match-many (cdr patterns) (cdr values) env k failure))
                               failure)))
             (arithmetic-form (term env &optional (depth 0))
               (when (> depth 64) (throw 'not-functional nil))
               (cond ((integerp term) term)
                     ((variable-symbol-p term) `(native-integer ,(value-form term env)))
                     ((and (consp term) (symbolp (car term)) (finite-list-p term))
                      (let* ((spelling (iso-predicate-name (car term) (length (cdr term))))
                             (args (cdr term)) (count (length args))
                             (operator (cdr (assoc spelling
                                                   '(("+" . +) ("-" . -) ("*" . *)
                                                     ("MOD" . mod) ("REM" . rem)
                                                     ("MIN" . min) ("MAX" . max)
                                                     ("ABS" . abs))
                                                   :test #'string=))))
                        (unless (and operator
                                     (if (eq operator 'abs) (= count 1)
                                         (if (member operator '(+ -))
                                             (member count '(1 2)) (= count 2))))
                          (throw 'not-functional nil))
                        (let ((operands (mapcar (lambda (argument)
                                                  (arithmetic-form argument env (1+ depth)))
                                                args)))
                          (if (member operator '(mod rem))
                              (let ((a (gensym "LEFT")) (b (gensym "RIGHT")))
                                `(let ((,a ,(first operands)) (,b ,(second operands)))
                                   (when (zerop ,b) (throw 'native-bailout nil))
                                   (,operator ,a ,b)))
                              `(,operator ,@operands)))))
                     (t (throw 'not-functional nil))))
             (goals-form (goals)
               (if (null goals)
                   (if enumeratep
                       `(funcall callback (1+ depth)
                                 ,@(loop for index in outputs
                                         collect (value-form (nth index (cdar clause)) env)))
                       `(return-from ,done
                          (values t ,@(loop for index in outputs
                                            collect (value-form (nth index (cdar clause)) env)))))
                   (let ((goal (car goals)))
                     (if (cut-goal-p goal)
                         (if enumeratep
                             (let* ((block (gensym "CUT-RIGHT")) (saved failure)
                                    (body (unwind-protect
                                              (progn (setf failure `(return-from ,block nil))
                                                     (goals-form (cdr goals)))
                                            (setf failure saved))))
                               `(return-from ,done (block ,block ,body)))
                             `(progn (setf ,committed t) ,(goals-form (cdr goals))))
                         (progn
                           (when (symbolp goal) (setf goal (list goal)))
                           (unless (and (consp goal) (symbolp (car goal)) (finite-list-p goal))
                             (throw 'not-functional nil))
                           (let* ((args (cdr goal)) (count (length args))
                                  (spelling (iso-predicate-name (car goal) count))
                                  (builtin (or (iso-primitive-p (car goal) count)
                                               (iso-syntax-p (car goal) count))))
                             (cond
                               ((and (string= spelling "TRUE") (null args)) (goals-form (cdr goals)))
                               ((and (member spelling '("FAIL" "FALSE") :test #'string=)
                                     (null args))
                                failure)
                               ((and (string= spelling "=") (= count 2) builtin)
                                (let (pattern expression)
                                  (cond ((known-p (second args) env)
                                         (setf pattern (first args)
                                               expression (value-form (second args) env)))
                                        ((known-p (first args) env)
                                         (setf pattern (second args)
                                               expression (value-form (first args) env)))
                                        (t (throw 'not-functional nil)))
                                  (let ((value (gensym "EQ")))
                                    `(let ((,value ,expression))
                                       ,(match-form pattern value env
                                                    (lambda () (goals-form (cdr goals))) failure)))))
                               ((and (string= spelling "FINDALL") (= count 3) builtin)
                                (let* ((template (first args)) (source (second args))
                                       (bag (third args))
                                       (nested (make-hash-table :test 'eq)))
                                  (maphash (lambda (key value) (setf (gethash key nested) value)) env)
                                  (unless (and (variable-symbol-p bag) (not (anonymous-p bag))
                                               (not (nth-value 1 (gethash bag env)))
                                               (not (contains-variable-p template bag))
                                               (not (contains-variable-p source bag)))
                                    (throw 'not-functional nil))
                                  (unless (and (consp source) (symbolp (car source))
                                               (finite-list-p source))
                                    (throw 'not-functional nil))
                                  (let* ((terms (cdr source))
                                         (inner-mask (loop for argument in terms for index from 0
                                                           when (known-p argument nested)
                                                             sum (ash 1 index)))
                                         (generator (funcall request (car source) (length terms)
                                                             inner-mask t))
                                         (in (loop for argument in terms for index from 0
                                                   when (logbitp index inner-mask)
                                                     collect (value-form argument nested)))
                                         (out (loop for argument in terms for index from 0
                                                    unless (logbitp index inner-mask) collect argument))
                                         (values (loop for argument in out collect (gensym "ITEM")))
                                         (collection (gensym "COLLECT"))
                                         (bag-value (gensym "BAG")))
                                    (unless (free-outputs-p out) (throw 'not-functional nil))
                                    `(let ((,collection nil))
                                       (,generator (1+ depth) ,@in
                                        (lambda (depth ,@values)
                                          (declare (ignorable depth))
                                          (native-budget-check budget depth)
                                          ,(match-many
                                            out values nested
                                            (lambda ()
                                              `(progn
                                                 (when (minusp (decf (native-budget-answers-left budget)))
                                                   (throw 'native-bailout nil))
                                                 (push (native-fresh-graph
                                                        ,(value-form template nested))
                                                       ,collection)))
                                            nil)))
                                       (let ((,bag-value (iso-list-from-host (nreverse ,collection))))
                                         ,(match-form bag bag-value env
                                                      (lambda () (goals-form (cdr goals)))
                                                      failure))))))
                               ((and (string= spelling "IS") (= count 2) builtin)
                                (let ((value (gensym "NUMBER")))
                                  `(let ((,value ,(arithmetic-form (second args) env)))
                                     ,(match-form (first args) value env
                                                  (lambda () (goals-form (cdr goals))) failure))))
                               ((and (member spelling '("<" "=<" ">" ">=" "=:=" "=\\=")
                                             :test #'string=)
                                     (= count 2) builtin)
                                (let ((operator (cond ((string= spelling "<") '<)
                                                      ((string= spelling "=<") '<=)
                                                      ((string= spelling ">") '>)
                                                      ((string= spelling ">=") '>=)
                                                      ((string= spelling "=:=") '=)
                                                      (t '/=))))
                                  `(if (,operator ,(arithmetic-form (first args) env)
                                                  ,(arithmetic-form (second args) env))
                                       ,(goals-form (cdr goals)) ,failure)))
                               (t
                                (when (or builtin
                                          (null (gethash
                                                 (cons (iso-resolve-name database (car goal) count)
                                                       count)
                                                 (database-predicates database))))
                                  (throw 'not-functional nil))
                                (let* ((mode-mask (loop for argument in args for index from 0
                                                        when (known-p argument env) sum (ash 1 index)))
                                       (callee (funcall request (car goal) count mode-mask enumeratep))
                                       (in (loop for argument in args for index from 0
                                                 when (logbitp index mode-mask)
                                                   collect (value-form argument env)))
                                       (out (loop for argument in args for index from 0
                                                  unless (logbitp index mode-mask) collect argument))
                                       (ok (gensym "OK"))
                                       (values (loop for argument in out collect (gensym "OUT"))))
                                  (unless (free-outputs-p out) (throw 'not-functional nil))
                                  (if enumeratep
                                      (let* ((block (gensym "NEXT")) (saved failure)
                                             (body (unwind-protect
                                                       (progn
                                                         (setf failure `(return-from ,block nil))
                                                         (match-many out values env
                                                                     (lambda () (goals-form (cdr goals)))
                                                                     failure))
                                                     (setf failure saved))))
                                        `(,callee (1+ depth) ,@in
                                          (lambda (depth ,@values)
                                            (declare (ignorable depth))
                                            (native-budget-check budget depth)
                                            (block ,block ,body))))
                                      `(multiple-value-bind (,ok ,@values)
                                           (,callee (1+ depth) ,@in)
                                         (if ,ok
                                             ,(match-many out values env
                                                          (lambda () (goals-form (cdr goals)))
                                                          failure)
                                             ,failure)))))))))))))
          (push `(let ((,committed nil))
                   (block ,failed
                     ,(match-many (loop for index in inputs collect (nth index (cdar clause)))
                                  parameters env
                                  (lambda () (goals-form (flatten-body (cdr clause))))
                                  failure))
                   (when ,committed (return-from ,done (values nil))))
                forms))))
    `(,function (depth ,@parameters ,@(when enumeratep '(callback)))
       (declare (optimize (speed 3) (safety 1) (debug 0)))
       (declare (ignorable depth))
       (native-budget-check budget depth)
       (block ,done ,@(nreverse forms) (values nil)))))

(defstruct (native-stack-template
             (:constructor make-native-stack-template
                 (entry parameters output-count definitions modes)))
  ;; Frozen, query-independent description of one verified mode group.
  entry parameters output-count definitions modes)

(defun compile-mode (database name arity mask &optional (enumeratep nil))
  "Compile a closed group of deterministic/semideterministic ground modes.
No VM bindings, effects or table operations occur inside this group."
  (let ((key (list database name arity mask enumeratep)))
    (when (member key *compiling-modes* :test #'equal) (return-from compile-mode nil))
    (let ((*database* database) (*term-model* (database-term-model database))
          (*compiling-modes* (cons key *compiling-modes*))
          (*compile-work* (or *compile-work* (list 128 0)))
          (*constants* (make-array 16 :adjustable t :fill-pointer 0))
          (*constant-index* (make-hash-table :test 'eq)))
      (catch 'not-functional
        (let ((nodes (make-hash-table :test 'equal)) (pending nil) (definitions nil))
          (labels ((request (name arity mask enumeratep)
                     (when (or (iso-primitive-p name arity) (iso-syntax-p name arity))
                       (throw 'not-functional nil))
                     (when (> arity *native-arity-limit*) (throw 'not-functional nil))
                     (let* ((name (iso-resolve-name database name arity))
                            (key (list name arity mask enumeratep)))
                       (or (gethash key nodes)
                           (progn
                             (unless (gethash (cons name arity)
                                              (database-predicates database))
                               (throw 'not-functional nil))
                             (when (gethash (cons name arity)
                                            (database-tabled database))
                               (throw 'not-functional nil))
                             (when (<= (first *compile-work*) 0) (throw 'not-functional nil))
                             (decf (first *compile-work*))
                             (let ((function (gensym "MODE")))
                               (setf (gethash key nodes) function)
                               (push (list key function) pending)
                               function))))))
            (let ((entry (request name arity mask enumeratep)))
              (loop while pending do
                (destructuring-bind (key function) (pop pending)
                  (push (emit-mode database (first key) (second key) (third key)
                                   (fourth key) function #'request)
                        definitions)))
              ;; The entry definition owns the fixed ABI; reuse its parameter names.
              (let* ((entry-form (find entry definitions :key #'first))
                     (entry-parameters (second entry-form))
                     (parameters (butlast (rest entry-parameters)
                                          (if enumeratep 1 0)))
                     (constants (coerce *constants* 'simple-vector))
                     (definitions (nreverse definitions)))
                (multiple-value-bind (function warnings failure)
                    (compile nil
                             `(lambda (constants budget depth ,@parameters
                                       ,@(when enumeratep '(callback)))
                                (declare (optimize (speed 3) (safety 1) (debug 0)))
                                (declare (ignorable depth constants
                                                    ,@(when enumeratep '(callback))))
                                (labels ,definitions
                                  (,entry depth ,@parameters
                                          ,@(when enumeratep '(callback))))))
                  (declare (ignore warnings))
                  (let ((function (accepted-generated-function function failure)))
                    (unless function (return-from compile-mode nil))
                    (make-native-mode
                     function constants
                     (unless enumeratep
                       (make-native-stack-template
                        entry parameters (- arity (logcount mask)) definitions
                        (loop for mode-key being the hash-keys of nodes
                              using (hash-value mode-function)
                              collect (list mode-function (second mode-key)
                                            (third mode-key) (fourth mode-key))))))))))))))))

;;; Explicit-stack tier.
;;;
;;; The tier above runs one activation per host frame, so deep semidet
;;; recursion exhausts the host stack. This tier lowers the same verified
;;; generated bodies of one mode group into a single TAGBODY: activations live
;;; in a private adjustable arena, calls jump to a static entry label after
;;; writing the callee frame, and returns dispatch on a dense integer token.
;;; Only known semidet calls suspend; every other generated form stays ordinary
;;; Lisp, and enumerated definitions keep their bounded Lisp recursion.

(defvar *stack-blocks* nil)
(defvar *stack-arena* nil)
(defvar *stack-base* nil)
(defvar *stack-top* nil)
(defvar *stack-result* nil)
(defvar *stack-success* nil)
(defvar *stack-return* nil)
(defvar *stack-resume* nil)
(defvar *stack-token* 0)
(defvar *stack-token-var* nil)
(defvar *stack-exit-name* nil)
(defvar *stack-mode-fail* nil)
(defvar *stack-dispatch* nil)
(defvar *stack-register* 0)
(defvar *stack-block* nil)
(defvar *stack-modes* nil)
(defvar *stack-entries* nil)
(defvar *stack-widths* nil)
(defvar *stack-empty-shadow* (make-hash-table :test 'eq))

(defun stack-new-label (name) (gensym name))
(defun stack-emit (form)
  (unless *stack-blocks* (error "Native stack lowerer emitted without a block"))
  (push form (cdr (car *stack-blocks*))))
(defun stack-tag (label) (push (cons label nil) *stack-blocks*))
(defun stack-tagbody-forms ()
  (loop for (label . forms) in (reverse *stack-blocks*)
        append (cons label (nreverse forms))))
(defun stack-alloc () (prog1 *stack-register* (incf *stack-register*)))
(defun stack-slot (slot) `(aref ,*stack-arena* (+ ,*stack-base* ,slot)))
(defun stack-copy-env (table)
  (let ((result (make-hash-table :test (hash-table-test table))))
    (maphash (lambda (key value) (setf (gethash key result) value)) table)
    result))
(defun stack-shadow (shadow names)
  (let ((result (stack-copy-env shadow)))
    (dolist (name names) (setf (gethash name result) t))
    result))
(defun stack-parse-let (form)
  "Return (values names inits body) for a generated LET with simple bindings."
  (let ((names nil) (inits nil))
    (dolist (binding (second form))
      (cond ((symbolp binding) (push binding names) (push nil inits))
            ((and (consp binding) (symbolp (first binding)) (null (cddr binding)))
             (push (first binding) names) (push (second binding) inits))
            (t (error "Native stack lowerer: unsupported LET binding ~S" binding))))
    (values (nreverse names) (nreverse inits) (cddr form))))

(defun stack-exit-form (value env shadow)
  "Translate a generated mode exit into a result publication and a jump."
  (cond
    ((and (consp value) (eq (first value) 'values))
     (if (second value)
         `(progn ,@(loop for out in (cddr value) for index from 0
                         collect `(setf (aref ,*stack-result* ,index)
                                        ,(stack-rewrite out env shadow)))
                 (setf ,*stack-success* t)
                 (go ,*stack-return*))
         `(progn (setf ,*stack-success* nil) (go ,*stack-return*))))
    ((null value) `(progn (setf ,*stack-success* nil) (go ,*stack-return*)))
    (t (error "Native stack lowerer: unsupported exit value ~S" value))))

(defun stack-rewrite (form env shadow)
  "Rewrite a non-suspending generated form, spilling bound variables to slots."
  (cond
    ((symbolp form)
     (cond ((gethash form shadow) form)
           ((gethash form env) (stack-slot (gethash form env)))
           (t form)))
    ((not (consp form)) form)
    ((eq (first form) 'quote) form)
    ((eq (first form) 'function) form)
    ((eq (first form) 'declare) nil)
    ((eq (first form) 'let)
     (multiple-value-bind (names inits body) (stack-parse-let form)
       `(let ,(loop for name in names for init in inits
                    collect (list name (stack-rewrite init env shadow)))
          ,@(let ((inner (stack-shadow shadow names)))
              (loop for item in body collect (stack-rewrite item env inner))))))
    ((eq (first form) 'lambda)
     (let ((inner (stack-shadow shadow (second form))))
       `(lambda ,(second form)
          ,@(loop for item in (cddr form) collect (stack-rewrite item env inner)))))
    ((eq (first form) 'multiple-value-bind)
     (let ((inner (stack-shadow shadow (second form))))
       `(multiple-value-bind ,(second form) ,(stack-rewrite (third form) env shadow)
          ,@(loop for item in (cdddr form) collect (stack-rewrite item env inner)))))
    ((eq (first form) 'block)
     `(block ,(second form)
        ,@(loop for item in (cddr form) collect (stack-rewrite item env shadow))))
    ((eq (first form) 'return-from)
     (if (eq (second form) *stack-exit-name*)
         (stack-exit-form (third form) env shadow)
         `(return-from ,(second form) ,(stack-rewrite (third form) env shadow))))
    ((eq (first form) 'setf)
     `(setf ,@(loop for (place value) on (cdr form) by #'cddr
                    append (list (cond ((and (symbolp place)
                                             (not (gethash place shadow))
                                             (gethash place env))
                                        (stack-slot (gethash place env)))
                                       ((consp place) (stack-rewrite place env shadow))
                                       (t place))
                                 (stack-rewrite value env shadow)))))
    (t `(,(first form)
         ,@(loop for item in (rest form) collect (stack-rewrite item env shadow))))))

(defun stack-lower-sequence (forms k env)
  (cond ((null forms) (stack-emit k))
        ((null (cdr forms)) (stack-lower-statement (car forms) k env))
        (t (let ((next (stack-new-label "SEQ")))
             (stack-lower-statement (car forms) `(go ,next) env)
             (stack-tag next)
             (stack-lower-sequence (cdr forms) k env)))))

(defun stack-lower-statement (form k env)
  "Lower one generated statement. K is the form emitted on normal completion."
  (cond
    ((atom form) (stack-emit k))
    (t (case (first form)
         (declare (stack-emit k))
         (progn (stack-lower-sequence (cdr form) k env))
         (if
          (let ((then (stack-new-label "THEN")) (otherwise (stack-new-label "ELSE")))
            (stack-emit `(if ,(stack-rewrite (second form) env *stack-empty-shadow*)
                             (go ,then) (go ,otherwise)))
            (stack-tag then) (stack-lower-statement (third form) k env)
            (stack-tag otherwise) (stack-lower-statement (fourth form) k env)))
         (when
          (stack-lower-statement `(if ,(second form) (progn ,@(cddr form)) nil) k env))
         (let (stack-lower-let form k env))
         (block (stack-lower-block form k env))
         (return-from (stack-lower-return form env))
         (multiple-value-bind (stack-lower-call form k env))
         (setf (stack-emit (stack-rewrite form env *stack-empty-shadow*))
               (stack-emit k))
         (t (stack-emit (stack-rewrite form env *stack-empty-shadow*))
            (stack-emit k))))))

(defun stack-lower-let (form k env)
  (multiple-value-bind (names inits body) (stack-parse-let form)
    (let* ((temps (loop repeat (length names) collect (gensym "INIT")))
           (slots (loop repeat (length names) collect (stack-alloc)))
           (inner (stack-copy-env env)))
      (stack-emit `(let ,(loop for temp in temps for init in inits
                               collect (list temp
                                             (stack-rewrite init env *stack-empty-shadow*)))
                     ,@(loop for slot in slots for temp in temps
                             collect `(setf ,(stack-slot slot) ,temp))))
      (loop for name in names for slot in slots do (setf (gethash name inner) slot))
      (stack-lower-sequence body k inner))))

(defun stack-lower-block (form k env)
  (let ((name (second form)))
    (if (eq name *stack-exit-name*)
        (stack-lower-sequence (cddr form) `(go ,*stack-mode-fail*) env)
        (let ((end (stack-new-label "BLOCK")))
          (let ((*stack-block* (acons name end *stack-block*)))
            (stack-lower-sequence (cddr form) `(go ,end) env))
          (stack-tag end)
          (stack-emit k)))))

(defun stack-lower-return (form env)
  (let ((name (second form)) (value (third form)))
    (if (eq name *stack-exit-name*)
        (stack-emit (stack-exit-form value env *stack-empty-shadow*))
        (let ((end (cdr (assoc name *stack-block*))))
          (unless end (error "Native stack lowerer: unknown block ~S" name))
          (when value (error "Native stack lowerer: unsupported block value ~S" value))
          (stack-emit `(go ,end))))))

(defun stack-lower-call (form k env)
  "Lower a known semidet call site into frame setup, jump and token resume."
  (destructuring-bind (variables call . body) (rest form)
    (unless (and (consp call) (symbolp (first call)))
      (error "Native stack lowerer: unsupported call ~S" call))
    (let ((mode (gethash (first call) *stack-modes*)))
      (unless mode (error "Native stack lowerer: unknown callee ~S" (first call)))
      (destructuring-bind (arity mask enumeratep) mode
        (when enumeratep
          (error "Native stack lowerer: enumerated callee ~S in a semidet body"
                 (first call)))
        (let* ((ins (rest (rest call)))
               (outs (rest variables))
               (entry (or (gethash (first call) *stack-entries*)
                          (error "Native stack lowerer: no entry for ~S"
                                 (first call))))
               (success (stack-new-label "RESUME"))
               (failure (stack-new-label "FAIL"))
               (continue (stack-new-label "BODY"))
               (success-token (prog1 *stack-token* (incf *stack-token*)))
               (failure-token (prog1 *stack-token* (incf *stack-token*)))
               (ok-slot (stack-alloc))
               (inner (stack-copy-env env)))
          (unless (= (length outs) (- arity (logcount mask)))
            (error "Native stack lowerer: output arity mismatch for ~S" (first call)))
          (unless (= (length ins) (logcount mask))
            (error "Native stack lowerer: input arity mismatch for ~S" (first call)))
          (let ((out-slots (loop repeat (length outs) collect (stack-alloc))))
            (push (cons success-token success) *stack-dispatch*)
            (push (cons failure-token failure) *stack-dispatch*)
            (stack-emit `(ensure-capacity (+ ,*stack-top* 3 ,(length ins))))
            (loop for in in ins for index from 0
                  do (stack-emit `(setf (aref ,*stack-arena*
                                             (+ ,*stack-top* ,(+ 3 index)))
                                       ,(stack-rewrite in env *stack-empty-shadow*))))
            (stack-emit `(setf (aref ,*stack-arena* ,*stack-top*) ,*stack-base*
                               (aref ,*stack-arena* (+ ,*stack-top* 1)) ,success-token
                               (aref ,*stack-arena* (+ ,*stack-top* 2)) ,failure-token
                               ,*stack-base* ,*stack-top*))
            (stack-emit `(go ,entry))
            (stack-tag success)
            (loop for slot in out-slots for index from 0
                  do (stack-emit `(setf ,(stack-slot slot)
                                        (aref ,*stack-result* ,index))))
            (loop for index below (length out-slots)
                  do (stack-emit `(setf (aref ,*stack-result* ,index) nil)))
            (stack-emit `(setf ,(stack-slot ok-slot) t))
            (stack-emit `(go ,continue))
            (stack-tag failure)
            (stack-emit `(setf ,(stack-slot ok-slot) nil))
            (loop for slot in out-slots
                  do (stack-emit `(setf ,(stack-slot slot) nil)))
            (stack-emit `(go ,continue))
            (stack-tag continue)
            (setf (gethash (first variables) inner) ok-slot)
            (loop for out in outs for slot in out-slots
                  do (setf (gethash out inner) slot))
            (stack-lower-sequence body k inner)))))))

(defun stack-lower-mode (definition fail)
  "Lower one verified semidet definition into entries, prologues and clauses."
  (let* ((function (first definition))
         (parameters (rest (second definition)))
         (mode (gethash function *stack-modes*))
         (mask (second mode))
         (entry (gethash function *stack-entries*))
         (forms (loop for form in (cddr definition)
                      unless (or (and (consp form) (eq (first form) 'declare))
                                 (and (consp form) (eq (first form) 'native-budget-check)))
                        collect form))
         (clause-block (and (consp (first forms))
                            (eq (first (first forms)) 'block)
                            (second (first forms))))
         (*stack-exit-name* (or clause-block function))
         (*stack-mode-fail* fail)
         (initial (+ 3 (length parameters))))
    (declare (ignore mask))
    (labels ((lower (content k)
               (let ((env (make-hash-table :test 'eq)))
                 (setf *stack-register* initial)
                 (loop for parameter in parameters for slot from 3
                       do (setf (gethash parameter env) slot))
                 (stack-lower-sequence content k env)
                 (setf (gethash function *stack-widths*)
                       (max *stack-register*
                            (gethash function *stack-widths* 0)))
                 *stack-register*))
             (prologue (label width body-label)
               (stack-tag label)
               (stack-emit `(ensure-capacity (+ ,*stack-base* ,width)))
               (stack-emit `(setf ,*stack-top* (+ ,*stack-base* ,width)))
               (stack-emit `(go ,body-label))))
      (stack-tag entry)
      (stack-emit '(native-stack-entry-check budget))
      (if clause-block
          (let* ((clauses (butlast (cddr (first forms))))
                 (count (length clauses))
                 (prologues (loop repeat count collect (stack-new-label "PROLOGUE")))
                 (entries (loop repeat count collect (stack-new-label "CLAUSE"))))
            (stack-emit `(go ,(first prologues)))
            (loop for clause in clauses
                  for index from 0
                  for label in prologues
                  for body-label in entries
                  do (progn
                       (stack-tag body-label)
                       (let* ((next (or (nth (1+ index) prologues) fail))
                              (width (lower (list clause) `(go ,next))))
                         (prologue label width body-label)))))
          (let ((label (stack-new-label "PROLOGUE"))
                (body-label (stack-new-label "CLAUSE")))
            (stack-emit `(go ,label))
            (stack-tag body-label)
            (prologue label (lower forms `(go ,fail)) body-label)))
      (stack-tag fail)
      (stack-emit `(setf ,*stack-success* nil))
      (stack-emit `(go ,*stack-return*)))))

(defun build-stack-function (template)
  "Compile the explicit-stack lambda for TEMPLATE.
Returns NIL when the host compiler rejects the generated form; unexpected
conditions propagate to the query cleaner."
  (let* ((entry (native-stack-template-entry template))
         (definitions (native-stack-template-definitions template))
         (modes (native-stack-template-modes template))
         (output-count (native-stack-template-output-count template))
         (result-width
           (loop for mode in modes
                 maximize (- (second mode) (logcount (third mode))) into width
                 finally (return (max width output-count))))
         (parameters (native-stack-template-parameters template))
         (root-prologue (stack-new-label "ROOT"))
         (begin (stack-new-label "BEGIN"))
         (exit (gensym "STACK"))
         (*stack-blocks* nil) (*stack-dispatch* nil) (*stack-token* 0)
         (*stack-block* nil) (*stack-register* 0)
         (*stack-modes* (make-hash-table :test 'eq))
         (*stack-entries* (make-hash-table :test 'eq))
         (*stack-widths* (make-hash-table :test 'eq))
         (*stack-arena* (gensym "ARENA")) (*stack-base* (gensym "BASE"))
         (*stack-top* (gensym "TOP")) (*stack-result* (gensym "RESULT"))
         (*stack-success* (gensym "SUCCESS")) (*stack-return* (gensym "RETURN"))
         (*stack-resume* (gensym "RESUME")) (*stack-token-var* (gensym "TOKEN"))
         (*stack-exit-name* nil) (*stack-mode-fail* nil))
    (stack-tag begin)
    (stack-emit `(go ,root-prologue))
    (dolist (mode modes)
      (setf (gethash (first mode) *stack-modes*) (rest mode))
      (unless (fourth mode)
        (setf (gethash (first mode) *stack-entries*) (stack-new-label "ENTRY")
              (gethash (first mode) *stack-widths*) 0)))
    (dolist (mode modes)
      (unless (fourth mode)
        (stack-lower-mode (find (first mode) definitions :key #'first)
                          (stack-new-label "MODEFAIL"))))
    ;; Return protocol: publish outputs, clear the dying frame, dispatch.
    (stack-tag *stack-return*)
    (stack-emit `(let* ((origin ,*stack-base*)
                        (parent (aref ,*stack-arena* origin))
                        (resume (if ,*stack-success*
                                    (aref ,*stack-arena* (+ origin 1))
                                    (aref ,*stack-arena* (+ origin 2)))))
                   (fill ,*stack-arena* nil :start origin :end ,*stack-top*)
                   (setf ,*stack-top* origin ,*stack-base* parent)
                   (if (minusp resume)
                       (return-from ,exit
                         (if ,*stack-success*
                             (values t
                                     ,@(loop for index below output-count
                                             collect `(aref ,*stack-result* ,index)))
                             (values nil)))
                       (progn (setf ,*stack-token-var* resume)
                              (go ,*stack-resume*)))))
    (stack-tag *stack-resume*)
    (stack-emit `(case ,*stack-token-var*
                   ,@(loop for (token . label) in (nreverse *stack-dispatch*)
                           collect `((,token) (go ,label)))
                   (t (error "Native stack tier resumed on unknown token ~D"
                             ,*stack-token-var*))))
    ;; Root activation: header sentinels, inputs and the starting frame.
    (stack-tag root-prologue)
    (stack-emit `(when (> ,(gethash entry *stack-widths*)
                          (native-budget-stack-slot-limit budget))
                   (throw 'native-bailout nil)))
    (stack-emit `(setf ,*stack-arena*
                       (make-array (min (native-budget-stack-slot-limit budget)
                                        (max 64 ,(gethash entry *stack-widths*)))
                                   :adjustable t :initial-element nil)
                       (aref ,*stack-arena* 0) -1
                       (aref ,*stack-arena* 1) -1
                       (aref ,*stack-arena* 2) -1))
    (loop for parameter in parameters for slot from 3
          do (stack-emit `(setf (aref ,*stack-arena* ,slot) ,parameter)))
    (stack-emit `(setf ,*stack-base* 0 ,*stack-top* 0))
    (stack-emit `(go ,(gethash entry *stack-entries*)))
    (let ((form
            `(lambda (constants budget depth ,@parameters)
                    (declare (optimize (speed 3) (safety 1) (debug 0)))
                    (declare (ignorable depth constants))
                    (labels (,@(loop for definition in definitions
                                     when (third (gethash (first definition)
                                                          *stack-modes*))
                                       collect definition))
                      (block ,exit
                        (let ((,*stack-arena* (make-array 0 :adjustable t
                                                          :initial-element nil))
                              (,*stack-result*
                                (make-array ,result-width :initial-element nil))
                              (,*stack-base* 0) (,*stack-top* 0)
                              (,*stack-token-var* -1) (,*stack-success* nil))
                          (declare (ignorable ,*stack-token-var*))
                          (flet ((ensure-capacity (needed)
                                   (cond ((> needed
                                             (native-budget-stack-slot-limit budget))
                                          (throw 'native-bailout nil))
                                         ((> needed (length ,*stack-arena*))
                                          (setf ,*stack-arena*
                                                (adjust-array
                                                 ,*stack-arena*
                                                 (min (native-budget-stack-slot-limit budget)
                                                      (max needed
                                                           (* 2 (length ,*stack-arena*))))))))))
                            (tagbody ,@(stack-tagbody-forms)))))))))
      (multiple-value-bind (function warnings failure)
          (compile nil form)
        (declare (ignore warnings))
        (accepted-generated-function function failure)))))

(defun compile-stack-mode (mode)
  "Return the cached explicit-stack function for MODE, compiling once.
NIL means this mode group is not available on the stack tier."
  (case (native-mode-stack-state mode)
    (:uncompiled
     (let ((template (native-mode-stack-template mode)))
       (setf (native-mode-stack-template mode) nil)
       (let ((function (and template (build-stack-function template))))
         (setf (native-mode-stack-function mode) function
               (native-mode-stack-state mode) (if function :ready :rejected))
         function)))
    (:ready (native-mode-stack-function mode))
    (t nil)))

;;; Instrumentation identity. Native code bypasses the WAM term dispatcher, so
;;; any replacement of the dispatcher or its provider must fall back to the VM.
(defvar *dispatch-baseline* nil)
(defun dispatch-baseline ()
  (or *dispatch-baseline*
      (let ((provider (provider-symbol 'execute-term-instruction)))
        (setf *dispatch-baseline*
              (list (symbol-function 'execute-term-instruction) provider
                    (and provider (symbol-function provider)))))))
(declaim (notinline dispatch-clean-p))
(defun dispatch-clean-p ()
  (let* ((baseline (dispatch-baseline))
         (provider (provider-symbol 'execute-term-instruction)))
    (and (eq (first baseline) (symbol-function 'execute-term-instruction))
         (eq (second baseline) provider)
         (eq (third baseline) (and provider (symbol-function provider))))))

(defun native-collect-ground-graph (root table)
  "Retain every cons of a dereference-clean ground input graph; reject variables."
  (let ((work (list root)))
    (loop while work do
      (let ((x (pop work)))
        (cond ((logic-var-p x) (return-from native-collect-ground-graph nil))
              ((consp x)
               (unless (gethash x table)
                 (setf (gethash x table) t)
                 (push (car x) work) (push (cdr x) work)))))))
  t)

(defun native-adopt-output (vm value retained seen)
  "Record every newly produced cons exactly once; inputs stay VM owned."
  (let ((work (list value)))
    (loop while work do
      (let ((x (pop work)))
        (cond ((logic-var-p x)
               (error "Native specializer produced a non-ground output: ~S" x))
              ((consp x)
               (unless (or (gethash x seen) (and retained (gethash x retained)))
                 (setf (gethash x seen) t)
                 (record-cell vm x)
                 (push (car x) work) (push (cdr x) work))))))))

(defun native-call (vm name arity tailp)
  "Specialize one predicate call. NIL declines without touching VM state;
T means the call was handled (success or logical failure)."
  (unless (and *native-enabled*
               (eq (database-execution-mode (machine-database vm)) :auto)
               (not (machine-slg-worker vm))
               (not (machine-slg vm))
               (not (machine-delays vm))
               (dispatch-clean-p))
    (return-from native-call nil))
  (let* ((database (machine-database vm))
         (*database* database)
         (*term-model* (database-term-model database))
         (generation (database-generation database))
         (cache (database-native-cache database)))
    (unless (and cache (= generation (car cache)))
      (setf cache (cons generation (make-hash-table :test 'equal))
            (database-native-cache database) cache))
    (let* ((arguments (machine-args vm))
           (mask (loop for index below arity
                       unless (logic-var-p (deref (elt arguments index)))
                         sum (ash 1 index)))
           (key (list name arity mask nil))
           (mode (multiple-value-bind (mode present) (gethash key (cdr cache))
                   (if present mode
                       (setf (gethash key (cdr cache))
                             (compile-mode database name arity mask nil))))))
      (when mode
        (let ((disabled (machine-native-disabled vm)))
          (when (and disabled (= generation (car disabled))
                     (gethash key (cdr disabled)))
            (return-from native-call nil)))
        ;; Unknown outputs must be distinct unbound logic variables.
        (let ((outputs nil) (open nil))
          (dotimes (index arity)
            (unless (logbitp index mask)
              (let ((value (deref (elt arguments index))))
                (when (member value outputs :test #'eq) (return-from native-call nil))
                (push value outputs) (push index open))))
          (let ((inputs nil) (retained nil))
            (dolist (index (loop for index below arity when (logbitp index mask) collect index))
              (let ((value (deref (elt arguments index))))
                (when (consp value)
                  (unless retained (setf retained (make-hash-table :test 'eq)))
                  (unless (native-collect-ground-graph value retained)
                    (return-from native-call nil))
                  (unless (iso-acyclic-p value) (return-from native-call nil)))
                (push value inputs)))
            (let* ((budget (make-native-budget
                            *native-fuel-limit* *native-depth-limit* *native-answer-limit*
                            (min *native-stack-slot-limit*
                                 (1- array-dimension-limit)
                                 (1- array-total-size-limit))))
                   (inputs (nreverse inputs))
                   (result (catch 'native-bailout
                             (multiple-value-list
                              (apply (native-mode-function mode)
                                     (native-mode-constants mode) budget 0 inputs)))))
              ;; A host-depth overflow promotes the identical attempt to the heap
              ;; tier once: same constants, same inputs, remaining budget only.
              (when (eq result :depth)
                (let ((stack (compile-stack-mode mode)))
                  (when stack
                    (setf result
                          (catch 'native-bailout
                            (multiple-value-list
                             (apply stack (native-mode-constants mode)
                                    budget 0 inputs)))))))
              ;; MULTIPLE-VALUE-LIST always yields a cons; a bailout value does not.
              (unless (consp result)
                (let ((disabled (machine-native-disabled vm)))
                  (unless (and disabled (= generation (car disabled)))
                    (setf disabled (cons generation (make-hash-table :test 'equal))
                          (machine-native-disabled vm) disabled))
                  (setf (gethash key (cdr disabled)) t))
                (incf (machine-native-deopts vm))
                (return-from native-call nil))
              (when (first result)
                (let ((values (rest result)) (positions (nreverse open)))
                  (unless (= (length values) (length positions))
                    (error "Native mode ~S returned ~D outputs for ~D positions"
                           key (length values) (length positions)))
                  (let ((seen (make-hash-table :test 'eq)))
                    (dolist (value values)
                      (native-adopt-output vm value retained seen)))
                  (loop for index in positions for value in values
                        do (unless (unify vm (elt arguments index) value)
                             (error "Native mode ~S produced an ununifiable output" key)))))
              (incf (machine-native-calls vm))
              (if (and (first result) tailp)
                  (restore-continuation vm)
                  (when (first result) (maybe-collect vm)))
              (unless (first result) (backtrack vm))
              t)))))))

(eval-when (:load-toplevel :execute)
  (register-provider 'ooparts/prolog/kernel/protocol:native-call 'native-call)
  ;; Capture the dispatch identity at load when the provider is already installed;
  ;; an uninstalled provider is captured on the first attempt instead.
  (when (provider-symbol 'execute-term-instruction) (dispatch-baseline)))
