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
(defvar *native-arity-limit*
  (min 64 (- call-arguments-limit 4) (- lambda-parameters-limit 4)
       (1- multiple-values-limit)))

(defvar *compiling-modes* nil)
(defvar *compile-work* nil)
(defvar *constants* nil)
(defvar *constant-index* nil)

(defstruct (native-mode (:constructor make-native-mode (function constants)))
  function constants)
(defstruct (native-budget (:constructor make-native-budget (fuel depth-limit answers-left)))
  fuel (depth-limit 0 :read-only t) answers-left)

(declaim (inline native-budget-fuel native-budget-depth-limit native-budget-answers-left
                 native-mode-function native-mode-constants native-integer native-budget-check))
(defun native-integer (value)
  (unless (integerp value) (throw 'native-bailout nil)) value)
(defun native-budget-check (budget depth)
  "Fail the whole attempt once its logical depth or fuel is exhausted."
  (when (or (> depth (native-budget-depth-limit budget))
            (minusp (decf (native-budget-fuel budget))))
    (throw 'native-bailout nil)))

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
                     (constants (coerce *constants* 'simple-vector)))
                (multiple-value-bind (function warnings failure)
                    (compile nil
                             `(lambda (constants budget depth ,@parameters
                                       ,@(when enumeratep '(callback)))
                                (declare (optimize (speed 3) (safety 1) (debug 0)))
                                (declare (ignorable depth constants
                                                    ,@(when enumeratep '(callback))))
                                (labels ,(nreverse definitions)
                                  (,entry depth ,@parameters
                                          ,@(when enumeratep '(callback))))))
                  (declare (ignore warnings))
                  (when failure (return-from compile-mode nil))
                  (make-native-mode function constants))))))))))

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
            (let* ((budget (make-native-budget *native-fuel-limit* *native-depth-limit*
                                               *native-answer-limit*))
                   (result (catch 'native-bailout
                             (multiple-value-list
                              (apply (native-mode-function mode)
                                     (native-mode-constants mode) budget 0
                                     (nreverse inputs))))))
              (unless result
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
