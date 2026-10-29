(uiop:define-package #:ooparts/prolog/kernel/engine
  (:use #:cl)
  (:import-from #:ooparts/prolog/kernel/instructions
    #:allocate #:call #:clear-x #:cut #:deallocate #:enter-cut-scope #:execute #:fail #:host
    #:jump #:leave-cut-scope #:proceed #:retry-me-else #:table-answer #:tnot #:trust-me
    #:try-branch #:try-me-else #:yield)
  (:import-from #:ooparts/prolog/kernel/model
    #:*term-model* #:database-term-model
    #:%make-machine #:%make-var #:choice #:choice-age #:choice-args #:choice-builtin-context
    #:choice-code #:choice-continuation #:choice-cut #:choice-delays #:choice-handlers
    #:choice-heap #:choice-lineage #:choice-pc #:choice-scopes #:choice-slots #:choice-trail
    #:continuation #:continuation-builtin-context #:continuation-code #:continuation-cut
    #:continuation-depth #:continuation-handlers #:continuation-lineage #:continuation-parent
    #:continuation-pc #:continuation-scopes #:continuation-slots #:database
    #:database-predicates #:database-tabled #:iso-exception #:iso-exception-term #:iso-state
    #:logic-var #:logic-var-binding #:logic-var-id #:logic-var-p #:machine #:machine-allocations
    #:machine-args #:machine-builtin-context #:machine-choices #:machine-closed #:machine-code
    #:machine-continuation #:machine-cut #:machine-database #:machine-delays #:machine-gc-count
    #:machine-gc-reclaimed #:machine-heap #:machine-iso-handlers #:machine-max-choices
    #:machine-max-depth #:machine-max-heap #:machine-max-live #:machine-max-trail #:machine-pc
    #:machine-ready #:machine-scan #:machine-scopes #:machine-serial #:machine-slg
    #:machine-slg-bypass #:machine-slg-lineage #:machine-slg-paused #:machine-slg-root
    #:machine-slg-worker #:machine-slots #:machine-steps #:machine-trail #:machine-variables
    #:make-choice #:make-continuation #:make-database #:predicate-adapter-context
    #:predicate-code #:slot-ref #:slot-ref-index #:slot-ref-p)
  (:import-from #:ooparts/prolog/kernel/protocol
    #:ensure-registers #:execute-term-instruction #:iso-atom #:iso-atomic-equal #:iso-compound
    #:iso-execute #:iso-handle-exception #:iso-instruction-p #:iso-invoke #:iso-primitive-p
    #:iso-resolve-name #:iso-syntax-p #:iso-unknown #:maybe-collect #:slg-call #:slg-check-cut
    #:slg-check-database #:slg-close #:slg-enter-cut-frame #:slg-negative #:slg-return-answer
    #:slg-statistics #:slg-table-goal #:standard-predicate #:table)
  (:import-from #:ooparts/prolog/api/state)
  (:export #:*database* #:backtrack #:bind-var #:close-query #:deref #:fresh-cons #:fresh-var
    #:instantiate #:invoke-predicate #:map-term #:next-solution #:pop-clear #:predicate-key
    #:push-choice #:query-statistics #:record-cell #:reify #:resolve-code #:restore-continuation
    #:run-machine #:truncate-vector #:unify #:unwind-trail))
(in-package #:ooparts/prolog/kernel/engine)

(defvar *database* (make-database))

(defun pop-clear (vector)
  (let* ((index (1- (fill-pointer vector))) (value (aref vector index)))
    (setf (aref vector index) nil (fill-pointer vector) index)
    value))
(defun truncate-vector (vector mark)
  (loop for i from mark below (fill-pointer vector) do (setf (aref vector i) nil))
  (setf (fill-pointer vector) mark))

(defun record-cell (vm cell)
  (incf (machine-serial vm)) (incf (machine-allocations vm))
  (vector-push-extend cell (machine-heap vm))
  (setf (machine-max-heap vm)
        (max (machine-max-heap vm) (fill-pointer (machine-heap vm))))
  cell)
(defun fresh-var (vm)
  (let ((v (%make-var (machine-serial vm))))
    (setf (logic-var-binding v) v)
    (record-cell vm v)))
(defun fresh-cons (vm car cdr) (record-cell vm (cons car cdr)))
(defun deref (term)
  (loop while (and (logic-var-p term)
                   (not (eq term (logic-var-binding term))))
        do (setf term (logic-var-binding term)) finally (return term)))
(defun bind-var (vm var value)
  ;; Only variables older than the youngest choice need undo records.
  (let ((choices (machine-choices vm)))
    (when (and (plusp (fill-pointer choices))
               (< (logic-var-id var) (choice-age (aref choices (1- (fill-pointer choices))))))
      (vector-push-extend var (machine-trail vm))
      (setf (machine-max-trail vm)
            (max (machine-max-trail vm) (fill-pointer (machine-trail vm))))))
  (setf (logic-var-binding var) value))
(defun unwind-trail (vm mark)
  (loop while (> (fill-pointer (machine-trail vm)) mark) do
    (let* ((v (pop-clear (machine-trail vm))))
      (setf (logic-var-binding v) v))))

(defun unify (vm left right)
  "Iterative rational-tree unification; failure is rolled back by the VM."
  (let ((work (list (cons left right))) (seen (make-hash-table :test 'eq)))
    (loop while work do
      (let* ((pair (pop work)) (a (deref (car pair))) (b (deref (cdr pair))))
        (cond ((eq a b))
              ((logic-var-p a)
               (if (and (logic-var-p b) (< (logic-var-id a) (logic-var-id b)))
                   (bind-var vm b a) (bind-var vm a b)))
              ((logic-var-p b) (bind-var vm b a))
              ((and (consp a) (consp b))
               (let ((partners (or (gethash a seen)
                                   (setf (gethash a seen) (make-hash-table :test 'eq)))))
                 (unless (gethash b partners)
                   (setf (gethash b partners) t)
                   (push (cons (cdr a) (cdr b)) work)
                   (push (cons (car a) (car b)) work))))
              ((not (iso-atomic-equal a b)) (return-from unify nil)))))
    t))

(defun map-term (root atom-function &optional allocator)
  "Copy a cons graph without Lisp recursion, preserving sharing and cycles."
  (let* ((box (list nil)) (work (list (list root box :car)))
         (seen (make-hash-table :test 'eq)))
    (loop while work do
      (destructuring-bind (source target side) (pop work)
        (let* ((value (funcall atom-function source))
               (mapped (if (consp value)
                           (or (gethash value seen)
                               (let ((cell (if allocator (funcall allocator) (cons nil nil))))
                                 (setf (gethash value seen) cell)
                                 (push (list (cdr value) cell :cdr) work)
                                 (push (list (car value) cell :car) work)
                                 cell)) value)))
          (if (eq side :car) (setf (car target) mapped) (setf (cdr target) mapped)))))
    (car box)))
(defun instantiate (template slots &optional vm)
  (map-term template (lambda (x) (if (slot-ref-p x) (aref slots (slot-ref-index x)) x))
            (and vm (lambda () (fresh-cons vm nil nil)))))
(defun reify (term &optional (names (make-hash-table :test 'eq)))
  (map-term term (lambda (x)
                   (let ((v (deref x)))
                     (if (logic-var-p v)
                         (or (gethash v names)
                             (setf (gethash v names)
                                   (make-symbol (format nil "?G~D" (hash-table-count names)))))
                         v)))))

(defun predicate-key (goal)
  (unless (and (consp goal) (symbolp (car goal)) (listp (cdr goal)))
    (error "Invalid predicate: ~S" goal))
  (cons (car goal) (length (cdr goal))))
(defun resolve-code (vm name arity)
  (let ((definition (gethash (cons name arity)
                             (database-predicates (machine-database vm)))))
    (let ((definition (or definition (standard-predicate name arity))))
      (and definition (predicate-code definition)))))
(defun backtrack (vm)
  (when (zerop (fill-pointer (machine-choices vm)))
    (close-query vm)
    (return-from backtrack nil))
  (let ((cp (pop-clear (machine-choices vm))))
    (unwind-trail vm (choice-trail cp))
    (truncate-vector (machine-heap vm) (choice-heap cp))
    (setf (machine-builtin-context vm) (choice-builtin-context cp)
          (machine-iso-handlers vm) (choice-handlers cp)
          (machine-code vm) (choice-code cp) (machine-pc vm) (choice-pc cp)
          (machine-args vm) (choice-args cp)
          (machine-continuation vm) (choice-continuation cp)
          (machine-slg-lineage vm) (choice-lineage cp)
          (machine-delays vm) (choice-delays cp)
          (machine-cut vm) (choice-cut cp) (machine-scopes vm) (choice-scopes cp) (machine-slots vm) (choice-slots cp) (machine-scan vm) nil)
    t))
(defun push-choice (vm target &optional branchp)
  (vector-push-extend
   (make-choice :code (machine-code vm) :pc target
                :args (copy-seq (machine-args vm))
                :continuation (machine-continuation vm) :cut (machine-cut vm)
                :trail (fill-pointer (machine-trail vm))
                :heap (fill-pointer (machine-heap vm)) :age (machine-serial vm)
                :builtin-context (machine-builtin-context vm) :handlers (machine-iso-handlers vm) :lineage (machine-slg-lineage vm) :delays (machine-delays vm) :slots (and branchp (machine-slots vm)) :scopes (machine-scopes vm))
   (machine-choices vm))
  (setf (machine-max-choices vm)
        (max (machine-max-choices vm) (fill-pointer (machine-choices vm)))))
(defun restore-continuation (vm)
  (let ((c (machine-continuation vm)))
    (unless c (error "Missing VM continuation"))
    (setf (machine-builtin-context vm) (continuation-builtin-context c)
          (machine-iso-handlers vm) (continuation-handlers c)
          (machine-code vm) (continuation-code c)
          (machine-pc vm) (continuation-pc c)
          (machine-slots vm) (continuation-slots c)
          (machine-slg-lineage vm) (continuation-lineage c)
          (machine-cut vm) (continuation-cut c) (machine-scopes vm) (continuation-scopes c)
          (machine-continuation vm) (continuation-parent c)
          (machine-scan vm) nil)
    (fill (machine-args vm) nil)
    (maybe-collect vm)))
(defun invoke-predicate (vm name arity tailp)
  (when (or (iso-primitive-p name arity) (iso-syntax-p name arity))
    (return-from invoke-predicate (iso-invoke vm name arity tailp)))
  (setf name (iso-resolve-name (machine-database vm) name arity))
  (when (gethash (cons name arity) (database-tabled (machine-database vm)))
    (if (machine-slg-bypass vm) (setf (machine-slg-bypass vm) nil)
        (return-from invoke-predicate (slg-call vm name arity tailp))))
  (let ((code (resolve-code vm name arity)))
    (unless code
      (return-from invoke-predicate
        (if (gethash (cons name arity) (database-tabled (machine-database vm)))
            (backtrack vm) (iso-unknown vm name arity))))
    (when (zerop (length code)) (return-from invoke-predicate (backtrack vm)))
    (unless tailp
      (let ((depth (1+ (if (machine-continuation vm)
                          (continuation-depth (machine-continuation vm)) 0))))
        (setf (machine-continuation vm)
              (make-continuation :code (machine-code vm) :pc (machine-pc vm)
                                 :builtin-context (machine-builtin-context vm) :handlers (machine-iso-handlers vm) :lineage (machine-slg-lineage vm)
                                 :slots (machine-slots vm) :cut (machine-cut vm) :scopes (machine-scopes vm)
                                 :parent (machine-continuation vm) :depth depth)
              (machine-max-depth vm) (max depth (machine-max-depth vm)))))
    (when (machine-slg-worker vm)
      (slg-enter-cut-frame vm))
    (let ((library (standard-predicate name arity)))
      (when (and library (predicate-adapter-context library)
                 (null (machine-builtin-context vm)))
        (setf (machine-builtin-context vm)
              (iso-compound (iso-atom "/") name arity))))
    ;; A_i aliases X_i; only the actual arguments survive a call boundary.
    (setf (machine-args vm) (subseq (machine-args vm) 0 arity)
          (machine-code vm) code (machine-pc vm) 0 (machine-slots vm) nil
          (machine-scan vm) nil (machine-scopes vm) nil
          (machine-cut vm) (fill-pointer (machine-choices vm)))
    (maybe-collect vm)
    t))

;; This dispatch point is replaceable for instrumentation. Some native Lisp
;; linkers cache ordinary calls after the first invocation, so resolve the
;; current function cell explicitly (also preventing FUNCALL simplification).
(declaim (notinline execute-term-instruction))

(defun run-machine (vm)
  (loop until (machine-closed vm) do
    (when (machine-slg-paused vm) (return-from run-machine nil))
    (let* ((instruction (aref (machine-code vm) (machine-pc vm)))
           (op (car instruction)) (operands (cdr instruction)))
      (incf (machine-pc vm)) (incf (machine-steps vm))
      (handler-case
       (case op
        ((try-me-else retry-me-else) (push-choice vm (first operands)))
        (try-branch (push-choice vm (first operands) t))
        (jump (setf (machine-pc vm) (first operands)))
        (trust-me nil)
        (allocate
         (setf (machine-slots vm) (make-array (first operands) :initial-element nil))
         (ensure-registers vm (second operands)))
        (deallocate (setf (machine-slots vm) nil))
        (clear-x (fill (machine-args vm) nil) (setf (machine-scan vm) nil) (maybe-collect vm))
        (call (invoke-predicate vm (first operands) (second operands) nil))
        (execute (invoke-predicate vm (first operands) (second operands) t))
        (proceed (restore-continuation vm))
        (enter-cut-scope
         (push (cons (machine-cut vm) (machine-slg-lineage vm)) (machine-scopes vm))
         (when (machine-slg-worker vm)
           (slg-enter-cut-frame vm))
         (setf (machine-cut vm) (length (machine-choices vm))))
        (leave-cut-scope
         (let ((scope (pop (machine-scopes vm))))
           (setf (machine-cut vm) (car scope) (machine-slg-lineage vm) (cdr scope))))
        (table-answer (slg-return-answer vm (first operands) (second operands)
                                        (third operands) (fourth operands)))
        (tnot (slg-negative vm (first operands)))
        (cut (slg-check-cut vm)
             (truncate-vector (machine-choices vm) (machine-cut vm)))
        (fail (backtrack vm))
        (host
         (when (or (machine-slg-worker vm) (machine-delays vm))
           (error "Lisp callbacks are unsupported inside an SLG generator or conditional derivation"))
         (destructuring-bind (function arguments output testp) operands
           (let* ((names (make-hash-table :test 'eq))
                  (values (mapcar (lambda (arg)
                                    (reify (instantiate arg (machine-slots vm) vm) names))
                                  arguments))
                  (value (apply function values)))
             (unless (and (or (not testp) value)
                          (or (null output)
                              (unify vm (instantiate output (machine-slots vm) vm) value)))
               (backtrack vm)))))
        (yield (when (machine-slg vm) (slg-check-database vm))
               (setf (machine-ready vm) t) (return-from run-machine t))
        (otherwise
         (unless (if (iso-instruction-p op) (iso-execute vm op operands)
                     (funcall (symbol-function 'execute-term-instruction) vm op operands))
           (backtrack vm))))
       (iso-exception (condition) (iso-handle-exception vm condition)))))
  nil)

(defun close-query (vm)
  (when (and (machine-slg vm) (not (machine-slg-worker vm)))
    (slg-close (machine-slg vm)))
  (unwind-trail vm 0)
  (setf (machine-closed vm) t (machine-ready vm) nil
        (machine-builtin-context vm) nil (machine-iso-handlers vm) nil (machine-continuation vm) nil (machine-slots vm) nil (machine-scan vm) nil (machine-scopes vm) nil
        (machine-code vm) #() (machine-args vm) #()
        (machine-slg-paused vm) nil (machine-slg-lineage vm) nil
        (machine-variables vm) nil (machine-slg-root vm) nil (machine-delays vm) nil
        (machine-choices vm) (make-array 0 :adjustable t :fill-pointer 0)
        (machine-heap vm) (make-array 0 :adjustable t :fill-pointer 0)
        (machine-trail vm) (make-array 0 :adjustable t :fill-pointer 0))
  nil)
(defun next-solution (vm)
  "Return an alist and a success flag; an empty alist can still be a solution."
  (let ((*database* (machine-database vm))
        (*term-model* (database-term-model (machine-database vm))))
  (when (machine-closed vm) (return-from next-solution (values nil nil)))
  (when (machine-slg vm) (slg-check-database vm))
  (when (machine-ready vm)
    (setf (machine-ready vm) nil)
    (unless (backtrack vm) (return-from next-solution (values nil nil))))
  ;; Bind the result before testing it. ECL/MKCL's native compilers can
  ;; duplicate a HANDLER-CASE expression in conditional position, which would
  ;; resume the VM a second time after YIELD without backtracking.
  (let ((foundp (handler-case (run-machine vm)
                  (error (condition)
                    ;; Abort an interrupted cursor before re-signaling.
                    (close-query vm)
                    (error condition)))))
    (when foundp
      (let ((names (make-hash-table :test 'eq)))
        (return-from next-solution
          (values (mapcar (lambda (entry) (cons (car entry) (reify (cdr entry) names)))
                          (machine-variables vm)) t
                  (if (machine-delays vm) :undefined :true)
                  (mapcar (lambda (table) (slg-table-goal (machine-slg vm) table))
                          (machine-delays vm)))))))
  (values nil nil)))
(defun query-statistics (vm)
  (list :instructions (machine-steps vm) :max-continuation-depth (machine-max-depth vm)
        :max-choice-points (machine-max-choices vm)
        :allocated-cells (machine-allocations vm) :heap-cells (fill-pointer (machine-heap vm))
        :max-heap-cells (machine-max-heap vm) :trail-cells (fill-pointer (machine-trail vm))
        :max-trail-cells (machine-max-trail vm) :gc-count (machine-gc-count vm)
        :gc-reclaimed (machine-gc-reclaimed vm) :max-live-cells (machine-max-live vm)
        :slg (and (machine-slg vm) (slg-statistics (machine-slg vm)))))
