;;; Deterministic cross-backend differential fixtures for ooparts/regexp.
(uiop:define-package #:ooparts-tests/regexp/differential
  (:use #:cl)
  (:import-from #:ooparts-tests/regexp/support #:check)
  (:import-from #:ooparts/regexp
    #:compile-regexp #:match-regexp #:search-regexp
    #:regexp-group-count #:match-start #:match-end)
  (:export #:run-tests #:run-differential-tests))
(in-package #:ooparts-tests/regexp/differential)

(defun strings-of-length (alphabet length)
  (if (zerop length)
      (list "")
      (loop for prefix in (strings-of-length alphabet (1- length))
            append (loop for character across alphabet
                         collect (concatenate 'string prefix
                                              (string character))))))

(defun strings-up-to (alphabet length)
  (loop for size from 0 to length
        append (strings-of-length alphabet size)))

(defparameter +shapes+
  '((:or "a" "aa")
    (:seq (:capture (:or "wee" "week"))
           (:capture (:or "knights" "night")))
    (:seq (:capture (:or "a" "aa"))
           (:capture (:or :epsilon "a")))
    (:repeat 0 nil (:capture (:or "a" "aa")))
    (:repeat 0 nil (:capture (:seq "a" (:repeat 0 1 (:capture "b")))))
    (:repeat 0 nil (:capture (:repeat 0 nil "a")))
    (:repeat 2 2 (:capture (:repeat 0 nil "a")))
    (:seq (:*? :any) #\c)
    (:seq (:capture (:*? :any)) (:* :any))
    (:seq (:capture (:*? "a")) #\b)
    (:or (:seq (:*? :any) #\c) (:seq (:* :any) #\d))
    (:seq (:* :any) #\c)
    (:seq (:*? :any) #\c)
    (:seq (:repeat? 1 nil
                    (:capture (:seq (:capture (:* "a"))
                                    (:seq (:* "a") "b"))))
           (:* :any))))

(defun expressions ()
  (let ((atoms '("" "a" "b"))
        (operators '(:* :+ :? :*? :+? :??))
        (forms '()))
    ;; Atoms.
    (dolist (atom atoms)
      (push atom forms))
    ;; Every unary quantifier and modifier over every atom.
    (dolist (operator operators)
      (dolist (atom atoms)
        (push (list operator atom) forms)))
    ;; Binary compositions of atoms.
    (dolist (operator '(:seq :or))
      (dolist (left atoms)
        (dolist (right atoms)
          (push (list operator left right) forms))))
    ;; Binary compositions of unary forms.
    (let ((unary (loop for operator in operators
                       collect (list operator "a"))))
      (dolist (operator '(:seq :or))
        (dolist (left unary)
          (dolist (right unary)
            (push (list operator left right) forms)))))
    ;; Capture wrappers.
    (dolist (atom atoms)
      (push (list :capture atom) forms))
    (push '(:seq (:capture "a") (:capture "b")) forms)
    ;; Interval bounds over every atom.
    (dolist (bounds '((0 0) (0 2) (1 2) (2 nil)))
      (dolist (atom atoms)
        (push (list :repeat (first bounds) (second bounds) atom) forms)))
    ;; Nested, repeated-capture and mixed-minimal shapes.
    (dolist (shape +shapes+)
      (push shape forms))
    (remove-duplicates (nreverse forms) :test #'equal)))

(defun outcome (regexp string mode)
  "Serialize the public result of REGEXP on STRING for MODE."
  (let ((match (ecase mode
                 (:match (match-regexp regexp string))
                 (:search (search-regexp regexp string)))))
    (when match
      (loop for group from 0 to (regexp-group-count regexp)
            collect (list (match-start match group)
                          (match-end match group))))))

(defun run-tests ()
  (let ((strings (strings-up-to "ab" 3)))
    (dolist (expression (expressions))
      (let* ((vm (compile-regexp expression :backend :vm))
             (automaton (compile-regexp expression :backend :automaton))
             (count (regexp-group-count vm)))
        (check (= count (regexp-group-count automaton))
               (format nil "~S: group count agrees" expression))
        (dolist (string strings)
          (dolist (mode '(:match :search))
            (let ((left (outcome vm string mode))
                  (right (outcome automaton string mode)))
              (check (equal left right)
                     (format nil "~S on ~S (~A): VM ~S, automaton ~S"
                             expression string mode left right))))))))
  t)

(defun run-differential-tests ()
  (run-tests))
