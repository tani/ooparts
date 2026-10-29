(asdf:defsystem "ooparts"
  :class :package-inferred-system
  :description "OOPArts: Common Lisp libraries"
  :version "0.1.0"
  :license "MIT"
  :depends-on ("ooparts/continuation" "ooparts/prolog" "ooparts/sat")
  :in-order-to ((asdf:test-op (asdf:test-op "ooparts/continuation/tests")
                             (asdf:test-op "ooparts/prolog/tests")
                             (asdf:test-op "ooparts/sat/tests"))))

(asdf:defsystem "ooparts/continuation"
  :description "Selective CPS shift/reset for SBCL"
  :version "1.2.0"
  :license "MIT"
  :depends-on ("sb-cltl2")
  :pathname "continuation/"
  :serial t
  :components ((:file "package") (:file "runtime") (:file "compiler"))
  :in-order-to ((asdf:test-op (asdf:test-op "ooparts/continuation/tests"))))

(asdf:defsystem "ooparts/continuation/tests"
  :depends-on ("ooparts/continuation")
  :pathname "continuation/tests/"
  :serial t
  :components ((:file "reference") (:file "tests"))
  :perform (asdf:test-op (o c)
             (declare (ignore o c))
             (uiop:symbol-call :ooparts/continuation/tests :run-tests)))

(asdf:defsystem "ooparts/prolog"
  :class :package-inferred-system
  :description "Stack-safe S-expression Prolog with a WAM-derived register VM"
  :version "0.10.0"
  :pathname "prolog/"
  :license "MIT"
  :depends-on ("uiop" "ooparts/prolog/src/api/package")
  :in-order-to ((asdf:test-op (asdf:test-op "ooparts/prolog/tests"))))

;; Module packages own their definitions. Map only the final public facade,
;; test runner, and generated atom namespace to their defining systems.
(asdf:register-system-packages "ooparts/prolog/src/api/package" '("OOPARTS/PROLOG" "PROLOG"))
(asdf:register-system-packages "ooparts/prolog/src/adapters/term-ops" '("OOPARTS/PROLOG/ATOMS"))
(asdf:register-system-packages "ooparts/prolog/tests/suite" '("OOPARTS/PROLOG/TESTS"))

(asdf:defsystem "ooparts/prolog/tests"
  :depends-on ("ooparts/prolog/tests/suite")
  :perform (asdf:test-op (op system)
             (declare (ignore op system))
             (uiop:symbol-call :ooparts/prolog/tests :run-tests)))

;; Standalone `ooparts-prolog' command line driver; (asdf:make "ooparts/prolog/cli").
(asdf:defsystem "ooparts/prolog/cli"
  ;; The CLI needs the full adapter layer (builtin providers); bring the
  ;; whole base system, not just the cli file's inferred dependencies.
  :depends-on ("ooparts/prolog" "ooparts/prolog/src/prolog/cli")
  :build-operation "asdf:program-op"
  :build-pathname "ooparts-prolog"
  :entry-point "ooparts/prolog/src/prolog/cli:main")

(asdf:defsystem "ooparts/sat"
  :description "SATCH production solver with a Common Lisp interface"
  :version "0.3.0"
  :license "MIT"
  :pathname "sat/"
  :serial t
  :components ((:file "src/package") (:file "src/runtime")
               (:file "src/generated/prefix")
               (:file "src/generated/part-00")
               (:file "src/generated/part-01")
               (:file "src/generated/part-02")
               (:file "src/generated/part-03")
               (:file "src/generated/part-04")
               (:file "src/generated/part-05")
               (:file "src/generated/part-06")
               (:file "src/generated/part-07")
               (:file "src/generated/part-08")
               (:file "src/generated/part-09")
               (:file "src/generated/part-10")
               (:file "src/generated/part-11")
               (:file "src/generated/part-12")
               (:file "src/generated/part-13")
               (:file "src/generated/part-14")
               (:file "src/api") (:file "src/interface"))
  :in-order-to ((asdf:test-op (asdf:test-op "ooparts/sat/tests"))))

(asdf:register-system-packages "ooparts/sat"
  '("OOPARTS/SAT" "SAT" "OOPARTS/SAT/LOW-LEVEL" "OOPARTS/SAT/IMPL"))

(asdf:defsystem "ooparts/sat/tests"
  :depends-on ("ooparts/sat")
  :pathname "sat/tests/"
  :perform (asdf:test-op (op component)
             (declare (ignore op))
             (dolist (file '("api.lisp" "numeric-boundaries.lisp" "interface.lisp"))
               (load (merge-pathnames file (asdf:component-pathname component))))))
