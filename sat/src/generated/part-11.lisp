(in-package #:ooparts/sat/impl)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))
;;; upstream/satch.c:9754:1
(defun |c/elimination_ticks_limit_hit| (arg-v-solver-5093)
 (declare  (type c-address arg-v-solver-5093))
 (let ((v-solver-5093 0))
 (declare (type c-address v-solver-5093) (ignorable v-solver-5093))
 (tagbody
    (setf v-solver-5093 arg-v-solver-5093)
    (return-from |c/elimination_ticks_limit_hit| (c-bool (if (> (m-u64 (+ (+ v-solver-5093 1016) 88)) (m-u64 (+ (+ (+ v-solver-5093 720) 0) 24))) 1 0)))
  )
  0))

;;; upstream/satch.c:9765:1
(defun |c/set_subsumption_ticks_limit| (arg-v-solver-5094)
 (declare  (type c-address arg-v-solver-5094))
 (let ((v-solver-5094 0) (v-limits-5095 0) (v-statistics-5096 0) (v-eliminations-5097 0) (v-delta-5098 0) (v-limit-5099 0))
 (declare (type c-address v-solver-5094) (type c-address v-limits-5095) (type c-address v-statistics-5096) (type (unsigned-byte 64) v-eliminations-5097) (type (unsigned-byte 64) v-delta-5098) (type (unsigned-byte 64) v-limit-5099) (ignorable v-solver-5094 v-limits-5095 v-statistics-5096 v-eliminations-5097 v-delta-5098 v-limit-5099))
 (tagbody
    (setf v-solver-5094 arg-v-solver-5094)
    (setf v-limits-5095 (+ v-solver-5094 720))
    (setf v-statistics-5096 (+ v-solver-5094 1016))
    (locally (declare (optimize (speed 1))) (setf v-eliminations-5097 (m-u64 (+ v-statistics-5096 96))))
    (locally (declare (optimize (speed 1))) (setf v-delta-5098 (c-u64 (- (m-u64 (+ v-statistics-5096 360)) (m-u64 (+ (+ v-limits-5095 120) 16))))))
    (locally (declare (optimize (speed 1))) (setf v-limit-5099 (values (the (unsigned-byte 64) (truncate (float (* (integer64-double v-delta-5098 nil) 0.1d0) 1d0))))))
    (progn (when (>= (m-u32 (+ v-solver-5094 884)) (c-u32 2)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-5094 (c-u32 2) |c/string/149| v-eliminations-5097 |c/string/163| v-limit-5099 0.1d0 v-delta-5098))))
    (progn (setf (m-u64 (+ (+ v-limits-5095 120) 8)) (c-u64 (+ (m-u64 (+ v-statistics-5096 304)) v-limit-5099))))
  )
  0))

;;; upstream/satch.c:9792:1
(defun |c/eliminate_variables| (arg-v-solver-5100)
 (declare  (type c-address arg-v-solver-5100))
 (let ((v-solver-5100 0) (v-eliminations-5101 0) (v-eliminated-5104 0) (v-total-5105 0) (v-round-5106 0) (v-original-5107 0) (v-remaining-5113 0) (v-idx-5119 0) (v-END_VARIABLES-5120 0) (v-kept-5136 0) (v-flags-5137 0) (v-idx-5141 0) (v-END_VARIABLES-5142 0) (v-f-5143 0) (v-statistics-5152 0) (v-limits-5153 0) (v-interval-5156 0))
 (declare (type c-address v-solver-5100) (type (unsigned-byte 64) v-eliminations-5101) (type (unsigned-byte 32) v-eliminated-5104) (type (unsigned-byte 32) v-total-5105) (type (unsigned-byte 32) v-round-5106) (type (unsigned-byte 32) v-original-5107) (type (unsigned-byte 32) v-remaining-5113) (type (unsigned-byte 32) v-idx-5119) (type (unsigned-byte 32) v-END_VARIABLES-5120) (type (unsigned-byte 32) v-kept-5136) (type c-address v-flags-5137) (type (unsigned-byte 32) v-idx-5141) (type (unsigned-byte 32) v-END_VARIABLES-5142) (type c-address v-f-5143) (type c-address v-statistics-5152) (type c-address v-limits-5153) (type (unsigned-byte 64) v-interval-5156) (ignorable v-solver-5100 v-eliminations-5101 v-eliminated-5104 v-total-5105 v-round-5106 v-original-5107 v-remaining-5113 v-idx-5119 v-END_VARIABLES-5120 v-kept-5136 v-flags-5137 v-idx-5141 v-END_VARIABLES-5142 v-f-5143 v-statistics-5152 v-limits-5153 v-interval-5156))
 (tagbody
    (setf v-solver-5100 arg-v-solver-5100)
    (progn (|c/start_profiling| v-solver-5100 (+ (+ v-solver-5100 1472) 24)))
    (locally (declare (optimize (speed 1))) (setf v-eliminations-5101 (progn 0 (let* ((a5102 (+ (+ v-solver-5100 1016) 96)) (old5103 (m-u64 a5102))) (setf (m-u64 a5102) (c-u64 (c-u64 (+ old5103 (c-u64 1))))) (m-u64 a5102)))))
    (progn (|c/update_phases_and_backtrack_to_root_level| v-solver-5100))
    (progn (|c/set_elimination_ticks_limit| v-solver-5100))
    (progn (|c/set_subsumption_ticks_limit| v-solver-5100))
    (progn (|c/switch_to_dense_mode| v-solver-5100))
    (setf v-total-5105 (c-u32 0))
    (setf v-round-5106 (c-u32 0))
    (setf v-original-5107 (c-u32 (m-u64 (+ (+ v-solver-5100 1016) 216))))
    LOOP5108
    (progn (|c/full_backward_subsumption| v-solver-5100))
    (unless (c-true (if (c-true (|c/more_elimination_candidates| v-solver-5100)) 0 1)) (go ELSE5111))
    (go ENDLOOP5109)
    ELSE5111
    (setf v-remaining-5113 (c-u32 (m-u64 (+ (+ v-solver-5100 1016) 216))))
    (progn (setf v-eliminated-5104 (c-u32 0)))
    (progn (let* ( (old5115 v-round-5106)) (setf v-round-5106 (c-u32 (c-u32 (+ old5115 (c-u32 1))))) old5115))
    (setf v-idx-5119 (c-u32 0))
    (setf v-END_VARIABLES-5120 (m-u32 (+ v-solver-5100 12)))
    LOOP5116
    (unless (c-true (if (< v-idx-5119 v-END_VARIABLES-5120) 1 0)) (go ENDLOOP5117))
    (unless (c-true (if (c-true (|c/can_be_eliminated| v-solver-5100 v-idx-5119)) (c-bool (|c/produces_few_resolvents| v-solver-5100 v-idx-5119)) 0)) (go ELSE5121))
    (progn (|c/eliminate_variable| v-solver-5100 v-idx-5119))
    (progn (let* ( (old5124 v-eliminated-5104)) (setf v-eliminated-5104 (c-u32 (c-u32 (+ old5124 (c-u32 1))))) old5124))
    (go ENDIF5122)
    ELSE5121
    (progn (set-bits (+ (+ (m-ptr (+ v-solver-5100 48)) (* 4 v-idx-5119)) 0) 1 1 (c-bool 0)))
    ENDIF5122
    (unless (c-true (m-u8 (+ v-solver-5100 4))) (go ELSE5125))
    (go ENDLOOP5117)
    ELSE5125
    (unless (c-true (|c/elimination_ticks_limit_hit| v-solver-5100)) (go ELSE5127))
    (progn (when (>= (m-u32 (+ v-solver-5100 884)) (c-u32 4)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-5100 (c-u32 4) |c/string/149| v-eliminations-5101 |c/string/164|))))
    (go ENDLOOP5117)
    ELSE5127
    (let* ( (old5130 v-idx-5119)) (setf v-idx-5119 (c-u32 (c-u32 (+ old5130 (c-u32 1))))) old5130)
    (go LOOP5116)
    ENDLOOP5117
    (progn (setf v-total-5105 (c-u32 (c-u32 (+ v-total-5105 v-eliminated-5104)))))
    (progn (when (>= (m-u32 (+ v-solver-5100 884)) (c-u32 3)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-5100 (c-u32 3) |c/string/149| v-eliminations-5101 |c/string/165| v-eliminated-5104 (|c/percent| (float v-eliminated-5104 1d0) (float v-remaining-5113 1d0)) v-remaining-5113 v-round-5106))))
    (progn (|c/report| v-solver-5100 (c-u32 (c-s32 (+ 1 (if (c-true v-eliminated-5104) 0 1)))) 101))
    (unless (c-true (if (>= v-round-5106 (c-u32 2)) 1 0)) (go ELSE5132))
    (go ENDLOOP5109)
    ELSE5132
    (unless (c-true (|c/elimination_ticks_limit_hit| v-solver-5100)) (go ELSE5134))
    (go ENDLOOP5109)
    ELSE5134
    (when (c-true (if (c-true (if (c-true (m-u8 (+ v-solver-5100 4))) 0 1)) (c-bool v-eliminated-5104) 0)) (go LOOP5108))
    ENDLOOP5109
    (setf v-kept-5136 (c-u32 0))
    (setf v-flags-5137 (m-ptr (+ v-solver-5100 48)))
    (setf v-idx-5141 (c-u32 0))
    (setf v-END_VARIABLES-5142 (m-u32 (+ v-solver-5100 12)))
    LOOP5138
    (unless (c-true (if (< v-idx-5141 v-END_VARIABLES-5142) 1 0)) (go ENDLOOP5139))
    (setf v-f-5143 (+ v-flags-5137 (* 4 v-idx-5141)))
    (unless (c-true (if (c-true (ldb (byte 1 0) (m-u8 (+ v-f-5143 0)))) 0 1)) (go ELSE5144))
    (go CONTINUE5140)
    ELSE5144
    (unless (c-true (ldb (byte 1 1) (m-u8 (+ v-f-5143 0)))) (go ELSE5146))
    (progn (let* ( (old5149 v-kept-5136)) (setf v-kept-5136 (c-u32 (c-u32 (+ old5149 (c-u32 1))))) old5149))
    (go ENDIF5147)
    ELSE5146
    ENDIF5147
    CONTINUE5140
    (let* ( (old5151 v-idx-5141)) (setf v-idx-5141 (c-u32 (c-u32 (+ old5151 (c-u32 1))))) old5151)
    (go LOOP5138)
    ENDLOOP5139
    (progn (when (>= (m-u32 (+ v-solver-5100 884)) (c-u32 3)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-5100 (c-u32 3) |c/string/149| v-eliminations-5101 |c/string/160| v-kept-5136 (|c/percent| (float v-kept-5136 1d0) (integer64-double (m-u64 (+ (+ v-solver-5100 1016) 216)) nil))))))
    (progn (when (>= (m-u32 (+ v-solver-5100 884)) (c-u32 2)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-5100 (c-u32 2) |c/string/149| v-eliminations-5101 |c/string/166| v-total-5105 (|c/percent| (float v-total-5105 1d0) (float v-original-5107 1d0)) v-round-5106))))
    (progn (|c/mark_and_collect_garbage_clauses_after_elimination| v-solver-5100))
    (progn (|c/switch_to_sparse_mode| v-solver-5100))
    (progn (setf (m-ptr (+ (+ v-solver-5100 552) 16)) (m-ptr (+ (+ v-solver-5100 552) 0))))
    (setf v-statistics-5152 (+ v-solver-5100 1016))
    (setf v-limits-5153 (+ v-solver-5100 720))
    (unless (c-true (if (c-true v-kept-5136) 0 1)) (go ELSE5154))
    (progn (setf (m-u64 (+ (+ v-limits-5153 0) 8)) (m-u64 (+ v-statistics-5152 104))))
    (progn (setf (m-u64 (+ (+ v-limits-5153 0) 16)) (m-u64 (+ v-statistics-5152 136))))
    (go ENDIF5155)
    ELSE5154
    ENDIF5155
    (progn (setf (m-u64 (+ (+ v-limits-5153 0) 32)) (m-u64 (+ v-statistics-5152 360))))
    (progn (setf (m-u64 (+ (+ v-limits-5153 120) 16)) (m-u64 (+ v-statistics-5152 360))))
    (locally (declare (optimize (speed 1))) (setf v-interval-5156 (values (the (unsigned-byte 64) (truncate (|c/scale_interval| (c-u64 500) (function-handle #'|c/nlognlogn|) v-eliminations-5101))))))
    (progn (setf (m-u64 (+ (+ v-limits-5153 0) 0)) (c-u64 (+ (m-u64 (+ (+ v-solver-5100 1016) 48)) v-interval-5156))))
    (progn (when (>= (m-u32 (+ v-solver-5100 884)) (c-u32 4)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-5100 (c-u32 4) |c/string/149| v-eliminations-5101 |c/string/143| (m-u64 (+ (+ v-limits-5153 0) 0)) v-interval-5156))))
    (progn (|c/stop_profiling| v-solver-5100 (+ (+ v-solver-5100 1472) 24) (|c/process_time|)))
    (return-from |c/eliminate_variables| (if (c-true (m-u8 (+ v-solver-5100 4))) 20 0))
  )
  0))

;;; upstream/satch.c:9938:1
(defun |c/extend_solution| (arg-v-solver-5157)
 (declare  (type c-address arg-v-solver-5157))
 (let ((v-solver-5157 0) (v-begin-5158 0) (v-values-5159 0) (v-p-5160 0) (v-last-5161 0) (v-satisfied-5162 0) (v-value-5163 0) (v-lit-5167 0))
 (declare (type c-address v-solver-5157) (type c-address v-begin-5158) (type c-address v-values-5159) (type c-address v-p-5160) (type (unsigned-byte 32) v-last-5161) (type (integer 0 1) v-satisfied-5162) (type (signed-byte 8) v-value-5163) (type (unsigned-byte 32) v-lit-5167) (ignorable v-solver-5157 v-begin-5158 v-values-5159 v-p-5160 v-last-5161 v-satisfied-5162 v-value-5163 v-lit-5167))
 (tagbody
    (setf v-solver-5157 arg-v-solver-5157)
    (setf v-begin-5158 (m-ptr (+ (+ v-solver-5157 496) 0)))
    (setf v-values-5159 (m-ptr (+ v-solver-5157 40)))
    (setf v-p-5160 (m-ptr (+ (+ v-solver-5157 496) 8)))
    (setf v-last-5161 4294967295)
    (setf v-satisfied-5162 (c-bool 0))
    (setf v-value-5163 (c-s8 (c-s32 (- 1))))
    LOOP5164
    (unless (c-true (if (/= v-p-5160 v-begin-5158) 1 0)) (go ENDLOOP5165))
    (setf v-lit-5167 (m-u32 (let* ( (old5169 v-p-5160)) (setf v-p-5160 (- old5169 (* 4 1))) v-p-5160)))
    (unless (c-true (if (/= v-lit-5167 4294967295) 1 0)) (go ELSE5170))
    (progn (setf v-value-5163 (m-s8 (+ v-values-5159 (* 1 v-lit-5167)))))
    (unless (c-true (if (> v-value-5163 0) 1 0)) (go ELSE5172))
    (progn (setf v-satisfied-5162 (c-bool 1)))
    (go ENDIF5173)
    ELSE5172
    ENDIF5173
    (go ENDIF5171)
    ELSE5170
    (unless (c-true (if (c-true v-satisfied-5162) 0 1)) (go ELSE5174))
    (progn (setf (m-s8 (+ v-values-5159 (* 1 v-last-5161))) (c-s8 1)))
    (progn (setf (m-s8 (+ v-values-5159 (* 1 (|c/NOT| v-last-5161)))) (c-s8 (c-s32 (- 1)))))
    (progn v-solver-5157)
    (go ENDIF5175)
    ELSE5174
    (progn (setf v-satisfied-5162 (c-bool 0)))
    ENDIF5175
    ENDIF5171
    (progn (setf v-last-5161 v-lit-5167))
    (go LOOP5164)
    ENDLOOP5165
  )
  0))

;;; upstream/satch.c:9979:1
(defun |c/satch_fixed| (arg-v-solver-5179 arg-v-lit-5180)
 (declare  (type c-address arg-v-solver-5179) (type (unsigned-byte 32) arg-v-lit-5180))
 (let ((v-solver-5179 0) (v-lit-5180 0) (v-value-5181 0))
 (declare (type c-address v-solver-5179) (type (unsigned-byte 32) v-lit-5180) (type (signed-byte 8) v-value-5181) (ignorable v-solver-5179 v-lit-5180 v-value-5181))
 (tagbody
    (setf v-solver-5179 arg-v-solver-5179)
    (setf v-lit-5180 arg-v-lit-5180)
    (setf v-value-5181 (m-s8 (+ (m-ptr (+ v-solver-5179 40)) (* 1 v-lit-5180))))
    (unless (c-true (if (c-true v-value-5181) 0 1)) (go ELSE5182))
    (return-from |c/satch_fixed| (c-s8 0))
    ELSE5182
    (unless (c-true (m-u32 (+ (m-ptr (+ v-solver-5179 32)) (* 4 (|c/INDEX| v-lit-5180))))) (go ELSE5184))
    (return-from |c/satch_fixed| (c-s8 0))
    ELSE5184
    (return-from |c/satch_fixed| v-value-5181)
  )
  0))

;;; upstream/satch.c:9992:1
(defun |c/int_compare| (arg-v-a-5186 arg-v-b-5187)
 (declare  (type (signed-byte 64) arg-v-a-5186) (type (signed-byte 64) arg-v-b-5187))
 (let ((v-a-5186 0) (v-b-5187 0))
 (declare (type (signed-byte 64) v-a-5186) (type (signed-byte 64) v-b-5187) (ignorable v-a-5186 v-b-5187))
 (tagbody
    (setf v-a-5186 arg-v-a-5186)
    (setf v-b-5187 arg-v-b-5187)
    (unless (c-true (if (< v-a-5186 v-b-5187) 1 0)) (go ELSE5188))
    (return-from |c/int_compare| (c-s32 (- 1)))
    ELSE5188
    (unless (c-true (if (= v-a-5186 v-b-5187) 1 0)) (go ELSE5190))
    (return-from |c/int_compare| 0)
    ELSE5190
    (return-from |c/int_compare| 1)
  )
  0))

;;; upstream/satch.c:10015:1
(defun |c/vivify_sort_lits_by_counts| (arg-v-solver-5192 arg-v-counts-5193 arg-v-c-5194)
 (declare (optimize (speed 1) (compilation-speed 3)) (notinline checked-address) (type c-address arg-v-solver-5192) (type c-address arg-v-counts-5193) (type c-address arg-v-c-5194))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-5192 0) (v-counts-5193 0) (v-c-5194 0) (v-N_RANK-5198 0) (v-V_RANK-5201 0) (v-LENGTH_RANK-5202 0) (v-WIDTH_RANK-5203 0) (v-MASK_RANK-5204 0) (v-COUNT_RANK-5205 (stack-alloc 2048)) (v-TMP_RANK-5206 0) (v-BYTES_TMP_RANK-5207 0) (v-A_RANK-5208 0) (v-B_RANK-5209 0) (v-C_RANK-5210 0) (v-MLOWER_RANK-5211 0) (v-MUPPER_RANK-5212 0) (v-BOUNDED_RANK-5213 0) (v-UPPER_RANK-5214 0) (v-LOWER_RANK-5215 0) (v-SHIFT_RANK-5216 0) (v-I_RANK-5220 0) (v-END_RANK-5223 0) (v-SORTED_RANK-5224 0) (v-LAST_RANK-5225 0) (v-P_RANK-5229 0) (v-R_RANK-5230 0) (v-S_RANK-5235 0) (v-M_RANK-5236 0) (v-POS_RANK-5249 0) (v-J_RANK-5253 0) (v-DELTA_RANK-5254 0) (v-D_RANK-5262 0) (v-P_RANK-5266 0) (v-R_RANK-5267 0) (v-S_RANK-5268 0) (v-M_RANK-5269 0) (v-POS_RANK-5270 0))
 (declare (type c-address v-solver-5192) (type c-address v-counts-5193) (type c-address v-c-5194) (type c-size v-N_RANK-5198) (type c-address v-V_RANK-5201) (type c-size v-LENGTH_RANK-5202) (type c-size v-WIDTH_RANK-5203) (type (unsigned-byte 32) v-MASK_RANK-5204) (type c-address v-COUNT_RANK-5205) (type c-address v-TMP_RANK-5206) (type c-size v-BYTES_TMP_RANK-5207) (type c-address v-A_RANK-5208) (type c-address v-B_RANK-5209) (type c-address v-C_RANK-5210) (type (unsigned-byte 32) v-MLOWER_RANK-5211) (type (unsigned-byte 32) v-MUPPER_RANK-5212) (type (integer 0 1) v-BOUNDED_RANK-5213) (type (unsigned-byte 32) v-UPPER_RANK-5214) (type (unsigned-byte 32) v-LOWER_RANK-5215) (type (unsigned-byte 32) v-SHIFT_RANK-5216) (type c-size v-I_RANK-5220) (type c-address v-END_RANK-5223) (type (integer 0 1) v-SORTED_RANK-5224) (type (unsigned-byte 32) v-LAST_RANK-5225) (type c-address v-P_RANK-5229) (type (unsigned-byte 32) v-R_RANK-5230) (type (unsigned-byte 32) v-S_RANK-5235) (type (unsigned-byte 32) v-M_RANK-5236) (type c-size v-POS_RANK-5249) (type c-size v-J_RANK-5253) (type c-size v-DELTA_RANK-5254) (type c-address v-D_RANK-5262) (type c-address v-P_RANK-5266) (type (unsigned-byte 32) v-R_RANK-5267) (type (unsigned-byte 32) v-S_RANK-5268) (type (unsigned-byte 32) v-M_RANK-5269) (type c-size v-POS_RANK-5270) (ignorable v-solver-5192 v-counts-5193 v-c-5194 v-N_RANK-5198 v-V_RANK-5201 v-LENGTH_RANK-5202 v-WIDTH_RANK-5203 v-MASK_RANK-5204 v-COUNT_RANK-5205 v-TMP_RANK-5206 v-BYTES_TMP_RANK-5207 v-A_RANK-5208 v-B_RANK-5209 v-C_RANK-5210 v-MLOWER_RANK-5211 v-MUPPER_RANK-5212 v-BOUNDED_RANK-5213 v-UPPER_RANK-5214 v-LOWER_RANK-5215 v-SHIFT_RANK-5216 v-I_RANK-5220 v-END_RANK-5223 v-SORTED_RANK-5224 v-LAST_RANK-5225 v-P_RANK-5229 v-R_RANK-5230 v-S_RANK-5235 v-M_RANK-5236 v-POS_RANK-5249 v-J_RANK-5253 v-DELTA_RANK-5254 v-D_RANK-5262 v-P_RANK-5266 v-R_RANK-5267 v-S_RANK-5268 v-M_RANK-5269 v-POS_RANK-5270))
 (tagbody
    (setf v-solver-5192 arg-v-solver-5192)
    (setf v-counts-5193 arg-v-counts-5193)
    (setf v-c-5194 arg-v-c-5194)
    (progn v-solver-5192)
    (setf v-N_RANK-5198 (the c-size (truncate (- (m-ptr (+ v-c-5194 8)) (m-ptr (+ v-c-5194 0))) 4)))
    (unless (c-true (if (<= v-N_RANK-5198 (c-u64 1)) 1 0)) (go ELSE5199))
    (go ENDLOOP5196)
    ELSE5199
    (setf v-V_RANK-5201 (m-ptr (+ v-c-5194 0)))
    (setf v-LENGTH_RANK-5202 (c-u64 8))
    (setf v-WIDTH_RANK-5203 (c-u64 (c-s32 (ash (c-s32 1) v-LENGTH_RANK-5202))))
    (setf v-MASK_RANK-5204 (c-u32 (c-u64 (- v-WIDTH_RANK-5203 (c-u64 1)))))
    (setf v-TMP_RANK-5206 0)
    (setf v-BYTES_TMP_RANK-5207 (c-u64 (* v-N_RANK-5198 4)))
    (setf v-A_RANK-5208 v-V_RANK-5201)
    (setf v-B_RANK-5209 0)
    (setf v-C_RANK-5210 v-A_RANK-5208)
    (setf v-MLOWER_RANK-5211 (c-u32 0))
    (setf v-MUPPER_RANK-5212 v-MASK_RANK-5204)
    (setf v-BOUNDED_RANK-5213 (c-bool 0))
    (setf v-UPPER_RANK-5214 (c-u32 0))
    (setf v-LOWER_RANK-5215 (c-u32 (lognot v-UPPER_RANK-5214)))
    (setf v-SHIFT_RANK-5216 v-MASK_RANK-5204)
    (setf v-I_RANK-5220 (c-u64 0))
    LOOP5217
    (unless (c-true (if (< v-I_RANK-5220 (c-u64 (* (c-u64 8) 4))) 1 0)) (go ENDLOOP5218))
    (unless (c-true (if (c-true v-BOUNDED_RANK-5213) (c-bool (if (= (c-u32 (logand v-LOWER_RANK-5215 v-SHIFT_RANK-5216)) (c-u32 (logand v-UPPER_RANK-5214 v-SHIFT_RANK-5216))) 1 0)) 0)) (go ELSE5221))
    (go CONTINUE5219)
    ELSE5221
    (progn (c-memset (+ v-COUNT_RANK-5205 (* 8 v-MLOWER_RANK-5211)) 0 (c-u64 (* (c-u32 (+ (c-u32 (- v-MUPPER_RANK-5212 v-MLOWER_RANK-5211)) (c-u32 1))) 8))))
    (setf v-END_RANK-5223 (+ v-C_RANK-5210 (* 4 v-N_RANK-5198)))
    (setf v-SORTED_RANK-5224 (c-bool 1))
    (setf v-LAST_RANK-5225 (c-u32 0))
    (setf v-P_RANK-5229 v-C_RANK-5210)
    LOOP5226
    (unless (c-true (if (/= v-P_RANK-5229 v-END_RANK-5223) 1 0)) (go ENDLOOP5227))
    (setf v-R_RANK-5230 (c-u32 (lognot (m-u32 (+ v-counts-5193 (* 4 (m-u32 v-P_RANK-5229)))))))
    (unless (c-true (if (c-true v-BOUNDED_RANK-5213) 0 1)) (go ELSE5231))
    (progn (setf v-LOWER_RANK-5215 (c-u32 (c-u32 (logand v-LOWER_RANK-5215 v-R_RANK-5230)))))
    (progn (setf v-UPPER_RANK-5214 (c-u32 (c-u32 (logior v-UPPER_RANK-5214 v-R_RANK-5230)))))
    (go ENDIF5232)
    ELSE5231
    ENDIF5232
    (setf v-S_RANK-5235 (c-u32 (ash (c-u32 v-R_RANK-5230) (- v-I_RANK-5220))))
    (setf v-M_RANK-5236 (c-u32 (logand v-S_RANK-5235 v-MASK_RANK-5204)))
    (unless (c-true (if (c-true v-SORTED_RANK-5224) (c-bool (if (> v-LAST_RANK-5225 v-M_RANK-5236) 1 0)) 0)) (go ELSE5237))
    (progn (setf v-SORTED_RANK-5224 (c-bool 0)))
    (go ENDIF5238)
    ELSE5237
    (progn (setf v-LAST_RANK-5225 v-M_RANK-5236))
    ENDIF5238
    (progn (let* ((a5239 (+ v-COUNT_RANK-5205 (* 8 v-M_RANK-5236))) (old5240 (m-size a5239))) (setf (m-size a5239) (c-u64 (c-u64 (+ old5240 (c-u64 1))))) old5240))
    (let* ( (old5242 v-P_RANK-5229)) (setf v-P_RANK-5229 (+ old5242 (* 4 1))) old5242)
    (go LOOP5226)
    ENDLOOP5227
    (progn (setf v-MLOWER_RANK-5211 (c-u32 (logand (c-u32 (ash (c-u32 v-LOWER_RANK-5215) (- v-I_RANK-5220))) v-MASK_RANK-5204))))
    (progn (setf v-MUPPER_RANK-5212 (c-u32 (logand (c-u32 (ash (c-u32 v-UPPER_RANK-5214) (- v-I_RANK-5220))) v-MASK_RANK-5204))))
    (unless (c-true (if (c-true v-BOUNDED_RANK-5213) 0 1)) (go ELSE5243))
    (progn (setf v-BOUNDED_RANK-5213 (c-bool 1)))
    (unless (c-true (if (= (c-u32 (logand v-LOWER_RANK-5215 v-SHIFT_RANK-5216)) (c-u32 (logand v-UPPER_RANK-5214 v-SHIFT_RANK-5216))) 1 0)) (go ELSE5245))
    (go CONTINUE5219)
    ELSE5245
    (go ENDIF5244)
    ELSE5243
    ENDIF5244
    (unless (c-true v-SORTED_RANK-5224) (go ELSE5247))
    (go CONTINUE5219)
    ELSE5247
    (setf v-POS_RANK-5249 (c-u64 0))
    (setf v-J_RANK-5253 v-MLOWER_RANK-5211)
    LOOP5250
    (unless (c-true (if (<= v-J_RANK-5253 v-MUPPER_RANK-5212) 1 0)) (go ENDLOOP5251))
    (setf v-DELTA_RANK-5254 (m-size (+ v-COUNT_RANK-5205 (* 8 v-J_RANK-5253))))
    (progn (setf (m-size (+ v-COUNT_RANK-5205 (* 8 v-J_RANK-5253))) v-POS_RANK-5249))
    (progn (setf v-POS_RANK-5249 (c-u64 (c-u64 (+ v-POS_RANK-5249 v-DELTA_RANK-5254)))))
    (let* ( (old5257 v-J_RANK-5253)) (setf v-J_RANK-5253 (c-u64 (c-u64 (+ old5257 (c-u64 1))))) old5257)
    (go LOOP5250)
    ENDLOOP5251
    (unless (c-true (if (c-true v-TMP_RANK-5206) 0 1)) (go ELSE5258))
    (progn (setf v-TMP_RANK-5206 (c-malloc v-BYTES_TMP_RANK-5207)))
    (unless (c-true (if (c-true v-TMP_RANK-5206) 0 1)) (go ELSE5260))
    (progn (|c/out_of_memory| v-BYTES_TMP_RANK-5207))
    (go ENDIF5261)
    ELSE5260
    ENDIF5261
    (progn (setf v-B_RANK-5209 v-TMP_RANK-5206))
    (go ENDIF5259)
    ELSE5258
    ENDIF5259
    (setf v-D_RANK-5262 (if (c-true (if (= v-C_RANK-5210 v-A_RANK-5208) 1 0)) v-B_RANK-5209 v-A_RANK-5208))
    (setf v-P_RANK-5266 v-C_RANK-5210)
    LOOP5263
    (unless (c-true (if (/= v-P_RANK-5266 v-END_RANK-5223) 1 0)) (go ENDLOOP5264))
    (setf v-R_RANK-5267 (c-u32 (lognot (m-u32 (+ v-counts-5193 (* 4 (m-u32 v-P_RANK-5266)))))))
    (setf v-S_RANK-5268 (c-u32 (ash (c-u32 v-R_RANK-5267) (- v-I_RANK-5220))))
    (setf v-M_RANK-5269 (c-u32 (logand v-S_RANK-5268 v-MASK_RANK-5204)))
    (setf v-POS_RANK-5270 (let* ((a5271 (+ v-COUNT_RANK-5205 (* 8 v-M_RANK-5269))) (old5272 (m-size a5271))) (setf (m-size a5271) (c-u64 (c-u64 (+ old5272 (c-u64 1))))) old5272))
    (progn (setf (m-u32 (+ v-D_RANK-5262 (* 4 v-POS_RANK-5270))) (m-u32 v-P_RANK-5266)))
    (let* ( (old5274 v-P_RANK-5266)) (setf v-P_RANK-5266 (+ old5274 (* 4 1))) old5274)
    (go LOOP5263)
    ENDLOOP5264
    (progn (setf v-C_RANK-5210 v-D_RANK-5262))
    CONTINUE5219
    (progn (setf v-I_RANK-5220 (c-u64 (c-u64 (+ v-I_RANK-5220 v-LENGTH_RANK-5202)))) (setf v-SHIFT_RANK-5216 (c-u32 (c-u32 (ash (c-u32 v-SHIFT_RANK-5216) v-LENGTH_RANK-5202)))))
    (go LOOP5217)
    ENDLOOP5218
    (unless (c-true (if (= v-C_RANK-5210 v-B_RANK-5209) 1 0)) (go ELSE5277))
    (progn (c-memcpy v-A_RANK-5208 v-B_RANK-5209 (c-u64 (* v-N_RANK-5198 4))))
    (go ENDIF5278)
    ELSE5277
    ENDIF5278
    (unless (c-true v-TMP_RANK-5206) (go ELSE5279))
    (progn (c-free v-TMP_RANK-5206))
    (go ENDIF5280)
    ELSE5279
    ENDIF5280
    ENDLOOP5196
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:10034:1
(defun |c/vivify_sort_stack_by_counts| (arg-v-solver-5284 arg-v-counts-5285 arg-v-c-5286)
 (declare  (type c-address arg-v-solver-5284) (type c-address arg-v-counts-5285) (type c-address arg-v-c-5286))
 (let ((v-solver-5284 0) (v-counts-5285 0) (v-c-5286 0))
 (declare (type c-address v-solver-5284) (type c-address v-counts-5285) (type c-address v-c-5286) (ignorable v-solver-5284 v-counts-5285 v-c-5286))
 (tagbody
    (setf v-solver-5284 arg-v-solver-5284)
    (setf v-counts-5285 arg-v-counts-5285)
    (setf v-c-5286 arg-v-c-5286)
    (progn (|c/vivify_sort_lits_by_counts| v-solver-5284 v-counts-5285 v-c-5286))
  )
  0))

;;; upstream/satch.c:10041:1
(defun |c/vivify_sort_clause_by_counts| (arg-v-solver-5287 arg-v-counts-5288 arg-v-c-5289)
 (declare  (type c-address arg-v-solver-5287) (type c-address arg-v-counts-5288) (type c-address arg-v-c-5289))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-5287 0) (v-counts-5288 0) (v-c-5289 0) (v-c2-5290 (stack-alloc 24)))
 (declare (type c-address v-solver-5287) (type c-address v-counts-5288) (type c-address v-c-5289) (type c-address v-c2-5290) (ignorable v-solver-5287 v-counts-5288 v-c-5289 v-c2-5290))
 (tagbody
    (setf v-solver-5287 arg-v-solver-5287)
    (setf v-counts-5288 arg-v-counts-5288)
    (setf v-c-5289 arg-v-c-5289)
    (c-memset v-c2-5290 0 24)
    (setf (m-ptr (+ v-c2-5290 0)) (+ v-c-5289 16))
    (setf (m-ptr (+ v-c2-5290 8)) (+ (+ v-c-5289 16) (* 4 (m-u32 (+ v-c-5289 12)))))
    (setf (m-ptr (+ v-c2-5290 16)) (+ (+ v-c-5289 16) (* 4 (m-u32 (+ v-c-5289 12)))))
    (progn (|c/vivify_sort_lits_by_counts| v-solver-5287 v-counts-5288 v-c2-5290))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:10059:1
(defun |c/worse_candidate| (arg-v-counts-5291 arg-v-c-5292 arg-v-d-5293)
 (declare  (type c-address arg-v-counts-5291) (type c-address arg-v-c-5292) (type c-address arg-v-d-5293))
 (let ((v-counts-5291 0) (v-c-5292 0) (v-d-5293 0) (v-p-5298 0) (v-q-5299 0) (v-e-5300 0) (v-f-5301 0) (v-a-5305 0) (v-b-5308 0) (v-u-5313 0) (v-v-5314 0))
 (declare (type c-address v-counts-5291) (type c-address v-c-5292) (type c-address v-d-5293) (type c-address v-p-5298) (type c-address v-q-5299) (type c-address v-e-5300) (type c-address v-f-5301) (type (unsigned-byte 32) v-a-5305) (type (unsigned-byte 32) v-b-5308) (type (unsigned-byte 32) v-u-5313) (type (unsigned-byte 32) v-v-5314) (ignorable v-counts-5291 v-c-5292 v-d-5293 v-p-5298 v-q-5299 v-e-5300 v-f-5301 v-a-5305 v-b-5308 v-u-5313 v-v-5314))
 (tagbody
    (setf v-counts-5291 arg-v-counts-5291)
    (setf v-c-5292 arg-v-c-5292)
    (setf v-d-5293 arg-v-d-5293)
    (unless (c-true (if (c-true (if (c-true (ldb (byte 2 7) (m-u16 (+ v-c-5292 0)))) 0 1)) (c-bool (ldb (byte 2 7) (m-u16 (+ v-d-5293 0)))) 0)) (go ELSE5294))
    (return-from |c/worse_candidate| (c-bool 1))
    ELSE5294
    (unless (c-true (if (c-true (ldb (byte 2 7) (m-u16 (+ v-c-5292 0)))) (c-bool (if (c-true (ldb (byte 2 7) (m-u16 (+ v-d-5293 0)))) 0 1)) 0)) (go ELSE5296))
    (return-from |c/worse_candidate| (c-bool 0))
    ELSE5296
    (setf v-p-5298 (+ v-c-5292 16))
    (setf v-q-5299 (+ v-d-5293 16))
    (setf v-e-5300 (+ (+ v-c-5292 16) (* 4 (m-u32 (+ v-c-5292 12)))))
    (setf v-f-5301 (+ (+ v-d-5293 16) (* 4 (m-u32 (+ v-d-5293 12)))))
    LOOP5302
    (unless (c-true (if (c-true (if (/= v-p-5298 v-e-5300) 1 0)) (c-bool (if (/= v-q-5299 v-f-5301) 1 0)) 0)) (go ENDLOOP5303))
    (setf v-a-5305 (m-u32 (let* ( (old5307 v-p-5298)) (setf v-p-5298 (+ old5307 (* 4 1))) old5307)))
    (setf v-b-5308 (m-u32 (let* ( (old5310 v-q-5299)) (setf v-q-5299 (+ old5310 (* 4 1))) old5310)))
    (unless (c-true (if (= v-a-5305 v-b-5308) 1 0)) (go ELSE5311))
    (go CONTINUE5304)
    ELSE5311
    (setf v-u-5313 (m-u32 (+ v-counts-5291 (* 4 v-a-5305))))
    (setf v-v-5314 (m-u32 (+ v-counts-5291 (* 4 v-b-5308))))
    (unless (c-true (if (< v-u-5313 v-v-5314) 1 0)) (go ELSE5315))
    (return-from |c/worse_candidate| (c-bool 1))
    ELSE5315
    (unless (c-true (if (> v-u-5313 v-v-5314) 1 0)) (go ELSE5317))
    (return-from |c/worse_candidate| (c-bool 0))
    ELSE5317
    (return-from |c/worse_candidate| (c-bool (if (< v-a-5305 v-b-5308) 1 0)))
    CONTINUE5304
    (go LOOP5302)
    ENDLOOP5303
    (unless (c-true (if (c-true (if (/= v-p-5298 v-e-5300) 1 0)) (c-bool (if (= v-q-5299 v-f-5301) 1 0)) 0)) (go ELSE5319))
    (return-from |c/worse_candidate| (c-bool 1))
    ELSE5319
    (unless (c-true (if (c-true (if (= v-p-5298 v-e-5300) 1 0)) (c-bool (if (/= v-q-5299 v-f-5301) 1 0)) 0)) (go ELSE5321))
    (return-from |c/worse_candidate| (c-bool 0))
    ELSE5321
    (return-from |c/worse_candidate| (c-bool (if (< v-c-5292 v-d-5293) 1 0)))
  )
  0))

;;; upstream/satch.c:10104:1
(defun |c/sort_vivification_candidates| (arg-v-solver-5323 arg-v-schedule-5324 arg-v-counts-5325)
 (declare (optimize (speed 1) (compilation-speed 3)) (notinline checked-address) (type c-address arg-v-solver-5323) (type c-address arg-v-schedule-5324) (type c-address arg-v-counts-5325))
 (let ((v-solver-5323 0) (v-schedule-5324 0) (v-counts-5325 0) (v-c-5329 0) (v-PTR_c-5330 0) (v-END_c-5331 0) (v-N_SORT_STACK-5337 0) (v-A_SORT_STACK-5340 0) (v-N_SORT-5344 0) (v-A_SORT-5347 0) (v-L_QUICK_SORT-5351 0) (v-R_QUICK_SORT-5352 0) (v-M-5358 0) (v-TMP_SWAP-5362 0) (v-TMP_SWAP-5371 0) (v-TMP_SWAP-5380 0) (v-TMP_SWAP-5389 0) (v-I_QUICK_SORT-5390 0) (v-L_PARTITION-5394 0) (v-J_PARTITION-5395 0) (v-PIVOT_PARTITION-5396 0) (v-TMP_SWAP-5417 0) (v-TMP_SWAP-5421 0) (v-LL_QUICK_SORT-5422 0) (v-RR_QUICK_SORT-5423 0) (v-old_size-5436 0) (v-old_capacity-5437 0) (v-new_capacity-5438 0) (v-new_bytes-5439 0) (v-old_size-5452 0) (v-old_capacity-5453 0) (v-new_capacity-5454 0) (v-new_bytes-5455 0) (v-L_INSERTION_SORT-5471 0) (v-R_INSERTION_SORT-5472 0) (v-I_INSERTION_SORT-5476 0) (v-TMP_SWAP-5485 0) (v-I_INSERTION_SORT-5491 0) (v-PIVOT_INSERTION_SORT-5492 0) (v-J_INSERTION_SORT-5493 0))
 (declare (type c-address v-solver-5323) (type c-address v-schedule-5324) (type c-address v-counts-5325) (type c-address v-c-5329) (type c-address v-PTR_c-5330) (type c-address v-END_c-5331) (type c-size v-N_SORT_STACK-5337) (type c-address v-A_SORT_STACK-5340) (type c-size v-N_SORT-5344) (type c-address v-A_SORT-5347) (type c-size v-L_QUICK_SORT-5351) (type c-size v-R_QUICK_SORT-5352) (type c-size v-M-5358) (type c-address v-TMP_SWAP-5362) (type c-address v-TMP_SWAP-5371) (type c-address v-TMP_SWAP-5380) (type c-address v-TMP_SWAP-5389) (type c-size v-I_QUICK_SORT-5390) (type c-size v-L_PARTITION-5394) (type c-size v-J_PARTITION-5395) (type c-address v-PIVOT_PARTITION-5396) (type c-address v-TMP_SWAP-5417) (type c-address v-TMP_SWAP-5421) (type c-size v-LL_QUICK_SORT-5422) (type c-size v-RR_QUICK_SORT-5423) (type c-size v-old_size-5436) (type c-size v-old_capacity-5437) (type c-size v-new_capacity-5438) (type c-size v-new_bytes-5439) (type c-size v-old_size-5452) (type c-size v-old_capacity-5453) (type c-size v-new_capacity-5454) (type c-size v-new_bytes-5455) (type c-size v-L_INSERTION_SORT-5471) (type c-size v-R_INSERTION_SORT-5472) (type c-size v-I_INSERTION_SORT-5476) (type c-address v-TMP_SWAP-5485) (type c-size v-I_INSERTION_SORT-5491) (type c-address v-PIVOT_INSERTION_SORT-5492) (type c-size v-J_INSERTION_SORT-5493) (ignorable v-solver-5323 v-schedule-5324 v-counts-5325 v-c-5329 v-PTR_c-5330 v-END_c-5331 v-N_SORT_STACK-5337 v-A_SORT_STACK-5340 v-N_SORT-5344 v-A_SORT-5347 v-L_QUICK_SORT-5351 v-R_QUICK_SORT-5352 v-M-5358 v-TMP_SWAP-5362 v-TMP_SWAP-5371 v-TMP_SWAP-5380 v-TMP_SWAP-5389 v-I_QUICK_SORT-5390 v-L_PARTITION-5394 v-J_PARTITION-5395 v-PIVOT_PARTITION-5396 v-TMP_SWAP-5417 v-TMP_SWAP-5421 v-LL_QUICK_SORT-5422 v-RR_QUICK_SORT-5423 v-old_size-5436 v-old_capacity-5437 v-new_capacity-5438 v-new_bytes-5439 v-old_size-5452 v-old_capacity-5453 v-new_capacity-5454 v-new_bytes-5455 v-L_INSERTION_SORT-5471 v-R_INSERTION_SORT-5472 v-I_INSERTION_SORT-5476 v-TMP_SWAP-5485 v-I_INSERTION_SORT-5491 v-PIVOT_INSERTION_SORT-5492 v-J_INSERTION_SORT-5493))
 (tagbody
    (setf v-solver-5323 arg-v-solver-5323)
    (setf v-schedule-5324 arg-v-schedule-5324)
    (setf v-counts-5325 arg-v-counts-5325)
    (setf v-PTR_c-5330 (m-ptr (+ v-schedule-5324 0)))
    (setf v-END_c-5331 (m-ptr (+ v-schedule-5324 8)))
    LOOP5326
    (unless (c-true (if (c-true (if (/= v-PTR_c-5330 v-END_c-5331) 1 0)) (c-bool (progn (setf v-c-5329 (m-ptr v-PTR_c-5330)) 1)) 0)) (go ENDLOOP5327))
    (progn (|c/vivify_sort_clause_by_counts| v-solver-5323 v-counts-5325 v-c-5329))
    (let* ( (old5333 v-PTR_c-5330)) (setf v-PTR_c-5330 (+ old5333 (* 8 1))) v-PTR_c-5330)
    (go LOOP5326)
    ENDLOOP5327
    (setf v-N_SORT_STACK-5337 (the c-size (truncate (- (m-ptr (+ v-schedule-5324 8)) (m-ptr (+ v-schedule-5324 0))) 8)))
    (unless (c-true (if (<= v-N_SORT_STACK-5337 (c-u64 1)) 1 0)) (go ELSE5338))
    (go ENDLOOP5335)
    ELSE5338
    (setf v-A_SORT_STACK-5340 (m-ptr (+ v-schedule-5324 0)))
    (setf v-N_SORT-5344 v-N_SORT_STACK-5337)
    (unless (c-true (if (c-true v-N_SORT-5344) 0 1)) (go ELSE5345))
    (go ENDLOOP5342)
    ELSE5345
    (setf v-A_SORT-5347 v-A_SORT_STACK-5340)
    (setf v-L_QUICK_SORT-5351 (c-u64 0))
    (setf v-R_QUICK_SORT-5352 (c-u64 (- v-N_SORT-5344 (c-u64 1))))
    (unless (c-true (if (<= (c-u64 (- v-R_QUICK_SORT-5352 v-L_QUICK_SORT-5351)) (c-u64 10)) 1 0)) (go ELSE5353))
    (go ENDLOOP5349)
    ELSE5353
    LOOP5355
    (setf v-M-5358 (c-u64 (+ v-L_QUICK_SORT-5351 (c-u64 (truncate (c-u64 (- v-R_QUICK_SORT-5352 v-L_QUICK_SORT-5351)) (c-u64 2))))))
    (setf v-TMP_SWAP-5362 (m-ptr (+ v-A_SORT-5347 (* 8 v-M-5358))))
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 v-M-5358))) (m-ptr (+ v-A_SORT-5347 (* 8 (c-u64 (- v-R_QUICK_SORT-5352 (c-u64 1))))))))
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 (c-u64 (- v-R_QUICK_SORT-5352 (c-u64 1)))))) v-TMP_SWAP-5362))
    (unless (c-true (|c/worse_candidate| v-counts-5325 (m-ptr (+ v-A_SORT-5347 (* 8 (c-u64 (- v-R_QUICK_SORT-5352 (c-u64 1)))))) (m-ptr (+ v-A_SORT-5347 (* 8 v-L_QUICK_SORT-5351))))) (go ELSE5366))
    (setf v-TMP_SWAP-5371 (m-ptr (+ v-A_SORT-5347 (* 8 v-L_QUICK_SORT-5351))))
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 v-L_QUICK_SORT-5351))) (m-ptr (+ v-A_SORT-5347 (* 8 (c-u64 (- v-R_QUICK_SORT-5352 (c-u64 1))))))))
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 (c-u64 (- v-R_QUICK_SORT-5352 (c-u64 1)))))) v-TMP_SWAP-5371))
    (go ENDIF5367)
    ELSE5366
    ENDIF5367
    (unless (c-true (|c/worse_candidate| v-counts-5325 (m-ptr (+ v-A_SORT-5347 (* 8 v-R_QUICK_SORT-5352))) (m-ptr (+ v-A_SORT-5347 (* 8 v-L_QUICK_SORT-5351))))) (go ELSE5375))
    (setf v-TMP_SWAP-5380 (m-ptr (+ v-A_SORT-5347 (* 8 v-L_QUICK_SORT-5351))))
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 v-L_QUICK_SORT-5351))) (m-ptr (+ v-A_SORT-5347 (* 8 v-R_QUICK_SORT-5352)))))
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 v-R_QUICK_SORT-5352))) v-TMP_SWAP-5380))
    (go ENDIF5376)
    ELSE5375
    ENDIF5376
    (unless (c-true (|c/worse_candidate| v-counts-5325 (m-ptr (+ v-A_SORT-5347 (* 8 v-R_QUICK_SORT-5352))) (m-ptr (+ v-A_SORT-5347 (* 8 (c-u64 (- v-R_QUICK_SORT-5352 (c-u64 1)))))))) (go ELSE5384))
    (setf v-TMP_SWAP-5389 (m-ptr (+ v-A_SORT-5347 (* 8 (c-u64 (- v-R_QUICK_SORT-5352 (c-u64 1)))))))
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 (c-u64 (- v-R_QUICK_SORT-5352 (c-u64 1)))))) (m-ptr (+ v-A_SORT-5347 (* 8 v-R_QUICK_SORT-5352)))))
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 v-R_QUICK_SORT-5352))) v-TMP_SWAP-5389))
    (go ENDIF5385)
    ELSE5384
    ENDIF5385
    (setf v-L_PARTITION-5394 (c-u64 (+ v-L_QUICK_SORT-5351 (c-u64 1))))
    (progn (setf v-I_QUICK_SORT-5390 (c-u64 (- v-L_PARTITION-5394 (c-u64 1)))))
    (setf v-J_PARTITION-5395 (c-u64 (- v-R_QUICK_SORT-5352 (c-u64 1))))
    (setf v-PIVOT_PARTITION-5396 (m-ptr (+ v-A_SORT-5347 (* 8 v-J_PARTITION-5395))))
    LOOP5397
    LOOP5400
    (unless (c-true (|c/worse_candidate| v-counts-5325 (m-ptr (+ v-A_SORT-5347 (* 8 (let* ( (old5404 v-I_QUICK_SORT-5390)) (setf v-I_QUICK_SORT-5390 (c-u64 (c-u64 (+ old5404 (c-u64 1))))) v-I_QUICK_SORT-5390)))) v-PIVOT_PARTITION-5396)) (go ENDLOOP5401))
    (go LOOP5400)
    ENDLOOP5401
    LOOP5405
    (unless (c-true (|c/worse_candidate| v-counts-5325 v-PIVOT_PARTITION-5396 (m-ptr (+ v-A_SORT-5347 (* 8 (let* ( (old5409 v-J_PARTITION-5395)) (setf v-J_PARTITION-5395 (c-u64 (c-u64 (- old5409 (c-u64 1))))) v-J_PARTITION-5395)))))) (go ENDLOOP5406))
    (unless (c-true (if (= v-J_PARTITION-5395 v-L_PARTITION-5394) 1 0)) (go ELSE5410))
    (go ENDLOOP5406)
    ELSE5410
    (go LOOP5405)
    ENDLOOP5406
    (unless (c-true (if (>= v-I_QUICK_SORT-5390 v-J_PARTITION-5395) 1 0)) (go ELSE5412))
    (go ENDLOOP5398)
    ELSE5412
    (setf v-TMP_SWAP-5417 (m-ptr (+ v-A_SORT-5347 (* 8 v-I_QUICK_SORT-5390))))
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 v-I_QUICK_SORT-5390))) (m-ptr (+ v-A_SORT-5347 (* 8 v-J_PARTITION-5395)))))
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 v-J_PARTITION-5395))) v-TMP_SWAP-5417))
    (go LOOP5397)
    ENDLOOP5398
    (setf v-TMP_SWAP-5421 (m-ptr (+ v-A_SORT-5347 (* 8 v-I_QUICK_SORT-5390))))
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 v-I_QUICK_SORT-5390))) (m-ptr (+ v-A_SORT-5347 (* 8 (c-u64 (- v-R_QUICK_SORT-5352 (c-u64 1))))))))
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 (c-u64 (- v-R_QUICK_SORT-5352 (c-u64 1)))))) v-TMP_SWAP-5421))
    (unless (c-true (if (< (c-u64 (- v-I_QUICK_SORT-5390 v-L_QUICK_SORT-5351)) (c-u64 (- v-R_QUICK_SORT-5352 v-I_QUICK_SORT-5390))) 1 0)) (go ELSE5424))
    (progn (setf v-LL_QUICK_SORT-5422 (c-u64 (+ v-I_QUICK_SORT-5390 (c-u64 1)))))
    (progn (setf v-RR_QUICK_SORT-5423 v-R_QUICK_SORT-5352))
    (progn (setf v-R_QUICK_SORT-5352 (c-u64 (- v-I_QUICK_SORT-5390 (c-u64 1)))))
    (go ENDIF5425)
    ELSE5424
    (progn (setf v-LL_QUICK_SORT-5422 v-L_QUICK_SORT-5351))
    (progn (setf v-RR_QUICK_SORT-5423 (c-u64 (- v-I_QUICK_SORT-5390 (c-u64 1)))))
    (progn (setf v-L_QUICK_SORT-5351 (c-u64 (+ v-I_QUICK_SORT-5390 (c-u64 1)))))
    ENDIF5425
    (unless (c-true (if (> (c-u64 (- v-R_QUICK_SORT-5352 v-L_QUICK_SORT-5351)) (c-u64 10)) 1 0)) (go ELSE5426))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-5323 1928) 8)) (m-ptr (+ (+ v-solver-5323 1928) 16))) 1 0)) (go ELSE5431))
    (setf v-old_size-5436 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5323 1928) 8)) (m-ptr (+ (+ v-solver-5323 1928) 0))) 4)))
    (setf v-old_capacity-5437 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5323 1928) 16)) (m-ptr (+ (+ v-solver-5323 1928) 0))) 4)))
    (setf v-new_capacity-5438 (if (c-true v-old_capacity-5437) (c-u64 (* (c-u64 2) v-old_capacity-5437)) (c-u64 1)))
    (setf v-new_bytes-5439 (c-u64 (* v-new_capacity-5438 4)))
    (progn (setf (m-ptr (+ (+ v-solver-5323 1928) 0)) (c-realloc (m-ptr (+ (+ v-solver-5323 1928) 0)) v-new_bytes-5439)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-5323 1928) 0))) 0 1)) (go ELSE5440))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-5439))
    (go ENDIF5441)
    ELSE5440
    ENDIF5441
    (progn (setf (m-ptr (+ (+ v-solver-5323 1928) 8)) (+ (m-ptr (+ (+ v-solver-5323 1928) 0)) (* 4 v-old_size-5436))))
    (progn (setf (m-ptr (+ (+ v-solver-5323 1928) 16)) (+ (m-ptr (+ (+ v-solver-5323 1928) 0)) (* 4 v-new_capacity-5438))))
    (go ENDIF5432)
    ELSE5431
    ENDIF5432
    (progn (setf (m-u32 (let* ((a5442 (+ (+ v-solver-5323 1928) 8)) (old5443 (m-ptr a5442))) (setf (m-ptr a5442) (+ old5443 (* 4 1))) old5443)) (c-u32 v-LL_QUICK_SORT-5422)))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-5323 1928) 8)) (m-ptr (+ (+ v-solver-5323 1928) 16))) 1 0)) (go ELSE5447))
    (setf v-old_size-5452 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5323 1928) 8)) (m-ptr (+ (+ v-solver-5323 1928) 0))) 4)))
    (setf v-old_capacity-5453 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5323 1928) 16)) (m-ptr (+ (+ v-solver-5323 1928) 0))) 4)))
    (setf v-new_capacity-5454 (if (c-true v-old_capacity-5453) (c-u64 (* (c-u64 2) v-old_capacity-5453)) (c-u64 1)))
    (setf v-new_bytes-5455 (c-u64 (* v-new_capacity-5454 4)))
    (progn (setf (m-ptr (+ (+ v-solver-5323 1928) 0)) (c-realloc (m-ptr (+ (+ v-solver-5323 1928) 0)) v-new_bytes-5455)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-5323 1928) 0))) 0 1)) (go ELSE5456))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-5455))
    (go ENDIF5457)
    ELSE5456
    ENDIF5457
    (progn (setf (m-ptr (+ (+ v-solver-5323 1928) 8)) (+ (m-ptr (+ (+ v-solver-5323 1928) 0)) (* 4 v-old_size-5452))))
    (progn (setf (m-ptr (+ (+ v-solver-5323 1928) 16)) (+ (m-ptr (+ (+ v-solver-5323 1928) 0)) (* 4 v-new_capacity-5454))))
    (go ENDIF5448)
    ELSE5447
    ENDIF5448
    (progn (setf (m-u32 (let* ((a5458 (+ (+ v-solver-5323 1928) 8)) (old5459 (m-ptr a5458))) (setf (m-ptr a5458) (+ old5459 (* 4 1))) old5459)) (c-u32 v-RR_QUICK_SORT-5423)))
    (go ENDIF5427)
    ELSE5426
    (unless (c-true (if (> (c-u64 (- v-RR_QUICK_SORT-5423 v-LL_QUICK_SORT-5422)) (c-u64 10)) 1 0)) (go ELSE5460))
    (progn (setf v-L_QUICK_SORT-5351 v-LL_QUICK_SORT-5422))
    (progn (setf v-R_QUICK_SORT-5352 v-RR_QUICK_SORT-5423))
    (go ENDIF5461)
    ELSE5460
    (unless (c-true (if (c-true (if (= (m-ptr (+ (+ v-solver-5323 1928) 8)) (m-ptr (+ (+ v-solver-5323 1928) 0))) 1 0)) 0 1)) (go ELSE5462))
    (progn (setf v-R_QUICK_SORT-5352 (progn 0 (m-u32 (let* ((a5464 (+ (+ v-solver-5323 1928) 8)) (old5465 (m-ptr a5464))) (setf (m-ptr a5464) (- old5465 (* 4 1))) (m-ptr a5464))))))
    (progn (setf v-L_QUICK_SORT-5351 (progn 0 (m-u32 (let* ((a5466 (+ (+ v-solver-5323 1928) 8)) (old5467 (m-ptr a5466))) (setf (m-ptr a5466) (- old5467 (* 4 1))) (m-ptr a5466))))))
    (go ENDIF5463)
    ELSE5462
    (go ENDLOOP5356)
    ENDIF5463
    ENDIF5461
    ENDIF5427
    (go LOOP5355)
    ENDLOOP5356
    ENDLOOP5349
    (setf v-L_INSERTION_SORT-5471 (c-u64 0))
    (setf v-R_INSERTION_SORT-5472 (c-u64 (- v-N_SORT-5344 (c-u64 1))))
    (setf v-I_INSERTION_SORT-5476 v-R_INSERTION_SORT-5472)
    LOOP5473
    (unless (c-true (if (> v-I_INSERTION_SORT-5476 v-L_INSERTION_SORT-5471) 1 0)) (go ENDLOOP5474))
    (unless (c-true (|c/worse_candidate| v-counts-5325 (m-ptr (+ v-A_SORT-5347 (* 8 v-I_INSERTION_SORT-5476))) (m-ptr (+ v-A_SORT-5347 (* 8 (c-u64 (- v-I_INSERTION_SORT-5476 (c-u64 1)))))))) (go ELSE5480))
    (setf v-TMP_SWAP-5485 (m-ptr (+ v-A_SORT-5347 (* 8 (c-u64 (- v-I_INSERTION_SORT-5476 (c-u64 1)))))))
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 (c-u64 (- v-I_INSERTION_SORT-5476 (c-u64 1)))))) (m-ptr (+ v-A_SORT-5347 (* 8 v-I_INSERTION_SORT-5476)))))
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 v-I_INSERTION_SORT-5476))) v-TMP_SWAP-5485))
    (go ENDIF5481)
    ELSE5480
    ENDIF5481
    (let* ( (old5487 v-I_INSERTION_SORT-5476)) (setf v-I_INSERTION_SORT-5476 (c-u64 (c-u64 (- old5487 (c-u64 1))))) old5487)
    (go LOOP5473)
    ENDLOOP5474
    (setf v-I_INSERTION_SORT-5491 (c-u64 (+ v-L_INSERTION_SORT-5471 (c-u64 2))))
    LOOP5488
    (unless (c-true (if (<= v-I_INSERTION_SORT-5491 v-R_INSERTION_SORT-5472) 1 0)) (go ENDLOOP5489))
    (setf v-PIVOT_INSERTION_SORT-5492 (m-ptr (+ v-A_SORT-5347 (* 8 v-I_INSERTION_SORT-5491))))
    (setf v-J_INSERTION_SORT-5493 v-I_INSERTION_SORT-5491)
    LOOP5494
    (unless (c-true (|c/worse_candidate| v-counts-5325 v-PIVOT_INSERTION_SORT-5492 (m-ptr (+ v-A_SORT-5347 (* 8 (c-u64 (- v-J_INSERTION_SORT-5493 (c-u64 1)))))))) (go ENDLOOP5495))
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 v-J_INSERTION_SORT-5493))) (m-ptr (+ v-A_SORT-5347 (* 8 (c-u64 (- v-J_INSERTION_SORT-5493 (c-u64 1))))))))
    (progn (let* ( (old5498 v-J_INSERTION_SORT-5493)) (setf v-J_INSERTION_SORT-5493 (c-u64 (c-u64 (- old5498 (c-u64 1))))) old5498))
    (go LOOP5494)
    ENDLOOP5495
    (progn (setf (m-ptr (+ v-A_SORT-5347 (* 8 v-J_INSERTION_SORT-5493))) v-PIVOT_INSERTION_SORT-5492))
    (let* ( (old5500 v-I_INSERTION_SORT-5491)) (setf v-I_INSERTION_SORT-5491 (c-u64 (c-u64 (+ old5500 (c-u64 1))))) old5500)
    (go LOOP5488)
    ENDLOOP5489
    ENDLOOP5342
    ENDLOOP5335
  )
  0))

;;; upstream/satch.c:10118:1
(defun |c/count_literal| (arg-v-lit-5504 arg-v-counts-5505)
 (declare  (type (unsigned-byte 32) arg-v-lit-5504) (type c-address arg-v-counts-5505))
 (let ((v-lit-5504 0) (v-counts-5505 0) (v-old_count-5506 0) (v-new_count-5507 0))
 (declare (type (unsigned-byte 32) v-lit-5504) (type c-address v-counts-5505) (type (unsigned-byte 32) v-old_count-5506) (type (unsigned-byte 32) v-new_count-5507) (ignorable v-lit-5504 v-counts-5505 v-old_count-5506 v-new_count-5507))
 (tagbody
    (setf v-lit-5504 arg-v-lit-5504)
    (setf v-counts-5505 arg-v-counts-5505)
    (setf v-old_count-5506 (m-u32 (+ v-counts-5505 (* 4 v-lit-5504))))
    (setf v-new_count-5507 (if (c-true (if (< v-old_count-5506 4294967295) 1 0)) (c-u32 (+ v-old_count-5506 (c-u32 1))) 4294967295))
    (progn (setf (m-u32 (+ v-counts-5505 (* 4 v-lit-5504))) v-new_count-5507))
  )
  0))

;;; upstream/satch.c:10127:1
(defun |c/vivify_count_clause| (arg-v-c-5508 arg-v-counts-5509)
 (declare  (type c-address arg-v-c-5508) (type c-address arg-v-counts-5509))
 (let ((v-c-5508 0) (v-counts-5509 0) (v-lit-5513 0) (v-P_lit-5514 0) (v-END_lit-5515 0))
 (declare (type c-address v-c-5508) (type c-address v-counts-5509) (type (unsigned-byte 32) v-lit-5513) (type c-address v-P_lit-5514) (type c-address v-END_lit-5515) (ignorable v-c-5508 v-counts-5509 v-lit-5513 v-P_lit-5514 v-END_lit-5515))
 (tagbody
    (setf v-c-5508 arg-v-c-5508)
    (setf v-counts-5509 arg-v-counts-5509)
    (setf v-P_lit-5514 (+ v-c-5508 16))
    (setf v-END_lit-5515 (+ v-P_lit-5514 (* 4 (m-u32 (+ v-c-5508 12)))))
    LOOP5510
    (unless (c-true (if (c-true (if (/= v-P_lit-5514 v-END_lit-5515) 1 0)) (c-bool (progn (setf v-lit-5513 (m-u32 v-P_lit-5514)) 1)) 0)) (go ENDLOOP5511))
    (progn (|c/count_literal| v-lit-5513 v-counts-5509))
    (let* ( (old5517 v-P_lit-5514)) (setf v-P_lit-5514 (+ old5517 (* 4 1))) v-P_lit-5514)
    (go LOOP5510)
    ENDLOOP5511
  )
  0))

;;; upstream/satch.c:10134:1
(defun |c/flush_large_watches| (arg-v-solver-5518)
 (declare  (type c-address arg-v-solver-5518))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-5518 0) (v-all_watches-5522 0) (v-lit-5526 0) (v-END_LITERALS-5527 0) (v-lit_watches-5528 0) (v-q-5529 0) (v-end-5530 0) (v-p-5531 0) (v-watch-5535 (stack-alloc 8)) (v-header-5540 (stack-alloc 8)))
 (declare (type c-address v-solver-5518) (type c-address v-all_watches-5522) (type (unsigned-byte 32) v-lit-5526) (type (unsigned-byte 32) v-END_LITERALS-5527) (type c-address v-lit_watches-5528) (type c-address v-q-5529) (type c-address v-end-5530) (type c-address v-p-5531) (type c-address v-watch-5535) (type c-address v-header-5540) (ignorable v-solver-5518 v-all_watches-5522 v-lit-5526 v-END_LITERALS-5527 v-lit_watches-5528 v-q-5529 v-end-5530 v-p-5531 v-watch-5535 v-header-5540))
 (tagbody
    (setf v-solver-5518 arg-v-solver-5518)
    (progn v-solver-5518)
    (setf v-all_watches-5522 (m-ptr (+ v-solver-5518 544)))
    (setf v-lit-5526 (c-u32 0))
    (setf v-END_LITERALS-5527 (c-u32 (* 2 (m-u32 (+ v-solver-5518 12)))))
    LOOP5523
    (unless (c-true (if (< v-lit-5526 v-END_LITERALS-5527) 1 0)) (go ENDLOOP5524))
    (setf v-lit_watches-5528 (+ v-all_watches-5522 (* 24 v-lit-5526)))
    (setf v-q-5529 (m-ptr (+ v-lit_watches-5528 0)))
    (setf v-end-5530 (m-ptr (+ v-lit_watches-5528 8)))
    (setf v-p-5531 v-q-5529)
    LOOP5532
    (unless (c-true (if (/= v-p-5531 v-end-5530) 1 0)) (go ENDLOOP5533))
    (copy-bytes v-watch-5535 (copy-bytes (let* ( (old5537 v-q-5529)) (setf v-q-5529 (+ old5537 (* 8 1))) old5537) (let* ( (old5539 v-p-5531)) (setf v-p-5531 (+ old5539 (* 8 1))) old5539) 8) 8)
    (copy-bytes v-header-5540 (+ v-watch-5535 0) 8)
    (unless (c-true (m-u8 (+ v-header-5540 0))) (go ELSE5541))
    (go ENDIF5542)
    ELSE5541
    (progn (let* ( (old5544 v-q-5529)) (setf v-q-5529 (- old5544 (* 8 1))) old5544))
    (progn (let* ( (old5546 v-p-5531)) (setf v-p-5531 (+ old5546 (* 8 1))) old5546))
    ENDIF5542
    (go LOOP5532)
    ENDLOOP5533
    (progn (setf (m-ptr (+ v-lit_watches-5528 8)) v-q-5529))
    (let* ( (old5548 v-lit-5526)) (setf v-lit-5526 (c-u32 (c-u32 (+ old5548 (c-u32 1))))) old5548)
    (go LOOP5523)
    ENDLOOP5524
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:10175:1
(defun |c/watch_large_clauses| (arg-v-solver-5549)
 (declare  (type c-address arg-v-solver-5549))
 (let ((v-solver-5549 0) (v-c-5556 0) (v-PTR_c-5557 0) (v-END_c-5558 0) (v-c-5566 0) (v-PTR_c-5567 0) (v-END_c-5568 0))
 (declare (type c-address v-solver-5549) (type c-address v-c-5556) (type c-address v-PTR_c-5557) (type c-address v-END_c-5558) (type c-address v-c-5566) (type c-address v-PTR_c-5567) (type c-address v-END_c-5568) (ignorable v-solver-5549 v-c-5556 v-PTR_c-5557 v-END_c-5558 v-c-5566 v-PTR_c-5567 v-END_c-5568))
 (tagbody
    (setf v-solver-5549 arg-v-solver-5549)
    (progn v-solver-5549)
    (setf v-PTR_c-5557 (m-ptr (+ (+ v-solver-5549 672) 0)))
    (setf v-END_c-5558 (m-ptr (+ (+ v-solver-5549 672) 8)))
    LOOP5553
    (unless (c-true (if (c-true (if (/= v-PTR_c-5557 v-END_c-5558) 1 0)) (c-bool (progn (setf v-c-5556 (m-ptr v-PTR_c-5557)) 1)) 0)) (go ENDLOOP5554))
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-c-5556 0)))) (go ELSE5559))
    (go CONTINUE5555)
    ELSE5559
    (progn (setf (m-u32 (+ v-c-5556 8)) (c-u32 0)))
    (progn (|c/watch_clause| v-solver-5549 v-c-5556))
    CONTINUE5555
    (let* ( (old5562 v-PTR_c-5557)) (setf v-PTR_c-5557 (+ old5562 (* 8 1))) v-PTR_c-5557)
    (go LOOP5553)
    ENDLOOP5554
    (setf v-PTR_c-5567 (m-ptr (+ (+ v-solver-5549 696) 0)))
    (setf v-END_c-5568 (m-ptr (+ (+ v-solver-5549 696) 8)))
    LOOP5563
    (unless (c-true (if (c-true (if (/= v-PTR_c-5567 v-END_c-5568) 1 0)) (c-bool (progn (setf v-c-5566 (m-ptr v-PTR_c-5567)) 1)) 0)) (go ENDLOOP5564))
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-c-5566 0)))) (go ELSE5569))
    (go CONTINUE5565)
    ELSE5569
    (progn (setf (m-u32 (+ v-c-5566 8)) (c-u32 0)))
    (progn (|c/watch_clause| v-solver-5549 v-c-5566))
    CONTINUE5565
    (let* ( (old5572 v-PTR_c-5567)) (setf v-PTR_c-5567 (+ old5572 (* 8 1))) v-PTR_c-5567)
    (go LOOP5563)
    ENDLOOP5564
  )
  0))

;;; upstream/satch.c:10206:1
(defun |c/promote_clause| (arg-v-solver-5573 arg-v-c-5574 arg-v-glue-5575)
 (declare  (type c-address arg-v-solver-5573) (type c-address arg-v-c-5574) (type (unsigned-byte 32) arg-v-glue-5575))
 (let ((v-solver-5573 0) (v-c-5574 0) (v-glue-5575 0) (v-old_glue-5576 0))
 (declare (type c-address v-solver-5573) (type c-address v-c-5574) (type (unsigned-byte 32) v-glue-5575) (type (unsigned-byte 32) v-old_glue-5576) (ignorable v-solver-5573 v-c-5574 v-glue-5575 v-old_glue-5576))
 (tagbody
    (setf v-solver-5573 arg-v-solver-5573)
    (setf v-c-5574 arg-v-c-5574)
    (setf v-glue-5575 arg-v-glue-5575)
    (setf v-old_glue-5576 (m-u32 (+ v-c-5574 4)))
    (progn (setf (m-u32 (+ v-c-5574 4)) v-glue-5575))
    (unless (c-true (if (c-true (if (> v-old_glue-5576 (c-u32 2)) 1 0)) (c-bool (if (<= v-glue-5575 (c-u32 2)) 1 0)) 0)) (go ELSE5577))
    (progn v-solver-5573)
    (go ENDIF5578)
    ELSE5577
    (unless (c-true (if (c-true (if (> v-old_glue-5576 (c-u32 6)) 1 0)) (c-bool (if (<= v-glue-5575 (c-u32 6)) 1 0)) 0)) (go ELSE5582))
    (progn v-solver-5573)
    (progn (set-bits (+ v-c-5574 0) 4 2 (c-u32 2)))
    (go ENDIF5583)
    ELSE5582
    (progn v-solver-5573)
    ENDIF5583
    ENDIF5578
  )
  0))

;;; upstream/satch.c:10246:1
(defun |c/vivify_marked_literal| (arg-v-solver-5590 arg-v-lit-5591)
 (declare  (type c-address arg-v-solver-5590) (type (unsigned-byte 32) arg-v-lit-5591))
 (let ((v-solver-5590 0) (v-lit-5591 0) (v-idx-5592 0) (v-res-5593 0))
 (declare (type c-address v-solver-5590) (type (unsigned-byte 32) v-lit-5591) (type (unsigned-byte 32) v-idx-5592) (type (signed-byte 8) v-res-5593) (ignorable v-solver-5590 v-lit-5591 v-idx-5592 v-res-5593))
 (tagbody
    (setf v-solver-5590 arg-v-solver-5590)
    (setf v-lit-5591 arg-v-lit-5591)
    (setf v-idx-5592 (|c/INDEX| v-lit-5591))
    (setf v-res-5593 (m-s8 (+ (m-ptr (+ v-solver-5590 1976)) (* 1 v-idx-5592))))
    (return-from |c/vivify_marked_literal| (c-s8 (if (= v-res-5593 (|c/INT_SIGN| v-lit-5591)) 1 0)))
  )
  0))

;;; upstream/satch.c:10254:1
(defun |c/vivify_mark_literal| (arg-v-solver-5594 arg-v-lit-5595)
 (declare  (type c-address arg-v-solver-5594) (type (unsigned-byte 32) arg-v-lit-5595))
 (let ((v-solver-5594 0) (v-lit-5595 0) (v-idx-5596 0))
 (declare (type c-address v-solver-5594) (type (unsigned-byte 32) v-lit-5595) (type (unsigned-byte 32) v-idx-5596) (ignorable v-solver-5594 v-lit-5595 v-idx-5596))
 (tagbody
    (setf v-solver-5594 arg-v-solver-5594)
    (setf v-lit-5595 arg-v-lit-5595)
    (setf v-idx-5596 (|c/INDEX| v-lit-5595))
    (progn (setf (m-s8 (+ (m-ptr (+ v-solver-5594 1976)) (* 1 v-idx-5596))) (c-s8 (|c/INT_SIGN| v-lit-5595))))
  )
  0))

;;; upstream/satch.c:10263:1
(defun |c/vivify_boolean_constraint_propagation| (arg-v-solver-5597 arg-v-ignore-5598)
 (declare  (type c-address arg-v-solver-5597) (type c-address arg-v-ignore-5598))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-5597 0) (v-ignore-5598 0) (v-trail-5599 0) (v-propagate-5600 0) (v-p-5601 0) (v-conflict-5602 0) (v-ticks-5603 (stack-alloc 8)) (v-propagated-5618 0))
 (declare (type c-address v-solver-5597) (type c-address v-ignore-5598) (type c-address v-trail-5599) (type c-address v-propagate-5600) (type c-address v-p-5601) (type c-address v-conflict-5602) (type c-address v-ticks-5603) (type (unsigned-byte 32) v-propagated-5618) (ignorable v-solver-5597 v-ignore-5598 v-trail-5599 v-propagate-5600 v-p-5601 v-conflict-5602 v-ticks-5603 v-propagated-5618))
 (tagbody
    (setf v-solver-5597 arg-v-solver-5597)
    (setf v-ignore-5598 arg-v-ignore-5598)
    (setf v-trail-5599 (+ v-solver-5597 552))
    (setf v-propagate-5600 (m-ptr (+ v-trail-5599 16)))
    (setf v-conflict-5602 0)
    (setf (m-u64 v-ticks-5603) (c-u64 0))
    (unless (c-true v-ignore-5598) (go ELSE5604))
    (progn v-solver-5597)
    (go ENDIF5605)
    ELSE5604
    ENDIF5605
    (progn (setf v-p-5601 v-propagate-5600))
    LOOP5609
    (unless (c-true (if (c-true (if (c-true v-conflict-5602) 0 1)) (c-bool (if (/= v-p-5601 (m-ptr (+ v-trail-5599 8))) 1 0)) 0)) (go ENDLOOP5610))
    (progn (setf v-conflict-5602 (|c/propagate_literal| v-solver-5597 (m-u32 v-p-5601) v-ignore-5598 v-ticks-5603)))
    (let* ( (old5613 v-p-5601)) (setf v-p-5601 (+ old5613 (* 4 1))) old5613)
    (go LOOP5609)
    ENDLOOP5610
    (progn (let ((a5617 (+ (+ v-solver-5597 1016) 440))) (setf (m-u64 a5617) (c-u64 (c-u64 (+ (m-u64 a5617) (m-u64 v-ticks-5603)))))))
    (progn (setf (m-ptr (+ (+ v-solver-5597 552) 16)) v-p-5601))
    (setf v-propagated-5618 (c-u32 (truncate (- v-p-5601 v-propagate-5600) 4)))
    (progn (let ((a5622 (+ (+ v-solver-5597 1016) 448))) (setf (m-u64 a5622) (c-u64 (c-u64 (+ (m-u64 a5622) v-propagated-5618))))))
    (unless (c-true v-conflict-5602) (go ELSE5623))
    (progn (progn 0 (let* ((a5625 (+ (+ v-solver-5597 1016) 432)) (old5626 (m-u64 a5625))) (setf (m-u64 a5625) (c-u64 (c-u64 (+ old5626 (c-u64 1))))) (m-u64 a5625))))
    (go ENDIF5624)
    ELSE5623
    ENDIF5624
    (return-from |c/vivify_boolean_constraint_propagation| v-conflict-5602)
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:10294:1
(defun |c/vivify_binary_or_large_conflict| (arg-v-solver-5627 arg-v-conflict-5628)
 (declare  (type c-address arg-v-solver-5627) (type c-address arg-v-conflict-5628))
 (let ((v-solver-5627 0) (v-conflict-5628 0) (v-lit-5635 0) (v-P_lit-5636 0) (v-END_lit-5637 0) (v-level-5638 0))
 (declare (type c-address v-solver-5627) (type c-address v-conflict-5628) (type (unsigned-byte 32) v-lit-5635) (type c-address v-P_lit-5636) (type c-address v-END_lit-5637) (type (unsigned-byte 32) v-level-5638) (ignorable v-solver-5627 v-conflict-5628 v-lit-5635 v-P_lit-5636 v-END_lit-5637 v-level-5638))
 (tagbody
    (setf v-solver-5627 arg-v-solver-5627)
    (setf v-conflict-5628 arg-v-conflict-5628)
    (progn v-solver-5627)
    (setf v-P_lit-5636 (+ v-conflict-5628 16))
    (setf v-END_lit-5637 (+ v-P_lit-5636 (* 4 (m-u32 (+ v-conflict-5628 12)))))
    LOOP5632
    (unless (c-true (if (c-true (if (/= v-P_lit-5636 v-END_lit-5637) 1 0)) (c-bool (progn (setf v-lit-5635 (m-u32 v-P_lit-5636)) 1)) 0)) (go ENDLOOP5633))
    (setf v-level-5638 (m-u32 (+ (m-ptr (+ v-solver-5627 32)) (* 4 (|c/INDEX| v-lit-5635)))))
    (unless (c-true (if (c-true v-level-5638) 0 1)) (go ELSE5639))
    (go CONTINUE5634)
    ELSE5639
    (progn (|c/mark_analyzed| v-solver-5627 (|c/INDEX| v-lit-5635)))
    CONTINUE5634
    (let* ( (old5642 v-P_lit-5636)) (setf v-P_lit-5636 (+ old5642 (* 4 1))) v-P_lit-5636)
    (go LOOP5632)
    ENDLOOP5633
    (progn v-solver-5627)
  )
  0))

