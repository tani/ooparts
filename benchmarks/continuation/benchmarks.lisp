(defpackage #:cps-bench (:use #:cl))
(in-package #:cps-bench)
(declaim (optimize (speed 3) (safety 1) (debug 0)))
(defvar *sink*)
(defvar *rng* 1)
(defstruct bench-case name source expected kind native native-form)
(defparameter *cases*
  (list
   (make-bench-case
    :name "pure-arithmetic" :native t
    :source '(ooparts/continuation:reset (+ (* x 3) (- x 1)))
    :expected (lambda (x) (+ (* x 3) (- x 1))))
   (make-bench-case
    :name "pure-local-recursion" :native t
    :source '(ooparts/continuation:reset
               (labels ((walk (n acc)
                          (if (zerop n) acc (walk (1- n) (+ acc n)))))
                 (walk 256 x)))
    :expected (lambda (x) (+ x 32896)))
   (make-bench-case
    :name "pure-dotimes" :native t
    :source '(ooparts/continuation:reset
               (let ((acc x)) (dotimes (i 128 acc) (incf acc (1+ i)))))
    :expected (lambda (x) (+ x 8256)))
   (make-bench-case
    :name "abort-no-resume"
    :source '(ooparts/continuation:reset (+ 1 (ooparts/continuation:shift k x)))
    :expected #'identity)
   (make-bench-case
    :name "capture-return" :kind :continuation
    :source '(ooparts/continuation:reset (+ x (ooparts/continuation:shift k k))))
   (make-bench-case
    :name "resume-stored" :kind :stored
    :source '(ooparts/continuation:reset (+ x (ooparts/continuation:shift k k)))
    :expected (lambda (x) (+ x 7)))
   (make-bench-case
    :name "capture-resume-once"
    :source '(ooparts/continuation:reset (+ 1 (ooparts/continuation:shift k (funcall k x))))
    :expected #'1+)
   (make-bench-case
    :name "capture-resume-twice"
    :source '(ooparts/continuation:reset (+ 1 (ooparts/continuation:shift k (+ (funcall k x) (funcall k (1+ x))))))
    :expected (lambda (x) (+ (* 2 x) 3)))
   (make-bench-case
    :name "deep-capture-resume"
    :source '(ooparts/continuation:reset
               (labels ((walk (n)
                          (if (zerop n) (ooparts/continuation:shift k (funcall k x))
                              (+ 1 (walk (1- n))))))
                 (walk 32)))
    :expected (lambda (x) (+ x 32)))
   (make-bench-case
    :name "sparse-control"
    :source '(ooparts/continuation:reset
               (labels ((work (n acc)
                          (if (zerop n) acc (work (1- n) (+ acc n)))))
                 (+ (work 256 0) (ooparts/continuation:shift k (funcall k x)))))
    :expected (lambda (x) (+ x 32896)))
   (make-bench-case
    :name "higher-order-capture"
    :source '(ooparts/continuation:reset
               (labels ((invoke-one (f v) (+ 1 (funcall f v))))
                 (invoke-one (lambda (v) (ooparts/continuation:shift k (funcall k (+ v 3)))) x)))
    :expected (lambda (x) (+ x 4)))
   (make-bench-case
    :name "multiple-values"
    :source '(ooparts/continuation:reset
               (multiple-value-bind (a b) (ooparts/continuation:shift k (funcall k x 3)) (+ a b)))
    :expected (lambda (x) (+ x 3)))
   (make-bench-case
    :name "nested-reset"
    :source '(ooparts/continuation:reset
               (+ 100 (ooparts/continuation:reset (+ 10 (ooparts/continuation:shift k (funcall k (1+ x)))))))
    :expected (lambda (x) (+ x 111)))))

(dolist (spec
         '(("typed-integer-loop"
            (ooparts/continuation:reset (let ((state x))
                          (declare (type fixnum state))
                          (dotimes (i 4096 state)
                            (declare (type fixnum i))
                            (setf state (logand (+ (* state 33) i) #xffffff)))))
            (lambda (x) (dotimes (i 4096 x)
                          (setf x (logand (+ (* x 33) i) #xffffff)))))
           ("typed-local-recursion"
            (ooparts/continuation:reset (labels ((walk (n acc)
                                   (declare (type fixnum n acc))
                                   (if (zerop n) acc (walk (1- n) (+ acc n)))))
                          (walk 256 x)))
            (lambda (x) (+ x 32896)))))
  (setf *cases* (append *cases*
                        (list (make-bench-case :name (car spec) :source (cadr spec)
                                               :native t :expected (eval (caddr spec)))))))

(defun lower-cl-cont (form &optional in-region)
  "Use the common single-prompt cases, with an explicit native boundary
for a nested delimiter. Nested WITH-CALL/CC alone merges regions."
  (cond ((atom form) form)
        ((eq (car form) 'quote) form)
        ((eq (car form) 'ooparts/continuation:reset)
         (let ((region (cons 'cl-cont:with-call/cc
                             (mapcar (lambda (x) (lower-cl-cont x t)) (cdr form)))))
           (if in-region (list 'cl-cont:without-call/cc region) region)))
        ((eq (car form) 'ooparts/continuation:shift)
         (list* 'cl-cont:let/cc (cadr form)
                (mapcar (lambda (x) (lower-cl-cont x t)) (cddr form))))
        (t (mapcar (lambda (x) (lower-cl-cont x in-region)) form))))
(defun strip-reset (form)
  (cond ((atom form) form)
        ((eq (car form) 'quote) form)
        ((eq (car form) 'ooparts/continuation:reset) (cons 'progn (mapcar #'strip-reset (cdr form))))
        (t (mapcar #'strip-reset form))))

;; Work is identical in all three variants. A shift resumes exactly once.
;; 4096 bounded integer updates; control frequency is varied independently.
(defun reference-work (n state)
  (declare (type fixnum n state))
  (dotimes (i n state)
    (setf state (logand (+ (* state 33) i) #xffffff))))
(declaim (notinline reference-work))
(defun inline-source (period)
  `(ooparts/continuation:reset
     (let ((state x))
       (dotimes (i 4096 state)
         (setf state (logand (+ (* state 33) i) #xffffff))
         ,@(when period
             `((when (zerop (mod (1+ i) ,period))
                 (setf state (ooparts/continuation:shift k (funcall k state))))))))))
(defun chunk-source (period)
  `(ooparts/continuation:reset
     (let ((state x))
       (dotimes (j 32 state)
         (setf state (reference-work 128 state))
         ,@(when period
             `((when (zerop (mod (1+ j) ,period))
                 (setf state (ooparts/continuation:shift k (funcall k state))))))))))
(defun native-one-resume (form)
  (cond ((atom form) form)
        ((eq (car form) 'quote) form)
        ((eq (car form) 'ooparts/continuation:reset)
         (cons 'progn (mapcar #'native-one-resume (cdr form))))
        ((eq (car form) 'ooparts/continuation:shift)
         (assert (and (= (length form) 3)
                      (eq (caaddr form) 'funcall)
                      (eq (cadr (caddr form)) (cadr form))))
         (native-one-resume (caddr (caddr form))))
        (t (mapcar #'native-one-resume form))))
(let ((native-forms
        '(("abort-no-resume" . x)
          ("capture-return" . (let ((saved x)) (lambda (v) (+ saved v))))
          ("resume-stored" . (let ((saved x)) (lambda (v) (+ saved v))))
          ("capture-resume-once" . (1+ x))
          ("capture-resume-twice" . (+ (* 2 x) 3))
          ("deep-capture-resume" . (+ x 32))
          ("sparse-control" .
            (labels ((work (n acc) (if (zerop n) acc (work (1- n) (+ acc n)))))
              (+ (work 256 0) x)))
          ("higher-order-capture" . (+ x 4))
          ("multiple-values" . (+ x 3))
          ("nested-reset" . (+ x 111)))))
  (dolist (case *cases*)
    (setf (bench-case-native-form case)
          (if (bench-case-native case) (strip-reset (bench-case-source case))
              (cdr (assoc (bench-case-name case) native-forms :test #'equal)))
          (bench-case-native case) t)))
(dolist (period '(nil 4096 256 16))
  (let ((source (inline-source period)))
    (setf *cases* (append *cases*
      (list (make-bench-case
        :name (format nil "inline-4096-shifts-~D" (if period (/ 4096 period) 0))
        :source source :native t :native-form (native-one-resume source)
        :expected (lambda (x) (reference-work 4096 x))))))))
(dolist (period '(nil 32 2))
  (let ((source (chunk-source period)))
    (setf *cases* (append *cases*
      (list (make-bench-case
        :name (format nil "chunked-4096-shifts-~D" (if period (/ 32 period) 0))
        :source source :native t :native-form (native-one-resume source)
        :expected (lambda (x)
                    (dotimes (j 32 x) (setf x (reference-work 128 x))))))))))

(defun compile-case (case variant)
  (let* ((source (bench-case-source case))
         (body (ecase variant
                 (:cl-cont (lower-cl-cont source))
                 (:selective (ooparts/continuation:transform source nil :selective))
                 (:full (ooparts/continuation:transform source nil :full))
                 (:native (bench-case-native-form case))))
         (f (compile nil (list 'lambda '(x) '(declare (type fixnum x)) body))))
    (if (eq (bench-case-kind case) :stored)
        (let ((k (funcall f 7))) (lambda (x) (funcall k x)))
        f)))
(defun validate-case (case f)
  (loop for x in '(0 1 2 3 7 31 127 255 511 1023)
        for result = (funcall f x)
        do (if (eq (bench-case-kind case) :continuation)
               (progn
                 (assert (functionp result))
                 (assert (= (+ x 3) (funcall result 3)))
                 (assert (= (+ x 9) (funcall result 9))))
               (assert (eql (funcall (bench-case-expected case) x) result)))))
(defun consume (f n)
  (declare (type function f) (type fixnum n))
  (let ((last nil))
    (dotimes (i n) (setf last (funcall f (logand i 1023))))
    (setf *sink* last)))
(defun measure (f iterations &optional collect-first)
  (when collect-first (sb-ext:gc :full t))
  (let ((bytes (sb-ext:get-bytes-consed))
        (gc sb-ext:*gc-run-time*)
        (wall (get-internal-real-time))
        (cpu (get-internal-run-time)))
    (consume f iterations)
    (values (/ (- (get-internal-run-time) cpu) (float internal-time-units-per-second 1d0))
            (/ (- (get-internal-real-time) wall) (float internal-time-units-per-second 1d0))
            (- (sb-ext:get-bytes-consed) bytes)
            (/ (- sb-ext:*gc-run-time* gc) (float internal-time-units-per-second 1d0)))))
(defun calibrate (f target)
  (consume f 64)
  (loop for n = 16 then (* n 4)
        for time = (measure f n t)
        when (or (>= time 0.006d0) (>= n 1048576))
          return (max 16 (min 10000000 (round (* target (/ n (max time 0.000001d0))))))))
(defun choose (n)
  (setf *rng* (mod (+ (* 1664525 *rng*) 1013904223) (expt 2 32)))
  (mod (ash *rng* -8) n))
(defun shuffled (items)
  (let ((v (coerce items 'vector)))
    (loop for i downfrom (1- (length v)) above 0
          do (rotatef (aref v i) (aref v (choose (1+ i)))))
    (coerce v 'list)))
(defun main ()
  (let* ((process (parse-integer (or (uiop:getenv "OOPARTS_CONT_BENCH_PROCESS") "1")))
         (rounds (parse-integer (or (uiop:getenv "OOPARTS_CONT_BENCH_ROUNDS") "9")))
         (target (read-from-string (or (uiop:getenv "OOPARTS_CONT_BENCH_TARGET") "0.05d0")))
         (baseline (uiop:getenv "OOPARTS_CONT_CL_CONT"))
         (path (uiop:getenv "OOPARTS_CONT_BENCH_CSV"))
         (cases (if (oddp process) *cases* (reverse *cases*))))
    (setf *rng* (+ 20261029 process))
    (with-open-file (out path :direction :output :if-exists :supersede)
      (format out "baseline,process,case,variant,round,iterations,cpu_seconds,wall_seconds,bytes,gc_seconds~%")
      (dolist (case cases)
        (let* ((variants (append '(:cl-cont :selective)
                                 (when (bench-case-native case) '(:native))))
               (functions (mapcar (lambda (v) (list v (compile-case case v))) variants)))
          (dolist (entry functions)
            (validate-case case (cadr entry))
            (setf (cddr entry) (list (calibrate (cadr entry) target))))
          (format t "Validated ~A ~A process ~D~%" baseline (bench-case-name case) process)
          (finish-output)
          (dotimes (round rounds)
            (dolist (entry (shuffled functions))
              (destructuring-bind (variant f iterations) entry
                (multiple-value-bind (cpu wall bytes gc) (measure f iterations t)
                  (format out "~A,~D,~A,~(~A~),~D,~D,~,9F,~,9F,~D,~,9F~%"
                          baseline process (bench-case-name case) variant
                          round iterations cpu wall bytes gc)))))
          (finish-output out))))
    (format t "BENCHMARK COMPLETED ~A process ~D~%" baseline process)))
(unless (uiop:getenv "OOPARTS_CONT_BENCH_DEFINITIONS_ONLY") (main))
