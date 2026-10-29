;;; Shared instruction and source-marker identities; no implementations.
(uiop:define-package #:ooparts/prolog/kernel/instructions (:use #:cl)
  (:export #:allocate #:call #:clear-x #:cut #:dcg-internal #:deallocate #:enter-cut-scope
    #:enter-scope #:execute #:fail #:get-constant #:get-list #:get-structure #:get-term
    #:get-value #:get-variable #:host #:iso-answer #:iso-catch-end #:iso-catch-fail #:iso-if
    #:jump #:leave-cut-scope #:leave-scope #:or-branches #:proceed #:put-args #:put-constant
    #:put-list #:put-structure #:put-value #:put-variable #:retry-me-else #:scoped-body
    #:set-constant #:set-value #:set-variable #:set-void #:table-answer #:tnot #:true #:trust-me
    #:try-branch #:try-me-else #:unify-constant #:unify-value #:unify-variable #:unify-void
    #:yield))
(in-package #:ooparts/prolog/kernel/instructions)
