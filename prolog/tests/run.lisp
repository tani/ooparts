(require :asdf)
(asdf:load-asd (merge-pathnames "../../ooparts.asd" *load-truename*))
(asdf:test-system "ooparts/prolog")
