(uiop:define-package #:ooparts/prolog/src/api/api
  (:use #:cl)
  (:import-from #:ooparts/prolog/src/kernel/engine
    #:*database* #:close-query #:next-solution)
  (:import-from #:ooparts/prolog/src/syntax/compiler
    #:add-clause #:make-query)
  (:import-from #:ooparts/prolog/src/syntax/dcg
    #:dcg-expand)
  (:import-from #:ooparts/prolog/src/syntax/host-syntax
    #:goals-form)
  (:import-from #:ooparts/prolog/src/kernel/protocol)
  (:import-from #:ooparts/prolog/src/kernel/model #:database-term-model)
  (:import-from #:ooparts/prolog/src/api/state)
  (:import-from #:ooparts/prolog/src/kernel/instructions)
  (:export #:---> #:--> #:<- #:<-- #:?- #:display-query-answer #:interactive-query #:prolog
    #:query-more-p))
(in-package #:ooparts/prolog/src/api/api)


(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun grammar-definition-form (head body replacep)
    `(ecase (database-term-model *database*)
       ,@(loop for model in '(:native :iso) collect
           (multiple-value-bind (expanded-head expanded-body)
               (dcg-expand head body :term-model model)
             `(,model (add-clause ',expanded-head ,(goals-form expanded-body) ,replacep)))))))
(defmacro --> (head &body body) (grammar-definition-form head body nil))
(defmacro ---> (head &body body) (grammar-definition-form head body t))

(defmacro <- (head &body body)
  `(add-clause ',head ,(goals-form body) nil))
(defmacro <-- (head &body body)
  `(add-clause ',head ,(goals-form body) t))
(defun display-query-answer (solution truth delays stream)
  ;; Pretty-print dispatch can loop on rational cons terms in CCL. The
  ;; ordinary circle-aware printer also keeps each binding on one line.
  (let ((*print-circle* t) (*print-pretty* nil) (*print-readably* nil))
    (fresh-line stream)
    (dolist (binding solution)
      (format stream "~S = ~S~%" (car binding) (cdr binding)))
    (if (eq truth :undefined)
        (format stream "undefined; delayed negation: ~S~%" delays)
        (unless solution (format stream "true.~%")))))

(defun query-more-p (stream)
  (loop
    (format stream "More? [; = next, Enter = stop] ")
    (finish-output stream)
    (let ((line (read-line stream nil nil)))
      (unless line (return nil))
      (let ((command (string-trim '(#\Space #\Tab #\Return) line)))
        (cond ((string= command ";") (return t))
              ((member command '("" "." "q") :test #'string-equal) (return nil))
              (t (format stream "Type ; for the next answer, or Enter to stop.~%")))))))

;; Keep cursor construction replaceable for ownership instrumentation, even
;; after a native implementation has cached earlier calls.
(declaim (notinline make-query))

(defun interactive-query (goals)
  "Display one answer at a time through *QUERY-IO*, without lookahead."
  (let ((vm (funcall (symbol-function 'make-query) goals)))
    (unwind-protect
         (loop
           (multiple-value-bind (solution foundp truth delays) (next-solution vm)
             (unless foundp
               (fresh-line *query-io*)
               (format *query-io* "false.~%")
               (finish-output *query-io*)
               (return))
             (display-query-answer solution truth delays *query-io*)
             (unless (query-more-p *query-io*) (return))))
      (close-query vm)))
  (values))

(defmacro ?- (&body goals)
  "Interactively display answers; ; requests another, Enter or EOF stops."
  `(interactive-query ,(goals-form goals)))
(defmacro prolog (&body goals)
  "Enumerate goals with lexical Lisp callbacks; RETURN-FROM PROLOG exits safely."
  (let ((vm (gensym "VM")) (solution (gensym "SOLUTION")) (found (gensym "FOUND")))
    `(block prolog
       (let ((,vm (make-query ,(goals-form goals))))
         (unwind-protect
              (loop (multiple-value-bind (,solution ,found) (next-solution ,vm)
                      (declare (ignore ,solution)) (unless ,found (return nil))))
           (close-query ,vm))))))
