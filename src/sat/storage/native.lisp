(uiop:define-package #:ooparts/sat/storage/native
  (:use #:cl)
  (:use-reexport #:ooparts/sat/storage/state)
  (:export #:ensure-arenas #:ensure-heap-space #:ensure-stack-space #:checked-sap #:define-memory-accessor #:m-u8 #:m-u16 #:m-u32 #:m-u64 #:m-s8 #:m-s16 #:m-s32 #:m-s64 #:m-f32 #:m-f64 #:copy-bytes #:c-memset #:backend-description #:storage-policy))
(in-package #:ooparts/sat/storage/native)

(defmacro storage-policy ()
  '(declaim (optimize (speed 3) (safety 1) (debug 1))))
(storage-policy)
(declaim (type (or null sb-sys:system-area-pointer) *heap* *stack*))

(defun ensure-arenas ()
  (unless *heap*
    (setf *heap* (sb-sys:allocate-system-memory +heap-size+)
          *stack* (sb-sys:allocate-system-memory +stack-size+)
          *heap-top* 16 *stack-top* 0
          *heap-start* (the (unsigned-byte 57) (sb-sys:sap-int *heap*))
          *stack-start* (the (unsigned-byte 57) (sb-sys:sap-int *stack*)))))

(declaim (inline ensure-heap-space ensure-stack-space))
(defun ensure-heap-space (size) (declare (ignore size)) nil)
(defun ensure-stack-space (size) (declare (ignore size)) nil)

(defmacro checked-sap (address width)
  `(sb-sys:int-sap (checked-address ,address ,width)))
(defmacro define-memory-accessor (name primitive width type)
  (declare (optimize (speed 1) (safety 3)))
  `(progn
     (defmacro ,name (address)
       (list ',primitive (list 'checked-sap address ,width) 0))
     (defsetf ,name (address) (value)
       (list 'setf (list ',primitive (list 'checked-sap address ,width) 0)
             (list 'the ',type value)))))
(define-memory-accessor m-u8 sb-sys:sap-ref-8 1 (unsigned-byte 8))
(define-memory-accessor m-u16 sb-sys:sap-ref-16 2 (unsigned-byte 16))
(define-memory-accessor m-u32 sb-sys:sap-ref-32 4 (unsigned-byte 32))
(define-memory-accessor m-u64 sb-sys:sap-ref-64 8 (unsigned-byte 64))
(define-memory-accessor m-s8 sb-sys:signed-sap-ref-8 1 (signed-byte 8))
(define-memory-accessor m-s16 sb-sys:signed-sap-ref-16 2 (signed-byte 16))
(define-memory-accessor m-s32 sb-sys:signed-sap-ref-32 4 (signed-byte 32))
(define-memory-accessor m-s64 sb-sys:signed-sap-ref-64 8 (signed-byte 64))
(define-memory-accessor m-f32 sb-sys:sap-ref-single 4 single-float)
(define-memory-accessor m-f64 sb-sys:sap-ref-double 8 double-float)

(declaim (ftype (function (c-address c-address c-size) (values c-address &optional)) copy-bytes))
(defun copy-bytes (destination source size)
  (declare (type c-address destination) (type c-address source) (type c-size size))
  (when (plusp size)
    (let ((dst (checked-sap destination size)) (src (checked-sap source size)))
      (if (and (> destination source) (< destination (+ source size)))
          (loop for i downfrom (1- size) to 0 do
            (setf (sb-sys:sap-ref-8 dst i) (sb-sys:sap-ref-8 src i)))
          (loop for i fixnum below size do
            (setf (sb-sys:sap-ref-8 dst i) (sb-sys:sap-ref-8 src i))))))
  destination)

(declaim (ftype (function (c-address (signed-byte 32) c-size) (values c-address &optional)) c-memset))
(defun c-memset (d v n)
  (declare (type c-address d) (type (signed-byte 32) v) (type c-size n))
  (when (plusp n)
    (let ((sap (checked-sap d n)) (byte (ldb (byte 8 0) v)))
      (dotimes (i n) (setf (sb-sys:sap-ref-8 sap i) byte))))
  d)

(declaim (ftype (function () (values simple-string &optional)) backend-description))
(defun backend-description ()
  "Common Lisp / SBCL native arenas; SATCH production defaults (-DNDEBUG)")
