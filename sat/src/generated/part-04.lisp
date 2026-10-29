(in-package #:ooparts/sat/impl)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))
;;; upstream/satch.c:3421:1
(defun |c/disconnect_literal| (arg-v-solver-902 arg-v-lit-903 arg-v-c-904)
 (declare  (type c-address arg-v-solver-902) (type (unsigned-byte 32) arg-v-lit-903) (type c-address arg-v-c-904))
 (let ((v-solver-902 0) (v-lit-903 0) (v-c-904 0) (v-watches-905 0) (v-end-906 0) (v-q-907 0))
 (declare (type c-address v-solver-902) (type (unsigned-byte 32) v-lit-903) (type c-address v-c-904) (type c-address v-watches-905) (type c-address v-end-906) (type c-address v-q-907) (ignorable v-solver-902 v-lit-903 v-c-904 v-watches-905 v-end-906 v-q-907))
 (tagbody
    (setf v-solver-902 arg-v-solver-902)
    (setf v-lit-903 arg-v-lit-903)
    (setf v-c-904 arg-v-c-904)
    (setf v-watches-905 (+ (m-ptr (+ v-solver-902 544)) (* 24 v-lit-903)))
    (setf v-end-906 (m-ptr (+ v-watches-905 8)))
    (setf v-q-907 (m-ptr (+ v-watches-905 0)))
    LOOP908
    (unless (c-true (progn 0 (if (/= (m-ptr (+ v-q-907 0)) v-c-904) 1 0))) (go ENDLOOP909))
    (progn (let* ( (old912 v-q-907)) (setf v-q-907 (+ old912 (* 8 1))) old912))
    (go LOOP908)
    ENDLOOP909
    LOOP913
    (unless (c-true (if (/= (let* ( (old917 v-q-907)) (setf v-q-907 (+ old917 (* 8 1))) v-q-907) v-end-906) 1 0)) (go ENDLOOP914))
    (progn (copy-bytes (+ v-q-907 (* 8 (c-s32 (- 1)))) v-q-907 8))
    (go LOOP913)
    ENDLOOP914
    (progn (let* ((a918 (+ v-watches-905 8)) (old919 (m-ptr a918))) (setf (m-ptr a918) (- old919 (* 8 1))) old919))
    (unless (c-true (if (= (m-ptr (+ v-watches-905 8)) (m-ptr (+ v-watches-905 0))) 1 0)) (go ELSE920))
    (progn (c-free (m-ptr (+ v-watches-905 0))))
    (progn (setf (m-ptr (+ v-watches-905 0)) (setf (m-ptr (+ v-watches-905 8)) (setf (m-ptr (+ v-watches-905 16)) 0))))
    (go ENDIF921)
    ELSE920
    ENDIF921
  )
  0))

;;; upstream/satch.c:3486:1
(defun |c/assignement_level| (arg-v-solver-925 arg-v-lit-926 arg-v-reason-927)
 (declare  (type c-address arg-v-solver-925) (type (unsigned-byte 32) arg-v-lit-926) (type c-address arg-v-reason-927))
 (let ((v-solver-925 0) (v-lit-926 0) (v-reason-927 0) (v-fullreason-930 0) (v-other-933 0) (v-level-937 0) (v-other-941 0) (v-P_other-942 0) (v-END_other-943 0) (v-tmp-946 0))
 (declare (type c-address v-solver-925) (type (unsigned-byte 32) v-lit-926) (type c-address v-reason-927) (type c-address v-fullreason-930) (type (unsigned-byte 32) v-other-933) (type (unsigned-byte 32) v-level-937) (type (unsigned-byte 32) v-other-941) (type c-address v-P_other-942) (type c-address v-END_other-943) (type (unsigned-byte 32) v-tmp-946) (ignorable v-solver-925 v-lit-926 v-reason-927 v-fullreason-930 v-other-933 v-level-937 v-other-941 v-P_other-942 v-END_other-943 v-tmp-946))
 (tagbody
    (setf v-solver-925 arg-v-solver-925)
    (setf v-lit-926 arg-v-lit-926)
    (setf v-reason-927 arg-v-reason-927)
    (unless (c-true (if (c-true (if (c-true v-reason-927) 0 1)) 1 (c-bool (m-u8 (+ v-solver-925 1984))))) (go ELSE928))
    (return-from |c/assignement_level| (m-u32 (+ v-solver-925 8)))
    ELSE928
    (unless (c-true (|c/is_tagged_clause| v-reason-927)) (go ELSE931))
    (setf v-other-933 (|c/tagged_clause_to_literal| v-reason-927))
    (progn v-solver-925)
    (return-from |c/assignement_level| (m-u32 (+ (m-ptr (+ v-solver-925 32)) (* 4 (|c/INDEX| v-other-933)))))
    ELSE931
    (progn (setf v-fullreason-930 v-reason-927))
    (setf v-level-937 (c-u32 0))
    (setf v-P_other-942 (+ v-fullreason-930 16))
    (setf v-END_other-943 (+ v-P_other-942 (* 4 (m-u32 (+ v-fullreason-930 12)))))
    LOOP938
    (unless (c-true (if (c-true (if (/= v-P_other-942 v-END_other-943) 1 0)) (c-bool (progn (setf v-other-941 (m-u32 v-P_other-942)) 1)) 0)) (go ENDLOOP939))
    (unless (c-true (if (= v-other-941 v-lit-926) 1 0)) (go ELSE944))
    (go CONTINUE940)
    ELSE944
    (setf v-tmp-946 (m-u32 (+ (m-ptr (+ v-solver-925 32)) (* 4 (|c/INDEX| v-other-941)))))
    (unless (c-true (if (> v-tmp-946 v-level-937) 1 0)) (go ELSE947))
    (progn (setf v-level-937 v-tmp-946))
    (go ENDIF948)
    ELSE947
    ENDIF948
    CONTINUE940
    (let* ( (old950 v-P_other-942)) (setf v-P_other-942 (+ old950 (* 4 1))) v-P_other-942)
    (go LOOP938)
    ENDLOOP939
    (progn v-solver-925)
    (return-from |c/assignement_level| v-level-937)
  )
  0))

;;; upstream/satch.c:3534:1
(defun |c/assign| (arg-v-solver-954 arg-v-lit-955 arg-v-reason-956 arg-v-known_unit-957)
 (declare (optimize (speed 3)) (type c-address arg-v-solver-954) (type (unsigned-byte 32) arg-v-lit-955) (type c-address arg-v-reason-956) (type (integer 0 1) arg-v-known_unit-957))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-954 0) (v-lit-955 0) (v-reason-956 0) (v-known_unit-957 0) (v-idx-958 0) (v-level-959 0) (v-f-974 0) (v-not_lit-979 0) (v-level-989 (stack-alloc 24)) (v-old_size-998 0) (v-old_capacity-999 0) (v-new_capacity-1000 0) (v-new_bytes-1001 0))
 (declare (type c-address v-solver-954) (type (unsigned-byte 32) v-lit-955) (type c-address v-reason-956) (type (integer 0 1) v-known_unit-957) (type (unsigned-byte 32) v-idx-958) (type (unsigned-byte 32) v-level-959) (type c-address v-f-974) (type (unsigned-byte 32) v-not_lit-979) (type c-address v-level-989) (type c-size v-old_size-998) (type c-size v-old_capacity-999) (type c-size v-new_capacity-1000) (type c-size v-new_bytes-1001) (ignorable v-solver-954 v-lit-955 v-reason-956 v-known_unit-957 v-idx-958 v-level-959 v-f-974 v-not_lit-979 v-level-989 v-old_size-998 v-old_capacity-999 v-new_capacity-1000 v-new_bytes-1001))
 (tagbody
    (setf v-solver-954 arg-v-solver-954)
    (setf v-lit-955 arg-v-lit-955)
    (setf v-reason-956 arg-v-reason-956)
    (setf v-known_unit-957 arg-v-known_unit-957)
    (setf v-idx-958 (|c/INDEX| v-lit-955))
    (setf v-level-959 (if (c-true v-known_unit-957) (c-u32 0) (|c/assignement_level| v-solver-954 v-lit-955 v-reason-956)))
    (unless (c-true (if (c-true (if (c-true v-known_unit-957) 0 1)) (c-bool (if (c-true v-level-959) 0 1)) 0)) (go ELSE960))
    (progn v-solver-954)
    (progn (setf v-reason-956 0))
    (go ENDIF961)
    ELSE960
    ENDIF961
    (progn (setf v-known_unit-957 (c-bool (if (c-true v-known_unit-957) 1 (c-bool (if (c-true v-level-959) 0 1))))))
    (unless (c-true (if (c-true (if (c-true (m-u32 (+ v-solver-954 8))) 0 1)) 1 (c-bool v-known_unit-957))) (go ELSE965))
    (progn v-solver-954)
    (progn (let* ((a970 (+ (+ v-solver-954 1016) 104)) (old971 (m-u64 a970))) (setf (m-u64 a970) (c-u64 (c-u64 (+ old971 (c-u64 1))))) old971))
    (progn (let* ((a972 (+ (+ v-solver-954 1016) 216)) (old973 (m-u64 a972))) (setf (m-u64 a972) (c-u64 (c-u64 (- old973 (c-u64 1))))) old973))
    (setf v-f-974 (+ (m-ptr (+ v-solver-954 48)) (* 4 v-idx-958)))
    (progn (set-bits (+ v-f-974 0) 0 1 (c-bool 0)))
    (progn (set-bits (+ v-f-974 0) 3 1 (c-bool 1)))
    (progn (|c/trace_and_check_unit_addition| v-solver-954 v-lit-955))
    (unless (c-true v-reason-956) (go ELSE975))
    (unless (c-true (if (c-true (|c/is_tagged_clause| v-reason-956)) 0 1)) (go ELSE977))
    (progn (|c/mark_garbage| v-solver-954 v-reason-956 |c/string/102|))
    (go ENDIF978)
    ELSE977
    ENDIF978
    (progn (setf v-reason-956 0))
    (go ENDIF976)
    ELSE975
    ENDIF976
    (go ENDIF966)
    ELSE965
    ENDIF966
    (setf v-not_lit-979 (|c/NOT| v-lit-955))
    (progn (setf (m-s8 (+ (m-ptr (+ v-solver-954 40)) (* 1 v-lit-955))) (c-s8 1)))
    (progn (setf (m-s8 (+ (m-ptr (+ v-solver-954 40)) (* 1 v-not_lit-979))) (c-s8 (c-s32 (- 1)))))
    (unless (c-true (if (c-true (m-u8 (+ v-solver-954 1984))) 0 1)) (go ELSE980))
    (progn (setf (m-s8 (+ (m-ptr (+ v-solver-954 56)) (* 1 v-idx-958))) (c-s8 (|c/INT_SIGN| v-lit-955))))
    (go ENDIF981)
    ELSE980
    ENDIF981
    (progn (setf (m-ptr (+ (m-ptr (+ v-solver-954 416)) (* 8 v-idx-958))) v-reason-956))
    (progn (setf (m-u32 (+ (m-ptr (+ v-solver-954 32)) (* 4 v-idx-958))) v-level-959))
    (progn (setf (m-u32 (+ (m-ptr (+ v-solver-954 224)) (* 4 v-idx-958))) (c-u32 (the c-size (truncate (- (m-ptr (+ (+ v-solver-954 552) 8)) (m-ptr (+ (+ v-solver-954 552) 0))) 4)))))
    (progn (setf (m-u32 (let* ((a982 (+ (+ v-solver-954 552) 8)) (old983 (m-ptr a982))) (setf (m-ptr a982) (+ old983 (* 4 1))) old983)) v-lit-955))
    (unless (c-true (if (c-true (if (c-true (if (= v-reason-956 0) 1 0)) (c-bool (m-u32 (+ v-solver-954 8))) 0)) (c-bool (if (c-true v-known_unit-957) 0 1)) 0)) (go ELSE984))
    (progn v-solver-954)
    (c-memset v-level-989 0 24)
    (setf (m-ptr (+ v-level-989 0)) (- (m-ptr (+ (+ v-solver-954 552) 8)) (* 4 1)))
    (setf (m-u32 (+ v-level-989 8)) (m-u32 (+ v-solver-954 8)))
    (c-memset (+ v-level-989 12) 0 8)
    (setf (m-u32 (+ (+ v-level-989 12) 0)) 4294967295)
    (setf (m-u32 (+ (+ v-level-989 12) 4)) (c-u32 0))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-954 576) 8)) (m-ptr (+ (+ v-solver-954 576) 16))) 1 0)) (go ELSE993))
    (setf v-old_size-998 (the c-size (truncate (- (m-ptr (+ (+ v-solver-954 576) 8)) (m-ptr (+ (+ v-solver-954 576) 0))) 24)))
    (setf v-old_capacity-999 (the c-size (truncate (- (m-ptr (+ (+ v-solver-954 576) 16)) (m-ptr (+ (+ v-solver-954 576) 0))) 24)))
    (setf v-new_capacity-1000 (if (c-true v-old_capacity-999) (c-u64 (* (c-u64 2) v-old_capacity-999)) (c-u64 1)))
    (setf v-new_bytes-1001 (c-u64 (* v-new_capacity-1000 24)))
    (progn (setf (m-ptr (+ (+ v-solver-954 576) 0)) (c-realloc (m-ptr (+ (+ v-solver-954 576) 0)) v-new_bytes-1001)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-954 576) 0))) 0 1)) (go ELSE1002))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-1001))
    (go ENDIF1003)
    ELSE1002
    ENDIF1003
    (progn (setf (m-ptr (+ (+ v-solver-954 576) 8)) (+ (m-ptr (+ (+ v-solver-954 576) 0)) (* 24 v-old_size-998))))
    (progn (setf (m-ptr (+ (+ v-solver-954 576) 16)) (+ (m-ptr (+ (+ v-solver-954 576) 0)) (* 24 v-new_capacity-1000))))
    (go ENDIF994)
    ELSE993
    ENDIF994
    (progn (copy-bytes (let* ((a1004 (+ (+ v-solver-954 576) 8)) (old1005 (m-ptr a1004))) (setf (m-ptr a1004) (+ old1005 (* 24 1))) old1005) v-level-989 24))
    (go ENDIF985)
    ELSE984
    ENDIF985
    (progn (let* ((a1006 (+ v-solver-954 24)) (old1007 (m-u32 a1006))) (setf (m-u32 a1006) (c-u32 (c-u32 (- old1007 (c-u32 1))))) old1007))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:3663:1
(defun |c/activate_literals| (arg-v-solver-1008)
 (declare  (type c-address arg-v-solver-1008))
 (let ((v-solver-1008 0) (v-flags-1009 0) (v-lit-1013 0) (v-PTR_lit-1014 0) (v-END_lit-1015 0) (v-idx-1016 0) (v-f-1017 0) (v-old_size-1035 0) (v-old_capacity-1036 0) (v-new_capacity-1037 0) (v-new_bytes-1038 0) (v-old_size-1051 0) (v-old_capacity-1052 0) (v-new_capacity-1053 0) (v-new_bytes-1054 0))
 (declare (type c-address v-solver-1008) (type c-address v-flags-1009) (type (unsigned-byte 32) v-lit-1013) (type c-address v-PTR_lit-1014) (type c-address v-END_lit-1015) (type (unsigned-byte 32) v-idx-1016) (type c-address v-f-1017) (type c-size v-old_size-1035) (type c-size v-old_capacity-1036) (type c-size v-new_capacity-1037) (type c-size v-new_bytes-1038) (type c-size v-old_size-1051) (type c-size v-old_capacity-1052) (type c-size v-new_capacity-1053) (type c-size v-new_bytes-1054) (ignorable v-solver-1008 v-flags-1009 v-lit-1013 v-PTR_lit-1014 v-END_lit-1015 v-idx-1016 v-f-1017 v-old_size-1035 v-old_capacity-1036 v-new_capacity-1037 v-new_bytes-1038 v-old_size-1051 v-old_capacity-1052 v-new_capacity-1053 v-new_bytes-1054))
 (tagbody
    (setf v-solver-1008 arg-v-solver-1008)
    (setf v-flags-1009 (m-ptr (+ v-solver-1008 48)))
    (setf v-PTR_lit-1014 (m-ptr (+ (+ v-solver-1008 624) 0)))
    (setf v-END_lit-1015 (m-ptr (+ (+ v-solver-1008 624) 8)))
    LOOP1010
    (unless (c-true (if (c-true (if (/= v-PTR_lit-1014 v-END_lit-1015) 1 0)) (c-bool (progn (setf v-lit-1013 (m-u32 v-PTR_lit-1014)) 1)) 0)) (go ENDLOOP1011))
    (setf v-idx-1016 (|c/INDEX| v-lit-1013))
    (setf v-f-1017 (+ v-flags-1009 (* 4 v-idx-1016)))
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-f-1017 0)))) (go ELSE1018))
    (go CONTINUE1012)
    ELSE1018
    (progn (set-bits (+ v-f-1017 0) 0 1 (c-bool 1)))
    (progn (set-bits (+ v-f-1017 0) 4 2 (c-u32 1)))
    (progn (progn 0 (let* ((a1020 (+ (+ v-solver-1008 1016) 144)) (old1021 (m-u64 a1020))) (setf (m-u64 a1020) (c-u64 (c-u64 (+ old1021 (c-u64 1))))) (m-u64 a1020))))
    (progn (set-bits (+ v-f-1017 0) 1 1 (c-bool 1)))
    (progn (progn 0 (let* ((a1022 (+ (+ v-solver-1008 1016) 136)) (old1023 (m-u64 a1022))) (setf (m-u64 a1022) (c-u64 (c-u64 (+ old1023 (c-u64 1))))) (m-u64 a1022))))
    (progn v-solver-1008)
    (unless (c-true (if (= (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 0)) 8)) (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 0)) 16))) 1 0)) (go ELSE1030))
    (setf v-old_size-1035 (the c-size (truncate (- (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 0)) 8)) (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 0)) 0))) 4)))
    (setf v-old_capacity-1036 (the c-size (truncate (- (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 0)) 16)) (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 0)) 0))) 4)))
    (setf v-new_capacity-1037 (if (c-true v-old_capacity-1036) (c-u64 (* (c-u64 2) v-old_capacity-1036)) (c-u64 1)))
    (setf v-new_bytes-1038 (c-u64 (* v-new_capacity-1037 4)))
    (progn (setf (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 0)) 0)) (c-realloc (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 0)) 0)) v-new_bytes-1038)))
    (unless (c-true (if (c-true (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 0)) 0))) 0 1)) (go ELSE1039))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-1038))
    (go ENDIF1040)
    ELSE1039
    ENDIF1040
    (progn (setf (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 0)) 8)) (+ (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 0)) 0)) (* 4 v-old_size-1035))))
    (progn (setf (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 0)) 16)) (+ (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 0)) 0)) (* 4 v-new_capacity-1037))))
    (go ENDIF1031)
    ELSE1030
    ENDIF1031
    (progn (setf (m-u32 (let* ((a1041 (+ (+ (+ v-solver-1008 104) (* 24 0)) 8)) (old1042 (m-ptr a1041))) (setf (m-ptr a1041) (+ old1042 (* 4 1))) old1042)) v-idx-1016))
    (unless (c-true (if (= (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 1)) 8)) (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 1)) 16))) 1 0)) (go ELSE1046))
    (setf v-old_size-1051 (the c-size (truncate (- (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 1)) 8)) (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 1)) 0))) 4)))
    (setf v-old_capacity-1052 (the c-size (truncate (- (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 1)) 16)) (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 1)) 0))) 4)))
    (setf v-new_capacity-1053 (if (c-true v-old_capacity-1052) (c-u64 (* (c-u64 2) v-old_capacity-1052)) (c-u64 1)))
    (setf v-new_bytes-1054 (c-u64 (* v-new_capacity-1053 4)))
    (progn (setf (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 1)) 0)) (c-realloc (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 1)) 0)) v-new_bytes-1054)))
    (unless (c-true (if (c-true (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 1)) 0))) 0 1)) (go ELSE1055))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-1054))
    (go ENDIF1056)
    ELSE1055
    ENDIF1056
    (progn (setf (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 1)) 8)) (+ (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 1)) 0)) (* 4 v-old_size-1051))))
    (progn (setf (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 1)) 16)) (+ (m-ptr (+ (+ (+ v-solver-1008 104) (* 24 1)) 0)) (* 4 v-new_capacity-1053))))
    (go ENDIF1047)
    ELSE1046
    ENDIF1047
    (progn (setf (m-u32 (let* ((a1057 (+ (+ (+ v-solver-1008 104) (* 24 1)) 8)) (old1058 (m-ptr a1057))) (setf (m-ptr a1057) (+ old1058 (* 4 1))) old1058)) v-idx-1016))
    (progn (let* ((a1059 (+ (+ v-solver-1008 1016) 216)) (old1060 (m-u64 a1059))) (setf (m-u64 a1059) (c-u64 (c-u64 (+ old1060 (c-u64 1))))) old1060))
    (progn (let* ((a1061 (+ (+ v-solver-1008 1016) 368)) (old1062 (m-u64 a1061))) (setf (m-u64 a1061) (c-u64 (c-u64 (+ old1062 (c-u64 1))))) old1062))
    (progn (let* ((a1063 (+ v-solver-1008 24)) (old1064 (m-u32 a1063))) (setf (m-u32 a1063) (c-u32 (c-u32 (+ old1064 (c-u32 1))))) old1064))
    CONTINUE1012
    (let* ( (old1066 v-PTR_lit-1014)) (setf v-PTR_lit-1014 (+ old1066 (* 4 1))) v-PTR_lit-1014)
    (go LOOP1010)
    ENDLOOP1011
  )
  0))

;;; upstream/satch.c:3713:1
(defun |c/restamp_queue| (arg-v-solver-1067 arg-v-queue-1068)
 (declare  (type c-address arg-v-solver-1067) (type c-address arg-v-queue-1068))
 (let ((v-solver-1067 0) (v-queue-1068 0) (v-restamped-1069 0) (v-links-1072 0) (v-link-1073 0) (v-stamp-1074 0) (v-idx-1078 0))
 (declare (type c-address v-solver-1067) (type c-address v-queue-1068) (type (unsigned-byte 64) v-restamped-1069) (type c-address v-links-1072) (type c-address v-link-1073) (type (unsigned-byte 32) v-stamp-1074) (type (unsigned-byte 32) v-idx-1078) (ignorable v-solver-1067 v-queue-1068 v-restamped-1069 v-links-1072 v-link-1073 v-stamp-1074 v-idx-1078))
 (tagbody
    (setf v-solver-1067 arg-v-solver-1067)
    (setf v-queue-1068 arg-v-queue-1068)
    (locally (declare (optimize (speed 1))) (setf v-restamped-1069 (progn 0 (let* ((a1070 (+ (+ v-solver-1067 1016) 248)) (old1071 (m-u64 a1070))) (setf (m-u64 a1070) (c-u64 (c-u64 (+ old1071 (c-u64 1))))) (m-u64 a1070)))))
    (progn (when (>= (m-u32 (+ v-solver-1067 884)) (c-u32 2)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-1067 (c-u32 2) |c/string/103| v-restamped-1069 |c/string/104|))))
    (setf v-links-1072 (m-ptr (+ v-queue-1068 0)))
    (setf v-stamp-1074 (c-u32 0))
    (setf v-idx-1078 (m-u32 (+ v-queue-1068 12)))
    LOOP1075
    (unless (c-true (if (/= v-idx-1078 4294967295) 1 0)) (go ENDLOOP1076))
    (progn (setf v-link-1073 (+ v-links-1072 (* 12 v-idx-1078))))
    (progn (setf (m-u32 (+ v-link-1073 8)) (let* ( (old1080 v-stamp-1074)) (setf v-stamp-1074 (c-u32 (c-u32 (+ old1080 (c-u32 1))))) v-stamp-1074)))
    (setf v-idx-1078 (m-u32 (+ v-link-1073 4)))
    (go LOOP1075)
    ENDLOOP1076
    (progn (setf (m-u32 (+ v-queue-1068 20)) (m-u32 (+ v-queue-1068 16))))
    (progn (setf (m-u32 (+ v-queue-1068 24)) v-stamp-1074))
  )
  0))

;;; upstream/satch.c:3737:1
(defun |c/enqueue| (arg-v-solver-1081 arg-v-queue-1082 arg-v-idx-1083)
 (declare  (type c-address arg-v-solver-1081) (type c-address arg-v-queue-1082) (type (unsigned-byte 32) arg-v-idx-1083))
 (let ((v-solver-1081 0) (v-queue-1082 0) (v-idx-1083 0) (v-links-1087 0) (v-link-1088 0) (v-last-1089 0) (v-prev-1092 0) (v-lit-1100 0))
 (declare (type c-address v-solver-1081) (type c-address v-queue-1082) (type (unsigned-byte 32) v-idx-1083) (type c-address v-links-1087) (type c-address v-link-1088) (type (unsigned-byte 32) v-last-1089) (type c-address v-prev-1092) (type (unsigned-byte 32) v-lit-1100) (ignorable v-solver-1081 v-queue-1082 v-idx-1083 v-links-1087 v-link-1088 v-last-1089 v-prev-1092 v-lit-1100))
 (tagbody
    (setf v-solver-1081 arg-v-solver-1081)
    (setf v-queue-1082 arg-v-queue-1082)
    (setf v-idx-1083 arg-v-idx-1083)
    (progn v-solver-1081)
    (setf v-links-1087 (m-ptr (+ v-queue-1082 0)))
    (setf v-link-1088 (+ v-links-1087 (* 12 v-idx-1083)))
    (setf v-last-1089 (m-u32 (+ v-queue-1082 16)))
    (unless (c-true (if (= v-last-1089 4294967295) 1 0)) (go ELSE1090))
    (progn (setf (m-u32 (+ v-queue-1082 12)) v-idx-1083))
    (go ENDIF1091)
    ELSE1090
    (setf v-prev-1092 (+ v-links-1087 (* 12 v-last-1089)))
    (progn (setf (m-u32 (+ v-prev-1092 4)) v-idx-1083))
    ENDIF1091
    (progn (setf (m-u32 (+ v-link-1088 0)) v-last-1089))
    (progn (setf (m-u32 (+ v-queue-1082 16)) v-idx-1083))
    (progn (setf (m-u32 (+ v-link-1088 4)) 4294967295))
    (progn (setf (m-u32 (+ v-link-1088 8)) (let* ((a1093 (+ v-queue-1082 24)) (old1094 (m-u32 a1093))) (setf (m-u32 a1093) (c-u32 (c-u32 (+ old1094 (c-u32 1))))) (m-u32 a1093))))
    (unless (c-true (m-u32 (+ v-link-1088 8))) (go ELSE1095))
    (progn v-solver-1081)
    (setf v-lit-1100 (|c/LITERAL| v-idx-1083))
    (unless (c-true (if (c-true (m-s8 (+ (m-ptr (+ v-solver-1081 40)) (* 1 v-lit-1100)))) 0 1)) (go ELSE1101))
    (progn (setf (m-u32 (+ v-queue-1082 20)) v-idx-1083))
    (go ENDIF1102)
    ELSE1101
    ENDIF1102
    (go ENDIF1096)
    ELSE1095
    (progn (|c/restamp_queue| v-solver-1081 v-queue-1082))
    ENDIF1096
  )
  0))

;;; upstream/satch.c:3791:1
(defun |c/dequeue| (arg-v-solver-1103 arg-v-queue-1104 arg-v-idx-1105)
 (declare  (type c-address arg-v-solver-1103) (type c-address arg-v-queue-1104) (type (unsigned-byte 32) arg-v-idx-1105))
 (let ((v-solver-1103 0) (v-queue-1104 0) (v-idx-1105 0) (v-links-1109 0) (v-link-1110 0) (v-prev_idx-1111 0) (v-next_idx-1112 0) (v-prev-1115 0) (v-next-1118 0))
 (declare (type c-address v-solver-1103) (type c-address v-queue-1104) (type (unsigned-byte 32) v-idx-1105) (type c-address v-links-1109) (type c-address v-link-1110) (type (unsigned-byte 32) v-prev_idx-1111) (type (unsigned-byte 32) v-next_idx-1112) (type c-address v-prev-1115) (type c-address v-next-1118) (ignorable v-solver-1103 v-queue-1104 v-idx-1105 v-links-1109 v-link-1110 v-prev_idx-1111 v-next_idx-1112 v-prev-1115 v-next-1118))
 (tagbody
    (setf v-solver-1103 arg-v-solver-1103)
    (setf v-queue-1104 arg-v-queue-1104)
    (setf v-idx-1105 arg-v-idx-1105)
    (progn v-solver-1103)
    (setf v-links-1109 (m-ptr (+ v-queue-1104 0)))
    (setf v-link-1110 (+ v-links-1109 (* 12 v-idx-1105)))
    (setf v-prev_idx-1111 (m-u32 (+ v-link-1110 0)))
    (setf v-next_idx-1112 (m-u32 (+ v-link-1110 4)))
    (unless (c-true (if (= v-prev_idx-1111 4294967295) 1 0)) (go ELSE1113))
    (progn (setf (m-u32 (+ v-queue-1104 12)) v-next_idx-1112))
    (go ENDIF1114)
    ELSE1113
    (setf v-prev-1115 (+ v-links-1109 (* 12 v-prev_idx-1111)))
    (progn (setf (m-u32 (+ v-prev-1115 4)) v-next_idx-1112))
    ENDIF1114
    (unless (c-true (if (= v-next_idx-1112 4294967295) 1 0)) (go ELSE1116))
    (progn (setf (m-u32 (+ v-queue-1104 16)) v-prev_idx-1111))
    (go ENDIF1117)
    ELSE1116
    (setf v-next-1118 (+ v-links-1109 (* 12 v-next_idx-1112)))
    (progn (setf (m-u32 (+ v-next-1118 0)) v-prev_idx-1111))
    ENDIF1117
  )
  0))

;;; upstream/satch.c:3832:1
(defun |c/resize_queue| (arg-v-queue-1119 arg-v-new_capacity-1120)
 (declare  (type c-address arg-v-queue-1119) (type c-size arg-v-new_capacity-1120))
 (let ((v-queue-1119 0) (v-new_capacity-1120 0) (v-new_bytes-1124 0))
 (declare (type c-address v-queue-1119) (type c-size v-new_capacity-1120) (type c-size v-new_bytes-1124) (ignorable v-queue-1119 v-new_capacity-1120 v-new_bytes-1124))
 (tagbody
    (setf v-queue-1119 arg-v-queue-1119)
    (setf v-new_capacity-1120 arg-v-new_capacity-1120)
    (setf v-new_bytes-1124 (c-u64 (* v-new_capacity-1120 12)))
    (progn (setf (m-ptr (+ v-queue-1119 0)) (c-realloc (m-ptr (+ v-queue-1119 0)) v-new_bytes-1124)))
    (unless (c-true (if (c-true (m-ptr (+ v-queue-1119 0))) 0 1)) (go ELSE1125))
    (progn (|c/out_of_memory| v-new_bytes-1124))
    (go ENDIF1126)
    ELSE1125
    ENDIF1126
  )
  0))

;;; upstream/satch.c:3838:1
(defun |c/init_queue| (arg-v-solver-1127 arg-v-queue-1128)
 (declare  (type c-address arg-v-solver-1127) (type c-address arg-v-queue-1128))
 (let ((v-solver-1127 0) (v-queue-1128 0))
 (declare (type c-address v-solver-1127) (type c-address v-queue-1128) (ignorable v-solver-1127 v-queue-1128))
 (tagbody
    (setf v-solver-1127 arg-v-solver-1127)
    (setf v-queue-1128 arg-v-queue-1128)
    (unless (c-true (if (c-true (m-u32 (+ v-queue-1128 8))) 0 1)) (go ELSE1129))
    (progn (setf (m-u32 (+ v-queue-1128 12)) (setf (m-u32 (+ v-queue-1128 16)) (setf (m-u32 (+ v-queue-1128 20)) 4294967295))))
    (go ENDIF1130)
    ELSE1129
    ENDIF1130
    (unless (c-true (if (c-true (m-ptr (+ v-queue-1128 0))) 0 1)) (go ELSE1131))
    (progn (|c/resize_queue| v-queue-1128 (m-size (+ v-solver-1127 16))))
    (go ENDIF1132)
    ELSE1131
    ENDIF1132
  )
  0))

;;; upstream/satch.c:3853:1
(defun |c/activate_queue| (arg-v-solver-1133 arg-v-queue-1134 arg-v-activate-1135)
 (declare  (type c-address arg-v-solver-1133) (type c-address arg-v-queue-1134) (type c-address arg-v-activate-1135))
 (let ((v-solver-1133 0) (v-queue-1134 0) (v-activate-1135 0) (v-stable-1136 0) (v-idx-1143 0) (v-PTR_idx-1144 0) (v-END_idx-1145 0))
 (declare (type c-address v-solver-1133) (type c-address v-queue-1134) (type c-address v-activate-1135) (type (unsigned-byte 32) v-stable-1136) (type (unsigned-byte 32) v-idx-1143) (type c-address v-PTR_idx-1144) (type c-address v-END_idx-1145) (ignorable v-solver-1133 v-queue-1134 v-activate-1135 v-stable-1136 v-idx-1143 v-PTR_idx-1144 v-END_idx-1145))
 (tagbody
    (setf v-solver-1133 arg-v-solver-1133)
    (setf v-queue-1134 arg-v-queue-1134)
    (setf v-activate-1135 arg-v-activate-1135)
    (progn (|c/init_queue| v-solver-1133 v-queue-1134))
    (setf v-stable-1136 (m-u8 (+ v-solver-1133 6)))
    (progn v-solver-1133)
    (setf v-PTR_idx-1144 (m-ptr (+ v-activate-1135 0)))
    (setf v-END_idx-1145 (m-ptr (+ v-activate-1135 8)))
    LOOP1140
    (unless (c-true (if (c-true (if (/= v-PTR_idx-1144 v-END_idx-1145) 1 0)) (c-bool (progn (setf v-idx-1143 (m-u32 v-PTR_idx-1144)) 1)) 0)) (go ENDLOOP1141))
    (progn (progn 0 (let* ((a1146 (+ (+ (+ v-solver-1133 1016) 0) (* 8 v-stable-1136))) (old1147 (m-u64 a1146))) (setf (m-u64 a1146) (c-u64 (c-u64 (+ old1147 (c-u64 1))))) (m-u64 a1146))))
    (progn (|c/enqueue| v-solver-1133 v-queue-1134 v-idx-1143))
    (let* ( (old1149 v-PTR_idx-1144)) (setf v-PTR_idx-1144 (+ old1149 (* 4 1))) v-PTR_idx-1144)
    (go LOOP1140)
    ENDLOOP1141
    (progn (c-free (m-ptr (+ v-activate-1135 0))))
    (progn (setf (m-ptr (+ v-activate-1135 0)) (setf (m-ptr (+ v-activate-1135 8)) (setf (m-ptr (+ v-activate-1135 16)) 0))))
    (progn (setf (m-u32 (+ v-queue-1134 8)) (m-u32 (+ v-solver-1133 12))))
  )
  0))

;;; upstream/satch.c:3892:1
(defun |c/get_queue| (arg-v-solver-1153)
 (declare  (type c-address arg-v-solver-1153))
 (let ((v-solver-1153 0) (v-stable-1154 0) (v-queue-1155 0) (v-activate-1156 0))
 (declare (type c-address v-solver-1153) (type (unsigned-byte 32) v-stable-1154) (type c-address v-queue-1155) (type c-address v-activate-1156) (ignorable v-solver-1153 v-stable-1154 v-queue-1155 v-activate-1156))
 (tagbody
    (setf v-solver-1153 arg-v-solver-1153)
    (setf v-stable-1154 (m-u8 (+ v-solver-1153 6)))
    (setf v-queue-1155 (+ (+ v-solver-1153 240) (* 32 v-stable-1154)))
    (setf v-activate-1156 (+ (+ v-solver-1153 104) (* 24 v-stable-1154)))
    (unless (c-true (if (c-true (if (= (m-ptr (+ v-activate-1156 8)) (m-ptr (+ v-activate-1156 0))) 1 0)) 0 1)) (go ELSE1157))
    (progn (|c/activate_queue| v-solver-1153 v-queue-1155 v-activate-1156))
    (go ENDIF1158)
    ELSE1157
    ENDIF1158
    (return-from |c/get_queue| v-queue-1155)
  )
  0))

;;; upstream/satch.c:3911:1
(defun |c/move_variable_to_front| (arg-v-solver-1159 arg-v-idx-1160)
 (declare  (type c-address arg-v-solver-1159) (type (unsigned-byte 32) arg-v-idx-1160))
 (let ((v-solver-1159 0) (v-idx-1160 0) (v-queue-1166 0))
 (declare (type c-address v-solver-1159) (type (unsigned-byte 32) v-idx-1160) (type c-address v-queue-1166) (ignorable v-solver-1159 v-idx-1160 v-queue-1166))
 (tagbody
    (setf v-solver-1159 arg-v-solver-1159)
    (setf v-idx-1160 arg-v-idx-1160)
    (progn (progn 0 (let* ((a1161 (+ (+ v-solver-1159 1016) 160)) (old1162 (m-u64 a1161))) (setf (m-u64 a1161) (c-u64 (c-u64 (+ old1162 (c-u64 1))))) (m-u64 a1161))))
    (progn v-solver-1159)
    (setf v-queue-1166 (|c/get_queue| v-solver-1159))
    (progn (|c/dequeue| v-solver-1159 v-queue-1166 v-idx-1160))
    (progn (|c/enqueue| v-solver-1159 v-queue-1166 v-idx-1160))
  )
  0))

;;; upstream/satch.c:3923:1
(defun |c/release_queue| (arg-v-queue-1167)
 (declare  (type c-address arg-v-queue-1167))
 (let ((v-queue-1167 0))
 (declare (type c-address v-queue-1167) (ignorable v-queue-1167))
 (tagbody
    (setf v-queue-1167 arg-v-queue-1167)
    (progn (c-free (m-ptr (+ v-queue-1167 0))))
  )
  0))

;;; upstream/satch.c:3962:1
(defun |c/resize_trail| (arg-v-trail-1168 arg-v-new_capacity-1169)
 (declare  (type c-address arg-v-trail-1168) (type c-size arg-v-new_capacity-1169))
 (let ((v-trail-1168 0) (v-new_capacity-1169 0) (v-size-1170 0) (v-bytes-1171 0) (v-propagate-1172 0))
 (declare (type c-address v-trail-1168) (type c-size v-new_capacity-1169) (type c-size v-size-1170) (type c-size v-bytes-1171) (type (unsigned-byte 32) v-propagate-1172) (ignorable v-trail-1168 v-new_capacity-1169 v-size-1170 v-bytes-1171 v-propagate-1172))
 (tagbody
    (setf v-trail-1168 arg-v-trail-1168)
    (setf v-new_capacity-1169 arg-v-new_capacity-1169)
    (setf v-size-1170 (the c-size (truncate (- (m-ptr (+ v-trail-1168 8)) (m-ptr (+ v-trail-1168 0))) 4)))
    (setf v-bytes-1171 (c-u64 (* v-new_capacity-1169 4)))
    (setf v-propagate-1172 (c-u32 (truncate (- (m-ptr (+ v-trail-1168 16)) (m-ptr (+ v-trail-1168 0))) 4)))
    (progn (setf (m-ptr (+ v-trail-1168 0)) (c-realloc (m-ptr (+ v-trail-1168 0)) v-bytes-1171)))
    (unless (c-true (if (c-true (m-ptr (+ v-trail-1168 0))) 0 1)) (go ELSE1173))
    (progn (|c/out_of_memory| v-bytes-1171))
    (go ENDIF1174)
    ELSE1173
    ENDIF1174
    (progn (setf (m-ptr (+ v-trail-1168 8)) (+ (m-ptr (+ v-trail-1168 0)) (* 4 v-size-1170))))
    (progn (setf (m-ptr (+ v-trail-1168 16)) (+ (m-ptr (+ v-trail-1168 0)) (* 4 v-propagate-1172))))
  )
  0))

;;; upstream/satch.c:3984:1
(defun |c/increase_capacity| (arg-v-solver-1175 arg-v-new_capacity-1176)
 (declare  (type c-address arg-v-solver-1175) (type (unsigned-byte 32) arg-v-new_capacity-1176))
 (let ((v-solver-1175 0) (v-new_capacity-1176 0) (v-old_capacity-1177 0) (v-size-1184 0) (v-old_bytes-1185 0) (v-new_bytes-1186 0) (v-chunk-1187 0) (v-size-1195 0) (v-old_bytes-1196 0) (v-new_bytes-1197 0) (v-chunk-1198 0) (v-size-1206 0) (v-old_bytes-1207 0) (v-new_bytes-1208 0) (v-chunk-1209 0) (v-size-1217 0) (v-old_bytes-1218 0) (v-new_bytes-1219 0) (v-chunk-1220 0) (v-size-1228 0) (v-old_bytes-1229 0) (v-new_bytes-1230 0) (v-chunk-1231 0) (v-size-1239 0) (v-old_bytes-1240 0) (v-new_bytes-1241 0) (v-chunk-1242 0) (v-size-1250 0) (v-old_bytes-1251 0) (v-new_bytes-1252 0) (v-chunk-1253 0) (v-size-1261 0) (v-old_bytes-1262 0) (v-new_bytes-1263 0) (v-chunk-1264 0) (v-size-1272 0) (v-old_bytes-1273 0) (v-new_bytes-1274 0) (v-chunk-1275 0) (v-size-1283 0) (v-old_bytes-1284 0) (v-new_bytes-1285 0) (v-chunk-1286 0) (v-new_bytes-1294 0) (v-size-1304 0) (v-old_bytes-1305 0) (v-new_bytes-1306 0) (v-chunk-1307 0))
 (declare (type c-address v-solver-1175) (type (unsigned-byte 32) v-new_capacity-1176) (type (unsigned-byte 32) v-old_capacity-1177) (type c-size v-size-1184) (type c-size v-old_bytes-1185) (type c-size v-new_bytes-1186) (type c-address v-chunk-1187) (type c-size v-size-1195) (type c-size v-old_bytes-1196) (type c-size v-new_bytes-1197) (type c-address v-chunk-1198) (type c-size v-size-1206) (type c-size v-old_bytes-1207) (type c-size v-new_bytes-1208) (type c-address v-chunk-1209) (type c-size v-size-1217) (type c-size v-old_bytes-1218) (type c-size v-new_bytes-1219) (type c-address v-chunk-1220) (type c-size v-size-1228) (type c-size v-old_bytes-1229) (type c-size v-new_bytes-1230) (type c-address v-chunk-1231) (type c-size v-size-1239) (type c-size v-old_bytes-1240) (type c-size v-new_bytes-1241) (type c-address v-chunk-1242) (type c-size v-size-1250) (type c-size v-old_bytes-1251) (type c-size v-new_bytes-1252) (type c-address v-chunk-1253) (type c-size v-size-1261) (type c-size v-old_bytes-1262) (type c-size v-new_bytes-1263) (type c-address v-chunk-1264) (type c-size v-size-1272) (type c-size v-old_bytes-1273) (type c-size v-new_bytes-1274) (type c-address v-chunk-1275) (type c-size v-size-1283) (type c-size v-old_bytes-1284) (type c-size v-new_bytes-1285) (type c-address v-chunk-1286) (type c-size v-new_bytes-1294) (type c-size v-size-1304) (type c-size v-old_bytes-1305) (type c-size v-new_bytes-1306) (type c-address v-chunk-1307) (ignorable v-solver-1175 v-new_capacity-1176 v-old_capacity-1177 v-size-1184 v-old_bytes-1185 v-new_bytes-1186 v-chunk-1187 v-size-1195 v-old_bytes-1196 v-new_bytes-1197 v-chunk-1198 v-size-1206 v-old_bytes-1207 v-new_bytes-1208 v-chunk-1209 v-size-1217 v-old_bytes-1218 v-new_bytes-1219 v-chunk-1220 v-size-1228 v-old_bytes-1229 v-new_bytes-1230 v-chunk-1231 v-size-1239 v-old_bytes-1240 v-new_bytes-1241 v-chunk-1242 v-size-1250 v-old_bytes-1251 v-new_bytes-1252 v-chunk-1253 v-size-1261 v-old_bytes-1262 v-new_bytes-1263 v-chunk-1264 v-size-1272 v-old_bytes-1273 v-new_bytes-1274 v-chunk-1275 v-size-1283 v-old_bytes-1284 v-new_bytes-1285 v-chunk-1286 v-new_bytes-1294 v-size-1304 v-old_bytes-1305 v-new_bytes-1306 v-chunk-1307))
 (tagbody
    (setf v-solver-1175 arg-v-solver-1175)
    (setf v-new_capacity-1176 arg-v-new_capacity-1176)
    (setf v-old_capacity-1177 (c-u32 (m-size (+ v-solver-1175 16))))
    (progn v-solver-1175)
    (setf v-size-1184 24)
    (setf v-old_bytes-1185 (if (c-true v-old_capacity-1177) (c-u64 (* (c-u64 (* (c-u64 2) (c-u32 (+ v-old_capacity-1177 (c-u32 0))))) v-size-1184)) (c-u64 0)))
    (setf v-new_bytes-1186 (c-u64 (* (c-u64 (* (c-u64 2) (c-u32 (+ v-new_capacity-1176 (c-u32 0))))) v-size-1184)))
    (setf v-chunk-1187 (c-calloc v-new_bytes-1186 (c-u64 1)))
    (unless (c-true (if (c-true v-chunk-1187) 0 1)) (go ELSE1188))
    (progn (|c/out_of_memory| v-new_bytes-1186))
    (go ENDIF1189)
    ELSE1188
    ENDIF1189
    (unless (c-true v-old_bytes-1185) (go ELSE1190))
    (progn (c-memcpy v-chunk-1187 (m-ptr (+ v-solver-1175 544)) v-old_bytes-1185))
    (go ENDIF1191)
    ELSE1190
    ENDIF1191
    (progn (c-free (m-ptr (+ v-solver-1175 544))))
    (progn (setf (m-ptr (+ v-solver-1175 544)) v-chunk-1187))
    (setf v-size-1195 8)
    (setf v-old_bytes-1196 (if (c-true v-old_capacity-1177) (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-old_capacity-1177 (c-u32 0))))) v-size-1195)) (c-u64 0)))
    (setf v-new_bytes-1197 (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-new_capacity-1176 (c-u32 0))))) v-size-1195)))
    (setf v-chunk-1198 (c-calloc v-new_bytes-1197 (c-u64 1)))
    (unless (c-true (if (c-true v-chunk-1198) 0 1)) (go ELSE1199))
    (progn (|c/out_of_memory| v-new_bytes-1197))
    (go ENDIF1200)
    ELSE1199
    ENDIF1200
    (unless (c-true v-old_bytes-1196) (go ELSE1201))
    (progn (c-memcpy v-chunk-1198 (m-ptr (+ v-solver-1175 416)) v-old_bytes-1196))
    (go ENDIF1202)
    ELSE1201
    ENDIF1202
    (progn (c-free (m-ptr (+ v-solver-1175 416))))
    (progn (setf (m-ptr (+ v-solver-1175 416)) v-chunk-1198))
    (setf v-size-1206 4)
    (setf v-old_bytes-1207 (if (c-true v-old_capacity-1177) (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-old_capacity-1177 (c-u32 0))))) v-size-1206)) (c-u64 0)))
    (setf v-new_bytes-1208 (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-new_capacity-1176 (c-u32 0))))) v-size-1206)))
    (setf v-chunk-1209 (c-calloc v-new_bytes-1208 (c-u64 1)))
    (unless (c-true (if (c-true v-chunk-1209) 0 1)) (go ELSE1210))
    (progn (|c/out_of_memory| v-new_bytes-1208))
    (go ENDIF1211)
    ELSE1210
    ENDIF1211
    (unless (c-true v-old_bytes-1207) (go ELSE1212))
    (progn (c-memcpy v-chunk-1209 (m-ptr (+ v-solver-1175 32)) v-old_bytes-1207))
    (go ENDIF1213)
    ELSE1212
    ENDIF1213
    (progn (c-free (m-ptr (+ v-solver-1175 32))))
    (progn (setf (m-ptr (+ v-solver-1175 32)) v-chunk-1209))
    (setf v-size-1217 1)
    (setf v-old_bytes-1218 (if (c-true v-old_capacity-1177) (c-u64 (* (c-u64 (* (c-u64 2) (c-u32 (+ v-old_capacity-1177 (c-u32 0))))) v-size-1217)) (c-u64 0)))
    (setf v-new_bytes-1219 (c-u64 (* (c-u64 (* (c-u64 2) (c-u32 (+ v-new_capacity-1176 (c-u32 0))))) v-size-1217)))
    (setf v-chunk-1220 (c-calloc v-new_bytes-1219 (c-u64 1)))
    (unless (c-true (if (c-true v-chunk-1220) 0 1)) (go ELSE1221))
    (progn (|c/out_of_memory| v-new_bytes-1219))
    (go ENDIF1222)
    ELSE1221
    ENDIF1222
    (unless (c-true v-old_bytes-1218) (go ELSE1223))
    (progn (c-memcpy v-chunk-1220 (m-ptr (+ v-solver-1175 40)) v-old_bytes-1218))
    (go ENDIF1224)
    ELSE1223
    ENDIF1224
    (progn (c-free (m-ptr (+ v-solver-1175 40))))
    (progn (setf (m-ptr (+ v-solver-1175 40)) v-chunk-1220))
    (setf v-size-1228 1)
    (setf v-old_bytes-1229 (if (c-true v-old_capacity-1177) (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-old_capacity-1177 (c-u32 0))))) v-size-1228)) (c-u64 0)))
    (setf v-new_bytes-1230 (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-new_capacity-1176 (c-u32 0))))) v-size-1228)))
    (setf v-chunk-1231 (c-calloc v-new_bytes-1230 (c-u64 1)))
    (unless (c-true (if (c-true v-chunk-1231) 0 1)) (go ELSE1232))
    (progn (|c/out_of_memory| v-new_bytes-1230))
    (go ENDIF1233)
    ELSE1232
    ENDIF1233
    (unless (c-true v-old_bytes-1229) (go ELSE1234))
    (progn (c-memcpy v-chunk-1231 (m-ptr (+ v-solver-1175 56)) v-old_bytes-1229))
    (go ENDIF1235)
    ELSE1234
    ENDIF1235
    (progn (c-free (m-ptr (+ v-solver-1175 56))))
    (progn (setf (m-ptr (+ v-solver-1175 56)) v-chunk-1231))
    (setf v-size-1239 1)
    (setf v-old_bytes-1240 (if (c-true v-old_capacity-1177) (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-old_capacity-1177 (c-u32 0))))) v-size-1239)) (c-u64 0)))
    (setf v-new_bytes-1241 (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-new_capacity-1176 (c-u32 0))))) v-size-1239)))
    (setf v-chunk-1242 (c-calloc v-new_bytes-1241 (c-u64 1)))
    (unless (c-true (if (c-true v-chunk-1242) 0 1)) (go ELSE1243))
    (progn (|c/out_of_memory| v-new_bytes-1241))
    (go ENDIF1244)
    ELSE1243
    ENDIF1244
    (unless (c-true v-old_bytes-1240) (go ELSE1245))
    (progn (c-memcpy v-chunk-1242 (m-ptr (+ v-solver-1175 64)) v-old_bytes-1240))
    (go ENDIF1246)
    ELSE1245
    ENDIF1246
    (progn (c-free (m-ptr (+ v-solver-1175 64))))
    (progn (setf (m-ptr (+ v-solver-1175 64)) v-chunk-1242))
    (setf v-size-1250 1)
    (setf v-old_bytes-1251 (if (c-true v-old_capacity-1177) (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-old_capacity-1177 (c-u32 0))))) v-size-1250)) (c-u64 0)))
    (setf v-new_bytes-1252 (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-new_capacity-1176 (c-u32 0))))) v-size-1250)))
    (setf v-chunk-1253 (c-calloc v-new_bytes-1252 (c-u64 1)))
    (unless (c-true (if (c-true v-chunk-1253) 0 1)) (go ELSE1254))
    (progn (|c/out_of_memory| v-new_bytes-1252))
    (go ENDIF1255)
    ELSE1254
    ENDIF1255
    (unless (c-true v-old_bytes-1251) (go ELSE1256))
    (progn (c-memcpy v-chunk-1253 (m-ptr (+ v-solver-1175 80)) v-old_bytes-1251))
    (go ENDIF1257)
    ELSE1256
    ENDIF1257
    (progn (c-free (m-ptr (+ v-solver-1175 80))))
    (progn (setf (m-ptr (+ v-solver-1175 80)) v-chunk-1253))
    (setf v-size-1261 1)
    (setf v-old_bytes-1262 (if (c-true v-old_capacity-1177) (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-old_capacity-1177 (c-u32 0))))) v-size-1261)) (c-u64 0)))
    (setf v-new_bytes-1263 (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-new_capacity-1176 (c-u32 0))))) v-size-1261)))
    (setf v-chunk-1264 (c-calloc v-new_bytes-1263 (c-u64 1)))
    (unless (c-true (if (c-true v-chunk-1264) 0 1)) (go ELSE1265))
    (progn (|c/out_of_memory| v-new_bytes-1263))
    (go ENDIF1266)
    ELSE1265
    ENDIF1266
    (unless (c-true v-old_bytes-1262) (go ELSE1267))
    (progn (c-memcpy v-chunk-1264 (m-ptr (+ v-solver-1175 96)) v-old_bytes-1262))
    (go ENDIF1268)
    ELSE1267
    ENDIF1268
    (progn (c-free (m-ptr (+ v-solver-1175 96))))
    (progn (setf (m-ptr (+ v-solver-1175 96)) v-chunk-1264))
    (setf v-size-1272 4)
    (setf v-old_bytes-1273 (if (c-true v-old_capacity-1177) (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-old_capacity-1177 (c-u32 0))))) v-size-1272)) (c-u64 0)))
    (setf v-new_bytes-1274 (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-new_capacity-1176 (c-u32 0))))) v-size-1272)))
    (setf v-chunk-1275 (c-calloc v-new_bytes-1274 (c-u64 1)))
    (unless (c-true (if (c-true v-chunk-1275) 0 1)) (go ELSE1276))
    (progn (|c/out_of_memory| v-new_bytes-1274))
    (go ENDIF1277)
    ELSE1276
    ENDIF1277
    (unless (c-true v-old_bytes-1273) (go ELSE1278))
    (progn (c-memcpy v-chunk-1275 (m-ptr (+ v-solver-1175 48)) v-old_bytes-1273))
    (go ENDIF1279)
    ELSE1278
    ENDIF1279
    (progn (c-free (m-ptr (+ v-solver-1175 48))))
    (progn (setf (m-ptr (+ v-solver-1175 48)) v-chunk-1275))
    (setf v-size-1283 1)
    (setf v-old_bytes-1284 (if (c-true v-old_capacity-1177) (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-old_capacity-1177 (c-u32 1))))) v-size-1283)) (c-u64 0)))
    (setf v-new_bytes-1285 (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-new_capacity-1176 (c-u32 1))))) v-size-1283)))
    (setf v-chunk-1286 (c-calloc v-new_bytes-1285 (c-u64 1)))
    (unless (c-true (if (c-true v-chunk-1286) 0 1)) (go ELSE1287))
    (progn (|c/out_of_memory| v-new_bytes-1285))
    (go ENDIF1288)
    ELSE1287
    ENDIF1288
    (unless (c-true v-old_bytes-1284) (go ELSE1289))
    (progn (c-memcpy v-chunk-1286 (m-ptr (+ v-solver-1175 232)) v-old_bytes-1284))
    (go ENDIF1290)
    ELSE1289
    ENDIF1290
    (progn (c-free (m-ptr (+ v-solver-1175 232))))
    (progn (setf (m-ptr (+ v-solver-1175 232)) v-chunk-1286))
    (setf v-new_bytes-1294 (c-u64 (* v-new_capacity-1176 4)))
    (progn (setf (m-ptr (+ v-solver-1175 224)) (c-realloc (m-ptr (+ v-solver-1175 224)) v-new_bytes-1294)))
    (unless (c-true (if (c-true (m-ptr (+ v-solver-1175 224))) 0 1)) (go ELSE1295))
    (progn (|c/out_of_memory| v-new_bytes-1294))
    (go ENDIF1296)
    ELSE1295
    ENDIF1296
    (progn (|c/resize_trail| (+ v-solver-1175 552) v-new_capacity-1176))
    (unless (c-true (m-u32 (+ (+ (+ v-solver-1175 240) (* 32 0)) 8))) (go ELSE1297))
    (progn (|c/resize_queue| (+ (+ v-solver-1175 240) (* 32 0)) v-new_capacity-1176))
    (go ENDIF1298)
    ELSE1297
    ENDIF1298
    (unless (c-true (m-u32 (+ (+ (+ v-solver-1175 304) (* 56 1)) 32))) (go ELSE1299))
    (progn (|c/resize_heap| (+ (+ v-solver-1175 304) (* 56 1)) v-old_capacity-1177 v-new_capacity-1176))
    (go ENDIF1300)
    ELSE1299
    ENDIF1300
    (setf v-size-1304 1)
    (setf v-old_bytes-1305 (if (c-true v-old_capacity-1177) (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-old_capacity-1177 (c-u32 0))))) v-size-1304)) (c-u64 0)))
    (setf v-new_bytes-1306 (c-u64 (* (c-u64 (* (c-u64 1) (c-u32 (+ v-new_capacity-1176 (c-u32 0))))) v-size-1304)))
    (setf v-chunk-1307 (c-calloc v-new_bytes-1306 (c-u64 1)))
    (unless (c-true (if (c-true v-chunk-1307) 0 1)) (go ELSE1308))
    (progn (|c/out_of_memory| v-new_bytes-1306))
    (go ENDIF1309)
    ELSE1308
    ENDIF1309
    (unless (c-true v-old_bytes-1305) (go ELSE1310))
    (progn (c-memcpy v-chunk-1307 (m-ptr (+ v-solver-1175 1976)) v-old_bytes-1305))
    (go ENDIF1311)
    ELSE1310
    ENDIF1311
    (progn (c-free (m-ptr (+ v-solver-1175 1976))))
    (progn (setf (m-ptr (+ v-solver-1175 1976)) v-chunk-1307))
    (progn (setf (m-size (+ v-solver-1175 16)) v-new_capacity-1176))
  )
  0))

;;; upstream/satch.c:4051:1
(defun |c/increase_size| (arg-v-solver-1312 arg-v-new_size-1313)
 (declare  (type c-address arg-v-solver-1312) (type (unsigned-byte 32) arg-v-new_size-1313))
 (let ((v-solver-1312 0) (v-new_size-1313 0) (v-old_capacity-1314 0) (v-new_capacity-1317 0))
 (declare (type c-address v-solver-1312) (type (unsigned-byte 32) v-new_size-1313) (type (unsigned-byte 32) v-old_capacity-1314) (type (unsigned-byte 32) v-new_capacity-1317) (ignorable v-solver-1312 v-new_size-1313 v-old_capacity-1314 v-new_capacity-1317))
 (tagbody
    (setf v-solver-1312 arg-v-solver-1312)
    (setf v-new_size-1313 arg-v-new_size-1313)
    (setf v-old_capacity-1314 (c-u32 (m-size (+ v-solver-1312 16))))
    (unless (c-true (if (> v-new_size-1313 v-old_capacity-1314) 1 0)) (go ELSE1315))
    (unless (c-true (if (> v-new_size-1313 (c-u32 (ash (c-u32 1) 30))) 1 0)) (go ELSE1318))
    (progn (setf v-new_capacity-1317 (c-u32 (ash (c-u32 1) 31))))
    (go ENDIF1319)
    ELSE1318
    (progn (setf v-new_capacity-1317 (c-u32 1)))
    LOOP1320
    (unless (c-true (if (> v-new_size-1313 v-new_capacity-1317) 1 0)) (go ENDLOOP1321))
    (progn (setf v-new_capacity-1317 (c-u32 (c-u32 (* v-new_capacity-1317 (c-u32 2))))))
    (go LOOP1320)
    ENDLOOP1321
    ENDIF1319
    (progn (|c/increase_capacity| v-solver-1312 v-new_capacity-1317))
    (go ENDIF1316)
    ELSE1315
    ENDIF1316
    (progn v-solver-1312)
    (progn (setf (m-u32 (+ v-solver-1312 12)) v-new_size-1313))
  )
  0))

;;; upstream/satch.c:4092:1
(defun |c/mark_literal| (arg-v-marks-1327 arg-v-lit-1328)
 (declare  (type c-address arg-v-marks-1327) (type (unsigned-byte 32) arg-v-lit-1328))
 (let ((v-marks-1327 0) (v-lit-1328 0) (v-idx-1329 0))
 (declare (type c-address v-marks-1327) (type (unsigned-byte 32) v-lit-1328) (type (unsigned-byte 32) v-idx-1329) (ignorable v-marks-1327 v-lit-1328 v-idx-1329))
 (tagbody
    (setf v-marks-1327 arg-v-marks-1327)
    (setf v-lit-1328 arg-v-lit-1328)
    (setf v-idx-1329 (|c/INDEX| v-lit-1328))
    (progn (setf (m-s8 (+ v-marks-1327 (* 1 v-idx-1329))) (c-s8 (|c/INT_SIGN| v-lit-1328))))
  )
  0))

;;; upstream/satch.c:4100:1
(defun |c/marked_literal| (arg-v-marks-1330 arg-v-lit-1331)
 (declare  (type c-address arg-v-marks-1330) (type (unsigned-byte 32) arg-v-lit-1331))
 (let ((v-marks-1330 0) (v-lit-1331 0) (v-idx-1332 0) (v-res-1333 0))
 (declare (type c-address v-marks-1330) (type (unsigned-byte 32) v-lit-1331) (type (unsigned-byte 32) v-idx-1332) (type (signed-byte 8) v-res-1333) (ignorable v-marks-1330 v-lit-1331 v-idx-1332 v-res-1333))
 (tagbody
    (setf v-marks-1330 arg-v-marks-1330)
    (setf v-lit-1331 arg-v-lit-1331)
    (setf v-idx-1332 (|c/INDEX| v-lit-1331))
    (setf v-res-1333 (m-s8 (+ v-marks-1330 (* 1 v-idx-1332))))
    (unless (c-true (|c/SIGN_BIT| v-lit-1331)) (go ELSE1334))
    (progn (setf v-res-1333 (c-s8 (c-s32 (- v-res-1333)))))
    (go ENDIF1335)
    ELSE1334
    ENDIF1335
    (return-from |c/marked_literal| v-res-1333)
  )
  0))

;;; upstream/satch.c:4110:1
(defun |c/unmark_literal| (arg-v-marks-1336 arg-v-lit-1337)
 (declare  (type c-address arg-v-marks-1336) (type (unsigned-byte 32) arg-v-lit-1337))
 (let ((v-marks-1336 0) (v-lit-1337 0) (v-idx-1338 0))
 (declare (type c-address v-marks-1336) (type (unsigned-byte 32) v-lit-1337) (type (unsigned-byte 32) v-idx-1338) (ignorable v-marks-1336 v-lit-1337 v-idx-1338))
 (tagbody
    (setf v-marks-1336 arg-v-marks-1336)
    (setf v-lit-1337 arg-v-lit-1337)
    (setf v-idx-1338 (|c/INDEX| v-lit-1337))
    (progn (setf (m-s8 (+ v-marks-1336 (* 1 v-idx-1338))) (c-s8 0)))
  )
  0))

;;; upstream/satch.c:4123:1
(defun |c/imported_clause_trivial_or_satisfied| (arg-v-solver-1339)
 (declare  (type c-address arg-v-solver-1339))
 (let ((v-solver-1339 0) (v-end_clause-1340 0) (v-begin_clause-1341 0) (v-q-1342 0) (v-trivial-1343 0) (v-marks-1344 0) (v-values-1345 0) (v-p-1349 0) (v-lit-1350 0) (v-value-1351 0) (v-prev-1362 0) (v-p-1380 0))
 (declare (type c-address v-solver-1339) (type c-address v-end_clause-1340) (type c-address v-begin_clause-1341) (type c-address v-q-1342) (type (integer 0 1) v-trivial-1343) (type c-address v-marks-1344) (type c-address v-values-1345) (type c-address v-p-1349) (type (unsigned-byte 32) v-lit-1350) (type (signed-byte 8) v-value-1351) (type (signed-byte 8) v-prev-1362) (type c-address v-p-1380) (ignorable v-solver-1339 v-end_clause-1340 v-begin_clause-1341 v-q-1342 v-trivial-1343 v-marks-1344 v-values-1345 v-p-1349 v-lit-1350 v-value-1351 v-prev-1362 v-p-1380))
 (tagbody
    (setf v-solver-1339 arg-v-solver-1339)
    (setf v-end_clause-1340 (m-ptr (+ (+ v-solver-1339 624) 8)))
    (setf v-begin_clause-1341 (m-ptr (+ (+ v-solver-1339 624) 0)))
    (setf v-q-1342 v-begin_clause-1341)
    (setf v-trivial-1343 (c-bool 0))
    (setf v-marks-1344 (m-ptr (+ v-solver-1339 96)))
    (setf v-values-1345 (m-ptr (+ v-solver-1339 40)))
    (setf v-p-1349 v-begin_clause-1341)
    LOOP1346
    (unless (c-true (if (/= v-p-1349 v-end_clause-1340) 1 0)) (go ENDLOOP1347))
    (setf v-lit-1350 (m-u32 v-p-1349))
    (setf v-value-1351 (m-s8 (+ v-values-1345 (* 1 v-lit-1350))))
    (unless (c-true (if (< v-value-1351 0) 1 0)) (go ELSE1352))
    (progn v-solver-1339)
    (go CONTINUE1348)
    ELSE1352
    (unless (c-true (if (> v-value-1351 0) 1 0)) (go ELSE1357))
    (progn v-solver-1339)
    (progn (setf v-trivial-1343 (c-bool 1)))
    (go ENDLOOP1347)
    ELSE1357
    (setf v-prev-1362 (|c/marked_literal| v-marks-1344 v-lit-1350))
    (unless (c-true (if (> v-prev-1362 0) 1 0)) (go ELSE1363))
    (progn v-solver-1339)
    (go CONTINUE1348)
    ELSE1363
    (unless (c-true (if (< v-prev-1362 0) 1 0)) (go ELSE1368))
    (progn v-solver-1339)
    (progn (setf v-trivial-1343 (c-bool 1)))
    (go ENDLOOP1347)
    ELSE1368
    (progn (setf (m-u32 (let* ( (old1374 v-q-1342)) (setf v-q-1342 (+ old1374 (* 4 1))) old1374)) v-lit-1350))
    (progn (|c/mark_literal| v-marks-1344 v-lit-1350))
    CONTINUE1348
    (let* ( (old1376 v-p-1349)) (setf v-p-1349 (+ old1376 (* 4 1))) old1376)
    (go LOOP1346)
    ENDLOOP1347
    (progn (setf (m-ptr (+ (+ v-solver-1339 624) 8)) v-q-1342))
    (setf v-p-1380 v-begin_clause-1341)
    LOOP1377
    (unless (c-true (if (/= v-p-1380 v-q-1342) 1 0)) (go ENDLOOP1378))
    (progn (|c/unmark_literal| v-marks-1344 (m-u32 v-p-1380)))
    (let* ( (old1382 v-p-1380)) (setf v-p-1380 (+ old1382 (* 4 1))) old1382)
    (go LOOP1377)
    ENDLOOP1378
    (return-from |c/imported_clause_trivial_or_satisfied| (c-bool v-trivial-1343))
  )
  0))

