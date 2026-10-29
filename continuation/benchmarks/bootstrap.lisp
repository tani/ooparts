(declaim (optimize (speed 3) (safety 1) (debug 0)))
(require :asdf)
(let ((cache (uiop:ensure-directory-pathname (uiop:getenv "SCPS_BENCH_CACHE"))))
  (asdf:initialize-output-translations
   (list :output-translations (list t (list cache :implementation))
         :ignore-inherited-configuration)))
(let ((vendor (uiop:ensure-directory-pathname (uiop:getenv "SCPS_BENCH_VENDOR"))))
  (dolist (name '("alexandria-20241012-git/alexandria.asd"
                  "closer-mop-20260101-git/closer-mop.asd"))
    (asdf:load-asd (merge-pathnames name vendor)))
  (asdf:load-asd
   (merge-pathnames (if (equal (uiop:getenv "SCPS_CL_CONT") "head")
                       "cl-cont/cl-cont.asd" "cl-cont-20110219-darcs/cl-cont.asd")
                   vendor)))
(asdf:load-system "cl-cont")
(asdf:load-asd (merge-pathnames "../ooparts.asd"
                              (uiop:ensure-directory-pathname (uiop:getenv "SCPS_BENCH_IMPLEMENTATION"))))
(asdf:load-system "ooparts/continuation")
(load (merge-pathnames "benchmarks.lisp" *load-truename*))
