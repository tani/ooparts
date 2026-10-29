(uiop:define-package #:ooparts/prolog/adapters/collection
  (:use #:cl)
  (:import-from #:ooparts/prolog/adapters/adapter
    #:iso-output-list)
  (:import-from #:ooparts/prolog/adapters/term-ops
    #:iso-atomic-equal #:iso-copy #:iso-text #:iso-variables #:iso-list-from-host)
  (:import-from #:ooparts/prolog/kernel/engine
    #:close-query #:deref #:map-term #:next-solution #:unify)
  (:import-from #:ooparts/prolog/kernel/instructions
    #:yield)
  (:import-from #:ooparts/prolog/kernel/model
    #:%make-machine #:logic-var-p #:machine-database #:machine-gc-floor #:machine-variables)
  (:import-from #:ooparts/prolog/kernel/runtime
    #:iso-enter #:iso-goal #:iso-result)
  (:import-from #:ooparts/prolog/kernel/protocol)
  (:import-from #:ooparts/prolog/api/state)
  (:import-from #:ooparts/prolog/adapters/dynamic)
  (:export #:iso-bagof-results #:iso-child-solutions #:iso-collect #:iso-group-answers
    #:iso-variant-p))
(in-package #:ooparts/prolog/adapters/collection)


(defun iso-child-solutions (vm template goal free)
  (let* ((child (%make-machine :database (machine-database vm) :code #((yield)) :args #()
                              :gc-floor (machine-gc-floor vm) :gc-limit (machine-gc-floor vm)))
         (roots (iso-copy (list template goal free) child)) (answers nil))
    (setf (machine-variables child) (list (cons :roots roots)))
    (unwind-protect
         (progn (iso-enter child (second roots))
                (loop while (nth-value 1 (next-solution child)) do
                  (push (iso-copy (list (first roots) (third roots)) vm) answers)))
      (close-query child))
    (nreverse answers)))
(defun iso-variant-p (a b)
  (let ((forward (make-hash-table :test 'eq)) (backward (make-hash-table :test 'eq))
        (seen (make-hash-table :test 'eq)) (work (list (cons a b))))
    (loop while work do
      (let* ((pair (pop work)) (x (deref (car pair))) (y (deref (cdr pair))))
        (cond ((and (logic-var-p x) (logic-var-p y))
               (when (or (and (gethash x forward) (not (eq (gethash x forward) y)))
                         (and (gethash y backward) (not (eq (gethash y backward) x))))
                 (return-from iso-variant-p nil))
               (setf (gethash x forward) y (gethash y backward) x))
              ((or (logic-var-p x) (logic-var-p y)) (return-from iso-variant-p nil))
              ((and (consp x) (consp y))
               (let ((partners (or (gethash x seen) (setf (gethash x seen) (make-hash-table :test 'eq)))))
                 (unless (gethash y partners) (setf (gethash y partners) t)
                   (push (cons (car x) (car y)) work) (push (cons (cdr x) (cdr y)) work))))
              ((not (iso-atomic-equal x y)) (return-from iso-variant-p nil))))) t))
(defun iso-collect (vm name args)
  (destructuring-bind (template goal output) args
    (iso-output-list output)
    (let ((existential nil) (actual goal))
      (loop for g = (iso-goal actual) while (and (string= (iso-text (car g)) "^") (= (length g) 3)) do
        (setf existential (append existential (iso-variables (second g))) actual (third g)))
      (let* ((free (unless (string= name "FINDALL")
                     (set-difference (iso-variables actual) (append (iso-variables template) existential) :test #'eq)))
             (answers (iso-child-solutions vm template actual free)))
        (if (string= name "FINDALL")
            (list (iso-result (list template goal (iso-list-from-host (mapcar #'first answers)))))
            (iso-bagof-results vm template goal free answers))))))
(defun iso-group-answers (vm answers)
  "Group copied answers by variant keys, preserving encounter order and aliases."
  (let ((groups nil))
    (dolist (answer answers)
      (let ((group (find (second answer) groups :key #'car :test #'iso-variant-p)))
        (if group
            (progn (unify vm (car group) (second answer))
                   (setf (cdr group) (append (cdr group) (list (first answer)))))
            (push (cons (second answer) (list (first answer))) groups))))
    (nreverse groups)))
(defun iso-bagof-results (vm template goal free answers)
  (mapcar
   (lambda (group)
     (let ((values (cdr group)) (bindings (pairlis free (car group))))
       (iso-result
        (list template
              (map-term goal (lambda (x)
                               (let ((entry (assoc (deref x) bindings :test #'eq)))
                                 (if entry (cdr entry) (deref x)))))
              (iso-list-from-host values)))))
   (iso-group-answers vm answers)))
