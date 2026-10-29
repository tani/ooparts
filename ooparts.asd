(asdf:defsystem "ooparts"
  :class :package-inferred-system
  :description "OOPArts: continuation, Prolog and SAT libraries"
  :version "0.2.0"
  :license "MIT"
  :pathname "src/"
  :depends-on ("ooparts/all")
  :in-order-to ((asdf:test-op (asdf:test-op "ooparts-tests"))))

(asdf:register-system-packages "sb-cltl2" '("SB-CLTL2"))
