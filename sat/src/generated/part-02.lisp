(in-package #:ooparts/sat/impl)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))
;;; upstream/satch.c:2294:1
(defun |c/new_irredundant_clause| (arg-v-solver-370)
 (declare  (type c-address arg-v-solver-370))
 (let ((v-solver-370 0) (v-res-371 0) (v-old_size-380 0) (v-old_capacity-381 0) (v-new_capacity-382 0) (v-new_bytes-383 0))
 (declare (type c-address v-solver-370) (type c-address v-res-371) (type c-size v-old_size-380) (type c-size v-old_capacity-381) (type c-size v-new_capacity-382) (type c-size v-new_bytes-383) (ignorable v-solver-370 v-res-371 v-old_size-380 v-old_capacity-381 v-new_capacity-382 v-new_bytes-383))
 (tagbody
    (setf v-solver-370 arg-v-solver-370)
    (setf v-res-371 (|c/add_clause| v-solver-370 (c-bool 0) (c-u32 0)))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-370 672) 8)) (m-ptr (+ (+ v-solver-370 672) 16))) 1 0)) (go ELSE375))
    (setf v-old_size-380 (the c-size (truncate (- (m-ptr (+ (+ v-solver-370 672) 8)) (m-ptr (+ (+ v-solver-370 672) 0))) 8)))
    (setf v-old_capacity-381 (the c-size (truncate (- (m-ptr (+ (+ v-solver-370 672) 16)) (m-ptr (+ (+ v-solver-370 672) 0))) 8)))
    (setf v-new_capacity-382 (if (c-true v-old_capacity-381) (c-u64 (* (c-u64 2) v-old_capacity-381)) (c-u64 1)))
    (setf v-new_bytes-383 (c-u64 (* v-new_capacity-382 8)))
    (progn (setf (m-ptr (+ (+ v-solver-370 672) 0)) (c-realloc (m-ptr (+ (+ v-solver-370 672) 0)) v-new_bytes-383)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-370 672) 0))) 0 1)) (go ELSE384))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-383))
    (go ENDIF385)
    ELSE384
    ENDIF385
    (progn (setf (m-ptr (+ (+ v-solver-370 672) 8)) (+ (m-ptr (+ (+ v-solver-370 672) 0)) (* 8 v-old_size-380))))
    (progn (setf (m-ptr (+ (+ v-solver-370 672) 16)) (+ (m-ptr (+ (+ v-solver-370 672) 0)) (* 8 v-new_capacity-382))))
    (go ENDIF376)
    ELSE375
    ENDIF376
    (progn (setf (m-ptr (let* ((a386 (+ (+ v-solver-370 672) 8)) (old387 (m-ptr a386))) (setf (m-ptr a386) (+ old387 (* 8 1))) old387)) v-res-371))
    (progn (progn 0 (let* ((a388 (+ (+ v-solver-370 1016) 120)) (old389 (m-u64 a388))) (setf (m-u64 a388) (c-u64 (c-u64 (+ old389 (c-u64 1))))) (m-u64 a388))))
    (return-from |c/new_irredundant_clause| v-res-371)
  )
  0))

;;; upstream/satch.c:2309:1
(defun |c/new_redundant_clause| (arg-v-solver-390 arg-v-glue-391)
 (declare  (type c-address arg-v-solver-390) (type (unsigned-byte 32) arg-v-glue-391))
 (let ((v-solver-390 0) (v-glue-391 0) (v-res-392 0) (v-old_size-401 0) (v-old_capacity-402 0) (v-new_capacity-403 0) (v-new_bytes-404 0))
 (declare (type c-address v-solver-390) (type (unsigned-byte 32) v-glue-391) (type c-address v-res-392) (type c-size v-old_size-401) (type c-size v-old_capacity-402) (type c-size v-new_capacity-403) (type c-size v-new_bytes-404) (ignorable v-solver-390 v-glue-391 v-res-392 v-old_size-401 v-old_capacity-402 v-new_capacity-403 v-new_bytes-404))
 (tagbody
    (setf v-solver-390 arg-v-solver-390)
    (setf v-glue-391 arg-v-glue-391)
    (setf v-res-392 (|c/add_clause| v-solver-390 (c-bool 1) v-glue-391))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-390 696) 8)) (m-ptr (+ (+ v-solver-390 696) 16))) 1 0)) (go ELSE396))
    (setf v-old_size-401 (the c-size (truncate (- (m-ptr (+ (+ v-solver-390 696) 8)) (m-ptr (+ (+ v-solver-390 696) 0))) 8)))
    (setf v-old_capacity-402 (the c-size (truncate (- (m-ptr (+ (+ v-solver-390 696) 16)) (m-ptr (+ (+ v-solver-390 696) 0))) 8)))
    (setf v-new_capacity-403 (if (c-true v-old_capacity-402) (c-u64 (* (c-u64 2) v-old_capacity-402)) (c-u64 1)))
    (setf v-new_bytes-404 (c-u64 (* v-new_capacity-403 8)))
    (progn (setf (m-ptr (+ (+ v-solver-390 696) 0)) (c-realloc (m-ptr (+ (+ v-solver-390 696) 0)) v-new_bytes-404)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-390 696) 0))) 0 1)) (go ELSE405))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-404))
    (go ENDIF406)
    ELSE405
    ENDIF406
    (progn (setf (m-ptr (+ (+ v-solver-390 696) 8)) (+ (m-ptr (+ (+ v-solver-390 696) 0)) (* 8 v-old_size-401))))
    (progn (setf (m-ptr (+ (+ v-solver-390 696) 16)) (+ (m-ptr (+ (+ v-solver-390 696) 0)) (* 8 v-new_capacity-403))))
    (go ENDIF397)
    ELSE396
    ENDIF397
    (progn (setf (m-ptr (let* ((a407 (+ (+ v-solver-390 696) 8)) (old408 (m-ptr a407))) (setf (m-ptr a407) (+ old408 (* 8 1))) old408)) v-res-392))
    (progn (progn 0 (let* ((a409 (+ (+ v-solver-390 1016) 208)) (old410 (m-u64 a409))) (setf (m-u64 a409) (c-u64 (c-u64 (+ old410 (c-u64 1))))) (m-u64 a409))))
    (return-from |c/new_redundant_clause| v-res-392)
  )
  0))

;;; upstream/satch.c:2335:1
(defun |c/delete_clause| (arg-v-solver-411 arg-v-c-412)
 (declare  (type c-address arg-v-solver-411) (type c-address arg-v-c-412))
 (let ((v-solver-411 0) (v-c-412 0))
 (declare (type c-address v-solver-411) (type c-address v-c-412) (ignorable v-solver-411 v-c-412))
 (tagbody
    (setf v-solver-411 arg-v-solver-411)
    (setf v-c-412 arg-v-c-412)
    (progn (progn 0 (let* ((a413 (+ (+ v-solver-411 1016) 56)) (old414 (m-u64 a413))) (setf (m-u64 a413) (c-u64 (c-u64 (+ old414 (c-u64 1))))) (m-u64 a413))))
    (progn v-solver-411)
    (unless (c-true (if (c-true (ldb (byte 1 0) (m-u8 (+ v-c-412 0)))) 0 1)) (go ELSE418))
    (progn (|c/trace_and_check_clause_deletion| v-solver-411 v-c-412))
    (unless (c-true (ldb (byte 1 2) (m-u8 (+ v-c-412 0)))) (go ELSE420))
    (progn (let* ((a425 (+ (+ v-solver-411 1016) 208)) (old426 (m-u64 a425))) (setf (m-u64 a425) (c-u64 (c-u64 (- old426 (c-u64 1))))) old426))
    (go ENDIF421)
    ELSE420
    (progn (let* ((a430 (+ (+ v-solver-411 1016) 120)) (old431 (m-u64 a430))) (setf (m-u64 a430) (c-u64 (c-u64 (- old431 (c-u64 1))))) old431))
    ENDIF421
    (go ENDIF419)
    ELSE418
    ENDIF419
    (return-from |c/delete_clause| (|c/deallocate_clause| v-c-412))
  )
  0))

;;; upstream/satch.c:2357:1
(defun |c/watch_literal| (arg-v-solver-432 arg-v-redundant-433 arg-v-lit-434 arg-v-blocking-435 arg-v-c-436)
 (declare  (type c-address arg-v-solver-432) (type (integer 0 1) arg-v-redundant-433) (type (unsigned-byte 32) arg-v-lit-434) (type (unsigned-byte 32) arg-v-blocking-435) (type c-address arg-v-c-436))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-432 0) (v-redundant-433 0) (v-lit-434 0) (v-blocking-435 0) (v-c-436 0) (v-watches-437 0) (v-watch-438 (stack-alloc 8)) (v-old_size-450 0) (v-old_capacity-451 0) (v-new_capacity-452 0) (v-new_bytes-453 0) (v-old_size-466 0) (v-old_capacity-467 0) (v-new_capacity-468 0) (v-new_bytes-469 0))
 (declare (type c-address v-solver-432) (type (integer 0 1) v-redundant-433) (type (unsigned-byte 32) v-lit-434) (type (unsigned-byte 32) v-blocking-435) (type c-address v-c-436) (type c-address v-watches-437) (type c-address v-watch-438) (type c-size v-old_size-450) (type c-size v-old_capacity-451) (type c-size v-new_capacity-452) (type c-size v-new_bytes-453) (type c-size v-old_size-466) (type c-size v-old_capacity-467) (type c-size v-new_capacity-468) (type c-size v-new_bytes-469) (ignorable v-solver-432 v-redundant-433 v-lit-434 v-blocking-435 v-c-436 v-watches-437 v-watch-438 v-old_size-450 v-old_capacity-451 v-new_capacity-452 v-new_bytes-453 v-old_size-466 v-old_capacity-467 v-new_capacity-468 v-new_bytes-469))
 (tagbody
    (setf v-solver-432 arg-v-solver-432)
    (setf v-redundant-433 arg-v-redundant-433)
    (setf v-lit-434 arg-v-lit-434)
    (setf v-blocking-435 arg-v-blocking-435)
    (setf v-c-436 arg-v-c-436)
    (setf v-watches-437 (+ (m-ptr (+ v-solver-432 544)) (* 24 v-lit-434)))
    (progn (setf (m-u8 (+ (+ v-watch-438 0) 0)) (c-bool (if (= (m-u32 (+ v-c-436 12)) (c-u32 2)) 1 0))))
    (progn (setf (m-u8 (+ (+ v-watch-438 0) 1)) (c-bool v-redundant-433)))
    (progn (setf (m-u32 (+ (+ v-watch-438 0) 4)) v-blocking-435))
    (progn v-solver-432)
    (unless (c-true (if (= (m-ptr (+ v-watches-437 8)) (m-ptr (+ v-watches-437 16))) 1 0)) (go ELSE445))
    (setf v-old_size-450 (the c-size (truncate (- (m-ptr (+ v-watches-437 8)) (m-ptr (+ v-watches-437 0))) 8)))
    (setf v-old_capacity-451 (the c-size (truncate (- (m-ptr (+ v-watches-437 16)) (m-ptr (+ v-watches-437 0))) 8)))
    (setf v-new_capacity-452 (if (c-true v-old_capacity-451) (c-u64 (* (c-u64 2) v-old_capacity-451)) (c-u64 1)))
    (setf v-new_bytes-453 (c-u64 (* v-new_capacity-452 8)))
    (progn (setf (m-ptr (+ v-watches-437 0)) (c-realloc (m-ptr (+ v-watches-437 0)) v-new_bytes-453)))
    (unless (c-true (if (c-true (m-ptr (+ v-watches-437 0))) 0 1)) (go ELSE454))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-453))
    (go ENDIF455)
    ELSE454
    ENDIF455
    (progn (setf (m-ptr (+ v-watches-437 8)) (+ (m-ptr (+ v-watches-437 0)) (* 8 v-old_size-450))))
    (progn (setf (m-ptr (+ v-watches-437 16)) (+ (m-ptr (+ v-watches-437 0)) (* 8 v-new_capacity-452))))
    (go ENDIF446)
    ELSE445
    ENDIF446
    (progn (copy-bytes (let* ((a456 (+ v-watches-437 8)) (old457 (m-ptr a456))) (setf (m-ptr a456) (+ old457 (* 8 1))) old457) v-watch-438 8))
    (progn (setf (m-ptr (+ v-watch-438 0)) v-c-436))
    (unless (c-true (if (= (m-ptr (+ v-watches-437 8)) (m-ptr (+ v-watches-437 16))) 1 0)) (go ELSE461))
    (setf v-old_size-466 (the c-size (truncate (- (m-ptr (+ v-watches-437 8)) (m-ptr (+ v-watches-437 0))) 8)))
    (setf v-old_capacity-467 (the c-size (truncate (- (m-ptr (+ v-watches-437 16)) (m-ptr (+ v-watches-437 0))) 8)))
    (setf v-new_capacity-468 (if (c-true v-old_capacity-467) (c-u64 (* (c-u64 2) v-old_capacity-467)) (c-u64 1)))
    (setf v-new_bytes-469 (c-u64 (* v-new_capacity-468 8)))
    (progn (setf (m-ptr (+ v-watches-437 0)) (c-realloc (m-ptr (+ v-watches-437 0)) v-new_bytes-469)))
    (unless (c-true (if (c-true (m-ptr (+ v-watches-437 0))) 0 1)) (go ELSE470))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-469))
    (go ENDIF471)
    ELSE470
    ENDIF471
    (progn (setf (m-ptr (+ v-watches-437 8)) (+ (m-ptr (+ v-watches-437 0)) (* 8 v-old_size-466))))
    (progn (setf (m-ptr (+ v-watches-437 16)) (+ (m-ptr (+ v-watches-437 0)) (* 8 v-new_capacity-468))))
    (go ENDIF462)
    ELSE461
    ENDIF462
    (progn (copy-bytes (let* ((a472 (+ v-watches-437 8)) (old473 (m-ptr a472))) (setf (m-ptr a472) (+ old473 (* 8 1))) old473) v-watch-438 8))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:2393:1
(defun |c/unwatch_literal| (arg-v-solver-474 arg-v-lit-475 arg-v-c-476)
 (declare  (type c-address arg-v-solver-474) (type (unsigned-byte 32) arg-v-lit-475) (type c-address arg-v-c-476))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-474 0) (v-lit-475 0) (v-c-476 0) (v-watches-477 0) (v-end-478 0) (v-q-479 0) (v-watch-483 (stack-alloc 8)) (v-header-486 (stack-alloc 8)) (v-d-489 0))
 (declare (type c-address v-solver-474) (type (unsigned-byte 32) v-lit-475) (type c-address v-c-476) (type c-address v-watches-477) (type c-address v-end-478) (type c-address v-q-479) (type c-address v-watch-483) (type c-address v-header-486) (type c-address v-d-489) (ignorable v-solver-474 v-lit-475 v-c-476 v-watches-477 v-end-478 v-q-479 v-watch-483 v-header-486 v-d-489))
 (tagbody
    (setf v-solver-474 arg-v-solver-474)
    (setf v-lit-475 arg-v-lit-475)
    (setf v-c-476 arg-v-c-476)
    (setf v-watches-477 (+ (m-ptr (+ v-solver-474 544)) (* 24 v-lit-475)))
    (setf v-end-478 (m-ptr (+ v-watches-477 8)))
    (setf v-q-479 (m-ptr (+ v-watches-477 0)))
    LOOP480
    (copy-bytes v-watch-483 (let* ( (old485 v-q-479)) (setf v-q-479 (+ old485 (* 8 1))) old485) 8)
    (copy-bytes v-header-486 (+ v-watch-483 0) 8)
    (unless (c-true (m-u8 (+ v-header-486 0))) (go ELSE487))
    (go CONTINUE482)
    ELSE487
    (setf v-d-489 (m-ptr (+ (let* ( (old491 v-q-479)) (setf v-q-479 (+ old491 (* 8 1))) old491) 0)))
    (unless (c-true (if (= v-c-476 v-d-489) 1 0)) (go ELSE492))
    (progn v-solver-474)
    (go ENDLOOP481)
    ELSE492
    CONTINUE482
    (go LOOP480)
    ENDLOOP481
    LOOP497
    (unless (c-true (if (/= v-q-479 v-end-478) 1 0)) (go ENDLOOP498))
    (progn (progn (copy-bytes (+ v-q-479 (* 8 (c-s32 (- 2)))) v-q-479 8) (let* ( (old501 v-q-479)) (setf v-q-479 (+ old501 (* 8 1))) old501)))
    (go LOOP497)
    ENDLOOP498
    (progn (let ((a502 (+ v-watches-477 8))) (setf (m-ptr a502) (- (m-ptr a502) (* 8 2)))))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:2456:1
(defun |c/watch_clause| (arg-v-solver-503 arg-v-c-504)
 (declare  (type c-address arg-v-solver-503) (type c-address arg-v-c-504))
 (let ((v-solver-503 0) (v-c-504 0) (v-lit-505 0) (v-other-506 0) (v-redundant-507 0))
 (declare (type c-address v-solver-503) (type c-address v-c-504) (type (unsigned-byte 32) v-lit-505) (type (unsigned-byte 32) v-other-506) (type (integer 0 1) v-redundant-507) (ignorable v-solver-503 v-c-504 v-lit-505 v-other-506 v-redundant-507))
 (tagbody
    (setf v-solver-503 arg-v-solver-503)
    (setf v-c-504 arg-v-c-504)
    (setf v-lit-505 (m-u32 (+ (+ v-c-504 16) (* 4 0))))
    (setf v-other-506 (m-u32 (+ (+ v-c-504 16) (* 4 1))))
    (setf v-redundant-507 (c-bool (ldb (byte 1 2) (m-u8 (+ v-c-504 0)))))
    (progn (|c/watch_literal| v-solver-503 (c-bool v-redundant-507) v-lit-505 v-other-506 v-c-504))
    (progn (|c/watch_literal| v-solver-503 (c-bool v-redundant-507) v-other-506 v-lit-505 v-c-504))
  )
  0))

;;; upstream/satch.c:2483:1
(defun |c/init_binary| (arg-v-solver-508)
 (declare  (type c-address arg-v-solver-508))
 (let ((v-solver-508 0) (v-i-512 0) (v-binary-513 0))
 (declare (type c-address v-solver-508) (type (unsigned-byte 32) v-i-512) (type c-address v-binary-513) (ignorable v-solver-508 v-i-512 v-binary-513))
 (tagbody
    (setf v-solver-508 arg-v-solver-508)
    (setf v-i-512 (c-u32 0))
    LOOP509
    (unless (c-true (if (< v-i-512 (c-u32 2)) 1 0)) (go ENDLOOP510))
    (setf v-binary-513 (+ (+ v-solver-508 424) (* 24 v-i-512)))
    (progn (setf (m-u32 (+ v-binary-513 12)) (c-u32 2)))
    (let* ( (old515 v-i-512)) (setf v-i-512 (c-u32 (c-u32 (+ old515 (c-u32 1))))) old515)
    (go LOOP509)
    ENDLOOP510
  )
  0))

;;; upstream/satch.c:2498:1
(defun |c/release_binary| (arg-v-solver-516)
 (declare  (type c-address arg-v-solver-516))
 (let ((v-solver-516 0))
 (declare (type c-address v-solver-516) (ignorable v-solver-516))
 (tagbody
    (setf v-solver-516 arg-v-solver-516)
    (progn v-solver-516)
  )
  0))

;;; upstream/satch.c:2514:1
(defun |c/binary_clause| (arg-v-solver-517 arg-v-pos-518 arg-v-redundant-519 arg-v-lit-520 arg-v-other-521)
 (declare  (type c-address arg-v-solver-517) (type (unsigned-byte 32) arg-v-pos-518) (type (integer 0 1) arg-v-redundant-519) (type (unsigned-byte 32) arg-v-lit-520) (type (unsigned-byte 32) arg-v-other-521))
 (let ((v-solver-517 0) (v-pos-518 0) (v-redundant-519 0) (v-lit-520 0) (v-other-521 0) (v-res-522 0))
 (declare (type c-address v-solver-517) (type (unsigned-byte 32) v-pos-518) (type (integer 0 1) v-redundant-519) (type (unsigned-byte 32) v-lit-520) (type (unsigned-byte 32) v-other-521) (type c-address v-res-522) (ignorable v-solver-517 v-pos-518 v-redundant-519 v-lit-520 v-other-521 v-res-522))
 (tagbody
    (setf v-solver-517 arg-v-solver-517)
    (setf v-pos-518 arg-v-pos-518)
    (setf v-redundant-519 arg-v-redundant-519)
    (setf v-lit-520 arg-v-lit-520)
    (setf v-other-521 arg-v-other-521)
    (setf v-res-522 (+ (+ v-solver-517 424) (* 24 v-pos-518)))
    (progn (set-bits (+ v-res-522 0) 2 1 (c-bool v-redundant-519)))
    (progn (setf (m-u32 (+ (+ v-res-522 16) (* 4 0))) v-lit-520))
    (progn (setf (m-u32 (+ (+ v-res-522 16) (* 4 1))) v-other-521))
    (return-from |c/binary_clause| v-res-522)
  )
  0))

;;; upstream/satch.c:2552:1
(defun |c/is_tagged_clause| (arg-v-c-523)
 (declare  (type c-address arg-v-c-523))
 (let ((v-c-523 0) (v-word-524 0))
 (declare (type c-address v-c-523) (type (unsigned-byte 64) v-word-524) (ignorable v-c-523 v-word-524))
 (tagbody
    (setf v-c-523 arg-v-c-523)
    (locally (declare (optimize (speed 1))) (setf v-word-524 (c-u64 v-c-523)))
    (return-from |c/is_tagged_clause| (c-bool (if (c-true (if (c-true (c-u64 (logand v-word-524 (c-u64 3)))) 0 1)) 0 1)))
  )
  0))

;;; upstream/satch.c:2559:1
(defun |c/tag_binary_clause| (arg-v-redundant-525 arg-v-other-526)
 (declare  (type (integer 0 1) arg-v-redundant-525) (type (unsigned-byte 64) arg-v-other-526))
 (let ((v-redundant-525 0) (v-other-526 0) (v-tmp-527 0) (v-res-528 0))
 (declare (type (integer 0 1) v-redundant-525) (type (unsigned-byte 64) v-other-526) (type (unsigned-byte 64) v-tmp-527) (type c-address v-res-528) (ignorable v-redundant-525 v-other-526 v-tmp-527 v-res-528))
 (tagbody
    (setf v-redundant-525 arg-v-redundant-525)
    (setf v-other-526 arg-v-other-526)
    (locally (declare (optimize (speed 1))) (setf v-tmp-527 (c-u64 (logior (c-u64 (logior (c-u64 (ash (c-u64 v-other-526) 2)) (c-u64 1))) (c-u64 (c-s32 (ash (c-s32 v-redundant-525) 1)))))))
    (setf v-res-528 v-tmp-527)
    (return-from |c/tag_binary_clause| v-res-528)
  )
  0))

;;; upstream/satch.c:2568:1
(defun |c/tagged_clause_to_literal| (arg-v-c-529)
 (declare  (type c-address arg-v-c-529))
 (let ((v-c-529 0) (v-tmp-530 0) (v-res-531 0))
 (declare (type c-address v-c-529) (type (unsigned-byte 64) v-tmp-530) (type (unsigned-byte 32) v-res-531) (ignorable v-c-529 v-tmp-530 v-res-531))
 (tagbody
    (setf v-c-529 arg-v-c-529)
    (locally (declare (optimize (speed 1))) (setf v-tmp-530 (c-u64 v-c-529)))
    (setf v-res-531 (c-u32 (c-u64 (ash (c-u64 v-tmp-530) (- 2)))))
    (return-from |c/tagged_clause_to_literal| v-res-531)
  )
  0))

;;; upstream/satch.c:2577:1
(defun |c/tagged_clause_to_redundant| (arg-v-c-532)
 (declare  (type c-address arg-v-c-532))
 (let ((v-c-532 0) (v-tmp-533 0) (v-res-534 0))
 (declare (type c-address v-c-532) (type (unsigned-byte 64) v-tmp-533) (type (integer 0 1) v-res-534) (ignorable v-c-532 v-tmp-533 v-res-534))
 (tagbody
    (setf v-c-532 arg-v-c-532)
    (locally (declare (optimize (speed 1))) (setf v-tmp-533 (c-u64 v-c-532)))
    (setf v-res-534 (c-bool (if (c-true (if (c-true (c-u64 (logand v-tmp-533 (c-u64 2)))) 0 1)) 0 1)))
    (return-from |c/tagged_clause_to_redundant| v-res-534)
  )
  0))

;;; upstream/satch.c:2606:1
(defun |c/untag_clause| (arg-v-solver-535 arg-v-pos-536 arg-v-lit-537 arg-v-c-538)
 (declare  (type c-address arg-v-solver-535) (type (unsigned-byte 32) arg-v-pos-536) (type (unsigned-byte 32) arg-v-lit-537) (type c-address arg-v-c-538))
 (let ((v-solver-535 0) (v-pos-536 0) (v-lit-537 0) (v-c-538 0) (v-other-539 0) (v-redundant-540 0))
 (declare (type c-address v-solver-535) (type (unsigned-byte 32) v-pos-536) (type (unsigned-byte 32) v-lit-537) (type c-address v-c-538) (type (unsigned-byte 32) v-other-539) (type (integer 0 1) v-redundant-540) (ignorable v-solver-535 v-pos-536 v-lit-537 v-c-538 v-other-539 v-redundant-540))
 (tagbody
    (setf v-solver-535 arg-v-solver-535)
    (setf v-pos-536 arg-v-pos-536)
    (setf v-lit-537 arg-v-lit-537)
    (setf v-c-538 arg-v-c-538)
    (setf v-other-539 (|c/tagged_clause_to_literal| v-c-538))
    (setf v-redundant-540 (c-bool (|c/tagged_clause_to_redundant| v-c-538)))
    (return-from |c/untag_clause| (|c/binary_clause| v-solver-535 v-pos-536 (c-bool v-redundant-540) v-lit-537 v-other-539))
  )
  0))

;;; upstream/satch.c:2708:1
(defun |c/bubble_up| (arg-v-solver-541 arg-v-heap-542 arg-v-idx-543)
 (declare  (type c-address arg-v-solver-541) (type c-address arg-v-heap-542) (type (unsigned-byte 32) arg-v-idx-543))
 (let ((v-solver-541 0) (v-heap-542 0) (v-idx-543 0) (v-stack-544 0) (v-pos-545 0) (v-idx_pos-546 0) (v-score-547 0) (v-idx_score-548 0d0) (v-parent_pos-552 0) (v-parent-553 0) (v-parent_score-554 0d0))
 (declare (type c-address v-solver-541) (type c-address v-heap-542) (type (unsigned-byte 32) v-idx-543) (type c-address v-stack-544) (type c-address v-pos-545) (type (unsigned-byte 32) v-idx_pos-546) (type c-address v-score-547) (type double-float v-idx_score-548) (type (unsigned-byte 32) v-parent_pos-552) (type (unsigned-byte 32) v-parent-553) (type double-float v-parent_score-554) (ignorable v-solver-541 v-heap-542 v-idx-543 v-stack-544 v-pos-545 v-idx_pos-546 v-score-547 v-idx_score-548 v-parent_pos-552 v-parent-553 v-parent_score-554))
 (tagbody
    (setf v-solver-541 arg-v-solver-541)
    (setf v-heap-542 arg-v-heap-542)
    (setf v-idx-543 arg-v-idx-543)
    (setf v-stack-544 (m-ptr (+ v-heap-542 0)))
    (setf v-pos-545 (m-ptr (+ v-heap-542 16)))
    (setf v-idx_pos-546 (m-u32 (+ v-pos-545 (* 4 v-idx-543))))
    (setf v-score-547 (m-ptr (+ v-heap-542 24)))
    (setf v-idx_score-548 (m-f64 (+ v-score-547 (* 8 v-idx-543))))
    LOOP549
    (unless (c-true v-idx_pos-546) (go ENDLOOP550))
    (setf v-parent_pos-552 (c-u32 (truncate (c-u32 (- v-idx_pos-546 (c-u32 1))) (c-u32 2))))
    (setf v-parent-553 (m-u32 (+ v-stack-544 (* 4 v-parent_pos-552))))
    (setf v-parent_score-554 (m-f64 (+ v-score-547 (* 8 v-parent-553))))
    (unless (c-true (if (>= v-parent_score-554 v-idx_score-548) 1 0)) (go ELSE555))
    (go ENDLOOP550)
    ELSE555
    (progn v-solver-541)
    (progn (setf (m-u32 (+ v-stack-544 (* 4 v-idx_pos-546))) v-parent-553))
    (progn (setf (m-u32 (+ v-pos-545 (* 4 v-parent-553))) v-idx_pos-546))
    (progn (setf v-idx_pos-546 v-parent_pos-552))
    (go LOOP549)
    ENDLOOP550
    (progn (setf (m-u32 (+ v-stack-544 (* 4 v-idx_pos-546))) v-idx-543))
    (progn (setf (m-u32 (+ v-pos-545 (* 4 v-idx-543))) v-idx_pos-546))
    (progn v-solver-541)
  )
  0))

;;; upstream/satch.c:2737:1
(defun |c/bubble_down| (arg-v-solver-566 arg-v-heap-567 arg-v-idx-568)
 (declare  (type c-address arg-v-solver-566) (type c-address arg-v-heap-567) (type (unsigned-byte 32) arg-v-idx-568))
 (let ((v-solver-566 0) (v-heap-567 0) (v-idx-568 0) (v-score-569 0) (v-begin-570 0) (v-pos-571 0) (v-size-572 0) (v-idx_score-573 0d0) (v-idx_pos-574 0) (v-child_pos-578 0) (v-child-581 0) (v-child_score-582 0d0) (v-sibling_pos-583 0) (v-sibling-586 0) (v-sibling_score-587 0d0))
 (declare (type c-address v-solver-566) (type c-address v-heap-567) (type (unsigned-byte 32) v-idx-568) (type c-address v-score-569) (type c-address v-begin-570) (type c-address v-pos-571) (type (unsigned-byte 32) v-size-572) (type double-float v-idx_score-573) (type (unsigned-byte 32) v-idx_pos-574) (type (unsigned-byte 32) v-child_pos-578) (type (unsigned-byte 32) v-child-581) (type double-float v-child_score-582) (type (unsigned-byte 32) v-sibling_pos-583) (type (unsigned-byte 32) v-sibling-586) (type double-float v-sibling_score-587) (ignorable v-solver-566 v-heap-567 v-idx-568 v-score-569 v-begin-570 v-pos-571 v-size-572 v-idx_score-573 v-idx_pos-574 v-child_pos-578 v-child-581 v-child_score-582 v-sibling_pos-583 v-sibling-586 v-sibling_score-587))
 (tagbody
    (setf v-solver-566 arg-v-solver-566)
    (setf v-heap-567 arg-v-heap-567)
    (setf v-idx-568 arg-v-idx-568)
    (setf v-score-569 (m-ptr (+ v-heap-567 24)))
    (setf v-begin-570 (m-ptr (+ v-heap-567 0)))
    (setf v-pos-571 (m-ptr (+ v-heap-567 16)))
    (setf v-size-572 (c-u32 (the c-size (truncate (- (m-ptr (+ v-heap-567 8)) (m-ptr (+ v-heap-567 0))) 4))))
    (setf v-idx_score-573 (m-f64 (+ v-score-569 (* 8 v-idx-568))))
    (setf v-idx_pos-574 (m-u32 (+ v-pos-571 (* 4 v-idx-568))))
    LOOP575
    (setf v-child_pos-578 (c-u32 (+ (c-u32 (* (c-u32 2) v-idx_pos-574)) (c-u32 1))))
    (unless (c-true (if (>= v-child_pos-578 v-size-572) 1 0)) (go ELSE579))
    (go ENDLOOP576)
    ELSE579
    (setf v-child-581 (m-u32 (+ v-begin-570 (* 4 v-child_pos-578))))
    (setf v-child_score-582 (m-f64 (+ v-score-569 (* 8 v-child-581))))
    (setf v-sibling_pos-583 (c-u32 (+ v-child_pos-578 (c-u32 1))))
    (unless (c-true (if (< v-sibling_pos-583 v-size-572) 1 0)) (go ELSE584))
    (setf v-sibling-586 (m-u32 (+ v-begin-570 (* 4 v-sibling_pos-583))))
    (setf v-sibling_score-587 (m-f64 (+ v-score-569 (* 8 v-sibling-586))))
    (unless (c-true (if (> v-sibling_score-587 v-child_score-582) 1 0)) (go ELSE588))
    (progn (setf v-child-581 v-sibling-586))
    (progn (setf v-child_pos-578 v-sibling_pos-583))
    (progn (setf v-child_score-582 v-sibling_score-587))
    (go ENDIF589)
    ELSE588
    ENDIF589
    (go ENDIF585)
    ELSE584
    ENDIF585
    (unless (c-true (if (<= v-child_score-582 v-idx_score-573) 1 0)) (go ELSE590))
    (go ENDLOOP576)
    ELSE590
    (progn v-solver-566)
    (progn (setf (m-u32 (+ v-begin-570 (* 4 v-idx_pos-574))) v-child-581))
    (progn (setf (m-u32 (+ v-pos-571 (* 4 v-child-581))) v-idx_pos-574))
    (progn (setf v-idx_pos-574 v-child_pos-578))
    (go LOOP575)
    ENDLOOP576
    (progn (setf (m-u32 (+ v-begin-570 (* 4 v-idx_pos-574))) v-idx-568))
    (progn (setf (m-u32 (+ v-pos-571 (* 4 v-idx-568))) v-idx_pos-574))
    (progn v-solver-566)
  )
  0))

;;; upstream/satch.c:2788:1
(defun |c/push_heap| (arg-v-solver-601 arg-v-heap-602 arg-v-idx-603)
 (declare  (type c-address arg-v-solver-601) (type c-address arg-v-heap-602) (type (unsigned-byte 32) arg-v-idx-603))
 (let ((v-solver-601 0) (v-heap-602 0) (v-idx-603 0) (v-size-604 0) (v-pos-605 0))
 (declare (type c-address v-solver-601) (type c-address v-heap-602) (type (unsigned-byte 32) v-idx-603) (type (unsigned-byte 32) v-size-604) (type c-address v-pos-605) (ignorable v-solver-601 v-heap-602 v-idx-603 v-size-604 v-pos-605))
 (tagbody
    (setf v-solver-601 arg-v-solver-601)
    (setf v-heap-602 arg-v-heap-602)
    (setf v-idx-603 arg-v-idx-603)
    (setf v-size-604 (c-u32 (the c-size (truncate (- (m-ptr (+ v-heap-602 8)) (m-ptr (+ v-heap-602 0))) 4))))
    (setf v-pos-605 (m-ptr (+ v-heap-602 16)))
    (progn (setf (m-u32 (+ v-pos-605 (* 4 v-idx-603))) v-size-604))
    (progn (setf (m-u32 (let* ((a606 (+ v-heap-602 8)) (old607 (m-ptr a606))) (setf (m-ptr a606) (+ old607 (* 4 1))) old607)) v-idx-603))
    (progn v-solver-601)
    (progn (|c/bubble_up| v-solver-601 v-heap-602 v-idx-603))
  )
  0))

;;; upstream/satch.c:2801:1
(defun |c/max_heap| (arg-v-heap-611)
 (declare  (type c-address arg-v-heap-611))
 (let ((v-heap-611 0))
 (declare (type c-address v-heap-611) (ignorable v-heap-611))
 (tagbody
    (setf v-heap-611 arg-v-heap-611)
    (return-from |c/max_heap| (m-u32 (+ (m-ptr (+ v-heap-611 0)) (* 4 (progn 0 0)))))
  )
  0))

;;; upstream/satch.c:2807:1
(defun |c/pop_heap| (arg-v-solver-612 arg-v-heap-613)
 (declare  (type c-address arg-v-solver-612) (type c-address arg-v-heap-613))
 (let ((v-solver-612 0) (v-heap-613 0) (v-res-617 0) (v-pos-621 0) (v-last-622 0))
 (declare (type c-address v-solver-612) (type c-address v-heap-613) (type (unsigned-byte 32) v-res-617) (type c-address v-pos-621) (type (unsigned-byte 32) v-last-622) (ignorable v-solver-612 v-heap-613 v-res-617 v-pos-621 v-last-622))
 (tagbody
    (setf v-solver-612 arg-v-solver-612)
    (setf v-heap-613 arg-v-heap-613)
    (setf v-res-617 (|c/max_heap| v-heap-613))
    (progn v-solver-612)
    (setf v-pos-621 (m-ptr (+ v-heap-613 16)))
    (progn (setf (m-u32 (+ v-pos-621 (* 4 v-res-617))) 4294967295))
    (setf v-last-622 (progn 0 (m-u32 (let* ((a623 (+ v-heap-613 8)) (old624 (m-ptr a623))) (setf (m-ptr a623) (- old624 (* 4 1))) (m-ptr a623)))))
    (unless (c-true (if (= v-last-622 v-res-617) 1 0)) (go ELSE625))
    (return-from |c/pop_heap| v-res-617)
    ELSE625
    (progn (setf (m-u32 (+ v-pos-621 (* 4 v-last-622))) (c-u32 0)))
    (progn (setf (m-u32 (+ (m-ptr (+ v-heap-613 0)) (* 4 0))) v-last-622))
    (progn (|c/bubble_down| v-solver-612 v-heap-613 v-last-622))
    (return-from |c/pop_heap| v-res-617)
  )
  0))

;;; upstream/satch.c:2827:1
(defun |c/update_heap| (arg-v-solver-627 arg-v-heap-628 arg-v-idx-629 arg-v-new_score-630)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-solver-627) (type c-address arg-v-heap-628) (type (unsigned-byte 32) arg-v-idx-629) (type double-float arg-v-new_score-630))
 (let ((v-solver-627 0) (v-heap-628 0) (v-idx-629 0) (v-new_score-630 0d0) (v-score-634 0) (v-old_score-635 0d0))
 (declare (type c-address v-solver-627) (type c-address v-heap-628) (type (unsigned-byte 32) v-idx-629) (type double-float v-new_score-630) (type c-address v-score-634) (type double-float v-old_score-635) (ignorable v-solver-627 v-heap-628 v-idx-629 v-new_score-630 v-score-634 v-old_score-635))
 (tagbody
    (setf v-solver-627 arg-v-solver-627)
    (setf v-heap-628 arg-v-heap-628)
    (setf v-idx-629 arg-v-idx-629)
    (setf v-new_score-630 arg-v-new_score-630)
    (setf v-score-634 (m-ptr (+ v-heap-628 24)))
    (setf v-old_score-635 (m-f64 (+ v-score-634 (* 8 v-idx-629))))
    (unless (c-true (if (< v-old_score-635 v-new_score-630) 1 0)) (go ELSE636))
    (progn (setf (m-f64 (+ v-score-634 (* 8 v-idx-629))) v-new_score-630))
    (unless (c-true (if (/= (m-u32 (+ (m-ptr (+ v-heap-628 16)) (* 4 v-idx-629))) 4294967295) 1 0)) (go ELSE638))
    (progn (|c/bubble_up| v-solver-627 v-heap-628 v-idx-629))
    (go ENDIF639)
    ELSE638
    ENDIF639
    (go ENDIF637)
    ELSE636
    (unless (c-true (if (> v-old_score-635 v-new_score-630) 1 0)) (go ELSE640))
    (unless (c-true (if (/= (m-u32 (+ (m-ptr (+ v-heap-628 16)) (* 4 v-idx-629))) 4294967295) 1 0)) (go ELSE642))
    (progn (|c/bubble_down| v-solver-627 v-heap-628 v-idx-629))
    (go ENDIF643)
    ELSE642
    ENDIF643
    (go ENDIF641)
    ELSE640
    ENDIF641
    ENDIF637
  )
  0))

