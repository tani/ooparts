(uiop:define-package #:ooparts/continuation/environment
  (:use #:cl)
  (:import-from #:cl-environments.cltl2 #:augment-environment #:variable-information
                #:function-information #:parse-macro #:enclose
                #:augmented-macroexpand-1 #:augmented-constantp #:augmented-get-setf-expansion)
  (:export #:augment-context #:variable-information #:function-information
           #:parse-macro #:enclose #:expand-once #:constant-form-p #:place-expansion))
(in-package #:ooparts/continuation/environment)

(defun augment-context (environment &rest arguments)
  #+sbcl
  (sb-ext:without-package-locks
    (apply #'augment-environment environment arguments))
  #-sbcl
  (apply #'augment-environment
         ;; CMUCL's macro-binding path copies its input environment directly.
         #+cmucl (or environment (c::make-null-environment))
         #-cmucl environment
         arguments))

(defun expand-once (form environment)
  (augmented-macroexpand-1 form environment))

(defun constant-form-p (form environment)
  (augmented-constantp form environment))

(defun place-expansion (place environment)
  (augmented-get-setf-expansion place environment))
