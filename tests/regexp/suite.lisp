;;; Aggregate the ooparts/regexp regression modules.
(uiop:define-package #:ooparts-tests/regexp/suite
  (:use #:cl)
  (:import-from #:ooparts-tests/regexp/syntax #:run-syntax-tests)
  (:import-from #:ooparts-tests/regexp/posix #:run-posix-tests)
  (:import-from #:ooparts-tests/regexp/differential #:run-differential-tests)
  (:import-from #:ooparts-tests/regexp/support #:*checks*)
  (:export #:run-tests))
(in-package #:ooparts-tests/regexp/suite)

(defun run-module-tests ()
  (run-syntax-tests)
  (run-posix-tests)
  (run-differential-tests))

(defun run-tests ()
  (let ((*checks* 0))
    (run-module-tests)
    (format t "~D regexp checks passed.~%" *checks*)
    t))
