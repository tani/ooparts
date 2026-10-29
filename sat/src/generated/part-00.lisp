(in-package #:ooparts/sat/impl)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))
;;; upstream/satch.c:971:1
(defun |c/LITERAL| (arg-v-idx-1)
 (declare  (type (unsigned-byte 32) arg-v-idx-1))
 (let ((v-idx-1 0))
 (declare (type (unsigned-byte 32) v-idx-1) (ignorable v-idx-1))
 (tagbody
    (setf v-idx-1 arg-v-idx-1)
    (return-from |c/LITERAL| (c-u32 (ash (c-u32 v-idx-1) 1)))
  )
  0))

;;; upstream/satch.c:980:1
(defun |c/INDEX| (arg-v-lit-2)
 (declare  (type (unsigned-byte 32) arg-v-lit-2))
 (let ((v-lit-2 0))
 (declare (type (unsigned-byte 32) v-lit-2) (ignorable v-lit-2))
 (tagbody
    (setf v-lit-2 arg-v-lit-2)
    (return-from |c/INDEX| (c-u32 (ash (c-u32 v-lit-2) (- 1))))
  )
  0))

;;; upstream/satch.c:988:1
(defun |c/SIGN_BIT| (arg-v-lit-3)
 (declare  (type (unsigned-byte 32) arg-v-lit-3))
 (let ((v-lit-3 0))
 (declare (type (unsigned-byte 32) v-lit-3) (ignorable v-lit-3))
 (tagbody
    (setf v-lit-3 arg-v-lit-3)
    (return-from |c/SIGN_BIT| (c-u32 (logand v-lit-3 (c-u32 1))))
  )
  0))

;;; upstream/satch.c:997:1
(defun |c/INT_SIGN| (arg-v-lit-4)
 (declare  (type (unsigned-byte 32) arg-v-lit-4))
 (let ((v-lit-4 0))
 (declare (type (unsigned-byte 32) v-lit-4) (ignorable v-lit-4))
 (tagbody
    (setf v-lit-4 arg-v-lit-4)
    (return-from |c/INT_SIGN| (if (c-true (|c/SIGN_BIT| v-lit-4)) (c-s32 (- 1)) 1))
  )
  0))

;;; upstream/satch.c:1005:1
(defun |c/NOT| (arg-v-lit-5)
 (declare  (type (unsigned-byte 32) arg-v-lit-5))
 (let ((v-lit-5 0))
 (declare (type (unsigned-byte 32) v-lit-5) (ignorable v-lit-5))
 (tagbody
    (setf v-lit-5 arg-v-lit-5)
    (return-from |c/NOT| (c-u32 (logxor v-lit-5 (c-u32 1))))
  )
  0))

;;; upstream/satch.c:1199:1
(defun |c/export_literal| (arg-v-ilit-6)
 (declare  (type (unsigned-byte 32) arg-v-ilit-6))
 (let ((v-ilit-6 0) (v-iidx-7 0) (v-eidx-8 0) (v-elit-9 0))
 (declare (type (unsigned-byte 32) v-ilit-6) (type (unsigned-byte 32) v-iidx-7) (type (signed-byte 32) v-eidx-8) (type (signed-byte 32) v-elit-9) (ignorable v-ilit-6 v-iidx-7 v-eidx-8 v-elit-9))
 (tagbody
    (setf v-ilit-6 arg-v-ilit-6)
    (setf v-iidx-7 (|c/INDEX| v-ilit-6))
    (setf v-eidx-8 (c-s32 (c-u32 (+ v-iidx-7 (c-u32 1)))))
    (setf v-elit-9 (if (c-true (|c/SIGN_BIT| v-ilit-6)) (c-s32 (- v-eidx-8)) v-eidx-8))
    (return-from |c/export_literal| (c-u32 v-elit-9))
  )
  0))

;;; upstream/satch.c:1283:1
(defun |c/fatal_error| (arg-v-fmt-10 &rest varargs)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-fmt-10))
 (let ((v-fmt-10 0) (v-colors-11 0) (v-terminal_file-12 0) (v-ap-13 0))
 (declare (type c-address v-fmt-10) (type (integer 0 1) v-colors-11) (type c-address v-terminal_file-12) (ignorable v-fmt-10 v-colors-11 v-terminal_file-12 v-ap-13))
 (tagbody
    (setf v-fmt-10 arg-v-fmt-10)
    (setf v-colors-11 (c-bool (c-isatty 2)))
    (setf v-terminal_file-12 (if (c-true (if (= 2 1) 1 0)) 1 2))
    (progn v-terminal_file-12)
    (progn (c-fprintf 2 |c/string/0| (if (c-true v-colors-11) |c/string/1| |c/string/2|) (if (c-true v-colors-11) |c/string/3| |c/string/2|) (if (c-true v-colors-11) |c/string/4| |c/string/2|)))
    (progn (setf v-ap-13 varargs))
    (progn (c-vfprintf 2 v-fmt-10 v-ap-13))
    (progn (c-fputc 10 2))
    (progn (c-fflush 2))
    (progn (c-abort))
  )
  0))

;;; upstream/satch.c:1299:1
(defun |c/out_of_memory| (arg-v-bytes-14)
 (declare (optimize (speed 1) (safety 1)) (type c-size arg-v-bytes-14))
 (let ((v-bytes-14 0))
 (declare (type c-size v-bytes-14) (ignorable v-bytes-14))
 (tagbody
    (setf v-bytes-14 arg-v-bytes-14)
    (progn (|c/fatal_error| |c/string/5| v-bytes-14))
  )
  0))

;;; upstream/satch.c:1309:1
(defun |c/message| (arg-v-solver-15 arg-v-level-16 arg-v-name-17 arg-v-count-18 arg-v-fmt-19 &rest varargs)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-solver-15) (type (unsigned-byte 32) arg-v-level-16) (type c-address arg-v-name-17) (type (unsigned-byte 64) arg-v-count-18) (type c-address arg-v-fmt-19))
 (let ((v-solver-15 0) (v-level-16 0) (v-name-17 0) (v-count-18 0) (v-fmt-19 0) (v-ap-22 0))
 (declare (type c-address v-solver-15) (type (unsigned-byte 32) v-level-16) (type c-address v-name-17) (type (unsigned-byte 64) v-count-18) (type c-address v-fmt-19) (ignorable v-solver-15 v-level-16 v-name-17 v-count-18 v-fmt-19 v-ap-22))
 (tagbody
    (setf v-solver-15 arg-v-solver-15)
    (setf v-level-16 arg-v-level-16)
    (setf v-name-17 arg-v-name-17)
    (setf v-count-18 arg-v-count-18)
    (setf v-fmt-19 arg-v-fmt-19)
    (unless (c-true (if (< (m-u32 (+ (+ v-solver-15 880) 4)) v-level-16) 1 0)) (go ELSE20))
    (return-from |c/message| 0)
    ELSE20
    (progn (c-fputs |c/string/6| 1))
    (progn (c-printf |c/string/7| v-name-17 v-count-18))
    (progn (setf v-ap-22 varargs))
    (progn (c-vprintf v-fmt-19 v-ap-22))
    (progn (c-fputc 10 1))
    (progn (c-fflush 1))
  )
  0))

;;; upstream/satch.c:1330:1
(defun |c/internal_section| (arg-v-solver-23 arg-v-name-24)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-solver-23) (type c-address arg-v-name-24))
 (let ((v-solver-23 0) (v-name-24 0) (v-colors-29 0) (v-terminal_file-30 0) (v-i-54 0))
 (declare (type c-address v-solver-23) (type c-address v-name-24) (type (integer 0 1) v-colors-29) (type c-address v-terminal_file-30) (type c-size v-i-54) (ignorable v-solver-23 v-name-24 v-colors-29 v-terminal_file-30 v-i-54))
 (tagbody
    (setf v-solver-23 arg-v-solver-23)
    (setf v-name-24 arg-v-name-24)
    (unless (c-true (m-u64 (+ (+ v-solver-23 1016) 272))) (go ELSE25))
    (progn (c-fputs |c/string/8| 1))
    (go ENDIF26)
    ELSE25
    ENDIF26
    (progn (progn 0 (let* ((a27 (+ (+ v-solver-23 1016) 272)) (old28 (m-u64 a27))) (setf (m-u64 a27) (c-u64 (c-u64 (+ old28 (c-u64 1))))) (m-u64 a27))))
    (setf v-colors-29 (c-bool (c-isatty 1)))
    (setf v-terminal_file-30 (if (c-true (if (= 1 1) 1 0)) 1 2))
    (progn v-terminal_file-30)
    (progn (c-fputs |c/string/6| 1))
    (unless (c-true v-colors-29) (go ELSE34))
    (progn (c-fputs |c/string/9| v-terminal_file-30))
    (go ENDIF35)
    ELSE34
    ENDIF35
    (progn (c-fputs |c/string/10| 1))
    (unless (c-true v-colors-29) (go ELSE39))
    (progn (c-fputs |c/string/1| v-terminal_file-30))
    (go ENDIF40)
    ELSE39
    ENDIF40
    (progn (c-fputs v-name-24 1))
    (unless (c-true v-colors-29) (go ELSE44))
    (progn (c-fputs |c/string/4| v-terminal_file-30))
    (go ENDIF45)
    ELSE44
    ENDIF45
    (unless (c-true v-colors-29) (go ELSE49))
    (progn (c-fputs |c/string/9| v-terminal_file-30))
    (go ENDIF50)
    ELSE49
    ENDIF50
    (progn (c-fputs |c/string/11| 1))
    (setf v-i-54 (c-strlen v-name-24))
    LOOP51
    (unless (c-true (if (< v-i-54 (c-u64 66)) 1 0)) (go ENDLOOP52))
    (progn (c-putc 45 1))
    (let* ( (old56 v-i-54)) (setf v-i-54 (c-u64 (c-u64 (+ old56 (c-u64 1))))) old56)
    (go LOOP51)
    ENDLOOP52
    (unless (c-true v-colors-29) (go ELSE60))
    (progn (c-fputs |c/string/4| v-terminal_file-30))
    (go ENDIF61)
    ELSE60
    ENDIF61
    (progn (c-fputs |c/string/12| 1))
    (progn (c-fflush 1))
  )
  0))

;;; upstream/satch.c:1357:1
(defun |c/is_temporary_binary| (arg-v-solver-62 arg-v-c-63)
 (declare  (type c-address arg-v-solver-62) (type c-address arg-v-c-63))
 (let ((v-solver-62 0) (v-c-63 0))
 (declare (type c-address v-solver-62) (type c-address v-c-63) (ignorable v-solver-62 v-c-63))
 (tagbody
    (setf v-solver-62 arg-v-solver-62)
    (setf v-c-63 arg-v-c-63)
    (return-from |c/is_temporary_binary| (c-bool (if (c-true (if (= v-c-63 (+ v-solver-62 424)) 1 0)) 1 (c-bool (if (= v-c-63 (+ (+ v-solver-62 424) (* 24 1))) 1 0)))))
  )
  0))

;;; upstream/satch.c:1598:1
(defun |c/process_time| ()
 (declare (optimize (speed 1) (safety 1)) )
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-u-64 (stack-alloc 144)) (v-res-65 0d0))
 (declare (type c-address v-u-64) (type double-float v-res-65) (ignorable v-u-64 v-res-65))
 (tagbody
    (unless (c-true (c-getrusage 0 v-u-64)) (go ELSE66))
    (return-from |c/process_time| (float 0 1d0))
    ELSE66
    (progn (setf v-res-65 (float (+ (integer64-double (m-s64 (+ (+ v-u-64 0) 0)) t) (float (* 1d-06 (integer64-double (m-s64 (+ (+ v-u-64 0) 8)) t)) 1d0)) 1d0)))
    (progn (setf v-res-65 (float (float (+ v-res-65 (float (+ (integer64-double (m-s64 (+ (+ v-u-64 16) 0)) t) (float (* 1d-06 (integer64-double (m-s64 (+ (+ v-u-64 16) 8)) t)) 1d0)) 1d0)) 1d0) 1d0)))
    (return-from |c/process_time| v-res-65)
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:1612:1
(defun |c/maximum_resident_set_size| ()
 (declare (optimize (speed 1) (safety 1)) )
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-u-69 (stack-alloc 144)))
 (declare (type c-address v-u-69) (ignorable v-u-69))
 (tagbody
    (unless (c-true (c-getrusage 0 v-u-69)) (go ELSE70))
    (return-from |c/maximum_resident_set_size| (c-u64 0))
    ELSE70
    (return-from |c/maximum_resident_set_size| (c-u64 (ash (c-u64 (c-u64 (m-s64 (+ v-u-69 32)))) 10)))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:1624:1
(defun |c/current_resident_set_size| ()
 (declare (optimize (speed 1) (safety 1)) )
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-path-72 (stack-alloc 48)) (v-file-73 0) (v-dummy-76 (stack-alloc 8)) (v-rss-77 (stack-alloc 8)) (v-scanned-78 0))
 (declare (type c-address v-path-72) (type c-address v-file-73) (type c-address v-dummy-76) (type c-address v-rss-77) (type (signed-byte 32) v-scanned-78) (ignorable v-path-72 v-file-73 v-dummy-76 v-rss-77 v-scanned-78))
 (tagbody
    (progn (c-sprintf v-path-72 |c/string/13| (c-u64 (c-getpid))))
    (setf v-file-73 (c-fopen v-path-72 |c/string/14|))
    (unless (c-true (if (c-true v-file-73) 0 1)) (go ELSE74))
    (return-from |c/current_resident_set_size| (c-u64 0))
    ELSE74
    (setf v-scanned-78 (c-fscanf v-file-73 |c/string/15| v-dummy-76 v-rss-77))
    (progn (c-fclose v-file-73))
    (return-from |c/current_resident_set_size| (if (c-true (if (= v-scanned-78 2) 1 0)) (c-u64 (* (m-u64 v-rss-77) (c-u64 (c-sysconf 30)))) (c-u64 0)))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:1645:1
(defun |c/percent| (arg-v-a-79 arg-v-b-80)
 (declare (optimize (speed 1) (safety 1)) (type double-float arg-v-a-79) (type double-float arg-v-b-80))
 (let ((v-a-79 0d0) (v-b-80 0d0))
 (declare (type double-float v-a-79) (type double-float v-b-80) (ignorable v-a-79 v-b-80))
 (tagbody
    (setf v-a-79 arg-v-a-79)
    (setf v-b-80 arg-v-b-80)
    (return-from |c/percent| (if (c-true v-b-80) (float (/ (float (* 100.0d0 v-a-79) 1d0) v-b-80) 1d0) (float 0 1d0)))
  )
  0))

;;; upstream/satch.c:1651:1
(defun |c/relative| (arg-v-a-81 arg-v-b-82)
 (declare (optimize (speed 1) (safety 1)) (type double-float arg-v-a-81) (type double-float arg-v-b-82))
 (let ((v-a-81 0d0) (v-b-82 0d0))
 (declare (type double-float v-a-81) (type double-float v-b-82) (ignorable v-a-81 v-b-82))
 (tagbody
    (setf v-a-81 arg-v-a-81)
    (setf v-b-82 arg-v-b-82)
    (return-from |c/relative| (if (c-true v-b-82) (float (/ v-a-81 v-b-82) 1d0) (float 0 1d0)))
  )
  0))

;;; upstream/satch.c:1674:1
(defun |c/init_profiles| (arg-v-solver-83)
 (declare  (type c-address arg-v-solver-83))
 (let ((v-solver-83 0) (v-profiles-84 0))
 (declare (type c-address v-solver-83) (type c-address v-profiles-84) (ignorable v-solver-83 v-profiles-84))
 (tagbody
    (setf v-solver-83 arg-v-solver-83)
    (setf v-profiles-84 (+ v-solver-83 1472))
    (progn (setf (m-ptr (+ v-profiles-84 392)) (+ v-profiles-84 264)))
    (progn (setf (m-ptr (+ (+ v-profiles-84 0) 16)) |c/string/16|))
    (progn (setf (m-ptr (+ (+ v-profiles-84 24) 16)) |c/string/17|))
    (progn (setf (m-ptr (+ (+ v-profiles-84 48) 16)) |c/string/18|))
    (progn (setf (m-ptr (+ (+ v-profiles-84 72) 16)) |c/string/19|))
    (progn (setf (m-ptr (+ (+ v-profiles-84 96) 16)) |c/string/20|))
    (progn (setf (m-ptr (+ (+ v-profiles-84 120) 16)) |c/string/21|))
    (progn (setf (m-ptr (+ (+ v-profiles-84 144) 16)) |c/string/22|))
    (progn (setf (m-ptr (+ (+ v-profiles-84 168) 16)) |c/string/23|))
    (progn (setf (m-ptr (+ (+ v-profiles-84 192) 16)) |c/string/24|))
    (progn (setf (m-ptr (+ (+ v-profiles-84 216) 16)) |c/string/25|))
    (progn (setf (m-ptr (+ (+ v-profiles-84 240) 16)) |c/string/26|))
  )
  0))

;;; upstream/satch.c:1685:1
(defun |c/start_profiling| (arg-v-solver-85 arg-v-profile-86)
 (declare  (type c-address arg-v-solver-85) (type c-address arg-v-profile-86))
 (let ((v-solver-85 0) (v-profile-86 0) (v-profiles-87 0) (v-start-88 0d0))
 (declare (type c-address v-solver-85) (type c-address v-profile-86) (type c-address v-profiles-87) (type double-float v-start-88) (ignorable v-solver-85 v-profile-86 v-profiles-87 v-start-88))
 (tagbody
    (setf v-solver-85 arg-v-solver-85)
    (setf v-profile-86 arg-v-profile-86)
    (setf v-profiles-87 (+ v-solver-85 1472))
    (setf v-start-88 (|c/process_time|))
    (progn (setf (m-f64 (+ v-profile-86 0)) v-start-88))
    (progn (setf (m-ptr (let* ((a89 (+ v-profiles-87 392)) (old90 (m-ptr a89))) (setf (m-ptr a89) (+ old90 (* 8 1))) old90)) v-profile-86))
  )
  0))

;;; upstream/satch.c:1705:1
(defun |c/stop_profiling| (arg-v-solver-91 arg-v-profile-92 arg-v-stop-93)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-solver-91) (type c-address arg-v-profile-92) (type double-float arg-v-stop-93))
 (let ((v-solver-91 0) (v-profile-92 0) (v-stop-93 0d0) (v-profiles-94 0) (v-time-95 0d0))
 (declare (type c-address v-solver-91) (type c-address v-profile-92) (type double-float v-stop-93) (type c-address v-profiles-94) (type double-float v-time-95) (ignorable v-solver-91 v-profile-92 v-stop-93 v-profiles-94 v-time-95))
 (tagbody
    (setf v-solver-91 arg-v-solver-91)
    (setf v-profile-92 arg-v-profile-92)
    (setf v-stop-93 arg-v-stop-93)
    (setf v-profiles-94 (+ v-solver-91 1472))
    (setf v-time-95 (float (- v-stop-93 (m-f64 (+ v-profile-92 0))) 1d0))
    (progn (let ((a96 (+ v-profile-92 8))) (setf (m-f64 a96) (float (float (+ (m-f64 a96) v-time-95) 1d0) 1d0))))
    (progn (progn 0 (m-ptr (let* ((a97 (+ v-profiles-94 392)) (old98 (m-ptr a97))) (setf (m-ptr a97) (- old98 (* 8 1))) (m-ptr a97)))))
    (return-from |c/stop_profiling| v-time-95)
  )
  0))

;;; upstream/satch.c:1721:1
(defun |c/flush_profiles| (arg-v-solver-99)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-solver-99))
 (let ((v-solver-99 0) (v-profiles-100 0) (v-stop-101 0d0))
 (declare (type c-address v-solver-99) (type c-address v-profiles-100) (type double-float v-stop-101) (ignorable v-solver-99 v-profiles-100 v-stop-101))
 (tagbody
    (setf v-solver-99 arg-v-solver-99)
    (setf v-profiles-100 (+ v-solver-99 1472))
    (setf v-stop-101 (|c/process_time|))
    LOOP102
    (unless (c-true (if (c-true (if (= (m-ptr (+ v-profiles-100 392)) (+ v-profiles-100 264)) 1 0)) 0 1)) (go ENDLOOP103))
    (progn (|c/stop_profiling| v-solver-99 (progn 0 (m-ptr (+ (m-ptr (+ v-profiles-100 392)) (* 8 (c-s32 (- 1)))))) v-stop-101))
    (go LOOP102)
    ENDLOOP103
    (progn (setf (m-f64 (+ (+ v-profiles-100 240) 8)) (float (+ (m-f64 (+ (+ v-profiles-100 48) 8)) (m-f64 (+ (+ v-profiles-100 96) 8))) 1d0)))
    (return-from |c/flush_profiles| v-stop-101)
  )
  0))

