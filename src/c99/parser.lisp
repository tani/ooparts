(uiop:define-package #:ooparts/c99/parser
  (:use #:cl)
  (:import-from #:ooparts/prolog
                #:---> #:phrase #:make-database #:*database*)
  (:export #:parse-c99))
(in-package #:ooparts/c99/parser)

(defun parse-c99 (tokens)
  "Parse exactly one no-argument int function returning a decimal constant.
The production is executed by the OOPArts Prolog DCG engine."
  (let ((*database* (make-database)))
    (---> (translation-unit ?name ?value)
      '(:int)
      '((:identifier ?name))
      '(:lparen :rparen :lbrace :return)
      '((:number ?value))
      '(:semicolon :rbrace))
    (let ((solutions (phrase '(translation-unit ?name ?value) tokens)))
      (unless (and solutions (null (cdr solutions)))
        (error "Unsupported C99 syntax or ambiguous translation unit: ~S" tokens))
      (let ((bindings (first solutions)))
        (list :function
              (cdr (assoc '?name bindings))
              (cdr (assoc '?value bindings)))))))
