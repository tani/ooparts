(require :asdf)
(asdf:load-asd (merge-pathnames "../ooparts.asd" *load-truename*))
(asdf:load-system "ooparts/continuation")
