(uiop:define-package #:ooparts-tests/continuation/adapters
  (:use #:cl)
  (:import-from #:ooparts/continuation #:register-cps-adapter)
  (:import-from #:ooparts/continuation/runtime)
  (:export #:with-error-adapter))
(in-package #:ooparts-tests/continuation/adapters)

(defmacro with-error-adapter ((replacement) &body body)
  "Scope an ERROR adapter to a test without changing the shared registry."
  (let ((original (gensym "ORIGINAL")))
    `(let* ((,original ooparts/continuation/runtime::*adapters*)
            (ooparts/continuation/runtime::*adapters* (make-hash-table :test #'eq)))
       (maphash (lambda (function adapter)
                  (setf (gethash function ooparts/continuation/runtime::*adapters*) adapter))
                ,original)
       (register-cps-adapter 'error ,replacement)
       ,@body)))
