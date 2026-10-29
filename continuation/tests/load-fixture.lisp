(load (merge-pathnames "../load.lisp" *load-truename*))
(load (uiop:getenv "SCPS_FIXTURE_FASL"))
(uiop:symbol-call :scps-fixture :checks)
