(uiop:define-package #:ooparts/curses/metrics
  (:use #:cl)
  (:export #:defapi #:*api-observer*))
(in-package #:ooparts/curses/metrics)
(defvar *api-observer* nil
  "Optional entry observer for coverage. NIL during normal use; receives the function name.")
(defmacro defapi (name arguments &body body)
  "Define an observable function without rebinding global function definitions.
Entry observation works even when a host compiler statically links Lisp calls."
  (let ((prefix nil))
    (when (stringp (first body)) (push (pop body) prefix))
    (loop while (and (consp (first body)) (eq (first (first body)) 'declare)) do (push (pop body) prefix))
    `(defun ,name ,arguments
       ,@(nreverse prefix)
       (when *api-observer* (funcall *api-observer* ',(if (consp name) (second name) name)))
       ,@body)))
