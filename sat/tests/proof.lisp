(let ((*compile-verbose* nil) (*load-verbose* nil))
  (load (merge-pathnames "../load.lisp" *load-truename*)))
(destructuring-bind (input output mode) (uiop:command-line-arguments)
  (with-open-file (in input)
    (let ((n (read in)) (m (read in)) (limit (read in)))
      (with-open-file (proof output :direction :output :if-exists :supersede
                             :element-type (if (string= mode "a") 'character '(unsigned-byte 8)))
        (sat:with-solver (s :variables n :proof-stream proof
                            :proof-format (if (string= mode "a") :ascii :binary))
          (dotimes (i m)
            (sat:add-clause s (loop for lit = (read in) until (zerop lit) collect lit)))
          (format t "~D~%"
                  (ecase (sat:solve s :conflict-limit (unless (minusp limit) limit))
                    (:sat 10) (:unsat 20) (:unknown 0))))))))
