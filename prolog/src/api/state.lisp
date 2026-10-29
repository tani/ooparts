(uiop:define-package #:ooparts/prolog/src/api/state (:use #:cl)
  (:export #:*iso-aliases* #:*iso-builtins* #:*iso-context* #:*iso-halt-function*
    #:*standard-predicates* #:*iso-standard-predicates* #:*syntax-predicates*))
(in-package #:ooparts/prolog/src/api/state)

(defvar *iso-builtins* (make-hash-table :test 'equal))
(defvar *iso-aliases* (make-hash-table :test 'equal))
(defvar *iso-context* nil)
(defvar *iso-halt-function* (lambda (status) (uiop:quit status)))
(defvar *syntax-predicates* (make-hash-table :test 'equal))
(defvar *standard-predicates* (make-hash-table :test 'equal))
(defvar *iso-standard-predicates* (make-hash-table :test 'equal))
