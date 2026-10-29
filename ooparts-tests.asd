(asdf:defsystem "ooparts-tests"
  :class :package-inferred-system
  :description "Regression suites for OOPArts"
  :license "MIT"
  :pathname "tests/"
  :depends-on ("ooparts-tests/all")
  :perform (asdf:test-op (operation system)
             (declare (ignore operation system))
             (uiop:symbol-call :ooparts-tests/all :run-tests)))
