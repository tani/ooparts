(require :asdf)
(let* ((*compile-verbose* nil) (*load-verbose* nil)
       (root (uiop:ensure-directory-pathname
              (or (uiop:getenv "OOPARTS_ROOT")
                  (namestring (merge-pathnames "../../" (uiop:pathname-directory-pathname *load-truename*)))))))
  (asdf:load-asd (merge-pathnames "ooparts.asd" root))
  (asdf:load-asd (merge-pathnames "ooparts-tests.asd" root))
  (asdf:load-system "ooparts-tests/prolog/support/derived-observations"))
(ooparts-tests/prolog/support/derived-observations:run-observations)
