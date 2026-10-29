(uiop:define-package #:ooparts-tests/sat/storage
  (:use #:cl #:ooparts/sat/runtime)
  (:export #:run-tests))
(in-package #:ooparts-tests/sat/storage)

(defun run-tests ()
  (let ((checks 0) (cell (c-malloc 64)))
    (macrolet ((check (value)
                 `(progn (incf checks)
                         (assert ,value () "Arena check ~D failed: ~S" checks ',value))))
      (unwind-protect
           (progn
             ;; Literal addresses belong to the loading process, and repeated
             ;; evaluation of the compiled expression performs no allocation.
             (let* ((literal (compile nil '(lambda () (c-string-literal "SAT literal"))))
                    (address (funcall literal)) (top *heap-top*))
               (check (string= (lisp-string address) "SAT literal"))
               (check (= address (funcall literal)))
               (check (= top *heap-top*)))
             ;; Cross-width accesses test the representation, not just a pair
             ;; of matching encoders and decoders. Unaligned words are legal.
             (setf (m-u64 (+ cell 1)) #x0123456789abcdef)
             (check (equal (loop for i from 1 to 8 collect (m-u8 (+ cell i)))
                           '(#xef #xcd #xab #x89 #x67 #x45 #x23 #x01)))
             (check (= (m-u16 (+ cell 2)) #xabcd))
             (check (= (m-u32 (+ cell 3)) #x456789ab))
             (macrolet ((signed (accessor unsigned bits)
                          `(dolist (value (list (- (ash 1 (1- ,bits))) -1 0
                                                (1- (ash 1 (1- ,bits)))))
                             (setf (,accessor cell) value)
                             (check (= (,accessor cell) value))
                             (check (= (,unsigned cell) (ldb (byte ,bits 0) value))))))
               (signed m-s8 m-u8 8) (signed m-s16 m-u16 16)
               (signed m-s32 m-u32 32) (signed m-s64 m-u64 64))
             (dolist (pair '((0f0 0) (1f0 #x3f800000) (-2f0 #xc0000000)
                             (1.5f0 #x3fc00000) (0.125f0 #x3e000000)))
               (setf (m-f32 cell) (first pair))
               (check (= (m-u32 cell) (second pair)))
               (check (= (m-f32 cell) (first pair))))
             (dolist (pair '((0d0 0) (1d0 #x3ff0000000000000) (-2d0 #xc000000000000000)
                             (1.5d0 #x3ff8000000000000) (0.125d0 #x3fc0000000000000)))
               (setf (m-f64 cell) (first pair))
               (check (= (m-u64 cell) (second pair)))
               (check (= (m-f64 cell) (first pair))))
             ;; Subnormals and signed zero are tested when the host represents
             ;; them. Some conforming Lisps have normalized floats only.
             (when (< least-positive-single-float least-positive-normalized-single-float)
               (setf (m-f32 cell) least-positive-single-float)
               (check (= (m-u32 cell) 1))
               (check (= (m-f32 cell) least-positive-single-float)))
             (when (< least-positive-double-float least-positive-normalized-double-float)
               (setf (m-f64 cell) least-positive-double-float)
               (check (= (m-u64 cell) 1))
               (check (= (m-f64 cell) least-positive-double-float)))
             ;; A compiler may coalesce EQL zero literals. Construct the sign
             ;; at runtime so this checks storage rather than FASL constants.
             (let ((negative-zero (locally (declare (notinline float-sign))
                                    (float-sign -1d0 0d0))))
               (when (minusp (float-sign negative-zero))
                 (setf (m-f64 cell) negative-zero)
                 (check (= (m-u64 cell) #x8000000000000000))
                 (check (minusp (float-sign (m-f64 cell))))))
             (dotimes (i 16) (setf (m-u8 (+ cell i)) i))
             (copy-bytes (+ cell 2) cell 10)
             (check (equal (loop for i below 12 collect (m-u8 (+ cell i)))
                           '(0 1 0 1 2 3 4 5 6 7 8 9)))
             (copy-bytes cell (+ cell 2) 10)
             (check (equal (loop for i below 10 collect (m-u8 (+ cell i)))
                           '(0 1 2 3 4 5 6 7 8 9)))
             (c-memset (+ cell 1) -1 7)
             (check (= (m-u64 cell) #xffffffffffffff00))
             ;; Growing either arena must preserve all previous virtual
             ;; addresses and bytes, including a copy across the two arenas.
             (let* ((*stack-top* *stack-top*)
                    (automatic (stack-alloc 8192)) (large (c-malloc 16384)))
               (unwind-protect
                    (progn
                      (setf (m-u64 cell) #x123456789abcdef0)
                      (copy-bytes automatic cell 8)
                      (copy-bytes large automatic 8)
                      (check (= (m-u64 large) #x123456789abcdef0))
                      (check (= (m-u64 cell) #x123456789abcdef0)))
                 (c-free large))))
        (c-free cell)))
    (format t "Arena storage: ~D checks passed.~%" checks)))
