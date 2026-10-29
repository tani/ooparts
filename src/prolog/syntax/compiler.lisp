(uiop:define-package #:ooparts/prolog/syntax/compiler
  (:use #:cl)
  (:import-from #:ooparts/prolog/kernel/engine
    #:*database* #:close-query #:deref #:fresh-var #:map-term #:next-solution #:predicate-key
    #:unify)
  (:import-from #:ooparts/prolog/kernel/instructions
    #:allocate #:call #:cut #:dcg-internal #:execute #:fail #:get-term #:host #:jump
    #:or-branches #:proceed #:put-args #:retry-me-else #:scoped-body #:tnot #:true #:trust-me
    #:try-branch #:try-me-else #:yield)
  (:import-from #:ooparts/prolog/kernel/model
    #:*term-model* #:database-term-model
    #:database-iso-state #:iso-state-loaded-files #:iso-state-declarations #:iso-state-dynamic #:%make-machine #:database #:database-generation #:database-predicates #:database-tabled
    #:disjunction-goal-branches #:disjunction-goal-p #:host-goal #:host-goal-arguments
    #:host-goal-function #:host-goal-output #:host-goal-p #:host-goal-testp #:logic-var-p
    #:machine-slots #:machine-variables #:make-predicate #:predicate #:predicate-clauses
    #:predicate-code #:scoped-goals-goals #:scoped-goals-p #:sequence-goals
    #:sequence-goals-goals #:sequence-goals-p #:slot-ref)
  (:import-from #:ooparts/prolog/kernel/protocol
    #:iso-atom #:iso-builtin-p #:iso-compound #:iso-error #:iso-goal #:iso-predicate-name
    #:lower-wam-code #:table)
  (:import-from #:ooparts/prolog/syntax/control-syntax
    #:iso-control-form-p #:iso-control-instructions #:validate-static-meta-goal)
  (:import-from #:ooparts/prolog/syntax/dcg
    #:expand-query-goals)
  (:import-from #:ooparts/prolog/api/state)
  (:import-from #:ooparts/prolog/kernel/protocol #:register-provider)
  (:export #:add-clause #:anonymous-p #:clear-database #:compile-clause #:compile-predicate
    #:control-goal-p #:disassemble-predicate #:goal-instructions #:make-query #:query
    #:term-template #:variable-symbol-p #:variables-in))
(in-package #:ooparts/prolog/syntax/compiler)

(defun variable-symbol-p (x)
  (and (symbolp x)
       (not (and (find-package :ooparts/prolog/atoms)
                 (eq (symbol-package x) (find-package :ooparts/prolog/atoms))))
       (plusp (length (symbol-name x)))
       (char= #\? (char (symbol-name x) 0))))
(defun anonymous-p (x) (and (variable-symbol-p x) (string= (symbol-name x) "?")))
(defun variables-in (form)
  (let ((result nil) (seen (make-hash-table :test 'eq))
        (cells (make-hash-table :test 'eq)) (work (list form)))
    (loop while work do
      (let* ((x (pop work)))
        (cond ((and (variable-symbol-p x) (not (anonymous-p x)))
               (unless (gethash x seen) (setf (gethash x seen) t) (push x result)))
              ((consp x) (unless (gethash x cells)
                           (setf (gethash x cells) t)
                           (push (cdr x) work) (push (car x) work))))))
    (nreverse result)))
(defun term-template (term table counter)
  (map-term term
    (lambda (x)
      (when (logic-var-p x) (setf x (deref x)))
      (if (or (variable-symbol-p x) (logic-var-p x))
          (slot-ref
           (if (anonymous-p x) (prog1 (car counter) (incf (car counter)))
               (or (gethash x table)
                   (setf (gethash x table) (prog1 (car counter) (incf (car counter))))))
           (anonymous-p x))
          x))))
(defun control-goal-p (goal name)
  (let ((symbol (if (and (consp goal) (null (cdr goal))) (car goal) goal)))
    (and (symbolp symbol) (string= (symbol-name symbol) name))))
(defun goal-instructions (goal table counter tailp)
  (when (and (consp goal) (symbolp (car goal))
             (member (iso-predicate-name (car goal) (length (cdr goal)))
                     '("ONCE" "\\+") :test #'string=))
    (validate-static-meta-goal goal))
  (flet ((template (x) (term-template x table counter)))
    (cond
      ((iso-control-form-p goal)
       (iso-control-instructions goal table counter tailp))
      ((sequence-goals-p goal)
       (loop for rest on (sequence-goals-goals goal)
             append (goal-instructions (car rest) table counter (and tailp (null (cdr rest))))))
      ((scoped-goals-p goal)
       (list (list 'scoped-body
                   (loop for child in (scoped-goals-goals goal)
                         append (goal-instructions child table counter nil)))))
      ((disjunction-goal-p goal)
       (list (list 'or-branches
                   (mapcar (lambda (branch)
                             (loop for child in branch append (goal-instructions child table counter nil)))
                           (disjunction-goal-branches goal)))))
      ((and (consp goal) (symbolp (car goal)) (string= (symbol-name (car goal)) "TNOT"))
       (unless (= (length goal) 2) (error "TNOT takes one goal"))
       (let ((target (iso-goal (second goal))))
         (predicate-key target)
         (list (list 'tnot (template target)))))
      ((host-goal-p goal)
       (list (list 'host (host-goal-function goal)
                   (mapcar #'template (host-goal-arguments goal))
                   (and (host-goal-output goal) (template (host-goal-output goal)))
                   (host-goal-testp goal))))
      ((control-goal-p goal "!") (list '(cut)))
      ((control-goal-p goal "TRUE") nil)
      ((control-goal-p goal "FAIL") (list '(fail)))
      ((and (consp goal) (symbolp (car goal))
            (string= (symbol-name (car goal)) "="))
       (unless (= (length goal) 3) (error "~A takes two arguments" (car goal)))
       (list (list 'unify (template (second goal)) (template (third goal)))))
      ((equal goal '(true)) nil)
      ((equal goal '(fail)) (list '(fail)))
      (t (when (and (symbolp goal) (not (variable-symbol-p goal)))
           (setf goal (list goal)))
         (let ((key (predicate-key goal)))
           (list (list 'put-args (mapcar #'template (cdr goal)))
                 (list (if tailp 'execute 'call) (car key) (cdr key))))))))
(defun compile-clause (head body)
  (let* ((table (make-hash-table :test 'eq)) (counter (list 0))
         (heads (loop for term in (cdr head) for i from 0
                      collect (list 'get-term i (term-template term table counter))))
         (instructions nil))
    (loop for rest on body do
      (setf instructions (nconc instructions
                                (goal-instructions (car rest) table counter (null (cdr rest))))))
    (unless (and instructions (eq (caar (last instructions)) 'execute))
      (setf instructions (nconc instructions (list '(proceed)))))
    (append (list (list 'allocate (car counter))) heads instructions)))
(defun compile-predicate (clauses)
  (let ((code (make-array 16 :adjustable t :fill-pointer 0)))
    (loop for rest on clauses for index from 0 do
      (let* ((clause (car rest)) (position (fill-pointer code))
             (branch (if (cdr rest) (list (if (zerop index) 'try-me-else 'retry-me-else) nil)
                         (list 'trust-me))))
        (vector-push-extend branch code)
        (let ((origin (fill-pointer code)))
        (dolist (instruction (let ((ir (compile-clause (car clause) (cdr clause))))
                              (lower-wam-code ir (second (car ir)) nil)))
          (vector-push-extend
           (if (member (car instruction) '(try-branch jump))
               (list (car instruction) (+ origin (second instruction))) instruction) code)))
        (when (cdr rest) (setf (second (aref code position)) (fill-pointer code)))))
    (coerce code 'simple-vector)))
(defun add-clause (head body replacep &optional (database *database*))
  (let ((*database* database) (*term-model* (database-term-model database)))
  ;; Publish a fresh code vector. In-flight calls retain their old alternatives.
  (let ((key (predicate-key head)))
    (when (iso-builtin-p (car key) (cdr key))
      (iso-error "permission_error" (iso-atom "modify") (iso-atom "static_procedure")
                 (iso-compound (iso-atom "/") (car key) (cdr key)))))
  (let* ((key (predicate-key head))
         (old (gethash key (database-predicates database)))
         (clauses (append (unless replacep (and old (predicate-clauses old)))
                          (list (cons head body))))
         (new (make-predicate :clauses clauses :code (compile-predicate clauses))))
    (incf (database-generation database))
    (setf (gethash key (database-predicates database)) new)
    (values (car key) (cdr key)))))
(defun clear-database (&optional (database *database*))
  (incf (database-generation database))
  (clrhash (database-tabled database))
  (clrhash (database-predicates database))
  (when (database-iso-state database)
    (clrhash (iso-state-loaded-files (database-iso-state database)))
    (clrhash (iso-state-declarations (database-iso-state database)))
    (clrhash (iso-state-dynamic (database-iso-state database)))) nil)
(defun make-query (goals &key (database *database*) (gc-threshold 4096))
  (let ((*database* database) (*term-model* (database-term-model database)))
  (unless (or (null gc-threshold) (and (integerp gc-threshold) (plusp gc-threshold)))
    (error "GC-THRESHOLD must be NIL or a positive integer"))
  (let* ((table (make-hash-table :test 'eq)) (counter (list 0))
         (code (loop for goal in (expand-query-goals goals)
                     append (goal-instructions goal table counter nil)))
         (instructions (lower-wam-code code (car counter) t))
         (vm (%make-machine :database database
                            :gc-floor gc-threshold :gc-limit gc-threshold
                            :code (coerce (append instructions '((yield))) 'vector)))
         (slots (make-array (car counter))))
    (dotimes (i (length slots)) (setf (aref slots i) (fresh-var vm)))
    (setf (machine-slots vm) slots
          (machine-variables vm)
          (sort (loop for name being the hash-keys of table using (hash-value index)
                      when (and (symbolp name) (not (get name 'dcg-internal))) collect (cons name (aref slots index)))
                #'< :key (lambda (entry) (gethash (car entry) table))))
    vm)))
(defun query (goals &key truth-values limit (database *database*) (gc-threshold 4096))
  "Collect solutions. Use MAKE-QUERY/NEXT-SOLUTION for streaming or large searches."
  (when (and limit (not (and (integerp limit) (>= limit 0))))
    (error "LIMIT must be NIL or a nonnegative integer"))
  (let ((vm (make-query goals :database database :gc-threshold gc-threshold)) (solutions nil) (count 0))
    (unwind-protect
         (loop until (and limit (>= count limit)) do
           (multiple-value-bind (solution foundp truth delays) (next-solution vm)
             (unless foundp (return))
             (when (or truth-values (eq truth :true))
               (push (if truth-values (list :truth truth :bindings solution :delays delays) solution)
                     solutions)
               (incf count))))
      (close-query vm))
    (nreverse solutions)))
(defun disassemble-predicate (name arity &optional (stream *standard-output*))
  (let ((p (gethash (cons name arity) (database-predicates *database*))))
    (unless p (error "Unknown predicate ~S/~D" name arity))
    (loop for instruction across (predicate-code p) for pc from 0 do
      (format stream "~4D  ~S~%" pc instruction))))

(eval-when (:load-toplevel :execute)
  (register-provider 'ooparts/prolog/kernel/protocol:goal-instructions 'goal-instructions)
  (register-provider 'ooparts/prolog/kernel/protocol:query 'query)
  (register-provider 'ooparts/prolog/kernel/protocol:variable-symbol-p 'variable-symbol-p)
)
