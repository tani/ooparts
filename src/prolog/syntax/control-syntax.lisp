(uiop:define-package #:ooparts/prolog/syntax/control-syntax
  (:use #:cl)
  (:import-from #:ooparts/prolog/kernel/engine
    #:deref #:map-term)
  (:import-from #:ooparts/prolog/kernel/instructions
    #:call #:cut #:fail #:iso-if #:or-branches #:scoped-body)
  (:import-from #:ooparts/prolog/kernel/model
    #:disjunction-goal-p #:host-goal-p #:logic-var-p #:scoped-goals-p #:sequence-goals-p)
  (:import-from #:ooparts/prolog/kernel/protocol
    #:goal-instructions #:iso-atom #:iso-error #:iso-goal #:iso-predicate-name #:table
    #:variable-symbol-p)
  (:import-from #:ooparts/prolog/api/state)
  (:import-from #:ooparts/prolog/syntax/dcg #:finite-list-p)
  (:export #:iso-control-form-p #:iso-control-instructions #:source-meta-goal-p
    #:validate-call-body #:validate-static-meta-goal))
(in-package #:ooparts/prolog/syntax/control-syntax)

(defun validate-call-body (goal)
  "Validate transparent control positions, retaining explicit meta-call boundaries."
  (let ((work (list goal)) (seen (make-hash-table :test 'eq)))
    (loop while work do
      (let* ((g (deref (pop work))))
        (unless (or (logic-var-p g) (variable-symbol-p g)
                    (host-goal-p g) (sequence-goals-p g)
                    (scoped-goals-p g) (disjunction-goal-p g))
          (unless (or (symbolp g)
                      (and (consp g) (finite-list-p g) (symbolp (car g))))
            (iso-error "type_error" (iso-atom "callable") goal))
          (when (and (consp g) (not (gethash g seen))
                     (member (iso-predicate-name (car g) (length (cdr g)))
                             '("," ";" "->") :test #'string=))
            (unless (= (length (cdr g)) 2)
              (iso-error "type_error" (iso-atom "callable") goal))
            (setf (gethash g seen) t)
            (push (third g) work) (push (second g) work)))))))


(defun source-meta-goal-p (goal)
  ;; Lexical callbacks are compiler objects, not first-class runtime terms.
  (let ((found nil))
    (map-term goal (lambda (x)
                     (when (or (host-goal-p x) (sequence-goals-p x)
                               (scoped-goals-p x) (disjunction-goal-p x))
                       (setf found t)) x))
    found))
(defun iso-control-form-p (goal)
  (or (logic-var-p goal) (variable-symbol-p goal)
      (and (consp goal) (symbolp (car goal))
           (let ((name (iso-predicate-name (car goal) (length (cdr goal)))))
             (or (member name '(";" "," "->" "FALSE") :test #'string=)
                 (and (member name '("ONCE" "\\+") :test #'string=)
                      (source-meta-goal-p goal)))))))
(defun iso-control-instructions (goal table counter tailp)
  (declare (ignore tailp))
  (labels ((compile-one (g) (let ((g (if (logic-var-p g) (deref g) g)))
                             (goal-instructions
                                (if (or (logic-var-p g) (variable-symbol-p g)
                                        (host-goal-p g) (sequence-goals-p g)
                                        (scoped-goals-p g) (disjunction-goal-p g)) g (iso-goal g))
                                table counter nil)))
           (scope (instructions) (list (list 'scoped-body instructions)))
           (cut-ir () '((cut))))
    (cond ((or (logic-var-p goal) (variable-symbol-p goal))
           (goal-instructions (list 'call goal) table counter nil))
          (t (let ((name (iso-predicate-name (car goal) (length (cdr goal)))) (args (cdr goal)))
               (unless (= (length args) (if (member name '(";" "," "->") :test #'string=) 2
                                          (if (string= name "FALSE") 0 1)))
                 (iso-error "type_error" (iso-atom "callable") goal))
               (cond ((string= name "FALSE") '((fail)))
                     ((string= name ",")
                      ;; Conjunction is transparent: compile its leaves in source
                      ;; order without one host stack frame per comma.
                      (let ((work (list goal)) (instructions nil))
                        (loop while work do
                          (let* ((g (pop work)) (g (if (logic-var-p g) (deref g) g)))
                            (if (and (consp g) (symbolp (car g))
                                     (consp (cdr g)) (consp (cddr g)) (null (cdddr g))
                                     (string= (iso-predicate-name (car g) 2) ","))
                                (progn (push (third g) work) (push (second g) work))
                                (setf instructions (nconc instructions (compile-one g))))))
                        instructions))
                     ((string= name "->") (list (list 'iso-if (compile-one (first args))
                                                       (compile-one (second args)) '((fail)))))
                     ((string= name ";")
                      (let ((left (if (logic-var-p (first args)) (deref (first args)) (first args))))
                        (if (and (consp left) (symbolp (car left)) (string= (iso-predicate-name (car left) (length (cdr left))) "->"))
                            (list (list 'iso-if (compile-one (second left)) (compile-one (third left))
                                        (compile-one (second args))))
                            (list (list 'or-branches (list (compile-one left) (compile-one (second args))))))))
                     ((string= name "ONCE") (scope (append (compile-one (first args)) (cut-ir))))
                     (t (scope (list (list 'or-branches
                                         (list (append (scope (compile-one (first args))) (cut-ir) '((fail))) nil)))))))))))

(defun validate-static-meta-goal (goal)
  "Preserve source-time callable errors when meta syntax becomes a library call."
  (let ((work (list goal)))
    (loop while work do
      (let ((g (pop work)))
        (unless (or (logic-var-p g) (variable-symbol-p g) (source-meta-goal-p g))
          (let* ((form (iso-goal g))
                 (name (iso-predicate-name (car form) (length (cdr form))))
                 (arity (cond ((member name '(";" "," "->") :test #'string=) 2)
                              ((member name '("ONCE" "\\+") :test #'string=) 1))))
            (when arity
              (unless (= arity (length (cdr form)))
                (iso-error "type_error" (iso-atom "callable") g))
              (setf work (append (cdr form) work)))))))))
