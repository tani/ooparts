(load (merge-pathnames "load.lisp" *load-truename*))
(defpackage #:scps-example (:use #:cl #:ooparts/continuation))
(in-package #:scps-example)

(format t "Composition: ~S~%"
        (reset (+ 1 (shift k (+ (funcall k 10) (funcall k 20))))))
(let ((k (reset (+ 10 (shift k k)))))
  (format t "Escaped, multi-shot: ~S~%" (list (funcall k 2) (funcall k 7))))
(defun/cps choose (xs)
  (shift k (mapcan (lambda (x) (funcall k x)) xs)))
(format t "Nondeterminism: ~S~%"
        (reset (let ((x (choose '(1 2))) (y (choose '(10 20)))) (list (+ x y)))))
(format t "Multiple values: ~S~%"
        (multiple-value-list (reset (shift k (funcall k 1 2 3)))))
(format t "Higher-order callback: ~S~%"
        (reset (mapcar (lambda (x) (+ x (shift k (funcall k 10)))) '(1 2 3))))
(format t "Effect analysis: ~S~%"
        (analyze '(labels ((twice (x) (+ x x))) (twice 4))))
