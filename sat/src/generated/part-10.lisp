(in-package #:ooparts/sat/impl)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))
;;; upstream/satch.c:8513:1
(defun |c/mark_satisfied_eliminated_redundant_clauses_garbage| (arg-v-solver-4138)
 (declare  (type c-address arg-v-solver-4138))
 (let ((v-solver-4138 0) (v-c-4142 0) (v-PTR_c-4143 0) (v-END_c-4144 0))
 (declare (type c-address v-solver-4138) (type c-address v-c-4142) (type c-address v-PTR_c-4143) (type c-address v-END_c-4144) (ignorable v-solver-4138 v-c-4142 v-PTR_c-4143 v-END_c-4144))
 (tagbody
    (setf v-solver-4138 arg-v-solver-4138)
    (setf v-PTR_c-4143 (m-ptr (+ (+ v-solver-4138 696) 0)))
    (setf v-END_c-4144 (m-ptr (+ (+ v-solver-4138 696) 8)))
    LOOP4139
    (unless (c-true (if (c-true (if (/= v-PTR_c-4143 v-END_c-4144) 1 0)) (c-bool (progn (setf v-c-4142 (m-ptr v-PTR_c-4143)) 1)) 0)) (go ENDLOOP4140))
    (unless (c-true (if (c-true (ldb (byte 1 0) (m-u8 (+ v-c-4142 0)))) 0 1)) (go ELSE4145))
    (unless (c-true (|c/clause_eliminated| v-solver-4138 v-c-4142)) (go ELSE4147))
    (progn (|c/mark_garbage| v-solver-4138 v-c-4142 |c/string/148|))
    (go ENDIF4148)
    ELSE4147
    (unless (c-true (|c/clause_satisfied| v-solver-4138 v-c-4142)) (go ELSE4149))
    (progn (|c/mark_garbage| v-solver-4138 v-c-4142 |c/string/137|))
    (go ENDIF4150)
    ELSE4149
    ENDIF4150
    ENDIF4148
    (go ENDIF4146)
    ELSE4145
    ENDIF4146
    (let* ( (old4152 v-PTR_c-4143)) (setf v-PTR_c-4143 (+ old4152 (* 8 1))) v-PTR_c-4143)
    (go LOOP4139)
    ENDLOOP4140
  )
  0))

;;; upstream/satch.c:8529:1
(defun |c/mark_and_collect_garbage_clauses_after_elimination| (arg-v-solver-4153)
 (declare  (type c-address arg-v-solver-4153))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-4153 0) (v-bytes-4156 (stack-alloc 8)) (v-count-4157 (stack-alloc 8)))
 (declare (type c-address v-solver-4153) (type c-address v-bytes-4156) (type c-address v-count-4157) (ignorable v-solver-4153 v-bytes-4156 v-count-4157))
 (tagbody
    (setf v-solver-4153 arg-v-solver-4153)
    (unless (c-true (if (< (m-u64 (+ (+ (+ v-solver-4153 720) 0) 8)) (m-u64 (+ (+ v-solver-4153 1016) 104))) 1 0)) (go ELSE4154))
    (progn (|c/mark_irredundant_clauses_as_garbage_if_satisfied| v-solver-4153))
    (go ENDIF4155)
    ELSE4154
    ENDIF4155
    (progn (|c/mark_satisfied_eliminated_redundant_clauses_garbage| v-solver-4153))
    (setf (m-size v-bytes-4156) (c-u64 0))
    (setf (m-size v-count-4157) (c-u64 0))
    (progn (|c/delete_garbage_clauses| v-solver-4153 (+ v-solver-4153 672) v-bytes-4156 v-count-4157))
    (progn (|c/delete_garbage_clauses| v-solver-4153 (+ v-solver-4153 696) v-bytes-4156 v-count-4157))
    (progn (when (>= (m-u32 (+ v-solver-4153 884)) (c-u32 2)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-4153 (c-u32 2) |c/string/149| (m-u64 (+ (+ v-solver-4153 1016) 96)) |c/string/142| (m-size v-count-4157) (m-size v-bytes-4156) (float (/ (integer64-double (m-size v-bytes-4156) nil) (float (c-u32 (ash (c-u32 1) 20)) 1d0)) 1d0)))))
    (progn (let ((a4161 (+ (+ v-solver-4153 1016) 40))) (setf (m-u64 a4161) (c-u64 (c-u64 (+ (m-u64 a4161) (m-size v-bytes-4156)))))))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:8570:1
(defun |c/backward_subsume_marked| (arg-v-solver-4162 arg-v-size-4163 arg-v-lit-4164 arg-v-skip-4165 arg-v-traversed-4166)
 (declare  (notinline checked-address) (type c-address arg-v-solver-4162) (type (unsigned-byte 32) arg-v-size-4163) (type (unsigned-byte 32) arg-v-lit-4164) (type c-address arg-v-skip-4165) (type (unsigned-byte 32) arg-v-traversed-4166))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-4162 0) (v-size-4163 0) (v-lit-4164 0) (v-skip-4165 0) (v-traversed-4166 0) (v-watches-4167 0) (v-values-4168 0) (v-marks-4169 0) (v-touched-4170 0) (v-ticks-4171 0) (v-end_of_watches-4176 0) (v-p-4177 0) (v-q-4178 0) (v-watch-4182 (stack-alloc 8)) (v-c-4185 0) (v-satisfied-4196 0) (v-clashed-4197 0) (v-found-4198 0) (v-clashing-4199 0) (v-other-4203 0) (v-P_other-4204 0) (v-END_other-4205 0) (v-value-4206 0) (v-mark-4211 0) (v-occs-4232 0) (v-other-4250 0) (v-P_other-4251 0) (v-END_other-4252 0) (v-first-4259 0) (v-second-4260 0) (v-other-4264 0) (v-P_other-4265 0) (v-END_other-4266 0) (v-r-4274 0) (v-end_of_literals-4275 0))
 (declare (type c-address v-solver-4162) (type (unsigned-byte 32) v-size-4163) (type (unsigned-byte 32) v-lit-4164) (type c-address v-skip-4165) (type (unsigned-byte 32) v-traversed-4166) (type c-address v-watches-4167) (type c-address v-values-4168) (type c-address v-marks-4169) (type (integer 0 1) v-touched-4170) (type (unsigned-byte 64) v-ticks-4171) (type c-address v-end_of_watches-4176) (type c-address v-p-4177) (type c-address v-q-4178) (type c-address v-watch-4182) (type c-address v-c-4185) (type (integer 0 1) v-satisfied-4196) (type (unsigned-byte 32) v-clashed-4197) (type (unsigned-byte 32) v-found-4198) (type (unsigned-byte 32) v-clashing-4199) (type (unsigned-byte 32) v-other-4203) (type c-address v-P_other-4204) (type c-address v-END_other-4205) (type (signed-byte 8) v-value-4206) (type (signed-byte 8) v-mark-4211) (type c-size v-occs-4232) (type (unsigned-byte 32) v-other-4250) (type c-address v-P_other-4251) (type c-address v-END_other-4252) (type (unsigned-byte 32) v-first-4259) (type (unsigned-byte 32) v-second-4260) (type (unsigned-byte 32) v-other-4264) (type c-address v-P_other-4265) (type c-address v-END_other-4266) (type c-address v-r-4274) (type c-address v-end_of_literals-4275) (ignorable v-solver-4162 v-size-4163 v-lit-4164 v-skip-4165 v-traversed-4166 v-watches-4167 v-values-4168 v-marks-4169 v-touched-4170 v-ticks-4171 v-end_of_watches-4176 v-p-4177 v-q-4178 v-watch-4182 v-c-4185 v-satisfied-4196 v-clashed-4197 v-found-4198 v-clashing-4199 v-other-4203 v-P_other-4204 v-END_other-4205 v-value-4206 v-mark-4211 v-occs-4232 v-other-4250 v-P_other-4251 v-END_other-4252 v-first-4259 v-second-4260 v-other-4264 v-P_other-4265 v-END_other-4266 v-r-4274 v-end_of_literals-4275))
 (tagbody
    (setf v-solver-4162 arg-v-solver-4162)
    (setf v-size-4163 arg-v-size-4163)
    (setf v-lit-4164 arg-v-lit-4164)
    (setf v-skip-4165 arg-v-skip-4165)
    (setf v-traversed-4166 arg-v-traversed-4166)
    (setf v-watches-4167 (+ (m-ptr (+ v-solver-4162 544)) (* 24 v-lit-4164)))
    (setf v-values-4168 (m-ptr (+ v-solver-4162 40)))
    (setf v-marks-4169 (m-ptr (+ v-solver-4162 96)))
    (setf v-touched-4170 (c-bool 0))
    (locally (declare (optimize (speed 1))) (setf v-ticks-4171 (c-u64 (+ (c-u64 1) (|c/cache_lines| (m-ptr (+ v-watches-4167 0)) (m-ptr (+ v-watches-4167 8)))))))
    (progn (let ((a4175 (+ (+ v-solver-4162 1016) 304))) (setf (m-u64 a4175) (c-u64 (c-u64 (+ (m-u64 a4175) v-ticks-4171))))))
    (setf v-end_of_watches-4176 (m-ptr (+ v-watches-4167 8)))
    (setf v-q-4178 (m-ptr (+ v-watches-4167 0)))
    (progn (setf v-p-4177 v-q-4178))
    LOOP4179
    (unless (c-true (if (/= v-p-4177 v-end_of_watches-4176) 1 0)) (go ENDLOOP4180))
    (copy-bytes v-watch-4182 (copy-bytes (let* ( (old4184 v-q-4178)) (setf v-q-4178 (+ old4184 (* 8 1))) old4184) v-p-4177 8) 8)
    (setf v-c-4185 (m-ptr (+ v-watch-4182 0)))
    (unless (c-true (if (= v-c-4185 v-skip-4165) 1 0)) (go ELSE4186))
    (go CONTINUE4181)
    ELSE4186
    (unless (c-true (|c/is_tagged_clause| v-c-4185)) (go ELSE4188))
    (go CONTINUE4181)
    ELSE4188
    (progn (let* ( (old4191 v-ticks-4171)) (setf v-ticks-4171 (c-u64 (c-u64 (+ old4191 (c-u64 1))))) old4191))
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-c-4185 0)))) (go ELSE4192))
    (go CONTINUE4181)
    ELSE4192
    (unless (c-true (if (< (m-u32 (+ v-c-4185 12)) v-size-4163) 1 0)) (go ELSE4194))
    (go CONTINUE4181)
    ELSE4194
    (setf v-satisfied-4196 (c-bool 0))
    (setf v-clashed-4197 (c-u32 0))
    (setf v-found-4198 (c-u32 0))
    (setf v-clashing-4199 4294967295)
    (setf v-P_other-4204 (+ v-c-4185 16))
    (setf v-END_other-4205 (+ v-P_other-4204 (* 4 (m-u32 (+ v-c-4185 12)))))
    LOOP4200
    (unless (c-true (if (c-true (if (/= v-P_other-4204 v-END_other-4205) 1 0)) (c-bool (progn (setf v-other-4203 (m-u32 v-P_other-4204)) 1)) 0)) (go ENDLOOP4201))
    (setf v-value-4206 (m-s8 (+ v-values-4168 (* 1 v-other-4203))))
    (unless (c-true (if (> v-value-4206 0) 1 0)) (go ELSE4207))
    (progn (setf v-satisfied-4196 (c-bool 1)))
    (go ENDLOOP4201)
    ELSE4207
    (unless (c-true (if (< v-value-4206 0) 1 0)) (go ELSE4209))
    (go CONTINUE4202)
    ELSE4209
    (setf v-mark-4211 (|c/marked_literal| v-marks-4169 v-other-4203))
    (unless (c-true (if (c-true v-mark-4211) 0 1)) (go ELSE4212))
    (go CONTINUE4202)
    ELSE4212
    (unless (c-true (if (< v-mark-4211 0) 1 0)) (go ELSE4214))
    (unless (c-true (let* ( (old4219 v-clashed-4197)) (setf v-clashed-4197 (c-u32 (c-u32 (+ old4219 (c-u32 1))))) old4219)) (go ELSE4216))
    (go ENDLOOP4201)
    ELSE4216
    (progn (setf v-clashing-4199 v-other-4203))
    (go ENDIF4215)
    ELSE4214
    ENDIF4215
    (progn (let* ( (old4221 v-found-4198)) (setf v-found-4198 (c-u32 (c-u32 (+ old4221 (c-u32 1))))) old4221))
    CONTINUE4202
    (let* ( (old4223 v-P_other-4204)) (setf v-P_other-4204 (+ old4223 (* 4 1))) v-P_other-4204)
    (go LOOP4200)
    ENDLOOP4201
    (unless (c-true (if (> v-clashed-4197 (c-u32 1)) 1 0)) (go ELSE4224))
    (go CONTINUE4181)
    ELSE4224
    (unless (c-true v-satisfied-4196) (go ELSE4226))
    (progn (|c/mark_garbage| v-solver-4162 v-c-4185 |c/string/137|))
    (go CONTINUE4181)
    ELSE4226
    (unless (c-true (if (< v-found-4198 v-size-4163) 1 0)) (go ELSE4228))
    (go CONTINUE4181)
    ELSE4228
    (unless (c-true v-clashed-4197) (go ELSE4230))
    (setf v-occs-4232 (the c-size (truncate (- (m-ptr (+ (+ (m-ptr (+ v-solver-4162 544)) (* 24 v-clashing-4199)) 8)) (m-ptr (+ (+ (m-ptr (+ v-solver-4162 544)) (* 24 v-clashing-4199)) 0))) 8)))
    (unless (c-true (if (>= (integer64-double v-occs-4232 nil) 1000.0d0) 1 0)) (go ELSE4233))
    (go CONTINUE4181)
    ELSE4233
    (progn v-solver-4162)
    (progn (|c/trace_and_check_clause_addition| v-solver-4162 v-c-4185 v-clashing-4199))
    (progn (|c/trace_and_check_clause_deletion| v-solver-4162 v-c-4185))
    (progn (|c/mark_eliminate_literal| v-solver-4162 v-clashing-4199))
    (unless (c-true (if (= v-lit-4164 v-clashing-4199) 1 0)) (go ELSE4238))
    (progn v-solver-4162)
    (progn (let* ( (old4244 v-q-4178)) (setf v-q-4178 (- old4244 (* 8 1))) old4244))
    (go ENDIF4239)
    ELSE4238
    (progn (let* ( (old4246 v-ticks-4171)) (setf v-ticks-4171 (c-u64 (c-u64 (+ old4246 (c-u64 1))))) old4246))
    (progn (|c/disconnect_literal| v-solver-4162 v-clashing-4199 v-c-4185))
    ENDIF4239
    (setf v-P_other-4251 (+ v-c-4185 16))
    (setf v-END_other-4252 (+ v-P_other-4251 (* 4 (m-u32 (+ v-c-4185 12)))))
    LOOP4247
    (unless (c-true (if (c-true (if (/= v-P_other-4251 v-END_other-4252) 1 0)) (c-bool (progn (setf v-other-4250 (m-u32 v-P_other-4251)) 1)) 0)) (go ENDLOOP4248))
    (unless (c-true (if (/= v-other-4250 v-clashing-4199) 1 0)) (go ELSE4253))
    (progn (|c/mark_subsume_literal| v-solver-4162 v-other-4250))
    (go ENDIF4254)
    ELSE4253
    ENDIF4254
    (let* ( (old4256 v-P_other-4251)) (setf v-P_other-4251 (+ old4256 (* 4 1))) v-P_other-4251)
    (go LOOP4247)
    ENDLOOP4248
    (unless (c-true (if (= (m-u32 (+ v-c-4185 12)) (c-u32 3)) 1 0)) (go ELSE4257))
    (progn (set-bits (+ v-c-4185 0) 0 1 (c-bool 1)))
    (setf v-first-4259 4294967295)
    (setf v-second-4260 4294967295)
    (setf v-P_other-4265 (+ v-c-4185 16))
    (setf v-END_other-4266 (+ v-P_other-4265 (* 4 (m-u32 (+ v-c-4185 12)))))
    LOOP4261
    (unless (c-true (if (c-true (if (/= v-P_other-4265 v-END_other-4266) 1 0)) (c-bool (progn (setf v-other-4264 (m-u32 v-P_other-4265)) 1)) 0)) (go ENDLOOP4262))
    (unless (c-true (if (/= v-other-4264 v-clashing-4199) 1 0)) (go ELSE4267))
    (unless (c-true (if (= v-first-4259 4294967295) 1 0)) (go ELSE4269))
    (progn (setf v-first-4259 v-other-4264))
    (go ENDIF4270)
    ELSE4269
    (progn (setf v-second-4260 v-other-4264))
    ENDIF4270
    (progn (|c/disconnect_literal| v-solver-4162 v-other-4264 v-c-4185))
    (go ENDIF4268)
    ELSE4267
    ENDIF4268
    (let* ( (old4272 v-P_other-4265)) (setf v-P_other-4265 (+ old4272 (* 4 1))) v-P_other-4265)
    (go LOOP4261)
    ENDLOOP4262
    (progn (|c/connect_literal| v-solver-4162 v-first-4259 (|c/tag_binary_clause| (c-bool 0) v-second-4260)))
    (progn (|c/connect_literal| v-solver-4162 v-second-4260 (|c/tag_binary_clause| (c-bool 0) v-first-4259)))
    (progn (setf v-touched-4170 (c-bool (if (c-true (if (= v-first-4259 v-traversed-4166) 1 0)) 1 (c-bool (if (= v-second-4260 v-traversed-4166) 1 0))))))
    (progn (setf v-ticks-4171 (c-u64 (c-u64 (+ v-ticks-4171 (c-u64 2))))))
    (go ENDIF4258)
    ELSE4257
    (setf v-r-4274 (+ v-c-4185 16))
    (setf v-end_of_literals-4275 (+ v-r-4274 (* 4 (m-u32 (+ v-c-4185 12)))))
    LOOP4276
    (unless (c-true (progn 0 (if (/= (m-u32 v-r-4274) v-clashing-4199) 1 0))) (go ENDLOOP4277))
    (progn (let* ( (old4280 v-r-4274)) (setf v-r-4274 (+ old4280 (* 4 1))) old4280))
    (go LOOP4276)
    ENDLOOP4277
    LOOP4281
    (unless (c-true (if (/= (let* ( (old4285 v-r-4274)) (setf v-r-4274 (+ old4285 (* 4 1))) v-r-4274) v-end_of_literals-4275) 1 0)) (go ENDLOOP4282))
    (progn (setf (m-u32 (+ v-r-4274 (* 4 (c-s32 (- 1))))) (m-u32 v-r-4274)))
    (go LOOP4281)
    ENDLOOP4282
    (progn (let* ((a4286 (+ v-c-4185 12)) (old4287 (m-u32 a4286))) (setf (m-u32 a4286) (c-u32 (c-u32 (- old4287 (c-u32 1))))) old4287))
    (progn (setf (m-u32 (+ v-c-4185 8)) (c-u32 0)))
    (progn v-solver-4162)
    (progn (progn 0 (let* ((a4291 (+ (+ v-solver-4162 1016) 296)) (old4292 (m-u64 a4291))) (setf (m-u64 a4291) (c-u64 (c-u64 (+ old4292 (c-u64 1))))) (m-u64 a4291))))
    ENDIF4258
    (go ENDIF4231)
    ELSE4230
    (progn (|c/mark_garbage| v-solver-4162 v-c-4185 |c/string/150|))
    (progn (progn 0 (let* ((a4293 (+ (+ v-solver-4162 1016) 320)) (old4294 (m-u64 a4293))) (setf (m-u64 a4293) (c-u64 (c-u64 (+ old4294 (c-u64 1))))) (m-u64 a4293))))
    ENDIF4231
    CONTINUE4181
    (let* ( (old4296 v-p-4177)) (setf v-p-4177 (+ old4296 (* 8 1))) old4296)
    (go LOOP4179)
    ENDLOOP4180
    (progn (setf (m-ptr (+ v-watches-4167 8)) v-q-4178))
    (unless (c-true (if (= (m-ptr (+ v-watches-4167 8)) (m-ptr (+ v-watches-4167 0))) 1 0)) (go ELSE4297))
    (progn (c-free (m-ptr (+ v-watches-4167 0))))
    (progn (setf (m-ptr (+ v-watches-4167 0)) (setf (m-ptr (+ v-watches-4167 8)) (setf (m-ptr (+ v-watches-4167 16)) 0))))
    (go ENDIF4298)
    ELSE4297
    ENDIF4298
    (progn (let ((a4305 (+ (+ v-solver-4162 1016) 304))) (setf (m-u64 a4305) (c-u64 (c-u64 (+ (m-u64 a4305) v-ticks-4171))))))
    (return-from |c/backward_subsume_marked| (c-bool v-touched-4170))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:8839:1
(defun |c/backward_subsume_with_clause| (arg-v-solver-4306 arg-v-c-4307 arg-v-traversed-4308)
 (declare  (notinline checked-address) (type c-address arg-v-solver-4306) (type c-address arg-v-c-4307) (type (unsigned-byte 32) arg-v-traversed-4308))
 (let ((v-solver-4306 0) (v-c-4307 0) (v-traversed-4308 0) (v-satisfied-4314 0) (v-touched-4315 0) (v-subsume-4316 0) (v-min_pos_occs-4317 0) (v-min_neg_occs-4318 0) (v-min_pos_lit-4319 0) (v-min_neg_lit-4320 0) (v-actual_size-4321 0) (v-watches-4322 0) (v-flags-4323 0) (v-values-4324 0) (v-marks-4325 0) (v-ticks-4326 0) (v-lit-4330 0) (v-P_lit-4331 0) (v-END_lit-4332 0) (v-value-4333 0) (v-idx-4341 0) (v-pos_occs-4351 0) (v-not_lit-4354 0) (v-neg_occs-4355 0) (v-lit-4390 0) (v-P_lit-4391 0) (v-END_lit-4392 0))
 (declare (type c-address v-solver-4306) (type c-address v-c-4307) (type (unsigned-byte 32) v-traversed-4308) (type (integer 0 1) v-satisfied-4314) (type (integer 0 1) v-touched-4315) (type (integer 0 1) v-subsume-4316) (type (unsigned-byte 64) v-min_pos_occs-4317) (type (unsigned-byte 64) v-min_neg_occs-4318) (type (unsigned-byte 32) v-min_pos_lit-4319) (type (unsigned-byte 32) v-min_neg_lit-4320) (type (unsigned-byte 32) v-actual_size-4321) (type c-address v-watches-4322) (type c-address v-flags-4323) (type c-address v-values-4324) (type c-address v-marks-4325) (type (unsigned-byte 64) v-ticks-4326) (type (unsigned-byte 32) v-lit-4330) (type c-address v-P_lit-4331) (type c-address v-END_lit-4332) (type (signed-byte 8) v-value-4333) (type (unsigned-byte 32) v-idx-4341) (type c-size v-pos_occs-4351) (type (unsigned-byte 32) v-not_lit-4354) (type c-size v-neg_occs-4355) (type (unsigned-byte 32) v-lit-4390) (type c-address v-P_lit-4391) (type c-address v-END_lit-4392) (ignorable v-solver-4306 v-c-4307 v-traversed-4308 v-satisfied-4314 v-touched-4315 v-subsume-4316 v-min_pos_occs-4317 v-min_neg_occs-4318 v-min_pos_lit-4319 v-min_neg_lit-4320 v-actual_size-4321 v-watches-4322 v-flags-4323 v-values-4324 v-marks-4325 v-ticks-4326 v-lit-4330 v-P_lit-4331 v-END_lit-4332 v-value-4333 v-idx-4341 v-pos_occs-4351 v-not_lit-4354 v-neg_occs-4355 v-lit-4390 v-P_lit-4391 v-END_lit-4392))
 (tagbody
    (setf v-solver-4306 arg-v-solver-4306)
    (setf v-c-4307 arg-v-c-4307)
    (setf v-traversed-4308 arg-v-traversed-4308)
    (unless (c-true (if (c-true (|c/is_temporary_binary| v-solver-4306 v-c-4307)) 0 1)) (go ELSE4309))
    (progn (set-bits (+ v-c-4307 0) 3 1 (c-bool 1)))
    (go ENDIF4310)
    ELSE4309
    ENDIF4310
    (progn v-solver-4306)
    (setf v-satisfied-4314 (c-bool 0))
    (setf v-touched-4315 (c-bool 0))
    (setf v-subsume-4316 (c-bool 1))
    (locally (declare (optimize (speed 1))) (setf v-min_pos_occs-4317 18446744073709551615))
    (locally (declare (optimize (speed 1))) (setf v-min_neg_occs-4318 18446744073709551615))
    (setf v-min_pos_lit-4319 4294967295)
    (setf v-min_neg_lit-4320 4294967295)
    (setf v-actual_size-4321 (c-u32 0))
    (setf v-watches-4322 (m-ptr (+ v-solver-4306 544)))
    (setf v-flags-4323 (m-ptr (+ v-solver-4306 48)))
    (setf v-values-4324 (m-ptr (+ v-solver-4306 40)))
    (setf v-marks-4325 (m-ptr (+ v-solver-4306 96)))
    (locally (declare (optimize (speed 1))) (setf v-ticks-4326 (c-u64 2)))
    (setf v-P_lit-4331 (+ v-c-4307 16))
    (setf v-END_lit-4332 (+ v-P_lit-4331 (* 4 (m-u32 (+ v-c-4307 12)))))
    LOOP4327
    (unless (c-true (if (c-true (if (/= v-P_lit-4331 v-END_lit-4332) 1 0)) (c-bool (progn (setf v-lit-4330 (m-u32 v-P_lit-4331)) 1)) 0)) (go ENDLOOP4328))
    (setf v-value-4333 (m-s8 (+ v-values-4324 (* 1 v-lit-4330))))
    (unless (c-true (if (> v-value-4333 0) 1 0)) (go ELSE4334))
    (progn v-solver-4306)
    (progn (setf v-satisfied-4314 (c-bool 1)))
    (go ENDLOOP4328)
    ELSE4334
    (unless (c-true (if (< v-value-4333 0) 1 0)) (go ELSE4339))
    (go CONTINUE4329)
    ELSE4339
    (setf v-idx-4341 (|c/INDEX| v-lit-4330))
    (unless (c-true (if (c-true (ldb (byte 2 4) (m-u8 (+ (+ v-flags-4323 (* 4 v-idx-4341)) 0)))) 0 1)) (go ELSE4342))
    (progn v-solver-4306)
    (progn (setf v-subsume-4316 (c-bool 0)))
    (go ENDLOOP4328)
    ELSE4342
    (progn (|c/mark_literal| v-marks-4325 v-lit-4330))
    (progn (let* ( (old4348 v-actual_size-4321)) (setf v-actual_size-4321 (c-u32 (c-u32 (+ old4348 (c-u32 1))))) old4348))
    (progn (let* ( (old4350 v-ticks-4326)) (setf v-ticks-4326 (c-u64 (c-u64 (+ old4350 (c-u64 1))))) old4350))
    (setf v-pos_occs-4351 (the c-size (truncate (- (m-ptr (+ (+ v-watches-4322 (* 24 v-lit-4330)) 8)) (m-ptr (+ (+ v-watches-4322 (* 24 v-lit-4330)) 0))) 8)))
    (unless (c-true (if (< v-pos_occs-4351 v-min_pos_occs-4317) 1 0)) (go ELSE4352))
    (progn (progn (setf v-min_pos_occs-4317 v-pos_occs-4351) (setf v-min_pos_lit-4319 v-lit-4330)))
    (go ENDIF4353)
    ELSE4352
    ENDIF4353
    (setf v-not_lit-4354 (|c/NOT| v-lit-4330))
    (setf v-neg_occs-4355 (the c-size (truncate (- (m-ptr (+ (+ v-watches-4322 (* 24 v-not_lit-4354)) 8)) (m-ptr (+ (+ v-watches-4322 (* 24 v-not_lit-4354)) 0))) 8)))
    (unless (c-true (if (< v-neg_occs-4355 v-min_neg_occs-4318) 1 0)) (go ELSE4356))
    (progn (progn (setf v-min_neg_occs-4318 v-neg_occs-4355) (setf v-min_neg_lit-4320 v-not_lit-4354)))
    (go ENDIF4357)
    ELSE4356
    ENDIF4357
    CONTINUE4329
    (let* ( (old4359 v-P_lit-4331)) (setf v-P_lit-4331 (+ old4359 (* 4 1))) v-P_lit-4331)
    (go LOOP4327)
    ENDLOOP4328
    (progn (let ((a4363 (+ (+ v-solver-4306 1016) 304))) (setf (m-u64 a4363) (c-u64 (c-u64 (+ (m-u64 a4363) v-ticks-4326))))))
    (unless (c-true v-satisfied-4314) (go ELSE4364))
    (unless (c-true (if (c-true (|c/is_temporary_binary| v-solver-4306 v-c-4307)) 0 1)) (go ELSE4366))
    (progn (|c/mark_garbage| v-solver-4306 v-c-4307 |c/string/137|))
    (go ENDIF4367)
    ELSE4366
    ENDIF4367
    (go ENDIF4365)
    ELSE4364
    (unless (c-true v-subsume-4316) (go ELSE4368))
    (progn v-solver-4306)
    (unless (c-true (if (<= (integer64-double v-min_pos_occs-4317 nil) 1000.0d0) 1 0)) (go ELSE4373))
    (progn (if (c-true (if (= v-min_pos_lit-4319 4294967295) 1 0)) (progn (c-fflush 1) (c-fprintf 2 |c/string/151| |c/string/152| 8930 |c/string/153| |c/string/154|) (c-abort) 0) 0))
    (progn v-solver-4306)
    (unless (c-true (|c/backward_subsume_marked| v-solver-4306 v-actual_size-4321 v-min_pos_lit-4319 v-c-4307 v-traversed-4308)) (go ELSE4378))
    (progn (setf v-touched-4315 (c-bool 1)))
    (go ENDIF4379)
    ELSE4378
    ENDIF4379
    (go ENDIF4374)
    ELSE4373
    ENDIF4374
    (unless (c-true (if (<= (integer64-double v-min_neg_occs-4318 nil) 1000.0d0) 1 0)) (go ELSE4380))
    (progn (if (c-true (if (= v-min_neg_lit-4320 4294967295) 1 0)) (progn (c-fflush 1) (c-fprintf 2 |c/string/151| |c/string/152| 8947 |c/string/153| |c/string/155|) (c-abort) 0) 0))
    (progn v-solver-4306)
    (unless (c-true (|c/backward_subsume_marked| v-solver-4306 v-actual_size-4321 v-min_neg_lit-4320 v-c-4307 v-traversed-4308)) (go ELSE4385))
    (progn (setf v-touched-4315 (c-bool 1)))
    (go ENDIF4386)
    ELSE4385
    ENDIF4386
    (go ENDIF4381)
    ELSE4380
    ENDIF4381
    (go ENDIF4369)
    ELSE4368
    ENDIF4369
    ENDIF4365
    (setf v-P_lit-4391 (+ v-c-4307 16))
    (setf v-END_lit-4392 (+ v-P_lit-4391 (* 4 (m-u32 (+ v-c-4307 12)))))
    LOOP4387
    (unless (c-true (if (c-true (if (/= v-P_lit-4391 v-END_lit-4392) 1 0)) (c-bool (progn (setf v-lit-4390 (m-u32 v-P_lit-4391)) 1)) 0)) (go ENDLOOP4388))
    (progn (|c/unmark_literal| v-marks-4325 v-lit-4390))
    (let* ( (old4394 v-P_lit-4391)) (setf v-P_lit-4391 (+ old4394 (* 4 1))) v-P_lit-4391)
    (go LOOP4387)
    ENDLOOP4388
    (return-from |c/backward_subsume_with_clause| (c-bool v-touched-4315))
  )
  0))

;;; upstream/satch.c:8966:1
(defun |c/backward_subsume_literal| (arg-v-solver-4395 arg-v-lit-4396)
 (declare  (type c-address arg-v-solver-4395) (type (unsigned-byte 32) arg-v-lit-4396))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-4395 0) (v-lit-4396 0) (v-watches-4399 0) (v-ticks-4405 0) (v-watch-4409 (stack-alloc 8)) (v-PTR_watch-4410 0) (v-END_watch-4411 0) (v-c-4412 0))
 (declare (type c-address v-solver-4395) (type (unsigned-byte 32) v-lit-4396) (type c-address v-watches-4399) (type (unsigned-byte 64) v-ticks-4405) (type c-address v-watch-4409) (type c-address v-PTR_watch-4410) (type c-address v-END_watch-4411) (type c-address v-c-4412) (ignorable v-solver-4395 v-lit-4396 v-watches-4399 v-ticks-4405 v-watch-4409 v-PTR_watch-4410 v-END_watch-4411 v-c-4412))
 (tagbody
    (setf v-solver-4395 arg-v-solver-4395)
    (setf v-lit-4396 arg-v-lit-4396)
    (progn (progn 0 (let* ((a4397 (+ (+ v-solver-4395 1016) 304)) (old4398 (m-u64 a4397))) (setf (m-u64 a4397) (c-u64 (c-u64 (+ old4398 (c-u64 1))))) (m-u64 a4397))))
    (setf v-watches-4399 (+ (m-ptr (+ v-solver-4395 544)) (* 24 v-lit-4396)))
    (unless (c-true (if (> (integer64-double (the c-size (truncate (- (m-ptr (+ v-watches-4399 8)) (m-ptr (+ v-watches-4399 0))) 8)) nil) 1000.0d0) 1 0)) (go ELSE4400))
    (return-from |c/backward_subsume_literal| 0)
    ELSE4400
    (progn v-solver-4395)
    (locally (declare (optimize (speed 1))) (setf v-ticks-4405 (|c/cache_lines| (m-ptr (+ v-watches-4399 0)) (m-ptr (+ v-watches-4399 8)))))
    user-RESTART
    (setf v-PTR_watch-4410 (m-ptr (+ v-watches-4399 0)))
    (setf v-END_watch-4411 (m-ptr (+ v-watches-4399 8)))
    LOOP4406
    (unless (c-true (if (c-true (if (/= v-PTR_watch-4410 v-END_watch-4411) 1 0)) (c-bool (progn (copy-bytes v-watch-4409 v-PTR_watch-4410 8) 1)) 0)) (go ENDLOOP4407))
    (setf v-c-4412 (m-ptr (+ v-watch-4409 0)))
    (unless (c-true (|c/is_tagged_clause| v-c-4412)) (go ELSE4413))
    (progn (setf v-c-4412 (|c/untag_clause| v-solver-4395 (c-u32 0) v-lit-4396 v-c-4412)))
    (go ENDIF4414)
    ELSE4413
    (progn (let* ( (old4416 v-ticks-4405)) (setf v-ticks-4405 (c-u64 (c-u64 (+ old4416 (c-u64 1))))) old4416))
    (unless (c-true (if (c-true (ldb (byte 1 0) (m-u8 (+ v-c-4412 0)))) 1 (c-bool (ldb (byte 1 3) (m-u8 (+ v-c-4412 0)))))) (go ELSE4417))
    (go CONTINUE4408)
    ELSE4417
    ENDIF4414
    (unless (c-true (if (<= (float (m-u32 (+ v-c-4412 12)) 1d0) 1000.0d0) 1 0)) (go ELSE4419))
    (unless (c-true (|c/backward_subsume_with_clause| v-solver-4395 v-c-4412 v-lit-4396)) (go ELSE4421))
    (progn v-solver-4395)
    (go user-RESTART)
    ELSE4421
    (go ENDIF4420)
    ELSE4419
    ENDIF4420
    CONTINUE4408
    (let* ( (old4427 v-PTR_watch-4410)) (setf v-PTR_watch-4410 (+ old4427 (* 8 1))) v-PTR_watch-4410)
    (go LOOP4406)
    ENDLOOP4407
    (progn (let ((a4431 (+ (+ v-solver-4395 1016) 304))) (setf (m-u64 a4431) (c-u64 (c-u64 (+ (m-u64 a4431) v-ticks-4405))))))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:9028:1
(defun |c/remove_duplicated_virtual_binary_clauses| (arg-v-solver-4432 arg-v-lit-4433)
 (declare  (type c-address arg-v-solver-4432) (type (unsigned-byte 32) arg-v-lit-4433))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-4432 0) (v-lit-4433 0) (v-watches-4437 0) (v-end-4438 0) (v-q-4439 0) (v-p-4440 0) (v-ticks-4441 0) (v-marks-4442 0) (v-assigned-4443 0) (v-watch-4447 (stack-alloc 8)) (v-c-4450 0) (v-other-4453 0) (v-mark-4454 0) (v-d-4457 0) (v-r-4474 0))
 (declare (type c-address v-solver-4432) (type (unsigned-byte 32) v-lit-4433) (type c-address v-watches-4437) (type c-address v-end-4438) (type c-address v-q-4439) (type c-address v-p-4440) (type (unsigned-byte 64) v-ticks-4441) (type c-address v-marks-4442) (type (integer 0 1) v-assigned-4443) (type c-address v-watch-4447) (type c-address v-c-4450) (type (unsigned-byte 32) v-other-4453) (type (signed-byte 8) v-mark-4454) (type c-address v-d-4457) (type c-address v-r-4474) (ignorable v-solver-4432 v-lit-4433 v-watches-4437 v-end-4438 v-q-4439 v-p-4440 v-ticks-4441 v-marks-4442 v-assigned-4443 v-watch-4447 v-c-4450 v-other-4453 v-mark-4454 v-d-4457 v-r-4474))
 (tagbody
    (setf v-solver-4432 arg-v-solver-4432)
    (setf v-lit-4433 arg-v-lit-4433)
    (progn v-solver-4432)
    (setf v-watches-4437 (+ (m-ptr (+ v-solver-4432 544)) (* 24 v-lit-4433)))
    (setf v-end-4438 (m-ptr (+ v-watches-4437 8)))
    (setf v-q-4439 (m-ptr (+ v-watches-4437 0)))
    (setf v-p-4440 v-q-4439)
    (locally (declare (optimize (speed 1))) (setf v-ticks-4441 (c-u64 (+ (c-u64 1) (|c/cache_lines| (m-ptr (+ v-watches-4437 0)) (m-ptr (+ v-watches-4437 8)))))))
    (setf v-marks-4442 (m-ptr (+ v-solver-4432 96)))
    (setf v-assigned-4443 (c-bool 0))
    LOOP4444
    (unless (c-true (if (c-true (if (c-true v-assigned-4443) 0 1)) (c-bool (if (/= v-p-4440 v-end-4438) 1 0)) 0)) (go ENDLOOP4445))
    (copy-bytes v-watch-4447 (let* ( (old4449 v-p-4440)) (setf v-p-4440 (+ old4449 (* 8 1))) old4449) 8)
    (setf v-c-4450 (m-ptr (+ v-watch-4447 0)))
    (unless (c-true (|c/is_tagged_clause| v-c-4450)) (go ELSE4451))
    (setf v-other-4453 (|c/tagged_clause_to_literal| v-c-4450))
    (setf v-mark-4454 (|c/marked_literal| v-marks-4442 v-other-4453))
    (unless (c-true (if (> v-mark-4454 0) 1 0)) (go ELSE4455))
    (progn (|c/really_delete_binary| v-solver-4432 (c-bool 0) v-lit-4433 v-other-4453))
    (setf v-d-4457 (|c/tag_binary_clause| (c-bool 0) v-lit-4433))
    (progn (|c/disconnect_literal| v-solver-4432 v-other-4453 v-d-4457))
    (progn (progn 0 (let* ((a4458 (+ (+ v-solver-4432 1016) 320)) (old4459 (m-u64 a4458))) (setf (m-u64 a4458) (c-u64 (c-u64 (+ old4459 (c-u64 1))))) (m-u64 a4458))))
    (progn (let* ( (old4461 v-ticks-4441)) (setf v-ticks-4441 (c-u64 (c-u64 (+ old4461 (c-u64 1))))) old4461))
    (go CONTINUE4446)
    ELSE4455
    (unless (c-true (if (< v-mark-4454 0) 1 0)) (go ELSE4462))
    (progn v-solver-4432)
    (progn (|c/trace_and_check_unit_addition| v-solver-4432 v-lit-4433))
    (progn (progn 0 (let* ((a4467 (+ (+ v-solver-4432 1016) 296)) (old4468 (m-u64 a4467))) (setf (m-u64 a4467) (c-u64 (c-u64 (+ old4468 (c-u64 1))))) (m-u64 a4467))))
    (progn (|c/assign| v-solver-4432 v-lit-4433 0 (c-bool 1)))
    (progn (setf v-assigned-4443 (c-bool 1)))
    (go ENDIF4463)
    ELSE4462
    (progn (|c/mark_literal| v-marks-4442 v-other-4453))
    ENDIF4463
    (go ENDIF4452)
    ELSE4451
    ENDIF4452
    (progn (copy-bytes (let* ( (old4470 v-q-4439)) (setf v-q-4439 (+ old4470 (* 8 1))) old4470) v-watch-4447 8))
    CONTINUE4446
    (go LOOP4444)
    ENDLOOP4445
    (setf v-r-4474 (m-ptr (+ v-watches-4437 0)))
    LOOP4471
    (unless (c-true (if (/= v-r-4474 v-q-4439) 1 0)) (go ENDLOOP4472))
    (unless (c-true (|c/is_tagged_clause| (m-ptr (+ v-r-4474 0)))) (go ELSE4475))
    (progn (|c/unmark_literal| v-marks-4442 (|c/tagged_clause_to_literal| (m-ptr (+ v-r-4474 0)))))
    (go ENDIF4476)
    ELSE4475
    ENDIF4476
    (let* ( (old4478 v-r-4474)) (setf v-r-4474 (+ old4478 (* 8 1))) old4478)
    (go LOOP4471)
    ENDLOOP4472
    LOOP4479
    (unless (c-true (if (/= v-p-4440 v-end-4438) 1 0)) (go ENDLOOP4480))
    (progn (copy-bytes (let* ( (old4483 v-q-4439)) (setf v-q-4439 (+ old4483 (* 8 1))) old4483) (let* ( (old4485 v-p-4440)) (setf v-p-4440 (+ old4485 (* 8 1))) old4485) 8))
    (go LOOP4479)
    ENDLOOP4480
    (progn (setf (m-ptr (+ v-watches-4437 8)) v-q-4439))
    (progn (let ((a4489 (+ (+ v-solver-4432 1016) 304))) (setf (m-u64 a4489) (c-u64 (c-u64 (+ (m-u64 a4489) v-ticks-4441))))))
    (return-from |c/remove_duplicated_virtual_binary_clauses| (c-bool (if (c-true v-assigned-4443) 0 1)))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:9091:1
(defun |c/backward_subsume_variable| (arg-v-solver-4490 arg-v-idx-4491)
 (declare  (type c-address arg-v-solver-4490) (type (unsigned-byte 32) arg-v-idx-4491))
 (let ((v-solver-4490 0) (v-idx-4491 0) (v-lit-4495 0) (v-not_lit-4496 0))
 (declare (type c-address v-solver-4490) (type (unsigned-byte 32) v-idx-4491) (type (unsigned-byte 32) v-lit-4495) (type (unsigned-byte 32) v-not_lit-4496) (ignorable v-solver-4490 v-idx-4491 v-lit-4495 v-not_lit-4496))
 (tagbody
    (setf v-solver-4490 arg-v-solver-4490)
    (setf v-idx-4491 arg-v-idx-4491)
    (progn v-solver-4490)
    (setf v-lit-4495 (|c/LITERAL| v-idx-4491))
    (setf v-not_lit-4496 (|c/NOT| v-lit-4495))
    (unless (c-true (if (c-true (|c/remove_duplicated_virtual_binary_clauses| v-solver-4490 v-lit-4495)) 0 1)) (go ELSE4497))
    (return-from |c/backward_subsume_variable| 0)
    ELSE4497
    (unless (c-true (if (c-true (|c/remove_duplicated_virtual_binary_clauses| v-solver-4490 v-not_lit-4496)) 0 1)) (go ELSE4499))
    (return-from |c/backward_subsume_variable| 0)
    ELSE4499
    (progn (|c/backward_subsume_literal| v-solver-4490 v-lit-4495))
    (progn (|c/backward_subsume_literal| v-solver-4490 v-not_lit-4496))
    (progn (set-bits (+ (+ (m-ptr (+ v-solver-4490 48)) (* 4 v-idx-4491)) 0) 4 2 (c-u32 2)))
  )
  0))

;;; upstream/satch.c:9114:1
(defun |c/subsumption_ticks_limit_hit| (arg-v-solver-4501)
 (declare  (type c-address arg-v-solver-4501))
 (let ((v-solver-4501 0))
 (declare (type c-address v-solver-4501) (ignorable v-solver-4501))
 (tagbody
    (setf v-solver-4501 arg-v-solver-4501)
    (return-from |c/subsumption_ticks_limit_hit| (c-bool (if (> (m-u64 (+ (+ v-solver-4501 1016) 304)) (m-u64 (+ (+ (+ v-solver-4501 720) 120) 8))) 1 0)))
  )
  0))

;;; upstream/satch.c:9122:1
(defun |c/full_backward_subsumption| (arg-v-solver-4502)
 (declare  (type c-address arg-v-solver-4502))
 (let ((v-solver-4502 0) (v-subsumptions-4505 0) (v-flags-4511 0) (v-total_subsumed-4512 0) (v-total_strengthened-4513 0) (v-strengthened-4514 0) (v-round-4515 0) (v-subsumed_before-4521 0) (v-strengthened_before-4522 0) (v-remaining-4523 0) (v-scheduled-4524 0) (v-tried-4525 0) (v-idx-4529 0) (v-END_VARIABLES-4530 0) (v-f-4531 0) (v-idx-4542 0) (v-END_VARIABLES-4543 0) (v-f-4544 0) (v-subsumed-4553 0) (v-c-4563 0) (v-PTR_c-4564 0) (v-END_c-4565 0) (v-kept-4568 0) (v-idx-4572 0) (v-END_VARIABLES-4573 0) (v-f-4574 0))
 (declare (type c-address v-solver-4502) (type (unsigned-byte 64) v-subsumptions-4505) (type c-address v-flags-4511) (type (unsigned-byte 64) v-total_subsumed-4512) (type (unsigned-byte 64) v-total_strengthened-4513) (type (unsigned-byte 64) v-strengthened-4514) (type (unsigned-byte 32) v-round-4515) (type (unsigned-byte 64) v-subsumed_before-4521) (type (unsigned-byte 64) v-strengthened_before-4522) (type (unsigned-byte 32) v-remaining-4523) (type (unsigned-byte 32) v-scheduled-4524) (type (unsigned-byte 32) v-tried-4525) (type (unsigned-byte 32) v-idx-4529) (type (unsigned-byte 32) v-END_VARIABLES-4530) (type c-address v-f-4531) (type (unsigned-byte 32) v-idx-4542) (type (unsigned-byte 32) v-END_VARIABLES-4543) (type c-address v-f-4544) (type (unsigned-byte 64) v-subsumed-4553) (type c-address v-c-4563) (type c-address v-PTR_c-4564) (type c-address v-END_c-4565) (type (unsigned-byte 32) v-kept-4568) (type (unsigned-byte 32) v-idx-4572) (type (unsigned-byte 32) v-END_VARIABLES-4573) (type c-address v-f-4574) (ignorable v-solver-4502 v-subsumptions-4505 v-flags-4511 v-total_subsumed-4512 v-total_strengthened-4513 v-strengthened-4514 v-round-4515 v-subsumed_before-4521 v-strengthened_before-4522 v-remaining-4523 v-scheduled-4524 v-tried-4525 v-idx-4529 v-END_VARIABLES-4530 v-f-4531 v-idx-4542 v-END_VARIABLES-4543 v-f-4544 v-subsumed-4553 v-c-4563 v-PTR_c-4564 v-END_c-4565 v-kept-4568 v-idx-4572 v-END_VARIABLES-4573 v-f-4574))
 (tagbody
    (setf v-solver-4502 arg-v-solver-4502)
    (unless (c-true (if (c-true (|c/more_subsumption_candidates| v-solver-4502)) 0 1)) (go ELSE4503))
    (return-from |c/full_backward_subsumption| 0)
    ELSE4503
    (progn (|c/start_profiling| v-solver-4502 (+ (+ v-solver-4502 1472) 144)))
    (locally (declare (optimize (speed 1))) (setf v-subsumptions-4505 (progn 0 (let* ((a4506 (+ (+ v-solver-4502 1016) 312)) (old4507 (m-u64 a4506))) (setf (m-u64 a4506) (c-u64 (c-u64 (+ old4507 (c-u64 1))))) (m-u64 a4506)))))
    (progn v-solver-4502)
    (setf v-flags-4511 (m-ptr (+ v-solver-4502 48)))
    (locally (declare (optimize (speed 1))) (setf v-total_subsumed-4512 (c-u64 0)))
    (locally (declare (optimize (speed 1))) (setf v-total_strengthened-4513 (c-u64 0)))
    (setf v-round-4515 (c-u32 0))
    LOOP4516
    (progn (let* ( (old4520 v-round-4515)) (setf v-round-4515 (c-u32 (c-u32 (+ old4520 (c-u32 1))))) old4520))
    (locally (declare (optimize (speed 1))) (setf v-subsumed_before-4521 (m-u64 (+ (+ v-solver-4502 1016) 320))))
    (locally (declare (optimize (speed 1))) (setf v-strengthened_before-4522 (m-u64 (+ (+ v-solver-4502 1016) 296))))
    (setf v-remaining-4523 (c-u32 (m-u64 (+ (+ v-solver-4502 1016) 216))))
    (setf v-scheduled-4524 (c-u32 0))
    (setf v-tried-4525 (c-u32 0))
    (setf v-idx-4529 (c-u32 0))
    (setf v-END_VARIABLES-4530 (m-u32 (+ v-solver-4502 12)))
    LOOP4526
    (unless (c-true (if (< v-idx-4529 v-END_VARIABLES-4530) 1 0)) (go ENDLOOP4527))
    (setf v-f-4531 (+ v-flags-4511 (* 4 v-idx-4529)))
    (unless (c-true (if (c-true (ldb (byte 1 0) (m-u8 (+ v-f-4531 0)))) (c-bool (let ((a4534 (+ v-f-4531 0))) (set-bits a4534 4 2 (c-u32 (c-u32 (logand (ldb (byte 2 4) (m-u8 a4534)) (c-u32 1))))))) 0)) (go ELSE4532))
    (progn (let* ( (old4536 v-scheduled-4524)) (setf v-scheduled-4524 (c-u32 (c-u32 (+ old4536 (c-u32 1))))) old4536))
    (go ENDIF4533)
    ELSE4532
    ENDIF4533
    (let* ( (old4538 v-idx-4529)) (setf v-idx-4529 (c-u32 (c-u32 (+ old4538 (c-u32 1))))) old4538)
    (go LOOP4526)
    ENDLOOP4527
    (setf v-idx-4542 (c-u32 0))
    (setf v-END_VARIABLES-4543 (m-u32 (+ v-solver-4502 12)))
    LOOP4539
    (unless (c-true (if (< v-idx-4542 v-END_VARIABLES-4543) 1 0)) (go ENDLOOP4540))
    (setf v-f-4544 (+ v-flags-4511 (* 4 v-idx-4542)))
    (unless (c-true (if (c-true (ldb (byte 1 0) (m-u8 (+ v-f-4544 0)))) (c-bool (ldb (byte 2 4) (m-u8 (+ v-f-4544 0)))) 0)) (go ELSE4545))
    (progn (|c/backward_subsume_variable| v-solver-4502 v-idx-4542))
    (progn (let* ( (old4548 v-tried-4525)) (setf v-tried-4525 (c-u32 (c-u32 (+ old4548 (c-u32 1))))) old4548))
    (unless (c-true (|c/subsumption_ticks_limit_hit| v-solver-4502)) (go ELSE4549))
    (progn (when (>= (m-u32 (+ v-solver-4502 884)) (c-u32 4)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-4502 (c-u32 4) |c/string/156| v-subsumptions-4505 |c/string/157|))))
    (go ENDLOOP4540)
    ELSE4549
    (go ENDIF4546)
    ELSE4545
    ENDIF4546
    (let* ( (old4552 v-idx-4542)) (setf v-idx-4542 (c-u32 (c-u32 (+ old4552 (c-u32 1))))) old4552)
    (go LOOP4539)
    ENDLOOP4540
    (progn (when (>= (m-u32 (+ v-solver-4502 884)) (c-u32 3)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-4502 (c-u32 3) |c/string/156| v-subsumptions-4505 |c/string/158| v-tried-4525 (|c/percent| (float v-tried-4525 1d0) (float v-scheduled-4524 1d0)) v-scheduled-4524 (|c/percent| (float v-scheduled-4524 1d0) (float v-remaining-4523 1d0)) v-round-4515))))
    (locally (declare (optimize (speed 1))) (setf v-subsumed-4553 (c-u64 (- (m-u64 (+ (+ v-solver-4502 1016) 320)) v-subsumed_before-4521))))
    (progn (setf v-strengthened-4514 (c-u64 (- (m-u64 (+ (+ v-solver-4502 1016) 296)) v-strengthened_before-4522))))
    (progn (setf v-total_subsumed-4512 (c-u64 (c-u64 (+ v-total_subsumed-4512 v-subsumed-4553)))))
    (progn (setf v-total_strengthened-4513 (c-u64 (c-u64 (+ v-total_strengthened-4513 v-strengthened-4514)))))
    (progn (when (>= (m-u32 (+ v-solver-4502 884)) (c-u32 3)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-4502 (c-u32 3) |c/string/156| v-subsumptions-4505 |c/string/159| v-subsumed-4553 v-strengthened-4514 v-round-4515))))
    (progn (|c/report| v-solver-4502 (c-u32 (c-s32 (+ 1 (if (c-true (c-u64 (+ v-subsumed-4553 v-strengthened-4514))) 0 1)))) 115))
    (unless (c-true (if (>= v-round-4515 (c-u32 2)) 1 0)) (go ELSE4556))
    (go ENDLOOP4517)
    ELSE4556
    (unless (c-true (|c/subsumption_ticks_limit_hit| v-solver-4502)) (go ELSE4558))
    (go ENDLOOP4517)
    ELSE4558
    (when (c-true (if (c-true (if (c-true (m-u8 (+ v-solver-4502 4))) 0 1)) (c-bool v-strengthened-4514) 0)) (go LOOP4516))
    ENDLOOP4517
    (setf v-PTR_c-4564 (m-ptr (+ (+ v-solver-4502 672) 0)))
    (setf v-END_c-4565 (m-ptr (+ (+ v-solver-4502 672) 8)))
    LOOP4560
    (unless (c-true (if (c-true (if (/= v-PTR_c-4564 v-END_c-4565) 1 0)) (c-bool (progn (setf v-c-4563 (m-ptr v-PTR_c-4564)) 1)) 0)) (go ENDLOOP4561))
    (progn (set-bits (+ v-c-4563 0) 3 1 (c-bool 0)))
    (let* ( (old4567 v-PTR_c-4564)) (setf v-PTR_c-4564 (+ old4567 (* 8 1))) v-PTR_c-4564)
    (go LOOP4560)
    ENDLOOP4561
    (setf v-kept-4568 (c-u32 0))
    (setf v-idx-4572 (c-u32 0))
    (setf v-END_VARIABLES-4573 (m-u32 (+ v-solver-4502 12)))
    LOOP4569
    (unless (c-true (if (< v-idx-4572 v-END_VARIABLES-4573) 1 0)) (go ENDLOOP4570))
    (setf v-f-4574 (+ v-flags-4511 (* 4 v-idx-4572)))
    (unless (c-true (c-u32 (logand (ldb (byte 1 0) (m-u8 (+ v-f-4574 0))) (c-u32 (logand (ldb (byte 2 4) (m-u8 (+ v-f-4574 0))) (c-u32 1)))))) (go ELSE4575))
    (progn (let* ( (old4578 v-kept-4568)) (setf v-kept-4568 (c-u32 (c-u32 (+ old4578 (c-u32 1))))) old4578))
    (go ENDIF4576)
    ELSE4575
    ENDIF4576
    (let* ( (old4580 v-idx-4572)) (setf v-idx-4572 (c-u32 (c-u32 (+ old4580 (c-u32 1))))) old4580)
    (go LOOP4569)
    ENDLOOP4570
    (progn (when (>= (m-u32 (+ v-solver-4502 884)) (c-u32 3)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-4502 (c-u32 3) |c/string/156| v-subsumptions-4505 |c/string/160| v-kept-4568 (|c/percent| (float v-kept-4568 1d0) (integer64-double (m-u64 (+ (+ v-solver-4502 1016) 216)) nil))))))
    (unless (c-true (if (c-true v-kept-4568) 0 1)) (go ELSE4581))
    (progn (setf (m-u64 (+ (+ (+ v-solver-4502 720) 120) 0)) (m-u64 (+ (+ v-solver-4502 1016) 144))))
    (go ENDIF4582)
    ELSE4581
    ENDIF4582
    (progn (when (>= (m-u32 (+ v-solver-4502 884)) (c-u32 2)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-4502 (c-u32 2) |c/string/156| v-subsumptions-4505 |c/string/161| v-total_subsumed-4512 v-total_strengthened-4513 v-round-4515))))
    (progn (|c/stop_profiling| v-solver-4502 (+ (+ v-solver-4502 1472) 144) (|c/process_time|)))
  )
  0))

;;; upstream/satch.c:9233:1
(defun |c/actual_number_of_occurrences| (arg-v-solver-4583 arg-v-lit-4584)
 (declare  (type c-address arg-v-solver-4583) (type (unsigned-byte 32) arg-v-lit-4584))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-4583 0) (v-lit-4584 0) (v-watches-4585 0) (v-values-4586 0) (v-begin-4587 0) (v-q-4588 0) (v-end-4589 0) (v-p-4590 0) (v-ticks-4591 0) (v-res-4592 0) (v-watch-4596 (stack-alloc 8)) (v-c-4599 0) (v-other-4602 0) (v-d-4605 0))
 (declare (type c-address v-solver-4583) (type (unsigned-byte 32) v-lit-4584) (type c-address v-watches-4585) (type c-address v-values-4586) (type c-address v-begin-4587) (type c-address v-q-4588) (type c-address v-end-4589) (type c-address v-p-4590) (type (unsigned-byte 64) v-ticks-4591) (type (unsigned-byte 32) v-res-4592) (type c-address v-watch-4596) (type c-address v-c-4599) (type (unsigned-byte 32) v-other-4602) (type c-address v-d-4605) (ignorable v-solver-4583 v-lit-4584 v-watches-4585 v-values-4586 v-begin-4587 v-q-4588 v-end-4589 v-p-4590 v-ticks-4591 v-res-4592 v-watch-4596 v-c-4599 v-other-4602 v-d-4605))
 (tagbody
    (setf v-solver-4583 arg-v-solver-4583)
    (setf v-lit-4584 arg-v-lit-4584)
    (setf v-watches-4585 (+ (m-ptr (+ v-solver-4583 544)) (* 24 v-lit-4584)))
    (setf v-values-4586 (m-ptr (+ v-solver-4583 40)))
    (setf v-begin-4587 (m-ptr (+ v-watches-4585 0)))
    (setf v-q-4588 v-begin-4587)
    (setf v-end-4589 (m-ptr (+ v-watches-4585 8)))
    (setf v-p-4590 v-q-4588)
    (locally (declare (optimize (speed 1))) (setf v-ticks-4591 (c-u64 1)))
    (setf v-res-4592 (c-u32 0))
    LOOP4593
    (unless (c-true (if (/= v-p-4590 v-end-4589) 1 0)) (go ENDLOOP4594))
    (copy-bytes v-watch-4596 (let* ( (old4598 v-p-4590)) (setf v-p-4590 (+ old4598 (* 8 1))) old4598) 8)
    (setf v-c-4599 (m-ptr (+ v-watch-4596 0)))
    (unless (c-true (|c/is_tagged_clause| v-c-4599)) (go ELSE4600))
    (setf v-other-4602 (|c/tagged_clause_to_literal| v-c-4599))
    (unless (c-true (if (> (m-s8 (+ v-values-4586 (* 1 v-other-4602))) 0) 1 0)) (go ELSE4603))
    (progn (|c/really_delete_binary| v-solver-4583 (c-bool 0) v-lit-4584 v-other-4602))
    (setf v-d-4605 (|c/tag_binary_clause| (c-bool 0) v-lit-4584))
    (progn (|c/disconnect_literal| v-solver-4583 v-other-4602 v-d-4605))
    (progn (let* ( (old4607 v-ticks-4591)) (setf v-ticks-4591 (c-u64 (c-u64 (+ old4607 (c-u64 1))))) old4607))
    (go CONTINUE4595)
    ELSE4603
    (go ENDIF4601)
    ELSE4600
    (progn (let* ( (old4609 v-ticks-4591)) (setf v-ticks-4591 (c-u64 (c-u64 (+ old4609 (c-u64 1))))) old4609))
    (unless (c-true (|c/mark_garbage_if_satisfied| v-solver-4583 v-c-4599)) (go ELSE4610))
    (go CONTINUE4595)
    ELSE4610
    ENDIF4601
    (progn (copy-bytes (let* ( (old4613 v-q-4588)) (setf v-q-4588 (+ old4613 (* 8 1))) old4613) v-watch-4596 8))
    (progn (let* ( (old4615 v-res-4592)) (setf v-res-4592 (c-u32 (c-u32 (+ old4615 (c-u32 1))))) old4615))
    (unless (c-true (if (> (float v-res-4592 1d0) 1000.0d0) 1 0)) (go ELSE4616))
    (go ENDLOOP4594)
    ELSE4616
    (unless (c-true (if (c-true (|c/is_tagged_clause| v-c-4599)) 0 1)) (go ELSE4618))
    (unless (c-true (if (> (m-u32 (+ v-c-4599 12)) (c-u32 100)) 1 0)) (go ELSE4620))
    (progn (setf v-res-4592 (values (the (unsigned-byte 32) (truncate (float (+ 1000.0d0 (float 1 1d0)) 1d0))))))
    (go ENDLOOP4594)
    ELSE4620
    (go ENDIF4619)
    ELSE4618
    ENDIF4619
    CONTINUE4595
    (go LOOP4593)
    ENDLOOP4594
    (progn (setf v-ticks-4591 (c-u64 (c-u64 (+ v-ticks-4591 (|c/cache_lines| v-begin-4587 v-q-4588))))))
    (progn (let ((a4626 (+ (+ v-solver-4583 1016) 88))) (setf (m-u64 a4626) (c-u64 (c-u64 (+ (m-u64 a4626) v-ticks-4591))))))
    LOOP4627
    (unless (c-true (if (/= v-p-4590 v-end-4589) 1 0)) (go ENDLOOP4628))
    (progn (copy-bytes (let* ( (old4631 v-q-4588)) (setf v-q-4588 (+ old4631 (* 8 1))) old4631) (let* ( (old4633 v-p-4590)) (setf v-p-4590 (+ old4633 (* 8 1))) old4633) 8))
    (go LOOP4627)
    ENDLOOP4628
    (progn (setf (m-ptr (+ v-watches-4585 8)) v-q-4588))
    (unless (c-true (if (= (m-ptr (+ v-watches-4585 8)) (m-ptr (+ v-watches-4585 0))) 1 0)) (go ELSE4634))
    (progn (c-free (m-ptr (+ v-watches-4585 0))))
    (progn (setf (m-ptr (+ v-watches-4585 0)) (setf (m-ptr (+ v-watches-4585 8)) (setf (m-ptr (+ v-watches-4585 16)) 0))))
    (go ENDIF4635)
    ELSE4634
    ENDIF4635
    (return-from |c/actual_number_of_occurrences| v-res-4592)
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:9311:1
(defun |c/can_be_eliminated| (arg-v-solver-4639 arg-v-pivot_idx-4640)
 (declare  (type c-address arg-v-solver-4639) (type (unsigned-byte 32) arg-v-pivot_idx-4640))
 (let ((v-solver-4639 0) (v-pivot_idx-4640 0) (v-f-4641 0) (v-lit-4646 0) (v-not_lit-4647 0) (v-pos-4648 0) (v-neg-4649 0))
 (declare (type c-address v-solver-4639) (type (unsigned-byte 32) v-pivot_idx-4640) (type c-address v-f-4641) (type (unsigned-byte 32) v-lit-4646) (type (unsigned-byte 32) v-not_lit-4647) (type (unsigned-byte 64) v-pos-4648) (type (unsigned-byte 64) v-neg-4649) (ignorable v-solver-4639 v-pivot_idx-4640 v-f-4641 v-lit-4646 v-not_lit-4647 v-pos-4648 v-neg-4649))
 (tagbody
    (setf v-solver-4639 arg-v-solver-4639)
    (setf v-pivot_idx-4640 arg-v-pivot_idx-4640)
    (setf v-f-4641 (+ (m-ptr (+ v-solver-4639 48)) (* 4 v-pivot_idx-4640)))
    (unless (c-true (if (c-true (ldb (byte 1 0) (m-u8 (+ v-f-4641 0)))) 0 1)) (go ELSE4642))
    (return-from |c/can_be_eliminated| (c-bool 0))
    ELSE4642
    (unless (c-true (if (c-true (ldb (byte 1 1) (m-u8 (+ v-f-4641 0)))) 0 1)) (go ELSE4644))
    (return-from |c/can_be_eliminated| (c-bool 0))
    ELSE4644
    (setf v-lit-4646 (|c/LITERAL| v-pivot_idx-4640))
    (setf v-not_lit-4647 (|c/NOT| v-lit-4646))
    (locally (declare (optimize (speed 1))) (setf v-pos-4648 (|c/actual_number_of_occurrences| v-solver-4639 v-lit-4646)))
    (locally (declare (optimize (speed 1))) (setf v-neg-4649 (|c/actual_number_of_occurrences| v-solver-4639 v-not_lit-4647)))
    (unless (c-true (if (c-true v-pos-4648) (c-bool (if (> (integer64-double v-neg-4649 nil) 1000.0d0) 1 0)) 0)) (go ELSE4650))
    (return-from |c/can_be_eliminated| (c-bool 0))
    ELSE4650
    (unless (c-true (if (c-true v-neg-4649) (c-bool (if (> (integer64-double v-pos-4648 nil) 1000.0d0) 1 0)) 0)) (go ELSE4652))
    (return-from |c/can_be_eliminated| (c-bool 0))
    ELSE4652
    (return-from |c/can_be_eliminated| (c-bool 1))
  )
  0))

;;; upstream/satch.c:9351:1
(defun |c/produces_few_resolvents| (arg-v-solver-4654 arg-v-pivot_idx-4655)
 (declare  (notinline checked-address) (type c-address arg-v-solver-4654) (type (unsigned-byte 32) arg-v-pivot_idx-4655))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-4654 0) (v-pivot_idx-4655 0) (v-pivot-4656 0) (v-not_pivot-4657 0) (v-pos_watches-4658 0) (v-neg_watches-4659 0) (v-pos_count-4663 0) (v-neg_count-4664 0) (v-limit-4665 0) (v-resolvents-4666 0) (v-ticks-4667 0) (v-marks-4670 0) (v-pos_watch-4674 (stack-alloc 8)) (v-PTR_pos_watch-4675 0) (v-END_pos_watch-4676 0) (v-c-4677 0) (v-lit-4687 0) (v-P_lit-4688 0) (v-END_lit-4689 0) (v-neg_watch-4695 (stack-alloc 8)) (v-PTR_neg_watch-4696 0) (v-END_neg_watch-4697 0) (v-d-4698 0) (v-tautological-4713 0) (v-lit-4717 0) (v-P_lit-4718 0) (v-END_lit-4719 0) (v-lit-4739 0) (v-P_lit-4740 0) (v-END_lit-4741 0) (v-old_size-4752 0) (v-old_capacity-4753 0) (v-new_capacity-4754 0) (v-new_bytes-4755 0) (v-lit-4765 0) (v-P_lit-4766 0) (v-END_lit-4767 0) (v-old_size-4778 0) (v-old_capacity-4779 0) (v-new_capacity-4780 0) (v-new_bytes-4781 0) (v-old_size-4796 0) (v-old_capacity-4797 0) (v-new_capacity-4798 0) (v-new_bytes-4799 0) (v-lit-4809 0) (v-P_lit-4810 0) (v-END_lit-4811 0))
 (declare (type c-address v-solver-4654) (type (unsigned-byte 32) v-pivot_idx-4655) (type (unsigned-byte 32) v-pivot-4656) (type (unsigned-byte 32) v-not_pivot-4657) (type c-address v-pos_watches-4658) (type c-address v-neg_watches-4659) (type c-size v-pos_count-4663) (type c-size v-neg_count-4664) (type (unsigned-byte 64) v-limit-4665) (type (unsigned-byte 64) v-resolvents-4666) (type (unsigned-byte 64) v-ticks-4667) (type c-address v-marks-4670) (type c-address v-pos_watch-4674) (type c-address v-PTR_pos_watch-4675) (type c-address v-END_pos_watch-4676) (type c-address v-c-4677) (type (unsigned-byte 32) v-lit-4687) (type c-address v-P_lit-4688) (type c-address v-END_lit-4689) (type c-address v-neg_watch-4695) (type c-address v-PTR_neg_watch-4696) (type c-address v-END_neg_watch-4697) (type c-address v-d-4698) (type (integer 0 1) v-tautological-4713) (type (unsigned-byte 32) v-lit-4717) (type c-address v-P_lit-4718) (type c-address v-END_lit-4719) (type (unsigned-byte 32) v-lit-4739) (type c-address v-P_lit-4740) (type c-address v-END_lit-4741) (type c-size v-old_size-4752) (type c-size v-old_capacity-4753) (type c-size v-new_capacity-4754) (type c-size v-new_bytes-4755) (type (unsigned-byte 32) v-lit-4765) (type c-address v-P_lit-4766) (type c-address v-END_lit-4767) (type c-size v-old_size-4778) (type c-size v-old_capacity-4779) (type c-size v-new_capacity-4780) (type c-size v-new_bytes-4781) (type c-size v-old_size-4796) (type c-size v-old_capacity-4797) (type c-size v-new_capacity-4798) (type c-size v-new_bytes-4799) (type (unsigned-byte 32) v-lit-4809) (type c-address v-P_lit-4810) (type c-address v-END_lit-4811) (ignorable v-solver-4654 v-pivot_idx-4655 v-pivot-4656 v-not_pivot-4657 v-pos_watches-4658 v-neg_watches-4659 v-pos_count-4663 v-neg_count-4664 v-limit-4665 v-resolvents-4666 v-ticks-4667 v-marks-4670 v-pos_watch-4674 v-PTR_pos_watch-4675 v-END_pos_watch-4676 v-c-4677 v-lit-4687 v-P_lit-4688 v-END_lit-4689 v-neg_watch-4695 v-PTR_neg_watch-4696 v-END_neg_watch-4697 v-d-4698 v-tautological-4713 v-lit-4717 v-P_lit-4718 v-END_lit-4719 v-lit-4739 v-P_lit-4740 v-END_lit-4741 v-old_size-4752 v-old_capacity-4753 v-new_capacity-4754 v-new_bytes-4755 v-lit-4765 v-P_lit-4766 v-END_lit-4767 v-old_size-4778 v-old_capacity-4779 v-new_capacity-4780 v-new_bytes-4781 v-old_size-4796 v-old_capacity-4797 v-new_capacity-4798 v-new_bytes-4799 v-lit-4809 v-P_lit-4810 v-END_lit-4811))
 (tagbody
    (setf v-solver-4654 arg-v-solver-4654)
    (setf v-pivot_idx-4655 arg-v-pivot_idx-4655)
    (setf v-pivot-4656 (|c/LITERAL| v-pivot_idx-4655))
    (setf v-not_pivot-4657 (|c/NOT| v-pivot-4656))
    (setf v-pos_watches-4658 (+ (m-ptr (+ v-solver-4654 544)) (* 24 v-pivot-4656)))
    (setf v-neg_watches-4659 (+ (m-ptr (+ v-solver-4654 544)) (* 24 v-not_pivot-4657)))
    (progn v-solver-4654)
    (setf v-pos_count-4663 (the c-size (truncate (- (m-ptr (+ v-pos_watches-4658 8)) (m-ptr (+ v-pos_watches-4658 0))) 8)))
    (setf v-neg_count-4664 (the c-size (truncate (- (m-ptr (+ v-neg_watches-4659 8)) (m-ptr (+ v-neg_watches-4659 0))) 8)))
    (locally (declare (optimize (speed 1))) (setf v-limit-4665 (c-u64 (+ v-pos_count-4663 v-neg_count-4664))))
    (locally (declare (optimize (speed 1))) (setf v-resolvents-4666 (c-u64 0)))
    (locally (declare (optimize (speed 1))) (setf v-ticks-4667 (c-u64 2)))
    (progn (setf v-ticks-4667 (c-u64 (c-u64 (+ v-ticks-4667 (|c/cache_lines| (m-ptr (+ v-pos_watches-4658 0)) (m-ptr (+ v-pos_watches-4658 8))))))))
    (progn (setf v-ticks-4667 (c-u64 (c-u64 (+ v-ticks-4667 (|c/cache_lines| (m-ptr (+ v-neg_watches-4659 0)) (m-ptr (+ v-neg_watches-4659 8))))))))
    (setf v-marks-4670 (m-ptr (+ v-solver-4654 96)))
    (setf v-PTR_pos_watch-4675 (m-ptr (+ v-pos_watches-4658 0)))
    (setf v-END_pos_watch-4676 (m-ptr (+ v-pos_watches-4658 8)))
    LOOP4671
    (unless (c-true (if (c-true (if (/= v-PTR_pos_watch-4675 v-END_pos_watch-4676) 1 0)) (c-bool (progn (copy-bytes v-pos_watch-4674 v-PTR_pos_watch-4675 8) 1)) 0)) (go ENDLOOP4672))
    (setf v-c-4677 (m-ptr (+ v-pos_watch-4674 0)))
    (unless (c-true (|c/is_tagged_clause| v-c-4677)) (go ELSE4678))
    (progn (setf v-c-4677 (|c/untag_clause| v-solver-4654 (c-u32 0) v-pivot-4656 v-c-4677)))
    (go ENDIF4679)
    ELSE4678
    (progn (let* ( (old4681 v-ticks-4667)) (setf v-ticks-4667 (c-u64 (c-u64 (+ old4681 (c-u64 1))))) old4681))
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-c-4677 0)))) (go ELSE4682))
    (go CONTINUE4673)
    ELSE4682
    ENDIF4679
    (setf v-P_lit-4688 (+ v-c-4677 16))
    (setf v-END_lit-4689 (+ v-P_lit-4688 (* 4 (m-u32 (+ v-c-4677 12)))))
    LOOP4684
    (unless (c-true (if (c-true (if (/= v-P_lit-4688 v-END_lit-4689) 1 0)) (c-bool (progn (setf v-lit-4687 (m-u32 v-P_lit-4688)) 1)) 0)) (go ENDLOOP4685))
    (progn (|c/mark_literal| v-marks-4670 v-lit-4687))
    (let* ( (old4691 v-P_lit-4688)) (setf v-P_lit-4688 (+ old4691 (* 4 1))) v-P_lit-4688)
    (go LOOP4684)
    ENDLOOP4685
    (setf v-PTR_neg_watch-4696 (m-ptr (+ v-neg_watches-4659 0)))
    (setf v-END_neg_watch-4697 (m-ptr (+ v-neg_watches-4659 8)))
    LOOP4692
    (unless (c-true (if (c-true (if (/= v-PTR_neg_watch-4696 v-END_neg_watch-4697) 1 0)) (c-bool (progn (copy-bytes v-neg_watch-4695 v-PTR_neg_watch-4696 8) 1)) 0)) (go ENDLOOP4693))
    (setf v-d-4698 (m-ptr (+ v-neg_watch-4695 0)))
    (unless (c-true (|c/is_tagged_clause| v-d-4698)) (go ELSE4699))
    (progn (setf v-d-4698 (|c/untag_clause| v-solver-4654 (c-u32 1) v-not_pivot-4657 v-d-4698)))
    (go ENDIF4700)
    ELSE4699
    (progn (let* ( (old4702 v-ticks-4667)) (setf v-ticks-4667 (c-u64 (c-u64 (+ old4702 (c-u64 1))))) old4702))
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-d-4698 0)))) (go ELSE4703))
    (go CONTINUE4694)
    ELSE4703
    ENDIF4700
    (progn v-solver-4654)
    (progn v-solver-4654)
    (progn (progn 0 (let* ((a4711 (+ (+ v-solver-4654 1016) 184)) (old4712 (m-u64 a4711))) (setf (m-u64 a4711) (c-u64 (c-u64 (+ old4712 (c-u64 1))))) (m-u64 a4711))))
    (setf v-tautological-4713 (c-bool 0))
    (setf v-P_lit-4718 (+ v-d-4698 16))
    (setf v-END_lit-4719 (+ v-P_lit-4718 (* 4 (m-u32 (+ v-d-4698 12)))))
    LOOP4714
    (unless (c-true (if (c-true (if (/= v-P_lit-4718 v-END_lit-4719) 1 0)) (c-bool (progn (setf v-lit-4717 (m-u32 v-P_lit-4718)) 1)) 0)) (go ENDLOOP4715))
    (unless (c-true (if (c-true (if (/= v-lit-4717 v-not_pivot-4657) 1 0)) (c-bool (if (< (|c/marked_literal| v-marks-4670 v-lit-4717) 0) 1 0)) 0)) (go ELSE4720))
    (progn v-solver-4654)
    (progn (setf v-tautological-4713 (c-bool 1)))
    (go ENDLOOP4715)
    ELSE4720
    (let* ( (old4726 v-P_lit-4718)) (setf v-P_lit-4718 (+ old4726 (* 4 1))) v-P_lit-4718)
    (go LOOP4714)
    ENDLOOP4715
    (unless (c-true v-tautological-4713) (go ELSE4727))
    (go CONTINUE4694)
    ELSE4727
    (progn v-solver-4654)
    (unless (c-true (if (> (let* ( (old4735 v-resolvents-4666)) (setf v-resolvents-4666 (c-u64 (c-u64 (+ old4735 (c-u64 1))))) v-resolvents-4666) v-limit-4665) 1 0)) (go ELSE4732))
    (go ENDLOOP4693)
    ELSE4732
    (setf v-P_lit-4740 (+ v-c-4677 16))
    (setf v-END_lit-4741 (+ v-P_lit-4740 (* 4 (m-u32 (+ v-c-4677 12)))))
    LOOP4736
    (unless (c-true (if (c-true (if (/= v-P_lit-4740 v-END_lit-4741) 1 0)) (c-bool (progn (setf v-lit-4739 (m-u32 v-P_lit-4740)) 1)) 0)) (go ENDLOOP4737))
    (unless (c-true (if (/= v-lit-4739 v-pivot-4656) 1 0)) (go ELSE4742))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-4654 520) 8)) (m-ptr (+ (+ v-solver-4654 520) 16))) 1 0)) (go ELSE4747))
    (setf v-old_size-4752 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4654 520) 8)) (m-ptr (+ (+ v-solver-4654 520) 0))) 4)))
    (setf v-old_capacity-4753 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4654 520) 16)) (m-ptr (+ (+ v-solver-4654 520) 0))) 4)))
    (setf v-new_capacity-4754 (if (c-true v-old_capacity-4753) (c-u64 (* (c-u64 2) v-old_capacity-4753)) (c-u64 1)))
    (setf v-new_bytes-4755 (c-u64 (* v-new_capacity-4754 4)))
    (progn (setf (m-ptr (+ (+ v-solver-4654 520) 0)) (c-realloc (m-ptr (+ (+ v-solver-4654 520) 0)) v-new_bytes-4755)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-4654 520) 0))) 0 1)) (go ELSE4756))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-4755))
    (go ENDIF4757)
    ELSE4756
    ENDIF4757
    (progn (setf (m-ptr (+ (+ v-solver-4654 520) 8)) (+ (m-ptr (+ (+ v-solver-4654 520) 0)) (* 4 v-old_size-4752))))
    (progn (setf (m-ptr (+ (+ v-solver-4654 520) 16)) (+ (m-ptr (+ (+ v-solver-4654 520) 0)) (* 4 v-new_capacity-4754))))
    (go ENDIF4748)
    ELSE4747
    ENDIF4748
    (progn (setf (m-u32 (let* ((a4758 (+ (+ v-solver-4654 520) 8)) (old4759 (m-ptr a4758))) (setf (m-ptr a4758) (+ old4759 (* 4 1))) old4759)) v-lit-4739))
    (go ENDIF4743)
    ELSE4742
    ENDIF4743
    (let* ( (old4761 v-P_lit-4740)) (setf v-P_lit-4740 (+ old4761 (* 4 1))) v-P_lit-4740)
    (go LOOP4736)
    ENDLOOP4737
    (setf v-P_lit-4766 (+ v-d-4698 16))
    (setf v-END_lit-4767 (+ v-P_lit-4766 (* 4 (m-u32 (+ v-d-4698 12)))))
    LOOP4762
    (unless (c-true (if (c-true (if (/= v-P_lit-4766 v-END_lit-4767) 1 0)) (c-bool (progn (setf v-lit-4765 (m-u32 v-P_lit-4766)) 1)) 0)) (go ENDLOOP4763))
    (unless (c-true (if (c-true (m-s8 (+ v-marks-4670 (* 1 (|c/INDEX| v-lit-4765))))) 0 1)) (go ELSE4768))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-4654 520) 8)) (m-ptr (+ (+ v-solver-4654 520) 16))) 1 0)) (go ELSE4773))
    (setf v-old_size-4778 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4654 520) 8)) (m-ptr (+ (+ v-solver-4654 520) 0))) 4)))
    (setf v-old_capacity-4779 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4654 520) 16)) (m-ptr (+ (+ v-solver-4654 520) 0))) 4)))
    (setf v-new_capacity-4780 (if (c-true v-old_capacity-4779) (c-u64 (* (c-u64 2) v-old_capacity-4779)) (c-u64 1)))
    (setf v-new_bytes-4781 (c-u64 (* v-new_capacity-4780 4)))
    (progn (setf (m-ptr (+ (+ v-solver-4654 520) 0)) (c-realloc (m-ptr (+ (+ v-solver-4654 520) 0)) v-new_bytes-4781)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-4654 520) 0))) 0 1)) (go ELSE4782))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-4781))
    (go ENDIF4783)
    ELSE4782
    ENDIF4783
    (progn (setf (m-ptr (+ (+ v-solver-4654 520) 8)) (+ (m-ptr (+ (+ v-solver-4654 520) 0)) (* 4 v-old_size-4778))))
    (progn (setf (m-ptr (+ (+ v-solver-4654 520) 16)) (+ (m-ptr (+ (+ v-solver-4654 520) 0)) (* 4 v-new_capacity-4780))))
    (go ENDIF4774)
    ELSE4773
    ENDIF4774
    (progn (setf (m-u32 (let* ((a4784 (+ (+ v-solver-4654 520) 8)) (old4785 (m-ptr a4784))) (setf (m-ptr a4784) (+ old4785 (* 4 1))) old4785)) v-lit-4765))
    (go ENDIF4769)
    ELSE4768
    ENDIF4769
    (let* ( (old4787 v-P_lit-4766)) (setf v-P_lit-4766 (+ old4787 (* 4 1))) v-P_lit-4766)
    (go LOOP4762)
    ENDLOOP4763
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-4654 520) 8)) (m-ptr (+ (+ v-solver-4654 520) 16))) 1 0)) (go ELSE4791))
    (setf v-old_size-4796 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4654 520) 8)) (m-ptr (+ (+ v-solver-4654 520) 0))) 4)))
    (setf v-old_capacity-4797 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4654 520) 16)) (m-ptr (+ (+ v-solver-4654 520) 0))) 4)))
    (setf v-new_capacity-4798 (if (c-true v-old_capacity-4797) (c-u64 (* (c-u64 2) v-old_capacity-4797)) (c-u64 1)))
    (setf v-new_bytes-4799 (c-u64 (* v-new_capacity-4798 4)))
    (progn (setf (m-ptr (+ (+ v-solver-4654 520) 0)) (c-realloc (m-ptr (+ (+ v-solver-4654 520) 0)) v-new_bytes-4799)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-4654 520) 0))) 0 1)) (go ELSE4800))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-4799))
    (go ENDIF4801)
    ELSE4800
    ENDIF4801
    (progn (setf (m-ptr (+ (+ v-solver-4654 520) 8)) (+ (m-ptr (+ (+ v-solver-4654 520) 0)) (* 4 v-old_size-4796))))
    (progn (setf (m-ptr (+ (+ v-solver-4654 520) 16)) (+ (m-ptr (+ (+ v-solver-4654 520) 0)) (* 4 v-new_capacity-4798))))
    (go ENDIF4792)
    ELSE4791
    ENDIF4792
    (progn (setf (m-u32 (let* ((a4802 (+ (+ v-solver-4654 520) 8)) (old4803 (m-ptr a4802))) (setf (m-ptr a4802) (+ old4803 (* 4 1))) old4803)) 4294967295))
    CONTINUE4694
    (let* ( (old4805 v-PTR_neg_watch-4696)) (setf v-PTR_neg_watch-4696 (+ old4805 (* 8 1))) v-PTR_neg_watch-4696)
    (go LOOP4692)
    ENDLOOP4693
    (setf v-P_lit-4810 (+ v-c-4677 16))
    (setf v-END_lit-4811 (+ v-P_lit-4810 (* 4 (m-u32 (+ v-c-4677 12)))))
    LOOP4806
    (unless (c-true (if (c-true (if (/= v-P_lit-4810 v-END_lit-4811) 1 0)) (c-bool (progn (setf v-lit-4809 (m-u32 v-P_lit-4810)) 1)) 0)) (go ENDLOOP4807))
    (progn (|c/unmark_literal| v-marks-4670 v-lit-4809))
    (let* ( (old4813 v-P_lit-4810)) (setf v-P_lit-4810 (+ old4813 (* 4 1))) v-P_lit-4810)
    (go LOOP4806)
    ENDLOOP4807
    (unless (c-true (if (> v-resolvents-4666 v-limit-4665) 1 0)) (go ELSE4814))
    (go ENDLOOP4672)
    ELSE4814
    (unless (c-true (m-u8 (+ v-solver-4654 4))) (go ELSE4816))
    (go ENDLOOP4672)
    ELSE4816
    CONTINUE4673
    (let* ( (old4819 v-PTR_pos_watch-4675)) (setf v-PTR_pos_watch-4675 (+ old4819 (* 8 1))) v-PTR_pos_watch-4675)
    (go LOOP4671)
    ENDLOOP4672
    (progn (let ((a4823 (+ (+ v-solver-4654 1016) 88))) (setf (m-u64 a4823) (c-u64 (c-u64 (+ (m-u64 a4823) v-ticks-4667))))))
    (unless (c-true (m-u8 (+ v-solver-4654 4))) (go ELSE4824))
    (return-from |c/produces_few_resolvents| (c-bool 0))
    ELSE4824
    (unless (c-true (if (> v-resolvents-4666 v-limit-4665) 1 0)) (go ELSE4826))
    (progn (setf (m-ptr (+ (+ v-solver-4654 520) 8)) (m-ptr (+ (+ v-solver-4654 520) 0))))
    (progn v-solver-4654)
    (return-from |c/produces_few_resolvents| (c-bool 0))
    ELSE4826
    (progn v-solver-4654)
    (return-from |c/produces_few_resolvents| (c-bool 1))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:9486:1
(defun |c/add_and_connect_resolvent| (arg-v-solver-4837)
 (declare  (type c-address arg-v-solver-4837))
 (let ((v-solver-4837 0) (v-size-4838 0) (v-unit-4846 0) (v-lit-4852 0) (v-other-4853 0) (v-resolvent-4859 0) (v-lit-4866 0) (v-PTR_lit-4867 0) (v-END_lit-4868 0))
 (declare (type c-address v-solver-4837) (type c-size v-size-4838) (type (unsigned-byte 32) v-unit-4846) (type (unsigned-byte 32) v-lit-4852) (type (unsigned-byte 32) v-other-4853) (type c-address v-resolvent-4859) (type (unsigned-byte 32) v-lit-4866) (type c-address v-PTR_lit-4867) (type c-address v-END_lit-4868) (ignorable v-solver-4837 v-size-4838 v-unit-4846 v-lit-4852 v-other-4853 v-resolvent-4859 v-lit-4866 v-PTR_lit-4867 v-END_lit-4868))
 (tagbody
    (setf v-solver-4837 arg-v-solver-4837)
    (setf v-size-4838 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4837 624) 8)) (m-ptr (+ (+ v-solver-4837 624) 0))) 4)))
    (unless (c-true (if (c-true v-size-4838) 0 1)) (go ELSE4839))
    (progn v-solver-4837)
    (progn (setf (m-u8 (+ v-solver-4837 4)) (c-bool 1)))
    (go ENDIF4840)
    ELSE4839
    (unless (c-true (if (= v-size-4838 (c-u64 1)) 1 0)) (go ELSE4844))
    (setf v-unit-4846 (m-u32 (+ (m-ptr (+ (+ v-solver-4837 624) 0)) (* 4 (progn 0 0)))))
    (progn v-solver-4837)
    (progn (|c/assign| v-solver-4837 v-unit-4846 0 (c-bool 1)))
    (go ENDIF4845)
    ELSE4844
    (unless (c-true (if (= v-size-4838 (c-u64 2)) 1 0)) (go ELSE4850))
    (setf v-lit-4852 (m-u32 (+ (m-ptr (+ (+ v-solver-4837 624) 0)) (* 4 (progn 0 0)))))
    (setf v-other-4853 (m-u32 (+ (m-ptr (+ (+ v-solver-4837 624) 0)) (* 4 (progn 0 1)))))
    (progn v-solver-4837)
    (progn (|c/connect_literal| v-solver-4837 v-lit-4852 (|c/tag_binary_clause| (c-bool 0) v-other-4853)))
    (progn (|c/connect_literal| v-solver-4837 v-other-4853 (|c/tag_binary_clause| (c-bool 0) v-lit-4852)))
    (progn (progn 0 (let* ((a4857 (+ (+ v-solver-4837 1016) 120)) (old4858 (m-u64 a4857))) (setf (m-u64 a4857) (c-u64 (c-u64 (+ old4858 (c-u64 1))))) (m-u64 a4857))))
    (go ENDIF4851)
    ELSE4850
    (setf v-resolvent-4859 (|c/new_irredundant_clause| v-solver-4837))
    (progn v-solver-4837)
    (progn (|c/connect_clause| v-solver-4837 v-resolvent-4859))
    ENDIF4851
    ENDIF4845
    ENDIF4840
    (setf v-PTR_lit-4867 (m-ptr (+ (+ v-solver-4837 624) 0)))
    (setf v-END_lit-4868 (m-ptr (+ (+ v-solver-4837 624) 8)))
    LOOP4863
    (unless (c-true (if (c-true (if (/= v-PTR_lit-4867 v-END_lit-4868) 1 0)) (c-bool (progn (setf v-lit-4866 (m-u32 v-PTR_lit-4867)) 1)) 0)) (go ENDLOOP4864))
    (progn (|c/mark_subsume_literal| v-solver-4837 v-lit-4866))
    (let* ( (old4870 v-PTR_lit-4867)) (setf v-PTR_lit-4867 (+ old4870 (* 4 1))) v-PTR_lit-4867)
    (go LOOP4863)
    ENDLOOP4864
  )
  0))

;;; upstream/satch.c:9534:1
(defun |c/push_clause_on_extension_stack| (arg-v-solver-4871 arg-v-eliminated-4872 arg-v-c-4873)
 (declare  (type c-address arg-v-solver-4871) (type (unsigned-byte 32) arg-v-eliminated-4872) (type c-address arg-v-c-4873))
 (let ((v-solver-4871 0) (v-eliminated-4872 0) (v-c-4873 0) (v-old_size-4884 0) (v-old_capacity-4885 0) (v-new_capacity-4886 0) (v-new_bytes-4887 0) (v-old_size-4900 0) (v-old_capacity-4901 0) (v-new_capacity-4902 0) (v-new_bytes-4903 0) (v-lit-4911 0) (v-P_lit-4912 0) (v-END_lit-4913 0) (v-old_size-4924 0) (v-old_capacity-4925 0) (v-new_capacity-4926 0) (v-new_bytes-4927 0))
 (declare (type c-address v-solver-4871) (type (unsigned-byte 32) v-eliminated-4872) (type c-address v-c-4873) (type c-size v-old_size-4884) (type c-size v-old_capacity-4885) (type c-size v-new_capacity-4886) (type c-size v-new_bytes-4887) (type c-size v-old_size-4900) (type c-size v-old_capacity-4901) (type c-size v-new_capacity-4902) (type c-size v-new_bytes-4903) (type (unsigned-byte 32) v-lit-4911) (type c-address v-P_lit-4912) (type c-address v-END_lit-4913) (type c-size v-old_size-4924) (type c-size v-old_capacity-4925) (type c-size v-new_capacity-4926) (type c-size v-new_bytes-4927) (ignorable v-solver-4871 v-eliminated-4872 v-c-4873 v-old_size-4884 v-old_capacity-4885 v-new_capacity-4886 v-new_bytes-4887 v-old_size-4900 v-old_capacity-4901 v-new_capacity-4902 v-new_bytes-4903 v-lit-4911 v-P_lit-4912 v-END_lit-4913 v-old_size-4924 v-old_capacity-4925 v-new_capacity-4926 v-new_bytes-4927))
 (tagbody
    (setf v-solver-4871 arg-v-solver-4871)
    (setf v-eliminated-4872 arg-v-eliminated-4872)
    (setf v-c-4873 arg-v-c-4873)
    (unless (c-true (|c/is_tagged_clause| v-c-4873)) (go ELSE4874))
    (progn (setf v-c-4873 (|c/untag_clause| v-solver-4871 (c-u32 0) v-eliminated-4872 v-c-4873)))
    (go ENDIF4875)
    ELSE4874
    ENDIF4875
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-4871 496) 8)) (m-ptr (+ (+ v-solver-4871 496) 16))) 1 0)) (go ELSE4879))
    (setf v-old_size-4884 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4871 496) 8)) (m-ptr (+ (+ v-solver-4871 496) 0))) 4)))
    (setf v-old_capacity-4885 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4871 496) 16)) (m-ptr (+ (+ v-solver-4871 496) 0))) 4)))
    (setf v-new_capacity-4886 (if (c-true v-old_capacity-4885) (c-u64 (* (c-u64 2) v-old_capacity-4885)) (c-u64 1)))
    (setf v-new_bytes-4887 (c-u64 (* v-new_capacity-4886 4)))
    (progn (setf (m-ptr (+ (+ v-solver-4871 496) 0)) (c-realloc (m-ptr (+ (+ v-solver-4871 496) 0)) v-new_bytes-4887)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-4871 496) 0))) 0 1)) (go ELSE4888))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-4887))
    (go ENDIF4889)
    ELSE4888
    ENDIF4889
    (progn (setf (m-ptr (+ (+ v-solver-4871 496) 8)) (+ (m-ptr (+ (+ v-solver-4871 496) 0)) (* 4 v-old_size-4884))))
    (progn (setf (m-ptr (+ (+ v-solver-4871 496) 16)) (+ (m-ptr (+ (+ v-solver-4871 496) 0)) (* 4 v-new_capacity-4886))))
    (go ENDIF4880)
    ELSE4879
    ENDIF4880
    (progn (setf (m-u32 (let* ((a4890 (+ (+ v-solver-4871 496) 8)) (old4891 (m-ptr a4890))) (setf (m-ptr a4890) (+ old4891 (* 4 1))) old4891)) 4294967295))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-4871 496) 8)) (m-ptr (+ (+ v-solver-4871 496) 16))) 1 0)) (go ELSE4895))
    (setf v-old_size-4900 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4871 496) 8)) (m-ptr (+ (+ v-solver-4871 496) 0))) 4)))
    (setf v-old_capacity-4901 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4871 496) 16)) (m-ptr (+ (+ v-solver-4871 496) 0))) 4)))
    (setf v-new_capacity-4902 (if (c-true v-old_capacity-4901) (c-u64 (* (c-u64 2) v-old_capacity-4901)) (c-u64 1)))
    (setf v-new_bytes-4903 (c-u64 (* v-new_capacity-4902 4)))
    (progn (setf (m-ptr (+ (+ v-solver-4871 496) 0)) (c-realloc (m-ptr (+ (+ v-solver-4871 496) 0)) v-new_bytes-4903)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-4871 496) 0))) 0 1)) (go ELSE4904))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-4903))
    (go ENDIF4905)
    ELSE4904
    ENDIF4905
    (progn (setf (m-ptr (+ (+ v-solver-4871 496) 8)) (+ (m-ptr (+ (+ v-solver-4871 496) 0)) (* 4 v-old_size-4900))))
    (progn (setf (m-ptr (+ (+ v-solver-4871 496) 16)) (+ (m-ptr (+ (+ v-solver-4871 496) 0)) (* 4 v-new_capacity-4902))))
    (go ENDIF4896)
    ELSE4895
    ENDIF4896
    (progn (setf (m-u32 (let* ((a4906 (+ (+ v-solver-4871 496) 8)) (old4907 (m-ptr a4906))) (setf (m-ptr a4906) (+ old4907 (* 4 1))) old4907)) v-eliminated-4872))
    (setf v-P_lit-4912 (+ v-c-4873 16))
    (setf v-END_lit-4913 (+ v-P_lit-4912 (* 4 (m-u32 (+ v-c-4873 12)))))
    LOOP4908
    (unless (c-true (if (c-true (if (/= v-P_lit-4912 v-END_lit-4913) 1 0)) (c-bool (progn (setf v-lit-4911 (m-u32 v-P_lit-4912)) 1)) 0)) (go ENDLOOP4909))
    (unless (c-true (if (/= v-lit-4911 v-eliminated-4872) 1 0)) (go ELSE4914))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-4871 496) 8)) (m-ptr (+ (+ v-solver-4871 496) 16))) 1 0)) (go ELSE4919))
    (setf v-old_size-4924 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4871 496) 8)) (m-ptr (+ (+ v-solver-4871 496) 0))) 4)))
    (setf v-old_capacity-4925 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4871 496) 16)) (m-ptr (+ (+ v-solver-4871 496) 0))) 4)))
    (setf v-new_capacity-4926 (if (c-true v-old_capacity-4925) (c-u64 (* (c-u64 2) v-old_capacity-4925)) (c-u64 1)))
    (setf v-new_bytes-4927 (c-u64 (* v-new_capacity-4926 4)))
    (progn (setf (m-ptr (+ (+ v-solver-4871 496) 0)) (c-realloc (m-ptr (+ (+ v-solver-4871 496) 0)) v-new_bytes-4927)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-4871 496) 0))) 0 1)) (go ELSE4928))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-4927))
    (go ENDIF4929)
    ELSE4928
    ENDIF4929
    (progn (setf (m-ptr (+ (+ v-solver-4871 496) 8)) (+ (m-ptr (+ (+ v-solver-4871 496) 0)) (* 4 v-old_size-4924))))
    (progn (setf (m-ptr (+ (+ v-solver-4871 496) 16)) (+ (m-ptr (+ (+ v-solver-4871 496) 0)) (* 4 v-new_capacity-4926))))
    (go ENDIF4920)
    ELSE4919
    ENDIF4920
    (progn (setf (m-u32 (let* ((a4930 (+ (+ v-solver-4871 496) 8)) (old4931 (m-ptr a4930))) (setf (m-ptr a4930) (+ old4931 (* 4 1))) old4931)) v-lit-4911))
    (go ENDIF4915)
    ELSE4914
    ENDIF4915
    (let* ( (old4933 v-P_lit-4912)) (setf v-P_lit-4912 (+ old4933 (* 4 1))) v-P_lit-4912)
    (go LOOP4908)
    ENDLOOP4909
  )
  0))

;;; upstream/satch.c:9549:1
(defun |c/push_unit_on_extension_stack| (arg-v-solver-4934 arg-v-eliminated-4935)
 (declare  (type c-address arg-v-solver-4934) (type (unsigned-byte 32) arg-v-eliminated-4935))
 (let ((v-solver-4934 0) (v-eliminated-4935 0) (v-old_size-4944 0) (v-old_capacity-4945 0) (v-new_capacity-4946 0) (v-new_bytes-4947 0) (v-old_size-4960 0) (v-old_capacity-4961 0) (v-new_capacity-4962 0) (v-new_bytes-4963 0))
 (declare (type c-address v-solver-4934) (type (unsigned-byte 32) v-eliminated-4935) (type c-size v-old_size-4944) (type c-size v-old_capacity-4945) (type c-size v-new_capacity-4946) (type c-size v-new_bytes-4947) (type c-size v-old_size-4960) (type c-size v-old_capacity-4961) (type c-size v-new_capacity-4962) (type c-size v-new_bytes-4963) (ignorable v-solver-4934 v-eliminated-4935 v-old_size-4944 v-old_capacity-4945 v-new_capacity-4946 v-new_bytes-4947 v-old_size-4960 v-old_capacity-4961 v-new_capacity-4962 v-new_bytes-4963))
 (tagbody
    (setf v-solver-4934 arg-v-solver-4934)
    (setf v-eliminated-4935 arg-v-eliminated-4935)
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-4934 496) 8)) (m-ptr (+ (+ v-solver-4934 496) 16))) 1 0)) (go ELSE4939))
    (setf v-old_size-4944 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4934 496) 8)) (m-ptr (+ (+ v-solver-4934 496) 0))) 4)))
    (setf v-old_capacity-4945 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4934 496) 16)) (m-ptr (+ (+ v-solver-4934 496) 0))) 4)))
    (setf v-new_capacity-4946 (if (c-true v-old_capacity-4945) (c-u64 (* (c-u64 2) v-old_capacity-4945)) (c-u64 1)))
    (setf v-new_bytes-4947 (c-u64 (* v-new_capacity-4946 4)))
    (progn (setf (m-ptr (+ (+ v-solver-4934 496) 0)) (c-realloc (m-ptr (+ (+ v-solver-4934 496) 0)) v-new_bytes-4947)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-4934 496) 0))) 0 1)) (go ELSE4948))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-4947))
    (go ENDIF4949)
    ELSE4948
    ENDIF4949
    (progn (setf (m-ptr (+ (+ v-solver-4934 496) 8)) (+ (m-ptr (+ (+ v-solver-4934 496) 0)) (* 4 v-old_size-4944))))
    (progn (setf (m-ptr (+ (+ v-solver-4934 496) 16)) (+ (m-ptr (+ (+ v-solver-4934 496) 0)) (* 4 v-new_capacity-4946))))
    (go ENDIF4940)
    ELSE4939
    ENDIF4940
    (progn (setf (m-u32 (let* ((a4950 (+ (+ v-solver-4934 496) 8)) (old4951 (m-ptr a4950))) (setf (m-ptr a4950) (+ old4951 (* 4 1))) old4951)) 4294967295))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-4934 496) 8)) (m-ptr (+ (+ v-solver-4934 496) 16))) 1 0)) (go ELSE4955))
    (setf v-old_size-4960 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4934 496) 8)) (m-ptr (+ (+ v-solver-4934 496) 0))) 4)))
    (setf v-old_capacity-4961 (the c-size (truncate (- (m-ptr (+ (+ v-solver-4934 496) 16)) (m-ptr (+ (+ v-solver-4934 496) 0))) 4)))
    (setf v-new_capacity-4962 (if (c-true v-old_capacity-4961) (c-u64 (* (c-u64 2) v-old_capacity-4961)) (c-u64 1)))
    (setf v-new_bytes-4963 (c-u64 (* v-new_capacity-4962 4)))
    (progn (setf (m-ptr (+ (+ v-solver-4934 496) 0)) (c-realloc (m-ptr (+ (+ v-solver-4934 496) 0)) v-new_bytes-4963)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-4934 496) 0))) 0 1)) (go ELSE4964))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-4963))
    (go ENDIF4965)
    ELSE4964
    ENDIF4965
    (progn (setf (m-ptr (+ (+ v-solver-4934 496) 8)) (+ (m-ptr (+ (+ v-solver-4934 496) 0)) (* 4 v-old_size-4960))))
    (progn (setf (m-ptr (+ (+ v-solver-4934 496) 16)) (+ (m-ptr (+ (+ v-solver-4934 496) 0)) (* 4 v-new_capacity-4962))))
    (go ENDIF4956)
    ELSE4955
    ENDIF4956
    (progn (setf (m-u32 (let* ((a4966 (+ (+ v-solver-4934 496) 8)) (old4967 (m-ptr a4966))) (setf (m-ptr a4966) (+ old4967 (* 4 1))) old4967)) v-eliminated-4935))
  )
  0))

;;; upstream/satch.c:9556:1
(defun |c/push_clauses_on_extension_stack| (arg-v-solver-4968 arg-v-eliminated-4969 arg-v-watches-4970)
 (declare  (type c-address arg-v-solver-4968) (type (unsigned-byte 32) arg-v-eliminated-4969) (type c-address arg-v-watches-4970))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-4968 0) (v-eliminated-4969 0) (v-watches-4970 0) (v-watch-4974 (stack-alloc 8)) (v-PTR_watch-4975 0) (v-END_watch-4976 0))
 (declare (type c-address v-solver-4968) (type (unsigned-byte 32) v-eliminated-4969) (type c-address v-watches-4970) (type c-address v-watch-4974) (type c-address v-PTR_watch-4975) (type c-address v-END_watch-4976) (ignorable v-solver-4968 v-eliminated-4969 v-watches-4970 v-watch-4974 v-PTR_watch-4975 v-END_watch-4976))
 (tagbody
    (setf v-solver-4968 arg-v-solver-4968)
    (setf v-eliminated-4969 arg-v-eliminated-4969)
    (setf v-watches-4970 arg-v-watches-4970)
    (setf v-PTR_watch-4975 (m-ptr (+ v-watches-4970 0)))
    (setf v-END_watch-4976 (m-ptr (+ v-watches-4970 8)))
    LOOP4971
    (unless (c-true (if (c-true (if (/= v-PTR_watch-4975 v-END_watch-4976) 1 0)) (c-bool (progn (copy-bytes v-watch-4974 v-PTR_watch-4975 8) 1)) 0)) (go ENDLOOP4972))
    (progn (|c/push_clause_on_extension_stack| v-solver-4968 v-eliminated-4969 (m-ptr (+ v-watch-4974 0))))
    (let* ( (old4978 v-PTR_watch-4975)) (setf v-PTR_watch-4975 (+ old4978 (* 8 1))) v-PTR_watch-4975)
    (go LOOP4971)
    ENDLOOP4972
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:9566:1
(defun |c/eliminate_watched_clause| (arg-v-solver-4979 arg-v-eliminated-4980 arg-v-c-4981)
 (declare  (type c-address arg-v-solver-4979) (type (unsigned-byte 32) arg-v-eliminated-4980) (type c-address arg-v-c-4981))
 (let ((v-solver-4979 0) (v-eliminated-4980 0) (v-c-4981 0) (v-other-4984 0) (v-d-4985 0))
 (declare (type c-address v-solver-4979) (type (unsigned-byte 32) v-eliminated-4980) (type c-address v-c-4981) (type (unsigned-byte 32) v-other-4984) (type c-address v-d-4985) (ignorable v-solver-4979 v-eliminated-4980 v-c-4981 v-other-4984 v-d-4985))
 (tagbody
    (setf v-solver-4979 arg-v-solver-4979)
    (setf v-eliminated-4980 arg-v-eliminated-4980)
    (setf v-c-4981 arg-v-c-4981)
    (unless (c-true (|c/is_tagged_clause| v-c-4981)) (go ELSE4982))
    (setf v-other-4984 (|c/tagged_clause_to_literal| v-c-4981))
    (progn (|c/really_delete_binary| v-solver-4979 (c-bool 0) v-eliminated-4980 v-other-4984))
    (setf v-d-4985 (|c/tag_binary_clause| (c-bool 0) v-eliminated-4980))
    (progn (|c/disconnect_literal| v-solver-4979 v-other-4984 v-d-4985))
    (progn (progn 0 (let* ((a4986 (+ (+ v-solver-4979 1016) 88)) (old4987 (m-u64 a4986))) (setf (m-u64 a4986) (c-u64 (c-u64 (+ old4987 (c-u64 1))))) (m-u64 a4986))))
    (progn (setf v-c-4981 (|c/untag_clause| v-solver-4979 (c-u32 0) v-eliminated-4980 v-c-4981)))
    (go ENDIF4983)
    ELSE4982
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-c-4981 0)))) (go ELSE4988))
    (return-from |c/eliminate_watched_clause| 0)
    ELSE4988
    (progn (|c/mark_garbage| v-solver-4979 v-c-4981 |c/string/148|))
    ENDIF4983
  )
  0))

;;; upstream/satch.c:9597:1
(defun |c/eliminate_watched_clauses| (arg-v-solver-4990 arg-v-eliminated-4991 arg-v-watches-4992)
 (declare  (type c-address arg-v-solver-4990) (type (unsigned-byte 32) arg-v-eliminated-4991) (type c-address arg-v-watches-4992))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-4990 0) (v-eliminated-4991 0) (v-watches-4992 0) (v-watch-4996 (stack-alloc 8)) (v-PTR_watch-4997 0) (v-END_watch-4998 0))
 (declare (type c-address v-solver-4990) (type (unsigned-byte 32) v-eliminated-4991) (type c-address v-watches-4992) (type c-address v-watch-4996) (type c-address v-PTR_watch-4997) (type c-address v-END_watch-4998) (ignorable v-solver-4990 v-eliminated-4991 v-watches-4992 v-watch-4996 v-PTR_watch-4997 v-END_watch-4998))
 (tagbody
    (setf v-solver-4990 arg-v-solver-4990)
    (setf v-eliminated-4991 arg-v-eliminated-4991)
    (setf v-watches-4992 arg-v-watches-4992)
    (setf v-PTR_watch-4997 (m-ptr (+ v-watches-4992 0)))
    (setf v-END_watch-4998 (m-ptr (+ v-watches-4992 8)))
    LOOP4993
    (unless (c-true (if (c-true (if (/= v-PTR_watch-4997 v-END_watch-4998) 1 0)) (c-bool (progn (copy-bytes v-watch-4996 v-PTR_watch-4997 8) 1)) 0)) (go ENDLOOP4994))
    (progn (|c/eliminate_watched_clause| v-solver-4990 v-eliminated-4991 (m-ptr (+ v-watch-4996 0))))
    (let* ( (old5000 v-PTR_watch-4997)) (setf v-PTR_watch-4997 (+ old5000 (* 8 1))) v-PTR_watch-4997)
    (go LOOP4993)
    ENDLOOP4994
    (progn (c-free (m-ptr (+ v-watches-4992 0))))
    (progn (setf (m-ptr (+ v-watches-4992 0)) (setf (m-ptr (+ v-watches-4992 8)) (setf (m-ptr (+ v-watches-4992 16)) 0))))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:9612:1
(defun |c/eliminate_variable| (arg-v-solver-5004 arg-v-pivot_idx-5005)
 (declare  (type c-address arg-v-solver-5004) (type (unsigned-byte 32) arg-v-pivot_idx-5005))
 (let ((v-solver-5004 0) (v-pivot_idx-5005 0) (v-pivot-5006 0) (v-not_pivot-5007 0) (v-f-5011 0) (v-ticks-5019 0) (v-values-5020 0) (v-satisfied-5021 0) (v-lit-5025 0) (v-PTR_lit-5026 0) (v-END_lit-5027 0) (v-value-5030 0) (v-old_size-5043 0) (v-old_capacity-5044 0) (v-new_capacity-5045 0) (v-new_bytes-5046 0) (v-pos_watches-5074 0) (v-neg_watches-5075 0) (v-pos_lines-5076 0) (v-neg_lines-5077 0))
 (declare (type c-address v-solver-5004) (type (unsigned-byte 32) v-pivot_idx-5005) (type (unsigned-byte 32) v-pivot-5006) (type (unsigned-byte 32) v-not_pivot-5007) (type c-address v-f-5011) (type (unsigned-byte 64) v-ticks-5019) (type c-address v-values-5020) (type (integer 0 1) v-satisfied-5021) (type (unsigned-byte 32) v-lit-5025) (type c-address v-PTR_lit-5026) (type c-address v-END_lit-5027) (type (signed-byte 8) v-value-5030) (type c-size v-old_size-5043) (type c-size v-old_capacity-5044) (type c-size v-new_capacity-5045) (type c-size v-new_bytes-5046) (type c-address v-pos_watches-5074) (type c-address v-neg_watches-5075) (type c-size v-pos_lines-5076) (type c-size v-neg_lines-5077) (ignorable v-solver-5004 v-pivot_idx-5005 v-pivot-5006 v-not_pivot-5007 v-f-5011 v-ticks-5019 v-values-5020 v-satisfied-5021 v-lit-5025 v-PTR_lit-5026 v-END_lit-5027 v-value-5030 v-old_size-5043 v-old_capacity-5044 v-new_capacity-5045 v-new_bytes-5046 v-pos_watches-5074 v-neg_watches-5075 v-pos_lines-5076 v-neg_lines-5077))
 (tagbody
    (setf v-solver-5004 arg-v-solver-5004)
    (setf v-pivot_idx-5005 arg-v-pivot_idx-5005)
    (setf v-pivot-5006 (|c/LITERAL| v-pivot_idx-5005))
    (setf v-not_pivot-5007 (|c/NOT| v-pivot-5006))
    (progn v-solver-5004)
    (setf v-f-5011 (+ (m-ptr (+ v-solver-5004 48)) (* 4 v-pivot_idx-5005)))
    (progn (set-bits (+ v-f-5011 0) 2 1 (c-bool 1)))
    (progn (set-bits (+ v-f-5011 0) 0 1 (c-bool 0)))
    (progn (let* ((a5015 (+ (+ v-solver-5004 1016) 216)) (old5016 (m-u64 a5015))) (setf (m-u64 a5015) (c-u64 (c-u64 (- old5016 (c-u64 1))))) old5016))
    (progn (progn 0 (let* ((a5017 (+ (+ v-solver-5004 1016) 80)) (old5018 (m-u64 a5017))) (setf (m-u64 a5017) (c-u64 (c-u64 (+ old5018 (c-u64 1))))) (m-u64 a5017))))
    (locally (declare (optimize (speed 1))) (setf v-ticks-5019 (c-u64 0)))
    (setf v-values-5020 (m-ptr (+ v-solver-5004 40)))
    (setf v-satisfied-5021 (c-bool 0))
    (setf v-PTR_lit-5026 (m-ptr (+ (+ v-solver-5004 520) 0)))
    (setf v-END_lit-5027 (m-ptr (+ (+ v-solver-5004 520) 8)))
    LOOP5022
    (unless (c-true (if (c-true (if (/= v-PTR_lit-5026 v-END_lit-5027) 1 0)) (c-bool (progn (setf v-lit-5025 (m-u32 v-PTR_lit-5026)) 1)) 0)) (go ENDLOOP5023))
    (unless (c-true (if (/= v-lit-5025 4294967295) 1 0)) (go ELSE5028))
    (setf v-value-5030 (m-s8 (+ v-values-5020 (* 1 v-lit-5025))))
    (unless (c-true (if (> v-value-5030 0) 1 0)) (go ELSE5031))
    (progn (setf v-satisfied-5021 (c-bool 1)))
    (go ENDIF5032)
    ELSE5031
    (unless (c-true (if (c-true (if (c-true v-satisfied-5021) 0 1)) (c-bool (if (c-true v-value-5030) 0 1)) 0)) (go ELSE5033))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-5004 624) 8)) (m-ptr (+ (+ v-solver-5004 624) 16))) 1 0)) (go ELSE5038))
    (setf v-old_size-5043 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5004 624) 8)) (m-ptr (+ (+ v-solver-5004 624) 0))) 4)))
    (setf v-old_capacity-5044 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5004 624) 16)) (m-ptr (+ (+ v-solver-5004 624) 0))) 4)))
    (setf v-new_capacity-5045 (if (c-true v-old_capacity-5044) (c-u64 (* (c-u64 2) v-old_capacity-5044)) (c-u64 1)))
    (setf v-new_bytes-5046 (c-u64 (* v-new_capacity-5045 4)))
    (progn (setf (m-ptr (+ (+ v-solver-5004 624) 0)) (c-realloc (m-ptr (+ (+ v-solver-5004 624) 0)) v-new_bytes-5046)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-5004 624) 0))) 0 1)) (go ELSE5047))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-5046))
    (go ENDIF5048)
    ELSE5047
    ENDIF5048
    (progn (setf (m-ptr (+ (+ v-solver-5004 624) 8)) (+ (m-ptr (+ (+ v-solver-5004 624) 0)) (* 4 v-old_size-5043))))
    (progn (setf (m-ptr (+ (+ v-solver-5004 624) 16)) (+ (m-ptr (+ (+ v-solver-5004 624) 0)) (* 4 v-new_capacity-5045))))
    (go ENDIF5039)
    ELSE5038
    ENDIF5039
    (progn (setf (m-u32 (let* ((a5049 (+ (+ v-solver-5004 624) 8)) (old5050 (m-ptr a5049))) (setf (m-ptr a5049) (+ old5050 (* 4 1))) old5050)) v-lit-5025))
    (go ENDIF5034)
    ELSE5033
    ENDIF5034
    ENDIF5032
    (go ENDIF5029)
    ELSE5028
    (unless (c-true v-satisfied-5021) (go ELSE5051))
    (progn (setf (m-ptr (+ (+ v-solver-5004 624) 8)) (m-ptr (+ (+ v-solver-5004 624) 0))))
    (progn (setf v-satisfied-5021 (c-bool 0)))
    (go ENDIF5052)
    ELSE5051
    (progn v-solver-5004)
    (progn (|c/trace_and_check_temporary_addition| v-solver-5004))
    (progn (|c/add_and_connect_resolvent| v-solver-5004))
    (progn (setf v-ticks-5019 (c-u64 (c-u64 (+ v-ticks-5019 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5004 624) 8)) (m-ptr (+ (+ v-solver-5004 624) 0))) 4)))))))
    (progn (setf (m-ptr (+ (+ v-solver-5004 624) 8)) (m-ptr (+ (+ v-solver-5004 624) 0))))
    (progn (let* ( (old5064 v-ticks-5019)) (setf v-ticks-5019 (c-u64 (c-u64 (+ old5064 (c-u64 1))))) old5064))
    (unless (c-true (m-u8 (+ v-solver-5004 4))) (go ELSE5065))
    (go ENDLOOP5023)
    ELSE5065
    ENDIF5052
    ENDIF5029
    (let* ( (old5068 v-PTR_lit-5026)) (setf v-PTR_lit-5026 (+ old5068 (* 4 1))) v-PTR_lit-5026)
    (go LOOP5022)
    ENDLOOP5023
    (unless (c-true (m-u8 (+ v-solver-5004 4))) (go ELSE5069))
    (return-from |c/eliminate_variable| 0)
    ELSE5069
    (progn (setf (m-ptr (+ (+ v-solver-5004 520) 8)) (m-ptr (+ (+ v-solver-5004 520) 0))))
    (setf v-pos_watches-5074 (+ (m-ptr (+ v-solver-5004 544)) (* 24 v-pivot-5006)))
    (setf v-neg_watches-5075 (+ (m-ptr (+ v-solver-5004 544)) (* 24 v-not_pivot-5007)))
    (setf v-pos_lines-5076 (c-u64 (+ (c-u64 1) (|c/cache_lines| (m-ptr (+ v-pos_watches-5074 0)) (m-ptr (+ v-pos_watches-5074 8))))))
    (setf v-neg_lines-5077 (c-u64 (+ (c-u64 1) (|c/cache_lines| (m-ptr (+ v-neg_watches-5075 0)) (m-ptr (+ v-neg_watches-5075 8))))))
    (unless (c-true (if (< (the c-size (truncate (- (m-ptr (+ v-pos_watches-5074 8)) (m-ptr (+ v-pos_watches-5074 0))) 8)) (the c-size (truncate (- (m-ptr (+ v-neg_watches-5075 8)) (m-ptr (+ v-neg_watches-5075 0))) 8))) 1 0)) (go ELSE5078))
    (progn (setf v-ticks-5019 (c-u64 (c-u64 (+ v-ticks-5019 (c-u64 (+ (c-u64 1) v-pos_lines-5076)))))))
    (progn (|c/push_clauses_on_extension_stack| v-solver-5004 v-pivot-5006 v-pos_watches-5074))
    (progn (|c/push_unit_on_extension_stack| v-solver-5004 v-not_pivot-5007))
    (go ENDIF5079)
    ELSE5078
    (progn (setf v-ticks-5019 (c-u64 (c-u64 (+ v-ticks-5019 (c-u64 (+ (c-u64 1) v-neg_lines-5077)))))))
    (progn (|c/push_clauses_on_extension_stack| v-solver-5004 v-not_pivot-5007 v-neg_watches-5075))
    (progn (|c/push_unit_on_extension_stack| v-solver-5004 v-pivot-5006))
    ENDIF5079
    (progn (setf v-ticks-5019 (c-u64 (c-u64 (+ v-ticks-5019 (c-u64 (+ (c-u64 (+ (c-u64 2) v-pos_lines-5076)) v-neg_lines-5077)))))))
    (progn (|c/eliminate_watched_clauses| v-solver-5004 v-pivot-5006 v-pos_watches-5074))
    (progn (|c/eliminate_watched_clauses| v-solver-5004 v-not_pivot-5007 v-neg_watches-5075))
    (progn (let ((a5086 (+ (+ v-solver-5004 1016) 88))) (setf (m-u64 a5086) (c-u64 (c-u64 (+ (m-u64 a5086) v-ticks-5019))))))
  )
  0))

;;; upstream/satch.c:9733:1
(defun |c/set_elimination_ticks_limit| (arg-v-solver-5087)
 (declare  (type c-address arg-v-solver-5087))
 (let ((v-solver-5087 0) (v-limits-5088 0) (v-statistics-5089 0) (v-eliminations-5090 0) (v-delta-5091 0) (v-limit-5092 0))
 (declare (type c-address v-solver-5087) (type c-address v-limits-5088) (type c-address v-statistics-5089) (type (unsigned-byte 64) v-eliminations-5090) (type (unsigned-byte 64) v-delta-5091) (type (unsigned-byte 64) v-limit-5092) (ignorable v-solver-5087 v-limits-5088 v-statistics-5089 v-eliminations-5090 v-delta-5091 v-limit-5092))
 (tagbody
    (setf v-solver-5087 arg-v-solver-5087)
    (setf v-limits-5088 (+ v-solver-5087 720))
    (setf v-statistics-5089 (+ v-solver-5087 1016))
    (locally (declare (optimize (speed 1))) (setf v-eliminations-5090 (m-u64 (+ v-statistics-5089 96))))
    (locally (declare (optimize (speed 1))) (setf v-delta-5091 (c-u64 (- (m-u64 (+ v-statistics-5089 360)) (m-u64 (+ (+ v-limits-5088 0) 32))))))
    (locally (declare (optimize (speed 1))) (setf v-limit-5092 (values (the (unsigned-byte 64) (truncate (float (* (integer64-double v-delta-5091 nil) 0.2d0) 1d0))))))
    (progn (when (>= (m-u32 (+ v-solver-5087 884)) (c-u32 2)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-5087 (c-u32 2) |c/string/149| v-eliminations-5090 |c/string/162| v-limit-5092 0.2d0 v-delta-5091))))
    (progn (setf (m-u64 (+ (+ v-limits-5088 0) 24)) (c-u64 (+ (m-u64 (+ v-statistics-5089 88)) v-limit-5092))))
  )
  0))

