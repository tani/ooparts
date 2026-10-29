(uiop:define-package #:ooparts-tests/continuation/suite
  (:use #:cl #:ooparts/continuation #:ooparts-tests/continuation/reference)
  (:import-from #:bordeaux-threads)
  (:import-from #:trivial-garbage)
  (:import-from #:ooparts-tests/continuation/adapters #:with-error-adapter)
  (:export #:run-tests))
(in-package #:ooparts-tests/continuation/suite)
(defvar *cases* nil)
(defvar *checks* 0)
(defvar *failures* nil)
(defparameter *test-special* :outside)
(defun host-callback (f) (+ 100 (funcall f 2)))
(defmacro case= (name expected &body body)
  `(push (list ',name ,expected '(progn ,@body)) *cases*))

(case= basic 32 (reset (+ 1 (shift k (+ (funcall k 10) (funcall k 20))))))
(case= abort 9 (reset (+ 100 (shift k (declare (ignore k)) 9))))
(case= nested 111 (reset (+ 100 (reset (+ 1 (shift k (funcall k 10)))))))
(case= composable 123 (reset (+ 1 (shift k (+ 100 (funcall k 22))))))
(case= zero-values nil (multiple-value-list (reset (values))))
(case= values '(1 2 3) (multiple-value-list (reset (values 1 2 3))))
(case= mv-resume '(4 5) (multiple-value-list (reset (shift k (funcall k 4 5)))))
(case= mv-resume-zero nil (multiple-value-list (reset (shift k (funcall k)))))
(case= missing-primary nil (reset (if (values) t nil)))
(case= primary-only 7 (reset (+ 5 (shift k (funcall k 2 100)))))
(case= mv-call '(1 2 3 4) (reset (multiple-value-call #'list (values 1 2) (shift k (funcall k 3 4)))))
(case= mv-prog1 '(1 2) (multiple-value-list (reset (multiple-value-prog1 (values 1 2) (shift k (funcall k 9))))))
;; A captured lexical location is shared; the already evaluated argument stays 0.
(case= shared-state '((0 1) (0 2))
  (let ((n 0)) (reset (list (shift k (list (funcall k 0) (funcall k 0))) (incf n)))))
(case= order '(1 2 3)
  (let ((log nil))
    (reset (list (progn (push 1 log) 1) (shift k (push 2 log) (funcall k 2)) (progn (push 3 log) 3)))
    (reverse log)))
(case= let-parallel '(3 10)
  (let ((x 10)) (reset (let ((x (shift k (funcall k 3))) (y x)) (list x y)))))
(case= let-sequential '(3 3)
  (let ((x 10)) (reset (let* ((x (shift k (funcall k 3))) (y x)) (list x y)))))
(case= optional-default 14
  (reset (funcall (lambda (x &optional (y (shift k (funcall k 10)))) (+ x y)) 4)))
(case= lambda-list '(1 2 t (:other 8 :z 9) 9 t 12)
  (reset (funcall (lambda (a &optional (b 3 bp) &rest rest &key (z 8 zp) &allow-other-keys
                            &aux (w (+ a b z))) (list a b (not (null bp)) rest z (not (null zp)) w))
                  1 2 :other 8 :z 9)))
(case= key-default '(3 nil)
  (reset (funcall (lambda (&key (x (shift k (funcall k 3)) xp)) (list x (not (null xp)))))))
(case= apply '(1 2 3) (reset (apply #'list 1 (shift k (funcall k '(2 3))))))
(case= flet 14 (reset (flet ((f (x) (+ x (shift k (funcall k 10))))) (f 4))))
(case= labels 120 (reset (labels ((f (n) (if (zerop n) (shift k (funcall k 1)) (* n (f (1- n)))))) (f 5))))
(case= mutual 8
  (reset (labels ((a (n) (if (zerop n) (shift k (funcall k 8)) (b (1- n))))
                  (b (n) (a n))) (a 10))))
(case= higher-order 12
  (reset (funcall (lambda (f) (+ 2 (funcall f 3)))
                  (lambda (x) (+ x (shift k (funcall k 7)))))))
(case= mapcar '(11 12 13)
  (reset (mapcar (lambda (x) (+ x (shift k (funcall k 10)))) '(1 2 3))))
(case= mapcar-multishot '((1 2) (1 3))
  (reset (mapcar (lambda (x) (if (= x 2) (shift k (list (funcall k 2) (funcall k 3))) x)) '(1 2))))
(case= mapcar-two '(11 22)
  (reset (mapcar (lambda (x y) (+ x y (shift k (funcall k 0)))) '(1 2) '(10 20))))
(case= reduce-left 10
  (reset (reduce (lambda (a b) (+ a b (shift k (funcall k 0)))) '(1 2 3 4))))
(case= reduce-right '(1 (2 (3 4)))
  (reset (reduce (lambda (a b) (shift k (funcall k (list a b)))) '(1 2 3 4) :from-end t)))
(case= block 7 (reset (block b (+ 100 (shift k (funcall k 0))) (return-from b 7) 8)))
(case= block-values '(2 3) (multiple-value-list (reset (block b (shift k (funcall k 0)) (return-from b (values 2 3))))))
(case= return-through-reset 17 (with-cps (block b (reset (+ 1 (return-from b 17))))))
(case= catch-throw '(2 3) (multiple-value-list (reset (catch 'tag (shift k (funcall k 0)) (throw 'tag (values 2 3))))))
(case= tagbody 3
  (reset (let ((n 0)) (tagbody again (incf n) (shift k (funcall k 0)) (if (< n 3) (go again))) n)))
(case= loop-macro 10 (reset (loop for x from 1 to 4 sum (shift k (funcall k x)))))
(case= dotimes-macro 6 (reset (let ((n 0)) (dotimes (x 4 n) (incf n (shift k (funcall k x)))))))
(case= symbol-macro 4
  (reset (let ((x (list 1))) (symbol-macrolet ((a (car x))) (setf a (shift k (funcall k 4))) a))))
(case= macrolet 8 (reset (macrolet ((twice (x) `(+ ,x ,x))) (twice (shift k (funcall k 4))))))
(case= macro-shadow 5 (reset (macrolet ((m () 100)) (flet ((m () 5)) (m)))))
(case= macro-over-function 9
  (reset (flet ((m () 5)) (macrolet ((m () 9)) (m)))))
(case= lexical-over-symbol-macro 5
  (reset (symbol-macrolet ((x 100)) (let ((x 5)) x))))
(case= symbol-macro-over-lexical 9
  (reset (let ((x 5)) (declare (ignorable x)) (symbol-macrolet ((x 9)) x))))
(case= incf-place-once '(4 1)
  (let ((items (vector 1)) (evaluations 0))
    (reset (incf (aref items (progn (incf evaluations) 0)) (shift k (funcall k 3))))
    (list (aref items 0) evaluations)))
(case= final-direct-values '(1 2)
  (multiple-value-list (reset (shift k (funcall k 0)) (+ 2 3) (values 1 2))))
(case= dolist-capture '(6 nil)
  (reset (let ((sum 0))
           (dolist (x '(1 2 3) (list sum x))
             (incf sum (shift k (funcall k x)))))))
(case= dotimes-count-once '(6 1 4)
  (let ((evaluations 0) (sum 0))
    (reset
      (dotimes (i (progn (incf evaluations) 4) (list sum evaluations i))
        (incf sum (shift k (funcall k i)))))))
(case= dolist-list-once '(6 1 nil)
  (let ((evaluations 0) (sum 0))
    (reset
      (dolist (item (progn (incf evaluations) '(1 2 3)) (list sum evaluations item))
        (incf sum (shift k (funcall k item)))))))
(case= decf-place-and-delta-order '(7 1 1)
  (let ((items (vector 10)) (places 0) (deltas 0))
    (reset
      (decf (aref items (progn (incf places) 0))
            (progn (incf deltas) (setf (aref items 0) 100)
                   (shift k (funcall k 3)))))
    (list (aref items 0) places deltas)))
(case= handler-compound-type '(1 2)
  (let ((calls 0))
    (let ((continuation
            (reset
              (handler-bind (((or warning simple-error)
                              (lambda (condition) (declare (ignore condition)) (incf calls))))
                (shift k k) (signal 'simple-warning) calls))))
      (list (funcall continuation 0) (funcall continuation 0)))))
(case= handler-cluster-disabled '(:inner :outer)
  (let ((log nil))
    (reset (handler-bind ((warning (lambda (condition) (declare (ignore condition)) (push :outer log))))
             (handler-bind ((warning (lambda (condition) (declare (ignore condition))
                                       (push :inner log) (signal 'warning))))
               (shift k (funcall k 0)) (signal 'warning))))
    (subseq (reverse log) 0 2)))
(case= unbound-binding-preserves-global '(:outside nil :outside)
  (list *test-special*
        (reset (progv '(*test-special*) '(1)
                 (shift k (funcall k 0)) (makunbound '*test-special*) (boundp '*test-special*)))
        *test-special*))

(case= special-binding '(9 :outside)
  (list (reset (let ((*test-special* 9)) (shift k (funcall k 0)) *test-special*)) *test-special*))
(case= special-capture '(9 10 :outside)
  (let ((k (reset (let ((*test-special* 8)) (shift k k) (incf *test-special*)))))
    (list (funcall k 0) (funcall k 0) *test-special*)))
(case= shift-body-unwinds :outside
  (reset (let ((*test-special* :inside)) (shift k (declare (ignore k)) *test-special*))))
(case= caller-special :caller
  (let ((k (reset (shift k k) *test-special*)))
    (let ((*test-special* :caller)) (funcall k 0))))
(case= progv '(4 5)
  (reset (progv '(*test-special*) '(4) (shift k (funcall k 0)) (list *test-special* (incf *test-special*)))))

(case= progv-mixed-preserves-outer '((1 nil 3) (10 20 30))
  (let ((symbols (list (gensym "FIRST") (gensym "SECOND") (gensym "THIRD"))))
    (progv symbols '(10 20 30)
      (list
       (reset
         (progv (list (first symbols) (third symbols) (second symbols)) '(1 3)
           (shift k (funcall k nil))
           (list (symbol-value (first symbols)) (boundp (second symbols))
                 (symbol-value (third symbols)))))
       (mapcar #'symbol-value symbols)))))
(case= cleanup '(:leave :after :leave)
  (let ((log nil))
    (reset (unwind-protect (shift k (push :after log) (funcall k 0)) (push :leave log)))
    (reverse log)))
(case= cleanup-values '(4 5)
  (multiple-value-list (reset (unwind-protect (values 4 5) (values 9)))))
(case= cleanup-overrides 8 (reset (catch 'tag (unwind-protect (throw 'tag 3) (throw 'tag 8)))))
(case= cleanup-shift 17
  (reset (+ 10 (unwind-protect 2 (shift k (+ 5 (funcall k 0)))))))
(case= wind '(:in :out :body :in :out)
  (let ((log nil))
    (reset (dynamic-wind (lambda () (push :in log))
                         (lambda () (shift k (push :body log) (funcall k 0)))
                         (lambda () (push :out log))))
    (reverse log)))
(case= the-values '(1 2)
  (multiple-value-list (reset (the (values integer integer) (shift k (funcall k 1 2))))))
(case= load-time 10 (reset (+ (load-time-value (+ 1 2)) (shift k (funcall k 7)))))
(case= eval-when 12 (reset (eval-when (:execute) (+ 5 (shift k (funcall k 7))))))

(case= handler-case 17
  (reset (handler-case (progn (shift k (funcall k 0)) (error "x"))
           (error (e) (declare (ignore e)) 17))))
(case= handler-normal 21
  (reset (handler-case (shift k (funcall k 1)) (:no-error (v) (+ v 20)))))
(case= handler-abort 18
  (reset (handler-bind ((error (lambda (e) (declare (ignore e)) (throw 'out 18))))
           (catch 'out (error "x")))))
(case= handler-reinstated '(17 17)
  (let ((k (reset (handler-case (progn (shift k k) (error "x"))
                   (error () 17)))))
    (list (funcall k 0) (funcall k 0))))
(case= restart 19
  (reset (restart-case (progn (shift k (funcall k 0)) (invoke-restart 'r 19))
           (r (x) x))))
(case= restart-reinstated '(4 5)
  (let ((k (reset (restart-case (let ((x (shift k k))) (invoke-restart 'r x))
                   (r (x) x)))))
    (list (funcall k 4) (funcall k 5))))

(case= restart-condition-association '(t t)
  (reset
    (let ((other (make-condition 'simple-error)))
      (handler-bind
          ((simple-error
             (lambda (condition)
               (invoke-restart 'recover
                               (list (not (null (find-restart 'recover condition)))
                                     (null (find-restart 'recover other)))))))
        (restart-case (error "Associated error")
          (recover (answer) answer))))))

(case= restart-signal-association '(t t)
  (reset
    (let ((other (make-condition 'simple-condition)))
      (handler-bind
          ((simple-condition
             (lambda (condition)
               (invoke-restart 'recover
                               (list (not (null (find-restart 'recover condition)))
                                     (null (find-restart 'recover other)))))))
        (restart-case (signal "Associated signal")
          (recover (answer) answer))))))

(case= restart-warning-association '(t t)
  (reset
    (let ((other (make-condition 'simple-warning)))
      (handler-bind
          ((simple-warning
             (lambda (condition)
               (invoke-restart 'recover
                               (list (not (null (find-restart 'recover condition)))
                                     (null (find-restart 'recover other)))))))
        (restart-case (warn "Associated warning")
          (recover (answer) answer))))))

(case= restart-correctable-association '(t t (7))
  (reset
    (let ((other (make-condition 'simple-error)))
      (handler-bind
          ((simple-error
             (lambda (condition)
               (invoke-restart 'recover
                               (list (not (null (find-restart 'recover condition)))
                                     (null (find-restart 'recover other))
                                     (simple-condition-format-arguments condition))))))
        (restart-case (cerror "Continue with ~D" "Associated error ~D" 7)
          (recover (answer) answer))))))

(case= restart-duplicate-names '(:second 2 0)
  (reset
    (let ((other (make-condition 'simple-error)))
      (handler-bind
          ((simple-error
             (lambda (condition)
               (let ((matching
                       (remove-if-not (lambda (restart) (eq (restart-name restart) 'recover))
                                      (compute-restarts condition))))
                 (invoke-restart (second matching) (length matching)
                                 (count 'recover (compute-restarts other) :key #'restart-name))))))
        (restart-case (error "Duplicate names")
          (recover (count others) :test (lambda (condition) (or (null condition) (typep condition 'simple-error)))
            (list :first count others))
          (recover (count others) :test (lambda (condition) (or (null condition) (typep condition 'simple-error)))
            (list :second count others)))))))

(case= restart-unnamed-associated 23
  (reset
    (handler-bind
        ((simple-error
           (lambda (condition)
             (invoke-restart
              (find-if (lambda (restart) (null (restart-name restart)))
                       (compute-restarts condition)) 23))))
      (restart-case (error "Unnamed restart")
        (nil (answer) :report "An anonymous recovery"
             :test (lambda (condition) (or (null condition) (typep condition 'simple-error)))
          answer)))))

(case= restart-condition-only-test '(t t)
  (reset
    (block answer
      (let ((other (make-condition 'simple-error)))
        (handler-bind
            ((simple-error
               (lambda (condition)
                 (return-from answer
                   (list (not (null (find-restart 'recover condition)))
                         (null (find-restart 'recover other)))))))
          (restart-case (error "A restart visible only for conditions")
            (recover () :test (lambda (condition) (typep condition 'simple-error))
              :unused)))))))

(case= restart-macro-association '(t t)
  (reset
    (let ((other (make-condition 'simple-error)))
      (macrolet ((fail () '(error "Expanded failure")))
        (handler-bind
            ((simple-error
               (lambda (condition)
                 (invoke-restart 'recover
                                 (list (not (null (find-restart 'recover condition)))
                                       (null (find-restart 'recover other)))))))
          (restart-case (fail) (recover (answer) answer)))))))

(defun restart-test (condition) (declare (ignore condition)) t)
(defun restart-report (stream) (write-string "A named recovery" stream))
(defun restart-arguments () (list 29))
(case= restart-named-options 29
  (reset
    (restart-case (invoke-restart-interactively 'recover)
      (recover (answer) :test restart-test :report restart-report
               :interactive restart-arguments
        answer))))

(case= restart-association-after-capture '(4 5)
  (let ((saved nil))
    (reset
      (handler-bind
          ((simple-error
             (lambda (condition)
               (invoke-restart 'recover (first (simple-condition-format-arguments condition))))))
        (restart-case (error "Captured value ~D" (shift k (setq saved k) :captured))
          (recover (answer) answer))))
    (list (funcall saved 4) (funcall saved 5))))

(defun reentrant-restart-associations ()
  (let ((saved nil) (first (make-condition 'simple-error))
        (second (make-condition 'simple-error)))
    (with-error-adapter
        ((lambda/cps (condition)
           (if (eq condition first)
               (invoke-restart 'recover (funcall saved second))
               (invoke-restart 'recover
                               (list (not (null (find-restart 'recover first)))
                                     (not (null (find-restart 'recover second))))))))
      (reset
        (restart-case (error (shift k (setf saved k) :captured))
          (recover (answer) answer)))
      (funcall saved first))))
(case= restart-reentrant-associations '(t t) (reentrant-restart-associations))

(defun captured-restart-associations ()
  (let ((saved nil) (condition (make-condition 'simple-error))
        (other (make-condition 'simple-error)))
    (with-error-adapter
        ((lambda/cps (datum)
           (shift k (setf saved k) :captured)
           (invoke-restart 'recover
                           (list (not (null (find-restart 'recover datum)))
                                 (null (find-restart 'recover other))))))
      (reset (restart-case (error condition) (recover (answer) answer)))
      (list (funcall saved nil) (funcall saved nil)))))
(case= restart-captured-associations '((t t) (t t)) (captured-restart-associations))
(case= error-cleanup '(:cleanup :handled)
  (let ((log nil))
    (handler-case (reset (unwind-protect (error "x") (push :cleanup log)))
      (error () (push :handled log)))
    (reverse log)))
(case= return-from-callback 8
  (reset (block b (host-callback (lambda (x) (declare (ignore x)) (return-from b 8))))))
(case= sequence-map '(11 22)
  (reset (map 'list (lambda (a b) (+ a b (shift k (funcall k 0)))) #(1 2) '(10 20))))
(case= some-value 2
  (reset (some (lambda (x) (shift k (funcall k (when (= x 2) x)))) '(1 2 3))))
(case= every-multishot '(t nil)
  (reset (every (lambda (x) (if (= x 2) (shift k (list (funcall k t) (funcall k nil))) t)) '(1 2 3))))
(case= notany-value t (reset (notany (lambda (x) (shift k (funcall k (< x 0)))) '(1 2 3))))
(case= notevery-value t (reset (notevery (lambda (x) (shift k (funcall k (< x 2)))) '(1 2 3))))
(case= map-for-effect '(1 2 3)
  (let ((seen nil))
    (reset (map nil (lambda (x) (shift k (funcall k 0)) (push x seen)) #(1 2 3)))
    (reverse seen)))
(case= reduce-key 12
  (reset (reduce #'+ '(1 2 3) :key (lambda (x) (shift k (funcall k (* 2 x)))))))
(case= reduce-empty 0 (reset (reduce (lambda (&rest xs) (shift k (funcall k (apply #'+ xs)))) nil)))
(case= progv-unbound nil
  (reset (progv '(*test-special*) nil (shift k (funcall k 0)) (boundp '*test-special*))))
(case= progv-mutated-unbound '(nil nil)
  (let ((k (reset (progv '(*test-special*) '(1) (shift k k) (makunbound '*test-special*) (boundp '*test-special*)))))
    (list (funcall k 0) (funcall k 0))))
(case= declared-special '(3 3)
  (reset (let ((x 3)) (declare (special x))
           (list x (funcall (lambda () (declare (special x)) (shift k (funcall k 0)) x))))))
(case= normal-map-alias '(3 4)
  (let ((f #'mapcar)) (reset (funcall f (lambda (x) (+ x (shift k (funcall k 2)))) '(1 2)))))
(case= dynamic-function-choice '(3 4)
  (reset (mapcar (if t (lambda (x) (+ x (shift k (funcall k 2)))) (lambda (x) x)) '(1 2))))
(case= specials-native-read 31
  (reset (let ((*test-special* 31)) (shift k (funcall k 0)) (symbol-value '*test-special*))))
(case= nested-wind '(:a-in :b-in :b-out :a-out :body :a-in :b-in :b-out :a-out)
  (let ((log nil))
    (reset (dynamic-wind
             (lambda () (push :a-in log))
             (lambda () (dynamic-wind (lambda () (push :b-in log))
                                      (lambda () (shift k (push :body log) (funcall k 0)))
                                      (lambda () (push :b-out log))))
             (lambda () (push :a-out log))))
    (reverse log)))

(case= shift-during-abort-cleanup 111
  (reset
    (let ((first t))
      (+ 10 (unwind-protect (shift k (funcall k 1))
              (when first (setf first nil) (shift h (+ 100 (funcall h 0)))))))))
(case= shift-during-wind-entry 1114
  (let ((n 0) (saved nil))
    (reset (+ 10 (dynamic-wind
                   (lambda () (incf n) (when (= n 2) (shift h (+ 100 (funcall h 0)))))
                   (lambda () (+ 1 (shift k (setf saved k) 0)))
                   (lambda () nil))))
    (reset (+ 1000 (funcall saved 3)))))
(case= shift-during-wind-entry-multishot 1128
  (let ((n 0) (saved nil))
    (reset (+ 10 (dynamic-wind
                   (lambda () (incf n) (when (= n 2) (shift h (+ 100 (funcall h 0) (funcall h 0)))))
                   (lambda () (+ 1 (shift k (setf saved k) 0)))
                   (lambda () nil))))
    (reset (+ 1000 (funcall saved 3)))))

(case= pure-go-loop 20
  (reset (let ((n 0)) (tagbody again (incf n) (when (< n 20) (go again))) n)))
(case= pure-go-shadowing 3
  (reset (let ((n 0))
           (tagbody again
             (tagbody again (incf n) (when (< n 2) (go again)))
             (incf n)) n)))
(case= go-across-reset 3
  (with-cps (let ((n 0))
              (tagbody again
                (reset (shift k (funcall k 0)) (incf n) (when (< n 3) (go again)))) n)))
(case= go-across-function 3
  (reset (let ((n 0))
           (tagbody again
             (incf n)
             (funcall (lambda () (when (< n 3) (go again))))) n)))
(case= pure-reset-nested-effect 111
  (reset (+ 100 (reset (+ 1 (shift k (funcall k 10)))))))

(case= direct-prefix-snapshots '(1 0 2)
  (reset (let ((x 1)) (list x (shift k (setf x 2) (funcall k 0)) x))))
(case= direct-prefix-specials '(6 0 7)
  (reset (let ((*test-special* 5))
           (list (incf *test-special*) (shift k (funcall k 0)) (incf *test-special*)))))
(case= direct-prefix-zero-primary '(nil 3)
  (reset (list (values) (shift k (funcall k 3)))))
(case= direct-prefix-native-error '(:cleanup :handled)
  (let ((log nil) (zero 0))
    (handler-case (reset (unwind-protect (list (/ 1 zero) (shift k (funcall k 0)))
                          (push :cleanup log)))
      (division-by-zero () (push :handled log)))
    (reverse log)))
(case= direct-prefix-sequence '(:one :two :three)
  (let ((log nil))
    (reset (push :one log) (push :two log) (shift k (funcall k 0)) (push :three log))
    (reverse log)))

(case= pure-block-return-values '(1 2)
  (multiple-value-list (reset (block b (return-from b (values 1 2)) 9))))
(case= pure-local-return 5
  (reset (flet ((f (x) (block b (when (> x 3) (return-from b 5)) x))) (f 7))))
(case= cross-lambda-return 7
  (reset (block b (funcall (lambda () (return-from b 7))) 9)))

(defun check (name expected actual)
  (incf *checks*)
  (unless (equal expected actual)
    (push (list name :expected expected :actual actual) *failures*)
    (format t "FAIL ~S expected ~S, got ~S~%" name expected actual)))
;; Native emission must preserve lexical function scope and escaping entries.
(case= native-mutual 1
  (reset (labels ((a (n) (if (zerop n) 1 (b (1- n))))
                  (b (n) (a n))) (a 100))))
(case= native-flet-shadow 4
  (reset (flet ((f (x) (+ x 1)))
           (flet ((f (x) (f (+ x 2)))) (f 1)))))
(case= native-escaped-function 10
  (funcall (reset (labels ((f (x) (+ x 3))) #'f)) 7))
(case= native-function-in-cps 14
  (reset (labels ((f (x) (+ x 4)))
           (+ (f 3) (shift k (funcall k (f 3)))))))
(case= native-typed-loop 45
  (reset (let ((acc 0)) (declare (type fixnum acc) (optimize (speed 3)))
           (dotimes (i 10 acc) (incf acc i)))))
(case= native-typed-lambda 7
  (reset (flet ((f (x) (declare (type fixnum x)) (+ x 3)))
           (declare (ftype (function (fixnum) fixnum) f) (inline f)) (f 4))))
(case= native-typed-locally 9
  (reset (let ((x 4)) (locally (declare (type fixnum x)) (+ x 5)))))
(case= native-escaped-boundary 'ooparts/continuation:native-boundary
  (let ((f (reset (lambda () (+ 1 2)))))
    (declare (ignore f))
    ;; A host callback cannot capture its native frame after a pure function.
    (handler-case
        (reset (host-callback (lambda (x) (shift k (funcall k x)))))
      (ooparts/continuation:native-boundary () 'ooparts/continuation:native-boundary))))

(defun run-form (form mode compiled)
  (let ((code (transform form nil mode)))
    (if compiled (funcall (compile nil `(lambda () ,code))) (eval code))))
(defun expect-condition (name type thunk)
  (handler-case (progn (funcall thunk) (check name type :no-condition))
    (error (e)
      (check name t (typep e type))
      (unless (typep e type)
        (format t "Condition mismatch: expected ~S, got ~S: ~A~%" type (type-of e) e)))))
(defun run-tests ()
  (let ((*checks* 0) (*failures* nil))
    ;; Exercise calls from ordinary host code, outside the CPS INVOKE path.
    (let ((function (lambda/cps (&rest arguments) (values-list arguments))))
      (check :native-cps-no-arguments nil (multiple-value-list (funcall function)))
      (check :native-cps-one-argument '(42) (multiple-value-list (funcall function 42)))
      (check :native-cps-multiple-arguments '(nil 42 :last)
             (multiple-value-list (funcall function nil 42 :last))))
    (dolist (case (reverse *cases*))
      (destructuring-bind (name expected form) case
        (dolist (mode '(:selective :full))
          (dolist (compiled '(nil t))
            (handler-case (check (list name mode compiled) expected (run-form form mode compiled))
              (error (e)
                (incf *checks*) (push (list name mode compiled e) *failures*)
                (format t "ERROR ~S ~S ~S: ~A~%" name mode compiled e)))))))
    (format t "Structured continuation cases completed.~%")
    (finish-output)
    (dolist (mode '(:selective :full))
      (format t "Boundary checks: ~S.~%" mode)
      (finish-output)
      (expect-condition (list :no-prompt mode) 'missing-reset
                        (lambda () (run-form '(shift k k) mode t)))
      (expect-condition (list :guarded-root-without-prompt mode) 'missing-reset
                        (lambda ()
                          (let ((ooparts/continuation/runtime:*native-call* t))
                            (run-form '(shift k k) mode t))))
      (expect-condition (list :native-boundary mode) 'native-boundary
                        (lambda () (run-form '(reset (host-callback (lambda (x) (shift k (+ x (funcall k 1)))))) mode t)))
      (check (list :native-local-reset mode) 105
             (run-form '(reset (host-callback (lambda (x) (reset (+ x (shift k (funcall k 3))))))) mode t)))
    (let ((k (reset (+ 10 (shift k k)))))
      (check :function-type t (functionp k))
      (check :continuation-type t (continuation-p k))
      (check :outside-multishot '(11 12 13) (list (funcall k 1) (funcall k 2) (funcall k 3))))
    (format t "Checking independent reduction semantics.~%")
    (finish-output)
    (let ((terms (append (generated-core-terms) (random-core-terms))))
      (loop for term in terms for index from 1 do
        (when (zerop (mod index 128))
          (format t "Reference progress: ~D/~D terms.~%" index (length terms))
          (finish-output))
        (let ((expected (reference-eval term)))
          (dolist (mode '(:selective :full))
            (handler-case (check (list :reference mode term) expected (run-form term mode t))
              (error (e) (incf *checks*) (push (list :reference term e) *failures*)
                (format t "REFERENCE ERROR ~S: ~A~%" term e))))))
      (format t "Independent reduction semantics: ~D terms, both modes.~%" (length terms)))
    (dolist (mode '(:selective :full))
      (check (list :tail-recursion mode) 100000
             (run-form '(reset (labels ((walk (n acc)
                                          (if (zerop n) (shift k (funcall k acc))
                                              (walk (1- n) (1+ acc))))) (walk 100000 0))) mode t))
      (check (list :deep-multishot mode) '(2001 2002)
             (run-form '(reset (labels ((walk (n)
                                          (if (zerop n) (shift k (list (funcall k 1) (funcall k 2)))
                                              (+ 1 (walk (1- n)))))) (walk 2000))) mode t)))
    (let ((k (reset (+ 10 (shift k k)))))
      (trivial-garbage:gc :full t)
      (check :after-full-gc 12 (funcall k 2))
      (if bordeaux-threads:*supports-threads-p*
          (let ((result nil))
            ;; JOIN-THREAD's return convention differs across older backends.
            ;; Test the continuation result, using JOIN only as a barrier.
            (bordeaux-threads:join-thread
             (bordeaux-threads:make-thread (lambda () (setf result (funcall k 3)))))
            (check :other-thread 13 result))
          (format t "Thread check skipped: this Lisp has no thread support.~%")))
    (expect-condition :pending-expired-block 'inactive-control-target
                      (lambda ()
                        (let ((k (with-cps (block b (reset (unwind-protect (return-from b :escaped)
                                                            (shift k k)))))))
                          (funcall k 0))))
    (expect-condition :native-unwind-boundary 'native-boundary
                      (lambda () (reset (unwind-protect (error "x") (shift k (funcall k 0))))))
    (expect-condition :go-target-outside-captured-prompt 'inactive-control-target
      (lambda ()
        (let ((saved nil))
          (with-cps (tagbody (setf saved (reset (shift k k) (go done))) done))
          (funcall saved 0))))
    (expect-condition :escaped-go-function 'inactive-control-target
      (lambda ()
        (let ((saved nil))
          (with-cps (tagbody (setf saved (lambda () (go done))) done))
          (funcall saved))))
    (check :pure-tagbody-is-direct :direct
           (getf (analyze '(let ((n 0)) (tagbody a (incf n) (when (< n 4) (go a))) n)) :effect))
    (check :pure-dotimes-is-direct :direct
           (getf (analyze '(let ((acc 7)) (dotimes (i 128 acc) (incf acc (1+ i))))) :effect))
    (format t "~D checks; ~D failures.~%" *checks* (length *failures*))
    (when *failures* (error "CPS tests failed (~D)." (length *failures*)))
    t))
