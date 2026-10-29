(in-package #:cps-bench)

;; Extend the existing 22 cases with forms affected by shared normalization.
(dolist
    (spec
     '(("incf-place"
        (ooparts/continuation:reset
          (let ((cell (vector x))) (incf (aref cell 0) 3)))
        (lambda (x) (+ x 3)))
       ("pure-dolist"
        (ooparts/continuation:reset
          (let ((sum x)) (dolist (i '(1 2 3 4 5 6 7 8) sum) (incf sum i))))
        (lambda (x) (+ x 36)))
       ("dotimes-shift"
        (ooparts/continuation:reset
          (let ((sum x))
            (dotimes (i 16 sum)
              (incf sum (ooparts/continuation:shift k (funcall k i))))))
        (lambda (x) (+ x 120)))
       ("dolist-shift"
        (ooparts/continuation:reset
          (let ((sum x))
            (dolist (i '(1 2 3 4 5 6 7 8) sum)
              (incf sum (ooparts/continuation:shift k (funcall k i))))))
        (lambda (x) (+ x 36)))
       ("handler-bind-normal"
        (ooparts/continuation:reset
          (handler-bind ((warning (lambda (condition) (declare (ignore condition)))))
            (1+ x)))
        (lambda (x) (1+ x)))
       ("handler-bind-signal"
        (ooparts/continuation:reset
          (let ((sum x))
            (handler-bind ((warning (lambda (condition)
                                     (declare (ignore condition)) (incf sum))))
              (signal 'simple-warning)
              (ooparts/continuation:shift k (funcall k sum)))))
        (lambda (x) (1+ x)))
       ("handler-case-error"
        (ooparts/continuation:reset
          (handler-case
              (progn (ooparts/continuation:shift k (funcall k x)) (error "Benchmark error"))
            (error () (1+ x))))
        (lambda (x) (1+ x)))
       ("handler-case-normal"
        (ooparts/continuation:reset
          (handler-case (ooparts/continuation:shift k (funcall k x))
            (:no-error (value) (1+ value))))
        (lambda (x) (1+ x)))))
  (push (make-bench-case :name (car spec) :source (cadr spec)
                         :native t :native-form (native-one-resume (cadr spec))
                         :expected (eval (caddr spec)))
        *cases*))

(defun normalization-main ()
  (let* ((process (parse-integer (uiop:getenv "OOPARTS_CONT_BENCH_PROCESS")))
         (rounds (parse-integer (uiop:getenv "OOPARTS_CONT_BENCH_ROUNDS")))
         (target (read-from-string (uiop:getenv "OOPARTS_CONT_BENCH_TARGET")))
         (cases (if (oddp process) *cases* (reverse *cases*))))
    (setf *rng* (+ 20261029 process))
    (with-open-file (out (uiop:getenv "OOPARTS_CONT_BENCH_CSV")
                         :direction :output :if-exists :supersede)
      (format out "process,case,variant,round,iterations,cpu_seconds,wall_seconds,bytes,gc_seconds~%")
      (dolist (case cases)
        (let* ((selective (compile-case case :selective))
               (native (compile-case case :native))
               (source (bench-case-source case))
               (transform (lambda (x) (declare (ignore x))
                            (ooparts/continuation:transform source nil :selective)))
               (functions (list (list :selective selective) (list :native native)
                                (list :transform transform))))
          (validate-case case selective)
          (validate-case case native)
          (dolist (entry functions)
            (setf (cddr entry) (list (calibrate (cadr entry) target))))
          (dotimes (round rounds)
            (dolist (entry (shuffled functions))
              (destructuring-bind (variant function iterations) entry
                (multiple-value-bind (cpu wall bytes gc) (measure function iterations t)
                  (format out "~D,~A,~(~A~),~D,~D,~,9F,~,9F,~D,~,9F~%"
                          process (bench-case-name case) variant round iterations cpu wall bytes gc)))))
          (finish-output out)
          (format t "Validated and measured ~A.~%" (bench-case-name case))
          (finish-output))))))

(normalization-main)
