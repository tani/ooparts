(require :asdf)
(asdf:load-asd (merge-pathnames "../../ooparts.asd" *load-truename*))
(asdf:load-system "ooparts/sat")

(multiple-value-bind (status model)
    (ooparts/sat:solve-cnf '((1 2) (-1 2) (-2 3)))
  (assert (eq status :sat))
  (assert (ooparts/sat:model-value model 2))
  (format t "~&~A: ~S~%" status model))

(ooparts/sat:with-solver (solver :variables 1)
  (ooparts/sat:add-clauses solver '((1) (-1)))
  (assert (eq :unsat (ooparts/sat:solve solver))))
