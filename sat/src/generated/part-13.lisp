(in-package #:ooparts/sat/impl)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))
;;; upstream/satch.c:11855:1
(defun |c/internal_release| (arg-v-solver-6669)
 (declare  (type c-address arg-v-solver-6669))
 (let ((v-solver-6669 0) (v-lit-6673 0) (v-END_LITERALS-6674 0) (v-watches-6675 0) (v-c-6720 0) (v-PTR_c-6721 0) (v-END_c-6722 0) (v-c-6731 0) (v-PTR_c-6732 0) (v-END_c-6733 0))
 (declare (type c-address v-solver-6669) (type (unsigned-byte 32) v-lit-6673) (type (unsigned-byte 32) v-END_LITERALS-6674) (type c-address v-watches-6675) (type c-address v-c-6720) (type c-address v-PTR_c-6721) (type c-address v-END_c-6722) (type c-address v-c-6731) (type c-address v-PTR_c-6732) (type c-address v-END_c-6733) (ignorable v-solver-6669 v-lit-6673 v-END_LITERALS-6674 v-watches-6675 v-c-6720 v-PTR_c-6721 v-END_c-6722 v-c-6731 v-PTR_c-6732 v-END_c-6733))
 (tagbody
    (setf v-solver-6669 arg-v-solver-6669)
    (progn (setf (m-ptr (+ v-solver-6669 1896)) 0))
    (setf v-lit-6673 (c-u32 0))
    (setf v-END_LITERALS-6674 (c-u32 (* 2 (m-u32 (+ v-solver-6669 12)))))
    LOOP6670
    (unless (c-true (if (< v-lit-6673 v-END_LITERALS-6674) 1 0)) (go ENDLOOP6671))
    (setf v-watches-6675 (+ (m-ptr (+ v-solver-6669 544)) (* 24 v-lit-6673)))
    (progn (c-free (m-ptr (+ v-watches-6675 0))))
    (progn (setf (m-ptr (+ v-watches-6675 0)) (setf (m-ptr (+ v-watches-6675 8)) (setf (m-ptr (+ v-watches-6675 16)) 0))))
    (let* ( (old6680 v-lit-6673)) (setf v-lit-6673 (c-u32 (c-u32 (+ old6680 (c-u32 1))))) old6680)
    (go LOOP6670)
    ENDLOOP6671
    (progn (c-free (m-ptr (+ v-solver-6669 544))))
    (progn (c-free (m-ptr (+ v-solver-6669 32))))
    (progn (c-free (m-ptr (+ v-solver-6669 40))))
    (progn (c-free (m-ptr (+ v-solver-6669 56))))
    (progn (c-free (m-ptr (+ v-solver-6669 64))))
    (progn (c-free (m-ptr (+ v-solver-6669 80))))
    (progn (c-free (m-ptr (+ v-solver-6669 96))))
    (progn (c-free (m-ptr (+ v-solver-6669 1976))))
    (progn (c-free (m-ptr (+ v-solver-6669 48))))
    (progn (c-free (m-ptr (+ v-solver-6669 232))))
    (progn (c-free (m-ptr (+ v-solver-6669 224))))
    (progn (c-free (m-ptr (+ (+ v-solver-6669 576) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6669 576) 0)) (setf (m-ptr (+ (+ v-solver-6669 576) 8)) (setf (m-ptr (+ (+ v-solver-6669 576) 16)) 0))))
    (progn (c-free (m-ptr (+ v-solver-6669 416))))
    (progn (c-free (m-ptr (+ (+ v-solver-6669 552) 0))))
    (progn (|c/release_queue| (+ (+ v-solver-6669 240) (* 32 0))))
    (progn (|c/release_heap| (+ (+ v-solver-6669 304) (* 56 1))))
    (progn (c-free (m-ptr (+ (+ (+ v-solver-6669 104) (* 24 0)) 0))))
    (progn (setf (m-ptr (+ (+ (+ v-solver-6669 104) (* 24 0)) 0)) (setf (m-ptr (+ (+ (+ v-solver-6669 104) (* 24 0)) 8)) (setf (m-ptr (+ (+ (+ v-solver-6669 104) (* 24 0)) 16)) 0))))
    (progn (c-free (m-ptr (+ (+ (+ v-solver-6669 104) (* 24 1)) 0))))
    (progn (setf (m-ptr (+ (+ (+ v-solver-6669 104) (* 24 1)) 0)) (setf (m-ptr (+ (+ (+ v-solver-6669 104) (* 24 1)) 8)) (setf (m-ptr (+ (+ (+ v-solver-6669 104) (* 24 1)) 16)) 0))))
    (progn (c-free (m-ptr (+ (+ v-solver-6669 496) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6669 496) 0)) (setf (m-ptr (+ (+ v-solver-6669 496) 8)) (setf (m-ptr (+ (+ v-solver-6669 496) 16)) 0))))
    (progn (c-free (m-ptr (+ (+ v-solver-6669 520) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6669 520) 0)) (setf (m-ptr (+ (+ v-solver-6669 520) 8)) (setf (m-ptr (+ (+ v-solver-6669 520) 16)) 0))))
    (progn (c-free (m-ptr (+ (+ v-solver-6669 152) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6669 152) 0)) (setf (m-ptr (+ (+ v-solver-6669 152) 8)) (setf (m-ptr (+ (+ v-solver-6669 152) 16)) 0))))
    (progn (c-free (m-ptr (+ (+ v-solver-6669 176) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6669 176) 0)) (setf (m-ptr (+ (+ v-solver-6669 176) 8)) (setf (m-ptr (+ (+ v-solver-6669 176) 16)) 0))))
    (progn (c-free (m-ptr (+ (+ v-solver-6669 200) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6669 200) 0)) (setf (m-ptr (+ (+ v-solver-6669 200) 8)) (setf (m-ptr (+ (+ v-solver-6669 200) 16)) 0))))
    (progn (c-free (m-ptr (+ (+ v-solver-6669 600) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6669 600) 0)) (setf (m-ptr (+ (+ v-solver-6669 600) 8)) (setf (m-ptr (+ (+ v-solver-6669 600) 16)) 0))))
    (progn (c-free (m-ptr (+ (+ v-solver-6669 624) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6669 624) 0)) (setf (m-ptr (+ (+ v-solver-6669 624) 8)) (setf (m-ptr (+ (+ v-solver-6669 624) 16)) 0))))
    (progn (c-free (m-ptr (+ (+ v-solver-6669 648) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6669 648) 0)) (setf (m-ptr (+ (+ v-solver-6669 648) 8)) (setf (m-ptr (+ (+ v-solver-6669 648) 16)) 0))))
    (progn (c-free (m-ptr (+ (+ v-solver-6669 472) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6669 472) 0)) (setf (m-ptr (+ (+ v-solver-6669 472) 8)) (setf (m-ptr (+ (+ v-solver-6669 472) 16)) 0))))
    (setf v-PTR_c-6721 (m-ptr (+ (+ v-solver-6669 672) 0)))
    (setf v-END_c-6722 (m-ptr (+ (+ v-solver-6669 672) 8)))
    LOOP6717
    (unless (c-true (if (c-true (if (/= v-PTR_c-6721 v-END_c-6722) 1 0)) (c-bool (progn (setf v-c-6720 (m-ptr v-PTR_c-6721)) 1)) 0)) (go ENDLOOP6718))
    (progn (|c/delete_clause| v-solver-6669 v-c-6720))
    (let* ( (old6724 v-PTR_c-6721)) (setf v-PTR_c-6721 (+ old6724 (* 8 1))) v-PTR_c-6721)
    (go LOOP6717)
    ENDLOOP6718
    (progn (c-free (m-ptr (+ (+ v-solver-6669 672) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6669 672) 0)) (setf (m-ptr (+ (+ v-solver-6669 672) 8)) (setf (m-ptr (+ (+ v-solver-6669 672) 16)) 0))))
    (setf v-PTR_c-6732 (m-ptr (+ (+ v-solver-6669 696) 0)))
    (setf v-END_c-6733 (m-ptr (+ (+ v-solver-6669 696) 8)))
    LOOP6728
    (unless (c-true (if (c-true (if (/= v-PTR_c-6732 v-END_c-6733) 1 0)) (c-bool (progn (setf v-c-6731 (m-ptr v-PTR_c-6732)) 1)) 0)) (go ENDLOOP6729))
    (progn (|c/delete_clause| v-solver-6669 v-c-6731))
    (let* ( (old6735 v-PTR_c-6732)) (setf v-PTR_c-6732 (+ old6735 (* 8 1))) v-PTR_c-6732)
    (go LOOP6728)
    ENDLOOP6729
    (progn (c-free (m-ptr (+ (+ v-solver-6669 696) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6669 696) 0)) (setf (m-ptr (+ (+ v-solver-6669 696) 8)) (setf (m-ptr (+ (+ v-solver-6669 696) 16)) 0))))
    (progn (|c/release_binary| v-solver-6669))
    (progn (c-free (m-ptr (+ (+ v-solver-6669 1872) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6669 1872) 0)) (setf (m-ptr (+ (+ v-solver-6669 1872) 8)) (setf (m-ptr (+ (+ v-solver-6669 1872) 16)) 0))))
    (progn (c-free (m-ptr (+ (+ v-solver-6669 1952) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6669 1952) 0)) (setf (m-ptr (+ (+ v-solver-6669 1952) 8)) (setf (m-ptr (+ (+ v-solver-6669 1952) 16)) 0))))
    (progn (c-free (m-ptr (+ (+ v-solver-6669 1904) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6669 1904) 0)) (setf (m-ptr (+ (+ v-solver-6669 1904) 8)) (setf (m-ptr (+ (+ v-solver-6669 1904) 16)) 0))))
    (progn (c-free v-solver-6669))
  )
  0))

;;; upstream/satch.c:11994:1
(defun |c/internal_add| (arg-v-solver-6748 arg-v-elit-6749)
 (declare  (type c-address arg-v-solver-6748) (type (signed-byte 32) arg-v-elit-6749))
 (let ((v-solver-6748 0) (v-elit-6749 0) (v-ilit-6754 0) (v-old_size-6763 0) (v-old_capacity-6764 0) (v-new_capacity-6765 0) (v-new_bytes-6766 0) (v-old_size-6779 0) (v-old_capacity-6780 0) (v-new_capacity-6781 0) (v-new_bytes-6782 0) (v-remove_original_clause-6787 0) (v-size-6790 0) (v-unit-6798 0) (v-value-6799 0) (v-clause-6815 0) (v-added-6819 0) (v-lit-6832 0) (v-PTR_lit-6833 0) (v-END_lit-6834 0))
 (declare (type c-address v-solver-6748) (type (signed-byte 32) v-elit-6749) (type (unsigned-byte 32) v-ilit-6754) (type c-size v-old_size-6763) (type c-size v-old_capacity-6764) (type c-size v-new_capacity-6765) (type c-size v-new_bytes-6766) (type c-size v-old_size-6779) (type c-size v-old_capacity-6780) (type c-size v-new_capacity-6781) (type c-size v-new_bytes-6782) (type (integer 0 1) v-remove_original_clause-6787) (type c-size v-size-6790) (type (unsigned-byte 32) v-unit-6798) (type (signed-byte 8) v-value-6799) (type c-address v-clause-6815) (type c-size v-added-6819) (type (signed-byte 32) v-lit-6832) (type c-address v-PTR_lit-6833) (type c-address v-END_lit-6834) (ignorable v-solver-6748 v-elit-6749 v-ilit-6754 v-old_size-6763 v-old_capacity-6764 v-new_capacity-6765 v-new_bytes-6766 v-old_size-6779 v-old_capacity-6780 v-new_capacity-6781 v-new_bytes-6782 v-remove_original_clause-6787 v-size-6790 v-unit-6798 v-value-6799 v-clause-6815 v-added-6819 v-lit-6832 v-PTR_lit-6833 v-END_lit-6834))
 (tagbody
    (setf v-solver-6748 arg-v-solver-6748)
    (setf v-elit-6749 arg-v-elit-6749)
    (unless (c-true (m-u8 (+ v-solver-6748 4))) (go ELSE6750))
    (return-from |c/internal_add| 0)
    ELSE6750
    (unless (c-true v-elit-6749) (go ELSE6752))
    (setf v-ilit-6754 (|c/import_literal| v-solver-6748 v-elit-6749))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-6748 624) 8)) (m-ptr (+ (+ v-solver-6748 624) 16))) 1 0)) (go ELSE6758))
    (setf v-old_size-6763 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6748 624) 8)) (m-ptr (+ (+ v-solver-6748 624) 0))) 4)))
    (setf v-old_capacity-6764 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6748 624) 16)) (m-ptr (+ (+ v-solver-6748 624) 0))) 4)))
    (setf v-new_capacity-6765 (if (c-true v-old_capacity-6764) (c-u64 (* (c-u64 2) v-old_capacity-6764)) (c-u64 1)))
    (setf v-new_bytes-6766 (c-u64 (* v-new_capacity-6765 4)))
    (progn (setf (m-ptr (+ (+ v-solver-6748 624) 0)) (c-realloc (m-ptr (+ (+ v-solver-6748 624) 0)) v-new_bytes-6766)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-6748 624) 0))) 0 1)) (go ELSE6767))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-6766))
    (go ENDIF6768)
    ELSE6767
    ENDIF6768
    (progn (setf (m-ptr (+ (+ v-solver-6748 624) 8)) (+ (m-ptr (+ (+ v-solver-6748 624) 0)) (* 4 v-old_size-6763))))
    (progn (setf (m-ptr (+ (+ v-solver-6748 624) 16)) (+ (m-ptr (+ (+ v-solver-6748 624) 0)) (* 4 v-new_capacity-6765))))
    (go ENDIF6759)
    ELSE6758
    ENDIF6759
    (progn (setf (m-u32 (let* ((a6769 (+ (+ v-solver-6748 624) 8)) (old6770 (m-ptr a6769))) (setf (m-ptr a6769) (+ old6770 (* 4 1))) old6770)) v-ilit-6754))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-6748 1872) 8)) (m-ptr (+ (+ v-solver-6748 1872) 16))) 1 0)) (go ELSE6774))
    (setf v-old_size-6779 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6748 1872) 8)) (m-ptr (+ (+ v-solver-6748 1872) 0))) 4)))
    (setf v-old_capacity-6780 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6748 1872) 16)) (m-ptr (+ (+ v-solver-6748 1872) 0))) 4)))
    (setf v-new_capacity-6781 (if (c-true v-old_capacity-6780) (c-u64 (* (c-u64 2) v-old_capacity-6780)) (c-u64 1)))
    (setf v-new_bytes-6782 (c-u64 (* v-new_capacity-6781 4)))
    (progn (setf (m-ptr (+ (+ v-solver-6748 1872) 0)) (c-realloc (m-ptr (+ (+ v-solver-6748 1872) 0)) v-new_bytes-6782)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-6748 1872) 0))) 0 1)) (go ELSE6783))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-6782))
    (go ENDIF6784)
    ELSE6783
    ENDIF6784
    (progn (setf (m-ptr (+ (+ v-solver-6748 1872) 8)) (+ (m-ptr (+ (+ v-solver-6748 1872) 0)) (* 4 v-old_size-6779))))
    (progn (setf (m-ptr (+ (+ v-solver-6748 1872) 16)) (+ (m-ptr (+ (+ v-solver-6748 1872) 0)) (* 4 v-new_capacity-6781))))
    (go ENDIF6775)
    ELSE6774
    ENDIF6775
    (progn (setf (m-s32 (let* ((a6785 (+ (+ v-solver-6748 1872) 8)) (old6786 (m-ptr a6785))) (setf (m-ptr a6785) (+ old6786 (* 4 1))) old6786)) v-elit-6749))
    (go ENDIF6753)
    ELSE6752
    (unless (c-true (if (c-true (|c/imported_clause_trivial_or_satisfied| v-solver-6748)) 0 1)) (go ELSE6788))
    (progn (|c/activate_literals| v-solver-6748))
    (setf v-size-6790 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6748 624) 8)) (m-ptr (+ (+ v-solver-6748 624) 0))) 4)))
    (unless (c-true (if (c-true v-size-6790) 0 1)) (go ELSE6791))
    (progn v-solver-6748)
    (progn (setf (m-u8 (+ v-solver-6748 4)) (c-bool 1)))
    (go ENDIF6792)
    ELSE6791
    (unless (c-true (if (= v-size-6790 (c-u64 1)) 1 0)) (go ELSE6796))
    (setf v-unit-6798 (m-u32 (+ (m-ptr (+ (+ v-solver-6748 624) 0)) (* 4 (progn 0 0)))))
    (setf v-value-6799 (m-s8 (+ (m-ptr (+ v-solver-6748 40)) (* 1 v-unit-6798))))
    (unless (c-true (if (> v-value-6799 0) 1 0)) (go ELSE6800))
    (progn v-solver-6748)
    (go ENDIF6801)
    ELSE6800
    (unless (c-true (if (< v-value-6799 0) 1 0)) (go ELSE6805))
    (progn v-solver-6748)
    (progn (setf (m-u8 (+ v-solver-6748 4)) (c-bool 1)))
    (go ENDIF6806)
    ELSE6805
    (progn v-solver-6748)
    (progn (|c/assign| v-solver-6748 v-unit-6798 0 (c-bool 1)))
    (progn (setf v-remove_original_clause-6787 (c-bool 1)))
    ENDIF6806
    ENDIF6801
    (go ENDIF6797)
    ELSE6796
    (unless (c-true (if (= v-size-6790 (c-u64 2)) 1 0)) (go ELSE6813))
    (progn (|c/add_new_binary_and_watch_it| v-solver-6748 (c-bool 0)))
    (go ENDIF6814)
    ELSE6813
    (setf v-clause-6815 (|c/new_irredundant_clause| v-solver-6748))
    (progn v-solver-6748)
    (progn (|c/watch_clause| v-solver-6748 v-clause-6815))
    ENDIF6814
    ENDIF6797
    ENDIF6792
    (setf v-added-6819 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6748 1872) 8)) (m-ptr (+ (+ v-solver-6748 1872) 0))) 4)))
    (unless (c-true (if (< v-size-6790 v-added-6819) 1 0)) (go ELSE6820))
    (progn (|c/trace_and_check_temporary_addition| v-solver-6748))
    (progn (setf v-remove_original_clause-6787 (c-bool 1)))
    (go ENDIF6821)
    ELSE6820
    (progn (setf v-remove_original_clause-6787 (c-bool 0)))
    ENDIF6821
    (go ENDIF6789)
    ELSE6788
    (progn (setf v-remove_original_clause-6787 (c-bool 1)))
    ENDIF6789
    (progn (setf (m-ptr (+ (+ v-solver-6748 624) 8)) (m-ptr (+ (+ v-solver-6748 624) 0))))
    (unless (c-true v-remove_original_clause-6787) (go ELSE6825))
    (unless (c-true (m-ptr (+ v-solver-6748 1896))) (go ELSE6827))
    (progn (|c/start_deletion_proof_line| v-solver-6748))
    (setf v-PTR_lit-6833 (m-ptr (+ (+ v-solver-6748 1872) 0)))
    (setf v-END_lit-6834 (m-ptr (+ (+ v-solver-6748 1872) 8)))
    LOOP6829
    (unless (c-true (if (c-true (if (/= v-PTR_lit-6833 v-END_lit-6834) 1 0)) (c-bool (progn (setf v-lit-6832 (m-s32 v-PTR_lit-6833)) 1)) 0)) (go ENDLOOP6830))
    (progn (|c/add_external_literal_to_proof_line| v-solver-6748 v-lit-6832))
    (let* ( (old6836 v-PTR_lit-6833)) (setf v-PTR_lit-6833 (+ old6836 (* 4 1))) v-PTR_lit-6833)
    (go LOOP6829)
    ENDLOOP6830
    (progn (|c/end_proof_line| v-solver-6748))
    (go ENDIF6828)
    ELSE6827
    ENDIF6828
    (go ENDIF6826)
    ELSE6825
    ENDIF6826
    (progn (setf (m-ptr (+ (+ v-solver-6748 1872) 8)) (m-ptr (+ (+ v-solver-6748 1872) 0))))
    ENDIF6753
  )
  0))

;;; upstream/satch.c:12142:1
(defun |c/satch_init| ()
 (declare  )
 (let ()
 
 (tagbody
    (return-from |c/satch_init| (|c/internal_init|))
  )
  0))

;;; upstream/satch.c:12148:1
(defun |c/satch_release| (arg-v-solver-6840)
 (declare  (type c-address arg-v-solver-6840))
 (let ((v-solver-6840 0))
 (declare (type c-address v-solver-6840) (ignorable v-solver-6840))
 (tagbody
    (setf v-solver-6840 arg-v-solver-6840)
    (unless (c-true (if (c-true v-solver-6840) 0 1)) (go ELSE6844))
    (progn (|c/invalid_usage| |c/string/180| |c/string/181|))
    (go ENDIF6845)
    ELSE6844
    ENDIF6845
    (progn (|c/internal_release| v-solver-6840))
  )
  0))

;;; upstream/satch.c:12161:1
(defun |c/satch_add| (arg-v-solver-6846 arg-v-elit-6847)
 (declare  (type c-address arg-v-solver-6846) (type (signed-byte 32) arg-v-elit-6847))
 (let ((v-solver-6846 0) (v-elit-6847 0))
 (declare (type c-address v-solver-6846) (type (signed-byte 32) v-elit-6847) (ignorable v-solver-6846 v-elit-6847))
 (tagbody
    (setf v-solver-6846 arg-v-solver-6846)
    (setf v-elit-6847 arg-v-elit-6847)
    (unless (c-true (if (c-true v-solver-6846) 0 1)) (go ELSE6851))
    (progn (|c/invalid_usage| |c/string/180| |c/string/182|))
    (go ENDIF6852)
    ELSE6851
    ENDIF6852
    (unless (c-true (if (c-true (if (c-true (m-u64 (+ (+ v-solver-6846 1016) 288))) 0 1)) 0 1)) (go ELSE6856))
    (progn (|c/invalid_usage| |c/string/183| |c/string/182|))
    (go ENDIF6857)
    ELSE6856
    ENDIF6857
    (unless (c-true (if (c-true (if (/= v-elit-6847 (c-s32 (- (c-s32 (- 2147483647)) 1))) 1 0)) 0 1)) (go ELSE6864))
    (progn (|c/invalid_usage| |c/string/184| |c/string/182|))
    (go ENDIF6865)
    ELSE6864
    ENDIF6865
    (progn (|c/internal_add| v-solver-6846 v-elit-6847))
  )
  0))

;;; upstream/satch.c:12174:1
(defun |c/satch_add_empty| (arg-v-solver-6869)
 (declare  (type c-address arg-v-solver-6869))
 (let ((v-solver-6869 0))
 (declare (type c-address v-solver-6869) (ignorable v-solver-6869))
 (tagbody
    (setf v-solver-6869 arg-v-solver-6869)
    (unless (c-true (if (c-true v-solver-6869) 0 1)) (go ELSE6873))
    (progn (|c/invalid_usage| |c/string/180| |c/string/185|))
    (go ENDIF6874)
    ELSE6873
    ENDIF6874
    (unless (c-true (if (c-true (if (c-true (m-u64 (+ (+ v-solver-6869 1016) 288))) 0 1)) 0 1)) (go ELSE6878))
    (progn (|c/invalid_usage| |c/string/183| |c/string/185|))
    (go ENDIF6879)
    ELSE6878
    ENDIF6879
    (progn (|c/internal_add| v-solver-6869 0))
  )
  0))

;;; upstream/satch.c:12182:1
(defun |c/satch_add_unit| (arg-v-solver-6880 arg-v-unit-6881)
 (declare  (type c-address arg-v-solver-6880) (type (signed-byte 32) arg-v-unit-6881))
 (let ((v-solver-6880 0) (v-unit-6881 0))
 (declare (type c-address v-solver-6880) (type (signed-byte 32) v-unit-6881) (ignorable v-solver-6880 v-unit-6881))
 (tagbody
    (setf v-solver-6880 arg-v-solver-6880)
    (setf v-unit-6881 arg-v-unit-6881)
    (unless (c-true (if (c-true v-solver-6880) 0 1)) (go ELSE6885))
    (progn (|c/invalid_usage| |c/string/180| |c/string/186|))
    (go ENDIF6886)
    ELSE6885
    ENDIF6886
    (unless (c-true (if (c-true (if (c-true (m-u64 (+ (+ v-solver-6880 1016) 288))) 0 1)) 0 1)) (go ELSE6890))
    (progn (|c/invalid_usage| |c/string/183| |c/string/186|))
    (go ENDIF6891)
    ELSE6890
    ENDIF6891
    (unless (c-true (if (c-true v-unit-6881) 0 1)) (go ELSE6898))
    (progn (|c/invalid_usage| |c/string/187| |c/string/186|))
    (go ENDIF6899)
    ELSE6898
    ENDIF6899
    (unless (c-true (if (c-true (if (/= v-unit-6881 (c-s32 (- (c-s32 (- 2147483647)) 1))) 1 0)) 0 1)) (go ELSE6903))
    (progn (|c/invalid_usage| |c/string/184| |c/string/186|))
    (go ENDIF6904)
    ELSE6903
    ENDIF6904
    (progn (|c/internal_add| v-solver-6880 v-unit-6881))
    (progn (|c/internal_add| v-solver-6880 0))
  )
  0))

;;; upstream/satch.c:12192:1
(defun |c/satch_add_binary_clause| (arg-v-solver-6905 arg-v-a-6906 arg-v-b-6907)
 (declare  (type c-address arg-v-solver-6905) (type (signed-byte 32) arg-v-a-6906) (type (signed-byte 32) arg-v-b-6907))
 (let ((v-solver-6905 0) (v-a-6906 0) (v-b-6907 0))
 (declare (type c-address v-solver-6905) (type (signed-byte 32) v-a-6906) (type (signed-byte 32) v-b-6907) (ignorable v-solver-6905 v-a-6906 v-b-6907))
 (tagbody
    (setf v-solver-6905 arg-v-solver-6905)
    (setf v-a-6906 arg-v-a-6906)
    (setf v-b-6907 arg-v-b-6907)
    (unless (c-true (if (c-true v-solver-6905) 0 1)) (go ELSE6911))
    (progn (|c/invalid_usage| |c/string/180| |c/string/188|))
    (go ENDIF6912)
    ELSE6911
    ENDIF6912
    (unless (c-true (if (c-true (if (c-true (m-u64 (+ (+ v-solver-6905 1016) 288))) 0 1)) 0 1)) (go ELSE6916))
    (progn (|c/invalid_usage| |c/string/183| |c/string/188|))
    (go ENDIF6917)
    ELSE6916
    ENDIF6917
    (unless (c-true (if (c-true v-a-6906) 0 1)) (go ELSE6924))
    (progn (|c/invalid_usage| |c/string/187| |c/string/188|))
    (go ENDIF6925)
    ELSE6924
    ENDIF6925
    (unless (c-true (if (c-true (if (/= v-a-6906 (c-s32 (- (c-s32 (- 2147483647)) 1))) 1 0)) 0 1)) (go ELSE6929))
    (progn (|c/invalid_usage| |c/string/184| |c/string/188|))
    (go ENDIF6930)
    ELSE6929
    ENDIF6930
    (unless (c-true (if (c-true v-b-6907) 0 1)) (go ELSE6937))
    (progn (|c/invalid_usage| |c/string/187| |c/string/188|))
    (go ENDIF6938)
    ELSE6937
    ENDIF6938
    (unless (c-true (if (c-true (if (/= v-b-6907 (c-s32 (- (c-s32 (- 2147483647)) 1))) 1 0)) 0 1)) (go ELSE6942))
    (progn (|c/invalid_usage| |c/string/184| |c/string/188|))
    (go ENDIF6943)
    ELSE6942
    ENDIF6943
    (progn (|c/internal_add| v-solver-6905 v-a-6906))
    (progn (|c/internal_add| v-solver-6905 v-b-6907))
    (progn (|c/internal_add| v-solver-6905 0))
  )
  0))

;;; upstream/satch.c:12204:1
(defun |c/satch_add_ternary_clause| (arg-v-solver-6944 arg-v-a-6945 arg-v-b-6946 arg-v-c-6947)
 (declare  (type c-address arg-v-solver-6944) (type (signed-byte 32) arg-v-a-6945) (type (signed-byte 32) arg-v-b-6946) (type (signed-byte 32) arg-v-c-6947))
 (let ((v-solver-6944 0) (v-a-6945 0) (v-b-6946 0) (v-c-6947 0))
 (declare (type c-address v-solver-6944) (type (signed-byte 32) v-a-6945) (type (signed-byte 32) v-b-6946) (type (signed-byte 32) v-c-6947) (ignorable v-solver-6944 v-a-6945 v-b-6946 v-c-6947))
 (tagbody
    (setf v-solver-6944 arg-v-solver-6944)
    (setf v-a-6945 arg-v-a-6945)
    (setf v-b-6946 arg-v-b-6946)
    (setf v-c-6947 arg-v-c-6947)
    (unless (c-true (if (c-true v-solver-6944) 0 1)) (go ELSE6951))
    (progn (|c/invalid_usage| |c/string/180| |c/string/189|))
    (go ENDIF6952)
    ELSE6951
    ENDIF6952
    (unless (c-true (if (c-true (if (c-true (m-u64 (+ (+ v-solver-6944 1016) 288))) 0 1)) 0 1)) (go ELSE6956))
    (progn (|c/invalid_usage| |c/string/183| |c/string/189|))
    (go ENDIF6957)
    ELSE6956
    ENDIF6957
    (unless (c-true (if (c-true v-a-6945) 0 1)) (go ELSE6964))
    (progn (|c/invalid_usage| |c/string/187| |c/string/189|))
    (go ENDIF6965)
    ELSE6964
    ENDIF6965
    (unless (c-true (if (c-true (if (/= v-a-6945 (c-s32 (- (c-s32 (- 2147483647)) 1))) 1 0)) 0 1)) (go ELSE6969))
    (progn (|c/invalid_usage| |c/string/184| |c/string/189|))
    (go ENDIF6970)
    ELSE6969
    ENDIF6970
    (unless (c-true (if (c-true v-b-6946) 0 1)) (go ELSE6977))
    (progn (|c/invalid_usage| |c/string/187| |c/string/189|))
    (go ENDIF6978)
    ELSE6977
    ENDIF6978
    (unless (c-true (if (c-true (if (/= v-b-6946 (c-s32 (- (c-s32 (- 2147483647)) 1))) 1 0)) 0 1)) (go ELSE6982))
    (progn (|c/invalid_usage| |c/string/184| |c/string/189|))
    (go ENDIF6983)
    ELSE6982
    ENDIF6983
    (unless (c-true (if (c-true v-c-6947) 0 1)) (go ELSE6990))
    (progn (|c/invalid_usage| |c/string/187| |c/string/189|))
    (go ENDIF6991)
    ELSE6990
    ENDIF6991
    (unless (c-true (if (c-true (if (/= v-c-6947 (c-s32 (- (c-s32 (- 2147483647)) 1))) 1 0)) 0 1)) (go ELSE6995))
    (progn (|c/invalid_usage| |c/string/184| |c/string/189|))
    (go ENDIF6996)
    ELSE6995
    ENDIF6996
    (progn (|c/internal_add| v-solver-6944 v-a-6945))
    (progn (|c/internal_add| v-solver-6944 v-b-6946))
    (progn (|c/internal_add| v-solver-6944 v-c-6947))
    (progn (|c/internal_add| v-solver-6944 0))
  )
  0))

;;; upstream/satch.c:12218:1
(defun |c/satch_add_quaternary_clause| (arg-v-solver-6997 arg-v-a-6998 arg-v-b-6999 arg-v-c-7000 arg-v-d-7001)
 (declare  (type c-address arg-v-solver-6997) (type (signed-byte 32) arg-v-a-6998) (type (signed-byte 32) arg-v-b-6999) (type (signed-byte 32) arg-v-c-7000) (type (signed-byte 32) arg-v-d-7001))
 (let ((v-solver-6997 0) (v-a-6998 0) (v-b-6999 0) (v-c-7000 0) (v-d-7001 0))
 (declare (type c-address v-solver-6997) (type (signed-byte 32) v-a-6998) (type (signed-byte 32) v-b-6999) (type (signed-byte 32) v-c-7000) (type (signed-byte 32) v-d-7001) (ignorable v-solver-6997 v-a-6998 v-b-6999 v-c-7000 v-d-7001))
 (tagbody
    (setf v-solver-6997 arg-v-solver-6997)
    (setf v-a-6998 arg-v-a-6998)
    (setf v-b-6999 arg-v-b-6999)
    (setf v-c-7000 arg-v-c-7000)
    (setf v-d-7001 arg-v-d-7001)
    (unless (c-true (if (c-true v-solver-6997) 0 1)) (go ELSE7005))
    (progn (|c/invalid_usage| |c/string/180| |c/string/190|))
    (go ENDIF7006)
    ELSE7005
    ENDIF7006
    (unless (c-true (if (c-true (if (c-true (m-u64 (+ (+ v-solver-6997 1016) 288))) 0 1)) 0 1)) (go ELSE7010))
    (progn (|c/invalid_usage| |c/string/183| |c/string/190|))
    (go ENDIF7011)
    ELSE7010
    ENDIF7011
    (unless (c-true (if (c-true v-a-6998) 0 1)) (go ELSE7018))
    (progn (|c/invalid_usage| |c/string/187| |c/string/190|))
    (go ENDIF7019)
    ELSE7018
    ENDIF7019
    (unless (c-true (if (c-true (if (/= v-a-6998 (c-s32 (- (c-s32 (- 2147483647)) 1))) 1 0)) 0 1)) (go ELSE7023))
    (progn (|c/invalid_usage| |c/string/184| |c/string/190|))
    (go ENDIF7024)
    ELSE7023
    ENDIF7024
    (unless (c-true (if (c-true v-b-6999) 0 1)) (go ELSE7031))
    (progn (|c/invalid_usage| |c/string/187| |c/string/190|))
    (go ENDIF7032)
    ELSE7031
    ENDIF7032
    (unless (c-true (if (c-true (if (/= v-b-6999 (c-s32 (- (c-s32 (- 2147483647)) 1))) 1 0)) 0 1)) (go ELSE7036))
    (progn (|c/invalid_usage| |c/string/184| |c/string/190|))
    (go ENDIF7037)
    ELSE7036
    ENDIF7037
    (unless (c-true (if (c-true v-c-7000) 0 1)) (go ELSE7044))
    (progn (|c/invalid_usage| |c/string/187| |c/string/190|))
    (go ENDIF7045)
    ELSE7044
    ENDIF7045
    (unless (c-true (if (c-true (if (/= v-c-7000 (c-s32 (- (c-s32 (- 2147483647)) 1))) 1 0)) 0 1)) (go ELSE7049))
    (progn (|c/invalid_usage| |c/string/184| |c/string/190|))
    (go ENDIF7050)
    ELSE7049
    ENDIF7050
    (unless (c-true (if (c-true v-d-7001) 0 1)) (go ELSE7057))
    (progn (|c/invalid_usage| |c/string/187| |c/string/190|))
    (go ENDIF7058)
    ELSE7057
    ENDIF7058
    (unless (c-true (if (c-true (if (/= v-d-7001 (c-s32 (- (c-s32 (- 2147483647)) 1))) 1 0)) 0 1)) (go ELSE7062))
    (progn (|c/invalid_usage| |c/string/184| |c/string/190|))
    (go ENDIF7063)
    ELSE7062
    ENDIF7063
    (progn (|c/internal_add| v-solver-6997 v-a-6998))
    (progn (|c/internal_add| v-solver-6997 v-b-6999))
    (progn (|c/internal_add| v-solver-6997 v-c-7000))
    (progn (|c/internal_add| v-solver-6997 v-d-7001))
    (progn (|c/internal_add| v-solver-6997 0))
  )
  0))

;;; upstream/satch.c:12240:1
(defun |c/satch_reserve| (arg-v-solver-7064 arg-v-max_var-7065)
 (declare  (type c-address arg-v-solver-7064) (type (signed-byte 32) arg-v-max_var-7065))
 (let ((v-solver-7064 0) (v-max_var-7065 0) (v-requested_capacity-7071 0))
 (declare (type c-address v-solver-7064) (type (signed-byte 32) v-max_var-7065) (type c-size v-requested_capacity-7071) (ignorable v-solver-7064 v-max_var-7065 v-requested_capacity-7071))
 (tagbody
    (setf v-solver-7064 arg-v-solver-7064)
    (setf v-max_var-7065 arg-v-max_var-7065)
    (unless (c-true (if (c-true v-solver-7064) 0 1)) (go ELSE7069))
    (progn (|c/invalid_usage| |c/string/180| |c/string/191|))
    (go ENDIF7070)
    ELSE7069
    ENDIF7070
    (setf v-requested_capacity-7071 (c-u64 v-max_var-7065))
    (unless (c-true (if (> v-requested_capacity-7071 (m-size (+ v-solver-7064 16))) 1 0)) (go ELSE7072))
    (progn (|c/increase_capacity| v-solver-7064 (c-u32 v-requested_capacity-7071)))
    (go ENDIF7073)
    ELSE7072
    ENDIF7073
  )
  0))

;;; upstream/satch.c:12250:1
(defun |c/satch_maximum_variable| (arg-v-solver-7074)
 (declare  (type c-address arg-v-solver-7074))
 (let ((v-solver-7074 0))
 (declare (type c-address v-solver-7074) (ignorable v-solver-7074))
 (tagbody
    (setf v-solver-7074 arg-v-solver-7074)
    (unless (c-true (if (c-true v-solver-7074) 0 1)) (go ELSE7078))
    (progn (|c/invalid_usage| |c/string/180| |c/string/192|))
    (go ENDIF7079)
    ELSE7078
    ENDIF7079
    (return-from |c/satch_maximum_variable| (c-s32 (m-u32 (+ v-solver-7074 12))))
  )
  0))

;;; upstream/satch.c:12266:1
(defun |c/satch_val| (arg-v-solver-7080 arg-v-elit-7081)
 (declare  (type c-address arg-v-solver-7080) (type (signed-byte 32) arg-v-elit-7081))
 (let ((v-solver-7080 0) (v-elit-7081 0) (v-eidx-7105 0) (v-iidx-7106 0) (v-ilit-7109 0) (v-tmp-7110 0) (v-res-7113 0))
 (declare (type c-address v-solver-7080) (type (signed-byte 32) v-elit-7081) (type (signed-byte 32) v-eidx-7105) (type (unsigned-byte 32) v-iidx-7106) (type (unsigned-byte 32) v-ilit-7109) (type (signed-byte 8) v-tmp-7110) (type (signed-byte 32) v-res-7113) (ignorable v-solver-7080 v-elit-7081 v-eidx-7105 v-iidx-7106 v-ilit-7109 v-tmp-7110 v-res-7113))
 (tagbody
    (setf v-solver-7080 arg-v-solver-7080)
    (setf v-elit-7081 arg-v-elit-7081)
    (unless (c-true (if (c-true v-solver-7080) 0 1)) (go ELSE7085))
    (progn (|c/invalid_usage| |c/string/180| |c/string/193|))
    (go ENDIF7086)
    ELSE7085
    ENDIF7086
    (unless (c-true (if (c-true v-elit-7081) 0 1)) (go ELSE7093))
    (progn (|c/invalid_usage| |c/string/187| |c/string/193|))
    (go ENDIF7094)
    ELSE7093
    ENDIF7094
    (unless (c-true (if (c-true (if (/= v-elit-7081 (c-s32 (- (c-s32 (- 2147483647)) 1))) 1 0)) 0 1)) (go ELSE7098))
    (progn (|c/invalid_usage| |c/string/184| |c/string/193|))
    (go ENDIF7099)
    ELSE7098
    ENDIF7099
    (unless (c-true (if (c-true (if (= (m-s32 (+ v-solver-7080 0)) 10) 1 0)) 0 1)) (go ELSE7103))
    (progn (|c/invalid_usage| (if (c-true (if (= (m-s32 (+ v-solver-7080 0)) 20) 1 0)) |c/string/194| (if (c-true (if (c-true (m-s32 (+ v-solver-7080 0))) 0 1)) |c/string/195| |c/string/196|)) |c/string/193|))
    (go ENDIF7104)
    ELSE7103
    ENDIF7104
    (setf v-eidx-7105 (c-abs v-elit-7081))
    (setf v-iidx-7106 (c-u32 (c-s32 (- v-eidx-7105 1))))
    (unless (c-true (if (>= v-iidx-7106 (m-u32 (+ v-solver-7080 12))) 1 0)) (go ELSE7107))
    (return-from |c/satch_val| v-eidx-7105)
    ELSE7107
    (setf v-ilit-7109 (|c/LITERAL| v-iidx-7106))
    (setf v-tmp-7110 (m-s8 (+ (m-ptr (+ v-solver-7080 40)) (* 1 v-ilit-7109))))
    (unless (c-true (if (c-true v-tmp-7110) 0 1)) (go ELSE7111))
    (return-from |c/satch_val| v-eidx-7105)
    ELSE7111
    (setf v-res-7113 (if (c-true (if (> v-tmp-7110 0) 1 0)) v-elit-7081 (c-s32 (- v-elit-7081))))
    (unless (c-true (if (< v-elit-7081 0) 1 0)) (go ELSE7114))
    (progn (setf v-res-7113 (c-s32 (- v-res-7113))))
    (go ENDIF7115)
    ELSE7114
    ENDIF7115
    (return-from |c/satch_val| v-res-7113)
  )
  0))

;;; upstream/satch.c:12294:1
(defun |c/satch_solve| (arg-v-solver-7116 arg-v-conflict_limit-7117)
 (declare  (type c-address arg-v-solver-7116) (type (signed-byte 32) arg-v-conflict_limit-7117))
 (let ((v-solver-7116 0) (v-conflict_limit-7117 0) (v-res-7137 0))
 (declare (type c-address v-solver-7116) (type (signed-byte 32) v-conflict_limit-7117) (type (signed-byte 32) v-res-7137) (ignorable v-solver-7116 v-conflict_limit-7117 v-res-7137))
 (tagbody
    (setf v-solver-7116 arg-v-solver-7116)
    (setf v-conflict_limit-7117 arg-v-conflict_limit-7117)
    (unless (c-true (if (c-true v-solver-7116) 0 1)) (go ELSE7121))
    (progn (|c/invalid_usage| |c/string/180| |c/string/197|))
    (go ENDIF7122)
    ELSE7121
    ENDIF7122
    (unless (c-true (if (c-true (if (= (m-ptr (+ (+ v-solver-7116 624) 8)) (m-ptr (+ (+ v-solver-7116 624) 0))) 1 0)) 0 1)) (go ELSE7126))
    (progn (|c/invalid_usage| |c/string/198| |c/string/197|))
    (go ENDIF7127)
    ELSE7126
    ENDIF7127
    (unless (c-true (if (c-true (if (c-true (m-s32 (+ v-solver-7116 0))) 0 1)) 0 1)) (go ELSE7131))
    (progn (|c/invalid_usage| |c/string/199| |c/string/197|))
    (go ENDIF7132)
    ELSE7131
    ENDIF7132
    (progn (progn 0 (let* ((a7133 (+ (+ v-solver-7116 1016) 288)) (old7134 (m-u64 a7133))) (setf (m-u64 a7133) (c-u64 (c-u64 (+ old7134 (c-u64 1))))) (m-u64 a7133))))
    (unless (c-true (m-u32 (+ (+ v-solver-7116 880) 4))) (go ELSE7135))
    (progn (|c/internal_section| v-solver-7116 |c/string/200|))
    (go ENDIF7136)
    ELSE7135
    ENDIF7136
    (setf v-res-7137 (|c/solve| v-solver-7116 v-conflict_limit-7117))
    (progn v-solver-7116)
    (progn (setf (m-s32 (+ v-solver-7116 0)) v-res-7137))
    (unless (c-true (if (= v-res-7137 10) 1 0)) (go ELSE7141))
    (progn (|c/extend_solution| v-solver-7116))
    (go ENDIF7142)
    ELSE7141
    ENDIF7142
    (return-from |c/satch_solve| v-res-7137)
  )
  0))

;;; upstream/satch.c:12322:1
(defun |c/satch_set_verbose_level| (arg-v-solver-7143 arg-v-new_verbose_level-7144)
 (declare  (type c-address arg-v-solver-7143) (type (signed-byte 32) arg-v-new_verbose_level-7144))
 (let ((v-solver-7143 0) (v-new_verbose_level-7144 0))
 (declare (type c-address v-solver-7143) (type (signed-byte 32) v-new_verbose_level-7144) (ignorable v-solver-7143 v-new_verbose_level-7144))
 (tagbody
    (setf v-solver-7143 arg-v-solver-7143)
    (setf v-new_verbose_level-7144 arg-v-new_verbose_level-7144)
    (unless (c-true (if (c-true v-solver-7143) 0 1)) (go ELSE7148))
    (progn (|c/invalid_usage| |c/string/180| |c/string/201|))
    (go ENDIF7149)
    ELSE7148
    ENDIF7149
    (unless (c-true (if (< v-new_verbose_level-7144 0) 1 0)) (go ELSE7150))
    (progn (setf v-new_verbose_level-7144 0))
    (go ENDIF7151)
    ELSE7150
    ENDIF7151
    (progn (setf (m-u32 (+ (+ v-solver-7143 880) 4)) (c-u32 v-new_verbose_level-7144)))
  )
  0))

;;; upstream/satch.c:12335:1
(defun |c/satch_enable_logging_messages| (arg-v-solver-7152)
 (declare  (type c-address arg-v-solver-7152))
 (let ((v-solver-7152 0))
 (declare (type c-address v-solver-7152) (ignorable v-solver-7152))
 (tagbody
    (setf v-solver-7152 arg-v-solver-7152)
    (unless (c-true (if (c-true v-solver-7152) 0 1)) (go ELSE7156))
    (progn (|c/invalid_usage| |c/string/180| |c/string/202|))
    (go ENDIF7157)
    ELSE7156
    ENDIF7157
    (progn (setf (m-u32 (+ (+ v-solver-7152 880) 4)) (c-u32 2147483647)))
  )
  0))

;;; upstream/satch.c:12349:1
(defun |c/satch_ascii_proof| (arg-v-solver-7158)
 (declare  (type c-address arg-v-solver-7158))
 (let ((v-solver-7158 0))
 (declare (type c-address v-solver-7158) (ignorable v-solver-7158))
 (tagbody
    (setf v-solver-7158 arg-v-solver-7158)
    (unless (c-true (if (c-true v-solver-7158) 0 1)) (go ELSE7162))
    (progn (|c/invalid_usage| |c/string/180| |c/string/203|))
    (go ENDIF7163)
    ELSE7162
    ENDIF7163
    (progn (setf (m-u8 (+ (+ v-solver-7158 880) 0)) (c-bool 1)))
  )
  0))

;;; upstream/satch.c:12356:1
(defun |c/satch_trace_proof| (arg-v-solver-7164 arg-v-proof-7165)
 (declare  (type c-address arg-v-solver-7164) (type c-address arg-v-proof-7165))
 (let ((v-solver-7164 0) (v-proof-7165 0))
 (declare (type c-address v-solver-7164) (type c-address v-proof-7165) (ignorable v-solver-7164 v-proof-7165))
 (tagbody
    (setf v-solver-7164 arg-v-solver-7164)
    (setf v-proof-7165 arg-v-proof-7165)
    (unless (c-true (if (c-true v-solver-7164) 0 1)) (go ELSE7169))
    (progn (|c/invalid_usage| |c/string/180| |c/string/204|))
    (go ENDIF7170)
    ELSE7169
    ENDIF7170
    (progn (setf (m-ptr (+ v-solver-7164 1896)) v-proof-7165))
  )
  0))

;;; upstream/satch.c:12365:1
(defun |c/satch_process_time| ()
 (declare (optimize (speed 1) (safety 1)) )
 (let ()
 
 (tagbody
    (return-from |c/satch_process_time| (|c/process_time|))
  )
  0))

;;; upstream/satch.c:12371:1
(defun |c/satch_start_profiling_parsing| (arg-v-solver-7171)
 (declare  (type c-address arg-v-solver-7171))
 (let ((v-solver-7171 0))
 (declare (type c-address v-solver-7171) (ignorable v-solver-7171))
 (tagbody
    (setf v-solver-7171 arg-v-solver-7171)
    (unless (c-true (if (c-true v-solver-7171) 0 1)) (go ELSE7175))
    (progn (|c/invalid_usage| |c/string/180| |c/string/205|))
    (go ENDIF7176)
    ELSE7175
    ENDIF7176
    (progn (|c/start_profiling| v-solver-7171 (+ (+ v-solver-7171 1472) 48)))
  )
  0))

