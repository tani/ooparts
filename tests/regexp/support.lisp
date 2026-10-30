;;; Shared assertion helpers for the OOPArts regexp regression modules.
(uiop:define-package #:ooparts-tests/regexp/support
  (:use #:cl)
  (:import-from #:ooparts/regexp
    #:compile-regexp #:match-regexp #:search-regexp
    #:regexp-p #:regexp-backend #:regexp-group-count
    #:regexp-match #:match-start #:match-end #:match-string
    #:regexp-error #:regexp-error-code)
  (:export #:*checks* #:check #:spans #:result-spans #:run-case
           #:run-for-backends #:check-error-code #:check-type-error
           #:with-clean-checks))
(in-package #:ooparts-tests/regexp/support)

(defvar *checks* 0)

(defun check (value &optional (description "check"))
  (incf *checks*)
  (unless value
    (error "FAILED: ~A" description))
  value)

(defmacro with-clean-checks (&body body)
  `(let ((*checks* 0))
     ,@body))

(defun result-spans (match group-count)
  "Serialize MATCH as a list of (START END) pairs, or NIL for no match."
  (when match
    (loop for group from 0 to group-count
          collect (list (match-start match group)
                        (match-end match group)))))

(defun spans (match &optional (group-count 0))
  "Serialize the readers of MATCH for groups 0 through GROUP-COUNT."
  (result-spans match group-count))

(defun %description (description expression input)
  (let ((*print-circle* t))
    (or description
        (format nil "~S on ~S" expression input))))

(defun %reader-consistency-p (match input expected)
  (loop for (start end) in expected
        for group from 0
        always (if (null start)
                   (and (null end)
                        (null (match-start match group))
                        (null (match-end match group))
                        (null (match-string match group)))
                   (and (eql start (match-start match group))
                        (eql end (match-end match group))
                        (equal (subseq input start end)
                               (match-string match group))))))

(defun run-case (expression input expected
                 &key (mode :search) flags execution description)
  "Compile EXPRESSION for both backends and compare the public result.

EXPECTED is a list of (START END) pairs for groups 0 onward, with
(NIL NIL) for an absent group, or NIL for no match.  MODE is :SEARCH
(default) or :MATCH.  FLAGS and EXECUTION are plists passed to the
compiler and the matcher respectively."
  (let ((label (%description description expression input)))
    (run-for-backends
     (lambda (backend)
       (let* ((regexp (apply #'compile-regexp expression :backend backend flags))
              (match (ecase mode
                       (:search (apply #'search-regexp regexp input execution))
                       (:match (apply #'match-regexp regexp input execution))))
              (actual (result-spans match (regexp-group-count regexp))))
         (check (and (regexp-p regexp)
                     (eq backend (regexp-backend regexp)))
                (format nil "~A: backend ~A" label backend))
         (check (equal expected actual)
                (format nil "~A (~A): expected ~S, got ~S"
                        label backend expected actual))
         (when match
           (check (typep match 'regexp-match)
                  (format nil "~A (~A): match type" label backend))
           (check (and (not (null expected))
                       (= (length expected) (1+ (regexp-group-count regexp)))
                       (%reader-consistency-p match input expected))
                  (format nil "~A (~A): reader consistency" label backend))))))))

(defun run-for-backends (function)
  (dolist (backend '(:vm :automaton))
    (funcall function backend)))

(defun check-error-code (expression code &optional description)
  "Verify that compiling EXPRESSION signals REGEXP-ERROR with CODE."
  (let ((label (%description description expression "")))
    (run-for-backends
     (lambda (backend)
       (let ((actual
               (handler-case
                   (progn (compile-regexp expression :backend backend) nil)
                 (regexp-error (condition) (regexp-error-code condition)))))
         (check (eql code actual)
                (format nil "~A (~A): expected ~S, got ~S"
                        label backend code actual)))))))

(defun check-type-error (thunk &optional description)
  "Verify that THUNK signals TYPE-ERROR."
  (check (handler-case
             (progn (funcall thunk) nil)
           (type-error () t))
         (or description "type-error")))
