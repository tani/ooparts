(in-package #:ooparts/sat/impl)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))
;;; upstream/satch.c:1745:1
(defun |c/print_profiles| (arg-v-solver-105)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-solver-105))
 (let ((v-solver-105 0) (v-stop-106 0d0) (v-profiles-107 0) (v-verbose-108 0) (v-profile-112 0) (v-profile-122 0) (v-profile-132 0) (v-profile-142 0) (v-profile-152 0) (v-profile-162 0) (v-profile-172 0) (v-profile-182 0) (v-profile-192 0) (v-profile-202 0) (v-profile-212 0) (v-size-219 0) (v-i-223 0) (v-p-224 0) (v-j-228 0) (v-q-229 0) (v-total-236 0d0) (v-i-240 0) (v-p-241 0))
 (declare (type c-address v-solver-105) (type double-float v-stop-106) (type c-address v-profiles-107) (type (integer 0 1) v-verbose-108) (type c-address v-profile-112) (type c-address v-profile-122) (type c-address v-profile-132) (type c-address v-profile-142) (type c-address v-profile-152) (type c-address v-profile-162) (type c-address v-profile-172) (type c-address v-profile-182) (type c-address v-profile-192) (type c-address v-profile-202) (type c-address v-profile-212) (type c-size v-size-219) (type c-size v-i-223) (type c-address v-p-224) (type c-size v-j-228) (type c-address v-q-229) (type double-float v-total-236) (type c-size v-i-240) (type c-address v-p-241) (ignorable v-solver-105 v-stop-106 v-profiles-107 v-verbose-108 v-profile-112 v-profile-122 v-profile-132 v-profile-142 v-profile-152 v-profile-162 v-profile-172 v-profile-182 v-profile-192 v-profile-202 v-profile-212 v-size-219 v-i-223 v-p-224 v-j-228 v-q-229 v-total-236 v-i-240 v-p-241))
 (tagbody
    (setf v-solver-105 arg-v-solver-105)
    (setf v-stop-106 (|c/flush_profiles| v-solver-105))
    (progn (|c/internal_section| v-solver-105 |c/string/27|))
    (setf v-profiles-107 (+ v-solver-105 1472))
    (setf v-verbose-108 (c-bool (if (> (m-u32 (+ (+ v-solver-105 880) 4)) (c-u32 1)) 1 0)))
    (setf v-profile-112 (+ v-profiles-107 0))
    (unless (c-true (if (= v-profile-112 (+ v-profiles-107 240)) 1 0)) (go ELSE113))
    (go ENDLOOP110)
    ELSE113
    (unless (c-true (if (c-true (if (c-true v-verbose-108) 0 1)) (c-bool (if (c-true (m-f64 (+ v-profile-112 8))) 0 1)) 0)) (go ELSE115))
    (go ENDLOOP110)
    ELSE115
    (progn (setf (m-ptr (let* ((a117 (+ v-profiles-107 392)) (old118 (m-ptr a117))) (setf (m-ptr a117) (+ old118 (* 8 1))) old118)) (+ v-profiles-107 0)))
    ENDLOOP110
    (setf v-profile-122 (+ v-profiles-107 24))
    (unless (c-true (if (= v-profile-122 (+ v-profiles-107 240)) 1 0)) (go ELSE123))
    (go ENDLOOP120)
    ELSE123
    (unless (c-true (if (c-true (if (c-true v-verbose-108) 0 1)) (c-bool (if (c-true (m-f64 (+ v-profile-122 8))) 0 1)) 0)) (go ELSE125))
    (go ENDLOOP120)
    ELSE125
    (progn (setf (m-ptr (let* ((a127 (+ v-profiles-107 392)) (old128 (m-ptr a127))) (setf (m-ptr a127) (+ old128 (* 8 1))) old128)) (+ v-profiles-107 24)))
    ENDLOOP120
    (setf v-profile-132 (+ v-profiles-107 48))
    (unless (c-true (if (= v-profile-132 (+ v-profiles-107 240)) 1 0)) (go ELSE133))
    (go ENDLOOP130)
    ELSE133
    (unless (c-true (if (c-true (if (c-true v-verbose-108) 0 1)) (c-bool (if (c-true (m-f64 (+ v-profile-132 8))) 0 1)) 0)) (go ELSE135))
    (go ENDLOOP130)
    ELSE135
    (progn (setf (m-ptr (let* ((a137 (+ v-profiles-107 392)) (old138 (m-ptr a137))) (setf (m-ptr a137) (+ old138 (* 8 1))) old138)) (+ v-profiles-107 48)))
    ENDLOOP130
    (setf v-profile-142 (+ v-profiles-107 72))
    (unless (c-true (if (= v-profile-142 (+ v-profiles-107 240)) 1 0)) (go ELSE143))
    (go ENDLOOP140)
    ELSE143
    (unless (c-true (if (c-true (if (c-true v-verbose-108) 0 1)) (c-bool (if (c-true (m-f64 (+ v-profile-142 8))) 0 1)) 0)) (go ELSE145))
    (go ENDLOOP140)
    ELSE145
    (progn (setf (m-ptr (let* ((a147 (+ v-profiles-107 392)) (old148 (m-ptr a147))) (setf (m-ptr a147) (+ old148 (* 8 1))) old148)) (+ v-profiles-107 72)))
    ENDLOOP140
    (setf v-profile-152 (+ v-profiles-107 96))
    (unless (c-true (if (= v-profile-152 (+ v-profiles-107 240)) 1 0)) (go ELSE153))
    (go ENDLOOP150)
    ELSE153
    (unless (c-true (if (c-true (if (c-true v-verbose-108) 0 1)) (c-bool (if (c-true (m-f64 (+ v-profile-152 8))) 0 1)) 0)) (go ELSE155))
    (go ENDLOOP150)
    ELSE155
    (progn (setf (m-ptr (let* ((a157 (+ v-profiles-107 392)) (old158 (m-ptr a157))) (setf (m-ptr a157) (+ old158 (* 8 1))) old158)) (+ v-profiles-107 96)))
    ENDLOOP150
    (setf v-profile-162 (+ v-profiles-107 120))
    (unless (c-true (if (= v-profile-162 (+ v-profiles-107 240)) 1 0)) (go ELSE163))
    (go ENDLOOP160)
    ELSE163
    (unless (c-true (if (c-true (if (c-true v-verbose-108) 0 1)) (c-bool (if (c-true (m-f64 (+ v-profile-162 8))) 0 1)) 0)) (go ELSE165))
    (go ENDLOOP160)
    ELSE165
    (progn (setf (m-ptr (let* ((a167 (+ v-profiles-107 392)) (old168 (m-ptr a167))) (setf (m-ptr a167) (+ old168 (* 8 1))) old168)) (+ v-profiles-107 120)))
    ENDLOOP160
    (setf v-profile-172 (+ v-profiles-107 144))
    (unless (c-true (if (= v-profile-172 (+ v-profiles-107 240)) 1 0)) (go ELSE173))
    (go ENDLOOP170)
    ELSE173
    (unless (c-true (if (c-true (if (c-true v-verbose-108) 0 1)) (c-bool (if (c-true (m-f64 (+ v-profile-172 8))) 0 1)) 0)) (go ELSE175))
    (go ENDLOOP170)
    ELSE175
    (progn (setf (m-ptr (let* ((a177 (+ v-profiles-107 392)) (old178 (m-ptr a177))) (setf (m-ptr a177) (+ old178 (* 8 1))) old178)) (+ v-profiles-107 144)))
    ENDLOOP170
    (setf v-profile-182 (+ v-profiles-107 168))
    (unless (c-true (if (= v-profile-182 (+ v-profiles-107 240)) 1 0)) (go ELSE183))
    (go ENDLOOP180)
    ELSE183
    (unless (c-true (if (c-true (if (c-true v-verbose-108) 0 1)) (c-bool (if (c-true (m-f64 (+ v-profile-182 8))) 0 1)) 0)) (go ELSE185))
    (go ENDLOOP180)
    ELSE185
    (progn (setf (m-ptr (let* ((a187 (+ v-profiles-107 392)) (old188 (m-ptr a187))) (setf (m-ptr a187) (+ old188 (* 8 1))) old188)) (+ v-profiles-107 168)))
    ENDLOOP180
    (setf v-profile-192 (+ v-profiles-107 192))
    (unless (c-true (if (= v-profile-192 (+ v-profiles-107 240)) 1 0)) (go ELSE193))
    (go ENDLOOP190)
    ELSE193
    (unless (c-true (if (c-true (if (c-true v-verbose-108) 0 1)) (c-bool (if (c-true (m-f64 (+ v-profile-192 8))) 0 1)) 0)) (go ELSE195))
    (go ENDLOOP190)
    ELSE195
    (progn (setf (m-ptr (let* ((a197 (+ v-profiles-107 392)) (old198 (m-ptr a197))) (setf (m-ptr a197) (+ old198 (* 8 1))) old198)) (+ v-profiles-107 192)))
    ENDLOOP190
    (setf v-profile-202 (+ v-profiles-107 216))
    (unless (c-true (if (= v-profile-202 (+ v-profiles-107 240)) 1 0)) (go ELSE203))
    (go ENDLOOP200)
    ELSE203
    (unless (c-true (if (c-true (if (c-true v-verbose-108) 0 1)) (c-bool (if (c-true (m-f64 (+ v-profile-202 8))) 0 1)) 0)) (go ELSE205))
    (go ENDLOOP200)
    ELSE205
    (progn (setf (m-ptr (let* ((a207 (+ v-profiles-107 392)) (old208 (m-ptr a207))) (setf (m-ptr a207) (+ old208 (* 8 1))) old208)) (+ v-profiles-107 216)))
    ENDLOOP200
    (setf v-profile-212 (+ v-profiles-107 240))
    (unless (c-true (if (= v-profile-212 (+ v-profiles-107 240)) 1 0)) (go ELSE213))
    (go ENDLOOP210)
    ELSE213
    (unless (c-true (if (c-true (if (c-true v-verbose-108) 0 1)) (c-bool (if (c-true (m-f64 (+ v-profile-212 8))) 0 1)) 0)) (go ELSE215))
    (go ENDLOOP210)
    ELSE215
    (progn (setf (m-ptr (let* ((a217 (+ v-profiles-107 392)) (old218 (m-ptr a217))) (setf (m-ptr a217) (+ old218 (* 8 1))) old218)) (+ v-profiles-107 240)))
    ENDLOOP210
    (setf v-size-219 (the c-size (truncate (- (m-ptr (+ v-profiles-107 392)) (+ v-profiles-107 264)) 8)))
    (setf v-i-223 (c-u64 0))
    LOOP220
    (unless (c-true (if (< v-i-223 v-size-219) 1 0)) (go ENDLOOP221))
    (setf v-p-224 (m-ptr (+ (+ v-profiles-107 264) (* 8 v-i-223))))
    (setf v-j-228 (c-u64 (+ v-i-223 (c-u64 1))))
    LOOP225
    (unless (c-true (if (< v-j-228 v-size-219) 1 0)) (go ENDLOOP226))
    (setf v-q-229 (m-ptr (+ (+ v-profiles-107 264) (* 8 v-j-228))))
    (unless (c-true (if (c-true (if (< (m-f64 (+ v-p-224 8)) (m-f64 (+ v-q-229 8))) 1 0)) 1 (c-bool (if (c-true (if (= (m-f64 (+ v-p-224 8)) (m-f64 (+ v-q-229 8))) 1 0)) (c-bool (if (> (c-strcmp (m-ptr (+ v-p-224 16)) (m-ptr (+ v-q-229 16))) 0) 1 0)) 0)))) (go ELSE230))
    (progn (setf (m-ptr (+ (+ v-profiles-107 264) (* 8 v-i-223))) v-q-229))
    (progn (setf (m-ptr (+ (+ v-profiles-107 264) (* 8 v-j-228))) v-p-224))
    (progn (setf v-p-224 v-q-229))
    (go ENDIF231)
    ELSE230
    ENDIF231
    (let* ( (old233 v-j-228)) (setf v-j-228 (c-u64 (c-u64 (+ old233 (c-u64 1))))) old233)
    (go LOOP225)
    ENDLOOP226
    (let* ( (old235 v-i-223)) (setf v-i-223 (c-u64 (c-u64 (+ old235 (c-u64 1))))) old235)
    (go LOOP220)
    ENDLOOP221
    (setf v-total-236 (m-f64 (+ (+ v-profiles-107 240) 8)))
    (setf v-i-240 (c-u64 0))
    LOOP237
    (unless (c-true (if (< v-i-240 v-size-219) 1 0)) (go ENDLOOP238))
    (setf v-p-241 (m-ptr (+ (+ v-profiles-107 264) (* 8 v-i-240))))
    (progn (c-printf |c/string/28| (m-f64 (+ v-p-241 8)) (|c/percent| (m-f64 (+ v-p-241 8)) v-total-236) (m-ptr (+ v-p-241 16))))
    (let* ( (old243 v-i-240)) (setf v-i-240 (c-u64 (c-u64 (+ old243 (c-u64 1))))) old243)
    (go LOOP237)
    ENDLOOP238
    (progn (c-fputs |c/string/29| 1))
    (progn (c-printf |c/string/30| v-total-236 100.0d0))
    (return-from |c/print_profiles| v-stop-106)
  )
  0))

;;; upstream/satch.c:1816:1
(defun |c/print_statistics| (arg-v-solver-244 arg-v-seconds-245)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-solver-244) (type double-float arg-v-seconds-245))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-244 0) (v-seconds-245 0d0) (v-s-246 (stack-alloc 456)) (v-verbose-247 0))
 (declare (type c-address v-solver-244) (type double-float v-seconds-245) (type c-address v-s-246) (type (integer 0 1) v-verbose-247) (ignorable v-solver-244 v-seconds-245 v-s-246 v-verbose-247))
 (tagbody
    (setf v-solver-244 arg-v-solver-244)
    (setf v-seconds-245 arg-v-seconds-245)
    (progn (|c/internal_section| v-solver-244 |c/string/31|))
    (copy-bytes v-s-246 (+ v-solver-244 1016) 456)
    (setf v-verbose-247 (c-bool (if (> (m-u32 (+ (+ v-solver-244 880) 4)) (c-u32 1)) 1 0)))
    (unless (c-true v-verbose-247) (go ELSE248))
    (progn (c-printf |c/string/32| |c/string/33| (m-u64 (+ v-s-246 16)) |c/string/2|))
    (go ENDIF249)
    ELSE248
    ENDIF249
    (progn (c-printf |c/string/34| |c/string/35| (m-u64 (+ v-s-246 24)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 48)) nil) (integer64-double (m-u64 (+ v-s-246 24)) nil))))
    (unless (c-true v-verbose-247) (go ELSE250))
    (progn (c-printf |c/string/36| |c/string/37| (m-u64 (+ v-s-246 32)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 32)) nil) (integer64-double (m-u64 (+ v-s-246 48)) nil))))
    (go ENDIF251)
    ELSE250
    ENDIF251
    (unless (c-true v-verbose-247) (go ELSE252))
    (progn (c-printf |c/string/38| |c/string/39| (m-u64 (+ v-s-246 344)) (|c/percent| (integer64-double (m-u64 (+ v-s-246 344)) nil) (integer64-double (m-u64 (+ v-s-246 128)) nil))))
    (go ENDIF253)
    ELSE252
    ENDIF253
    (unless (c-true v-verbose-247) (go ELSE254))
    (progn (c-printf |c/string/40| |c/string/41| (m-u64 (+ v-s-246 352)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 352)) nil) (integer64-double (m-u64 (+ v-s-246 344)) nil))))
    (go ENDIF255)
    ELSE254
    ENDIF255
    (progn (c-printf |c/string/42| |c/string/43| (m-u64 (+ v-s-246 40)) (float (/ (integer64-double (m-u64 (+ v-s-246 40)) nil) (float (c-u32 (ash (c-u32 1) 20)) 1d0)) 1d0)))
    (progn (c-printf |c/string/44| |c/string/45| (m-u64 (+ v-s-246 48)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 48)) nil) v-seconds-245)))
    (progn (c-printf |c/string/46| |c/string/47| (m-u64 (+ v-s-246 64)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 64)) nil) (integer64-double (m-u64 (+ v-s-246 48)) nil))))
    (unless (c-true v-verbose-247) (go ELSE256))
    (progn (c-printf |c/string/36| |c/string/48| (m-u64 (+ v-s-246 72)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 72)) nil) (integer64-double (m-u64 (+ v-s-246 48)) nil))))
    (go ENDIF257)
    ELSE256
    ENDIF257
    (unless (c-true v-verbose-247) (go ELSE258))
    (progn (c-printf |c/string/49| |c/string/50| (m-u64 (+ v-s-246 56)) (|c/percent| (integer64-double (m-u64 (+ v-s-246 56)) nil) (integer64-double (m-u64 (+ v-s-246 16)) nil))))
    (go ENDIF259)
    ELSE258
    ENDIF259
    (progn (c-printf |c/string/51| |c/string/52| (m-u64 (+ v-s-246 80)) (|c/percent| (integer64-double (m-u64 (+ v-s-246 80)) nil) (integer64-double (m-u64 (+ v-s-246 368)) nil))))
    (unless (c-true v-verbose-247) (go ELSE260))
    (progn (c-printf |c/string/34| |c/string/53| (m-u64 (+ v-s-246 96)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 48)) nil) (integer64-double (m-u64 (+ v-s-246 96)) nil))))
    (go ENDIF261)
    ELSE260
    ENDIF261
    (progn (c-printf |c/string/51| |c/string/54| (m-u64 (+ v-s-246 104)) (|c/percent| (integer64-double (m-u64 (+ v-s-246 104)) nil) (integer64-double (m-u64 (+ v-s-246 368)) nil))))
    (progn (c-printf |c/string/36| |c/string/55| (m-u64 (+ v-s-246 128)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 128)) nil) (integer64-double (m-u64 (+ v-s-246 48)) nil))))
    (unless (c-true v-verbose-247) (go ELSE262))
    (progn (c-printf |c/string/56| |c/string/57| (m-u64 (+ v-s-246 112)) (|c/percent| (integer64-double (m-u64 (+ v-s-246 112)) nil) (integer64-double (m-u64 (+ v-s-246 32)) nil))))
    (go ENDIF263)
    ELSE262
    ENDIF263
    (unless (c-true v-verbose-247) (go ELSE264))
    (progn (c-printf |c/string/58| |c/string/59| (m-u64 (+ v-s-246 152)) (|c/percent| (integer64-double (m-u64 (+ v-s-246 152)) nil) (integer64-double (m-u64 (+ v-s-246 72)) nil))))
    (go ENDIF265)
    ELSE264
    ENDIF265
    (unless (c-true v-verbose-247) (go ELSE266))
    (progn (c-printf |c/string/56| |c/string/60| (m-u64 (+ v-s-246 160)) (|c/percent| (integer64-double (m-u64 (+ v-s-246 160)) nil) (integer64-double (m-u64 (+ v-s-246 32)) nil))))
    (go ENDIF267)
    ELSE266
    ENDIF267
    (progn (c-printf |c/string/44| |c/string/61| (m-u64 (+ v-s-246 168)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 168)) nil) v-seconds-245)))
    (unless (c-true v-verbose-247) (go ELSE268))
    (progn (c-printf |c/string/56| |c/string/62| (m-u64 (+ v-s-246 176)) (|c/percent| (integer64-double (m-u64 (+ v-s-246 176)) nil) (integer64-double (m-u64 (+ v-s-246 32)) nil))))
    (go ENDIF269)
    ELSE268
    ENDIF269
    (progn (c-printf |c/string/63| |c/string/64| (m-u64 (+ v-s-246 192)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 192)) nil) (integer64-double (m-u64 (+ v-s-246 200)) nil))))
    (unless (c-true v-verbose-247) (go ELSE270))
    (progn (c-printf |c/string/34| |c/string/65| (m-u64 (+ v-s-246 200)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 48)) nil) (integer64-double (m-u64 (+ v-s-246 200)) nil))))
    (go ENDIF271)
    ELSE270
    ENDIF271
    (progn (c-printf |c/string/34| |c/string/66| (m-u64 (+ v-s-246 224)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 48)) nil) (integer64-double (m-u64 (+ v-s-246 224)) nil))))
    (progn (c-printf |c/string/34| |c/string/67| (m-u64 (+ v-s-246 240)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 48)) nil) (integer64-double (m-u64 (+ v-s-246 240)) nil))))
    (progn (c-printf |c/string/34| |c/string/68| (m-u64 (+ v-s-246 248)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 48)) nil) (integer64-double (m-u64 (+ v-s-246 248)) nil))))
    (progn (c-printf |c/string/69| |c/string/70| (m-u64 (+ v-s-246 184)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 184)) nil) (integer64-double (m-u64 (+ v-s-246 368)) nil))))
    (progn (c-printf |c/string/34| |c/string/71| (m-u64 (+ v-s-246 256)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 48)) nil) (integer64-double (m-u64 (+ v-s-246 256)) nil))))
    (unless (c-true v-verbose-247) (go ELSE272))
    (progn (c-printf |c/string/72| |c/string/73| (m-u64 (+ v-s-246 264)) (|c/percent| (integer64-double (m-u64 (+ v-s-246 264)) nil) (integer64-double (m-u64 (+ v-s-246 256)) nil))))
    (go ENDIF273)
    ELSE272
    ENDIF273
    (unless (c-true v-verbose-247) (go ELSE274))
    (progn (c-printf |c/string/58| |c/string/74| (m-u64 (+ v-s-246 280)) (|c/percent| (integer64-double (m-u64 (+ v-s-246 280)) nil) (integer64-double (m-u64 (+ v-s-246 72)) nil))))
    (go ENDIF275)
    ELSE274
    ENDIF275
    (progn (c-printf |c/string/49| |c/string/75| (m-u64 (+ v-s-246 296)) (|c/percent| (integer64-double (m-u64 (+ v-s-246 296)) nil) (integer64-double (m-u64 (+ v-s-246 16)) nil))))
    (progn (c-printf |c/string/49| |c/string/76| (m-u64 (+ v-s-246 320)) (|c/percent| (integer64-double (m-u64 (+ v-s-246 320)) nil) (integer64-double (m-u64 (+ v-s-246 16)) nil))))
    (unless (c-true v-verbose-247) (go ELSE276))
    (progn (c-printf |c/string/34| |c/string/77| (m-u64 (+ v-s-246 312)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 48)) nil) (integer64-double (m-u64 (+ v-s-246 312)) nil))))
    (go ENDIF277)
    ELSE276
    ENDIF277
    (unless (c-true v-verbose-247) (go ELSE278))
    (progn (c-printf |c/string/34| |c/string/78| (m-u64 (+ v-s-246 328)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 48)) nil) (integer64-double (m-u64 (+ v-s-246 328)) nil))))
    (go ENDIF279)
    ELSE278
    ENDIF279
    (unless (c-true v-verbose-247) (go ELSE280))
    (progn (c-printf |c/string/34| |c/string/79| (m-u64 (+ v-s-246 336)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 48)) nil) (integer64-double (m-u64 (+ v-s-246 336)) nil))))
    (go ENDIF281)
    ELSE280
    ENDIF281
    (progn (c-printf |c/string/80| |c/string/81| (m-u64 (+ v-s-246 408)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 408)) nil) (integer64-double (m-u64 (+ v-s-246 416)) nil))))
    (progn (c-printf |c/string/80| |c/string/82| (m-u64 (+ v-s-246 448)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 448)) nil) (integer64-double (m-u64 (+ v-s-246 416)) nil))))
    (progn (c-printf |c/string/83| |c/string/84| (m-u64 (+ v-s-246 440)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 440)) nil) (integer64-double (m-u64 (+ v-s-246 448)) nil))))
    (progn (c-printf |c/string/80| |c/string/85| (m-u64 (+ v-s-246 400)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 400)) nil) (integer64-double (m-u64 (+ v-s-246 416)) nil))))
    (progn (c-printf |c/string/80| |c/string/86| (m-u64 (+ v-s-246 392)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 392)) nil) (integer64-double (m-u64 (+ v-s-246 416)) nil))))
    (unless (c-true v-verbose-247) (go ELSE282))
    (progn (c-printf |c/string/87| |c/string/88| (m-u64 (+ v-s-246 376)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 376)) nil) (integer64-double (m-u64 (+ v-s-246 408)) nil))))
    (go ENDIF283)
    ELSE282
    ENDIF283
    (unless (c-true v-verbose-247) (go ELSE284))
    (progn (c-printf |c/string/89| |c/string/90| (m-u64 (+ v-s-246 360)) (|c/relative| (integer64-double (m-u64 (+ v-s-246 360)) nil) (integer64-double (m-u64 (+ v-s-246 168)) nil))))
    (go ENDIF285)
    ELSE284
    ENDIF285
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:1977:1
(defun |c/print_resource_usage| (arg-v-solver-286 arg-v-seconds-287)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-solver-286) (type double-float arg-v-seconds-287))
 (let ((v-solver-286 0) (v-seconds-287 0d0) (v-memory-288 0))
 (declare (type c-address v-solver-286) (type double-float v-seconds-287) (type (unsigned-byte 64) v-memory-288) (ignorable v-solver-286 v-seconds-287 v-memory-288))
 (tagbody
    (setf v-solver-286 arg-v-solver-286)
    (setf v-seconds-287 arg-v-seconds-287)
    (progn (|c/internal_section| v-solver-286 |c/string/91|))
    (locally (declare (optimize (speed 1))) (setf v-memory-288 (|c/maximum_resident_set_size|)))
    (progn (c-printf |c/string/92| |c/string/93| v-memory-288 (float (/ (integer64-double v-memory-288 nil) (float (c-s32 (ash (c-s32 1) 20)) 1d0)) 1d0)))
    (progn (c-printf |c/string/94| |c/string/95| |c/string/2| v-seconds-287))
  )
  0))

;;; upstream/satch.c:2002:1
(defun |c/start_addition_proof_line| (arg-v-solver-289)
 (declare  (type c-address arg-v-solver-289))
 (let ((v-solver-289 0))
 (declare (type c-address v-solver-289) (ignorable v-solver-289))
 (tagbody
    (setf v-solver-289 arg-v-solver-289)
    (unless (c-true (if (c-true (m-u8 (+ (+ v-solver-289 880) 0))) 0 1)) (go ELSE290))
    (progn (c-fputc 97 (m-ptr (+ v-solver-289 1896))))
    (go ENDIF291)
    ELSE290
    ENDIF291
  )
  0))

;;; upstream/satch.c:2010:1
(defun |c/start_deletion_proof_line| (arg-v-solver-292)
 (declare  (type c-address arg-v-solver-292))
 (let ((v-solver-292 0))
 (declare (type c-address v-solver-292) (ignorable v-solver-292))
 (tagbody
    (setf v-solver-292 arg-v-solver-292)
    (progn (c-fputc 100 (m-ptr (+ v-solver-292 1896))))
    (unless (c-true (m-u8 (+ (+ v-solver-292 880) 0))) (go ELSE293))
    (progn (c-fputc 32 (m-ptr (+ v-solver-292 1896))))
    (go ENDIF294)
    ELSE293
    ENDIF294
  )
  0))

;;; upstream/satch.c:2019:1
(defun |c/add_external_literal_to_proof_line| (arg-v-solver-295 arg-v-elit-296)
 (declare  (type c-address arg-v-solver-295) (type (signed-byte 32) arg-v-elit-296))
 (let ((v-solver-295 0) (v-elit-296 0) (v-plit-299 0) (v-rest-300 0) (v-byte-304 0))
 (declare (type c-address v-solver-295) (type (signed-byte 32) v-elit-296) (type (unsigned-byte 32) v-plit-299) (type (unsigned-byte 32) v-rest-300) (type (unsigned-byte 8) v-byte-304) (ignorable v-solver-295 v-elit-296 v-plit-299 v-rest-300 v-byte-304))
 (tagbody
    (setf v-solver-295 arg-v-solver-295)
    (setf v-elit-296 arg-v-elit-296)
    (unless (c-true (m-u8 (+ (+ v-solver-295 880) 0))) (go ELSE297))
    (progn (c-fprintf (m-ptr (+ v-solver-295 1896)) |c/string/96| v-elit-296))
    (go ENDIF298)
    ELSE297
    (setf v-plit-299 (c-u32 (+ (c-u32 (* 2 (c-u32 (c-abs v-elit-296)))) (c-u32 (if (< v-elit-296 0) 1 0)))))
    (setf v-rest-300 v-plit-299)
    LOOP301
    (unless (c-true (c-u32 (logand v-rest-300 (c-u32 (c-s32 (lognot 127)))))) (go ENDLOOP302))
    (setf v-byte-304 (c-u8 (c-u32 (logior (c-u32 (logand v-rest-300 (c-u32 127))) (c-u32 128)))))
    (progn (c-fputc v-byte-304 (m-ptr (+ v-solver-295 1896))))
    (progn (setf v-rest-300 (c-u32 (c-u32 (ash (c-u32 v-rest-300) (- 7))))))
    (go LOOP301)
    ENDLOOP302
    (progn (c-fputc (c-u8 v-rest-300) (m-ptr (+ v-solver-295 1896))))
    ENDIF298
  )
  0))

;;; upstream/satch.c:2052:1
(defun |c/add_internal_literal_to_proof_line| (arg-v-solver-306 arg-v-ilit-307)
 (declare  (type c-address arg-v-solver-306) (type (unsigned-byte 32) arg-v-ilit-307))
 (let ((v-solver-306 0) (v-ilit-307 0) (v-elit-308 0))
 (declare (type c-address v-solver-306) (type (unsigned-byte 32) v-ilit-307) (type (signed-byte 32) v-elit-308) (ignorable v-solver-306 v-ilit-307 v-elit-308))
 (tagbody
    (setf v-solver-306 arg-v-solver-306)
    (setf v-ilit-307 arg-v-ilit-307)
    (setf v-elit-308 (c-s32 (|c/export_literal| v-ilit-307)))
    (progn (|c/add_external_literal_to_proof_line| v-solver-306 v-elit-308))
  )
  0))

;;; upstream/satch.c:2059:1
(defun |c/end_proof_line| (arg-v-solver-309)
 (declare  (type c-address arg-v-solver-309))
 (let ((v-solver-309 0))
 (declare (type c-address v-solver-309) (ignorable v-solver-309))
 (tagbody
    (setf v-solver-309 arg-v-solver-309)
    (unless (c-true (m-u8 (+ (+ v-solver-309 880) 0))) (go ELSE310))
    (progn (c-fputs |c/string/97| (m-ptr (+ v-solver-309 1896))))
    (go ENDIF311)
    ELSE310
    (progn (c-fputc 0 (m-ptr (+ v-solver-309 1896))))
    ENDIF311
    (progn (c-fflush (m-ptr (+ v-solver-309 1896))))
  )
  0))

;;; upstream/satch.c:2081:1
(defun |c/trace_and_check_addition| (arg-v-solver-312 arg-v-size-313 arg-v-literals-314 arg-v-except-315)
 (declare  (type c-address arg-v-solver-312) (type c-size arg-v-size-313) (type c-address arg-v-literals-314) (type (unsigned-byte 32) arg-v-except-315))
 (let ((v-solver-312 0) (v-size-313 0) (v-literals-314 0) (v-except-315 0) (v-lit-321 0) (v-P_lit-322 0) (v-END_lit-323 0))
 (declare (type c-address v-solver-312) (type c-size v-size-313) (type c-address v-literals-314) (type (unsigned-byte 32) v-except-315) (type (unsigned-byte 32) v-lit-321) (type c-address v-P_lit-322) (type c-address v-END_lit-323) (ignorable v-solver-312 v-size-313 v-literals-314 v-except-315 v-lit-321 v-P_lit-322 v-END_lit-323))
 (tagbody
    (setf v-solver-312 arg-v-solver-312)
    (setf v-size-313 arg-v-size-313)
    (setf v-literals-314 arg-v-literals-314)
    (setf v-except-315 arg-v-except-315)
    (unless (c-true (m-ptr (+ v-solver-312 1896))) (go ELSE316))
    (progn (|c/start_addition_proof_line| v-solver-312))
    (setf v-P_lit-322 v-literals-314)
    (setf v-END_lit-323 (+ v-P_lit-322 (* 4 v-size-313)))
    LOOP318
    (unless (c-true (if (c-true (if (/= v-P_lit-322 v-END_lit-323) 1 0)) (c-bool (progn (setf v-lit-321 (m-u32 v-P_lit-322)) 1)) 0)) (go ENDLOOP319))
    (unless (c-true (if (/= v-lit-321 v-except-315) 1 0)) (go ELSE324))
    (progn (|c/add_internal_literal_to_proof_line| v-solver-312 v-lit-321))
    (go ENDIF325)
    ELSE324
    ENDIF325
    (let* ( (old327 v-P_lit-322)) (setf v-P_lit-322 (+ old327 (* 4 1))) v-P_lit-322)
    (go LOOP318)
    ENDLOOP319
    (progn (|c/end_proof_line| v-solver-312))
    (go ENDIF317)
    ELSE316
    ENDIF317
  )
  0))

;;; upstream/satch.c:2103:1
(defun |c/trace_and_check_deletion| (arg-v-solver-328 arg-v-size-329 arg-v-literals-330)
 (declare  (type c-address arg-v-solver-328) (type c-size arg-v-size-329) (type c-address arg-v-literals-330))
 (let ((v-solver-328 0) (v-size-329 0) (v-literals-330 0) (v-lit-336 0) (v-P_lit-337 0) (v-END_lit-338 0))
 (declare (type c-address v-solver-328) (type c-size v-size-329) (type c-address v-literals-330) (type (unsigned-byte 32) v-lit-336) (type c-address v-P_lit-337) (type c-address v-END_lit-338) (ignorable v-solver-328 v-size-329 v-literals-330 v-lit-336 v-P_lit-337 v-END_lit-338))
 (tagbody
    (setf v-solver-328 arg-v-solver-328)
    (setf v-size-329 arg-v-size-329)
    (setf v-literals-330 arg-v-literals-330)
    (unless (c-true (m-ptr (+ v-solver-328 1896))) (go ELSE331))
    (progn (|c/start_deletion_proof_line| v-solver-328))
    (setf v-P_lit-337 v-literals-330)
    (setf v-END_lit-338 (+ v-P_lit-337 (* 4 v-size-329)))
    LOOP333
    (unless (c-true (if (c-true (if (/= v-P_lit-337 v-END_lit-338) 1 0)) (c-bool (progn (setf v-lit-336 (m-u32 v-P_lit-337)) 1)) 0)) (go ENDLOOP334))
    (progn (|c/add_internal_literal_to_proof_line| v-solver-328 v-lit-336))
    (let* ( (old340 v-P_lit-337)) (setf v-P_lit-337 (+ old340 (* 4 1))) v-P_lit-337)
    (go LOOP333)
    ENDLOOP334
    (progn (|c/end_proof_line| v-solver-328))
    (go ENDIF332)
    ELSE331
    ENDIF332
  )
  0))

;;; upstream/satch.c:2121:1
(defun |c/trace_and_check_empty_addition| (arg-v-solver-341)
 (declare  (type c-address arg-v-solver-341))
 (let ((v-solver-341 0))
 (declare (type c-address v-solver-341) (ignorable v-solver-341))
 (tagbody
    (setf v-solver-341 arg-v-solver-341)
    (progn (|c/trace_and_check_addition| v-solver-341 (c-u64 0) 0 4294967295))
  )
  0))

;;; upstream/satch.c:2127:1
(defun |c/trace_and_check_unit_addition| (arg-v-solver-342 arg-v-unit-343)
 (declare  (type c-address arg-v-solver-342) (type (unsigned-byte 32) arg-v-unit-343))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-342 0) (v-unit-343 (stack-alloc 4)))
 (declare (type c-address v-solver-342) (type c-address v-unit-343) (ignorable v-solver-342 v-unit-343))
 (tagbody
    (setf v-solver-342 arg-v-solver-342)
    (setf (m-u32 v-unit-343) (c-u32 arg-v-unit-343))
    (progn (|c/trace_and_check_addition| v-solver-342 (c-u64 1) v-unit-343 4294967295))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:2135:1
(defun |c/trace_and_check_temporary_addition| (arg-v-solver-344)
 (declare  (type c-address arg-v-solver-344))
 (let ((v-solver-344 0) (v-size-345 0))
 (declare (type c-address v-solver-344) (type c-size v-size-345) (ignorable v-solver-344 v-size-345))
 (tagbody
    (setf v-solver-344 arg-v-solver-344)
    (setf v-size-345 (the c-size (truncate (- (m-ptr (+ (+ v-solver-344 624) 8)) (m-ptr (+ (+ v-solver-344 624) 0))) 4)))
    (progn (|c/trace_and_check_addition| v-solver-344 v-size-345 (m-ptr (+ (+ v-solver-344 624) 0)) 4294967295))
  )
  0))

;;; upstream/satch.c:2146:1
(defun |c/trace_and_check_binary_deletion| (arg-v-solver-346 arg-v-lit-347 arg-v-other-348)
 (declare  (type c-address arg-v-solver-346) (type (unsigned-byte 32) arg-v-lit-347) (type (unsigned-byte 32) arg-v-other-348))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-346 0) (v-lit-347 0) (v-other-348 0) (v-literals-349 (stack-alloc 8)))
 (declare (type c-address v-solver-346) (type (unsigned-byte 32) v-lit-347) (type (unsigned-byte 32) v-other-348) (type c-address v-literals-349) (ignorable v-solver-346 v-lit-347 v-other-348 v-literals-349))
 (tagbody
    (setf v-solver-346 arg-v-solver-346)
    (setf v-lit-347 arg-v-lit-347)
    (setf v-other-348 arg-v-other-348)
    (c-memset v-literals-349 0 8)
    (setf (m-u32 (+ v-literals-349 0)) v-lit-347)
    (setf (m-u32 (+ v-literals-349 4)) v-other-348)
    (progn (|c/trace_and_check_deletion| v-solver-346 (c-u64 2) v-literals-349))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:2158:1
(defun |c/trace_and_check_clause_addition| (arg-v-solver-350 arg-v-c-351 arg-v-remove-352)
 (declare  (type c-address arg-v-solver-350) (type c-address arg-v-c-351) (type (unsigned-byte 32) arg-v-remove-352))
 (let ((v-solver-350 0) (v-c-351 0) (v-remove-352 0))
 (declare (type c-address v-solver-350) (type c-address v-c-351) (type (unsigned-byte 32) v-remove-352) (ignorable v-solver-350 v-c-351 v-remove-352))
 (tagbody
    (setf v-solver-350 arg-v-solver-350)
    (setf v-c-351 arg-v-c-351)
    (setf v-remove-352 arg-v-remove-352)
    (progn (|c/trace_and_check_addition| v-solver-350 (m-u32 (+ v-c-351 12)) (+ v-c-351 16) v-remove-352))
  )
  0))

;;; upstream/satch.c:2167:1
(defun |c/trace_and_check_clause_deletion| (arg-v-solver-353 arg-v-c-354)
 (declare  (type c-address arg-v-solver-353) (type c-address arg-v-c-354))
 (let ((v-solver-353 0) (v-c-354 0))
 (declare (type c-address v-solver-353) (type c-address v-c-354) (ignorable v-solver-353 v-c-354))
 (tagbody
    (setf v-solver-353 arg-v-solver-353)
    (setf v-c-354 arg-v-c-354)
    (progn (|c/trace_and_check_deletion| v-solver-353 (m-u32 (+ v-c-354 12)) (+ v-c-354 16)))
  )
  0))

;;; upstream/satch.c:2182:1
(defun |c/bytes_clause| (arg-v-size-355)
 (declare  (type c-size arg-v-size-355))
 (let ((v-size-355 0))
 (declare (type c-size v-size-355) (ignorable v-size-355))
 (tagbody
    (setf v-size-355 arg-v-size-355)
    (return-from |c/bytes_clause| (c-u64 (+ 24 (c-u64 (* (c-u64 (- v-size-355 (c-u64 2))) 4)))))
  )
  0))

;;; upstream/satch.c:2191:1
(defun |c/allocate_clause| (arg-v-size-356)
 (declare  (type c-size arg-v-size-356))
 (let ((v-size-356 0) (v-bytes-357 0) (v-res-358 0))
 (declare (type c-size v-size-356) (type c-size v-bytes-357) (type c-address v-res-358) (ignorable v-size-356 v-bytes-357 v-res-358))
 (tagbody
    (setf v-size-356 arg-v-size-356)
    (setf v-bytes-357 (|c/bytes_clause| v-size-356))
    (setf v-res-358 (c-malloc v-bytes-357))
    (unless (c-true (if (c-true v-res-358) 0 1)) (go ELSE359))
    (progn (|c/out_of_memory| v-bytes-357))
    (go ENDIF360)
    ELSE359
    ENDIF360
    (return-from |c/allocate_clause| v-res-358)
  )
  0))

;;; upstream/satch.c:2201:1
(defun |c/deallocate_clause| (arg-v-c-361)
 (declare  (type c-address arg-v-c-361))
 (let ((v-c-361 0) (v-bytes-362 0))
 (declare (type c-address v-c-361) (type c-size v-bytes-362) (ignorable v-c-361 v-bytes-362))
 (tagbody
    (setf v-c-361 arg-v-c-361)
    (setf v-bytes-362 (|c/bytes_clause| (m-u32 (+ v-c-361 12))))
    (progn (c-free v-c-361))
    (return-from |c/deallocate_clause| v-bytes-362)
  )
  0))

;;; upstream/satch.c:2246:1
(defun |c/add_clause| (arg-v-solver-363 arg-v-redundant-364 arg-v-glue-365)
 (declare  (type c-address arg-v-solver-363) (type (integer 0 1) arg-v-redundant-364) (type (unsigned-byte 32) arg-v-glue-365))
 (let ((v-solver-363 0) (v-redundant-364 0) (v-glue-365 0) (v-size-368 0) (v-res-369 0))
 (declare (type c-address v-solver-363) (type (integer 0 1) v-redundant-364) (type (unsigned-byte 32) v-glue-365) (type c-size v-size-368) (type c-address v-res-369) (ignorable v-solver-363 v-redundant-364 v-glue-365 v-size-368 v-res-369))
 (tagbody
    (setf v-solver-363 arg-v-solver-363)
    (setf v-redundant-364 arg-v-redundant-364)
    (setf v-glue-365 arg-v-glue-365)
    (progn (progn 0 (let* ((a366 (+ (+ v-solver-363 1016) 16)) (old367 (m-u64 a366))) (setf (m-u64 a366) (c-u64 (c-u64 (+ old367 (c-u64 1))))) (m-u64 a366))))
    (setf v-size-368 (the c-size (truncate (- (m-ptr (+ (+ v-solver-363 624) 8)) (m-ptr (+ (+ v-solver-363 624) 0))) 4)))
    (setf v-res-369 (|c/allocate_clause| v-size-368))
    (progn (set-bits (+ v-res-369 0) 0 1 (c-bool 0)))
    (progn (set-bits (+ v-res-369 0) 1 1 (c-bool 0)))
    (progn (set-bits (+ v-res-369 0) 2 1 (c-bool v-redundant-364)))
    (progn (set-bits (+ v-res-369 0) 4 2 (c-u32 0)))
    (progn (set-bits (+ v-res-369 0) 3 1 (c-bool 0)))
    (progn (setf (m-u32 (+ v-res-369 4)) v-glue-365))
    (progn (setf (m-u32 (+ v-res-369 8)) (c-u32 0)))
    (progn (setf (m-u32 (+ v-res-369 12)) (c-u32 v-size-368)))
    (progn (set-bits (+ v-res-369 0) 7 2 (c-u32 0)))
    (progn (set-bits (+ v-res-369 0) 6 1 (c-bool 0)))
    (progn (c-memcpy (+ v-res-369 16) (m-ptr (+ (+ v-solver-363 624) 0)) (c-u64 (* v-size-368 4))))
    (return-from |c/add_clause| v-res-369)
  )
  0))

