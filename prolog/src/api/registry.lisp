(uiop:define-package #:ooparts/prolog/src/api/registry
  (:use #:cl)
  (:import-from #:ooparts/prolog/src/api/state
    #:*iso-aliases* #:*iso-builtins* #:*iso-context* #:*iso-halt-function*
    #:*standard-predicates* #:*iso-standard-predicates* #:*syntax-predicates*)
  (:import-from #:ooparts/prolog/src/kernel/protocol
    #:iso-predicate-name)
  (:import-from #:ooparts/prolog/src/kernel/model #:*term-model*)
  (:import-from #:ooparts/prolog/src/kernel/instructions)
  (:import-from #:ooparts/prolog/src/api/api)
  (:import-from #:ooparts/prolog/src/kernel/protocol #:register-provider)
  (:export #:builtin-predicate-inventory #:iso-builtin-p #:iso-primitive-p #:iso-register
    #:iso-syntax-p #:standard-predicate #:syntax-register))
(in-package #:ooparts/prolog/src/api/registry)

(defun iso-register (name arities)
  (dolist (arity arities) (setf (gethash (cons (string-upcase name) arity) *iso-builtins*) t)))
(defun iso-primitive-p (name arity)
  (and (symbolp name)
       (gethash (cons (iso-predicate-name name arity) arity) *iso-builtins*)))
(defun iso-syntax-p (name arity)
  (and (symbolp name)
       (gethash (cons (iso-predicate-name name arity) arity) *syntax-predicates*)))
(defun syntax-register (name arities)
  (dolist (arity arities)
    (setf (gethash (cons (string-upcase name) arity) *syntax-predicates*) t)))
(defun standard-predicate (name arity)
  (and (symbolp name)
       (gethash (cons (iso-predicate-name name arity) arity)
                (if (eq *term-model* :iso) *iso-standard-predicates* *standard-predicates*))))
(defun iso-builtin-p (name arity)
  "Protected public names: primitives, syntax, and derived library predicates."
  (or (iso-primitive-p name arity) (iso-syntax-p name arity)
      (standard-predicate name arity)))
(defun builtin-predicate-inventory (&key (kind :all))
  "Public indicators by implementation KIND: :ALL, :PRIMITIVE, :SYNTAX, :DERIVED."
  (unless (member kind '(:all :primitive :syntax :derived))
    (error "Unknown predicate implementation kind: ~S" kind))
  (let ((registries (if (eq kind :all)
                        (list *iso-builtins* *syntax-predicates* *standard-predicates*)
                        (list (ecase kind
                                (:primitive *iso-builtins*)
                                (:syntax *syntax-predicates*)
                                (:derived *standard-predicates*))))))
    (sort (remove-duplicates
           (loop for registry in registries append
             (loop for key being the hash-keys of registry
                   unless (char= #\% (char (car key) 0)) collect (copy-tree key)))
           :test #'equal)
          (lambda (a b) (or (string< (car a) (car b))
                           (and (string= (car a) (car b)) (< (cdr a) (cdr b))))))))

(eval-when (:load-toplevel :execute)
  (register-provider 'ooparts/prolog/src/kernel/protocol:iso-builtin-p 'iso-builtin-p)
  (register-provider 'ooparts/prolog/src/kernel/protocol:iso-primitive-p 'iso-primitive-p)
  (register-provider 'ooparts/prolog/src/kernel/protocol:iso-syntax-p 'iso-syntax-p)
  (register-provider 'ooparts/prolog/src/kernel/protocol:standard-predicate 'standard-predicate)
)
