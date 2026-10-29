(uiop:define-package #:ooparts/prolog/src/kernel/runtime
  (:use #:cl)
  (:import-from #:ooparts/prolog/src/adapters/term-ops
    #:iso-atom #:iso-atom-name #:iso-bind #:iso-compound #:iso-copy #:iso-error #:iso-required
    #:iso-unifiable-p)
  (:import-from #:ooparts/prolog/src/api/state
    #:*iso-aliases*)
  (:import-from #:ooparts/prolog/src/kernel/engine
    #:backtrack #:fresh-var #:push-choice #:truncate-vector #:unify #:unwind-trail)
  (:import-from #:ooparts/prolog/src/kernel/instructions
    #:iso-answer #:iso-catch-end #:iso-catch-fail #:proceed #:try-branch)
  (:import-from #:ooparts/prolog/src/kernel/model
    #:choice-age #:choice-args #:choice-builtin-context #:choice-code #:choice-continuation
    #:choice-cut #:choice-delays #:choice-heap #:choice-lineage #:choice-pc #:choice-scopes
    #:choice-slots #:choice-trail #:continuation-depth #:database #:database-predicates
    #:iso-exception-term #:iso-handler #:iso-handler-catcher #:iso-handler-parent
    #:iso-handler-recovery #:iso-handler-snapshot #:iso-handler-tailp #:logic-var-p
    #:machine-args #:machine-builtin-context #:machine-choices #:machine-code
    #:machine-continuation #:machine-cut #:machine-database #:machine-delays #:machine-heap
    #:machine-iso-handlers #:machine-max-depth #:machine-pc #:machine-scopes
    #:machine-slg-lineage #:machine-slg-worker #:machine-slots #:machine-trail #:make-choice
    #:make-continuation #:make-iso-handler)
  (:import-from #:ooparts/prolog/src/kernel/protocol
    #:iso-flag-value)
  (:import-from #:ooparts/prolog/src/kernel/slg
    #:slg-enter-cut-frame #:table)
  (:import-from #:ooparts/prolog/src/syntax/compiler
    #:goal-instructions)
  (:import-from #:ooparts/prolog/src/syntax/control-syntax
    #:validate-call-body)
  (:import-from #:ooparts/prolog/src/syntax/dcg
    #:finite-list-p)
  (:import-from #:ooparts/prolog/src/syntax/wam-compiler
    #:lower-wam-code)
  (:import-from #:ooparts/prolog/src/kernel/protocol #:register-provider)
  (:export #:iso-alternatives #:iso-catch #:iso-enter #:iso-execute #:iso-goal
    #:iso-handle-exception #:iso-instruction-p #:iso-predicate-name #:iso-resolve-name
    #:iso-result #:iso-rule-functor-p #:iso-save-continuation #:iso-unknown))
(in-package #:ooparts/prolog/src/kernel/runtime)


;;; Runtime goal compilation uses existing logic variables as Y-register roots.
(defun iso-goal (term)
  (let ((term (iso-required term)))
    (cond ((and (consp term) (finite-list-p term) (symbolp (car term))) term)
          ((symbolp term) (list term))
          (t (iso-error "type_error" (iso-atom "callable") term)))))
(defun iso-predicate-name (symbol arity)
  (let ((name (string-upcase (symbol-name symbol))))
    (or (gethash (cons name arity) *iso-aliases*) name)))
(defun iso-rule-functor-p (symbol)
  (and (symbolp symbol)
       (member (string-upcase (symbol-name symbol)) '(":-" "RULE") :test #'string=)))
(defun iso-save-continuation (vm)
  (let ((depth (1+ (if (machine-continuation vm) (continuation-depth (machine-continuation vm)) 0))))
    (setf (machine-continuation vm)
          (make-continuation :code (machine-code vm) :pc (machine-pc vm) :slots (machine-slots vm)
                            :cut (machine-cut vm) :scopes (machine-scopes vm) :lineage (machine-slg-lineage vm)
                            :builtin-context (machine-builtin-context vm) :handlers (machine-iso-handlers vm) :parent (machine-continuation vm) :depth depth)
          (machine-max-depth vm) (max depth (machine-max-depth vm)))))
(defun iso-enter (vm goal &optional tailp suffix)
  (validate-call-body goal)
  (let* ((table (make-hash-table :test 'eq)) (counter (list 0))
         (ir (goal-instructions (iso-goal goal) table counter (null suffix)))
         (code (lower-wam-code ir (car counter) t))
         (slots (make-array (car counter))))
    (maphash (lambda (var index) (setf (aref slots index) (if (logic-var-p var) var (fresh-var vm)))) table)
    (unless tailp (iso-save-continuation vm))
    (when (machine-slg-worker vm) (slg-enter-cut-frame vm))
    (setf (machine-code vm) (coerce (append code suffix '((proceed))) 'vector)
          (machine-pc vm) 0 (machine-slots vm) slots (machine-scopes vm) nil
          (machine-cut vm) (length (machine-choices vm))) t))
(defun iso-unknown (vm name arity)
  (case (iso-flag-value (machine-database vm) "unknown")
    (:fail (backtrack vm))
    (:warning (warn "Undefined Prolog predicate ~S/~D" name arity) (backtrack vm))
    (otherwise (iso-error "existence_error" (iso-atom "procedure")
                          (iso-compound (iso-atom "/") name arity)))))
(defun iso-resolve-name (database name arity)
  (or (and (gethash (cons name arity) (database-predicates database)) name)
      (loop for key being the hash-keys of (database-predicates database)
            when (and (= arity (cdr key)) (string= (iso-atom-name name) (iso-atom-name (car key)))) return (car key))
      name))
(defun iso-alternatives (vm alternatives tailp)
  "Install finite alternatives on the WAM choice stack, never on the Lisp stack."
  (unless alternatives (return-from iso-alternatives (backtrack vm)))
  (unless tailp (iso-save-continuation vm))
  (let ((code (make-array 0 :adjustable t :fill-pointer 0)))
    (loop for rest on alternatives do
      (let ((branch (and (cdr rest) (list 'try-branch nil))))
        (when branch (vector-push-extend branch code))
        (vector-push-extend (list 'iso-answer (caar rest) (cdar rest)) code)
        (vector-push-extend '(proceed) code)
        (when branch (setf (second branch) (length code)))))
    (setf (machine-code vm) code (machine-pc vm) 0) t))
(defun iso-result (args &optional action) (cons args action))
(defun iso-instruction-p (op) (member op '(iso-answer iso-catch-end iso-catch-fail)))
(defun iso-execute (vm op operands)
  (case op
    (iso-answer
     (let ((values (iso-copy (first operands) vm)))
       (and (loop for x in values for i from 0 always (iso-bind vm (aref (machine-args vm) i) x))
            (or (null (second operands)) (funcall (second operands))))))

    (iso-catch-fail (backtrack vm))
    (iso-catch-end (setf (machine-iso-handlers vm) (iso-handler-parent (machine-iso-handlers vm))) t)))

(defun iso-catch (vm goal catcher recovery tailp)
  ;; Save the protected call's entry state; choice points retain handler chains.
  (let ((snapshot (make-choice :code (machine-code vm) :pc (machine-pc vm)
                              :args (copy-seq (machine-args vm)) :slots (machine-slots vm)
                              :continuation (machine-continuation vm) :cut (machine-cut vm)
                              :scopes (machine-scopes vm) :lineage (machine-slg-lineage vm)
                              :delays (machine-delays vm) :heap (length (machine-heap vm))
                              :trail (length (machine-trail vm)) :age (length (machine-choices vm))
                              :builtin-context (machine-builtin-context vm) :handlers (machine-iso-handlers vm))))
    (let ((code (machine-code vm)) (pc (machine-pc vm)))
      (setf (machine-code vm) #((iso-catch-fail)) (machine-pc vm) 0)
      (push-choice vm 0 t)
      (setf (machine-code vm) code (machine-pc vm) pc))
    (unless tailp (iso-save-continuation vm))
    (setf (machine-iso-handlers vm)
          (make-iso-handler :snapshot snapshot :catcher catcher :recovery recovery
                           :parent (machine-iso-handlers vm) :tailp tailp))
    (iso-enter vm goal t '((iso-catch-end)))))
(defun iso-handle-exception (vm exception)
  (let ((ball (iso-copy (iso-exception-term exception))) (handler (machine-iso-handlers vm)))
    (loop while handler do
      (let* ((cp (iso-handler-snapshot handler)) (catcher (iso-handler-catcher handler))
             (recovery (iso-handler-recovery handler)))
          (setf (machine-iso-handlers vm) (iso-handler-parent handler))
          (unwind-trail vm (choice-trail cp))
          (truncate-vector (machine-heap vm) (choice-heap cp))
          (truncate-vector (machine-choices vm) (choice-age cp))
          (setf (machine-builtin-context vm) (choice-builtin-context cp)
                (machine-code vm) (choice-code cp) (machine-pc vm) (choice-pc cp)
                (machine-slots vm) (choice-slots cp) (machine-args vm) (choice-args cp)
                (machine-continuation vm) (choice-continuation cp) (machine-cut vm) (choice-cut cp)
                (machine-scopes vm) (choice-scopes cp) (machine-slg-lineage vm) (choice-lineage cp)
                (machine-delays vm) (choice-delays cp))
          (when (iso-unifiable-p catcher ball)
            (unify vm catcher (iso-copy ball vm))
            (return-from iso-handle-exception (iso-enter vm recovery (iso-handler-tailp handler)))))
      (setf handler (iso-handler-parent handler)))
    (error exception)))

(eval-when (:load-toplevel :execute)
  (register-provider 'ooparts/prolog/src/kernel/protocol:iso-execute 'iso-execute)
  (register-provider 'ooparts/prolog/src/kernel/protocol:iso-goal 'iso-goal)
  (register-provider 'ooparts/prolog/src/kernel/protocol:iso-handle-exception 'iso-handle-exception)
  (register-provider 'ooparts/prolog/src/kernel/protocol:iso-instruction-p 'iso-instruction-p)
  (register-provider 'ooparts/prolog/src/kernel/protocol:iso-predicate-name 'iso-predicate-name)
  (register-provider 'ooparts/prolog/src/kernel/protocol:iso-resolve-name 'iso-resolve-name)
  (register-provider 'ooparts/prolog/src/kernel/protocol:iso-unknown 'iso-unknown)
)
