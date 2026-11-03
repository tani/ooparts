(require "asdf")
(let ((root (merge-pathnames "../../" (uiop:pathname-directory-pathname *load-truename*))))
  (asdf:load-asd (merge-pathnames "ooparts.asd" root))
  (asdf:load-asd (merge-pathnames "ooparts-tests.asd" root)))
(asdf:load-system "ooparts-tests/advice/behavior")
(uiop:symbol-call :ooparts-tests/advice/behavior :run-audit
                 (or (uiop:getenv "OOPARTS_ADVICE_AUDIT_DIRECTORY")
                     (format nil "build/advice/audit/~A/" (lisp-implementation-type))))
