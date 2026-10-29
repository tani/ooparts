(in-package #:ooparts/sat/impl)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))
;;; upstream/satch.c:12378:1
(defun |c/satch_stop_profiling_parsing| (arg-v-solver-7177)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-solver-7177))
 (let ((v-solver-7177 0))
 (declare (type c-address v-solver-7177) (ignorable v-solver-7177))
 (tagbody
    (setf v-solver-7177 arg-v-solver-7177)
    (unless (c-true (if (c-true v-solver-7177) 0 1)) (go ELSE7181))
    (progn (|c/invalid_usage| |c/string/180| |c/string/206|))
    (go ENDIF7182)
    ELSE7181
    ENDIF7182
    (return-from |c/satch_stop_profiling_parsing| (|c/stop_profiling| v-solver-7177 (+ (+ v-solver-7177 1472) 48) (|c/process_time|)))
  )
  0))

;;; upstream/satch.c:12385:1
(defun |c/satch_section| (arg-v-solver-7183 arg-v-name-7184)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-solver-7183) (type c-address arg-v-name-7184))
 (let ((v-solver-7183 0) (v-name-7184 0))
 (declare (type c-address v-solver-7183) (type c-address v-name-7184) (ignorable v-solver-7183 v-name-7184))
 (tagbody
    (setf v-solver-7183 arg-v-solver-7183)
    (setf v-name-7184 arg-v-name-7184)
    (unless (c-true (if (c-true v-solver-7183) 0 1)) (go ELSE7188))
    (progn (|c/invalid_usage| |c/string/180| |c/string/207|))
    (go ENDIF7189)
    ELSE7188
    ENDIF7189
    (progn (|c/internal_section| v-solver-7183 v-name-7184))
  )
  0))

;;; upstream/satch.c:12392:1
(defun |c/satch_statistics| (arg-v-solver-7190)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-solver-7190))
 (let ((v-solver-7190 0) (v-stop-7196 0d0))
 (declare (type c-address v-solver-7190) (type double-float v-stop-7196) (ignorable v-solver-7190 v-stop-7196))
 (tagbody
    (setf v-solver-7190 arg-v-solver-7190)
    (unless (c-true (if (c-true v-solver-7190) 0 1)) (go ELSE7194))
    (progn (|c/invalid_usage| |c/string/180| |c/string/208|))
    (go ENDIF7195)
    ELSE7194
    ENDIF7195
    (setf v-stop-7196 (|c/print_profiles| v-solver-7190))
    (progn (|c/print_statistics| v-solver-7190 v-stop-7196))
    (progn (|c/print_resource_usage| v-solver-7190 v-stop-7196))
  )
  0))

;;; upstream/satch.c:12401:1
(defun |c/satch_conflicts| (arg-v-solver-7197)
 (declare  (type c-address arg-v-solver-7197))
 (let ((v-solver-7197 0) (v-conflicts-7203 0))
 (declare (type c-address v-solver-7197) (type (unsigned-byte 64) v-conflicts-7203) (ignorable v-solver-7197 v-conflicts-7203))
 (tagbody
    (setf v-solver-7197 arg-v-solver-7197)
    (unless (c-true (if (c-true v-solver-7197) 0 1)) (go ELSE7201))
    (progn (|c/invalid_usage| |c/string/180| |c/string/209|))
    (go ENDIF7202)
    ELSE7201
    ENDIF7202
    (locally (declare (optimize (speed 1))) (setf v-conflicts-7203 (m-u64 (+ (+ v-solver-7197 1016) 48))))
    (return-from |c/satch_conflicts| (c-s32 (if (c-true (if (> v-conflicts-7203 (c-u64 2147483647)) 1 0)) (c-u64 2147483647) v-conflicts-7203)))
  )
  0))
