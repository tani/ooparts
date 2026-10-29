(in-package #:ooparts/sat/impl)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))
;;; upstream/satch.c:7939:1
(defun |c/reduce| (arg-v-solver-3876)
 (declare  (type c-address arg-v-solver-3876))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-3876 0) (v-reductions-3877 0) (v-new_fixed-3880 0) (v-candidates-3883 (stack-alloc 24)) (v-bytes-3890 (stack-alloc 8)) (v-count-3891 (stack-alloc 8)) (v-interval-3900 0))
 (declare (type c-address v-solver-3876) (type (unsigned-byte 64) v-reductions-3877) (type (integer 0 1) v-new_fixed-3880) (type c-address v-candidates-3883) (type c-address v-bytes-3890) (type c-address v-count-3891) (type (unsigned-byte 64) v-interval-3900) (ignorable v-solver-3876 v-reductions-3877 v-new_fixed-3880 v-candidates-3883 v-bytes-3890 v-count-3891 v-interval-3900))
 (tagbody
    (setf v-solver-3876 arg-v-solver-3876)
    (progn (|c/start_profiling| v-solver-3876 (+ (+ v-solver-3876 1472) 72)))
    (locally (declare (optimize (speed 1))) (setf v-reductions-3877 (progn 0 (let* ((a3878 (+ (+ v-solver-3876 1016) 200)) (old3879 (m-u64 a3878))) (setf (m-u64 a3878) (c-u64 (c-u64 (+ old3879 (c-u64 1))))) (m-u64 a3878)))))
    (setf v-new_fixed-3880 (c-bool (if (< (m-u64 (+ (+ (+ v-solver-3876 720) 64) 8)) (m-u64 (+ (+ v-solver-3876 1016) 104))) 1 0)))
    (unless (c-true v-new_fixed-3880) (go ELSE3881))
    (progn (|c/update_phases_and_backtrack_to_root_level| v-solver-3876))
    (progn (|c/mark_irredundant_clauses_as_garbage_if_satisfied| v-solver-3876))
    (go ENDIF3882)
    ELSE3881
    (progn (|c/set_protect_flag_of_reasons| v-solver-3876 (c-bool 1)))
    ENDIF3882
    (progn (setf (m-ptr (+ v-candidates-3883 8)) (setf (m-ptr (+ v-candidates-3883 0)) (setf (m-ptr (+ v-candidates-3883 16)) 0))))
    (progn (|c/gather_reduce_candidates| v-solver-3876 (c-bool v-new_fixed-3880) v-candidates-3883))
    (progn (|c/sort_reduce_candidates| v-candidates-3883))
    (progn (|c/mark_garbage_candidates| v-solver-3876 v-candidates-3883))
    (progn (c-free (m-ptr (+ v-candidates-3883 0))))
    (progn (setf (m-ptr (+ v-candidates-3883 0)) (setf (m-ptr (+ v-candidates-3883 8)) (setf (m-ptr (+ v-candidates-3883 16)) 0))))
    (progn (|c/flush_garbage_watches| v-solver-3876))
    (setf (m-size v-bytes-3890) (c-u64 0))
    (setf (m-size v-count-3891) (c-u64 0))
    (unless (c-true v-new_fixed-3880) (go ELSE3892))
    (progn (|c/delete_garbage_clauses| v-solver-3876 (+ v-solver-3876 672) v-bytes-3890 v-count-3891))
    (go ENDIF3893)
    ELSE3892
    ENDIF3893
    (progn (|c/delete_garbage_clauses| v-solver-3876 (+ v-solver-3876 696) v-bytes-3890 v-count-3891))
    (progn (when (>= (m-u32 (+ v-solver-3876 884)) (c-u32 2)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-3876 (c-u32 2) |c/string/19| v-reductions-3877 |c/string/142| (m-size v-count-3891) (m-size v-bytes-3890) (float (/ (integer64-double (m-size v-bytes-3890) nil) (float (c-u32 (ash (c-u32 1) 20)) 1d0)) 1d0)))))
    (progn (let ((a3897 (+ (+ v-solver-3876 1016) 40))) (setf (m-u64 a3897) (c-u64 (c-u64 (+ (m-u64 a3897) (m-size v-bytes-3890)))))))
    (unless (c-true (if (c-true v-new_fixed-3880) 0 1)) (go ELSE3898))
    (progn (|c/set_protect_flag_of_reasons| v-solver-3876 (c-bool 0)))
    (go ENDIF3899)
    ELSE3898
    ENDIF3899
    (progn (setf (m-u64 (+ (+ (+ v-solver-3876 720) 64) 8)) (m-u64 (+ (+ v-solver-3876 1016) 104))))
    (locally (declare (optimize (speed 1))) (setf v-interval-3900 (values (the (unsigned-byte 64) (truncate (|c/scale_interval| (c-u64 300) (function-handle #'|c/ndivlogn|) v-reductions-3877))))))
    (progn (setf (m-u64 (+ (+ (+ v-solver-3876 720) 64) 0)) (c-u64 (+ (m-u64 (+ (+ v-solver-3876 1016) 48)) v-interval-3900))))
    (progn (when (>= (m-u32 (+ v-solver-3876 884)) (c-u32 4)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-3876 (c-u32 4) |c/string/19| v-reductions-3877 |c/string/143| (m-u64 (+ (+ (+ v-solver-3876 720) 64) 0)) v-interval-3900))))
    (progn (|c/report| v-solver-3876 (c-u32 1) 45))
    (progn (|c/stop_profiling| v-solver-3876 (+ (+ v-solver-3876 1472) 72) (|c/process_time|)))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:8045:1
(defun |c/start_mode| (arg-v-solver-3901)
 (declare  (type c-address arg-v-solver-3901))
 (let ((v-solver-3901 0))
 (declare (type c-address v-solver-3901) (ignorable v-solver-3901))
 (tagbody
    (setf v-solver-3901 arg-v-solver-3901)
    (unless (c-true (m-u8 (+ v-solver-3901 6))) (go ELSE3902))
    (progn (|c/start_profiling| v-solver-3901 (+ (+ v-solver-3901 1472) 120)))
    (progn (|c/report| v-solver-3901 (c-u32 1) 91))
    (progn v-solver-3901)
    (go ENDIF3903)
    ELSE3902
    (progn (|c/start_profiling| v-solver-3901 (+ (+ v-solver-3901 1472) 0)))
    (progn (|c/report| v-solver-3901 (c-u32 1) 123))
    (progn v-solver-3901)
    ENDIF3903
  )
  0))

;;; upstream/satch.c:8062:1
(defun |c/stop_mode| (arg-v-solver-3910)
 (declare  (type c-address arg-v-solver-3910))
 (let ((v-solver-3910 0))
 (declare (type c-address v-solver-3910) (ignorable v-solver-3910))
 (tagbody
    (setf v-solver-3910 arg-v-solver-3910)
    (unless (c-true (m-u8 (+ v-solver-3910 6))) (go ELSE3911))
    (progn (|c/stop_profiling| v-solver-3910 (+ (+ v-solver-3910 1472) 120) (|c/process_time|)))
    (progn v-solver-3910)
    (progn (|c/report| v-solver-3910 (c-u32 1) 93))
    (go ENDIF3912)
    ELSE3911
    (progn (|c/stop_profiling| v-solver-3910 (+ (+ v-solver-3910 1472) 0) (|c/process_time|)))
    (progn v-solver-3910)
    (progn (|c/report| v-solver-3910 (c-u32 1) 125))
    ENDIF3912
  )
  0))

;;; upstream/satch.c:8092:1
(defun |c/switching| (arg-v-solver-3919)
 (declare  (type c-address arg-v-solver-3919))
 (let ((v-solver-3919 0) (v-limits-3920 0))
 (declare (type c-address v-solver-3919) (type c-address v-limits-3920) (ignorable v-solver-3919 v-limits-3920))
 (tagbody
    (setf v-solver-3919 arg-v-solver-3919)
    (setf v-limits-3920 (+ v-solver-3919 720))
    (unless (c-true (if (c-true (m-u64 (+ (+ v-limits-3920 96) 0))) (c-bool (if (<= (m-u64 (+ (+ v-limits-3920 96) 0)) (m-u64 (+ (+ v-solver-3919 1016) 48))) 1 0)) 0)) (go ELSE3921))
    (return-from |c/switching| (c-bool 1))
    ELSE3921
    (return-from |c/switching| (c-bool (if (<= (m-u64 (+ (+ (+ v-limits-3920 96) 8) 0)) (m-u64 (+ (+ v-solver-3919 1016) 360))) 1 0)))
  )
  0))

;;; upstream/satch.c:8101:1
(defun |c/set_new_mode_switching_limit| (arg-v-solver-3923 arg-v-switched-3924)
 (declare  (type c-address arg-v-solver-3923) (type (unsigned-byte 64) arg-v-switched-3924))
 (let ((v-solver-3923 0) (v-switched-3924 0) (v-limits-3925 0) (v-interval-3926 0) (v-count-3927 0) (v-scaled-3928 0))
 (declare (type c-address v-solver-3923) (type (unsigned-byte 64) v-switched-3924) (type c-address v-limits-3925) (type (unsigned-byte 64) v-interval-3926) (type (unsigned-byte 64) v-count-3927) (type (unsigned-byte 64) v-scaled-3928) (ignorable v-solver-3923 v-switched-3924 v-limits-3925 v-interval-3926 v-count-3927 v-scaled-3928))
 (tagbody
    (setf v-solver-3923 arg-v-solver-3923)
    (setf v-switched-3924 arg-v-switched-3924)
    (setf v-limits-3925 (+ v-solver-3923 720))
    (locally (declare (optimize (speed 1))) (setf v-interval-3926 (m-u64 (+ (+ (+ v-limits-3925 96) 8) 8))))
    (locally (declare (optimize (speed 1))) (setf v-count-3927 (c-u64 (truncate (c-u64 (+ v-switched-3924 (c-u64 1))) (c-u64 2)))))
    (locally (declare (optimize (speed 1))) (setf v-scaled-3928 (values (the (unsigned-byte 64) (truncate (|c/scale_interval| v-interval-3926 (function-handle #'|c/quadratic|) v-count-3927))))))
    (progn (setf (m-u64 (+ (+ (+ (+ v-solver-3923 720) 96) 8) 0)) (c-u64 (+ (m-u64 (+ (+ v-solver-3923 1016) 360)) v-scaled-3928))))
    (progn (when (>= (m-u32 (+ v-solver-3923 884)) (c-u32 3)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-3923 (c-u32 3) |c/string/144| v-switched-3924 |c/string/145| (if (c-true (m-u8 (+ v-solver-3923 6))) |c/string/16| |c/string/21|) (m-u64 (+ (+ (+ v-limits-3925 96) 8) 0)) v-scaled-3928))))
  )
  0))

;;; upstream/satch.c:8115:1
(defun |c/mode_ticks_limit_hit| (arg-v-solver-3929 arg-v-switched-3930)
 (declare  (type c-address arg-v-solver-3929) (type (unsigned-byte 64) arg-v-switched-3930))
 (let ((v-solver-3929 0) (v-switched-3930 0))
 (declare (type c-address v-solver-3929) (type (unsigned-byte 64) v-switched-3930) (ignorable v-solver-3929 v-switched-3930))
 (tagbody
    (setf v-solver-3929 arg-v-solver-3929)
    (setf v-switched-3930 arg-v-switched-3930)
    (progn (when (>= (m-u32 (+ v-solver-3929 884)) (c-u32 2)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-3929 (c-u32 2) |c/string/144| v-switched-3930 |c/string/146| (m-u64 (+ (+ (+ (+ v-solver-3929 720) 96) 8) 0)) (m-u64 (+ (+ v-solver-3929 1016) 360))))))
  )
  0))

;;; upstream/satch.c:8123:1
(defun |c/switch_to_focused_mode| (arg-v-solver-3931 arg-v-switched-3932)
 (declare  (type c-address arg-v-solver-3931) (type (unsigned-byte 64) arg-v-switched-3932))
 (let ((v-solver-3931 0) (v-switched-3932 0))
 (declare (type c-address v-solver-3931) (type (unsigned-byte 64) v-switched-3932) (ignorable v-solver-3931 v-switched-3932))
 (tagbody
    (setf v-solver-3931 arg-v-solver-3931)
    (setf v-switched-3932 arg-v-switched-3932)
    (progn (|c/mode_ticks_limit_hit| v-solver-3931 v-switched-3932))
    (progn (setf (m-u8 (+ v-solver-3931 6)) (c-bool 0)))
  )
  0))

;;; upstream/satch.c:8133:1
(defun |c/switch_to_stable_mode| (arg-v-solver-3933 arg-v-switched-3934)
 (declare  (type c-address arg-v-solver-3933) (type (unsigned-byte 64) arg-v-switched-3934))
 (let ((v-solver-3933 0) (v-switched-3934 0) (v-limits-3935 0))
 (declare (type c-address v-solver-3933) (type (unsigned-byte 64) v-switched-3934) (type c-address v-limits-3935) (ignorable v-solver-3933 v-switched-3934 v-limits-3935))
 (tagbody
    (setf v-solver-3933 arg-v-solver-3933)
    (setf v-switched-3934 arg-v-switched-3934)
    (setf v-limits-3935 (+ v-solver-3933 720))
    (unless (c-true (m-u64 (+ (+ v-limits-3935 96) 0))) (go ELSE3936))
    (progn (when (>= (m-u32 (+ v-solver-3933 884)) (c-u32 2)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-3933 (c-u32 2) |c/string/144| v-switched-3934 |c/string/147| (m-u64 (+ (+ v-limits-3935 96) 0)) (m-u64 (+ (+ v-solver-3933 1016) 48)) (m-u64 (+ (+ v-solver-3933 1016) 360))))))
    (progn (setf (m-u64 (+ (+ (+ v-limits-3935 96) 8) 8)) (m-u64 (+ (+ v-solver-3933 1016) 360))))
    (progn (setf (m-u64 (+ (+ v-limits-3935 96) 0)) (c-u64 0)))
    (go ENDIF3937)
    ELSE3936
    (progn (|c/mode_ticks_limit_hit| v-solver-3933 v-switched-3934))
    ENDIF3937
    (progn (setf (m-u8 (+ v-solver-3933 6)) (c-bool 1)))
    (progn (setf (m-u64 (+ (+ v-solver-3933 864) 0)) (setf (m-u64 (+ (+ v-solver-3933 864) 8)) (c-u64 1))))
    (progn (setf (m-u64 (+ (+ v-solver-3933 720) 88)) (c-u64 (+ (m-u64 (+ (+ v-solver-3933 1016) 48)) (c-u64 1024)))))
    (progn v-solver-3933)
    (progn (setf (m-u32 (+ v-solver-3933 72)) (c-u32 0)))
  )
  0))

;;; upstream/satch.c:8167:1
(defun |c/switch_mode| (arg-v-solver-3941)
 (declare  (type c-address arg-v-solver-3941))
 (let ((v-solver-3941 0) (v-switched-3942 0) (v-a-3949 0))
 (declare (type c-address v-solver-3941) (type (unsigned-byte 64) v-switched-3942) (type c-address v-a-3949) (ignorable v-solver-3941 v-switched-3942 v-a-3949))
 (tagbody
    (setf v-solver-3941 arg-v-solver-3941)
    (progn (|c/stop_mode| v-solver-3941))
    (locally (declare (optimize (speed 1))) (setf v-switched-3942 (progn 0 (let* ((a3943 (+ (+ v-solver-3941 1016) 328)) (old3944 (m-u64 a3943))) (setf (m-u64 a3943) (c-u64 (c-u64 (+ old3944 (c-u64 1))))) (m-u64 a3943)))))
    (unless (c-true (m-u32 (+ v-solver-3941 8))) (go ELSE3945))
    (progn (|c/backtrack| v-solver-3941 (c-u32 0)))
    (go ENDIF3946)
    ELSE3945
    ENDIF3946
    (unless (c-true (m-u8 (+ v-solver-3941 6))) (go ELSE3947))
    (progn (|c/switch_to_focused_mode| v-solver-3941 v-switched-3942))
    (go ENDIF3948)
    ELSE3947
    (progn (|c/switch_to_stable_mode| v-solver-3941 v-switched-3942))
    ENDIF3948
    (setf v-a-3949 (|c/averages| v-solver-3941))
    (progn (setf (m-u64 (+ v-a-3949 40)) (m-u64 (+ (+ v-solver-3941 1016) 64))))
    (progn (|c/set_new_mode_switching_limit| v-solver-3941 v-switched-3942))
    (progn (|c/start_mode| v-solver-3941))
  )
  0))

;;; upstream/satch.c:8203:1
(defun |c/more_elimination_candidates| (arg-v-solver-3950)
 (declare  (type c-address arg-v-solver-3950))
 (let ((v-solver-3950 0))
 (declare (type c-address v-solver-3950) (ignorable v-solver-3950))
 (tagbody
    (setf v-solver-3950 arg-v-solver-3950)
    (return-from |c/more_elimination_candidates| (c-bool (if (> (m-u64 (+ (+ v-solver-3950 1016) 136)) (m-u64 (+ (+ (+ v-solver-3950 720) 0) 16))) 1 0)))
  )
  0))

;;; upstream/satch.c:8212:1
(defun |c/more_subsumption_candidates| (arg-v-solver-3951)
 (declare  (type c-address arg-v-solver-3951))
 (let ((v-solver-3951 0))
 (declare (type c-address v-solver-3951) (ignorable v-solver-3951))
 (tagbody
    (setf v-solver-3951 arg-v-solver-3951)
    (return-from |c/more_subsumption_candidates| (c-bool (if (> (m-u64 (+ (+ v-solver-3951 1016) 144)) (m-u64 (+ (+ (+ v-solver-3951 720) 120) 0))) 1 0)))
  )
  0))

;;; upstream/satch.c:8220:1
(defun |c/eliminating| (arg-v-solver-3952)
 (declare  (type c-address arg-v-solver-3952))
 (let ((v-solver-3952 0))
 (declare (type c-address v-solver-3952) (ignorable v-solver-3952))
 (tagbody
    (setf v-solver-3952 arg-v-solver-3952)
    (unless (c-true (if (c-true (|c/more_elimination_candidates| v-solver-3952)) 0 1)) (go ELSE3953))
    (unless (c-true (if (c-true (|c/more_subsumption_candidates| v-solver-3952)) 0 1)) (go ELSE3955))
    (return-from |c/eliminating| (c-bool 0))
    ELSE3955
    (go ENDIF3954)
    ELSE3953
    ENDIF3954
    (return-from |c/eliminating| (c-bool (if (< (m-u64 (+ (+ (+ v-solver-3952 720) 0) 0)) (m-u64 (+ (+ v-solver-3952 1016) 48))) 1 0)))
  )
  0))

;;; upstream/satch.c:8258:1
(defun |c/flush_redundant_watches| (arg-v-solver-3957 arg-v-new_fixed-3958)
 (declare  (type c-address arg-v-solver-3957) (type (integer 0 1) arg-v-new_fixed-3958))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-3957 0) (v-new_fixed-3958 0) (v-flags-3959 0) (v-lit-3963 0) (v-END_LITERALS-3964 0) (v-watches-3965 0) (v-end-3966 0) (v-q-3967 0) (v-p-3968 0) (v-lit_active-3969 0) (v-header-3973 (stack-alloc 8)) (v-other-3976 0) (v-redundant-3977 0) (v-other_active-3978 0) (v-old_size-3993 0) (v-old_capacity-3994 0) (v-new_capacity-3995 0) (v-new_bytes-3996 0) (v-old_size-4009 0) (v-old_capacity-4010 0) (v-new_capacity-4011 0) (v-new_bytes-4012 0) (v-c-4023 0))
 (declare (type c-address v-solver-3957) (type (integer 0 1) v-new_fixed-3958) (type c-address v-flags-3959) (type (unsigned-byte 32) v-lit-3963) (type (unsigned-byte 32) v-END_LITERALS-3964) (type c-address v-watches-3965) (type c-address v-end-3966) (type c-address v-q-3967) (type c-address v-p-3968) (type (integer 0 1) v-lit_active-3969) (type c-address v-header-3973) (type (unsigned-byte 32) v-other-3976) (type (integer 0 1) v-redundant-3977) (type (integer 0 1) v-other_active-3978) (type c-size v-old_size-3993) (type c-size v-old_capacity-3994) (type c-size v-new_capacity-3995) (type c-size v-new_bytes-3996) (type c-size v-old_size-4009) (type c-size v-old_capacity-4010) (type c-size v-new_capacity-4011) (type c-size v-new_bytes-4012) (type c-address v-c-4023) (ignorable v-solver-3957 v-new_fixed-3958 v-flags-3959 v-lit-3963 v-END_LITERALS-3964 v-watches-3965 v-end-3966 v-q-3967 v-p-3968 v-lit_active-3969 v-header-3973 v-other-3976 v-redundant-3977 v-other_active-3978 v-old_size-3993 v-old_capacity-3994 v-new_capacity-3995 v-new_bytes-3996 v-old_size-4009 v-old_capacity-4010 v-new_capacity-4011 v-new_bytes-4012 v-c-4023))
 (tagbody
    (setf v-solver-3957 arg-v-solver-3957)
    (setf v-new_fixed-3958 arg-v-new_fixed-3958)
    (setf v-flags-3959 (m-ptr (+ v-solver-3957 48)))
    (setf v-lit-3963 (c-u32 0))
    (setf v-END_LITERALS-3964 (c-u32 (* 2 (m-u32 (+ v-solver-3957 12)))))
    LOOP3960
    (unless (c-true (if (< v-lit-3963 v-END_LITERALS-3964) 1 0)) (go ENDLOOP3961))
    (setf v-watches-3965 (+ (m-ptr (+ v-solver-3957 544)) (* 24 v-lit-3963)))
    (setf v-end-3966 (m-ptr (+ v-watches-3965 8)))
    (setf v-q-3967 (m-ptr (+ v-watches-3965 0)))
    (setf v-p-3968 v-q-3967)
    (setf v-lit_active-3969 (c-bool (if (c-true v-new_fixed-3958) 1 (ldb (byte 1 0) (m-u8 (+ (+ v-flags-3959 (* 4 (|c/INDEX| v-lit-3963))) 0))))))
    LOOP3970
    (unless (c-true (if (/= v-p-3968 v-end-3966) 1 0)) (go ENDLOOP3971))
    (copy-bytes v-header-3973 (+ v-p-3968 0) 8)
    (unless (c-true (m-u8 (+ v-header-3973 0))) (go ELSE3974))
    (setf v-other-3976 (m-u32 (+ v-header-3973 4)))
    (setf v-redundant-3977 (c-bool (m-u8 (+ v-header-3973 1))))
    (setf v-other_active-3978 (c-bool (if (c-true v-new_fixed-3958) 1 (ldb (byte 1 0) (m-u8 (+ (+ v-flags-3959 (* 4 (|c/INDEX| v-other-3976))) 0))))))
    (unless (c-true (if (c-true v-lit_active-3969) (c-bool v-other_active-3978) 0)) (go ELSE3979))
    (unless (c-true (m-u8 (+ v-header-3973 1))) (go ELSE3981))
    (unless (c-true (if (< v-lit-3963 v-other-3976) 1 0)) (go ELSE3983))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-3957 472) 8)) (m-ptr (+ (+ v-solver-3957 472) 16))) 1 0)) (go ELSE3988))
    (setf v-old_size-3993 (the c-size (truncate (- (m-ptr (+ (+ v-solver-3957 472) 8)) (m-ptr (+ (+ v-solver-3957 472) 0))) 4)))
    (setf v-old_capacity-3994 (the c-size (truncate (- (m-ptr (+ (+ v-solver-3957 472) 16)) (m-ptr (+ (+ v-solver-3957 472) 0))) 4)))
    (setf v-new_capacity-3995 (if (c-true v-old_capacity-3994) (c-u64 (* (c-u64 2) v-old_capacity-3994)) (c-u64 1)))
    (setf v-new_bytes-3996 (c-u64 (* v-new_capacity-3995 4)))
    (progn (setf (m-ptr (+ (+ v-solver-3957 472) 0)) (c-realloc (m-ptr (+ (+ v-solver-3957 472) 0)) v-new_bytes-3996)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-3957 472) 0))) 0 1)) (go ELSE3997))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-3996))
    (go ENDIF3998)
    ELSE3997
    ENDIF3998
    (progn (setf (m-ptr (+ (+ v-solver-3957 472) 8)) (+ (m-ptr (+ (+ v-solver-3957 472) 0)) (* 4 v-old_size-3993))))
    (progn (setf (m-ptr (+ (+ v-solver-3957 472) 16)) (+ (m-ptr (+ (+ v-solver-3957 472) 0)) (* 4 v-new_capacity-3995))))
    (go ENDIF3989)
    ELSE3988
    ENDIF3989
    (progn (setf (m-u32 (let* ((a3999 (+ (+ v-solver-3957 472) 8)) (old4000 (m-ptr a3999))) (setf (m-ptr a3999) (+ old4000 (* 4 1))) old4000)) v-lit-3963))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-3957 472) 8)) (m-ptr (+ (+ v-solver-3957 472) 16))) 1 0)) (go ELSE4004))
    (setf v-old_size-4009 (the c-size (truncate (- (m-ptr (+ (+ v-solver-3957 472) 8)) (m-ptr (+ (+ v-solver-3957 472) 0))) 4)))
    (setf v-old_capacity-4010 (the c-size (truncate (- (m-ptr (+ (+ v-solver-3957 472) 16)) (m-ptr (+ (+ v-solver-3957 472) 0))) 4)))
    (setf v-new_capacity-4011 (if (c-true v-old_capacity-4010) (c-u64 (* (c-u64 2) v-old_capacity-4010)) (c-u64 1)))
    (setf v-new_bytes-4012 (c-u64 (* v-new_capacity-4011 4)))
    (progn (setf (m-ptr (+ (+ v-solver-3957 472) 0)) (c-realloc (m-ptr (+ (+ v-solver-3957 472) 0)) v-new_bytes-4012)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-3957 472) 0))) 0 1)) (go ELSE4013))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-4012))
    (go ENDIF4014)
    ELSE4013
    ENDIF4014
    (progn (setf (m-ptr (+ (+ v-solver-3957 472) 8)) (+ (m-ptr (+ (+ v-solver-3957 472) 0)) (* 4 v-old_size-4009))))
    (progn (setf (m-ptr (+ (+ v-solver-3957 472) 16)) (+ (m-ptr (+ (+ v-solver-3957 472) 0)) (* 4 v-new_capacity-4011))))
    (go ENDIF4005)
    ELSE4004
    ENDIF4005
    (progn (setf (m-u32 (let* ((a4015 (+ (+ v-solver-3957 472) 8)) (old4016 (m-ptr a4015))) (setf (m-ptr a4015) (+ old4016 (* 4 1))) old4016)) v-other-3976))
    (go ENDIF3984)
    ELSE3983
    ENDIF3984
    (go ENDIF3982)
    ELSE3981
    (progn (setf (m-ptr (+ (let* ( (old4018 v-q-3967)) (setf v-q-3967 (+ old4018 (* 8 1))) old4018) 0)) (|c/tag_binary_clause| (c-bool 0) v-other-3976)))
    ENDIF3982
    (go ENDIF3980)
    ELSE3979
    (progn (|c/delete_binary| v-solver-3957 (c-bool v-redundant-3977) v-lit-3963 v-other-3976))
    ENDIF3980
    (progn (let* ( (old4020 v-p-3968)) (setf v-p-3968 (+ old4020 (* 8 1))) old4020))
    (go ENDIF3975)
    ELSE3974
    (unless (c-true (if (c-true (m-u8 (+ v-header-3973 1))) 0 1)) (go ELSE4021))
    (setf v-c-4023 (m-ptr (+ (+ v-p-3968 (* 8 1)) 0)))
    (unless (c-true (if (c-true (if (c-true v-new_fixed-3958) 0 1)) 1 (c-bool (if (c-true (ldb (byte 1 0) (m-u8 (+ v-c-4023 0)))) 0 1)))) (go ELSE4024))
    (progn (setf (m-ptr (+ (let* ( (old4027 v-q-3967)) (setf v-q-3967 (+ old4027 (* 8 1))) old4027) 0)) v-c-4023))
    (go ENDIF4025)
    ELSE4024
    ENDIF4025
    (go ENDIF4022)
    ELSE4021
    ENDIF4022
    (progn (setf v-p-3968 (+ v-p-3968 (* 8 2))))
    ENDIF3975
    (go LOOP3970)
    ENDLOOP3971
    (progn (setf (m-ptr (+ v-watches-3965 8)) v-q-3967))
    (unless (c-true (if (= (m-ptr (+ v-watches-3965 8)) (m-ptr (+ v-watches-3965 0))) 1 0)) (go ELSE4029))
    (progn (c-free (m-ptr (+ v-watches-3965 0))))
    (progn (setf (m-ptr (+ v-watches-3965 0)) (setf (m-ptr (+ v-watches-3965 8)) (setf (m-ptr (+ v-watches-3965 16)) 0))))
    (go ENDIF4030)
    ELSE4029
    ENDIF4030
    (let* ( (old4035 v-lit-3963)) (setf v-lit-3963 (c-u32 (c-u32 (+ old4035 (c-u32 1))))) old4035)
    (go LOOP3960)
    ENDLOOP3961
    (progn v-solver-3957)
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:8372:1
(defun |c/connect_occurrences_in_irredundant_clauses| (arg-v-solver-4039)
 (declare  (type c-address arg-v-solver-4039))
 (let ((v-solver-4039 0) (v-c-4043 0) (v-PTR_c-4044 0) (v-END_c-4045 0) (v-lits-4046 0) (v-end-4047 0) (v-p-4051 0))
 (declare (type c-address v-solver-4039) (type c-address v-c-4043) (type c-address v-PTR_c-4044) (type c-address v-END_c-4045) (type c-address v-lits-4046) (type c-address v-end-4047) (type c-address v-p-4051) (ignorable v-solver-4039 v-c-4043 v-PTR_c-4044 v-END_c-4045 v-lits-4046 v-end-4047 v-p-4051))
 (tagbody
    (setf v-solver-4039 arg-v-solver-4039)
    (setf v-PTR_c-4044 (m-ptr (+ (+ v-solver-4039 672) 0)))
    (setf v-END_c-4045 (m-ptr (+ (+ v-solver-4039 672) 8)))
    LOOP4040
    (unless (c-true (if (c-true (if (/= v-PTR_c-4044 v-END_c-4045) 1 0)) (c-bool (progn (setf v-c-4043 (m-ptr v-PTR_c-4044)) 1)) 0)) (go ENDLOOP4041))
    (setf v-lits-4046 (+ v-c-4043 16))
    (setf v-end-4047 (+ v-lits-4046 (* 4 (m-u32 (+ v-c-4043 12)))))
    (setf v-p-4051 (+ v-lits-4046 (* 4 2)))
    LOOP4048
    (unless (c-true (if (/= v-p-4051 v-end-4047) 1 0)) (go ENDLOOP4049))
    (unless (c-true (if (c-true (ldb (byte 1 0) (m-u8 (+ v-c-4043 0)))) 0 1)) (go ELSE4052))
    (progn (|c/connect_literal| v-solver-4039 (m-u32 v-p-4051) v-c-4043))
    (go ENDIF4053)
    ELSE4052
    ENDIF4053
    (let* ( (old4055 v-p-4051)) (setf v-p-4051 (+ old4055 (* 4 1))) old4055)
    (go LOOP4048)
    ENDLOOP4049
    (let* ( (old4057 v-PTR_c-4044)) (setf v-PTR_c-4044 (+ old4057 (* 8 1))) v-PTR_c-4044)
    (go LOOP4040)
    ENDLOOP4041
  )
  0))

;;; upstream/satch.c:8386:1
(defun |c/switch_to_dense_mode| (arg-v-solver-4058)
 (declare  (type c-address arg-v-solver-4058))
 (let ((v-solver-4058 0) (v-new_fixed-4062 0))
 (declare (type c-address v-solver-4058) (type (integer 0 1) v-new_fixed-4062) (ignorable v-solver-4058 v-new_fixed-4062))
 (tagbody
    (setf v-solver-4058 arg-v-solver-4058)
    (progn v-solver-4058)
    (setf v-new_fixed-4062 (c-bool (if (< (m-u64 (+ (+ (+ v-solver-4058 720) 0) 8)) (m-u64 (+ (+ v-solver-4058 1016) 104))) 1 0)))
    (unless (c-true v-new_fixed-4062) (go ELSE4063))
    (progn (|c/mark_irredundant_clauses_as_garbage_if_satisfied| v-solver-4058))
    (go ENDIF4064)
    ELSE4063
    ENDIF4064
    (progn (|c/flush_redundant_watches| v-solver-4058 (c-bool v-new_fixed-4062)))
    (progn (setf (m-u8 (+ v-solver-4058 7)) (c-bool 1)))
    (progn (|c/connect_occurrences_in_irredundant_clauses| v-solver-4058))
  )
  0))

;;; upstream/satch.c:8406:1
(defun |c/disconnect_all_clauses| (arg-v-solver-4065)
 (declare  (type c-address arg-v-solver-4065))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-4065 0) (v-flags-4066 0) (v-lit-4070 0) (v-END_LITERALS-4071 0) (v-watches-4072 0) (v-end-4073 0) (v-q-4074 0) (v-c-4075 0) (v-lit_eliminated-4076 0) (v-p-4080 0) (v-other-4083 0) (v-other_eliminated-4084 0) (v-watch-4087 (stack-alloc 8)))
 (declare (type c-address v-solver-4065) (type c-address v-flags-4066) (type (unsigned-byte 32) v-lit-4070) (type (unsigned-byte 32) v-END_LITERALS-4071) (type c-address v-watches-4072) (type c-address v-end-4073) (type c-address v-q-4074) (type c-address v-c-4075) (type (integer 0 1) v-lit_eliminated-4076) (type c-address v-p-4080) (type (unsigned-byte 32) v-other-4083) (type (integer 0 1) v-other_eliminated-4084) (type c-address v-watch-4087) (ignorable v-solver-4065 v-flags-4066 v-lit-4070 v-END_LITERALS-4071 v-watches-4072 v-end-4073 v-q-4074 v-c-4075 v-lit_eliminated-4076 v-p-4080 v-other-4083 v-other_eliminated-4084 v-watch-4087))
 (tagbody
    (setf v-solver-4065 arg-v-solver-4065)
    (setf v-flags-4066 (m-ptr (+ v-solver-4065 48)))
    (setf v-lit-4070 (c-u32 0))
    (setf v-END_LITERALS-4071 (c-u32 (* 2 (m-u32 (+ v-solver-4065 12)))))
    LOOP4067
    (unless (c-true (if (< v-lit-4070 v-END_LITERALS-4071) 1 0)) (go ENDLOOP4068))
    (setf v-watches-4072 (+ (m-ptr (+ v-solver-4065 544)) (* 24 v-lit-4070)))
    (setf v-end-4073 (m-ptr (+ v-watches-4072 8)))
    (setf v-q-4074 (m-ptr (+ v-watches-4072 0)))
    (setf v-lit_eliminated-4076 (c-bool (ldb (byte 1 2) (m-u8 (+ (+ v-flags-4066 (* 4 (|c/INDEX| v-lit-4070))) 0)))))
    (setf v-p-4080 v-q-4074)
    LOOP4077
    (unless (c-true (if (/= v-p-4080 v-end-4073) 1 0)) (go ENDLOOP4078))
    (unless (c-true (|c/is_tagged_clause| (setf v-c-4075 (m-ptr (+ v-p-4080 0))))) (go ELSE4081))
    (setf v-other-4083 (|c/tagged_clause_to_literal| v-c-4075))
    (setf v-other_eliminated-4084 (c-bool (ldb (byte 1 2) (m-u8 (+ (+ v-flags-4066 (* 4 (|c/INDEX| v-other-4083))) 0)))))
    (unless (c-true (if (c-true (if (c-true v-lit_eliminated-4076) 0 1)) (c-bool (if (c-true v-other_eliminated-4084) 0 1)) 0)) (go ELSE4085))
    (progn (setf (m-u8 (+ (+ v-watch-4087 0) 0)) (c-bool 1)))
    (progn (setf (m-u8 (+ (+ v-watch-4087 0) 1)) (c-bool 0)))
    (progn (setf (m-u32 (+ (+ v-watch-4087 0) 4)) v-other-4083))
    (progn (copy-bytes (let* ( (old4089 v-q-4074)) (setf v-q-4074 (+ old4089 (* 8 1))) old4089) v-watch-4087 8))
    (go ENDIF4086)
    ELSE4085
    (progn (|c/delete_binary| v-solver-4065 (c-bool 0) v-lit-4070 v-other-4083))
    ENDIF4086
    (go ENDIF4082)
    ELSE4081
    ENDIF4082
    (let* ( (old4091 v-p-4080)) (setf v-p-4080 (+ old4091 (* 8 1))) old4091)
    (go LOOP4077)
    ENDLOOP4078
    (progn (setf (m-ptr (+ v-watches-4072 8)) v-q-4074))
    (let* ( (old4093 v-lit-4070)) (setf v-lit-4070 (c-u32 (c-u32 (+ old4093 (c-u32 1))))) old4093)
    (go LOOP4067)
    ENDLOOP4068
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:8452:1
(defun |c/watch_saved_redundant_binaries| (arg-v-solver-4094)
 (declare  (type c-address arg-v-solver-4094))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-4094 0) (v-begin-4095 0) (v-end-4096 0) (v-flags-4097 0) (v-p-4101 0) (v-i-4102 (stack-alloc 8)) (v-f-4103 (stack-alloc 8)) (v-eliminated-4104 (stack-alloc 2)))
 (declare (type c-address v-solver-4094) (type c-address v-begin-4095) (type c-address v-end-4096) (type c-address v-flags-4097) (type c-address v-p-4101) (type c-address v-i-4102) (type c-address v-f-4103) (type c-address v-eliminated-4104) (ignorable v-solver-4094 v-begin-4095 v-end-4096 v-flags-4097 v-p-4101 v-i-4102 v-f-4103 v-eliminated-4104))
 (tagbody
    (setf v-solver-4094 arg-v-solver-4094)
    (setf v-begin-4095 (m-ptr (+ (+ v-solver-4094 472) 0)))
    (setf v-end-4096 (m-ptr (+ (+ v-solver-4094 472) 8)))
    (setf v-flags-4097 (m-ptr (+ v-solver-4094 48)))
    (setf v-p-4101 v-begin-4095)
    LOOP4098
    (unless (c-true (if (/= v-p-4101 v-end-4096) 1 0)) (go ENDLOOP4099))
    (c-memset v-i-4102 0 8)
    (setf (m-u32 (+ v-i-4102 0)) (|c/INDEX| (m-u32 (+ v-p-4101 (* 4 0)))))
    (setf (m-u32 (+ v-i-4102 4)) (|c/INDEX| (m-u32 (+ v-p-4101 (* 4 1)))))
    (c-memset v-f-4103 0 8)
    (copy-bytes (+ v-f-4103 0) (+ v-flags-4097 (* 4 (m-u32 (+ v-i-4102 (* 4 0))))) 4)
    (copy-bytes (+ v-f-4103 4) (+ v-flags-4097 (* 4 (m-u32 (+ v-i-4102 (* 4 1))))) 4)
    (c-memset v-eliminated-4104 0 2)
    (setf (m-u8 (+ v-eliminated-4104 0)) (c-bool (ldb (byte 1 2) (m-u8 (+ (+ v-f-4103 (* 4 0)) 0)))))
    (setf (m-u8 (+ v-eliminated-4104 1)) (c-bool (ldb (byte 1 2) (m-u8 (+ (+ v-f-4103 (* 4 1)) 0)))))
    (unless (c-true (if (c-true (if (c-true (m-u8 (+ v-eliminated-4104 (* 1 0)))) 0 1)) (c-bool (if (c-true (m-u8 (+ v-eliminated-4104 (* 1 1)))) 0 1)) 0)) (go ELSE4105))
    (progn (|c/watch_binary| v-solver-4094 (c-bool 1) (m-u32 (+ v-p-4101 (* 4 0))) (m-u32 (+ v-p-4101 (* 4 1)))))
    (progn (|c/watch_binary| v-solver-4094 (c-bool 1) (m-u32 (+ v-p-4101 (* 4 1))) (m-u32 (+ v-p-4101 (* 4 0)))))
    (go ENDIF4106)
    ELSE4105
    (progn (|c/delete_binary| v-solver-4094 (c-bool 1) (m-u32 (+ v-p-4101 (* 4 0))) (m-u32 (+ v-p-4101 (* 4 1)))))
    ENDIF4106
    (setf v-p-4101 (+ v-p-4101 (* 4 2)))
    (go LOOP4098)
    ENDLOOP4099
    (progn (setf (m-ptr (+ (+ v-solver-4094 472) 8)) (m-ptr (+ (+ v-solver-4094 472) 0))))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:8476:1
(defun |c/watch_clauses| (arg-v-solver-4111 arg-v-clauses-4112)
 (declare  (type c-address arg-v-solver-4111) (type c-address arg-v-clauses-4112))
 (let ((v-solver-4111 0) (v-clauses-4112 0) (v-c-4116 0) (v-PTR_c-4117 0) (v-END_c-4118 0))
 (declare (type c-address v-solver-4111) (type c-address v-clauses-4112) (type c-address v-c-4116) (type c-address v-PTR_c-4117) (type c-address v-END_c-4118) (ignorable v-solver-4111 v-clauses-4112 v-c-4116 v-PTR_c-4117 v-END_c-4118))
 (tagbody
    (setf v-solver-4111 arg-v-solver-4111)
    (setf v-clauses-4112 arg-v-clauses-4112)
    (setf v-PTR_c-4117 (m-ptr (+ v-clauses-4112 0)))
    (setf v-END_c-4118 (m-ptr (+ v-clauses-4112 8)))
    LOOP4113
    (unless (c-true (if (c-true (if (/= v-PTR_c-4117 v-END_c-4118) 1 0)) (c-bool (progn (setf v-c-4116 (m-ptr v-PTR_c-4117)) 1)) 0)) (go ENDLOOP4114))
    (progn (|c/watch_clause| v-solver-4111 v-c-4116))
    (let* ( (old4120 v-PTR_c-4117)) (setf v-PTR_c-4117 (+ old4120 (* 8 1))) v-PTR_c-4117)
    (go LOOP4113)
    ENDLOOP4114
  )
  0))

;;; upstream/satch.c:8483:1
(defun |c/switch_to_sparse_mode| (arg-v-solver-4121)
 (declare  (type c-address arg-v-solver-4121))
 (let ((v-solver-4121 0))
 (declare (type c-address v-solver-4121) (ignorable v-solver-4121))
 (tagbody
    (setf v-solver-4121 arg-v-solver-4121)
    (progn v-solver-4121)
    (progn (|c/disconnect_all_clauses| v-solver-4121))
    (progn (setf (m-u8 (+ v-solver-4121 7)) (c-bool 0)))
    (progn (|c/watch_saved_redundant_binaries| v-solver-4121))
    (progn (|c/watch_clauses| v-solver-4121 (+ v-solver-4121 672)))
    (progn (|c/watch_clauses| v-solver-4121 (+ v-solver-4121 696)))
  )
  0))

;;; upstream/satch.c:8501:1
(defun |c/clause_eliminated| (arg-v-solver-4125 arg-v-c-4126)
 (declare  (type c-address arg-v-solver-4125) (type c-address arg-v-c-4126))
 (let ((v-solver-4125 0) (v-c-4126 0) (v-flags-4127 0) (v-lit-4131 0) (v-P_lit-4132 0) (v-END_lit-4133 0))
 (declare (type c-address v-solver-4125) (type c-address v-c-4126) (type c-address v-flags-4127) (type (unsigned-byte 32) v-lit-4131) (type c-address v-P_lit-4132) (type c-address v-END_lit-4133) (ignorable v-solver-4125 v-c-4126 v-flags-4127 v-lit-4131 v-P_lit-4132 v-END_lit-4133))
 (tagbody
    (setf v-solver-4125 arg-v-solver-4125)
    (setf v-c-4126 arg-v-c-4126)
    (setf v-flags-4127 (m-ptr (+ v-solver-4125 48)))
    (setf v-P_lit-4132 (+ v-c-4126 16))
    (setf v-END_lit-4133 (+ v-P_lit-4132 (* 4 (m-u32 (+ v-c-4126 12)))))
    LOOP4128
    (unless (c-true (if (c-true (if (/= v-P_lit-4132 v-END_lit-4133) 1 0)) (c-bool (progn (setf v-lit-4131 (m-u32 v-P_lit-4132)) 1)) 0)) (go ENDLOOP4129))
    (unless (c-true (ldb (byte 1 2) (m-u8 (+ (+ v-flags-4127 (* 4 (|c/INDEX| v-lit-4131))) 0)))) (go ELSE4134))
    (return-from |c/clause_eliminated| (c-bool 1))
    ELSE4134
    (let* ( (old4137 v-P_lit-4132)) (setf v-P_lit-4132 (+ old4137 (* 4 1))) v-P_lit-4132)
    (go LOOP4128)
    ENDLOOP4129
    (return-from |c/clause_eliminated| (c-bool 0))
  )
  0))

