(uiop:define-package #:ooparts-tests/test
  (:use #:cl)
  (:import-from #:ooparts/test #:test #:is #:signals #:run #:*tests*)
  (:export #:run-tests))
(in-package #:ooparts-tests/test)

;; Keep regression fixtures out of the public default registry, including when
;; this file is compiled and loaded repeatedly by ASDF.
(let ((*tests* nil))
  (test %passing
    (is (= 2 (+ 1 1)))
    (signals simple-error (error "Expected fixture error")))
  (test %values
    (declare (optimize (safety 3)))
    (values :first :second))
  (test %failing
    (error "Intentional fixture failure")))

(defun %capture (thunk)
  (with-output-to-string (stream)
    (let ((*standard-output* stream) (ooparts/test:*test-output* stream))
      (funcall thunk))))

(defun %must-error (thunk &optional (type 'error))
  (ooparts/test:is (handler-case (progn (funcall thunk) nil)
            (error (condition) (typep condition type)))))

(defun %check-registry ()
  (let ((*tests* nil))
    ;; Re-evaluating a definition replaces the function without duplicating it.
    (eval '(test %temporary (is t)))
    (eval '(test %temporary (is (= 1 1))))
    (ooparts/test:is (equal *tests* '(%temporary)))
    (unwind-protect
         (ooparts/test:is (search "Success: 1 test, 1 check."
                         (%capture (lambda () (run)))))
      (fmakunbound '%temporary))))

(defun %check-assertions ()
  (let ((count 0))
    (is (progn (incf count) t))
    (ooparts/test:is (= count 1)))
  (%must-error (lambda () (is nil)))
  (signals simple-error (error "Expected"))
  (signals error (error 'simple-error :format-control "Subtype"))
  (signals simple-warning (warn "Expected warning"))
  (signals simple-condition (signal "Expected signal"))
  (%must-error (lambda () (signals error :no-condition)))
  (%must-error (lambda () (signals type-error (error "Wrong type"))))
  ;; ASSERT retains its interactive CONTINUE restart.
  (let ((condition-count 0))
    (handler-bind ((error (lambda (condition)
                           (incf condition-count)
                           (invoke-restart (or (find-restart 'continue condition)
                                               (find-restart 'continue))))))
      (is (plusp condition-count)))
    (ooparts/test:is (= condition-count 1))))

(defun %check-runs ()
  (let ((*tests* '(%passing)))
    (ooparts/test:is (search "Success: 1 test, 2 checks."
                    (%capture (lambda () (run))))))
  (ooparts/test:is (search "Success: 1 test, 2 checks."
                  (%capture #'%passing)))
  (let ((result nil))
    (%capture (lambda () (setf result (multiple-value-list (%values)))))
    (ooparts/test:is (equal result '(:first :second)))
    (%capture (lambda () (setf result (multiple-value-list (run nil)))))
    (ooparts/test:is (null result)))
  (ooparts/test:is (search "Success: 0 tests, 0 checks."
                  (%capture (lambda () (run nil)))))
  (ooparts/test:is (search "Success: 2 tests, 4 checks."
                  (%capture (lambda () (run (vector '%passing #'%passing))))))
  (let ((tests (list '%passing '%values)))
    (%capture (lambda () (run tests)))
    (ooparts/test:is (equal tests '(%passing %values))))
  (%must-error (lambda () (run '(%failing))))
  (let ((output (%capture (lambda ()
                           (handler-case (run '(%failing))
                             (error () nil))))))
    (ooparts/test:is (not (search "Success:" output)))))

(defun %check-replay ()
  ;; Failed runs must replay both the shuffle and test-side random draws, even
  ;; after unrelated draws from the caller's random state.
  (let ((ooparts/test::*failed-random-state* nil)
        (observed nil) (fail t))
    (let ((tests (loop for id below 6 collect
                      (let ((id id))
                        (lambda ()
                          (push (list id (random 1000000)) observed)
                          (when fail (error "Replay fixture")))))))
      (%must-error (lambda () (run tests)))
      (let ((first (copy-tree observed)))
        (setf observed nil)
        (random 1000000)
        (%must-error (lambda () (run tests)))
        (ooparts/test:is (equal first observed))
        (ooparts/test:is ooparts/test::*failed-random-state*)
        (setf fail nil observed nil)
        (run tests)
        (ooparts/test:is (equal (first first) (car (last observed))))
        (ooparts/test:is (= 6 (length observed)))
        (ooparts/test:is (null ooparts/test::*failed-random-state*))))))

(defun %check-extensions ()
  (let ((result nil) (application-output nil))
    (let ((report
            (let ((ooparts/test::*running* nil))
              (%capture
               (lambda ()
                 (setf result
                       (multiple-value-list
                        (ooparts/test:with-suite (:outer)
                          (is t)
                          (ooparts/test:with-suite (:inner)
                            (is t () "Formatted ~S" :diagnostic)
                            (is (eq :value (ooparts/test:check :value))))
                          (setf application-output
                                (with-output-to-string (*standard-output*)
                                  (is t)))
                          (values :first :second)))))))))
      (is (search "Success: 2 tests, 5 checks." report))
      (is (equal result '(:first :second)))
      (is (equal application-output ""))))
  (let ((report
          (let ((ooparts/test::*running* nil))
            (%capture
             (lambda ()
               (%must-error
                (lambda ()
                  (ooparts/test:with-suite (:failure)
                    (ooparts/test:check nil "Expected ~S" :failure)))))))))
    (is (not (search "Success:" report))))
  (signals type-error (ooparts/test:check-program nil))
  (signals type-error (ooparts/test:check-program "not an argv list"))
  (signals type-error (ooparts/test:check-program '("not executed") :expected-status -1))
  ;; Accept mutable places and custom diagnostics without depending on the
  ;; implementation-specific argument convention of ASSERT's editing restart.
  (let ((value t))
    (is value (value) "Expected a true value, got ~S" value))
  t)

(defun run-tests ()
  (ooparts/test:with-suite ("ooparts-tests/test")
  ;; Do not replace the caller's registry, output or retained failure seed.
  (let ((*tests* nil)
        (ooparts/test::*running* nil)
        (ooparts/test::*failed-random-state* nil))
    (%capture (lambda ()
                (%check-registry)
                (%check-assertions)
                (%check-runs)
                (%check-replay))))
  (%check-extensions)
  (format t "~&ooparts/test regression suite passed.~%")
  t))
