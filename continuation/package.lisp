(defpackage #:ooparts/continuation
  (:use #:cl)
  (:nicknames #:selective-cps #:scps)
  (:export #:reset #:shift #:with-cps #:lambda/cps #:defun/cps
           #:cps-function-p #:continuation-p #:transform #:analyze
           #:*transformation-mode* #:missing-reset #:native-boundary
           #:unsupported-form #:inactive-control-target #:cps-error
           #:dynamic-wind #:register-cps-adapter))
(in-package #:ooparts/continuation)

(define-condition cps-error (error) ())
(define-condition missing-reset (cps-error) ()
  (:report (lambda (c s) (declare (ignore c))
             (write-string "SHIFT has no enclosing transformed RESET." s))))
(define-condition native-boundary (cps-error) ()
  (:report (lambda (c s) (declare (ignore c))
             (write-string "Control would cross an untransformed native callback. Transform the caller or use a CPS adapter / a local RESET." s))))
(define-condition unsupported-form (cps-error)
  ((form :initarg :form :reader unsupported-form-form)
   (reason :initarg :reason :reader unsupported-form-reason))
  (:report (lambda (c s) (format s "Cannot transform ~S: ~A"
                               (unsupported-form-form c)
                               (unsupported-form-reason c)))))
(define-condition inactive-control-target (cps-error)
  ((name :initarg :name))
  (:report (lambda (c s) (format s "Control target ~S is not dynamically active."
                               (slot-value c 'name)))))
