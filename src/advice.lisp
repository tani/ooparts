(uiop:define-package #:ooparts/advice
  (:use #:cl)
  (:import-from #:ooparts/advice/core
                #:advice-add #:advice-remove #:advice-member-p #:advice-mapc
                #:define-advice #:advice-status #:reconcile-definitions)
  (:use-reexport #:ooparts/advice/compilation)
  (:export #:advice-add #:advice-remove #:advice-member-p #:advice-mapc
           #:define-advice #:advice-status #:reconcile-definitions))
(in-package #:ooparts/advice)

(eval-when (:load-toplevel :execute)
  (enable-advice-compilation))
