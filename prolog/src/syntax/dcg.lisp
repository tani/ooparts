(uiop:define-package #:ooparts/prolog/src/syntax/dcg
  (:use #:cl)
  (:import-from #:ooparts/prolog/src/kernel/engine
    #:*database*)
  (:import-from #:ooparts/prolog/src/kernel/instructions
    #:dcg-internal)
  (:import-from #:ooparts/prolog/src/kernel/model
    #:*term-model* #:database-term-model #:database #:disjunction-goal #:make-disjunction-goal #:make-scoped-goals #:scoped-goals)
  (:import-from #:ooparts/prolog/src/kernel/protocol
    #:query #:variable-symbol-p #:iso-list-cons #:iso-empty-list)
  (:import-from #:ooparts/prolog/src/api/state)
  (:import-from #:ooparts/prolog/src/kernel/wam)
  (:export #:dcg-body-goals #:dcg-control-p #:dcg-empty-terminals-p #:dcg-expand #:dcg-marker-p
    #:dcg-nonterminal #:dcg-terminal-tokens #:dcg-variable #:expand-query-goals #:finite-list-p
    #:flatten-dcg-sequence #:phrase #:phrase-goals #:validate-dcg-controls))
(in-package #:ooparts/prolog/src/syntax/dcg)

(defun finite-list-p (value)
  (let ((seen (make-hash-table :test 'eq)))
    (loop while (consp value) do
      (when (gethash value seen) (return-from finite-list-p nil))
      (setf (gethash value seen) t value (cdr value)))
    (null value)))
(defun dcg-variable ()
  (let ((symbol (gensym "?DCG-")))
    (setf (get symbol 'dcg-internal) t) symbol))
(defun dcg-marker-p (form marker)
  (and (consp form)
       (or (eq (car form) marker)
           (and (symbolp (car form))
                (string= (symbol-name (car form))
                         (case marker
                           (:seq "AND") (:or "OR") (:goals "DO")
                           (:terminals "QUOTE") (otherwise "")))))))
(defun dcg-terminal-tokens (form)
  (if (eq (car form) :terminals)
      (cdr form)
      (progn
        (unless (and (finite-list-p form) (= (length form) 2)
                     (finite-list-p (second form)))
          (error "DCG QUOTE requires exactly one finite proper token list"))
        (second form))))
(defun dcg-empty-terminals-p (form)
  (and (dcg-marker-p form :terminals) (null (dcg-terminal-tokens form))))
(defun dcg-control-p (form name)
  (let ((symbol (if (and (consp form) (null (cdr form))) (car form) form)))
    (and (symbolp symbol) (string= (symbol-name symbol) name))))
(defun dcg-nonterminal (form input rest)
  (when (and (symbolp form) (not (variable-symbol-p form))) (setf form (list form)))
  (unless (and (consp form) (finite-list-p form) (symbolp (car form))
               (not (keywordp (car form))) (not (variable-symbol-p (car form))))
    (error "DCG nonterminal must be a static predicate name/application: ~S" form))
  (append form (list input rest)))
(defun validate-dcg-controls (forms)
  (unless (finite-list-p forms) (error "DCG body must be a finite proper list"))
  (let ((work (mapcar (lambda (form) (cons :enter form)) forms))
        (colors (make-hash-table :test 'eq)))
    (loop while work do
      (let* ((item (pop work)) (form (cdr item)))
        (when (or (dcg-marker-p form :seq) (dcg-marker-p form :or))
          (if (eq (car item) :leave) (setf (gethash form colors) :done)
              (case (gethash form colors)
                (:active (error "Cyclic DCG control expression"))
                (:done nil)
                (otherwise
                 (unless (finite-list-p form) (error "Malformed DCG control expression"))
                 (setf (gethash form colors) :active)
                 (push (cons :leave form) work)
                 (dolist (child (reverse (cdr form))) (push (cons :enter child) work))))))))))
(defun flatten-dcg-sequence (forms)
  (validate-dcg-controls forms)
  (let ((work (copy-list forms)) (result nil))
    (loop while work do
      (let* ((form (pop work)))
        (if (dcg-marker-p form :seq)
            (dolist (child (reverse (cdr form))) (push child work))
            (push form result))))
    (nreverse result)))
(defun dcg-body-goals (forms input rest)
  (let* ((forms (flatten-dcg-sequence forms))
         (last-consuming
           (loop for form in forms for index from 0
                 unless (or (dcg-marker-p form :goals) (dcg-marker-p form :goal)
                            (dcg-control-p form "!") (dcg-control-p form "TRUE")
                            (dcg-control-p form "FAIL")
                            (dcg-empty-terminals-p form)) collect index into indices
                 finally (return (car (last indices)))))
         (state input) (goals nil))
    (loop for form in forms for index from 0 do
      (unless (or (symbolp form) (finite-list-p form)) (error "Malformed DCG form"))
      (cond
        ((or (dcg-marker-p form :goals) (dcg-marker-p form :goal))
         (when (and (dcg-marker-p form :goal) (/= (length form) 2))
           (error ":GOAL takes exactly one ordinary goal"))
         (dolist (goal (cdr form)) (push goal goals)))
        ((or (dcg-control-p form "!") (dcg-control-p form "TRUE") (dcg-control-p form "FAIL"))
         (push form goals))
        ((dcg-empty-terminals-p form) nil)
        (t
         (let ((next (if (= index last-consuming) rest (dcg-variable))))
           (cond
             ((dcg-marker-p form :terminals)
              (let ((tail next))
                (dolist (token (reverse (dcg-terminal-tokens form))) (setf tail (iso-list-cons token tail)))
                (push (list '= state tail) goals)))
             ((dcg-marker-p form :or)
              (unless (cdr form) (error "DCG OR requires at least one branch"))
              (push (make-disjunction-goal
                     :branches (mapcar (lambda (branch) (dcg-body-goals (list branch) state next))
                                       (cdr form))) goals))
             (t (push (dcg-nonterminal form state next) goals)))
           (setf state next)))))
    ;; Empty and purely semantic productions consume nothing.
    (when (null last-consuming) (push (list '= input rest) goals))
    (nreverse goals)))
(defun dcg-expand (head body &key (term-model (database-term-model *database*)))
  "Return two values: the ordinary predicate head and its expanded Prolog body."
  (let ((*term-model* term-model) (input (dcg-variable)) (rest (dcg-variable)))
    (values (dcg-nonterminal head input rest) (dcg-body-goals body input rest))))
(defun phrase-goals (grammar input rest) (dcg-body-goals (list grammar) input rest))
(defun expand-query-goals (goals)
  (loop for goal in goals append
    (if (and (consp goal) (symbolp (car goal)) (string= (symbol-name (car goal)) "PHRASE"))
        (progn
          (unless (and (finite-list-p goal) (member (length goal) '(3 4)))
            (error "PHRASE takes a grammar, input, and optional remainder"))
          (list (make-scoped-goals :goals (phrase-goals (second goal) (third goal) (if (cdddr goal) (fourth goal) (iso-empty-list))))))
        (list goal))))
(defun phrase (grammar input &optional (rest nil rest-p) &key limit (database *database*) (gc-threshold 4096))
  "Collect DCG solutions from runtime Lisp data; default remainder is the model's empty list."
  (let ((*term-model* (database-term-model database)))
  (query (list (list 'phrase grammar input (if rest-p rest (iso-empty-list))))
         :limit limit :database database :gc-threshold gc-threshold)))
