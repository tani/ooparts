;;; Copyright (c) 2014 James M. Lawrence
;;; Copyright (c) 2026 Masaya Taniguchi (OOPArts extensions)
;;;
;;; Permission is hereby granted, free of charge, to any person
;;; obtaining a copy of this software and associated documentation
;;; files (the "Software"), to deal in the Software without
;;; restriction, including without limitation the rights to use, copy,
;;; modify, merge, publish, distribute, sublicense, and/or sell copies
;;; of the Software, and to permit persons to whom the Software is
;;; furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be
;;; included in all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;;; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;;; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;;; DEALINGS IN THE SOFTWARE.

;;; Adapted from lmj/1am, revision 8b1da94eca4613fd8a20bdf63f0e609e379b0ba5.
;;; OOPArts adaptation: inferred namespace, suites, checks and output control.

(uiop:define-package #:ooparts/test
  (:use #:cl)
  (:export #:test #:is #:signals #:run #:*tests*
           #:check #:with-suite #:call-with-suite #:check-program
           #:*test-output* #:*print-progress*))

(in-package #:ooparts/test)

(defvar *tests* nil "A list of tests; the default argument to `run'.")
(defvar *pass-count* nil)
(defvar *running* nil)
(defvar *failed-random-state* nil)
(defvar *test-output* nil "Output stream, or NIL to use *STANDARD-OUTPUT*.")
(defvar *print-progress* t "Whether successful checks print a dot.")
(defvar *test-count* 0)

(defun test-output () (or *test-output* *standard-output*))

(defun %shuffle (vector)
  (loop for i downfrom (- (length vector) 1) to 1
        do (rotatef (aref vector i) (aref vector (random (1+ i)))))
  vector)

(defun shuffle (sequence)
  (%shuffle (map 'vector #'identity sequence)))

(defun call-with-random-state (fn)
  (let ((*random-state* (or *failed-random-state*
                            (load-time-value (make-random-state t)))))
    (setf *failed-random-state* (make-random-state nil))
    (multiple-value-prog1 (funcall fn)
      (setf *failed-random-state* nil))))

(defun report (test-count pass-count)
  (format (test-output) "~&Success: ~s test~:p, ~s check~:p.~%" test-count pass-count))

(defun %run (fn test-count)
  (let ((*pass-count* 0) (*test-count* 0) (*test-output* (test-output)))
    (multiple-value-prog1 (call-with-random-state fn)
      (report (or test-count *test-count*) *pass-count*))))

(defun run (&optional (tests *tests*))
  "Run each test in the sequence `tests'. Default is `*tests*'."
  (let ((*running* t))
    (%run (lambda () (map nil #'funcall (shuffle tests)))
          (length tests)))
  (values))

(defun call-test (name fn &optional newline)
  (format (test-output) "~&~s~@[~%~]" name newline)
  (finish-output (test-output))
  (if *running*
      (progn (incf *test-count*) (funcall fn))
      (%run fn 1)))

(defun call-with-suite (name function)
  "Run FUNCTION as a named, ordered test group and preserve its values.
Nested suites share the root check counter and random state. Errors propagate
without a success summary. The root binds its report stream before invoking
test code, so capturing application output does not capture test reports."
  (if *running*
      (call-test name function t)
      (let ((*running* t) (*print-progress* nil))
        (%run (lambda () (call-test name function t)) nil))))

(defmacro with-suite ((name) &body body)
  "Execute BODY, including declarations, in a named ordered test group."
  `(call-with-suite ,name (lambda () ,@body)))

(defmacro test (name &body body)
  "Define a test function and add it to `*tests*'."
  `(progn
     (defun ,name ()
       (call-test ',name (lambda () ,@body)))
     (pushnew ',name *tests*)
     ',name))

(defun passed ()
  (when *print-progress* (write-char #\. (test-output)))
  ;; Checks done outside a test run are not tallied.
  (when *pass-count*
    (incf *pass-count*))
  (values))

(defmacro is (form &optional places (datum nil datum-p) &rest arguments)
  "Assert FORM and count a successful check. Accept CL:ASSERT's optional
PLACES, DATUM and ARGUMENTS, retaining its diagnostics and CONTINUE restart."
  `(progn
     (assert ,form ,places ,@(when datum-p (cons datum arguments)))
     (passed)))

(defun check (value &optional (description "Check failed") &rest arguments)
  "Count a true VALUE or signal a descriptive SIMPLE-ERROR. Return VALUE.
Unlike IS, this function accepts an already evaluated value, so it does not
offer a retry restart. DESCRIPTION is a FORMAT control; ARGUMENTS fill it."
  (unless value (apply #'error description arguments))
  (passed)
  value)

(defun check-program (command &key directory (expected-status 0))
  "Run a nonempty argv list, inheriting process streams, and check its status.
This optional UIOP adapter lets development-only Python/C/oracle drivers use
the same runner. No external executable is required by the framework itself."
  (unless (and (consp command) (list-length command) (every #'stringp command))
    (error 'type-error :datum command :expected-type '(cons string list)))
  (check-type expected-status (integer 0 *))
  (multiple-value-bind (output errors status)
      (uiop:run-program command :directory directory :input :interactive
                       :output :interactive :error-output :interactive
                       :ignore-error-status t)
    (declare (ignore output errors))
    (check (eql status expected-status) "~S exited with status ~S; expected ~D."
           command status expected-status)
    status))

(defun %signals (expected fn)
  (flet ((handler (condition)
           (cond ((typep condition expected)
                  (passed)
                  (return-from %signals (values)))
                 (t (error "Expected to signal ~s, but got ~s:~%~a"
                           expected (type-of condition) condition)))))
    (handler-bind ((condition #'handler))
      (funcall fn)))
  (error "Expected to signal ~s, but got nothing." expected))

(defmacro signals (condition &body body)
  "Assert that `body' signals a condition of type `condition'."
  `(%signals ',condition (lambda () ,@body)))
