;;; Selected public interface, without internal implementation exports.
(uiop:define-package #:ooparts/prolog/api/public
  (:use #:cl)
  (:import-from #:ooparts/prolog/library/standard-library)
  (:import-from #:ooparts/prolog/text/loader #:load-prolog #:load-prolog-string #:load-prolog-file)
  (:import-from #:ooparts/prolog/text/reader #:read-prolog-term #:parse-prolog-string)
  (:import-from #:ooparts/prolog/api/interface #:<- #:<-- #:?- #:prolog #:--> #:--->)
  (:import-from #:ooparts/prolog/api/registry #:builtin-predicate-inventory)
  (:import-from #:ooparts/prolog/syntax/native)
  (:import-from #:ooparts/prolog/api/state #:*iso-halt-function*)
  (:import-from #:ooparts/prolog/kernel/engine #:next-solution #:close-query #:*database*
    #:query-statistics)
  (:import-from #:ooparts/prolog/kernel/gc #:collect-query-garbage)
  (:import-from #:ooparts/prolog/kernel/instructions #:tnot)
  (:import-from #:ooparts/prolog/kernel/model #:slg-incomplete-cut #:make-database #:iso-exception
    #:iso-exception-term #:database-term-model #:database-execution-mode #:$cons #:$nil)
  (:import-from #:ooparts/prolog/kernel/slg #:table #:untable)
  (:import-from #:ooparts/prolog/syntax/compiler #:query #:make-query #:clear-database
    #:disassemble-predicate)
  (:import-from #:ooparts/prolog/syntax/dcg #:phrase #:dcg-expand)
  (:export #:load-prolog #:load-prolog-string #:load-prolog-file #:read-prolog-term #:parse-prolog-string
    #:<- #:<-- #:?- #:prolog #:--> #:---> #:phrase #:dcg-expand #:query #:make-query
    #:next-solution #:slg-incomplete-cut #:table #:untable #:tnot #:close-query #:clear-database
    #:*database* #:make-database #:database-term-model #:database-execution-mode #:$cons #:$nil #:*iso-halt-function* #:iso-exception #:iso-exception-term
    #:builtin-predicate-inventory #:collect-query-garbage #:query-statistics
    #:disassemble-predicate))
(in-package #:ooparts/prolog/api/public)
