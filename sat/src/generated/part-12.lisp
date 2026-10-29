(in-package #:ooparts/sat/impl)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))
;;; upstream/satch.c:10322:1
(defun |c/vivify_mark_garbage| (arg-v-solver-5646 arg-v-c-5647 arg-v-msg-5648)
 (declare  (type c-address arg-v-solver-5646) (type c-address arg-v-c-5647) (type c-address arg-v-msg-5648))
 (let ((v-solver-5646 0) (v-c-5647 0) (v-msg-5648 0))
 (declare (type c-address v-solver-5646) (type c-address v-c-5647) (type c-address v-msg-5648) (ignorable v-solver-5646 v-c-5647 v-msg-5648))
 (tagbody
    (setf v-solver-5646 arg-v-solver-5646)
    (setf v-c-5647 arg-v-c-5647)
    (setf v-msg-5648 arg-v-msg-5648)
    (progn (|c/unwatch_literal| v-solver-5646 (m-u32 (+ (+ v-c-5647 16) (* 4 0))) v-c-5647))
    (progn (|c/unwatch_literal| v-solver-5646 (m-u32 (+ (+ v-c-5647 16) (* 4 1))) v-c-5647))
    (progn (|c/mark_garbage| v-solver-5646 v-c-5647 v-msg-5648))
  )
  0))

;;; upstream/satch.c:10336:1
(defun |c/vivify_learn| (arg-v-solver-5649 arg-v-c-5650 arg-v-non_false-5651 arg-v-irredundant-5652 arg-v-implied-5653)
 (declare  (notinline checked-address) (type c-address arg-v-solver-5649) (type c-address arg-v-c-5650) (type (unsigned-byte 32) arg-v-non_false-5651) (type (integer 0 1) arg-v-irredundant-5652) (type (unsigned-byte 32) arg-v-implied-5653))
 (let ((v-solver-5649 0) (v-c-5650 0) (v-non_false-5651 0) (v-irredundant-5652 0) (v-implied-5653 0) (v-res-5654 0) (v-size-5655 0) (v-unit-5663 0) (v-conflict-5664 0) (v-levels-5672 0) (v-values-5673 0) (v-highest_level-5674 0) (v-lit-5678 0) (v-PTR_lit-5679 0) (v-END_lit-5680 0) (v-value-5681 0) (v-idx-5687 0) (v-level-5688 0) (v-literals_on_highest_level-5698 0) (v-lit-5702 0) (v-PTR_lit-5703 0) (v-END_lit-5704 0) (v-value-5705 0) (v-idx-5710 0) (v-level-5711 0) (v-jump_level-5723 0) (v-lit-5727 0) (v-PTR_lit-5728 0) (v-END_lit-5729 0) (v-value-5730 0) (v-idx-5733 0) (v-level-5734 0) (v-redundant-5748 0) (v-old_size-5759 0) (v-new_size-5760 0) (v-lits-5761 0) (v-litA-5762 0) (v-litB-5763 0) (v-i-5767 0) (v-lit-5768 0) (v-old_size-5777 0) (v-old_capacity-5778 0) (v-new_capacity-5779 0) (v-new_bytes-5780 0) (v-keep-5785 0) (v-idx-5788 0) (v-mark-5789 0) (v-old_size-5828 0) (v-old_capacity-5829 0) (v-new_capacity-5830 0) (v-new_bytes-5831 0) (v-old_size-5844 0) (v-old_capacity-5845 0) (v-new_capacity-5846 0) (v-new_bytes-5847 0))
 (declare (type c-address v-solver-5649) (type c-address v-c-5650) (type (unsigned-byte 32) v-non_false-5651) (type (integer 0 1) v-irredundant-5652) (type (unsigned-byte 32) v-implied-5653) (type (integer 0 1) v-res-5654) (type c-size v-size-5655) (type (unsigned-byte 32) v-unit-5663) (type c-address v-conflict-5664) (type c-address v-levels-5672) (type c-address v-values-5673) (type (unsigned-byte 32) v-highest_level-5674) (type (unsigned-byte 32) v-lit-5678) (type c-address v-PTR_lit-5679) (type c-address v-END_lit-5680) (type (signed-byte 8) v-value-5681) (type (unsigned-byte 32) v-idx-5687) (type (unsigned-byte 32) v-level-5688) (type (unsigned-byte 32) v-literals_on_highest_level-5698) (type (unsigned-byte 32) v-lit-5702) (type c-address v-PTR_lit-5703) (type c-address v-END_lit-5704) (type (unsigned-byte 32) v-value-5705) (type (unsigned-byte 32) v-idx-5710) (type (unsigned-byte 32) v-level-5711) (type (unsigned-byte 32) v-jump_level-5723) (type (unsigned-byte 32) v-lit-5727) (type c-address v-PTR_lit-5728) (type c-address v-END_lit-5729) (type (signed-byte 8) v-value-5730) (type (unsigned-byte 32) v-idx-5733) (type (unsigned-byte 32) v-level-5734) (type (integer 0 1) v-redundant-5748) (type (unsigned-byte 32) v-old_size-5759) (type (unsigned-byte 32) v-new_size-5760) (type c-address v-lits-5761) (type (unsigned-byte 32) v-litA-5762) (type (unsigned-byte 32) v-litB-5763) (type (unsigned-byte 32) v-i-5767) (type (unsigned-byte 32) v-lit-5768) (type c-size v-old_size-5777) (type c-size v-old_capacity-5778) (type c-size v-new_capacity-5779) (type c-size v-new_bytes-5780) (type (integer 0 1) v-keep-5785) (type (unsigned-byte 32) v-idx-5788) (type (signed-byte 8) v-mark-5789) (type c-size v-old_size-5828) (type c-size v-old_capacity-5829) (type c-size v-new_capacity-5830) (type c-size v-new_bytes-5831) (type c-size v-old_size-5844) (type c-size v-old_capacity-5845) (type c-size v-new_capacity-5846) (type c-size v-new_bytes-5847) (ignorable v-solver-5649 v-c-5650 v-non_false-5651 v-irredundant-5652 v-implied-5653 v-res-5654 v-size-5655 v-unit-5663 v-conflict-5664 v-levels-5672 v-values-5673 v-highest_level-5674 v-lit-5678 v-PTR_lit-5679 v-END_lit-5680 v-value-5681 v-idx-5687 v-level-5688 v-literals_on_highest_level-5698 v-lit-5702 v-PTR_lit-5703 v-END_lit-5704 v-value-5705 v-idx-5710 v-level-5711 v-jump_level-5723 v-lit-5727 v-PTR_lit-5728 v-END_lit-5729 v-value-5730 v-idx-5733 v-level-5734 v-redundant-5748 v-old_size-5759 v-new_size-5760 v-lits-5761 v-litA-5762 v-litB-5763 v-i-5767 v-lit-5768 v-old_size-5777 v-old_capacity-5778 v-new_capacity-5779 v-new_bytes-5780 v-keep-5785 v-idx-5788 v-mark-5789 v-old_size-5828 v-old_capacity-5829 v-new_capacity-5830 v-new_bytes-5831 v-old_size-5844 v-old_capacity-5845 v-new_capacity-5846 v-new_bytes-5847))
 (tagbody
    (setf v-solver-5649 arg-v-solver-5649)
    (setf v-c-5650 arg-v-c-5650)
    (setf v-non_false-5651 arg-v-non_false-5651)
    (setf v-irredundant-5652 arg-v-irredundant-5652)
    (setf v-implied-5653 arg-v-implied-5653)
    (setf v-size-5655 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5649 624) 8)) (m-ptr (+ (+ v-solver-5649 624) 0))) 4)))
    (unless (c-true (if (= v-size-5655 (c-u64 1)) 1 0)) (go ELSE5656))
    (progn v-solver-5649)
    (unless (c-true (m-u32 (+ v-solver-5649 8))) (go ELSE5661))
    (progn (|c/backtrack| v-solver-5649 (c-u32 0)))
    (go ENDIF5662)
    ELSE5661
    ENDIF5662
    (setf v-unit-5663 (m-u32 (+ (m-ptr (+ (+ v-solver-5649 624) 0)) (* 4 (progn 0 0)))))
    (progn (|c/assign| v-solver-5649 v-unit-5663 0 (c-bool 1)))
    (progn (setf (m-u8 (+ v-solver-5649 5)) (c-bool 1)))
    (progn (|c/vivify_mark_garbage| v-solver-5649 v-c-5650 |c/string/167|))
    (setf v-conflict-5664 (|c/boolean_constraint_propagation| v-solver-5649))
    (unless (c-true v-conflict-5664) (go ELSE5665))
    (progn v-solver-5649)
    (progn (setf (m-u8 (+ v-solver-5649 4)) (c-bool 1)))
    (return-from |c/vivify_learn| (c-bool 0))
    ELSE5665
    (progn (progn 0 (let* ((a5670 (+ (+ v-solver-5649 1016) 392)) (old5671 (m-u64 a5670))) (setf (m-u64 a5670) (c-u64 (c-u64 (+ old5671 (c-u64 1))))) (m-u64 a5670))))
    (progn (setf v-res-5654 (c-bool 1)))
    (go ENDIF5657)
    ELSE5656
    (setf v-levels-5672 (m-ptr (+ v-solver-5649 32)))
    (setf v-values-5673 (m-ptr (+ v-solver-5649 40)))
    (setf v-highest_level-5674 (c-u32 0))
    (setf v-PTR_lit-5679 (m-ptr (+ (+ v-solver-5649 624) 0)))
    (setf v-END_lit-5680 (m-ptr (+ (+ v-solver-5649 624) 8)))
    LOOP5675
    (unless (c-true (if (c-true (if (/= v-PTR_lit-5679 v-END_lit-5680) 1 0)) (c-bool (progn (setf v-lit-5678 (m-u32 v-PTR_lit-5679)) 1)) 0)) (go ENDLOOP5676))
    (setf v-value-5681 (m-s8 (+ v-values-5673 (* 1 v-lit-5678))))
    (unless (c-true (if (c-true v-value-5681) 0 1)) (go ELSE5682))
    (progn v-solver-5649)
    (progn (setf v-highest_level-5674 4294967295))
    (go ENDLOOP5676)
    ELSE5682
    (setf v-idx-5687 (|c/INDEX| v-lit-5678))
    (setf v-level-5688 (m-u32 (+ v-levels-5672 (* 4 v-idx-5687))))
    (unless (c-true (if (> v-level-5688 v-highest_level-5674) 1 0)) (go ELSE5689))
    (progn (setf v-highest_level-5674 v-level-5688))
    (go ENDIF5690)
    ELSE5689
    ENDIF5690
    (let* ( (old5692 v-PTR_lit-5679)) (setf v-PTR_lit-5679 (+ old5692 (* 4 1))) v-PTR_lit-5679)
    (go LOOP5675)
    ENDLOOP5676
    (unless (c-true (if (/= v-highest_level-5674 4294967295) 1 0)) (go ELSE5693))
    (progn v-solver-5649)
    (go ENDIF5694)
    ELSE5693
    ENDIF5694
    (setf v-literals_on_highest_level-5698 (c-u32 0))
    (setf v-PTR_lit-5703 (m-ptr (+ (+ v-solver-5649 624) 0)))
    (setf v-END_lit-5704 (m-ptr (+ (+ v-solver-5649 624) 8)))
    LOOP5699
    (unless (c-true (if (c-true (if (/= v-PTR_lit-5703 v-END_lit-5704) 1 0)) (c-bool (progn (setf v-lit-5702 (m-u32 v-PTR_lit-5703)) 1)) 0)) (go ENDLOOP5700))
    (setf v-value-5705 (c-u32 (m-s8 (+ v-values-5673 (* 1 v-lit-5702)))))
    (unless (c-true (if (c-true v-value-5705) 0 1)) (go ELSE5706))
    (progn (let* ( (old5709 v-literals_on_highest_level-5698)) (setf v-literals_on_highest_level-5698 (c-u32 (c-u32 (+ old5709 (c-u32 1))))) old5709))
    (go ENDIF5707)
    ELSE5706
    (setf v-idx-5710 (|c/INDEX| v-lit-5702))
    (setf v-level-5711 (m-u32 (+ v-levels-5672 (* 4 v-idx-5710))))
    (unless (c-true (if (= v-level-5711 v-highest_level-5674) 1 0)) (go ELSE5712))
    (progn (let* ( (old5715 v-literals_on_highest_level-5698)) (setf v-literals_on_highest_level-5698 (c-u32 (c-u32 (+ old5715 (c-u32 1))))) old5715))
    (go ENDIF5713)
    ELSE5712
    ENDIF5713
    ENDIF5707
    (let* ( (old5717 v-PTR_lit-5703)) (setf v-PTR_lit-5703 (+ old5717 (* 4 1))) v-PTR_lit-5703)
    (go LOOP5699)
    ENDLOOP5700
    (unless (c-true (if (c-true (if (= v-highest_level-5674 4294967295) 1 0)) (c-bool (if (> v-literals_on_highest_level-5698 (c-u32 1)) 1 0)) 0)) (go ELSE5718))
    (progn v-solver-5649)
    (go ENDIF5719)
    ELSE5718
    (setf v-jump_level-5723 (c-u32 0))
    (setf v-PTR_lit-5728 (m-ptr (+ (+ v-solver-5649 624) 0)))
    (setf v-END_lit-5729 (m-ptr (+ (+ v-solver-5649 624) 8)))
    LOOP5724
    (unless (c-true (if (c-true (if (/= v-PTR_lit-5728 v-END_lit-5729) 1 0)) (c-bool (progn (setf v-lit-5727 (m-u32 v-PTR_lit-5728)) 1)) 0)) (go ENDLOOP5725))
    (setf v-value-5730 (m-s8 (+ v-values-5673 (* 1 v-lit-5727))))
    (unless (c-true (if (c-true v-value-5730) 0 1)) (go ELSE5731))
    (go CONTINUE5726)
    ELSE5731
    (setf v-idx-5733 (|c/INDEX| v-lit-5727))
    (setf v-level-5734 (m-u32 (+ v-levels-5672 (* 4 v-idx-5733))))
    (unless (c-true (if (= v-level-5734 v-highest_level-5674) 1 0)) (go ELSE5735))
    (go CONTINUE5726)
    ELSE5735
    (unless (c-true (if (> v-level-5734 v-jump_level-5723) 1 0)) (go ELSE5737))
    (progn (setf v-jump_level-5723 v-level-5734))
    (go ENDIF5738)
    ELSE5737
    ENDIF5738
    CONTINUE5726
    (let* ( (old5740 v-PTR_lit-5728)) (setf v-PTR_lit-5728 (+ old5740 (* 4 1))) v-PTR_lit-5728)
    (go LOOP5724)
    ENDLOOP5725
    (progn v-solver-5649)
    (unless (c-true (if (< v-jump_level-5723 (m-u32 (+ v-solver-5649 8))) 1 0)) (go ELSE5744))
    (progn (|c/backtrack| v-solver-5649 v-jump_level-5723))
    (go ENDIF5745)
    ELSE5744
    ENDIF5745
    ENDIF5719
    (unless (c-true (if (= v-size-5655 (c-u64 2)) 1 0)) (go ELSE5746))
    (setf v-redundant-5748 (c-bool (ldb (byte 1 2) (m-u8 (+ v-c-5650 0)))))
    (progn v-solver-5649)
    (progn (|c/trace_and_check_temporary_addition| v-solver-5649))
    (progn (|c/add_new_binary_and_watch_it| v-solver-5649 (c-bool v-redundant-5748)))
    (progn (|c/vivify_mark_garbage| v-solver-5649 v-c-5650 |c/string/168|))
    (progn (progn 0 (let* ((a5752 (+ (+ v-solver-5649 1016) 392)) (old5753 (m-u64 a5752))) (setf (m-u64 a5752) (c-u64 (c-u64 (+ old5753 (c-u64 1))))) (m-u64 a5752))))
    (progn (setf v-res-5654 (c-bool 1)))
    (go ENDIF5747)
    ELSE5746
    (unless (c-true (if (< v-size-5655 v-non_false-5651) 1 0)) (go ELSE5754))
    (progn (setf (m-ptr (+ (+ v-solver-5649 624) 8)) (m-ptr (+ (+ v-solver-5649 624) 0))))
    (setf v-old_size-5759 (m-u32 (+ v-c-5650 12)))
    (setf v-new_size-5760 (c-u32 0))
    (setf v-lits-5761 (+ v-c-5650 16))
    (setf v-litA-5762 (m-u32 (+ v-lits-5761 (* 4 0))))
    (setf v-litB-5763 (m-u32 (+ v-lits-5761 (* 4 1))))
    (setf v-i-5767 (c-u32 0))
    LOOP5764
    (unless (c-true (if (< v-i-5767 v-old_size-5759) 1 0)) (go ENDLOOP5765))
    (setf v-lit-5768 (m-u32 (+ v-lits-5761 (* 4 v-i-5767))))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-5649 624) 8)) (m-ptr (+ (+ v-solver-5649 624) 16))) 1 0)) (go ELSE5772))
    (setf v-old_size-5777 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5649 624) 8)) (m-ptr (+ (+ v-solver-5649 624) 0))) 4)))
    (setf v-old_capacity-5778 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5649 624) 16)) (m-ptr (+ (+ v-solver-5649 624) 0))) 4)))
    (setf v-new_capacity-5779 (if (c-true v-old_capacity-5778) (c-u64 (* (c-u64 2) v-old_capacity-5778)) (c-u64 1)))
    (setf v-new_bytes-5780 (c-u64 (* v-new_capacity-5779 4)))
    (progn (setf (m-ptr (+ (+ v-solver-5649 624) 0)) (c-realloc (m-ptr (+ (+ v-solver-5649 624) 0)) v-new_bytes-5780)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-5649 624) 0))) 0 1)) (go ELSE5781))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-5780))
    (go ENDIF5782)
    ELSE5781
    ENDIF5782
    (progn (setf (m-ptr (+ (+ v-solver-5649 624) 8)) (+ (m-ptr (+ (+ v-solver-5649 624) 0)) (* 4 v-old_size-5777))))
    (progn (setf (m-ptr (+ (+ v-solver-5649 624) 16)) (+ (m-ptr (+ (+ v-solver-5649 624) 0)) (* 4 v-new_capacity-5779))))
    (go ENDIF5773)
    ELSE5772
    ENDIF5773
    (progn (setf (m-u32 (let* ((a5783 (+ (+ v-solver-5649 624) 8)) (old5784 (m-ptr a5783))) (setf (m-ptr a5783) (+ old5784 (* 4 1))) old5784)) v-lit-5768))
    (setf v-keep-5785 (c-bool 1))
    (unless (c-true (if (/= v-lit-5768 v-implied-5653) 1 0)) (go ELSE5786))
    (setf v-idx-5788 (|c/INDEX| v-lit-5768))
    (setf v-mark-5789 (m-s8 (+ (m-ptr (+ v-solver-5649 96)) (* 1 v-idx-5788))))
    (unless (c-true (if (c-true (c-s32 (logand v-mark-5789 1))) 0 1)) (go ELSE5790))
    (progn (setf v-keep-5785 (c-bool 0)))
    (go ENDIF5791)
    ELSE5790
    (unless (c-true (m-ptr (+ (m-ptr (+ v-solver-5649 416)) (* 8 v-idx-5788)))) (go ELSE5792))
    (progn (setf v-keep-5785 (c-bool 0)))
    (go ENDIF5793)
    ELSE5792
    ENDIF5793
    ENDIF5791
    (unless (c-true (if (c-true v-keep-5785) 0 1)) (go ELSE5794))
    (progn v-solver-5649)
    (go ENDIF5795)
    ELSE5794
    ENDIF5795
    (go ENDIF5787)
    ELSE5786
    ENDIF5787
    (unless (c-true (if (c-true (ldb (byte 1 2) (m-u8 (+ v-c-5650 0)))) 0 1)) (go ELSE5799))
    (unless (c-true v-keep-5785) (go ELSE5801))
    (progn (|c/mark_subsume_variable| v-solver-5649 (|c/INDEX| v-lit-5768)))
    (go ENDIF5802)
    ELSE5801
    ENDIF5802
    (unless (c-true (if (c-true v-keep-5785) 0 1)) (go ELSE5803))
    (progn (|c/mark_eliminate_literal| v-solver-5649 v-lit-5768))
    (go ENDIF5804)
    ELSE5803
    ENDIF5804
    (go ENDIF5800)
    ELSE5799
    ENDIF5800
    (unless (c-true v-keep-5785) (go ELSE5805))
    (progn (setf (m-u32 (+ v-lits-5761 (* 4 (let* ( (old5808 v-new_size-5760)) (setf v-new_size-5760 (c-u32 (c-u32 (+ old5808 (c-u32 1))))) old5808)))) v-lit-5768))
    (go ENDIF5806)
    ELSE5805
    ENDIF5806
    (let* ( (old5810 v-i-5767)) (setf v-i-5767 (c-u32 (c-u32 (+ old5810 (c-u32 1))))) old5810)
    (go LOOP5764)
    ENDLOOP5765
    (unless (c-true (if (c-true (ldb (byte 1 6) (m-u8 (+ v-c-5650 0)))) 0 1)) (go ELSE5811))
    (progn (set-bits (+ v-c-5650 0) 6 1 (c-bool 1)))
    (progn (setf (m-u32 (+ v-lits-5761 (* 4 (c-u32 (- v-old_size-5759 (c-u32 1)))))) 4294967295))
    (go ENDIF5812)
    ELSE5811
    ENDIF5812
    (progn (setf (m-u32 (+ v-c-5650 12)) v-new_size-5760))
    (progn (|c/trace_and_check_clause_addition| v-solver-5649 v-c-5650 4294967295))
    (progn (|c/trace_and_check_deletion| v-solver-5649 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5649 624) 8)) (m-ptr (+ (+ v-solver-5649 624) 0))) 4)) (m-ptr (+ (+ v-solver-5649 624) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-5649 624) 8)) (m-ptr (+ (+ v-solver-5649 624) 0))))
    (unless (c-true (if (c-true (if (c-true (ldb (byte 1 2) (m-u8 (+ v-c-5650 0)))) 0 1)) (c-bool (if (>= (m-u32 (+ v-c-5650 4)) v-new_size-5760) 1 0)) 0)) (go ELSE5816))
    (progn (|c/promote_clause| v-solver-5649 v-c-5650 (c-u32 (- v-new_size-5760 (c-u32 1)))))
    (go ENDIF5817)
    ELSE5816
    ENDIF5817
    (progn (|c/unwatch_literal| v-solver-5649 v-litA-5762 v-c-5650))
    (progn (|c/unwatch_literal| v-solver-5649 v-litB-5763 v-c-5650))
    (unless (c-true (if (= v-new_size-5760 (c-u32 2)) 1 0)) (go ELSE5818))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-5649 624) 8)) (m-ptr (+ (+ v-solver-5649 624) 16))) 1 0)) (go ELSE5823))
    (setf v-old_size-5828 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5649 624) 8)) (m-ptr (+ (+ v-solver-5649 624) 0))) 4)))
    (setf v-old_capacity-5829 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5649 624) 16)) (m-ptr (+ (+ v-solver-5649 624) 0))) 4)))
    (setf v-new_capacity-5830 (if (c-true v-old_capacity-5829) (c-u64 (* (c-u64 2) v-old_capacity-5829)) (c-u64 1)))
    (setf v-new_bytes-5831 (c-u64 (* v-new_capacity-5830 4)))
    (progn (setf (m-ptr (+ (+ v-solver-5649 624) 0)) (c-realloc (m-ptr (+ (+ v-solver-5649 624) 0)) v-new_bytes-5831)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-5649 624) 0))) 0 1)) (go ELSE5832))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-5831))
    (go ENDIF5833)
    ELSE5832
    ENDIF5833
    (progn (setf (m-ptr (+ (+ v-solver-5649 624) 8)) (+ (m-ptr (+ (+ v-solver-5649 624) 0)) (* 4 v-old_size-5828))))
    (progn (setf (m-ptr (+ (+ v-solver-5649 624) 16)) (+ (m-ptr (+ (+ v-solver-5649 624) 0)) (* 4 v-new_capacity-5830))))
    (go ENDIF5824)
    ELSE5823
    ENDIF5824
    (progn (setf (m-u32 (let* ((a5834 (+ (+ v-solver-5649 624) 8)) (old5835 (m-ptr a5834))) (setf (m-ptr a5834) (+ old5835 (* 4 1))) old5835)) (m-u32 (+ (+ v-c-5650 16) (* 4 0)))))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-5649 624) 8)) (m-ptr (+ (+ v-solver-5649 624) 16))) 1 0)) (go ELSE5839))
    (setf v-old_size-5844 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5649 624) 8)) (m-ptr (+ (+ v-solver-5649 624) 0))) 4)))
    (setf v-old_capacity-5845 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5649 624) 16)) (m-ptr (+ (+ v-solver-5649 624) 0))) 4)))
    (setf v-new_capacity-5846 (if (c-true v-old_capacity-5845) (c-u64 (* (c-u64 2) v-old_capacity-5845)) (c-u64 1)))
    (setf v-new_bytes-5847 (c-u64 (* v-new_capacity-5846 4)))
    (progn (setf (m-ptr (+ (+ v-solver-5649 624) 0)) (c-realloc (m-ptr (+ (+ v-solver-5649 624) 0)) v-new_bytes-5847)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-5649 624) 0))) 0 1)) (go ELSE5848))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-5847))
    (go ENDIF5849)
    ELSE5848
    ENDIF5849
    (progn (setf (m-ptr (+ (+ v-solver-5649 624) 8)) (+ (m-ptr (+ (+ v-solver-5649 624) 0)) (* 4 v-old_size-5844))))
    (progn (setf (m-ptr (+ (+ v-solver-5649 624) 16)) (+ (m-ptr (+ (+ v-solver-5649 624) 0)) (* 4 v-new_capacity-5846))))
    (go ENDIF5840)
    ELSE5839
    ENDIF5840
    (progn (setf (m-u32 (let* ((a5850 (+ (+ v-solver-5649 624) 8)) (old5851 (m-ptr a5850))) (setf (m-ptr a5850) (+ old5851 (* 4 1))) old5851)) (m-u32 (+ (+ v-c-5650 16) (* 4 1)))))
    (progn (|c/add_new_binary_and_watch_it| v-solver-5649 (c-bool (ldb (byte 1 2) (m-u8 (+ v-c-5650 0))))))
    (progn (setf (m-ptr (+ (+ v-solver-5649 624) 8)) (m-ptr (+ (+ v-solver-5649 624) 0))))
    (progn (|c/vivify_mark_garbage| v-solver-5649 v-c-5650 |c/string/169|))
    (go ENDIF5819)
    ELSE5818
    (progn (setf (m-u32 (+ v-c-5650 8)) (c-u32 0)))
    (progn v-solver-5649)
    (progn (progn 0 (let* ((a5858 (+ (+ v-solver-5649 1016) 392)) (old5859 (m-u64 a5858))) (setf (m-u64 a5858) (c-u64 (c-u64 (+ old5859 (c-u64 1))))) (m-u64 a5858))))
    (progn (|c/watch_clause| v-solver-5649 v-c-5650))
    ENDIF5819
    (progn (setf v-res-5654 (c-bool 1)))
    (go ENDIF5755)
    ELSE5754
    (unless (c-true (if (c-true v-irredundant-5652) (c-bool (if (c-true (ldb (byte 1 2) (m-u8 (+ v-c-5650 0)))) 0 1)) 0)) (go ELSE5860))
    (progn (progn 0 (let* ((a5862 (+ (+ v-solver-5649 1016) 400)) (old5863 (m-u64 a5862))) (setf (m-u64 a5862) (c-u64 (c-u64 (+ old5863 (c-u64 1))))) (m-u64 a5862))))
    (progn (|c/vivify_mark_garbage| v-solver-5649 v-c-5650 |c/string/170|))
    (progn (setf v-res-5654 (c-bool 1)))
    (go ENDIF5861)
    ELSE5860
    (progn v-solver-5649)
    (progn (setf v-res-5654 (c-bool 0)))
    ENDIF5861
    ENDIF5755
    ENDIF5747
    ENDIF5657
    (return-from |c/vivify_learn| (c-bool v-res-5654))
  )
  0))

;;; upstream/satch.c:10582:1
(defun |c/vivify_analyze| (arg-v-solver-5867 arg-v-c-5868 arg-v-conflict-5869 arg-v-irredundant_ptr-5870)
 (declare  (type c-address arg-v-solver-5867) (type c-address arg-v-c-5868) (type c-address arg-v-conflict-5869) (type c-address arg-v-irredundant_ptr-5870))
 (let ((v-solver-5867 0) (v-c-5868 0) (v-conflict-5869 0) (v-irredundant_ptr-5870 0) (v-vivify_marks-5874 0) (v-marks-5875 0) (v-lit-5879 0) (v-P_lit-5880 0) (v-END_lit-5881 0) (v-subsumed-5887 0) (v-lit-5893 0) (v-P_lit-5894 0) (v-END_lit-5895 0) (v-value-5896 0) (v-analyzed-5908 0) (v-irredundant-5909 0) (v-levels-5910 0) (v-values-5911 0) (v-reasons-5912 0) (v-idx-5916 0) (v-lit-5917 0) (v-not_lit-5918 0) (v-reason-5919 0) (v-old_size-5935 0) (v-old_capacity-5936 0) (v-new_capacity-5937 0) (v-new_bytes-5938 0) (v-other-5945 0) (v-redundant-5946 0) (v-subsuming-5966 0) (v-other-5970 0) (v-P_other-5971 0) (v-END_other-5972 0) (v-lit-5993 0) (v-P_lit-5994 0) (v-END_lit-5995 0) (v-size-6001 0))
 (declare (type c-address v-solver-5867) (type c-address v-c-5868) (type c-address v-conflict-5869) (type c-address v-irredundant_ptr-5870) (type c-address v-vivify_marks-5874) (type c-address v-marks-5875) (type (unsigned-byte 32) v-lit-5879) (type c-address v-P_lit-5880) (type c-address v-END_lit-5881) (type (integer 0 1) v-subsumed-5887) (type (unsigned-byte 32) v-lit-5893) (type c-address v-P_lit-5894) (type c-address v-END_lit-5895) (type (signed-byte 8) v-value-5896) (type c-size v-analyzed-5908) (type (integer 0 1) v-irredundant-5909) (type c-address v-levels-5910) (type c-address v-values-5911) (type c-address v-reasons-5912) (type (unsigned-byte 32) v-idx-5916) (type (unsigned-byte 32) v-lit-5917) (type (unsigned-byte 32) v-not_lit-5918) (type c-address v-reason-5919) (type c-size v-old_size-5935) (type c-size v-old_capacity-5936) (type c-size v-new_capacity-5937) (type c-size v-new_bytes-5938) (type (unsigned-byte 32) v-other-5945) (type (integer 0 1) v-redundant-5946) (type (integer 0 1) v-subsuming-5966) (type (unsigned-byte 32) v-other-5970) (type c-address v-P_other-5971) (type c-address v-END_other-5972) (type (unsigned-byte 32) v-lit-5993) (type c-address v-P_lit-5994) (type c-address v-END_lit-5995) (type c-size v-size-6001) (ignorable v-solver-5867 v-c-5868 v-conflict-5869 v-irredundant_ptr-5870 v-vivify_marks-5874 v-marks-5875 v-lit-5879 v-P_lit-5880 v-END_lit-5881 v-subsumed-5887 v-lit-5893 v-P_lit-5894 v-END_lit-5895 v-value-5896 v-analyzed-5908 v-irredundant-5909 v-levels-5910 v-values-5911 v-reasons-5912 v-idx-5916 v-lit-5917 v-not_lit-5918 v-reason-5919 v-old_size-5935 v-old_capacity-5936 v-new_capacity-5937 v-new_bytes-5938 v-other-5945 v-redundant-5946 v-subsuming-5966 v-other-5970 v-P_other-5971 v-END_other-5972 v-lit-5993 v-P_lit-5994 v-END_lit-5995 v-size-6001))
 (tagbody
    (setf v-solver-5867 arg-v-solver-5867)
    (setf v-c-5868 arg-v-c-5868)
    (setf v-conflict-5869 arg-v-conflict-5869)
    (setf v-irredundant_ptr-5870 arg-v-irredundant_ptr-5870)
    (progn v-solver-5867)
    (setf v-vivify_marks-5874 (m-ptr (+ v-solver-5867 1976)))
    (setf v-marks-5875 (m-ptr (+ v-solver-5867 96)))
    (setf v-P_lit-5880 (+ v-c-5868 16))
    (setf v-END_lit-5881 (+ v-P_lit-5880 (* 4 (m-u32 (+ v-c-5868 12)))))
    LOOP5876
    (unless (c-true (if (c-true (if (/= v-P_lit-5880 v-END_lit-5881) 1 0)) (c-bool (progn (setf v-lit-5879 (m-u32 v-P_lit-5880)) 1)) 0)) (go ENDLOOP5877))
    (progn v-solver-5867)
    (progn (|c/vivify_mark_literal| v-solver-5867 v-lit-5879))
    (let* ( (old5886 v-P_lit-5880)) (setf v-P_lit-5880 (+ old5886 (* 4 1))) v-P_lit-5880)
    (go LOOP5876)
    ENDLOOP5877
    (setf v-subsumed-5887 (c-bool 0))
    (unless (c-true (if (c-true (ldb (byte 1 2) (m-u8 (+ v-c-5868 0)))) 1 (c-bool (if (c-true (ldb (byte 1 2) (m-u8 (+ v-conflict-5869 0)))) 0 1)))) (go ELSE5888))
    (progn (setf v-subsumed-5887 (c-bool 1)))
    (setf v-P_lit-5894 (+ v-conflict-5869 16))
    (setf v-END_lit-5895 (+ v-P_lit-5894 (* 4 (m-u32 (+ v-conflict-5869 12)))))
    LOOP5890
    (unless (c-true (if (c-true (if (/= v-P_lit-5894 v-END_lit-5895) 1 0)) (c-bool (progn (setf v-lit-5893 (m-u32 v-P_lit-5894)) 1)) 0)) (go ENDLOOP5891))
    (setf v-value-5896 (|c/satch_fixed| v-solver-5867 v-lit-5893))
    (unless (c-true (if (< v-value-5896 0) 1 0)) (go ELSE5897))
    (go CONTINUE5892)
    ELSE5897
    (unless (c-true (if (> (|c/vivify_marked_literal| v-solver-5867 v-lit-5893) 0) 1 0)) (go ELSE5899))
    (go CONTINUE5892)
    ELSE5899
    (progn (setf v-subsumed-5887 (c-bool 0)))
    (go ENDLOOP5891)
    CONTINUE5892
    (let* ( (old5902 v-P_lit-5894)) (setf v-P_lit-5894 (+ old5902 (* 4 1))) v-P_lit-5894)
    (go LOOP5890)
    ENDLOOP5891
    (unless (c-true v-subsumed-5887) (go ELSE5903))
    (progn v-solver-5867)
    (go ENDIF5904)
    ELSE5903
    ENDIF5904
    (go ENDIF5889)
    ELSE5888
    ENDIF5889
    (setf v-analyzed-5908 (c-u64 0))
    (setf v-irredundant-5909 (c-bool (if (c-true v-conflict-5869) (c-bool (if (c-true (ldb (byte 1 2) (m-u8 (+ v-conflict-5869 0)))) 0 1)) 0)))
    (setf v-levels-5910 (m-ptr (+ v-solver-5867 32)))
    (setf v-values-5911 (m-ptr (+ v-solver-5867 40)))
    (setf v-reasons-5912 (m-ptr (+ v-solver-5867 416)))
    LOOP5913
    (unless (c-true (if (< v-analyzed-5908 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5867 600) 8)) (m-ptr (+ (+ v-solver-5867 600) 0))) 8))) 1 0)) (go ENDLOOP5914))
    (setf v-idx-5916 (m-u32 (+ (+ (m-ptr (+ (+ v-solver-5867 600) 0)) (* 8 (progn 0 v-analyzed-5908))) 0)))
    (setf v-lit-5917 (if (c-true (if (> (m-s8 (+ v-values-5911 (* 1 (|c/LITERAL| v-idx-5916)))) 0) 1 0)) (|c/LITERAL| v-idx-5916) (|c/NOT| (|c/LITERAL| v-idx-5916))))
    (setf v-not_lit-5918 (|c/NOT| v-lit-5917))
    (setf v-reason-5919 (m-ptr (+ v-reasons-5912 (* 8 (|c/INDEX| v-lit-5917)))))
    (progn (let* ( (old5921 v-analyzed-5908)) (setf v-analyzed-5908 (c-u64 (c-u64 (+ old5921 (c-u64 1))))) old5921))
    (unless (c-true (if (c-true (m-ptr (+ v-reasons-5912 (* 8 v-idx-5916)))) 0 1)) (go ELSE5922))
    (progn v-solver-5867)
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-5867 624) 8)) (m-ptr (+ (+ v-solver-5867 624) 16))) 1 0)) (go ELSE5930))
    (setf v-old_size-5935 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5867 624) 8)) (m-ptr (+ (+ v-solver-5867 624) 0))) 4)))
    (setf v-old_capacity-5936 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5867 624) 16)) (m-ptr (+ (+ v-solver-5867 624) 0))) 4)))
    (setf v-new_capacity-5937 (if (c-true v-old_capacity-5936) (c-u64 (* (c-u64 2) v-old_capacity-5936)) (c-u64 1)))
    (setf v-new_bytes-5938 (c-u64 (* v-new_capacity-5937 4)))
    (progn (setf (m-ptr (+ (+ v-solver-5867 624) 0)) (c-realloc (m-ptr (+ (+ v-solver-5867 624) 0)) v-new_bytes-5938)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-5867 624) 0))) 0 1)) (go ELSE5939))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-5938))
    (go ENDIF5940)
    ELSE5939
    ENDIF5940
    (progn (setf (m-ptr (+ (+ v-solver-5867 624) 8)) (+ (m-ptr (+ (+ v-solver-5867 624) 0)) (* 4 v-old_size-5935))))
    (progn (setf (m-ptr (+ (+ v-solver-5867 624) 16)) (+ (m-ptr (+ (+ v-solver-5867 624) 0)) (* 4 v-new_capacity-5937))))
    (go ENDIF5931)
    ELSE5930
    ENDIF5931
    (progn (setf (m-u32 (let* ((a5941 (+ (+ v-solver-5867 624) 8)) (old5942 (m-ptr a5941))) (setf (m-ptr a5941) (+ old5942 (* 4 1))) old5942)) v-not_lit-5918))
    (go ENDIF5923)
    ELSE5922
    (unless (c-true (|c/is_tagged_clause| v-reason-5919)) (go ELSE5943))
    (setf v-other-5945 (|c/tagged_clause_to_literal| v-reason-5919))
    (setf v-redundant-5946 (c-bool (|c/tagged_clause_to_redundant| v-reason-5919)))
    (unless (c-true v-redundant-5946) (go ELSE5947))
    (progn (setf v-irredundant-5909 (c-bool 0)))
    (go ENDIF5948)
    ELSE5947
    ENDIF5948
    (unless (c-true (if (c-true (ldb (byte 1 2) (m-u8 (+ v-c-5868 0)))) 1 (c-bool (if (c-true v-redundant-5946) 0 1)))) (go ELSE5949))
    (unless (c-true (if (c-true (if (< (|c/vivify_marked_literal| v-solver-5867 v-lit-5917) 0) 1 0)) (c-bool (if (< (|c/vivify_marked_literal| v-solver-5867 v-other-5945) 0) 1 0)) 0)) (go ELSE5951))
    (progn v-solver-5867)
    (progn (setf v-subsumed-5887 (c-bool 1)))
    (go ENDIF5952)
    ELSE5951
    ENDIF5952
    (go ENDIF5950)
    ELSE5949
    ENDIF5950
    (unless (c-true (c-s32 (logand (m-s8 (+ v-marks-5875 (* 1 (|c/INDEX| v-other-5945)))) 1))) (go ELSE5956))
    (go CONTINUE5915)
    ELSE5956
    (progn v-solver-5867)
    (progn (|c/mark_analyzed| v-solver-5867 (|c/INDEX| v-other-5945)))
    (go ENDIF5944)
    ELSE5943
    (progn v-solver-5867)
    (unless (c-true (ldb (byte 1 2) (m-u8 (+ v-reason-5919 0)))) (go ELSE5964))
    (progn (setf v-irredundant-5909 (c-bool 0)))
    (go ENDIF5965)
    ELSE5964
    ENDIF5965
    (setf v-subsuming-5966 (c-bool (|c/vivify_marked_literal| v-solver-5867 v-lit-5917)))
    (setf v-P_other-5971 (+ v-reason-5919 16))
    (setf v-END_other-5972 (+ v-P_other-5971 (* 4 (m-u32 (+ v-reason-5919 12)))))
    LOOP5967
    (unless (c-true (if (c-true (if (/= v-P_other-5971 v-END_other-5972) 1 0)) (c-bool (progn (setf v-other-5970 (m-u32 v-P_other-5971)) 1)) 0)) (go ENDLOOP5968))
    (unless (c-true (if (= v-other-5970 v-lit-5917) 1 0)) (go ELSE5973))
    (go CONTINUE5969)
    ELSE5973
    (unless (c-true (if (= v-other-5970 v-not_lit-5918) 1 0)) (go ELSE5975))
    (go CONTINUE5969)
    ELSE5975
    (unless (c-true (if (c-true (m-u32 (+ v-levels-5910 (* 4 (|c/INDEX| v-other-5970))))) 0 1)) (go ELSE5977))
    (go CONTINUE5969)
    ELSE5977
    (unless (c-true (if (c-true (|c/vivify_marked_literal| v-solver-5867 v-other-5970)) 0 1)) (go ELSE5979))
    (progn (setf v-subsuming-5966 (c-bool 0)))
    (go ENDIF5980)
    ELSE5979
    ENDIF5980
    (unless (c-true (c-s32 (logand (m-s8 (+ v-marks-5875 (* 1 (|c/INDEX| v-other-5970)))) 1))) (go ELSE5981))
    (go CONTINUE5969)
    ELSE5981
    (progn (|c/mark_analyzed| v-solver-5867 (|c/INDEX| v-other-5970)))
    CONTINUE5969
    (let* ( (old5984 v-P_other-5971)) (setf v-P_other-5971 (+ old5984 (* 4 1))) v-P_other-5971)
    (go LOOP5967)
    ENDLOOP5968
    (unless (c-true (if (c-true v-subsuming-5966) (c-bool (if (c-true (ldb (byte 1 2) (m-u8 (+ v-c-5868 0)))) 1 (c-bool (if (c-true (ldb (byte 1 2) (m-u8 (+ v-reason-5919 0)))) 0 1)))) 0)) (go ELSE5985))
    (progn (setf v-subsumed-5887 (c-bool 1)))
    (progn v-solver-5867)
    (go ENDIF5986)
    ELSE5985
    ENDIF5986
    ENDIF5944
    ENDIF5923
    CONTINUE5915
    (go LOOP5913)
    ENDLOOP5914
    (setf v-P_lit-5994 (+ v-c-5868 16))
    (setf v-END_lit-5995 (+ v-P_lit-5994 (* 4 (m-u32 (+ v-c-5868 12)))))
    LOOP5990
    (unless (c-true (if (c-true (if (/= v-P_lit-5994 v-END_lit-5995) 1 0)) (c-bool (progn (setf v-lit-5993 (m-u32 v-P_lit-5994)) 1)) 0)) (go ENDLOOP5991))
    (progn v-solver-5867)
    (progn (|c/unmark_literal| v-vivify_marks-5874 v-lit-5993))
    (let* ( (old6000 v-P_lit-5994)) (setf v-P_lit-5994 (+ old6000 (* 4 1))) v-P_lit-5994)
    (go LOOP5990)
    ENDLOOP5991
    (setf v-size-6001 (the c-size (truncate (- (m-ptr (+ (+ v-solver-5867 624) 8)) (m-ptr (+ (+ v-solver-5867 624) 0))) 4)))
    (unless (c-true v-subsumed-5887) (go ELSE6002))
    (unless (c-true (if (= v-size-6001 (c-u64 1)) 1 0)) (go ELSE6004))
    (progn v-solver-5867)
    (progn (setf v-subsumed-5887 (c-bool 0)))
    (go ENDIF6005)
    ELSE6004
    (progn v-solver-5867)
    ENDIF6005
    (go ENDIF6003)
    ELSE6002
    ENDIF6003
    (unless (c-true (if (c-true v-subsumed-5887) 0 1)) (go ELSE6012))
    (progn (setf (m-u8 v-irredundant_ptr-5870) (c-bool v-irredundant-5909)))
    (progn v-solver-5867)
    (go ENDIF6013)
    ELSE6012
    ENDIF6013
    (return-from |c/vivify_analyze| (c-bool v-subsumed-5887))
  )
  0))

;;; upstream/satch.c:10730:1
(defun |c/vivify_reset_analyzed| (arg-v-solver-6017)
 (declare  (type c-address arg-v-solver-6017))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-6017 0) (v-marks-6018 0) (v-analyzed-6022 (stack-alloc 8)) (v-PTR_analyzed-6023 0) (v-END_analyzed-6024 0) (v-idx-6025 0))
 (declare (type c-address v-solver-6017) (type c-address v-marks-6018) (type c-address v-analyzed-6022) (type c-address v-PTR_analyzed-6023) (type c-address v-END_analyzed-6024) (type (unsigned-byte 32) v-idx-6025) (ignorable v-solver-6017 v-marks-6018 v-analyzed-6022 v-PTR_analyzed-6023 v-END_analyzed-6024 v-idx-6025))
 (tagbody
    (setf v-solver-6017 arg-v-solver-6017)
    (setf v-marks-6018 (m-ptr (+ v-solver-6017 96)))
    (setf v-PTR_analyzed-6023 (m-ptr (+ (+ v-solver-6017 600) 0)))
    (setf v-END_analyzed-6024 (m-ptr (+ (+ v-solver-6017 600) 8)))
    LOOP6019
    (unless (c-true (if (c-true (if (/= v-PTR_analyzed-6023 v-END_analyzed-6024) 1 0)) (c-bool (progn (copy-bytes v-analyzed-6022 v-PTR_analyzed-6023 8) 1)) 0)) (go ENDLOOP6020))
    (setf v-idx-6025 (m-u32 (+ v-analyzed-6022 0)))
    (progn (let ((a6026 (+ v-marks-6018 (* 1 v-idx-6025)))) (setf (m-s8 a6026) (c-s8 (c-s32 (logand (m-s8 a6026) (c-s32 (lognot 1))))))))
    (let* ( (old6028 v-PTR_analyzed-6023)) (setf v-PTR_analyzed-6023 (+ old6028 (* 8 1))) v-PTR_analyzed-6023)
    (go LOOP6019)
    ENDLOOP6020
    (progn (setf (m-ptr (+ (+ v-solver-6017 600) 8)) (m-ptr (+ (+ v-solver-6017 600) 0))))
    (progn (setf (m-ptr (+ (+ v-solver-6017 624) 8)) (m-ptr (+ (+ v-solver-6017 624) 0))))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:10744:1
(defun |c/vivify_unit_conflict| (arg-v-solver-6035 arg-v-lit-6036)
 (declare  (type c-address arg-v-solver-6035) (type (unsigned-byte 32) arg-v-lit-6036))
 (let ((v-solver-6035 0) (v-lit-6036 0) (v-idx-6037 0) (v-conflict-6041 0) (v-reason-6042 0) (v-old_size-6053 0) (v-old_capacity-6054 0) (v-new_capacity-6055 0) (v-new_bytes-6056 0))
 (declare (type c-address v-solver-6035) (type (unsigned-byte 32) v-lit-6036) (type (unsigned-byte 32) v-idx-6037) (type c-address v-conflict-6041) (type c-address v-reason-6042) (type c-size v-old_size-6053) (type c-size v-old_capacity-6054) (type c-size v-new_capacity-6055) (type c-size v-new_bytes-6056) (ignorable v-solver-6035 v-lit-6036 v-idx-6037 v-conflict-6041 v-reason-6042 v-old_size-6053 v-old_capacity-6054 v-new_capacity-6055 v-new_bytes-6056))
 (tagbody
    (setf v-solver-6035 arg-v-solver-6035)
    (setf v-lit-6036 arg-v-lit-6036)
    (setf v-idx-6037 (|c/INDEX| v-lit-6036))
    (progn v-solver-6035)
    (setf v-reason-6042 (m-ptr (+ (m-ptr (+ v-solver-6035 416)) (* 8 v-idx-6037))))
    (unless (c-true (|c/is_tagged_clause| v-reason-6042)) (go ELSE6043))
    (progn (setf v-conflict-6041 (|c/untag_clause| v-solver-6035 (c-u32 0) v-lit-6036 v-reason-6042)))
    (go ENDIF6044)
    ELSE6043
    (progn (setf v-conflict-6041 v-reason-6042))
    ENDIF6044
    (progn (|c/mark_analyzed| v-solver-6035 v-idx-6037))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-6035 624) 8)) (m-ptr (+ (+ v-solver-6035 624) 16))) 1 0)) (go ELSE6048))
    (setf v-old_size-6053 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6035 624) 8)) (m-ptr (+ (+ v-solver-6035 624) 0))) 4)))
    (setf v-old_capacity-6054 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6035 624) 16)) (m-ptr (+ (+ v-solver-6035 624) 0))) 4)))
    (setf v-new_capacity-6055 (if (c-true v-old_capacity-6054) (c-u64 (* (c-u64 2) v-old_capacity-6054)) (c-u64 1)))
    (setf v-new_bytes-6056 (c-u64 (* v-new_capacity-6055 4)))
    (progn (setf (m-ptr (+ (+ v-solver-6035 624) 0)) (c-realloc (m-ptr (+ (+ v-solver-6035 624) 0)) v-new_bytes-6056)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-6035 624) 0))) 0 1)) (go ELSE6057))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-6056))
    (go ENDIF6058)
    ELSE6057
    ENDIF6058
    (progn (setf (m-ptr (+ (+ v-solver-6035 624) 8)) (+ (m-ptr (+ (+ v-solver-6035 624) 0)) (* 4 v-old_size-6053))))
    (progn (setf (m-ptr (+ (+ v-solver-6035 624) 16)) (+ (m-ptr (+ (+ v-solver-6035 624) 0)) (* 4 v-new_capacity-6055))))
    (go ENDIF6049)
    ELSE6048
    ENDIF6049
    (progn (setf (m-u32 (let* ((a6059 (+ (+ v-solver-6035 624) 8)) (old6060 (m-ptr a6059))) (setf (m-ptr a6059) (+ old6060 (* 4 1))) old6060)) v-lit-6036))
    (return-from |c/vivify_unit_conflict| v-conflict-6041)
  )
  0))

;;; upstream/satch.c:10769:1
(defun |c/vivify_clause| (arg-v-solver-6061 arg-v-c-6062 arg-v-counts-6063)
 (declare  (notinline checked-address) (type c-address arg-v-solver-6061) (type c-address arg-v-c-6062) (type c-address arg-v-counts-6063))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-6061 0) (v-c-6062 0) (v-counts-6063 0) (v-levels-6064 0) (v-sorted-6065 0) (v-lit-6075 0) (v-P_lit-6076 0) (v-END_lit-6077 0) (v-value-6078 0) (v-old_size-6091 0) (v-old_capacity-6092 0) (v-new_capacity-6093 0) (v-new_bytes-6094 0) (v-non_false-6103 0) (v-unit-6122 0) (v-lit-6126 0) (v-P_lit-6127 0) (v-END_lit-6128 0) (v-value-6129 0) (v-level-6146 0) (v-implied-6150 0) (v-falsified-6151 0) (v-satisfied-6152 0) (v-conflict-6153 0) (v-level-6154 0) (v-res-6155 0) (v-lit-6159 0) (v-PTR_lit-6160 0) (v-END_lit-6161 0) (v-frame-6166 (stack-alloc 24)) (v-not_lit-6167 0) (v-value-6180 0) (v-not_lit-6186 0) (v-irredundant-6215 (stack-alloc 1)) (v-subsumed-6216 0) (v-reasons-6231 0) (v-lit-6235 0) (v-PTR_lit-6236 0) (v-END_lit-6237 0) (v-idx-6238 0) (v-old_size-6249 0) (v-old_capacity-6250 0) (v-new_capacity-6251 0) (v-new_bytes-6252 0))
 (declare (type c-address v-solver-6061) (type c-address v-c-6062) (type c-address v-counts-6063) (type c-address v-levels-6064) (type c-address v-sorted-6065) (type (unsigned-byte 32) v-lit-6075) (type c-address v-P_lit-6076) (type c-address v-END_lit-6077) (type (signed-byte 8) v-value-6078) (type c-size v-old_size-6091) (type c-size v-old_capacity-6092) (type c-size v-new_capacity-6093) (type c-size v-new_bytes-6094) (type (unsigned-byte 32) v-non_false-6103) (type (unsigned-byte 32) v-unit-6122) (type (unsigned-byte 32) v-lit-6126) (type c-address v-P_lit-6127) (type c-address v-END_lit-6128) (type (signed-byte 8) v-value-6129) (type (unsigned-byte 32) v-level-6146) (type (unsigned-byte 32) v-implied-6150) (type (unsigned-byte 32) v-falsified-6151) (type (unsigned-byte 32) v-satisfied-6152) (type c-address v-conflict-6153) (type (unsigned-byte 32) v-level-6154) (type (integer 0 1) v-res-6155) (type (unsigned-byte 32) v-lit-6159) (type c-address v-PTR_lit-6160) (type c-address v-END_lit-6161) (type c-address v-frame-6166) (type (unsigned-byte 32) v-not_lit-6167) (type (signed-byte 8) v-value-6180) (type (unsigned-byte 32) v-not_lit-6186) (type c-address v-irredundant-6215) (type (integer 0 1) v-subsumed-6216) (type c-address v-reasons-6231) (type (unsigned-byte 32) v-lit-6235) (type c-address v-PTR_lit-6236) (type c-address v-END_lit-6237) (type (unsigned-byte 32) v-idx-6238) (type c-size v-old_size-6249) (type c-size v-old_capacity-6250) (type c-size v-new_capacity-6251) (type c-size v-new_bytes-6252) (ignorable v-solver-6061 v-c-6062 v-counts-6063 v-levels-6064 v-sorted-6065 v-lit-6075 v-P_lit-6076 v-END_lit-6077 v-value-6078 v-old_size-6091 v-old_capacity-6092 v-new_capacity-6093 v-new_bytes-6094 v-non_false-6103 v-unit-6122 v-lit-6126 v-P_lit-6127 v-END_lit-6128 v-value-6129 v-level-6146 v-implied-6150 v-falsified-6151 v-satisfied-6152 v-conflict-6153 v-level-6154 v-res-6155 v-lit-6159 v-PTR_lit-6160 v-END_lit-6161 v-frame-6166 v-not_lit-6167 v-value-6180 v-not_lit-6186 v-irredundant-6215 v-subsumed-6216 v-reasons-6231 v-lit-6235 v-PTR_lit-6236 v-END_lit-6237 v-idx-6238 v-old_size-6249 v-old_capacity-6250 v-new_capacity-6251 v-new_bytes-6252))
 (tagbody
    (setf v-solver-6061 arg-v-solver-6061)
    (setf v-c-6062 arg-v-c-6062)
    (setf v-counts-6063 arg-v-counts-6063)
    (setf v-levels-6064 (m-ptr (+ v-solver-6061 32)))
    (setf v-sorted-6065 (+ v-solver-6061 1904))
    (progn v-solver-6061)
    (progn (setf (m-ptr (+ v-sorted-6065 8)) (m-ptr (+ v-sorted-6065 0))))
    (setf v-P_lit-6076 (+ v-c-6062 16))
    (setf v-END_lit-6077 (+ v-P_lit-6076 (* 4 (m-u32 (+ v-c-6062 12)))))
    LOOP6072
    (unless (c-true (if (c-true (if (/= v-P_lit-6076 v-END_lit-6077) 1 0)) (c-bool (progn (setf v-lit-6075 (m-u32 v-P_lit-6076)) 1)) 0)) (go ENDLOOP6073))
    (setf v-value-6078 (|c/satch_fixed| v-solver-6061 v-lit-6075))
    (unless (c-true (if (< v-value-6078 0) 1 0)) (go ELSE6079))
    (go CONTINUE6074)
    ELSE6079
    (unless (c-true (if (> v-value-6078 0) 1 0)) (go ELSE6081))
    (progn (|c/vivify_mark_garbage| v-solver-6061 v-c-6062 |c/string/137|))
    (go ENDLOOP6073)
    ELSE6081
    (unless (c-true (if (= (m-ptr (+ v-sorted-6065 8)) (m-ptr (+ v-sorted-6065 16))) 1 0)) (go ELSE6086))
    (setf v-old_size-6091 (the c-size (truncate (- (m-ptr (+ v-sorted-6065 8)) (m-ptr (+ v-sorted-6065 0))) 4)))
    (setf v-old_capacity-6092 (the c-size (truncate (- (m-ptr (+ v-sorted-6065 16)) (m-ptr (+ v-sorted-6065 0))) 4)))
    (setf v-new_capacity-6093 (if (c-true v-old_capacity-6092) (c-u64 (* (c-u64 2) v-old_capacity-6092)) (c-u64 1)))
    (setf v-new_bytes-6094 (c-u64 (* v-new_capacity-6093 4)))
    (progn (setf (m-ptr (+ v-sorted-6065 0)) (c-realloc (m-ptr (+ v-sorted-6065 0)) v-new_bytes-6094)))
    (unless (c-true (if (c-true (m-ptr (+ v-sorted-6065 0))) 0 1)) (go ELSE6095))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-6094))
    (go ENDIF6096)
    ELSE6095
    ENDIF6096
    (progn (setf (m-ptr (+ v-sorted-6065 8)) (+ (m-ptr (+ v-sorted-6065 0)) (* 4 v-old_size-6091))))
    (progn (setf (m-ptr (+ v-sorted-6065 16)) (+ (m-ptr (+ v-sorted-6065 0)) (* 4 v-new_capacity-6093))))
    (go ENDIF6087)
    ELSE6086
    ENDIF6087
    (progn (setf (m-u32 (let* ((a6097 (+ v-sorted-6065 8)) (old6098 (m-ptr a6097))) (setf (m-ptr a6097) (+ old6098 (* 4 1))) old6098)) v-lit-6075))
    CONTINUE6074
    (let* ( (old6100 v-P_lit-6076)) (setf v-P_lit-6076 (+ old6100 (* 4 1))) v-P_lit-6076)
    (go LOOP6072)
    ENDLOOP6073
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-c-6062 0)))) (go ELSE6101))
    (return-from |c/vivify_clause| (c-bool 0))
    ELSE6101
    (setf v-non_false-6103 (c-u32 (the c-size (truncate (- (m-ptr (+ v-sorted-6065 8)) (m-ptr (+ v-sorted-6065 0))) 4))))
    (unless (c-true (if (c-true v-non_false-6103) 0 1)) (go ELSE6104))
    (progn v-solver-6061)
    (go ENDIF6105)
    ELSE6104
    (unless (c-true (if (= v-non_false-6103 (m-u32 (+ v-c-6062 12))) 1 0)) (go ELSE6109))
    (progn v-solver-6061)
    (go ENDIF6110)
    ELSE6109
    (progn v-solver-6061)
    ENDIF6110
    ENDIF6105
    (unless (c-true (if (= v-non_false-6103 (c-u32 2)) 1 0)) (go ELSE6117))
    (progn v-solver-6061)
    (return-from |c/vivify_clause| (c-bool 0))
    ELSE6117
    (setf v-unit-6122 4294967295)
    (setf v-P_lit-6127 (+ v-c-6062 16))
    (setf v-END_lit-6128 (+ v-P_lit-6127 (* 4 (m-u32 (+ v-c-6062 12)))))
    LOOP6123
    (unless (c-true (if (c-true (if (/= v-P_lit-6127 v-END_lit-6128) 1 0)) (c-bool (progn (setf v-lit-6126 (m-u32 v-P_lit-6127)) 1)) 0)) (go ENDLOOP6124))
    (setf v-value-6129 (m-s8 (+ (m-ptr (+ v-solver-6061 40)) (* 1 v-lit-6126))))
    (unless (c-true (if (< v-value-6129 0) 1 0)) (go ELSE6130))
    (go CONTINUE6125)
    ELSE6130
    (unless (c-true (if (c-true v-value-6129) 0 1)) (go ELSE6132))
    (progn (setf v-unit-6122 4294967295))
    (go ENDLOOP6124)
    ELSE6132
    (unless (c-true (if (/= v-unit-6122 4294967295) 1 0)) (go ELSE6134))
    (progn (setf v-unit-6122 4294967295))
    (go ENDLOOP6124)
    ELSE6134
    (progn (setf v-unit-6122 v-lit-6126))
    CONTINUE6125
    (let* ( (old6137 v-P_lit-6127)) (setf v-P_lit-6127 (+ old6137 (* 4 1))) v-P_lit-6127)
    (go LOOP6123)
    ENDLOOP6124
    (unless (c-true (if (= v-unit-6122 4294967295) 1 0)) (go ELSE6138))
    (progn v-solver-6061)
    (go ENDIF6139)
    ELSE6138
    (progn v-solver-6061)
    (setf v-level-6146 (m-u32 (+ v-levels-6064 (* 4 (|c/INDEX| v-unit-6122)))))
    (progn v-solver-6061)
    (progn (|c/backtrack| v-solver-6061 (c-u32 (- v-level-6146 (c-u32 1)))))
    ENDIF6139
    (progn (|c/vivify_sort_stack_by_counts| v-solver-6061 v-counts-6063 v-sorted-6065))
    (setf v-implied-6150 4294967295)
    (setf v-falsified-6151 (c-u32 0))
    (setf v-satisfied-6152 (c-u32 0))
    (setf v-conflict-6153 0)
    (setf v-level-6154 (c-u32 0))
    (setf v-res-6155 (c-bool 0))
    (setf v-PTR_lit-6160 (m-ptr (+ v-sorted-6065 0)))
    (setf v-END_lit-6161 (m-ptr (+ v-sorted-6065 8)))
    LOOP6156
    (unless (c-true (if (c-true (if (/= v-PTR_lit-6160 v-END_lit-6161) 1 0)) (c-bool (progn (setf v-lit-6159 (m-u32 v-PTR_lit-6160)) 1)) 0)) (go ENDLOOP6157))
    (unless (c-true (if (< (let* ( (old6165 v-level-6154)) (setf v-level-6154 (c-u32 (c-u32 (+ old6165 (c-u32 1))))) old6165) (m-u32 (+ v-solver-6061 8))) 1 0)) (go ELSE6162))
    (copy-bytes v-frame-6166 (+ (m-ptr (+ (+ v-solver-6061 576) 0)) (* 24 (progn 0 (c-u32 (- v-level-6154 (c-u32 1)))))) 24)
    (setf v-not_lit-6167 (|c/NOT| v-lit-6159))
    (unless (c-true (if (= (m-u32 (m-ptr (+ v-frame-6166 0))) v-not_lit-6167) 1 0)) (go ELSE6168))
    (progn v-solver-6061)
    (progn (progn 0 (let* ((a6173 (+ (+ v-solver-6061 1016) 376)) (old6174 (m-u64 a6173))) (setf (m-u64 a6173) (c-u64 (c-u64 (+ old6174 (c-u64 1))))) (m-u64 a6173))))
    (progn (progn 0 (let* ((a6175 (+ (+ v-solver-6061 1016) 384)) (old6176 (m-u64 a6175))) (setf (m-u64 a6175) (c-u64 (c-u64 (+ old6176 (c-u64 1))))) (m-u64 a6175))))
    (go CONTINUE6158)
    ELSE6168
    (progn v-solver-6061)
    (progn (|c/backtrack| v-solver-6061 (c-u32 (- v-level-6154 (c-u32 1)))))
    (go ENDIF6163)
    ELSE6162
    ENDIF6163
    (setf v-value-6180 (m-s8 (+ (m-ptr (+ v-solver-6061 40)) (* 1 v-lit-6159))))
    (unless (c-true (if (c-true v-value-6180) 0 1)) (go ELSE6181))
    (progn v-solver-6061)
    (setf v-not_lit-6186 (|c/NOT| v-lit-6159))
    (progn (progn 0 (let* ((a6187 (+ (+ v-solver-6061 1016) 384)) (old6188 (m-u64 a6187))) (setf (m-u64 a6187) (c-u64 (c-u64 (+ old6188 (c-u64 1))))) (m-u64 a6187))))
    (progn (let* ((a6189 (+ v-solver-6061 8)) (old6190 (m-u32 a6189))) (setf (m-u32 a6189) (c-u32 (c-u32 (+ old6190 (c-u32 1))))) old6190))
    (progn (|c/assign| v-solver-6061 v-not_lit-6186 0 (c-bool 0)))
    (progn (setf v-conflict-6153 (|c/vivify_boolean_constraint_propagation| v-solver-6061 v-c-6062)))
    (unless (c-true (if (c-true v-conflict-6153) 0 1)) (go ELSE6191))
    (go CONTINUE6158)
    ELSE6191
    (progn (|c/vivify_binary_or_large_conflict| v-solver-6061 v-conflict-6153))
    (go ENDLOOP6157)
    ELSE6181
    (unless (c-true (if (< v-value-6180 0) 1 0)) (go ELSE6193))
    (progn v-solver-6061)
    (progn (let* ( (old6199 v-falsified-6151)) (setf v-falsified-6151 (c-u32 (c-u32 (+ old6199 (c-u32 1))))) old6199))
    (go CONTINUE6158)
    ELSE6193
    (progn (let* ( (old6201 v-satisfied-6152)) (setf v-satisfied-6152 (c-u32 (c-u32 (+ old6201 (c-u32 1))))) old6201))
    (progn v-solver-6061)
    (unless (c-true (if (c-true (ldb (byte 1 2) (m-u8 (+ v-c-6062 0)))) 0 1)) (go ELSE6205))
    (progn (setf v-implied-6150 v-lit-6159))
    (progn (setf v-conflict-6153 (|c/vivify_unit_conflict| v-solver-6061 v-lit-6159)))
    (go ENDIF6206)
    ELSE6205
    (progn (|c/vivify_mark_garbage| v-solver-6061 v-c-6062 |c/string/171|))
    (progn (progn 0 (let* ((a6207 (+ (+ v-solver-6061 1016) 424)) (old6208 (m-u64 a6207))) (setf (m-u64 a6207) (c-u64 (c-u64 (+ old6208 (c-u64 1))))) (m-u64 a6207))))
    (progn (setf v-res-6155 (c-bool 1)))
    ENDIF6206
    (go ENDLOOP6157)
    CONTINUE6158
    (let* ( (old6210 v-PTR_lit-6160)) (setf v-PTR_lit-6160 (+ old6210 (* 4 1))) v-PTR_lit-6160)
    (go LOOP6156)
    ENDLOOP6157
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-c-6062 0)))) (go ELSE6211))
    (go ENDIF6212)
    ELSE6211
    (unless (c-true v-conflict-6153) (go ELSE6213))
    (setf v-subsumed-6216 (c-bool (|c/vivify_analyze| v-solver-6061 v-c-6062 v-conflict-6153 v-irredundant-6215)))
    (progn (|c/backtrack| v-solver-6061 (c-u32 (- (m-u32 (+ v-solver-6061 8)) (c-u32 1)))))
    (unless (c-true v-subsumed-6216) (go ELSE6217))
    (progn (|c/vivify_mark_garbage| v-solver-6061 v-c-6062 |c/string/172|))
    (progn v-solver-6061)
    (progn (progn 0 (let* ((a6222 (+ (+ v-solver-6061 1016) 400)) (old6223 (m-u64 a6222))) (setf (m-u64 a6222) (c-u64 (c-u64 (+ old6223 (c-u64 1))))) (m-u64 a6222))))
    (progn (progn 0 (let* ((a6224 (+ (+ v-solver-6061 1016) 320)) (old6225 (m-u64 a6224))) (setf (m-u64 a6224) (c-u64 (c-u64 (+ old6225 (c-u64 1))))) (m-u64 a6224))))
    (progn (setf v-res-6155 (c-bool 1)))
    (go ENDIF6218)
    ELSE6217
    (progn (setf v-res-6155 (c-bool (|c/vivify_learn| v-solver-6061 v-c-6062 v-non_false-6103 (c-bool (m-u8 v-irredundant-6215)) v-implied-6150))))
    ENDIF6218
    (progn (|c/vivify_reset_analyzed| v-solver-6061))
    (go ENDIF6214)
    ELSE6213
    (unless (c-true (if (c-true v-falsified-6151) (c-bool (if (c-true v-satisfied-6152) 0 1)) 0)) (go ELSE6226))
    (progn v-solver-6061)
    (setf v-reasons-6231 (m-ptr (+ v-solver-6061 416)))
    (setf v-PTR_lit-6236 (m-ptr (+ v-sorted-6065 0)))
    (setf v-END_lit-6237 (m-ptr (+ v-sorted-6065 8)))
    LOOP6232
    (unless (c-true (if (c-true (if (/= v-PTR_lit-6236 v-END_lit-6237) 1 0)) (c-bool (progn (setf v-lit-6235 (m-u32 v-PTR_lit-6236)) 1)) 0)) (go ENDLOOP6233))
    (setf v-idx-6238 (|c/INDEX| v-lit-6235))
    (unless (c-true (m-ptr (+ v-reasons-6231 (* 8 v-idx-6238)))) (go ELSE6239))
    (go CONTINUE6234)
    ELSE6239
    (progn (|c/mark_analyzed| v-solver-6061 v-idx-6238))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-6061 624) 8)) (m-ptr (+ (+ v-solver-6061 624) 16))) 1 0)) (go ELSE6244))
    (setf v-old_size-6249 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6061 624) 8)) (m-ptr (+ (+ v-solver-6061 624) 0))) 4)))
    (setf v-old_capacity-6250 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6061 624) 16)) (m-ptr (+ (+ v-solver-6061 624) 0))) 4)))
    (setf v-new_capacity-6251 (if (c-true v-old_capacity-6250) (c-u64 (* (c-u64 2) v-old_capacity-6250)) (c-u64 1)))
    (setf v-new_bytes-6252 (c-u64 (* v-new_capacity-6251 4)))
    (progn (setf (m-ptr (+ (+ v-solver-6061 624) 0)) (c-realloc (m-ptr (+ (+ v-solver-6061 624) 0)) v-new_bytes-6252)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-6061 624) 0))) 0 1)) (go ELSE6253))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-6252))
    (go ENDIF6254)
    ELSE6253
    ENDIF6254
    (progn (setf (m-ptr (+ (+ v-solver-6061 624) 8)) (+ (m-ptr (+ (+ v-solver-6061 624) 0)) (* 4 v-old_size-6249))))
    (progn (setf (m-ptr (+ (+ v-solver-6061 624) 16)) (+ (m-ptr (+ (+ v-solver-6061 624) 0)) (* 4 v-new_capacity-6251))))
    (go ENDIF6245)
    ELSE6244
    ENDIF6245
    (progn (setf (m-u32 (let* ((a6255 (+ (+ v-solver-6061 624) 8)) (old6256 (m-ptr a6255))) (setf (m-ptr a6255) (+ old6256 (* 4 1))) old6256)) v-lit-6235))
    CONTINUE6234
    (let* ( (old6258 v-PTR_lit-6236)) (setf v-PTR_lit-6236 (+ old6258 (* 4 1))) v-PTR_lit-6236)
    (go LOOP6232)
    ENDLOOP6233
    (progn (setf v-res-6155 (c-bool (|c/vivify_learn| v-solver-6061 v-c-6062 v-non_false-6103 (c-bool 0) 4294967295))))
    (progn (|c/vivify_reset_analyzed| v-solver-6061))
    (go ENDIF6227)
    ELSE6226
    (progn v-solver-6061)
    ENDIF6227
    ENDIF6214
    ENDIF6212
    (unless (c-true (if (c-true v-res-6155) 0 1)) (go ELSE6262))
    (return-from |c/vivify_clause| (c-bool 0))
    ELSE6262
    (progn (progn 0 (let* ((a6264 (+ (+ v-solver-6061 1016) 408)) (old6265 (m-u64 a6264))) (setf (m-u64 a6264) (c-u64 (c-u64 (+ old6265 (c-u64 1))))) (m-u64 a6264))))
    (return-from |c/vivify_clause| (c-bool 1))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:10984:1
(defun |c/simplify_vivification_candidate| (arg-v-solver-6266 arg-v-c-6267)
 (declare  (type c-address arg-v-solver-6266) (type c-address arg-v-c-6267))
 (let ((v-solver-6266 0) (v-c-6267 0) (v-satisfied-6268 0) (v-values-6269 0) (v-lit-6276 0) (v-P_lit-6277 0) (v-END_lit-6278 0) (v-value-6279 0) (v-old_size-6292 0) (v-old_capacity-6293 0) (v-new_capacity-6294 0) (v-new_bytes-6295 0) (v-non_false-6302 0) (v-old_size-6318 0) (v-new_size-6319 0) (v-lits-6320 0) (v-i-6327 0) (v-lit-6328 0) (v-old_size-6337 0) (v-old_capacity-6338 0) (v-new_capacity-6339 0) (v-new_bytes-6340 0) (v-value-6345 0))
 (declare (type c-address v-solver-6266) (type c-address v-c-6267) (type (integer 0 1) v-satisfied-6268) (type c-address v-values-6269) (type (unsigned-byte 32) v-lit-6276) (type c-address v-P_lit-6277) (type c-address v-END_lit-6278) (type (signed-byte 8) v-value-6279) (type c-size v-old_size-6292) (type c-size v-old_capacity-6293) (type c-size v-new_capacity-6294) (type c-size v-new_bytes-6295) (type (unsigned-byte 32) v-non_false-6302) (type (unsigned-byte 32) v-old_size-6318) (type (unsigned-byte 32) v-new_size-6319) (type c-address v-lits-6320) (type (unsigned-byte 32) v-i-6327) (type (unsigned-byte 32) v-lit-6328) (type c-size v-old_size-6337) (type c-size v-old_capacity-6338) (type c-size v-new_capacity-6339) (type c-size v-new_bytes-6340) (type (signed-byte 8) v-value-6345) (ignorable v-solver-6266 v-c-6267 v-satisfied-6268 v-values-6269 v-lit-6276 v-P_lit-6277 v-END_lit-6278 v-value-6279 v-old_size-6292 v-old_capacity-6293 v-new_capacity-6294 v-new_bytes-6295 v-non_false-6302 v-old_size-6318 v-new_size-6319 v-lits-6320 v-i-6327 v-lit-6328 v-old_size-6337 v-old_capacity-6338 v-new_capacity-6339 v-new_bytes-6340 v-value-6345))
 (tagbody
    (setf v-solver-6266 arg-v-solver-6266)
    (setf v-c-6267 arg-v-c-6267)
    (setf v-satisfied-6268 (c-bool 0))
    (setf v-values-6269 (m-ptr (+ v-solver-6266 40)))
    (progn v-solver-6266)
    (setf v-P_lit-6277 (+ v-c-6267 16))
    (setf v-END_lit-6278 (+ v-P_lit-6277 (* 4 (m-u32 (+ v-c-6267 12)))))
    LOOP6273
    (unless (c-true (if (c-true (if (/= v-P_lit-6277 v-END_lit-6278) 1 0)) (c-bool (progn (setf v-lit-6276 (m-u32 v-P_lit-6277)) 1)) 0)) (go ENDLOOP6274))
    (setf v-value-6279 (m-s8 (+ v-values-6269 (* 1 v-lit-6276))))
    (unless (c-true (if (> v-value-6279 0) 1 0)) (go ELSE6280))
    (progn (setf v-satisfied-6268 (c-bool 1)))
    (progn (|c/mark_garbage| v-solver-6266 v-c-6267 |c/string/173|))
    (go ENDLOOP6274)
    ELSE6280
    (unless (c-true (if (c-true v-value-6279) 0 1)) (go ELSE6282))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-6266 624) 8)) (m-ptr (+ (+ v-solver-6266 624) 16))) 1 0)) (go ELSE6287))
    (setf v-old_size-6292 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6266 624) 8)) (m-ptr (+ (+ v-solver-6266 624) 0))) 4)))
    (setf v-old_capacity-6293 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6266 624) 16)) (m-ptr (+ (+ v-solver-6266 624) 0))) 4)))
    (setf v-new_capacity-6294 (if (c-true v-old_capacity-6293) (c-u64 (* (c-u64 2) v-old_capacity-6293)) (c-u64 1)))
    (setf v-new_bytes-6295 (c-u64 (* v-new_capacity-6294 4)))
    (progn (setf (m-ptr (+ (+ v-solver-6266 624) 0)) (c-realloc (m-ptr (+ (+ v-solver-6266 624) 0)) v-new_bytes-6295)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-6266 624) 0))) 0 1)) (go ELSE6296))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-6295))
    (go ENDIF6297)
    ELSE6296
    ENDIF6297
    (progn (setf (m-ptr (+ (+ v-solver-6266 624) 8)) (+ (m-ptr (+ (+ v-solver-6266 624) 0)) (* 4 v-old_size-6292))))
    (progn (setf (m-ptr (+ (+ v-solver-6266 624) 16)) (+ (m-ptr (+ (+ v-solver-6266 624) 0)) (* 4 v-new_capacity-6294))))
    (go ENDIF6288)
    ELSE6287
    ENDIF6288
    (progn (setf (m-u32 (let* ((a6298 (+ (+ v-solver-6266 624) 8)) (old6299 (m-ptr a6298))) (setf (m-ptr a6298) (+ old6299 (* 4 1))) old6299)) v-lit-6276))
    (go ENDIF6283)
    ELSE6282
    ENDIF6283
    (let* ( (old6301 v-P_lit-6277)) (setf v-P_lit-6277 (+ old6301 (* 4 1))) v-P_lit-6277)
    (go LOOP6273)
    ENDLOOP6274
    (setf v-non_false-6302 (c-u32 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6266 624) 8)) (m-ptr (+ (+ v-solver-6266 624) 0))) 4))))
    (unless (c-true v-satisfied-6268) (go ELSE6303))
    (progn (setf (m-ptr (+ (+ v-solver-6266 624) 8)) (m-ptr (+ (+ v-solver-6266 624) 0))))
    (return-from |c/simplify_vivification_candidate| (c-bool 1))
    ELSE6303
    (unless (c-true (if (= v-non_false-6302 (m-u32 (+ v-c-6267 12))) 1 0)) (go ELSE6308))
    (progn (setf (m-ptr (+ (+ v-solver-6266 624) 8)) (m-ptr (+ (+ v-solver-6266 624) 0))))
    (return-from |c/simplify_vivification_candidate| (c-bool 0))
    ELSE6308
    (unless (c-true (if (= v-non_false-6302 (c-u32 2)) 1 0)) (go ELSE6313))
    (progn (|c/trace_and_check_temporary_addition| v-solver-6266))
    (progn v-solver-6266)
    (progn (|c/add_new_binary_and_watch_it| v-solver-6266 (c-bool (ldb (byte 1 2) (m-u8 (+ v-c-6267 0))))))
    (progn (|c/mark_garbage| v-solver-6266 v-c-6267 |c/string/174|))
    (go ENDIF6314)
    ELSE6313
    (setf v-old_size-6318 (m-u32 (+ v-c-6267 12)))
    (setf v-new_size-6319 (c-u32 0))
    (setf v-lits-6320 (+ v-c-6267 16))
    (progn (setf (m-ptr (+ (+ v-solver-6266 624) 8)) (m-ptr (+ (+ v-solver-6266 624) 0))))
    (setf v-i-6327 (c-u32 0))
    LOOP6324
    (unless (c-true (if (< v-i-6327 v-old_size-6318) 1 0)) (go ENDLOOP6325))
    (setf v-lit-6328 (m-u32 (+ v-lits-6320 (* 4 v-i-6327))))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-6266 624) 8)) (m-ptr (+ (+ v-solver-6266 624) 16))) 1 0)) (go ELSE6332))
    (setf v-old_size-6337 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6266 624) 8)) (m-ptr (+ (+ v-solver-6266 624) 0))) 4)))
    (setf v-old_capacity-6338 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6266 624) 16)) (m-ptr (+ (+ v-solver-6266 624) 0))) 4)))
    (setf v-new_capacity-6339 (if (c-true v-old_capacity-6338) (c-u64 (* (c-u64 2) v-old_capacity-6338)) (c-u64 1)))
    (setf v-new_bytes-6340 (c-u64 (* v-new_capacity-6339 4)))
    (progn (setf (m-ptr (+ (+ v-solver-6266 624) 0)) (c-realloc (m-ptr (+ (+ v-solver-6266 624) 0)) v-new_bytes-6340)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-6266 624) 0))) 0 1)) (go ELSE6341))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-6340))
    (go ENDIF6342)
    ELSE6341
    ENDIF6342
    (progn (setf (m-ptr (+ (+ v-solver-6266 624) 8)) (+ (m-ptr (+ (+ v-solver-6266 624) 0)) (* 4 v-old_size-6337))))
    (progn (setf (m-ptr (+ (+ v-solver-6266 624) 16)) (+ (m-ptr (+ (+ v-solver-6266 624) 0)) (* 4 v-new_capacity-6339))))
    (go ENDIF6333)
    ELSE6332
    ENDIF6333
    (progn (setf (m-u32 (let* ((a6343 (+ (+ v-solver-6266 624) 8)) (old6344 (m-ptr a6343))) (setf (m-ptr a6343) (+ old6344 (* 4 1))) old6344)) v-lit-6328))
    (setf v-value-6345 (m-s8 (+ (m-ptr (+ v-solver-6266 40)) (* 1 v-lit-6328))))
    (unless (c-true (if (c-true (if (/= v-value-6345 0) 1 0)) (c-bool (if (= (m-u32 (+ (m-ptr (+ v-solver-6266 32)) (* 4 (|c/INDEX| v-lit-6328)))) (c-u32 0)) 1 0)) 0)) (go ELSE6346))
    (go CONTINUE6326)
    ELSE6346
    (unless (c-true (if (< v-value-6345 0) 1 0)) (go ELSE6348))
    (go CONTINUE6326)
    ELSE6348
    (progn (setf (m-u32 (+ v-lits-6320 (* 4 (let* ( (old6351 v-new_size-6319)) (setf v-new_size-6319 (c-u32 (c-u32 (+ old6351 (c-u32 1))))) old6351)))) v-lit-6328))
    CONTINUE6326
    (let* ( (old6353 v-i-6327)) (setf v-i-6327 (c-u32 (c-u32 (+ old6353 (c-u32 1))))) old6353)
    (go LOOP6324)
    ENDLOOP6325
    (progn (setf (m-u32 (+ v-c-6267 12)) v-new_size-6319))
    (progn (setf (m-u32 (+ v-c-6267 8)) (c-u32 0)))
    (unless (c-true (if (c-true (ldb (byte 1 2) (m-u8 (+ v-c-6267 0)))) (c-bool (if (>= (m-u32 (+ v-c-6267 4)) v-new_size-6319) 1 0)) 0)) (go ELSE6354))
    (progn (|c/promote_clause| v-solver-6266 v-c-6267 (c-u32 (- v-new_size-6319 (c-u32 1)))))
    (go ENDIF6355)
    ELSE6354
    ENDIF6355
    (unless (c-true (if (c-true (ldb (byte 1 6) (m-u8 (+ v-c-6267 0)))) 0 1)) (go ELSE6356))
    (progn (set-bits (+ v-c-6267 0) 6 1 (c-bool 1)))
    (progn (setf (m-u32 (+ v-lits-6320 (* 4 (c-u32 (- v-old_size-6318 (c-u32 1)))))) 4294967295))
    (go ENDIF6357)
    ELSE6356
    ENDIF6357
    (progn v-solver-6266)
    (progn (|c/trace_and_check_clause_addition| v-solver-6266 v-c-6267 4294967295))
    (progn (|c/trace_and_check_deletion| v-solver-6266 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6266 624) 8)) (m-ptr (+ (+ v-solver-6266 624) 0))) 4)) (m-ptr (+ (+ v-solver-6266 624) 0))))
    ENDIF6314
    (progn (setf (m-ptr (+ (+ v-solver-6266 624) 8)) (m-ptr (+ (+ v-solver-6266 624) 0))))
    (return-from |c/simplify_vivification_candidate| (c-bool 0))
  )
  0))

;;; upstream/satch.c:11089:1
(defun |c/schedule_vivification_candidates| (arg-v-solver-6364 arg-v-counts-6365 arg-v-redundant-6366 arg-v-tier2-6367)
 (declare  (notinline checked-address) (type c-address arg-v-solver-6364) (type c-address arg-v-counts-6365) (type (integer 0 1) arg-v-redundant-6366) (type (integer 0 1) arg-v-tier2-6367))
 (let ((v-solver-6364 0) (v-counts-6365 0) (v-redundant-6366 0) (v-tier2-6367 0) (v-lower_glue_limit-6368 0) (v-upper_glue_limit-6369 0) (v-prioritized-6372 0) (v-prioritize-6376 0) (v-c-6382 0) (v-PTR_c-6383 0) (v-END_c-6384 0) (v-old_size-6405 0) (v-old_capacity-6406 0) (v-new_capacity-6407 0) (v-new_bytes-6408 0) (v-c-6418 0) (v-PTR_c-6419 0) (v-END_c-6420 0) (v-old_size-6445 0) (v-old_capacity-6446 0) (v-new_capacity-6447 0) (v-new_bytes-6448 0) (v-c-6468 0) (v-PTR_c-6469 0) (v-END_c-6470 0))
 (declare (type c-address v-solver-6364) (type c-address v-counts-6365) (type (integer 0 1) v-redundant-6366) (type (integer 0 1) v-tier2-6367) (type (unsigned-byte 32) v-lower_glue_limit-6368) (type (unsigned-byte 32) v-upper_glue_limit-6369) (type c-size v-prioritized-6372) (type (unsigned-byte 32) v-prioritize-6376) (type c-address v-c-6382) (type c-address v-PTR_c-6383) (type c-address v-END_c-6384) (type c-size v-old_size-6405) (type c-size v-old_capacity-6406) (type c-size v-new_capacity-6407) (type c-size v-new_bytes-6408) (type c-address v-c-6418) (type c-address v-PTR_c-6419) (type c-address v-END_c-6420) (type c-size v-old_size-6445) (type c-size v-old_capacity-6446) (type c-size v-new_capacity-6447) (type c-size v-new_bytes-6448) (type c-address v-c-6468) (type c-address v-PTR_c-6469) (type c-address v-END_c-6470) (ignorable v-solver-6364 v-counts-6365 v-redundant-6366 v-tier2-6367 v-lower_glue_limit-6368 v-upper_glue_limit-6369 v-prioritized-6372 v-prioritize-6376 v-c-6382 v-PTR_c-6383 v-END_c-6384 v-old_size-6405 v-old_capacity-6406 v-new_capacity-6407 v-new_bytes-6408 v-c-6418 v-PTR_c-6419 v-END_c-6420 v-old_size-6445 v-old_capacity-6446 v-new_capacity-6447 v-new_bytes-6448 v-c-6468 v-PTR_c-6469 v-END_c-6470))
 (tagbody
    (setf v-solver-6364 arg-v-solver-6364)
    (setf v-counts-6365 arg-v-counts-6365)
    (setf v-redundant-6366 arg-v-redundant-6366)
    (setf v-tier2-6367 arg-v-tier2-6367)
    (unless (c-true v-tier2-6367) (go ELSE6370))
    (progn (setf v-lower_glue_limit-6368 (c-u32 (c-s32 (+ 2 1)))))
    (progn (setf v-upper_glue_limit-6369 (c-u32 6)))
    (go ENDIF6371)
    ELSE6370
    (progn (setf v-lower_glue_limit-6368 (c-u32 0)))
    (progn (setf v-upper_glue_limit-6369 (c-u32 2)))
    ENDIF6371
    (setf v-prioritized-6372 (c-u64 0))
    (setf v-prioritize-6376 (c-u32 0))
    LOOP6373
    (unless (c-true (if (< v-prioritize-6376 (c-u32 2)) 1 0)) (go ENDLOOP6374))
    (unless (c-true (if (c-true v-redundant-6366) 0 1)) (go ELSE6377))
    (setf v-PTR_c-6383 (m-ptr (+ (+ v-solver-6364 672) 0)))
    (setf v-END_c-6384 (m-ptr (+ (+ v-solver-6364 672) 8)))
    LOOP6379
    (unless (c-true (if (c-true (if (/= v-PTR_c-6383 v-END_c-6384) 1 0)) (c-bool (progn (setf v-c-6382 (m-ptr v-PTR_c-6383)) 1)) 0)) (go ENDLOOP6380))
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-c-6382 0)))) (go ELSE6385))
    (go CONTINUE6381)
    ELSE6385
    (unless (c-true (ldb (byte 1 2) (m-u8 (+ v-c-6382 0)))) (go ELSE6387))
    (go CONTINUE6381)
    ELSE6387
    (unless (c-true (if (/= (ldb (byte 2 7) (m-u16 (+ v-c-6382 0))) v-prioritize-6376) 1 0)) (go ELSE6389))
    (go CONTINUE6381)
    ELSE6389
    (unless (c-true (|c/simplify_vivification_candidate| v-solver-6364 v-c-6382)) (go ELSE6391))
    (go CONTINUE6381)
    ELSE6391
    (unless (c-true v-prioritize-6376) (go ELSE6393))
    (progn (let* ( (old6396 v-prioritized-6372)) (setf v-prioritized-6372 (c-u64 (c-u64 (+ old6396 (c-u64 1))))) old6396))
    (go ENDIF6394)
    ELSE6393
    ENDIF6394
    (progn (|c/vivify_count_clause| v-c-6382 v-counts-6365))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-6364 1952) 8)) (m-ptr (+ (+ v-solver-6364 1952) 16))) 1 0)) (go ELSE6400))
    (setf v-old_size-6405 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6364 1952) 8)) (m-ptr (+ (+ v-solver-6364 1952) 0))) 8)))
    (setf v-old_capacity-6406 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6364 1952) 16)) (m-ptr (+ (+ v-solver-6364 1952) 0))) 8)))
    (setf v-new_capacity-6407 (if (c-true v-old_capacity-6406) (c-u64 (* (c-u64 2) v-old_capacity-6406)) (c-u64 1)))
    (setf v-new_bytes-6408 (c-u64 (* v-new_capacity-6407 8)))
    (progn (setf (m-ptr (+ (+ v-solver-6364 1952) 0)) (c-realloc (m-ptr (+ (+ v-solver-6364 1952) 0)) v-new_bytes-6408)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-6364 1952) 0))) 0 1)) (go ELSE6409))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-6408))
    (go ENDIF6410)
    ELSE6409
    ENDIF6410
    (progn (setf (m-ptr (+ (+ v-solver-6364 1952) 8)) (+ (m-ptr (+ (+ v-solver-6364 1952) 0)) (* 8 v-old_size-6405))))
    (progn (setf (m-ptr (+ (+ v-solver-6364 1952) 16)) (+ (m-ptr (+ (+ v-solver-6364 1952) 0)) (* 8 v-new_capacity-6407))))
    (go ENDIF6401)
    ELSE6400
    ENDIF6401
    (progn (setf (m-ptr (let* ((a6411 (+ (+ v-solver-6364 1952) 8)) (old6412 (m-ptr a6411))) (setf (m-ptr a6411) (+ old6412 (* 8 1))) old6412)) v-c-6382))
    CONTINUE6381
    (let* ( (old6414 v-PTR_c-6383)) (setf v-PTR_c-6383 (+ old6414 (* 8 1))) v-PTR_c-6383)
    (go LOOP6379)
    ENDLOOP6380
    (go ENDIF6378)
    ELSE6377
    (setf v-PTR_c-6419 (m-ptr (+ (+ v-solver-6364 696) 0)))
    (setf v-END_c-6420 (m-ptr (+ (+ v-solver-6364 696) 8)))
    LOOP6415
    (unless (c-true (if (c-true (if (/= v-PTR_c-6419 v-END_c-6420) 1 0)) (c-bool (progn (setf v-c-6418 (m-ptr v-PTR_c-6419)) 1)) 0)) (go ENDLOOP6416))
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-c-6418 0)))) (go ELSE6421))
    (go CONTINUE6417)
    ELSE6421
    (unless (c-true (if (c-true (ldb (byte 1 2) (m-u8 (+ v-c-6418 0)))) 0 1)) (go ELSE6423))
    (go CONTINUE6417)
    ELSE6423
    (unless (c-true (if (< (m-u32 (+ v-c-6418 4)) v-lower_glue_limit-6368) 1 0)) (go ELSE6425))
    (go CONTINUE6417)
    ELSE6425
    (unless (c-true (if (> (m-u32 (+ v-c-6418 4)) v-upper_glue_limit-6369) 1 0)) (go ELSE6427))
    (go CONTINUE6417)
    ELSE6427
    (unless (c-true (if (/= (ldb (byte 2 7) (m-u16 (+ v-c-6418 0))) v-prioritize-6376) 1 0)) (go ELSE6429))
    (go CONTINUE6417)
    ELSE6429
    (unless (c-true (|c/simplify_vivification_candidate| v-solver-6364 v-c-6418)) (go ELSE6431))
    (go CONTINUE6417)
    ELSE6431
    (unless (c-true v-prioritize-6376) (go ELSE6433))
    (progn (let* ( (old6436 v-prioritized-6372)) (setf v-prioritized-6372 (c-u64 (c-u64 (+ old6436 (c-u64 1))))) old6436))
    (go ENDIF6434)
    ELSE6433
    ENDIF6434
    (progn (|c/vivify_count_clause| v-c-6418 v-counts-6365))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-6364 1952) 8)) (m-ptr (+ (+ v-solver-6364 1952) 16))) 1 0)) (go ELSE6440))
    (setf v-old_size-6445 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6364 1952) 8)) (m-ptr (+ (+ v-solver-6364 1952) 0))) 8)))
    (setf v-old_capacity-6446 (the c-size (truncate (- (m-ptr (+ (+ v-solver-6364 1952) 16)) (m-ptr (+ (+ v-solver-6364 1952) 0))) 8)))
    (setf v-new_capacity-6447 (if (c-true v-old_capacity-6446) (c-u64 (* (c-u64 2) v-old_capacity-6446)) (c-u64 1)))
    (setf v-new_bytes-6448 (c-u64 (* v-new_capacity-6447 8)))
    (progn (setf (m-ptr (+ (+ v-solver-6364 1952) 0)) (c-realloc (m-ptr (+ (+ v-solver-6364 1952) 0)) v-new_bytes-6448)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-6364 1952) 0))) 0 1)) (go ELSE6449))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-6448))
    (go ENDIF6450)
    ELSE6449
    ENDIF6450
    (progn (setf (m-ptr (+ (+ v-solver-6364 1952) 8)) (+ (m-ptr (+ (+ v-solver-6364 1952) 0)) (* 8 v-old_size-6445))))
    (progn (setf (m-ptr (+ (+ v-solver-6364 1952) 16)) (+ (m-ptr (+ (+ v-solver-6364 1952) 0)) (* 8 v-new_capacity-6447))))
    (go ENDIF6441)
    ELSE6440
    ENDIF6441
    (progn (setf (m-ptr (let* ((a6451 (+ (+ v-solver-6364 1952) 8)) (old6452 (m-ptr a6451))) (setf (m-ptr a6451) (+ old6452 (* 8 1))) old6452)) v-c-6418))
    CONTINUE6417
    (let* ( (old6454 v-PTR_c-6419)) (setf v-PTR_c-6419 (+ old6454 (* 8 1))) v-PTR_c-6419)
    (go LOOP6415)
    ENDLOOP6416
    ENDIF6378
    (let* ( (old6456 v-prioritize-6376)) (setf v-prioritize-6376 (c-u32 (c-u32 (+ old6456 (c-u32 1))))) old6456)
    (go LOOP6373)
    ENDLOOP6374
    (unless (c-true v-prioritized-6372) (go ELSE6457))
    (progn v-solver-6364)
    (go ENDIF6458)
    ELSE6457
    (progn v-solver-6364)
    (setf v-PTR_c-6469 (m-ptr (+ (+ v-solver-6364 1952) 0)))
    (setf v-END_c-6470 (m-ptr (+ (+ v-solver-6364 1952) 8)))
    LOOP6465
    (unless (c-true (if (c-true (if (/= v-PTR_c-6469 v-END_c-6470) 1 0)) (c-bool (progn (setf v-c-6468 (m-ptr v-PTR_c-6469)) 1)) 0)) (go ENDLOOP6466))
    (progn (set-bits (+ v-c-6468 0) 7 2 (c-u32 1)))
    (let* ( (old6472 v-PTR_c-6469)) (setf v-PTR_c-6469 (+ old6472 (* 8 1))) v-PTR_c-6469)
    (go LOOP6465)
    ENDLOOP6466
    ENDIF6458
  )
  0))

;;; upstream/satch.c:11223:1
(defun |c/vivify_round| (arg-v-solver-6473 arg-v-round-6474 arg-v-delta-6475 arg-v-effort-6476)
 (declare  (type c-address arg-v-solver-6473) (type (unsigned-byte 32) arg-v-round-6474) (type (unsigned-byte 64) arg-v-delta-6475) (type double-float arg-v-effort-6476))
 (let ((v-solver-6473 0) (v-round-6474 0) (v-delta-6475 0) (v-effort-6476 0d0) (v-tag-6477 0) (v-scaled-6482 0) (v-start-6483 0) (v-ticks_limit-6484 0) (v-redundant-6485 0) (v-tier2-6486 0) (v-counts-6491 0) (v-schedule-6494 0) (v-scheduled-6495 0) (v-vivified-6499 0) (v-tried-6500 0) (v-c-6506 0) (v-remain-6523 0) (v-keep-6524 0) (v-prioritized-6525 0) (v-c-6531 0))
 (declare (type c-address v-solver-6473) (type (unsigned-byte 32) v-round-6474) (type (unsigned-byte 64) v-delta-6475) (type double-float v-effort-6476) (type (signed-byte 8) v-tag-6477) (type (unsigned-byte 64) v-scaled-6482) (type (unsigned-byte 64) v-start-6483) (type (unsigned-byte 64) v-ticks_limit-6484) (type (integer 0 1) v-redundant-6485) (type (integer 0 1) v-tier2-6486) (type c-address v-counts-6491) (type c-address v-schedule-6494) (type c-size v-scheduled-6495) (type c-size v-vivified-6499) (type c-size v-tried-6500) (type c-address v-c-6506) (type c-size v-remain-6523) (type (integer 0 1) v-keep-6524) (type c-size v-prioritized-6525) (type c-address v-c-6531) (ignorable v-solver-6473 v-round-6474 v-delta-6475 v-effort-6476 v-tag-6477 v-scaled-6482 v-start-6483 v-ticks_limit-6484 v-redundant-6485 v-tier2-6486 v-counts-6491 v-schedule-6494 v-scheduled-6495 v-vivified-6499 v-tried-6500 v-c-6506 v-remain-6523 v-keep-6524 v-prioritized-6525 v-c-6531))
 (tagbody
    (setf v-solver-6473 arg-v-solver-6473)
    (setf v-round-6474 arg-v-round-6474)
    (setf v-delta-6475 arg-v-delta-6475)
    (setf v-effort-6476 arg-v-effort-6476)
    (unless (c-true (if (= v-round-6474 (c-u32 2)) 1 0)) (go ELSE6478))
    (progn (setf v-tag-6477 (c-s8 117)))
    (go ENDIF6479)
    ELSE6478
    (unless (c-true (if (= v-round-6474 (c-u32 1)) 1 0)) (go ELSE6480))
    (progn (setf v-tag-6477 (c-s8 118)))
    (go ENDIF6481)
    ELSE6480
    (progn (setf v-tag-6477 (c-s8 119)))
    ENDIF6481
    ENDIF6479
    (progn (|c/flush_large_watches| v-solver-6473))
    (locally (declare (optimize (speed 1))) (setf v-scaled-6482 (values (the (unsigned-byte 64) (truncate (float (* v-effort-6476 (integer64-double v-delta-6475 nil)) 1d0))))))
    (locally (declare (optimize (speed 1))) (setf v-start-6483 (m-u64 (+ (+ v-solver-6473 1016) 440))))
    (locally (declare (optimize (speed 1))) (setf v-ticks_limit-6484 (c-u64 (+ v-start-6483 v-scaled-6482))))
    (unless (c-true (if (= v-round-6474 (c-u32 1)) 1 0)) (go ELSE6487))
    (progn (progn (setf v-redundant-6485 (c-bool 1)) (setf v-tier2-6486 (c-bool 0))))
    (go ENDIF6488)
    ELSE6487
    (unless (c-true (if (= v-round-6474 (c-u32 2)) 1 0)) (go ELSE6489))
    (progn (setf v-redundant-6485 (c-bool (setf v-tier2-6486 (c-bool 1)))))
    (go ENDIF6490)
    ELSE6489
    (progn (setf v-redundant-6485 (c-bool (setf v-tier2-6486 (c-bool 0)))))
    ENDIF6490
    ENDIF6488
    (setf v-counts-6491 (c-calloc (c-u32 (* 2 (m-u32 (+ v-solver-6473 12)))) 4))
    (unless (c-true (if (c-true v-counts-6491) 0 1)) (go ELSE6492))
    (progn (|c/fatal_error| |c/string/175|))
    (go ENDIF6493)
    ELSE6492
    ENDIF6493
    (setf v-schedule-6494 (+ v-solver-6473 1952))
    (progn (|c/schedule_vivification_candidates| v-solver-6473 v-counts-6491 (c-bool v-redundant-6485) (c-bool v-tier2-6486)))
    (setf v-scheduled-6495 (the c-size (truncate (- (m-ptr (+ v-schedule-6494 8)) (m-ptr (+ v-schedule-6494 0))) 8)))
    (progn v-solver-6473)
    (setf v-vivified-6499 (c-u64 0))
    (setf v-tried-6500 (c-u64 0))
    (progn (|c/sort_vivification_candidates| v-solver-6473 v-schedule-6494 v-counts-6491))
    (progn (|c/watch_large_clauses| v-solver-6473))
    LOOP6501
    (unless (c-true (if (c-true (if (= (m-ptr (+ v-schedule-6494 8)) (m-ptr (+ v-schedule-6494 0))) 1 0)) 0 1)) (go ENDLOOP6502))
    (unless (c-true (if (> (m-u64 (+ (+ v-solver-6473 1016) 440)) v-ticks_limit-6484) 1 0)) (go ELSE6504))
    (go ENDLOOP6502)
    ELSE6504
    (setf v-c-6506 (progn 0 (m-ptr (let* ((a6507 (+ v-schedule-6494 8)) (old6508 (m-ptr a6507))) (setf (m-ptr a6507) (- old6508 (* 8 1))) (m-ptr a6507)))))
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-c-6506 0)))) (go ELSE6509))
    (go CONTINUE6503)
    ELSE6509
    (progn (let* ( (old6512 v-tried-6500)) (setf v-tried-6500 (c-u64 (c-u64 (+ old6512 (c-u64 1))))) old6512))
    (unless (c-true (|c/vivify_clause| v-solver-6473 v-c-6506 v-counts-6491)) (go ELSE6513))
    (progn (let* ( (old6516 v-vivified-6499)) (setf v-vivified-6499 (c-u64 (c-u64 (+ old6516 (c-u64 1))))) v-vivified-6499))
    (go ENDIF6514)
    ELSE6513
    ENDIF6514
    (progn (set-bits (+ v-c-6506 0) 7 2 (c-u32 0)))
    (unless (c-true (m-u8 (+ v-solver-6473 4))) (go ELSE6517))
    (go ENDLOOP6502)
    ELSE6517
    CONTINUE6503
    (go LOOP6501)
    ENDLOOP6502
    (unless (c-true (m-u32 (+ v-solver-6473 8))) (go ELSE6519))
    (progn (|c/backtrack| v-solver-6473 (c-u32 0)))
    (go ENDIF6520)
    ELSE6519
    ENDIF6520
    (unless (c-true (if (c-true (m-u8 (+ v-solver-6473 4))) 0 1)) (go ELSE6521))
    (setf v-remain-6523 (the c-size (truncate (- (m-ptr (+ v-schedule-6494 8)) (m-ptr (+ v-schedule-6494 0))) 8)))
    (setf v-keep-6524 (c-bool 1))
    (setf v-prioritized-6525 (c-u64 0))
    (unless (c-true v-remain-6523) (go ELSE6526))
    LOOP6528
    (unless (c-true (if (c-true (if (= (m-ptr (+ v-schedule-6494 8)) (m-ptr (+ v-schedule-6494 0))) 1 0)) 0 1)) (go ENDLOOP6529))
    (setf v-c-6531 (progn 0 (m-ptr (let* ((a6532 (+ v-schedule-6494 8)) (old6533 (m-ptr a6532))) (setf (m-ptr a6532) (- old6533 (* 8 1))) (m-ptr a6532)))))
    (unless (c-true (if (c-true (ldb (byte 2 7) (m-u16 (+ v-c-6531 0)))) 0 1)) (go ELSE6534))
    (go CONTINUE6530)
    ELSE6534
    (progn (let* ( (old6537 v-prioritized-6525)) (setf v-prioritized-6525 (c-u64 (c-u64 (+ old6537 (c-u64 1))))) old6537))
    CONTINUE6530
    (go LOOP6528)
    ENDLOOP6529
    (unless (c-true (if (c-true v-prioritized-6525) 0 1)) (go ELSE6538))
    (progn v-solver-6473)
    (go ENDIF6539)
    ELSE6538
    (progn v-solver-6473)
    ENDIF6539
    (go ENDIF6527)
    ELSE6526
    (progn v-solver-6473)
    ENDIF6527
    (go ENDIF6522)
    ELSE6521
    ENDIF6522
    (progn (setf (m-ptr (+ v-schedule-6494 8)) (m-ptr (+ v-schedule-6494 0))))
    (progn (|c/report| v-solver-6473 (c-u32 1) v-tag-6477))
    (progn (c-free v-counts-6491))
    (return-from |c/vivify_round| v-scheduled-6495)
  )
  0))

;;; upstream/satch.c:11418:1
(defun |c/vivify_redundant_tier1| (arg-v-solver-6552 arg-v-delta-6553 arg-v-effort-6554)
 (declare  (type c-address arg-v-solver-6552) (type (unsigned-byte 64) arg-v-delta-6553) (type double-float arg-v-effort-6554))
 (let ((v-solver-6552 0) (v-delta-6553 0) (v-effort-6554 0d0))
 (declare (type c-address v-solver-6552) (type (unsigned-byte 64) v-delta-6553) (type double-float v-effort-6554) (ignorable v-solver-6552 v-delta-6553 v-effort-6554))
 (tagbody
    (setf v-solver-6552 arg-v-solver-6552)
    (setf v-delta-6553 arg-v-delta-6553)
    (setf v-effort-6554 arg-v-effort-6554)
    (return-from |c/vivify_redundant_tier1| (|c/vivify_round| v-solver-6552 (c-u32 1) v-delta-6553 v-effort-6554))
  )
  0))

;;; upstream/satch.c:11426:1
(defun |c/vivify_redundant_tier2| (arg-v-solver-6555 arg-v-delta-6556 arg-v-effort-6557)
 (declare  (type c-address arg-v-solver-6555) (type (unsigned-byte 64) arg-v-delta-6556) (type double-float arg-v-effort-6557))
 (let ((v-solver-6555 0) (v-delta-6556 0) (v-effort-6557 0d0))
 (declare (type c-address v-solver-6555) (type (unsigned-byte 64) v-delta-6556) (type double-float v-effort-6557) (ignorable v-solver-6555 v-delta-6556 v-effort-6557))
 (tagbody
    (setf v-solver-6555 arg-v-solver-6555)
    (setf v-delta-6556 arg-v-delta-6556)
    (setf v-effort-6557 arg-v-effort-6557)
    (return-from |c/vivify_redundant_tier2| (|c/vivify_round| v-solver-6555 (c-u32 2) v-delta-6556 v-effort-6557))
  )
  0))

;;; upstream/satch.c:11433:1
(defun |c/vivify_irredundant| (arg-v-solver-6558 arg-v-redundant_scheduled-6559 arg-v-delta-6560 arg-v-effort-6561)
 (declare  (type c-address arg-v-solver-6558) (type (unsigned-byte 64) arg-v-redundant_scheduled-6559) (type (unsigned-byte 64) arg-v-delta-6560) (type double-float arg-v-effort-6561))
 (let ((v-solver-6558 0) (v-redundant_scheduled-6559 0) (v-delta-6560 0) (v-effort-6561 0d0) (v-factor-6562 0d0) (v-limit-6563 0) (v-irredundant_candidates-6564 0) (v-c-6568 0) (v-PTR_c-6569 0) (v-END_c-6570 0))
 (declare (type c-address v-solver-6558) (type (unsigned-byte 64) v-redundant_scheduled-6559) (type (unsigned-byte 64) v-delta-6560) (type double-float v-effort-6561) (type double-float v-factor-6562) (type (unsigned-byte 64) v-limit-6563) (type (unsigned-byte 64) v-irredundant_candidates-6564) (type c-address v-c-6568) (type c-address v-PTR_c-6569) (type c-address v-END_c-6570) (ignorable v-solver-6558 v-redundant_scheduled-6559 v-delta-6560 v-effort-6561 v-factor-6562 v-limit-6563 v-irredundant_candidates-6564 v-c-6568 v-PTR_c-6569 v-END_c-6570))
 (tagbody
    (setf v-solver-6558 arg-v-solver-6558)
    (setf v-redundant_scheduled-6559 arg-v-redundant_scheduled-6559)
    (setf v-delta-6560 arg-v-delta-6560)
    (setf v-effort-6561 arg-v-effort-6561)
    (setf v-factor-6562 (float 10 1d0))
    (locally (declare (optimize (speed 1))) (setf v-limit-6563 (values (the (unsigned-byte 64) (truncate (float (* v-factor-6562 (integer64-double v-redundant_scheduled-6559 nil)) 1d0))))))
    (locally (declare (optimize (speed 1))) (setf v-irredundant_candidates-6564 (c-u64 0)))
    (setf v-PTR_c-6569 (m-ptr (+ (+ v-solver-6558 672) 0)))
    (setf v-END_c-6570 (m-ptr (+ (+ v-solver-6558 672) 8)))
    LOOP6565
    (unless (c-true (if (c-true (if (/= v-PTR_c-6569 v-END_c-6570) 1 0)) (c-bool (progn (setf v-c-6568 (m-ptr v-PTR_c-6569)) 1)) 0)) (go ENDLOOP6566))
    (unless (c-true (ldb (byte 1 0) (m-u8 (+ v-c-6568 0)))) (go ELSE6571))
    (go CONTINUE6567)
    ELSE6571
    (unless (c-true (if (> (let* ( (old6576 v-irredundant_candidates-6564)) (setf v-irredundant_candidates-6564 (c-u64 (c-u64 (+ old6576 (c-u64 1))))) v-irredundant_candidates-6564) v-limit-6563) 1 0)) (go ELSE6573))
    (go ENDLOOP6566)
    ELSE6573
    CONTINUE6567
    (let* ( (old6578 v-PTR_c-6569)) (setf v-PTR_c-6569 (+ old6578 (* 8 1))) v-PTR_c-6569)
    (go LOOP6565)
    ENDLOOP6566
    (unless (c-true (if (> v-irredundant_candidates-6564 v-limit-6563) 1 0)) (go ELSE6579))
    (progn v-solver-6558)
    (go ENDIF6580)
    ELSE6579
    (progn v-solver-6558)
    (unless (c-true (if (> v-irredundant_candidates-6564 v-redundant_scheduled-6559) 1 0)) (go ELSE6587))
    (progn v-solver-6558)
    (go ENDIF6588)
    ELSE6587
    ENDIF6588
    (progn (|c/vivify_round| v-solver-6558 (c-u32 3) v-delta-6560 v-effort-6561))
    ENDIF6580
  )
  0))

;;; upstream/satch.c:11474:1
(defun |c/vivify_adjustment| (arg-v-solver-6592)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-solver-6592))
 (let ((v-solver-6592 0))
 (declare (type c-address v-solver-6592) (ignorable v-solver-6592))
 (tagbody
    (setf v-solver-6592 arg-v-solver-6592)
    (return-from |c/vivify_adjustment| (values (the (unsigned-byte 64) (truncate (|c/nlogn| (c-u64 (+ (c-u64 (+ (c-u64 1) (m-u64 (+ (+ v-solver-6592 1016) 120)))) (m-u64 (+ (+ v-solver-6592 1016) 208)))))))))
  )
  0))

;;; upstream/satch.c:11481:1
(defun |c/really_vivify| (arg-v-solver-6593)
 (declare  (type c-address arg-v-solver-6593))
 (let ((v-solver-6593 0) (v-limit-6594 0) (v-search_ticks-6595 0))
 (declare (type c-address v-solver-6593) (type (unsigned-byte 64) v-limit-6594) (type (unsigned-byte 64) v-search_ticks-6595) (ignorable v-solver-6593 v-limit-6594 v-search_ticks-6595))
 (tagbody
    (setf v-solver-6593 arg-v-solver-6593)
    (locally (declare (optimize (speed 1))) (setf v-limit-6594 (|c/vivify_adjustment| v-solver-6593)))
    (locally (declare (optimize (speed 1))) (setf v-search_ticks-6595 (m-u64 (+ (+ v-solver-6593 1016) 360))))
    (return-from |c/really_vivify| (c-bool (if (< v-limit-6594 v-search_ticks-6595) 1 0)))
  )
  0))

;;; upstream/satch.c:11499:1
(defun |c/vivify| (arg-v-solver-6596)
 (declare  (type c-address arg-v-solver-6596))
 (let ((v-solver-6596 0) (v-vivifications-6601 0) (v-interval-6604 0) (v-limits-6605 0) (v-statistics-6610 0) (v-last-6611 0) (v-ticks-6612 0) (v-adjustment-6613 0) (v-delta-6614 0) (v-redundant_scheduled-6615 0) (v-sum-6616 0d0) (v-vivified-6617 0) (v-limit-6624 0))
 (declare (type c-address v-solver-6596) (type (unsigned-byte 64) v-vivifications-6601) (type (unsigned-byte 64) v-interval-6604) (type c-address v-limits-6605) (type c-address v-statistics-6610) (type (unsigned-byte 64) v-last-6611) (type (unsigned-byte 64) v-ticks-6612) (type (unsigned-byte 64) v-adjustment-6613) (type (unsigned-byte 64) v-delta-6614) (type (unsigned-byte 64) v-redundant_scheduled-6615) (type double-float v-sum-6616) (type (unsigned-byte 64) v-vivified-6617) (type (unsigned-byte 64) v-limit-6624) (ignorable v-solver-6596 v-vivifications-6601 v-interval-6604 v-limits-6605 v-statistics-6610 v-last-6611 v-ticks-6612 v-adjustment-6613 v-delta-6614 v-redundant_scheduled-6615 v-sum-6616 v-vivified-6617 v-limit-6624))
 (tagbody
    (setf v-solver-6596 arg-v-solver-6596)
    (unless (c-true (m-u8 (+ v-solver-6596 4))) (go ELSE6597))
    (return-from |c/vivify| 20)
    ELSE6597
    (unless (c-true (m-u32 (+ v-solver-6596 8))) (go ELSE6599))
    (progn (|c/update_phases_and_backtrack_to_root_level| v-solver-6596))
    (go ENDIF6600)
    ELSE6599
    ENDIF6600
    (locally (declare (optimize (speed 1))) (setf v-vivifications-6601 (progn 0 (let* ((a6602 (+ (+ v-solver-6596 1016) 416)) (old6603 (m-u64 a6602))) (setf (m-u64 a6602) (c-u64 (c-u64 (+ old6603 (c-u64 1))))) (m-u64 a6602)))))
    (locally (declare (optimize (speed 1))) (setf v-interval-6604 (values (the (unsigned-byte 64) (truncate (|c/scale_interval| (c-u64 1000) (function-handle #'|c/nlogn|) v-vivifications-6601))))))
    (setf v-limits-6605 (+ v-solver-6596 720))
    (progn (setf (m-u64 (+ (+ v-limits-6605 40) 0)) (c-u64 (+ (m-u64 (+ (+ v-solver-6596 1016) 48)) v-interval-6604))))
    (unless (c-true (if (c-true (m-u64 (+ (+ v-solver-6596 1016) 208))) 0 1)) (go ELSE6606))
    (return-from |c/vivify| 0)
    ELSE6606
    (unless (c-true (if (c-true (|c/really_vivify| v-solver-6596)) 0 1)) (go ELSE6608))
    (return-from |c/vivify| 0)
    ELSE6608
    (progn (|c/start_profiling| v-solver-6596 (+ (+ v-solver-6596 1472) 216)))
    (progn (setf (m-u8 (+ v-solver-6596 1984)) (c-bool 1)))
    (setf v-statistics-6610 (+ v-solver-6596 1016))
    (locally (declare (optimize (speed 1))) (setf v-last-6611 (c-u64 (- (m-u64 (+ v-statistics-6610 360)) (m-u64 (+ (+ v-limits-6605 40) 16))))))
    (locally (declare (optimize (speed 1))) (setf v-ticks-6612 (values (the (unsigned-byte 64) (truncate (if (c-true (if (< (integer64-double v-last-6611 nil) 10000.0d0) 1 0)) 10000.0d0 (integer64-double v-last-6611 nil)))))))
    (locally (declare (optimize (speed 1))) (setf v-adjustment-6613 (|c/vivify_adjustment| v-solver-6596)))
    (locally (declare (optimize (speed 1))) (setf v-delta-6614 (values (the (unsigned-byte 64) (truncate (float (+ (float (* (integer64-double (c-u64 (* v-ticks-6612 (c-u64 100))) nil) 0.001d0) 1d0) (integer64-double v-adjustment-6613 nil)) 1d0))))))
    (progn (when (>= (m-u32 (+ v-solver-6596 884)) (c-u32 2)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-6596 (c-u32 2) |c/string/176| v-vivifications-6601 |c/string/162| (c-u64 (+ (m-u64 (+ (+ v-solver-6596 1016) 360)) v-delta-6614)) (float (* (float 100 1d0) 0.001d0) 1d0) v-delta-6614))))
    (locally (declare (optimize (speed 1))) (setf v-redundant_scheduled-6615 (c-u64 0)))
    (setf v-sum-6616 (float (c-s32 (+ (c-s32 (+ 3 6)) 1)) 1d0))
    (locally (declare (optimize (speed 1))) (setf v-vivified-6617 (m-u64 (+ (+ v-solver-6596 1016) 408))))
    (progn (setf v-redundant_scheduled-6615 (c-u64 (c-u64 (+ v-redundant_scheduled-6615 (|c/vivify_redundant_tier2| v-solver-6596 v-delta-6614 (float (/ (float 6 1d0) v-sum-6616) 1d0)))))))
    (unless (c-true (if (c-true (m-u8 (+ v-solver-6596 4))) 0 1)) (go ELSE6619))
    (progn (setf v-redundant_scheduled-6615 (c-u64 (c-u64 (+ v-redundant_scheduled-6615 (|c/vivify_redundant_tier1| v-solver-6596 v-delta-6614 (float (/ (float 3 1d0) v-sum-6616) 1d0)))))))
    (unless (c-true (if (c-true (m-u8 (+ v-solver-6596 4))) 0 1)) (go ELSE6622))
    (progn (|c/vivify_irredundant| v-solver-6596 v-redundant_scheduled-6615 v-delta-6614 (float (/ (float 1 1d0) v-sum-6616) 1d0)))
    (go ENDIF6623)
    ELSE6622
    ENDIF6623
    (go ENDIF6620)
    ELSE6619
    ENDIF6620
    (locally (declare (optimize (speed 1))) (setf v-limit-6624 (m-u64 (+ (+ v-limits-6605 40) 0))))
    (progn (setf (m-u64 (+ (+ v-limits-6605 40) 16)) (m-u64 (+ (+ v-solver-6596 1016) 360))))
    (progn (when (>= (m-u32 (+ v-solver-6596 884)) (c-u32 2)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-6596 (c-u32 2) |c/string/176| v-vivifications-6601 |c/string/177| (c-u64 (- (m-u64 (+ (+ v-solver-6596 1016) 408)) v-vivified-6617)) v-limit-6624 v-interval-6604))))
    (progn (setf (m-u8 (+ v-solver-6596 1984)) (c-bool 0)))
    (progn (setf (m-ptr (+ (+ v-solver-6596 1952) 8)) (m-ptr (+ (+ v-solver-6596 1952) 0))))
    (progn (|c/stop_profiling| v-solver-6596 (+ (+ v-solver-6596 1472) 216) (|c/process_time|)))
    (unless (c-true (m-u8 (+ v-solver-6596 4))) (go ELSE6628))
    (return-from |c/vivify| 20)
    ELSE6628
    (return-from |c/vivify| 0)
  )
  0))

;;; upstream/satch.c:11593:1
(defun |c/vivifying| (arg-v-solver-6630)
 (declare  (type c-address arg-v-solver-6630))
 (let ((v-solver-6630 0))
 (declare (type c-address v-solver-6630) (ignorable v-solver-6630))
 (tagbody
    (setf v-solver-6630 arg-v-solver-6630)
    (return-from |c/vivifying| (c-bool (if (< (m-u64 (+ (+ (+ v-solver-6630 720) 40) 0)) (m-u64 (+ (+ v-solver-6630 1016) 48))) 1 0)))
  )
  0))

;;; upstream/satch.c:11612:1
(defun |c/init_limits| (arg-v-solver-6631)
 (declare  (type c-address arg-v-solver-6631))
 (let ((v-solver-6631 0))
 (declare (type c-address v-solver-6631) (ignorable v-solver-6631))
 (tagbody
    (setf v-solver-6631 arg-v-solver-6631)
    (progn (setf (m-u64 (+ (+ (+ v-solver-6631 720) 0) 0)) (c-u64 500)))
    (progn (setf (m-u64 (+ (+ (+ v-solver-6631 720) 64) 0)) (c-u64 300)))
    (progn (setf (m-u64 (+ (+ v-solver-6631 720) 80)) (values (the (unsigned-byte 64) (truncate 1000.0d0)))))
    (progn (setf (m-u64 (+ (+ v-solver-6631 720) 88)) (c-u64 1)))
    (progn (setf (m-u64 (+ (+ (+ v-solver-6631 720) 96) 0)) (values (the (unsigned-byte 64) (truncate 1000.0d0)))))
    (progn (setf (m-u64 (+ (+ (+ (+ v-solver-6631 720) 96) 8) 0)) (values (the (unsigned-byte 64) (truncate 100000000.0d0)))))
    (progn (setf (m-u64 (+ (+ (+ v-solver-6631 720) 40) 0)) (c-u64 1000)))
    (progn v-solver-6631)
  )
  0))

;;; upstream/satch.c:11657:1
(defun |c/solve| (arg-v-solver-6632 arg-v-delta_limit-6633)
 (declare  (type c-address arg-v-solver-6632) (type (signed-byte 32) arg-v-delta_limit-6633))
 (let ((v-solver-6632 0) (v-delta_limit-6633 0) (v-res-6634 0) (v-conflict-6635 0) (v-conflict_limit-6636 0))
 (declare (type c-address v-solver-6632) (type (signed-byte 32) v-delta_limit-6633) (type (signed-byte 32) v-res-6634) (type c-address v-conflict-6635) (type (unsigned-byte 64) v-conflict_limit-6636) (ignorable v-solver-6632 v-delta_limit-6633 v-res-6634 v-conflict-6635 v-conflict_limit-6636))
 (tagbody
    (setf v-solver-6632 arg-v-solver-6632)
    (setf v-delta_limit-6633 arg-v-delta_limit-6633)
    (progn (|c/start_profiling| v-solver-6632 (+ (+ v-solver-6632 1472) 96)))
    (progn (|c/report| v-solver-6632 (c-u32 1) 42))
    (setf v-res-6634 (if (c-true (m-u8 (+ v-solver-6632 4))) 20 0))
    (locally (declare (optimize (speed 1))) (setf v-conflict_limit-6636 (if (c-true (if (< v-delta_limit-6633 0) 1 0)) 18446744073709551615 (c-u64 (+ (m-u64 (+ (+ v-solver-6632 1016) 48)) (c-u64 v-delta_limit-6633))))))
    (progn (|c/start_mode| v-solver-6632))
    LOOP6637
    (unless (c-true (if (c-true v-res-6634) 0 1)) (go ENDLOOP6638))
    (unless (c-true (setf v-conflict-6635 (|c/boolean_constraint_propagation| v-solver-6632))) (go ELSE6640))
    (unless (c-true (if (c-true (|c/analyze_conflict| v-solver-6632 v-conflict-6635)) 0 1)) (go ELSE6642))
    (progn (setf v-res-6634 20))
    (go ENDIF6643)
    ELSE6642
    ENDIF6643
    (go ENDIF6641)
    ELSE6640
    (unless (c-true (m-u8 (+ v-solver-6632 5))) (go ELSE6644))
    (progn (|c/iterate| v-solver-6632))
    (go ENDIF6645)
    ELSE6644
    ENDIF6645
    (unless (c-true (if (c-true (m-u32 (+ v-solver-6632 24))) 0 1)) (go ELSE6646))
    (progn (setf v-res-6634 10))
    (go ENDIF6647)
    ELSE6646
    (unless (c-true (if (>= (m-u64 (+ (+ v-solver-6632 1016) 48)) v-conflict_limit-6636) 1 0)) (go ELSE6648))
    (go ENDLOOP6638)
    ELSE6648
    (unless (c-true (|c/restarting| v-solver-6632)) (go ELSE6650))
    (progn (|c/restart| v-solver-6632))
    (go ENDIF6651)
    ELSE6650
    (unless (c-true (|c/switching| v-solver-6632)) (go ELSE6652))
    (progn (|c/switch_mode| v-solver-6632))
    (go ENDIF6653)
    ELSE6652
    (unless (c-true (|c/reducing| v-solver-6632)) (go ELSE6654))
    (progn (|c/reduce| v-solver-6632))
    (go ENDIF6655)
    ELSE6654
    (unless (c-true (|c/rephasing| v-solver-6632)) (go ELSE6656))
    (progn (|c/rephase| v-solver-6632))
    (go ENDIF6657)
    ELSE6656
    (unless (c-true (|c/eliminating| v-solver-6632)) (go ELSE6658))
    (progn (setf v-res-6634 (|c/eliminate_variables| v-solver-6632)))
    (go ENDIF6659)
    ELSE6658
    (unless (c-true (|c/vivifying| v-solver-6632)) (go ELSE6660))
    (progn (setf v-res-6634 (|c/vivify| v-solver-6632)))
    (go ENDIF6661)
    ELSE6660
    (progn (|c/decide| v-solver-6632))
    ENDIF6661
    ENDIF6659
    ENDIF6657
    ENDIF6655
    ENDIF6653
    ENDIF6651
    ENDIF6647
    ENDIF6641
    (go LOOP6637)
    ENDLOOP6638
    (progn (|c/stop_mode| v-solver-6632))
    (progn (|c/report| v-solver-6632 (c-u32 1) (if (c-true (if (c-true v-res-6634) 0 1)) 63 (if (c-true (if (= v-res-6634 10) 1 0)) 49 48))))
    (progn (|c/stop_profiling| v-solver-6632 (+ (+ v-solver-6632 1472) 96) (|c/process_time|)))
    (return-from |c/solve| v-res-6634)
  )
  0))

;;; upstream/satch.c:11779:1
(defun |c/invalid_usage| (arg-v-message-6662 arg-v-function-6663)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-message-6662) (type c-address arg-v-function-6663))
 (let ((v-message-6662 0) (v-function-6663 0) (v-colors-6664 0) (v-terminal_file-6665 0))
 (declare (type c-address v-message-6662) (type c-address v-function-6663) (type (integer 0 1) v-colors-6664) (type c-address v-terminal_file-6665) (ignorable v-message-6662 v-function-6663 v-colors-6664 v-terminal_file-6665))
 (tagbody
    (setf v-message-6662 arg-v-message-6662)
    (setf v-function-6663 arg-v-function-6663)
    (setf v-colors-6664 (c-bool (c-isatty 2)))
    (setf v-terminal_file-6665 (if (c-true (if (= 2 1) 1 0)) 1 2))
    (progn v-terminal_file-6665)
    (progn (c-fprintf 2 |c/string/178| (if (c-true v-colors-6664) |c/string/1| |c/string/2|) (if (c-true v-colors-6664) |c/string/3| |c/string/2|) (if (c-true v-colors-6664) |c/string/4| |c/string/2|) v-function-6663 v-message-6662))
    (progn (c-fflush 2))
    (progn (c-abort))
  )
  0))

;;; upstream/satch.c:11820:1
(defun |c/internal_init| ()
 (declare  )
 (let ((v-solver-6666 0))
 (declare (type c-address v-solver-6666) (ignorable v-solver-6666))
 (tagbody
    (setf v-solver-6666 (c-calloc (c-u64 1) 1992))
    (unless (c-true (if (c-true v-solver-6666) 0 1)) (go ELSE6667))
    (progn (|c/fatal_error| |c/string/179|))
    (go ENDIF6668)
    ELSE6667
    ENDIF6668
    (progn (|c/init_binary| v-solver-6666))
    (progn (setf (m-f64 (+ (+ (+ v-solver-6666 304) (* 56 0)) 48)) 1.15d0))
    (progn (setf (m-f64 (+ (+ (+ v-solver-6666 304) (* 56 1)) 48)) 1.05d0))
    (progn (|c/init_averages| v-solver-6666))
    (progn (|c/init_limits| v-solver-6666))
    (progn (|c/init_profiles| v-solver-6666))
    (return-from |c/internal_init| v-solver-6666)
  )
  0))

