(uiop:define-package #:ooparts/c99
  (:use #:cl)
  (:import-from #:ooparts/c99/lexer #:tokenize-c99)
  (:import-from #:ooparts/c99/parser #:parse-c99)
  (:import-from #:ooparts/c99/codegen #:emit-assembly)
  (:export #:tokenize-c99 #:parse-c99 #:emit-assembly #:compile-c99))
(in-package #:ooparts/c99)

(defun compile-c99 (source &key (target :x86-64-linux))
  "Compile the documented initial C99 subset to assembly source text.
This does not implement preprocessing, general expressions, or linking."
  (emit-assembly (parse-c99 (tokenize-c99 source)) :target target))
