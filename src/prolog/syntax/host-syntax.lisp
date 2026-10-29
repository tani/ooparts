(uiop:define-package #:ooparts/prolog/syntax/host-syntax
  (:use #:cl)
  (:import-from #:ooparts/prolog/kernel/model
    #:*term-model* #:database-term-model #:disjunction-goal-branches #:disjunction-goal-p #:make-disjunction-goal #:make-host-goal
    #:make-scoped-goals #:make-sequence-goals #:scoped-goals-goals #:scoped-goals-p)
  (:import-from #:ooparts/prolog/syntax/compiler
    #:variables-in)
  (:import-from #:ooparts/prolog/syntax/dcg
    #:expand-query-goals #:finite-list-p)
  (:import-from #:ooparts/prolog/syntax/let-syntax
    #:let-goal-form #:lexical-binding-value)
  (:import-from #:ooparts/prolog/kernel/engine #:*database*)
  (:import-from #:ooparts/prolog/kernel/protocol)
  (:import-from #:ooparts/prolog/api/state)
  (:import-from #:ooparts/prolog/kernel/instructions)
  (:import-from #:ooparts/prolog/kernel/protocol #:register-provider)
  (:export #:goal-form #:goals-form #:host-goal-form #:source-control-p #:source-sequence))
(in-package #:ooparts/prolog/syntax/host-syntax)


(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun host-goal-form (goal &optional bindings)
    (let* ((testp (string= (symbol-name (car goal)) "LISPP"))
           (output (and (not testp) (= (length goal) 3) (second goal)))
           (expression (if output (third goal) (second goal)))
           (expression (if bindings
                           `(symbol-macrolet
                                ,(mapcar (lambda (entry)
                                           `(,(car entry) (lexical-binding-value ,(cdr entry)))) bindings)
                              ,expression)
                           expression))
           (variables (variables-in expression)))
      (unless (if testp (= (length goal) 2) (member (length goal) '(2 3)))
        (error "Invalid Lisp bridge goal: ~S" goal))
      `(make-host-goal :function (lambda ,variables
                                  ,@(when variables `((declare (ignorable ,@variables))))
                                  ,expression)
                       :arguments ',variables :output ',output :testp ,testp)))
  (defun source-control-p (goal names)
    (and (consp goal) (symbolp (car goal))
         (member (symbol-name (car goal)) names :test #'string=)))
  (defun source-sequence (goals)
    (let ((work (copy-list goals)) (result nil))
      (loop while work do
        (let* ((goal (pop work)))
          (if (and (source-control-p goal '("AND" ","))
                   (finite-list-p goal) (= (length goal) 3))
              (progn (push (third goal) work) (push (second goal) work))
              (push goal result))))
      (nreverse result)))
  (defun goal-form (goal &optional bindings)
    (cond
      ((scoped-goals-p goal)
       `(make-scoped-goals :goals ,(goals-form (scoped-goals-goals goal) bindings)))
      ((disjunction-goal-p goal)
       `(make-disjunction-goal :branches
          (list ,@(mapcar (lambda (branch) (goals-form branch bindings))
                         (disjunction-goal-branches goal)))))
      ((and (consp goal) (symbolp (car goal))
            (member (symbol-name (car goal)) '("LISP" "LISPP") :test #'string=))
       (host-goal-form goal bindings))
      ((or (source-control-p goal '("LET"))
           (and (source-control-p goal '("AND" ","))
                (finite-list-p goal) (= (length goal) 3)))
       `(make-sequence-goals :goals ,(goals-form (list goal) bindings)))
      ((source-control-p goal '("OR" ";" "->" "ONCE" "/+" "\\+"))
       `(list ',(car goal) ,@(mapcar (lambda (child) (goal-form child bindings)) (cdr goal))))
      (t `',goal)))
  (defvar *specializing-goals* nil)
  (defun goals-form (goals &optional bindings)
    (unless *specializing-goals*
      (return-from goals-form
        `(ecase (database-term-model *database*)
           ,@(loop for model in '(:native :iso) collect
               (let ((*specializing-goals* t) (*term-model* model))
                 `(,model ,(goals-form goals bindings)))))))
    (let ((result nil))
      (dolist (goal (source-sequence (expand-query-goals goals)))
        (if (source-control-p goal '("LET"))
            (multiple-value-bind (initializer environment) (let-goal-form goal bindings)
              (push initializer result)
              (setf bindings environment))
            (push (goal-form goal bindings) result)))
      `(list ,@(nreverse result)))))

(eval-when (:load-toplevel :execute)
  (register-provider 'ooparts/prolog/kernel/protocol:host-goal-form 'host-goal-form)
)
