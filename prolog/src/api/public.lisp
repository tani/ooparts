;;; Selected public interface, without internal implementation exports.
(uiop:define-package #:ooparts/prolog/src/api/public
  (:use #:cl)
  (:import-from #:ooparts/prolog/src/library/standard-library)
  (:import-from #:ooparts/prolog/src/prolog/loader #:load-prolog #:load-prolog-string #:load-prolog-file)
  (:import-from #:ooparts/prolog/src/prolog/reader #:read-prolog-term #:parse-prolog-string)
  (:import-from #:ooparts/prolog/src/api/api #:<- #:<-- #:?- #:prolog #:--> #:--->)
  (:import-from #:ooparts/prolog/src/api/registry #:builtin-predicate-inventory)
  (:import-from #:ooparts/prolog/src/api/state #:*iso-halt-function*)
  (:import-from #:ooparts/prolog/src/kernel/engine #:next-solution #:close-query #:*database*
    #:query-statistics)
  (:import-from #:ooparts/prolog/src/kernel/gc #:collect-query-garbage)
  (:import-from #:ooparts/prolog/src/kernel/instructions #:tnot)
  (:import-from #:ooparts/prolog/src/kernel/model #:slg-incomplete-cut #:make-database #:iso-exception
    #:iso-exception-term #:database-term-model #:$cons #:$nil)
  (:import-from #:ooparts/prolog/src/kernel/slg #:table #:untable)
  (:import-from #:ooparts/prolog/src/syntax/compiler #:query #:make-query #:clear-database
    #:disassemble-predicate)
  (:import-from #:ooparts/prolog/src/syntax/dcg #:phrase #:dcg-expand)
  (:export #:load-prolog #:load-prolog-string #:load-prolog-file #:read-prolog-term #:parse-prolog-string
    #:<- #:<-- #:?- #:prolog #:--> #:---> #:phrase #:dcg-expand #:query #:make-query
    #:next-solution #:slg-incomplete-cut #:table #:untable #:tnot #:close-query #:clear-database
    #:*database* #:make-database #:database-term-model #:$cons #:$nil #:*iso-halt-function* #:iso-exception #:iso-exception-term
    #:builtin-predicate-inventory #:collect-query-garbage #:query-statistics
    #:disassemble-predicate))
(in-package #:ooparts/prolog/src/api/public)
