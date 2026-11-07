(uiop:define-package #:ooparts/sml
  (:use #:cl)
  (:shadowing-import-from #:ooparts/sml/source #:position)
  (:use-reexport
    #:ooparts/sml/source
    #:ooparts/sml/syntax
    #:ooparts/sml/lexer
    #:ooparts/sml/parser
    #:ooparts/sml/basis
    #:ooparts/sml/compiler)
  (:import-from #:ooparts/sml/types #:sml-type-error)
  (:import-from #:ooparts/sml/elaborate
    #:sml-elaboration-error #:elaboration-error-kind)
  (:import-from #:ooparts/sml/runtime #:sml-raise #:sml-raise-value)
  (:export
    #:sml-type-error #:sml-elaboration-error #:elaboration-error-kind
    #:sml-raise #:sml-raise-value))
(in-package #:ooparts/sml)

;;; The lexer, parser, and elaborator represent source as native Prolog terms.
;;; Semantic elaboration and code generation remain in Prolog/DCG; execution
;;; uses host-compiled Curry forms rather than an SML tree interpreter.
