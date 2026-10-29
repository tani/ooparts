(load (merge-pathnames "../load.lisp" *load-truename*))
(load (uiop:getenv "SCPS_FIXTURE_FASL"))
(sb-ext:save-lisp-and-die (uiop:getenv "SCPS_TEST_CORE")
  :toplevel (lambda ()
              (handler-case
                  (progn (uiop:symbol-call :scps-fixture :checks) (sb-ext:exit :code 0))
                (error (e) (format *error-output* "Core check failed: ~A~%" e)
                  (sb-ext:exit :code 1)))))
