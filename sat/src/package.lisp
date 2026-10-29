#-(and sbcl x86-64 linux)
(error "ooparts/sat currently requires SBCL on Linux x86-64 (LP64, little endian).")

(defpackage #:ooparts/sat/impl (:use #:cl))
(defpackage #:ooparts/sat/low-level
  (:use #:cl)
  (:export #:satch-init #:satch-release #:satch-add #:satch-solve #:satch-val
   #:satch-add-empty #:satch-add-unit #:satch-add-binary-clause
   #:satch-add-ternary-clause #:satch-add-quaternary-clause #:satch-reserve
   #:satch-set-verbose-level #:satch-enable-logging-messages #:satch-ascii-proof
   #:satch-trace-proof #:satch-maximum-variable #:satch-process-time
   #:satch-section #:satch-statistics #:satch-conflicts
   #:satch-start-profiling-parsing #:satch-stop-profiling-parsing
   #:satch-version #:satch-compile #:satch-identifier
   #:+unknown+ #:+satisfiable+ #:+unsatisfiable+
   #:with-solver #:add-clause #:solve-cnf #:read-dimacs #:solve-file))

(defpackage #:ooparts/sat
  (:use #:cl)
  (:nicknames #:sat)
  (:import-from #:ooparts/sat/low-level #:read-dimacs)
  (:export #:solver #:solver-p #:make-solver #:close-solver #:with-solver
           #:solver-status #:solver-closed-p #:solver-state-error
           #:state-error-solver #:state-error-operation
           #:state-error-expected #:state-error-actual
           #:literal #:add-clause #:add-clauses #:new-variable #:reserve-variables
           #:solve #:solve-cnf #:solve-file #:solve-stream #:read-dimacs
           #:model #:value #:model-value #:statistics))
