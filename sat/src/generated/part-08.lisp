(in-package #:ooparts/sat/impl)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))
;;; upstream/satch.c:7089:1
(defun |c/reuse_scored_trail| (arg-v-solver-3438)
 (declare  (type c-address arg-v-solver-3438))
 (let ((v-solver-3438 0))
 (declare (type c-address v-solver-3438) (ignorable v-solver-3438))
 (tagbody
    (setf v-solver-3438 arg-v-solver-3438)
    (return-from |c/reuse_scored_trail| (|c/reuse_scored_trail_from| v-solver-3438 (c-u32 1)))
  )
  0))

;;; upstream/satch.c:7118:1
(defun |c/reuse_trail| (arg-v-solver-3439)
 (declare  (type c-address arg-v-solver-3439))
 (let ((v-solver-3439 0) (v-res-3440 0))
 (declare (type c-address v-solver-3439) (type (unsigned-byte 32) v-res-3440) (ignorable v-solver-3439 v-res-3440))
 (tagbody
    (setf v-solver-3439 arg-v-solver-3439)
    (unless (c-true (m-u8 (+ v-solver-3439 6))) (go ELSE3441))
    (progn (setf v-res-3440 (|c/reuse_scored_trail| v-solver-3439)))
    (go ENDIF3442)
    ELSE3441
    (progn (setf v-res-3440 (|c/reuse_stamped_trail| v-solver-3439)))
    ENDIF3442
    (unless (c-true v-res-3440) (go ELSE3443))
    (progn (when (>= (m-u32 (+ v-solver-3439 884)) (c-u32 4)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-3439 (c-u32 4) |c/string/131| (m-u64 (+ (+ v-solver-3439 1016) 256)) |c/string/132| v-res-3440 (m-u32 (+ v-solver-3439 8)) (|c/percent| (float v-res-3440 1d0) (float (m-u32 (+ v-solver-3439 8)) 1d0))))))
    (progn (progn 0 (let* ((a3445 (+ (+ v-solver-3439 1016) 264)) (old3446 (m-u64 a3445))) (setf (m-u64 a3445) (c-u64 (c-u64 (+ old3446 (c-u64 1))))) (m-u64 a3445))))
    (go ENDIF3444)
    ELSE3443
    (progn v-solver-3439)
    ENDIF3444
    (return-from |c/reuse_trail| v-res-3440)
  )
  0))

;;; upstream/satch.c:7176:1
(defun |c/restarting| (arg-v-solver-3450)
 (declare  (type c-address arg-v-solver-3450))
 (let ((v-solver-3450 0) (v-a-3457 0) (v-fast-3458 0d0) (v-slow-3459 0d0) (v-limit-3460 0d0))
 (declare (type c-address v-solver-3450) (type c-address v-a-3457) (type double-float v-fast-3458) (type double-float v-slow-3459) (type double-float v-limit-3460) (ignorable v-solver-3450 v-a-3457 v-fast-3458 v-slow-3459 v-limit-3460))
 (tagbody
    (setf v-solver-3450 arg-v-solver-3450)
    (unless (c-true (if (c-true (m-u32 (+ v-solver-3450 8))) 0 1)) (go ELSE3451))
    (return-from |c/restarting| (c-bool 0))
    ELSE3451
    (unless (c-true (if (> (m-u64 (+ (+ v-solver-3450 720) 88)) (m-u64 (+ (+ v-solver-3450 1016) 48))) 1 0)) (go ELSE3453))
    (return-from |c/restarting| (c-bool 0))
    ELSE3453
    (unless (c-true (m-u8 (+ v-solver-3450 6))) (go ELSE3455))
    (return-from |c/restarting| (c-bool 1))
    ELSE3455
    (setf v-a-3457 (|c/averages| v-solver-3450))
    (setf v-fast-3458 (|c/unbiased_fast_average| v-a-3457 (m-f64 (+ v-a-3457 48))))
    (setf v-slow-3459 (|c/unbiased_slow_average| v-a-3457 (m-f64 (+ v-a-3457 8))))
    (setf v-limit-3460 (float (* 1.1d0 v-slow-3459) 1d0))
    (return-from |c/restarting| (c-bool (if (<= v-limit-3460 v-fast-3458) 1 0)))
  )
  0))

;;; upstream/satch.c:7207:1
(defun |c/restart| (arg-v-solver-3461)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-solver-3461))
 (let ((v-solver-3461 0) (v-restarts-3462 0) (v-new_level-3467 0) (v-interval-3470 0) (v-r-3473 0) (v-u-3474 0) (v-v-3475 0))
 (declare (type c-address v-solver-3461) (type (unsigned-byte 64) v-restarts-3462) (type (unsigned-byte 32) v-new_level-3467) (type (unsigned-byte 64) v-interval-3470) (type c-address v-r-3473) (type (unsigned-byte 64) v-u-3474) (type (unsigned-byte 64) v-v-3475) (ignorable v-solver-3461 v-restarts-3462 v-new_level-3467 v-interval-3470 v-r-3473 v-u-3474 v-v-3475))
 (tagbody
    (setf v-solver-3461 arg-v-solver-3461)
    (locally (declare (optimize (speed 1))) (setf v-restarts-3462 (progn 0 (let* ((a3463 (+ (+ v-solver-3461 1016) 256)) (old3464 (m-u64 a3463))) (setf (m-u64 a3463) (c-u64 (c-u64 (+ old3464 (c-u64 1))))) (m-u64 a3463)))))
    (progn (when (>= (m-u32 (+ v-solver-3461 884)) (c-u32 4)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-3461 (c-u32 4) |c/string/131| v-restarts-3462 |c/string/133| (m-u64 (+ (+ v-solver-3461 1016) 48)) (m-u64 (+ (+ v-solver-3461 720) 88))))))
    (progn (|c/report| v-solver-3461 (c-u32 3) 114))
    (unless (c-true (m-u8 (+ v-solver-3461 6))) (go ELSE3465))
    (progn (|c/update_phases| v-solver-3461))
    (go ENDIF3466)
    ELSE3465
    ENDIF3466
    (setf v-new_level-3467 (|c/reuse_trail| v-solver-3461))
    (unless (c-true (if (< v-new_level-3467 (m-u32 (+ v-solver-3461 8))) 1 0)) (go ELSE3468))
    (progn (|c/backtrack| v-solver-3461 v-new_level-3467))
    (go ENDIF3469)
    ELSE3468
    ENDIF3469
    (unless (c-true (m-u8 (+ v-solver-3461 6))) (go ELSE3471))
    (setf v-r-3473 (+ v-solver-3461 864))
    (locally (declare (optimize (speed 1))) (setf v-u-3474 (m-u64 (+ v-r-3473 0))))
    (locally (declare (optimize (speed 1))) (setf v-v-3475 (m-u64 (+ v-r-3473 8))))
    (progn (setf v-interval-3470 (c-u64 (* v-v-3475 (c-u64 1024)))))
    (unless (c-true (if (= (c-u64 (logand v-u-3474 (c-u64 (- v-u-3474)))) v-v-3475) 1 0)) (go ELSE3476))
    (progn (progn (let* ( (old3479 v-u-3474)) (setf v-u-3474 (c-u64 (c-u64 (+ old3479 (c-u64 1))))) old3479) (setf v-v-3475 (c-u64 1))))
    (go ENDIF3477)
    ELSE3476
    (progn (progn 0 (setf v-v-3475 (c-u64 (c-u64 (* v-v-3475 (c-u64 2)))))))
    ENDIF3477
    (progn (progn (setf (m-u64 (+ v-r-3473 0)) v-u-3474) (setf (m-u64 (+ v-r-3473 8)) v-v-3475)))
    (go ENDIF3472)
    ELSE3471
    (progn (setf v-interval-3470 (values (the (unsigned-byte 64) (truncate (float (+ (float (c-s32 (- 1 1)) 1d0) (|c/logn| v-restarts-3462)) 1d0))))))
    ENDIF3472
    (progn (setf (m-u64 (+ (+ v-solver-3461 720) 88)) (c-u64 (+ (m-u64 (+ (+ v-solver-3461 1016) 48)) v-interval-3470))))
    (progn (when (>= (m-u32 (+ v-solver-3461 884)) (c-u32 4)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-3461 (c-u32 4) |c/string/131| v-restarts-3462 |c/string/134| (if (c-true (m-u8 (+ v-solver-3461 6))) |c/string/21| |c/string/16|) (m-u64 (+ (+ v-solver-3461 720) 88)) v-interval-3470))))
  )
  0))

;;; upstream/satch.c:7295:1
(defun |c/rephasing| (arg-v-solver-3481)
 (declare  (type c-address arg-v-solver-3481))
 (let ((v-solver-3481 0))
 (declare (type c-address v-solver-3481) (ignorable v-solver-3481))
 (tagbody
    (setf v-solver-3481 arg-v-solver-3481)
    (unless (c-true (if (c-true (m-u8 (+ v-solver-3481 6))) 0 1)) (go ELSE3482))
    (return-from |c/rephasing| (c-bool 0))
    ELSE3482
    (return-from |c/rephasing| (c-bool (if (<= (m-u64 (+ (+ v-solver-3481 720) 80)) (m-u64 (+ (+ v-solver-3481 1016) 48))) 1 0)))
  )
  0))

;;; upstream/satch.c:7303:1
(defun |c/original_phases| (arg-v-solver-3484)
 (declare  (type c-address arg-v-solver-3484))
 (let ((v-solver-3484 0) (v-value-3485 0))
 (declare (type c-address v-solver-3484) (type (signed-byte 8) v-value-3485) (ignorable v-solver-3484 v-value-3485))
 (tagbody
    (setf v-solver-3484 arg-v-solver-3484)
    (setf v-value-3485 (c-s8 (|c/original_phase|)))
    (progn (c-memset (m-ptr (+ v-solver-3484 56)) v-value-3485 (m-u32 (+ v-solver-3484 12))))
    (return-from |c/original_phases| (c-s8 79))
  )
  0))

;;; upstream/satch.c:7313:1
(defun |c/inverted_phases| (arg-v-solver-3486)
 (declare  (type c-address arg-v-solver-3486))
 (let ((v-solver-3486 0) (v-value-3487 0))
 (declare (type c-address v-solver-3486) (type (signed-byte 8) v-value-3487) (ignorable v-solver-3486 v-value-3487))
 (tagbody
    (setf v-solver-3486 arg-v-solver-3486)
    (setf v-value-3487 (c-s8 (c-s32 (- (|c/original_phase|)))))
    (progn (c-memset (m-ptr (+ v-solver-3486 56)) v-value-3487 (m-u32 (+ v-solver-3486 12))))
    (return-from |c/inverted_phases| (c-s8 73))
  )
  0))

;;; upstream/satch.c:7325:1
(defun |c/best_phases| (arg-v-solver-3488)
 (declare  (type c-address arg-v-solver-3488))
 (let ((v-solver-3488 0) (v-bests-3489 0) (v-end-3490 0) (v-saved-3491 0) (v-q-3492 0) (v-tmp-3493 0) (v-p-3497 0))
 (declare (type c-address v-solver-3488) (type c-address v-bests-3489) (type c-address v-end-3490) (type c-address v-saved-3491) (type c-address v-q-3492) (type (signed-byte 8) v-tmp-3493) (type c-address v-p-3497) (ignorable v-solver-3488 v-bests-3489 v-end-3490 v-saved-3491 v-q-3492 v-tmp-3493 v-p-3497))
 (tagbody
    (setf v-solver-3488 arg-v-solver-3488)
    (setf v-bests-3489 (m-ptr (+ v-solver-3488 80)))
    (setf v-end-3490 (+ v-bests-3489 (* 1 (m-u32 (+ v-solver-3488 12)))))
    (setf v-saved-3491 (m-ptr (+ v-solver-3488 56)))
    (setf v-q-3492 v-saved-3491)
    (setf v-p-3497 v-bests-3489)
    LOOP3494
    (unless (c-true (if (/= v-p-3497 v-end-3490) 1 0)) (go ENDLOOP3495))
    (unless (c-true (setf v-tmp-3493 (m-s8 v-p-3497))) (go ELSE3498))
    (progn (setf (m-s8 v-q-3492) v-tmp-3493))
    (go ENDIF3499)
    ELSE3498
    ENDIF3499
    (progn (let* ( (old3501 v-p-3497)) (setf v-p-3497 (+ old3501 (* 1 1))) old3501) (let* ( (old3503 v-q-3492)) (setf v-q-3492 (+ old3503 (* 1 1))) old3503))
    (go LOOP3494)
    ENDLOOP3495
    (progn (setf (m-u32 (+ v-solver-3488 88)) (c-u32 0)))
    (return-from |c/best_phases| (c-s8 66))
  )
  0))

;;; upstream/satch.c:7341:1
(defun |c/rephase| (arg-v-solver-3504)
 (declare  (type c-address arg-v-solver-3504))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-3504 0) (v-functions-3505 (stack-alloc 32)) (v-size_functions-3506 0) (v-rephased-3515 0) (v-type-3518 0) (v-interval-3519 0))
 (declare (type c-address v-solver-3504) (type c-address v-functions-3505) (type (unsigned-byte 32) v-size_functions-3506) (type (unsigned-byte 64) v-rephased-3515) (type (signed-byte 8) v-type-3518) (type (unsigned-byte 64) v-interval-3519) (ignorable v-solver-3504 v-functions-3505 v-size_functions-3506 v-rephased-3515 v-type-3518 v-interval-3519))
 (tagbody
    (setf v-solver-3504 arg-v-solver-3504)
    (setf v-size_functions-3506 (c-u32 0))
    (progn (setf (m-ptr (+ v-functions-3505 (* 8 (let* ( (old3508 v-size_functions-3506)) (setf v-size_functions-3506 (c-u32 (c-u32 (+ old3508 (c-u32 1))))) old3508)))) (function-handle #'|c/inverted_phases|)))
    (progn (setf (m-ptr (+ v-functions-3505 (* 8 (let* ( (old3510 v-size_functions-3506)) (setf v-size_functions-3506 (c-u32 (c-u32 (+ old3510 (c-u32 1))))) old3510)))) (function-handle #'|c/best_phases|)))
    (progn (setf (m-ptr (+ v-functions-3505 (* 8 (let* ( (old3512 v-size_functions-3506)) (setf v-size_functions-3506 (c-u32 (c-u32 (+ old3512 (c-u32 1))))) old3512)))) (function-handle #'|c/original_phases|)))
    (progn (setf (m-ptr (+ v-functions-3505 (* 8 (let* ( (old3514 v-size_functions-3506)) (setf v-size_functions-3506 (c-u32 (c-u32 (+ old3514 (c-u32 1))))) old3514)))) (function-handle #'|c/best_phases|)))
    (locally (declare (optimize (speed 1))) (setf v-rephased-3515 (progn 0 (let* ((a3516 (+ (+ v-solver-3504 1016) 224)) (old3517 (m-u64 a3516))) (setf (m-u64 a3516) (c-u64 (c-u64 (+ old3517 (c-u64 1))))) (m-u64 a3516)))))
    (setf v-type-3518 (funcall (the (function (c-address) (values (signed-byte 8) &optional)) (function-from-handle (m-ptr (+ v-functions-3505 (* 8 (c-u64 (rem v-rephased-3515 v-size_functions-3506))))))) v-solver-3504))
    (locally (declare (optimize (speed 1))) (setf v-interval-3519 (values (the (unsigned-byte 64) (truncate (|c/scale_interval| (values (the (unsigned-byte 64) (truncate 1000.0d0))) (function-handle #'|c/nlognlognlogn|) v-rephased-3515))))))
    (progn (setf (m-u64 (+ (+ v-solver-3504 720) 80)) (c-u64 (+ (m-u64 (+ (+ v-solver-3504 1016) 48)) v-interval-3519))))
    (progn (when (>= (m-u32 (+ v-solver-3504 884)) (c-u32 4)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-3504 (c-u32 4) |c/string/135| v-rephased-3515 |c/string/136| (m-u64 (+ (+ v-solver-3504 720) 80)) v-interval-3519))))
    (unless (c-true (m-u8 (+ v-solver-3504 6))) (go ELSE3520))
    (progn v-solver-3504)
    (progn (c-memcpy (m-ptr (+ v-solver-3504 64)) (m-ptr (+ v-solver-3504 56)) (m-u32 (+ v-solver-3504 12))))
    (progn (setf (m-u32 (+ v-solver-3504 72)) (c-u32 0)))
    (go ENDIF3521)
    ELSE3520
    ENDIF3521
    (progn (|c/report| v-solver-3504 (c-u32 1) v-type-3518))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:7392:1
(defun |c/reducing| (arg-v-solver-3525)
 (declare  (type c-address arg-v-solver-3525))
 (let ((v-solver-3525 0))
 (declare (type c-address v-solver-3525) (ignorable v-solver-3525))
 (tagbody
    (setf v-solver-3525 arg-v-solver-3525)
    (return-from |c/reducing| (c-bool (if (<= (m-u64 (+ (+ (+ v-solver-3525 720) 64) 0)) (m-u64 (+ (+ v-solver-3525 1016) 48))) 1 0)))
  )
  0))

;;; upstream/satch.c:7404:1
(defun |c/set_protect_flag_of_reasons| (arg-v-solver-3526 arg-v-protect-3527)
 (declare  (type c-address arg-v-solver-3526) (type (integer 0 1) arg-v-protect-3527))
 (let ((v-solver-3526 0) (v-protect-3527 0) (v-reasons-3528 0) (v-lit-3532 0) (v-PTR_lit-3533 0) (v-END_lit-3534 0) (v-idx-3535 0) (v-reason-3536 0))
 (declare (type c-address v-solver-3526) (type (integer 0 1) v-protect-3527) (type c-address v-reasons-3528) (type (unsigned-byte 32) v-lit-3532) (type c-address v-PTR_lit-3533) (type c-address v-END_lit-3534) (type (unsigned-byte 32) v-idx-3535) (type c-address v-reason-3536) (ignorable v-solver-3526 v-protect-3527 v-reasons-3528 v-lit-3532 v-PTR_lit-3533 v-END_lit-3534 v-idx-3535 v-reason-3536))
 (tagbody
    (setf v-solver-3526 arg-v-solver-3526)
    (setf v-protect-3527 arg-v-protect-3527)
    (setf v-reasons-3528 (m-ptr (+ v-solver-3526 416)))
    (setf v-PTR_lit-3533 (m-ptr (+ (+ v-solver-3526 552) 0)))
    (setf v-END_lit-3534 (m-ptr (+ (+ v-solver-3526 552) 8)))
    LOOP3529
    (unless (c-true (if (c-true (if (/= v-PTR_lit-3533 v-END_lit-3534) 1 0)) (c-bool (progn (setf v-lit-3532 (m-u32 v-PTR_lit-3533)) 1)) 0)) (go ENDLOOP3530))
    (setf v-idx-3535 (|c/INDEX| v-lit-3532))
    (setf v-reason-3536 (m-ptr (+ v-reasons-3528 (* 8 v-idx-3535))))
    (unless (c-true (if (c-true v-reason-3536) 0 1)) (go ELSE3537))
    (go CONTINUE3531)
    ELSE3537
    (unless (c-true (|c/is_tagged_clause| v-reason-3536)) (go ELSE3539))
    (go CONTINUE3531)
    ELSE3539
    (progn v-solver-3526)
    (progn (set-bits (+ v-reason-3536 0) 1 1 (c-bool v-protect-3527)))
    CONTINUE3531
    (let* ( (old3545 v-PTR_lit-3533)) (setf v-PTR_lit-3533 (+ old3545 (* 4 1))) v-PTR_lit-3533)
    (go LOOP3529)
    ENDLOOP3530
  )
  0))

;;; upstream/satch.c:7433:1
(defun |c/clause_satisfied| (arg-v-solver-3546 arg-v-c-3547)
 (declare  (type c-address arg-v-solver-3546) (type c-address arg-v-c-3547))
 (let ((v-solver-3546 0) (v-c-3547 0) (v-values-3548 0) (v-num_false-3549 0) (v-lit-3553 0) (v-P_lit-3554 0) (v-END_lit-3555 0) (v-value-3556 0) (v-lit-3573 0) (v-P_lit-3574 0) (v-END_lit-3575 0) (v-old_size-3586 0) (v-old_capacity-3587 0) (v-new_capacity-3588 0) (v-new_bytes-3589 0) (v-lit-3599 0) (v-PTR_lit-3600 0) (v-END_lit-3601 0) (v-old_lits-3606 0) (v-new_lits-3607 0) (v-size-3608 0) (v-p-3614 0) (v-lit-3618 0) (v-PTR_lit-3619 0) (v-END_lit-3620 0))
 (declare (type c-address v-solver-3546) (type c-address v-c-3547) (type c-address v-values-3548) (type (unsigned-byte 32) v-num_false-3549) (type (unsigned-byte 32) v-lit-3553) (type c-address v-P_lit-3554) (type c-address v-END_lit-3555) (type (signed-byte 8) v-value-3556) (type (unsigned-byte 32) v-lit-3573) (type c-address v-P_lit-3574) (type c-address v-END_lit-3575) (type c-size v-old_size-3586) (type c-size v-old_capacity-3587) (type c-size v-new_capacity-3588) (type c-size v-new_bytes-3589) (type (unsigned-byte 32) v-lit-3599) (type c-address v-PTR_lit-3600) (type c-address v-END_lit-3601) (type c-address v-old_lits-3606) (type c-address v-new_lits-3607) (type c-size v-size-3608) (type c-address v-p-3614) (type (unsigned-byte 32) v-lit-3618) (type c-address v-PTR_lit-3619) (type c-address v-END_lit-3620) (ignorable v-solver-3546 v-c-3547 v-values-3548 v-num_false-3549 v-lit-3553 v-P_lit-3554 v-END_lit-3555 v-value-3556 v-lit-3573 v-P_lit-3574 v-END_lit-3575 v-old_size-3586 v-old_capacity-3587 v-new_capacity-3588 v-new_bytes-3589 v-lit-3599 v-PTR_lit-3600 v-END_lit-3601 v-old_lits-3606 v-new_lits-3607 v-size-3608 v-p-3614 v-lit-3618 v-PTR_lit-3619 v-END_lit-3620))
 (tagbody
    (setf v-solver-3546 arg-v-solver-3546)
    (setf v-c-3547 arg-v-c-3547)
    (setf v-values-3548 (m-ptr (+ v-solver-3546 40)))
    (setf v-num_false-3549 (c-u32 0))
    (setf v-P_lit-3554 (+ v-c-3547 16))
    (setf v-END_lit-3555 (+ v-P_lit-3554 (* 4 (m-u32 (+ v-c-3547 12)))))
    LOOP3550
    (unless (c-true (if (c-true (if (/= v-P_lit-3554 v-END_lit-3555) 1 0)) (c-bool (progn (setf v-lit-3553 (m-u32 v-P_lit-3554)) 1)) 0)) (go ENDLOOP3551))
    (setf v-value-3556 (m-s8 (+ v-values-3548 (* 1 v-lit-3553))))
    (unless (c-true (if (> v-value-3556 0) 1 0)) (go ELSE3557))
    (return-from |c/clause_satisfied| (c-bool 1))
    ELSE3557
    (unless (c-true (if (< v-value-3556 0) 1 0)) (go ELSE3559))
    (progn (let* ( (old3562 v-num_false-3549)) (setf v-num_false-3549 (c-u32 (c-u32 (+ old3562 (c-u32 1))))) old3562))
    (go ENDIF3560)
    ELSE3559
    ENDIF3560
    (let* ( (old3564 v-P_lit-3554)) (setf v-P_lit-3554 (+ old3564 (* 4 1))) v-P_lit-3554)
    (go LOOP3550)
    ENDLOOP3551
    (unless (c-true (if (c-true v-num_false-3549) 0 1)) (go ELSE3565))
    (return-from |c/clause_satisfied| (c-bool 0))
    ELSE3565
    (progn v-solver-3546)
    (setf v-P_lit-3574 (+ v-c-3547 16))
    (setf v-END_lit-3575 (+ v-P_lit-3574 (* 4 (m-u32 (+ v-c-3547 12)))))
    LOOP3570
    (unless (c-true (if (c-true (if (/= v-P_lit-3574 v-END_lit-3575) 1 0)) (c-bool (progn (setf v-lit-3573 (m-u32 v-P_lit-3574)) 1)) 0)) (go ENDLOOP3571))
    (unless (c-true (if (c-true (m-s8 (+ v-values-3548 (* 1 v-lit-3573)))) 0 1)) (go ELSE3576))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-3546 624) 8)) (m-ptr (+ (+ v-solver-3546 624) 16))) 1 0)) (go ELSE3581))
    (setf v-old_size-3586 (the c-size (truncate (- (m-ptr (+ (+ v-solver-3546 624) 8)) (m-ptr (+ (+ v-solver-3546 624) 0))) 4)))
    (setf v-old_capacity-3587 (the c-size (truncate (- (m-ptr (+ (+ v-solver-3546 624) 16)) (m-ptr (+ (+ v-solver-3546 624) 0))) 4)))
    (setf v-new_capacity-3588 (if (c-true v-old_capacity-3587) (c-u64 (* (c-u64 2) v-old_capacity-3587)) (c-u64 1)))
    (setf v-new_bytes-3589 (c-u64 (* v-new_capacity-3588 4)))
    (progn (setf (m-ptr (+ (+ v-solver-3546 624) 0)) (c-realloc (m-ptr (+ (+ v-solver-3546 624) 0)) v-new_bytes-3589)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-3546 624) 0))) 0 1)) (go ELSE3590))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-3589))
    (go ENDIF3591)
    ELSE3590
    ENDIF3591
    (progn (setf (m-ptr (+ (+ v-solver-3546 624) 8)) (+ (m-ptr (+ (+ v-solver-3546 624) 0)) (* 4 v-old_size-3586))))
    (progn (setf (m-ptr (+ (+ v-solver-3546 624) 16)) (+ (m-ptr (+ (+ v-solver-3546 624) 0)) (* 4 v-new_capacity-3588))))
    (go ENDIF3582)
    ELSE3581
    ENDIF3582
    (progn (setf (m-u32 (let* ((a3592 (+ (+ v-solver-3546 624) 8)) (old3593 (m-ptr a3592))) (setf (m-ptr a3592) (+ old3593 (* 4 1))) old3593)) v-lit-3573))
    (go ENDIF3577)
    ELSE3576
    ENDIF3577
    (let* ( (old3595 v-P_lit-3574)) (setf v-P_lit-3574 (+ old3595 (* 4 1))) v-P_lit-3574)
    (go LOOP3570)
    ENDLOOP3571
    (setf v-PTR_lit-3600 (m-ptr (+ (+ v-solver-3546 624) 0)))
    (setf v-END_lit-3601 (m-ptr (+ (+ v-solver-3546 624) 8)))
    LOOP3596
    (unless (c-true (if (c-true (if (/= v-PTR_lit-3600 v-END_lit-3601) 1 0)) (c-bool (progn (setf v-lit-3599 (m-u32 v-PTR_lit-3600)) 1)) 0)) (go ENDLOOP3597))
    (progn (|c/mark_subsume_literal| v-solver-3546 v-lit-3599))
    (let* ( (old3603 v-PTR_lit-3600)) (setf v-PTR_lit-3600 (+ old3603 (* 4 1))) v-PTR_lit-3600)
    (go LOOP3596)
    ENDLOOP3597
    (unless (c-true (if (c-true (m-u8 (+ v-solver-3546 7))) 0 1)) (go ELSE3604))
    (progn (|c/trace_and_check_temporary_addition| v-solver-3546))
    (progn (|c/trace_and_check_clause_deletion| v-solver-3546 v-c-3547))
    (setf v-old_lits-3606 (+ v-c-3547 16))
    (setf v-new_lits-3607 (m-ptr (+ (+ v-solver-3546 624) 0)))
    (progn (|c/unwatch_literal| v-solver-3546 (m-u32 (+ v-old_lits-3606 (* 4 0))) v-c-3547))
    (progn (|c/unwatch_literal| v-solver-3546 (m-u32 (+ v-old_lits-3606 (* 4 1))) v-c-3547))
    (setf v-size-3608 (the c-size (truncate (- (m-ptr (+ (+ v-solver-3546 624) 8)) (m-ptr (+ (+ v-solver-3546 624) 0))) 4)))
    (unless (c-true (if (= v-size-3608 (c-u64 2)) 1 0)) (go ELSE3609))
    (progn (|c/watch_binary| v-solver-3546 (c-bool (ldb (byte 1 2) (m-u8 (+ v-c-3547 0)))) (m-u32 (+ v-new_lits-3607 (* 4 0))) (m-u32 (+ v-new_lits-3607 (* 4 1)))))
    (progn (|c/watch_binary| v-solver-3546 (c-bool (ldb (byte 1 2) (m-u8 (+ v-c-3547 0)))) (m-u32 (+ v-new_lits-3607 (* 4 1))) (m-u32 (+ v-new_lits-3607 (* 4 0)))))
    (progn v-solver-3546)
    (progn (set-bits (+ v-c-3547 0) 0 1 (c-bool 1)))
    (go ENDIF3610)
    ELSE3609
    (progn (|c/watch_literal| v-solver-3546 (c-bool (ldb (byte 1 2) (m-u8 (+ v-c-3547 0)))) (m-u32 (+ v-new_lits-3607 (* 4 0))) (m-u32 (+ v-new_lits-3607 (* 4 1))) v-c-3547))
    (progn (|c/watch_literal| v-solver-3546 (c-bool (ldb (byte 1 2) (m-u8 (+ v-c-3547 0)))) (m-u32 (+ v-new_lits-3607 (* 4 1))) (m-u32 (+ v-new_lits-3607 (* 4 0))) v-c-3547))
    (setf v-p-3614 (+ v-c-3547 16))
    (setf v-PTR_lit-3619 (m-ptr (+ (+ v-solver-3546 624) 0)))
    (setf v-END_lit-3620 (m-ptr (+ (+ v-solver-3546 624) 8)))
    LOOP3615
    (unless (c-true (if (c-true (if (/= v-PTR_lit-3619 v-END_lit-3620) 1 0)) (c-bool (progn (setf v-lit-3618 (m-u32 v-PTR_lit-3619)) 1)) 0)) (go ENDLOOP3616))
    (progn (setf (m-u32 (let* ( (old3622 v-p-3614)) (setf v-p-3614 (+ old3622 (* 4 1))) old3622)) v-lit-3618))
    (let* ( (old3624 v-PTR_lit-3619)) (setf v-PTR_lit-3619 (+ old3624 (* 4 1))) v-PTR_lit-3619)
    (go LOOP3615)
    ENDLOOP3616
    (progn (setf (m-u32 (+ v-c-3547 12)) (c-u32 v-size-3608)))
    (unless (c-true (if (c-true (ldb (byte 1 2) (m-u8 (+ v-c-3547 0)))) (c-bool (if (>= (m-u32 (+ v-c-3547 12)) (m-u32 (+ v-c-3547 4))) 1 0)) 0)) (go ELSE3625))
    (progn (setf (m-u32 (+ v-c-3547 4)) (c-u32 (c-u64 (- v-size-3608 (c-u64 1))))))
    (go ENDIF3626)
    ELSE3625
    ENDIF3626
    (progn (setf (m-u32 (+ v-c-3547 8)) (c-u32 0)))
    (progn v-solver-3546)
    ENDIF3610
    (go ENDIF3605)
    ELSE3604
    ENDIF3605
    (progn (setf (m-ptr (+ (+ v-solver-3546 624) 8)) (m-ptr (+ (+ v-solver-3546 624) 0))))
    (return-from |c/clause_satisfied| (c-bool 0))
  )
  0))

;;; upstream/satch.c:7553:1
(defun |c/mark_garbage_if_satisfied| (arg-v-solver-3633 arg-v-c-3634)
 (declare  (type c-address arg-v-solver-3633) (type c-address arg-v-c-3634))
 (let ((v-solver-3633 0) (v-c-3634 0))
 (declare (type c-address v-solver-3633) (type c-address v-c-3634) (ignorable v-solver-3633 v-c-3634))
 (tagbody
    (setf v-solver-3633 arg-v-solver-3633)
    (setf v-c-3634 arg-v-c-3634)
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-c-3634 0)))) (go ELSE3635))
    (return-from |c/mark_garbage_if_satisfied| (c-bool 1))
    ELSE3635
    (unless (c-true (if (c-true (|c/clause_satisfied| v-solver-3633 v-c-3634)) 0 1)) (go ELSE3637))
    (return-from |c/mark_garbage_if_satisfied| (c-bool 0))
    ELSE3637
    (progn (|c/mark_garbage| v-solver-3633 v-c-3634 |c/string/137|))
    (return-from |c/mark_garbage_if_satisfied| (c-bool 1))
  )
  0))

;;; upstream/satch.c:7581:1
(defun |c/mark_irredundant_clauses_as_garbage_if_satisfied| (arg-v-solver-3639)
 (declare  (type c-address arg-v-solver-3639))
 (let ((v-solver-3639 0) (v-c-3643 0) (v-PTR_c-3644 0) (v-END_c-3645 0))
 (declare (type c-address v-solver-3639) (type c-address v-c-3643) (type c-address v-PTR_c-3644) (type c-address v-END_c-3645) (ignorable v-solver-3639 v-c-3643 v-PTR_c-3644 v-END_c-3645))
 (tagbody
    (setf v-solver-3639 arg-v-solver-3639)
    (setf v-PTR_c-3644 (m-ptr (+ (+ v-solver-3639 672) 0)))
    (setf v-END_c-3645 (m-ptr (+ (+ v-solver-3639 672) 8)))
    LOOP3640
    (unless (c-true (if (c-true (if (/= v-PTR_c-3644 v-END_c-3645) 1 0)) (c-bool (progn (setf v-c-3643 (m-ptr v-PTR_c-3644)) 1)) 0)) (go ENDLOOP3641))
    (progn (|c/mark_garbage_if_satisfied| v-solver-3639 v-c-3643))
    (let* ( (old3647 v-PTR_c-3644)) (setf v-PTR_c-3644 (+ old3647 (* 8 1))) v-PTR_c-3644)
    (go LOOP3640)
    ENDLOOP3641
  )
  0))

;;; upstream/satch.c:7598:1
(defun |c/gather_reduce_candidates| (arg-v-solver-3648 arg-v-new_fixed-3649 arg-v-candidates-3650)
 (declare  (type c-address arg-v-solver-3648) (type (integer 0 1) arg-v-new_fixed-3649) (type c-address arg-v-candidates-3650))
 (let ((v-solver-3648 0) (v-new_fixed-3649 0) (v-candidates-3650 0) (v-c-3654 0) (v-PTR_c-3655 0) (v-BEGIN_c-3656 0) (v-old_size-3685 0) (v-old_capacity-3686 0) (v-new_capacity-3687 0) (v-new_bytes-3688 0) (v-size_candidates-3695 0) (v-redundant-3696 0))
 (declare (type c-address v-solver-3648) (type (integer 0 1) v-new_fixed-3649) (type c-address v-candidates-3650) (type c-address v-c-3654) (type c-address v-PTR_c-3655) (type c-address v-BEGIN_c-3656) (type c-size v-old_size-3685) (type c-size v-old_capacity-3686) (type c-size v-new_capacity-3687) (type c-size v-new_bytes-3688) (type c-size v-size_candidates-3695) (type c-size v-redundant-3696) (ignorable v-solver-3648 v-new_fixed-3649 v-candidates-3650 v-c-3654 v-PTR_c-3655 v-BEGIN_c-3656 v-old_size-3685 v-old_capacity-3686 v-new_capacity-3687 v-new_bytes-3688 v-size_candidates-3695 v-redundant-3696))
 (tagbody
    (setf v-solver-3648 arg-v-solver-3648)
    (setf v-new_fixed-3649 arg-v-new_fixed-3649)
    (setf v-candidates-3650 arg-v-candidates-3650)
    (setf v-PTR_c-3655 (m-ptr (+ (+ v-solver-3648 696) 8)))
    (setf v-BEGIN_c-3656 (m-ptr (+ (+ v-solver-3648 696) 0)))
    LOOP3651
    (unless (c-true (if (c-true (if (/= (let* ( (old3658 v-PTR_c-3655)) (setf v-PTR_c-3655 (- old3658 (* 8 1))) old3658) v-BEGIN_c-3656) 1 0)) (c-bool (progn (setf v-c-3654 (m-ptr v-PTR_c-3655)) 1)) 0)) (go ENDLOOP3652))
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-c-3654 0)))) (go ELSE3659))
    (go CONTINUE3653)
    ELSE3659
    (unless (c-true (ldb (byte 1 1) (m-u8 (+ v-c-3654 0)))) (go ELSE3661))
    (go CONTINUE3653)
    ELSE3661
    (unless (c-true v-new_fixed-3649) (go ELSE3663))
    (unless (c-true (|c/mark_garbage_if_satisfied| v-solver-3648 v-c-3654)) (go ELSE3665))
    (go CONTINUE3653)
    ELSE3665
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-c-3654 0)))) (go ELSE3667))
    (go CONTINUE3653)
    ELSE3667
    (go ENDIF3664)
    ELSE3663
    ENDIF3664
    (unless (c-true (if (<= (m-u32 (+ v-c-3654 4)) (c-u32 2)) 1 0)) (go ELSE3669))
    (go CONTINUE3653)
    ELSE3669
    (unless (c-true (ldb (byte 2 4) (m-u8 (+ v-c-3654 0)))) (go ELSE3671))
    (progn (let* ((a3673 (+ v-c-3654 0)) (old3674 (ldb (byte 2 4) (m-u8 a3673)))) (set-bits a3673 4 2 (c-u32 (c-u32 (- old3674 (c-u32 1))))) old3674))
    (unless (c-true (if (<= (m-u32 (+ v-c-3654 4)) (c-u32 6)) 1 0)) (go ELSE3675))
    (go CONTINUE3653)
    ELSE3675
    (go ENDIF3672)
    ELSE3671
    ENDIF3672
    (unless (c-true (if (= (m-ptr (+ v-candidates-3650 8)) (m-ptr (+ v-candidates-3650 16))) 1 0)) (go ELSE3680))
    (setf v-old_size-3685 (the c-size (truncate (- (m-ptr (+ v-candidates-3650 8)) (m-ptr (+ v-candidates-3650 0))) 8)))
    (setf v-old_capacity-3686 (the c-size (truncate (- (m-ptr (+ v-candidates-3650 16)) (m-ptr (+ v-candidates-3650 0))) 8)))
    (setf v-new_capacity-3687 (if (c-true v-old_capacity-3686) (c-u64 (* (c-u64 2) v-old_capacity-3686)) (c-u64 1)))
    (setf v-new_bytes-3688 (c-u64 (* v-new_capacity-3687 8)))
    (progn (setf (m-ptr (+ v-candidates-3650 0)) (c-realloc (m-ptr (+ v-candidates-3650 0)) v-new_bytes-3688)))
    (unless (c-true (if (c-true (m-ptr (+ v-candidates-3650 0))) 0 1)) (go ELSE3689))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-3688))
    (go ENDIF3690)
    ELSE3689
    ENDIF3690
    (progn (setf (m-ptr (+ v-candidates-3650 8)) (+ (m-ptr (+ v-candidates-3650 0)) (* 8 v-old_size-3685))))
    (progn (setf (m-ptr (+ v-candidates-3650 16)) (+ (m-ptr (+ v-candidates-3650 0)) (* 8 v-new_capacity-3687))))
    (go ENDIF3681)
    ELSE3680
    ENDIF3681
    (progn (setf (m-ptr (let* ((a3691 (+ v-candidates-3650 8)) (old3692 (m-ptr a3691))) (setf (m-ptr a3691) (+ old3692 (* 8 1))) old3692)) v-c-3654))
    CONTINUE3653
    (go LOOP3651)
    ENDLOOP3652
    (unless (c-true (if (< (m-u32 (+ (+ v-solver-3648 880) 4)) (c-u32 2)) 1 0)) (go ELSE3693))
    (return-from |c/gather_reduce_candidates| 0)
    ELSE3693
    (setf v-size_candidates-3695 (the c-size (truncate (- (m-ptr (+ v-candidates-3650 8)) (m-ptr (+ v-candidates-3650 0))) 8)))
    (setf v-redundant-3696 (the c-size (truncate (- (m-ptr (+ (+ v-solver-3648 696) 8)) (m-ptr (+ (+ v-solver-3648 696) 0))) 8)))
    (progn (when (>= (m-u32 (+ v-solver-3648 884)) (c-u32 2)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-3648 (c-u32 2) |c/string/19| (m-u64 (+ (+ v-solver-3648 1016) 200)) |c/string/138| v-size_candidates-3695 (|c/percent| (integer64-double v-size_candidates-3695 nil) (integer64-double v-redundant-3696 nil))))))
  )
  0))

;;; upstream/satch.c:7661:1
(defun |c/flush_garbage_watches| (arg-v-solver-3697)
 (declare  (type c-address arg-v-solver-3697))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-3697 0) (v-all_watches-3698 0) (v-values-3699 0) (v-levels-3700 0) (v-lit-3704 0) (v-END_LITERALS-3705 0) (v-lit_value-3706 0) (v-lit_watches-3709 0) (v-end-3710 0) (v-q-3711 0) (v-p-3712 0) (v-watch-3716 (stack-alloc 8)) (v-header-3719 (stack-alloc 8)) (v-blocking-3722 0) (v-blocking_value-3723 0) (v-clause-3732 0))
 (declare (type c-address v-solver-3697) (type c-address v-all_watches-3698) (type c-address v-values-3699) (type c-address v-levels-3700) (type (unsigned-byte 32) v-lit-3704) (type (unsigned-byte 32) v-END_LITERALS-3705) (type (signed-byte 8) v-lit_value-3706) (type c-address v-lit_watches-3709) (type c-address v-end-3710) (type c-address v-q-3711) (type c-address v-p-3712) (type c-address v-watch-3716) (type c-address v-header-3719) (type (unsigned-byte 32) v-blocking-3722) (type (signed-byte 8) v-blocking_value-3723) (type c-address v-clause-3732) (ignorable v-solver-3697 v-all_watches-3698 v-values-3699 v-levels-3700 v-lit-3704 v-END_LITERALS-3705 v-lit_value-3706 v-lit_watches-3709 v-end-3710 v-q-3711 v-p-3712 v-watch-3716 v-header-3719 v-blocking-3722 v-blocking_value-3723 v-clause-3732))
 (tagbody
    (setf v-solver-3697 arg-v-solver-3697)
    (setf v-all_watches-3698 (m-ptr (+ v-solver-3697 544)))
    (setf v-values-3699 (m-ptr (+ v-solver-3697 40)))
    (setf v-levels-3700 (m-ptr (+ v-solver-3697 32)))
    (setf v-lit-3704 (c-u32 0))
    (setf v-END_LITERALS-3705 (c-u32 (* 2 (m-u32 (+ v-solver-3697 12)))))
    LOOP3701
    (unless (c-true (if (< v-lit-3704 v-END_LITERALS-3705) 1 0)) (go ENDLOOP3702))
    (setf v-lit_value-3706 (m-s8 (+ v-values-3699 (* 1 v-lit-3704))))
    (unless (c-true (if (c-true v-lit_value-3706) (c-bool (m-u32 (+ v-levels-3700 (* 4 (|c/INDEX| v-lit-3704))))) 0)) (go ELSE3707))
    (progn (setf v-lit_value-3706 (c-s8 0)))
    (go ENDIF3708)
    ELSE3707
    ENDIF3708
    (setf v-lit_watches-3709 (+ v-all_watches-3698 (* 24 v-lit-3704)))
    (setf v-end-3710 (m-ptr (+ v-lit_watches-3709 8)))
    (setf v-q-3711 (m-ptr (+ v-lit_watches-3709 0)))
    (setf v-p-3712 v-q-3711)
    LOOP3713
    (unless (c-true (if (/= v-p-3712 v-end-3710) 1 0)) (go ENDLOOP3714))
    (copy-bytes v-watch-3716 (let* ( (old3718 v-p-3712)) (setf v-p-3712 (+ old3718 (* 8 1))) old3718) 8)
    (copy-bytes v-header-3719 (+ v-watch-3716 0) 8)
    (unless (c-true (m-u8 (+ v-header-3719 0))) (go ELSE3720))
    (setf v-blocking-3722 (m-u32 (+ v-header-3719 4)))
    (setf v-blocking_value-3723 (m-s8 (+ v-values-3699 (* 1 v-blocking-3722))))
    (unless (c-true (if (c-true v-blocking_value-3723) (c-bool (m-u32 (+ v-levels-3700 (* 4 (|c/INDEX| v-blocking-3722))))) 0)) (go ELSE3724))
    (progn (setf v-blocking_value-3723 (c-s8 0)))
    (go ENDIF3725)
    ELSE3724
    ENDIF3725
    (unless (c-true (if (c-true v-lit_value-3706) 1 (c-bool v-blocking_value-3723))) (go ELSE3726))
    (progn (|c/delete_binary| v-solver-3697 (c-bool (m-u8 (+ v-header-3719 1))) v-lit-3704 v-blocking-3722))
    (go CONTINUE3715)
    ELSE3726
    (progn (copy-bytes (let* ( (old3729 v-q-3711)) (setf v-q-3711 (+ old3729 (* 8 1))) old3729) v-watch-3716 8))
    (go CONTINUE3715)
    ELSE3720
    (progn (copy-bytes (let* ( (old3731 v-q-3711)) (setf v-q-3711 (+ old3731 (* 8 1))) old3731) v-watch-3716 8))
    (setf v-clause-3732 (m-ptr (+ (copy-bytes (let* ( (old3734 v-q-3711)) (setf v-q-3711 (+ old3734 (* 8 1))) old3734) (let* ( (old3736 v-p-3712)) (setf v-p-3712 (+ old3736 (* 8 1))) old3736) 8) 0)))
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-clause-3732 0)))) (go ELSE3737))
    (progn (setf v-q-3711 (- v-q-3711 (* 8 2))))
    (go ENDIF3738)
    ELSE3737
    ENDIF3738
    CONTINUE3715
    (go LOOP3713)
    ENDLOOP3714
    (progn (setf (m-ptr (+ v-lit_watches-3709 8)) v-q-3711))
    (let* ( (old3741 v-lit-3704)) (setf v-lit-3704 (c-u32 (c-u32 (+ old3741 (c-u32 1))))) old3741)
    (go LOOP3701)
    ENDLOOP3702
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:7728:1
(defun |c/delete_garbage_clauses| (arg-v-solver-3742 arg-v-clauses-3743 arg-v-bytes_ptr-3744 arg-v-count_ptr-3745)
 (declare  (type c-address arg-v-solver-3742) (type c-address arg-v-clauses-3743) (type c-address arg-v-bytes_ptr-3744) (type c-address arg-v-count_ptr-3745))
 (let ((v-solver-3742 0) (v-clauses-3743 0) (v-bytes_ptr-3744 0) (v-count_ptr-3745 0) (v-bytes-3746 0) (v-count-3747 0) (v-end-3748 0) (v-q-3749 0) (v-p-3753 0) (v-c-3754 0))
 (declare (type c-address v-solver-3742) (type c-address v-clauses-3743) (type c-address v-bytes_ptr-3744) (type c-address v-count_ptr-3745) (type c-size v-bytes-3746) (type c-size v-count-3747) (type c-address v-end-3748) (type c-address v-q-3749) (type c-address v-p-3753) (type c-address v-c-3754) (ignorable v-solver-3742 v-clauses-3743 v-bytes_ptr-3744 v-count_ptr-3745 v-bytes-3746 v-count-3747 v-end-3748 v-q-3749 v-p-3753 v-c-3754))
 (tagbody
    (setf v-solver-3742 arg-v-solver-3742)
    (setf v-clauses-3743 arg-v-clauses-3743)
    (setf v-bytes_ptr-3744 arg-v-bytes_ptr-3744)
    (setf v-count_ptr-3745 arg-v-count_ptr-3745)
    (setf v-bytes-3746 (c-u64 0))
    (setf v-count-3747 (c-u64 0))
    (setf v-end-3748 (m-ptr (+ v-clauses-3743 8)))
    (setf v-q-3749 (m-ptr (+ v-clauses-3743 0)))
    (setf v-p-3753 v-q-3749)
    LOOP3750
    (unless (c-true (if (/= v-p-3753 v-end-3748) 1 0)) (go ENDLOOP3751))
    (setf v-c-3754 (m-ptr v-p-3753))
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-c-3754 0)))) (go ELSE3755))
    (progn (setf v-bytes-3746 (c-u64 (c-u64 (+ v-bytes-3746 (|c/delete_clause| v-solver-3742 v-c-3754))))))
    (progn (let* ( (old3759 v-count-3747)) (setf v-count-3747 (c-u64 (c-u64 (+ old3759 (c-u64 1))))) old3759))
    (go ENDIF3756)
    ELSE3755
    (progn (setf (m-ptr (let* ( (old3761 v-q-3749)) (setf v-q-3749 (+ old3761 (* 8 1))) old3761)) v-c-3754))
    ENDIF3756
    (let* ( (old3763 v-p-3753)) (setf v-p-3753 (+ old3763 (* 8 1))) old3763)
    (go LOOP3750)
    ENDLOOP3751
    (progn (setf (m-ptr (+ v-clauses-3743 8)) v-q-3749))
    (progn (let ((a3764 v-bytes_ptr-3744)) (setf (m-size a3764) (c-u64 (c-u64 (+ (m-size a3764) v-bytes-3746))))))
    (progn (let ((a3765 v-count_ptr-3745)) (setf (m-size a3765) (c-u64 (c-u64 (+ (m-size a3765) v-count-3747))))))
  )
  0))

;;; upstream/satch.c:7771:1
(defun |c/rank_clause| (arg-v-c-3766)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-c-3766))
 (let ((v-c-3766 0))
 (declare (type c-address v-c-3766) (ignorable v-c-3766))
 (tagbody
    (setf v-c-3766 arg-v-c-3766)
    (return-from |c/rank_clause| (c-u64 (+ (c-u64 (ash (c-u64 (m-u32 (+ v-c-3766 4))) 32)) (m-u32 (+ v-c-3766 12)))))
  )
  0))

;;; upstream/satch.c:7777:1
(defun |c/sort_reduce_candidates| (arg-v-candidates-3767)
 (declare (optimize (speed 1) (compilation-speed 3)) (notinline checked-address) (type c-address arg-v-candidates-3767))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-candidates-3767 0) (v-N_RANK-3771 0) (v-V_RANK-3774 0) (v-LENGTH_RANK-3775 0) (v-WIDTH_RANK-3776 0) (v-MASK_RANK-3777 0) (v-COUNT_RANK-3778 (stack-alloc 2048)) (v-TMP_RANK-3779 0) (v-BYTES_TMP_RANK-3780 0) (v-A_RANK-3781 0) (v-B_RANK-3782 0) (v-C_RANK-3783 0) (v-MLOWER_RANK-3784 0) (v-MUPPER_RANK-3785 0) (v-BOUNDED_RANK-3786 0) (v-UPPER_RANK-3787 0) (v-LOWER_RANK-3788 0) (v-SHIFT_RANK-3789 0) (v-I_RANK-3793 0) (v-END_RANK-3796 0) (v-SORTED_RANK-3797 0) (v-LAST_RANK-3798 0) (v-P_RANK-3802 0) (v-R_RANK-3803 0) (v-S_RANK-3808 0) (v-M_RANK-3809 0) (v-POS_RANK-3822 0) (v-J_RANK-3826 0) (v-DELTA_RANK-3827 0) (v-D_RANK-3835 0) (v-P_RANK-3839 0) (v-R_RANK-3840 0) (v-S_RANK-3841 0) (v-M_RANK-3842 0) (v-POS_RANK-3843 0))
 (declare (type c-address v-candidates-3767) (type c-size v-N_RANK-3771) (type c-address v-V_RANK-3774) (type c-size v-LENGTH_RANK-3775) (type c-size v-WIDTH_RANK-3776) (type (unsigned-byte 64) v-MASK_RANK-3777) (type c-address v-COUNT_RANK-3778) (type c-address v-TMP_RANK-3779) (type c-size v-BYTES_TMP_RANK-3780) (type c-address v-A_RANK-3781) (type c-address v-B_RANK-3782) (type c-address v-C_RANK-3783) (type (unsigned-byte 64) v-MLOWER_RANK-3784) (type (unsigned-byte 64) v-MUPPER_RANK-3785) (type (integer 0 1) v-BOUNDED_RANK-3786) (type (unsigned-byte 64) v-UPPER_RANK-3787) (type (unsigned-byte 64) v-LOWER_RANK-3788) (type (unsigned-byte 64) v-SHIFT_RANK-3789) (type c-size v-I_RANK-3793) (type c-address v-END_RANK-3796) (type (integer 0 1) v-SORTED_RANK-3797) (type (unsigned-byte 64) v-LAST_RANK-3798) (type c-address v-P_RANK-3802) (type (unsigned-byte 64) v-R_RANK-3803) (type (unsigned-byte 64) v-S_RANK-3808) (type (unsigned-byte 64) v-M_RANK-3809) (type c-size v-POS_RANK-3822) (type c-size v-J_RANK-3826) (type c-size v-DELTA_RANK-3827) (type c-address v-D_RANK-3835) (type c-address v-P_RANK-3839) (type (unsigned-byte 64) v-R_RANK-3840) (type (unsigned-byte 64) v-S_RANK-3841) (type (unsigned-byte 64) v-M_RANK-3842) (type c-size v-POS_RANK-3843) (ignorable v-candidates-3767 v-N_RANK-3771 v-V_RANK-3774 v-LENGTH_RANK-3775 v-WIDTH_RANK-3776 v-MASK_RANK-3777 v-COUNT_RANK-3778 v-TMP_RANK-3779 v-BYTES_TMP_RANK-3780 v-A_RANK-3781 v-B_RANK-3782 v-C_RANK-3783 v-MLOWER_RANK-3784 v-MUPPER_RANK-3785 v-BOUNDED_RANK-3786 v-UPPER_RANK-3787 v-LOWER_RANK-3788 v-SHIFT_RANK-3789 v-I_RANK-3793 v-END_RANK-3796 v-SORTED_RANK-3797 v-LAST_RANK-3798 v-P_RANK-3802 v-R_RANK-3803 v-S_RANK-3808 v-M_RANK-3809 v-POS_RANK-3822 v-J_RANK-3826 v-DELTA_RANK-3827 v-D_RANK-3835 v-P_RANK-3839 v-R_RANK-3840 v-S_RANK-3841 v-M_RANK-3842 v-POS_RANK-3843))
 (tagbody
    (setf v-candidates-3767 arg-v-candidates-3767)
    (setf v-N_RANK-3771 (the c-size (truncate (- (m-ptr (+ v-candidates-3767 8)) (m-ptr (+ v-candidates-3767 0))) 8)))
    (unless (c-true (if (<= v-N_RANK-3771 (c-u64 1)) 1 0)) (go ELSE3772))
    (go ENDLOOP3769)
    ELSE3772
    (setf v-V_RANK-3774 (m-ptr (+ v-candidates-3767 0)))
    (setf v-LENGTH_RANK-3775 (c-u64 8))
    (setf v-WIDTH_RANK-3776 (c-u64 (c-s32 (ash (c-s32 1) v-LENGTH_RANK-3775))))
    (locally (declare (optimize (speed 1))) (setf v-MASK_RANK-3777 (c-u64 (- v-WIDTH_RANK-3776 (c-u64 1)))))
    (setf v-TMP_RANK-3779 0)
    (setf v-BYTES_TMP_RANK-3780 (c-u64 (* v-N_RANK-3771 8)))
    (setf v-A_RANK-3781 v-V_RANK-3774)
    (setf v-B_RANK-3782 0)
    (setf v-C_RANK-3783 v-A_RANK-3781)
    (locally (declare (optimize (speed 1))) (setf v-MLOWER_RANK-3784 (c-u64 0)))
    (locally (declare (optimize (speed 1))) (setf v-MUPPER_RANK-3785 v-MASK_RANK-3777))
    (setf v-BOUNDED_RANK-3786 (c-bool 0))
    (locally (declare (optimize (speed 1))) (setf v-UPPER_RANK-3787 (c-u64 0)))
    (locally (declare (optimize (speed 1))) (setf v-LOWER_RANK-3788 (c-u64 (lognot v-UPPER_RANK-3787))))
    (locally (declare (optimize (speed 1))) (setf v-SHIFT_RANK-3789 v-MASK_RANK-3777))
    (setf v-I_RANK-3793 (c-u64 0))
    LOOP3790
    (unless (c-true (if (< v-I_RANK-3793 (c-u64 (* (c-u64 8) 8))) 1 0)) (go ENDLOOP3791))
    (unless (c-true (if (c-true v-BOUNDED_RANK-3786) (c-bool (if (= (c-u64 (logand v-LOWER_RANK-3788 v-SHIFT_RANK-3789)) (c-u64 (logand v-UPPER_RANK-3787 v-SHIFT_RANK-3789))) 1 0)) 0)) (go ELSE3794))
    (go CONTINUE3792)
    ELSE3794
    (progn (c-memset (+ v-COUNT_RANK-3778 (* 8 v-MLOWER_RANK-3784)) 0 (c-u64 (* (c-u64 (+ (c-u64 (- v-MUPPER_RANK-3785 v-MLOWER_RANK-3784)) (c-u64 1))) 8))))
    (setf v-END_RANK-3796 (+ v-C_RANK-3783 (* 8 v-N_RANK-3771)))
    (setf v-SORTED_RANK-3797 (c-bool 1))
    (locally (declare (optimize (speed 1))) (setf v-LAST_RANK-3798 (c-u64 0)))
    (setf v-P_RANK-3802 v-C_RANK-3783)
    LOOP3799
    (unless (c-true (if (/= v-P_RANK-3802 v-END_RANK-3796) 1 0)) (go ENDLOOP3800))
    (locally (declare (optimize (speed 1))) (setf v-R_RANK-3803 (|c/rank_clause| (m-ptr v-P_RANK-3802))))
    (unless (c-true (if (c-true v-BOUNDED_RANK-3786) 0 1)) (go ELSE3804))
    (progn (setf v-LOWER_RANK-3788 (c-u64 (c-u64 (logand v-LOWER_RANK-3788 v-R_RANK-3803)))))
    (progn (setf v-UPPER_RANK-3787 (c-u64 (c-u64 (logior v-UPPER_RANK-3787 v-R_RANK-3803)))))
    (go ENDIF3805)
    ELSE3804
    ENDIF3805
    (locally (declare (optimize (speed 1))) (setf v-S_RANK-3808 (c-u64 (ash (c-u64 v-R_RANK-3803) (- v-I_RANK-3793)))))
    (locally (declare (optimize (speed 1))) (setf v-M_RANK-3809 (c-u64 (logand v-S_RANK-3808 v-MASK_RANK-3777))))
    (unless (c-true (if (c-true v-SORTED_RANK-3797) (c-bool (if (> v-LAST_RANK-3798 v-M_RANK-3809) 1 0)) 0)) (go ELSE3810))
    (progn (setf v-SORTED_RANK-3797 (c-bool 0)))
    (go ENDIF3811)
    ELSE3810
    (progn (setf v-LAST_RANK-3798 v-M_RANK-3809))
    ENDIF3811
    (progn (let* ((a3812 (+ v-COUNT_RANK-3778 (* 8 v-M_RANK-3809))) (old3813 (m-size a3812))) (setf (m-size a3812) (c-u64 (c-u64 (+ old3813 (c-u64 1))))) old3813))
    (let* ( (old3815 v-P_RANK-3802)) (setf v-P_RANK-3802 (+ old3815 (* 8 1))) old3815)
    (go LOOP3799)
    ENDLOOP3800
    (progn (setf v-MLOWER_RANK-3784 (c-u64 (logand (c-u64 (ash (c-u64 v-LOWER_RANK-3788) (- v-I_RANK-3793))) v-MASK_RANK-3777))))
    (progn (setf v-MUPPER_RANK-3785 (c-u64 (logand (c-u64 (ash (c-u64 v-UPPER_RANK-3787) (- v-I_RANK-3793))) v-MASK_RANK-3777))))
    (unless (c-true (if (c-true v-BOUNDED_RANK-3786) 0 1)) (go ELSE3816))
    (progn (setf v-BOUNDED_RANK-3786 (c-bool 1)))
    (unless (c-true (if (= (c-u64 (logand v-LOWER_RANK-3788 v-SHIFT_RANK-3789)) (c-u64 (logand v-UPPER_RANK-3787 v-SHIFT_RANK-3789))) 1 0)) (go ELSE3818))
    (go CONTINUE3792)
    ELSE3818
    (go ENDIF3817)
    ELSE3816
    ENDIF3817
    (unless (c-true v-SORTED_RANK-3797) (go ELSE3820))
    (go CONTINUE3792)
    ELSE3820
    (setf v-POS_RANK-3822 (c-u64 0))
    (setf v-J_RANK-3826 v-MLOWER_RANK-3784)
    LOOP3823
    (unless (c-true (if (<= v-J_RANK-3826 v-MUPPER_RANK-3785) 1 0)) (go ENDLOOP3824))
    (setf v-DELTA_RANK-3827 (m-size (+ v-COUNT_RANK-3778 (* 8 v-J_RANK-3826))))
    (progn (setf (m-size (+ v-COUNT_RANK-3778 (* 8 v-J_RANK-3826))) v-POS_RANK-3822))
    (progn (setf v-POS_RANK-3822 (c-u64 (c-u64 (+ v-POS_RANK-3822 v-DELTA_RANK-3827)))))
    (let* ( (old3830 v-J_RANK-3826)) (setf v-J_RANK-3826 (c-u64 (c-u64 (+ old3830 (c-u64 1))))) old3830)
    (go LOOP3823)
    ENDLOOP3824
    (unless (c-true (if (c-true v-TMP_RANK-3779) 0 1)) (go ELSE3831))
    (progn (setf v-TMP_RANK-3779 (c-malloc v-BYTES_TMP_RANK-3780)))
    (unless (c-true (if (c-true v-TMP_RANK-3779) 0 1)) (go ELSE3833))
    (progn (|c/out_of_memory| v-BYTES_TMP_RANK-3780))
    (go ENDIF3834)
    ELSE3833
    ENDIF3834
    (progn (setf v-B_RANK-3782 v-TMP_RANK-3779))
    (go ENDIF3832)
    ELSE3831
    ENDIF3832
    (setf v-D_RANK-3835 (if (c-true (if (= v-C_RANK-3783 v-A_RANK-3781) 1 0)) v-B_RANK-3782 v-A_RANK-3781))
    (setf v-P_RANK-3839 v-C_RANK-3783)
    LOOP3836
    (unless (c-true (if (/= v-P_RANK-3839 v-END_RANK-3796) 1 0)) (go ENDLOOP3837))
    (locally (declare (optimize (speed 1))) (setf v-R_RANK-3840 (|c/rank_clause| (m-ptr v-P_RANK-3839))))
    (locally (declare (optimize (speed 1))) (setf v-S_RANK-3841 (c-u64 (ash (c-u64 v-R_RANK-3840) (- v-I_RANK-3793)))))
    (locally (declare (optimize (speed 1))) (setf v-M_RANK-3842 (c-u64 (logand v-S_RANK-3841 v-MASK_RANK-3777))))
    (setf v-POS_RANK-3843 (let* ((a3844 (+ v-COUNT_RANK-3778 (* 8 v-M_RANK-3842))) (old3845 (m-size a3844))) (setf (m-size a3844) (c-u64 (c-u64 (+ old3845 (c-u64 1))))) old3845))
    (progn (setf (m-ptr (+ v-D_RANK-3835 (* 8 v-POS_RANK-3843))) (m-ptr v-P_RANK-3839)))
    (let* ( (old3847 v-P_RANK-3839)) (setf v-P_RANK-3839 (+ old3847 (* 8 1))) old3847)
    (go LOOP3836)
    ENDLOOP3837
    (progn (setf v-C_RANK-3783 v-D_RANK-3835))
    CONTINUE3792
    (progn (setf v-I_RANK-3793 (c-u64 (c-u64 (+ v-I_RANK-3793 v-LENGTH_RANK-3775)))) (setf v-SHIFT_RANK-3789 (c-u64 (c-u64 (ash (c-u64 v-SHIFT_RANK-3789) v-LENGTH_RANK-3775)))))
    (go LOOP3790)
    ENDLOOP3791
    (unless (c-true (if (= v-C_RANK-3783 v-B_RANK-3782) 1 0)) (go ELSE3850))
    (progn (c-memcpy v-A_RANK-3781 v-B_RANK-3782 (c-u64 (* v-N_RANK-3771 8))))
    (go ENDIF3851)
    ELSE3850
    ENDIF3851
    (unless (c-true v-TMP_RANK-3779) (go ELSE3852))
    (progn (c-free v-TMP_RANK-3779))
    (go ENDIF3853)
    ELSE3852
    ENDIF3853
    ENDLOOP3769
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:7843:1
(defun |c/mark_garbage_candidates| (arg-v-solver-3857 arg-v-candidates-3858)
 (declare  (type c-address arg-v-solver-3857) (type c-address arg-v-candidates-3858))
 (let ((v-solver-3857 0) (v-candidates-3858 0) (v-size-3859 0) (v-reduce-3860 0) (v-keep_fraction-3861 0d0) (v-keep-3862 0) (v-reduced-3863 0) (v-c-3867 0))
 (declare (type c-address v-solver-3857) (type c-address v-candidates-3858) (type c-size v-size-3859) (type c-size v-reduce-3860) (type double-float v-keep_fraction-3861) (type c-size v-keep-3862) (type c-size v-reduced-3863) (type c-address v-c-3867) (ignorable v-solver-3857 v-candidates-3858 v-size-3859 v-reduce-3860 v-keep_fraction-3861 v-keep-3862 v-reduced-3863 v-c-3867))
 (tagbody
    (setf v-solver-3857 arg-v-solver-3857)
    (setf v-candidates-3858 arg-v-candidates-3858)
    (setf v-size-3859 (the c-size (truncate (- (m-ptr (+ v-candidates-3858 8)) (m-ptr (+ v-candidates-3858 0))) 8)))
    (setf v-reduce-3860 (values (the c-size (truncate (float (* 0.75d0 (integer64-double v-size-3859 nil)) 1d0)))))
    (progn (when (>= (m-u32 (+ v-solver-3857 884)) (c-u32 4)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-3857 (c-u32 4) |c/string/19| (m-u64 (+ (+ v-solver-3857 1016) 200)) |c/string/139| v-reduce-3860 v-size-3859 (|c/percent| (integer64-double v-reduce-3860 nil) (integer64-double v-size-3859 nil))))))
    (setf v-keep_fraction-3861 (float (- 1.0d0 0.75d0) 1d0))
    (setf v-keep-3862 (values (the c-size (truncate (float (* v-keep_fraction-3861 (integer64-double v-size-3859 nil)) 1d0)))))
    (setf v-reduced-3863 (c-u64 0))
    LOOP3864
    (unless (c-true (if (> (the c-size (truncate (- (m-ptr (+ v-candidates-3858 8)) (m-ptr (+ v-candidates-3858 0))) 8)) v-keep-3862) 1 0)) (go ENDLOOP3865))
    (setf v-c-3867 (progn 0 (m-ptr (let* ((a3868 (+ v-candidates-3858 8)) (old3869 (m-ptr a3868))) (setf (m-ptr a3868) (- old3869 (* 8 1))) (m-ptr a3868)))))
    (progn (|c/mark_garbage| v-solver-3857 v-c-3867 |c/string/140|))
    (progn (let* ( (old3871 v-reduced-3863)) (setf v-reduced-3863 (c-u64 (c-u64 (+ old3871 (c-u64 1))))) old3871))
    (go LOOP3864)
    ENDLOOP3865
    (progn (let ((a3875 (+ (+ v-solver-3857 1016) 192))) (setf (m-u64 a3875) (c-u64 (c-u64 (+ (m-u64 a3875) v-reduced-3863))))))
    (progn (when (>= (m-u32 (+ v-solver-3857 884)) (c-u32 3)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-3857 (c-u32 3) |c/string/19| (m-u64 (+ (+ v-solver-3857 1016) 200)) |c/string/141| v-reduced-3863 v-size-3859 (|c/percent| (integer64-double v-reduced-3863 nil) (integer64-double v-size-3859 nil))))))
  )
  0))

