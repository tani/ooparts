(uiop:define-package #:ooparts/advice/backend
  (:use #:cl)
  (:export #:attach #:detach))
(in-package #:ooparts/advice/backend)

#-sbcl
(defstruct installation original wrapper)

(defun attach (name dispatcher)
  "Install DISPATCHER, called with the current underlying function and arguments."
  #+sbcl
  (progn
    (sb-ext:assert-version->= 2 6 6)
    (sb-int:encapsulate name 'ooparts/advice dispatcher)
    nil)
  #-sbcl
  (let* ((original (fdefinition name))
         (wrapper (lambda (&rest args) (apply dispatcher original args))))
    (setf (fdefinition name) wrapper)
    (make-installation :original original :wrapper wrapper)))

(defun detach (name installation)
  "Remove our wrapper, preserving an externally replaced portable definition."
  (declare (ignorable installation))
  #+sbcl
  (sb-int:unencapsulate name 'ooparts/advice)
  #-sbcl
  (when (and (fboundp name)
             (eq (fdefinition name) (installation-wrapper installation)))
    (setf (fdefinition name) (installation-original installation)))
  nil)
