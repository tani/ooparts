(uiop:define-package #:ooparts/continuation/environment
  (:use #:cl)
  #+sbcl
  (:import-from #:sb-cltl2 #:augment-environment #:variable-information
                #:function-information #:parse-macro #:enclose)
  #-sbcl
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
  (apply #'augment-environment environment arguments))

(defun expand-once (form environment)
  #+sbcl (macroexpand-1 form environment)
  #-sbcl (augmented-macroexpand-1 form environment))

(defun constant-form-p (form environment)
  #+sbcl (constantp form environment)
  #-sbcl (augmented-constantp form environment))

(defun place-expansion (place environment)
  #+sbcl (get-setf-expansion place environment)
  #-sbcl (augmented-get-setf-expansion place environment))
