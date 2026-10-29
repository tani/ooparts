(in-package #:ooparts/sat/impl)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))
;;; upstream/satch.c:2847:1
(defun |c/heap_score| (arg-v-heap-644 arg-v-idx-645)
 (declare (optimize (speed 1) (safety 1)) (type c-address arg-v-heap-644) (type (unsigned-byte 32) arg-v-idx-645))
 (let ((v-heap-644 0) (v-idx-645 0))
 (declare (type c-address v-heap-644) (type (unsigned-byte 32) v-idx-645) (ignorable v-heap-644 v-idx-645))
 (tagbody
    (setf v-heap-644 arg-v-heap-644)
    (setf v-idx-645 arg-v-idx-645)
    (return-from |c/heap_score| (m-f64 (+ (m-ptr (+ v-heap-644 24)) (* 8 v-idx-645))))
  )
  0))

;;; upstream/satch.c:2853:1
(defun |c/rescore_scores| (arg-v-solver-646 arg-v-scores-647)
 (declare  (type c-address arg-v-solver-646) (type c-address arg-v-scores-647))
 (let ((v-solver-646 0) (v-scores-647 0) (v-rescored-648 0) (v-size-651 0) (v-score-652 0) (v-max_score-653 0d0) (v-idx-657 0) (v-tmp_score-658 0d0) (v-idx-666 0))
 (declare (type c-address v-solver-646) (type c-address v-scores-647) (type (unsigned-byte 64) v-rescored-648) (type (unsigned-byte 32) v-size-651) (type c-address v-score-652) (type double-float v-max_score-653) (type (unsigned-byte 32) v-idx-657) (type double-float v-tmp_score-658) (type (unsigned-byte 32) v-idx-666) (ignorable v-solver-646 v-scores-647 v-rescored-648 v-size-651 v-score-652 v-max_score-653 v-idx-657 v-tmp_score-658 v-idx-666))
 (tagbody
    (setf v-solver-646 arg-v-solver-646)
    (setf v-scores-647 arg-v-scores-647)
    (locally (declare (optimize (speed 1))) (setf v-rescored-648 (progn 0 (let* ((a649 (+ (+ v-solver-646 1016) 240)) (old650 (m-u64 a649))) (setf (m-u64 a649) (c-u64 (c-u64 (+ old650 (c-u64 1))))) (m-u64 a649)))))
    (setf v-size-651 (m-u32 (+ v-solver-646 12)))
    (setf v-score-652 (m-ptr (+ v-scores-647 24)))
    (setf v-max_score-653 (m-f64 (+ v-score-652 (* 8 0))))
    (setf v-idx-657 (c-u32 1))
    LOOP654
    (unless (c-true (if (< v-idx-657 v-size-651) 1 0)) (go ENDLOOP655))
    (setf v-tmp_score-658 (m-f64 (+ v-score-652 (* 8 v-idx-657))))
    (unless (c-true (if (> v-tmp_score-658 v-max_score-653) 1 0)) (go ELSE659))
    (progn (setf v-max_score-653 v-tmp_score-658))
    (go ENDIF660)
    ELSE659
    ENDIF660
    (let* ( (old662 v-idx-657)) (setf v-idx-657 (c-u32 (c-u32 (+ old662 (c-u32 1))))) old662)
    (go LOOP654)
    ENDLOOP655
    (progn (when (>= (m-u32 (+ v-solver-646 884)) (c-u32 2)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-646 (c-u32 2) |c/string/99| v-rescored-648 |c/string/100| v-max_score-653))))
    (setf v-idx-666 (c-u32 0))
    LOOP663
    (unless (c-true (if (< v-idx-666 v-size-651) 1 0)) (go ENDLOOP664))
    (progn (let ((a667 (+ v-score-652 (* 8 v-idx-666)))) (setf (m-f64 a667) (float (float (/ (m-f64 a667) v-max_score-653) 1d0) 1d0))))
    (let* ( (old669 v-idx-666)) (setf v-idx-666 (c-u32 (c-u32 (+ old669 (c-u32 1))))) old669)
    (go LOOP663)
    ENDLOOP664
    (progn (let ((a670 (+ v-scores-647 40))) (setf (m-f64 a670) (float (float (/ (m-f64 a670) v-max_score-653) 1d0) 1d0))))
    (progn (when (>= (m-u32 (+ v-solver-646 884)) (c-u32 3)) (locally (declare (optimize (speed 1) (safety 1))) (|c/message| v-solver-646 (c-u32 3) |c/string/99| v-rescored-648 |c/string/101| (m-f64 (+ v-scores-647 40))))))
  )
  0))

;;; upstream/satch.c:2881:1
(defun |c/resize_heap| (arg-v-heap-671 arg-v-old_capacity-672 arg-v-new_capacity-673)
 (declare  (type c-address arg-v-heap-671) (type c-size arg-v-old_capacity-672) (type c-size arg-v-new_capacity-673))
 (let ((v-heap-671 0) (v-old_capacity-672 0) (v-new_capacity-673 0) (v-size-674 0) (v-new_bytes-678 0) (v-new_bytes-684 0) (v-size-690 0) (v-old_bytes-691 0) (v-new_bytes-692 0) (v-chunk-693 0))
 (declare (type c-address v-heap-671) (type c-size v-old_capacity-672) (type c-size v-new_capacity-673) (type c-size v-size-674) (type c-size v-new_bytes-678) (type c-size v-new_bytes-684) (type c-size v-size-690) (type c-size v-old_bytes-691) (type c-size v-new_bytes-692) (type c-address v-chunk-693) (ignorable v-heap-671 v-old_capacity-672 v-new_capacity-673 v-size-674 v-new_bytes-678 v-new_bytes-684 v-size-690 v-old_bytes-691 v-new_bytes-692 v-chunk-693))
 (tagbody
    (setf v-heap-671 arg-v-heap-671)
    (setf v-old_capacity-672 arg-v-old_capacity-672)
    (setf v-new_capacity-673 arg-v-new_capacity-673)
    (setf v-size-674 (the c-size (truncate (- (m-ptr (+ v-heap-671 8)) (m-ptr (+ v-heap-671 0))) 4)))
    (setf v-new_bytes-678 (c-u64 (* v-new_capacity-673 4)))
    (progn (setf (m-ptr (+ v-heap-671 0)) (c-realloc (m-ptr (+ v-heap-671 0)) v-new_bytes-678)))
    (unless (c-true (if (c-true (m-ptr (+ v-heap-671 0))) 0 1)) (go ELSE679))
    (progn (|c/out_of_memory| v-new_bytes-678))
    (go ENDIF680)
    ELSE679
    ENDIF680
    (progn (setf (m-ptr (+ v-heap-671 8)) (+ (m-ptr (+ v-heap-671 0)) (* 4 v-size-674))))
    (setf v-new_bytes-684 (c-u64 (* v-new_capacity-673 4)))
    (progn (setf (m-ptr (+ v-heap-671 16)) (c-realloc (m-ptr (+ v-heap-671 16)) v-new_bytes-684)))
    (unless (c-true (if (c-true (m-ptr (+ v-heap-671 16))) 0 1)) (go ELSE685))
    (progn (|c/out_of_memory| v-new_bytes-684))
    (go ENDIF686)
    ELSE685
    ENDIF686
    (setf v-size-690 8)
    (setf v-old_bytes-691 (if (c-true v-old_capacity-672) (c-u64 (* (c-u64 (* (c-u64 1) (c-u64 (+ v-old_capacity-672 (c-u64 0))))) v-size-690)) (c-u64 0)))
    (setf v-new_bytes-692 (c-u64 (* (c-u64 (* (c-u64 1) (c-u64 (+ v-new_capacity-673 (c-u64 0))))) v-size-690)))
    (setf v-chunk-693 (c-calloc v-new_bytes-692 (c-u64 1)))
    (unless (c-true (if (c-true v-chunk-693) 0 1)) (go ELSE694))
    (progn (|c/out_of_memory| v-new_bytes-692))
    (go ENDIF695)
    ELSE694
    ENDIF695
    (unless (c-true v-old_bytes-691) (go ELSE696))
    (progn (c-memcpy v-chunk-693 (m-ptr (+ v-heap-671 24)) v-old_bytes-691))
    (go ENDIF697)
    ELSE696
    ENDIF697
    (progn (c-free (m-ptr (+ v-heap-671 24))))
    (progn (setf (m-ptr (+ v-heap-671 24)) v-chunk-693))
  )
  0))

;;; upstream/satch.c:2891:1
(defun |c/release_heap| (arg-v-heap-698)
 (declare  (type c-address arg-v-heap-698))
 (let ((v-heap-698 0))
 (declare (type c-address v-heap-698) (ignorable v-heap-698))
 (tagbody
    (setf v-heap-698 arg-v-heap-698)
    (progn (c-free (m-ptr (+ v-heap-698 0))))
    (progn (c-free (m-ptr (+ v-heap-698 16))))
    (progn (c-free (m-ptr (+ v-heap-698 24))))
    (progn (c-memset v-heap-698 0 56))
  )
  0))

;;; upstream/satch.c:2900:1
(defun |c/init_scores| (arg-v-solver-699 arg-v-scores-700)
 (declare  (type c-address arg-v-solver-699) (type c-address arg-v-scores-700))
 (let ((v-solver-699 0) (v-scores-700 0))
 (declare (type c-address v-solver-699) (type c-address v-scores-700) (ignorable v-solver-699 v-scores-700))
 (tagbody
    (setf v-solver-699 arg-v-solver-699)
    (setf v-scores-700 arg-v-scores-700)
    (unless (c-true (if (c-true (m-f64 (+ v-scores-700 40))) 0 1)) (go ELSE701))
    (progn (setf (m-f64 (+ v-scores-700 40)) 1.0d0))
    (go ENDIF702)
    ELSE701
    ENDIF702
    (unless (c-true (if (c-true (m-ptr (+ v-scores-700 0))) 0 1)) (go ELSE703))
    (progn (|c/resize_heap| v-scores-700 (c-u64 0) (m-size (+ v-solver-699 16))))
    (go ENDIF704)
    ELSE703
    ENDIF704
  )
  0))

;;; upstream/satch.c:2927:1
(defun |c/activate_scores| (arg-v-solver-705 arg-v-scores-706 arg-v-activate-707)
 (declare  (type c-address arg-v-solver-705) (type c-address arg-v-scores-706) (type c-address arg-v-activate-707))
 (let ((v-solver-705 0) (v-scores-706 0) (v-activate-707 0) (v-stable-708 0) (v-pos-712 0) (v-score-713 0) (v-idx-717 0) (v-PTR_idx-718 0) (v-END_idx-719 0) (v-activated-720 0))
 (declare (type c-address v-solver-705) (type c-address v-scores-706) (type c-address v-activate-707) (type (unsigned-byte 32) v-stable-708) (type c-address v-pos-712) (type c-address v-score-713) (type (unsigned-byte 32) v-idx-717) (type c-address v-PTR_idx-718) (type c-address v-END_idx-719) (type (unsigned-byte 64) v-activated-720) (ignorable v-solver-705 v-scores-706 v-activate-707 v-stable-708 v-pos-712 v-score-713 v-idx-717 v-PTR_idx-718 v-END_idx-719 v-activated-720))
 (tagbody
    (setf v-solver-705 arg-v-solver-705)
    (setf v-scores-706 arg-v-scores-706)
    (setf v-activate-707 arg-v-activate-707)
    (progn (|c/init_scores| v-solver-705 v-scores-706))
    (setf v-stable-708 (m-u8 (+ v-solver-705 6)))
    (progn v-solver-705)
    (setf v-pos-712 (m-ptr (+ v-scores-706 16)))
    (setf v-score-713 (m-ptr (+ v-scores-706 24)))
    (setf v-PTR_idx-718 (m-ptr (+ v-activate-707 0)))
    (setf v-END_idx-719 (m-ptr (+ v-activate-707 8)))
    LOOP714
    (unless (c-true (if (c-true (if (/= v-PTR_idx-718 v-END_idx-719) 1 0)) (c-bool (progn (setf v-idx-717 (m-u32 v-PTR_idx-718)) 1)) 0)) (go ENDLOOP715))
    (locally (declare (optimize (speed 1))) (setf v-activated-720 (progn 0 (let* ((a721 (+ (+ (+ v-solver-705 1016) 0) (* 8 v-stable-708))) (old722 (m-u64 a721))) (setf (m-u64 a721) (c-u64 (c-u64 (+ old722 (c-u64 1))))) (m-u64 a721)))))
    (progn (setf (m-u32 (+ v-pos-712 (* 4 v-idx-717))) 4294967295))
    (progn (setf (m-f64 (+ v-score-713 (* 8 v-idx-717))) (float (- (float 1 1d0) (float (/ 1.0d0 (integer64-double v-activated-720 nil)) 1d0)) 1d0)))
    (progn (|c/push_heap| v-solver-705 v-scores-706 v-idx-717))
    (let* ( (old724 v-PTR_idx-718)) (setf v-PTR_idx-718 (+ old724 (* 4 1))) v-PTR_idx-718)
    (go LOOP714)
    ENDLOOP715
    (progn (c-free (m-ptr (+ v-activate-707 0))))
    (progn (setf (m-ptr (+ v-activate-707 0)) (setf (m-ptr (+ v-activate-707 8)) (setf (m-ptr (+ v-activate-707 16)) 0))))
    (progn (setf (m-u32 (+ v-scores-706 32)) (m-u32 (+ v-solver-705 12))))
  )
  0))

;;; upstream/satch.c:2978:1
(defun |c/get_scores| (arg-v-solver-728)
 (declare  (type c-address arg-v-solver-728))
 (let ((v-solver-728 0) (v-stable-729 0) (v-scores-730 0) (v-activate-731 0))
 (declare (type c-address v-solver-728) (type (unsigned-byte 32) v-stable-729) (type c-address v-scores-730) (type c-address v-activate-731) (ignorable v-solver-728 v-stable-729 v-scores-730 v-activate-731))
 (tagbody
    (setf v-solver-728 arg-v-solver-728)
    (setf v-stable-729 (m-u8 (+ v-solver-728 6)))
    (setf v-scores-730 (+ (+ v-solver-728 304) (* 56 v-stable-729)))
    (setf v-activate-731 (+ (+ v-solver-728 104) (* 24 v-stable-729)))
    (unless (c-true (if (c-true (if (= (m-ptr (+ v-activate-731 8)) (m-ptr (+ v-activate-731 0))) 1 0)) 0 1)) (go ELSE732))
    (progn (|c/activate_scores| v-solver-728 v-scores-730 v-activate-731))
    (go ENDIF733)
    ELSE732
    ENDIF733
    (return-from |c/get_scores| v-scores-730)
  )
  0))

;;; upstream/satch.c:2997:1
(defun |c/bump_variable_score| (arg-v-solver-734 arg-v-idx-735)
 (declare  (type c-address arg-v-solver-734) (type (unsigned-byte 32) arg-v-idx-735))
 (let ((v-solver-734 0) (v-idx-735 0) (v-scores-738 0) (v-old_score-739 0d0) (v-new_score-740 0d0))
 (declare (type c-address v-solver-734) (type (unsigned-byte 32) v-idx-735) (type c-address v-scores-738) (type double-float v-old_score-739) (type double-float v-new_score-740) (ignorable v-solver-734 v-idx-735 v-scores-738 v-old_score-739 v-new_score-740))
 (tagbody
    (setf v-solver-734 arg-v-solver-734)
    (setf v-idx-735 arg-v-idx-735)
    (progn (progn 0 (let* ((a736 (+ (+ v-solver-734 1016) 112)) (old737 (m-u64 a736))) (setf (m-u64 a736) (c-u64 (c-u64 (+ old737 (c-u64 1))))) (m-u64 a736))))
    (setf v-scores-738 (|c/get_scores| v-solver-734))
    (setf v-old_score-739 (|c/heap_score| v-scores-738 v-idx-735))
    (setf v-new_score-740 (float (+ v-old_score-739 (m-f64 (+ v-scores-738 40))) 1d0))
    (progn v-solver-734)
    (progn (|c/update_heap| v-solver-734 v-scores-738 v-idx-735 v-new_score-740))
    (unless (c-true (if (> v-new_score-740 1d+150) 1 0)) (go ELSE744))
    (progn (|c/rescore_scores| v-solver-734 v-scores-738))
    (go ENDIF745)
    ELSE744
    ENDIF745
  )
  0))

;;; upstream/satch.c:3010:1
(defun |c/bump_score_increment| (arg-v-solver-746)
 (declare  (type c-address arg-v-solver-746))
 (let ((v-solver-746 0) (v-scores-747 0))
 (declare (type c-address v-solver-746) (type c-address v-scores-747) (ignorable v-solver-746 v-scores-747))
 (tagbody
    (setf v-solver-746 arg-v-solver-746)
    (setf v-scores-747 (|c/get_scores| v-solver-746))
    (progn (let ((a748 (+ v-scores-747 40))) (setf (m-f64 a748) (float (float (* (m-f64 a748) (m-f64 (+ v-scores-747 48))) 1d0) 1d0))))
    (progn v-solver-746)
  )
  0))

;;; upstream/satch.c:3206:1
(defun |c/mark_eliminate_literal| (arg-v-solver-752 arg-v-lit-753)
 (declare  (type c-address arg-v-solver-752) (type (unsigned-byte 32) arg-v-lit-753))
 (let ((v-solver-752 0) (v-lit-753 0) (v-idx-754 0) (v-f-755 0))
 (declare (type c-address v-solver-752) (type (unsigned-byte 32) v-lit-753) (type (unsigned-byte 32) v-idx-754) (type c-address v-f-755) (ignorable v-solver-752 v-lit-753 v-idx-754 v-f-755))
 (tagbody
    (setf v-solver-752 arg-v-solver-752)
    (setf v-lit-753 arg-v-lit-753)
    (setf v-idx-754 (|c/INDEX| v-lit-753))
    (setf v-f-755 (+ (m-ptr (+ v-solver-752 48)) (* 4 v-idx-754)))
    (unless (c-true (if (c-true (ldb (byte 1 0) (m-u8 (+ v-f-755 0)))) 0 1)) (go ELSE756))
    (return-from |c/mark_eliminate_literal| 0)
    ELSE756
    (unless (c-true (ldb (byte 1 1) (m-u8 (+ v-f-755 0)))) (go ELSE758))
    (return-from |c/mark_eliminate_literal| 0)
    ELSE758
    (progn v-solver-752)
    (progn (set-bits (+ v-f-755 0) 1 1 (c-bool 1)))
    (progn (progn 0 (let* ((a763 (+ (+ v-solver-752 1016) 136)) (old764 (m-u64 a763))) (setf (m-u64 a763) (c-u64 (c-u64 (+ old764 (c-u64 1))))) (m-u64 a763))))
  )
  0))

;;; upstream/satch.c:3220:1
(defun |c/mark_eliminate_clause| (arg-v-solver-765 arg-v-c-766)
 (declare  (type c-address arg-v-solver-765) (type c-address arg-v-c-766))
 (let ((v-solver-765 0) (v-c-766 0) (v-lit-770 0) (v-P_lit-771 0) (v-END_lit-772 0))
 (declare (type c-address v-solver-765) (type c-address v-c-766) (type (unsigned-byte 32) v-lit-770) (type c-address v-P_lit-771) (type c-address v-END_lit-772) (ignorable v-solver-765 v-c-766 v-lit-770 v-P_lit-771 v-END_lit-772))
 (tagbody
    (setf v-solver-765 arg-v-solver-765)
    (setf v-c-766 arg-v-c-766)
    (setf v-P_lit-771 (+ v-c-766 16))
    (setf v-END_lit-772 (+ v-P_lit-771 (* 4 (m-u32 (+ v-c-766 12)))))
    LOOP767
    (unless (c-true (if (c-true (if (/= v-P_lit-771 v-END_lit-772) 1 0)) (c-bool (progn (setf v-lit-770 (m-u32 v-P_lit-771)) 1)) 0)) (go ENDLOOP768))
    (progn (|c/mark_eliminate_literal| v-solver-765 v-lit-770))
    (let* ( (old774 v-P_lit-771)) (setf v-P_lit-771 (+ old774 (* 4 1))) v-P_lit-771)
    (go LOOP767)
    ENDLOOP768
  )
  0))

;;; upstream/satch.c:3234:1
(defun |c/mark_subsume_variable| (arg-v-solver-775 arg-v-idx-776)
 (declare  (type c-address arg-v-solver-775) (type (unsigned-byte 32) arg-v-idx-776))
 (let ((v-solver-775 0) (v-idx-776 0) (v-f-777 0))
 (declare (type c-address v-solver-775) (type (unsigned-byte 32) v-idx-776) (type c-address v-f-777) (ignorable v-solver-775 v-idx-776 v-f-777))
 (tagbody
    (setf v-solver-775 arg-v-solver-775)
    (setf v-idx-776 arg-v-idx-776)
    (setf v-f-777 (+ (m-ptr (+ v-solver-775 48)) (* 4 v-idx-776)))
    (unless (c-true (if (c-true (ldb (byte 1 0) (m-u8 (+ v-f-777 0)))) 0 1)) (go ELSE778))
    (return-from |c/mark_subsume_variable| 0)
    ELSE778
    (unless (c-true (c-u32 (logand (ldb (byte 2 4) (m-u8 (+ v-f-777 0))) (c-u32 1)))) (go ELSE780))
    (return-from |c/mark_subsume_variable| 0)
    ELSE780
    (progn v-solver-775)
    (progn (let ((a785 (+ v-f-777 0))) (set-bits a785 4 2 (c-u32 (c-u32 (logior (ldb (byte 2 4) (m-u8 a785)) (c-u32 1)))))))
    (progn (progn 0 (let* ((a786 (+ (+ v-solver-775 1016) 144)) (old787 (m-u64 a786))) (setf (m-u64 a786) (c-u64 (c-u64 (+ old787 (c-u64 1))))) (m-u64 a786))))
  )
  0))

;;; upstream/satch.c:3248:1
(defun |c/mark_subsume_literal| (arg-v-solver-788 arg-v-lit-789)
 (declare  (type c-address arg-v-solver-788) (type (unsigned-byte 32) arg-v-lit-789))
 (let ((v-solver-788 0) (v-lit-789 0) (v-idx-790 0))
 (declare (type c-address v-solver-788) (type (unsigned-byte 32) v-lit-789) (type (unsigned-byte 32) v-idx-790) (ignorable v-solver-788 v-lit-789 v-idx-790))
 (tagbody
    (setf v-solver-788 arg-v-solver-788)
    (setf v-lit-789 arg-v-lit-789)
    (setf v-idx-790 (|c/INDEX| v-lit-789))
    (progn (|c/mark_subsume_variable| v-solver-788 v-idx-790))
  )
  0))

;;; upstream/satch.c:3265:1
(defun |c/watch_binary| (arg-v-solver-791 arg-v-redundant-792 arg-v-lit-793 arg-v-blocking-794)
 (declare  (type c-address arg-v-solver-791) (type (integer 0 1) arg-v-redundant-792) (type (unsigned-byte 32) arg-v-lit-793) (type (unsigned-byte 32) arg-v-blocking-794))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-791 0) (v-redundant-792 0) (v-lit-793 0) (v-blocking-794 0) (v-watch-795 (stack-alloc 8)) (v-old_size-804 0) (v-old_capacity-805 0) (v-new_capacity-806 0) (v-new_bytes-807 0))
 (declare (type c-address v-solver-791) (type (integer 0 1) v-redundant-792) (type (unsigned-byte 32) v-lit-793) (type (unsigned-byte 32) v-blocking-794) (type c-address v-watch-795) (type c-size v-old_size-804) (type c-size v-old_capacity-805) (type c-size v-new_capacity-806) (type c-size v-new_bytes-807) (ignorable v-solver-791 v-redundant-792 v-lit-793 v-blocking-794 v-watch-795 v-old_size-804 v-old_capacity-805 v-new_capacity-806 v-new_bytes-807))
 (tagbody
    (setf v-solver-791 arg-v-solver-791)
    (setf v-redundant-792 arg-v-redundant-792)
    (setf v-lit-793 arg-v-lit-793)
    (setf v-blocking-794 arg-v-blocking-794)
    (progn (setf (m-u8 (+ (+ v-watch-795 0) 0)) (c-bool 1)))
    (progn (setf (m-u8 (+ (+ v-watch-795 0) 1)) (c-bool v-redundant-792)))
    (progn (setf (m-u32 (+ (+ v-watch-795 0) 4)) v-blocking-794))
    (unless (c-true (if (= (m-ptr (+ (+ (m-ptr (+ v-solver-791 544)) (* 24 v-lit-793)) 8)) (m-ptr (+ (+ (m-ptr (+ v-solver-791 544)) (* 24 v-lit-793)) 16))) 1 0)) (go ELSE799))
    (setf v-old_size-804 (the c-size (truncate (- (m-ptr (+ (+ (m-ptr (+ v-solver-791 544)) (* 24 v-lit-793)) 8)) (m-ptr (+ (+ (m-ptr (+ v-solver-791 544)) (* 24 v-lit-793)) 0))) 8)))
    (setf v-old_capacity-805 (the c-size (truncate (- (m-ptr (+ (+ (m-ptr (+ v-solver-791 544)) (* 24 v-lit-793)) 16)) (m-ptr (+ (+ (m-ptr (+ v-solver-791 544)) (* 24 v-lit-793)) 0))) 8)))
    (setf v-new_capacity-806 (if (c-true v-old_capacity-805) (c-u64 (* (c-u64 2) v-old_capacity-805)) (c-u64 1)))
    (setf v-new_bytes-807 (c-u64 (* v-new_capacity-806 8)))
    (progn (setf (m-ptr (+ (+ (m-ptr (+ v-solver-791 544)) (* 24 v-lit-793)) 0)) (c-realloc (m-ptr (+ (+ (m-ptr (+ v-solver-791 544)) (* 24 v-lit-793)) 0)) v-new_bytes-807)))
    (unless (c-true (if (c-true (m-ptr (+ (+ (m-ptr (+ v-solver-791 544)) (* 24 v-lit-793)) 0))) 0 1)) (go ELSE808))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-807))
    (go ENDIF809)
    ELSE808
    ENDIF809
    (progn (setf (m-ptr (+ (+ (m-ptr (+ v-solver-791 544)) (* 24 v-lit-793)) 8)) (+ (m-ptr (+ (+ (m-ptr (+ v-solver-791 544)) (* 24 v-lit-793)) 0)) (* 8 v-old_size-804))))
    (progn (setf (m-ptr (+ (+ (m-ptr (+ v-solver-791 544)) (* 24 v-lit-793)) 16)) (+ (m-ptr (+ (+ (m-ptr (+ v-solver-791 544)) (* 24 v-lit-793)) 0)) (* 8 v-new_capacity-806))))
    (go ENDIF800)
    ELSE799
    ENDIF800
    (progn (copy-bytes (let* ((a810 (+ (+ (m-ptr (+ v-solver-791 544)) (* 24 v-lit-793)) 8)) (old811 (m-ptr a810))) (setf (m-ptr a810) (+ old811 (* 8 1))) old811) v-watch-795 8))
    (progn v-solver-791)
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:3278:1
(defun |c/add_new_binary_and_watch_it| (arg-v-solver-815 arg-v-redundant-816)
 (declare  (type c-address arg-v-solver-815) (type (integer 0 1) arg-v-redundant-816))
 (let ((v-solver-815 0) (v-redundant-816 0) (v-lit-817 0) (v-other-818 0))
 (declare (type c-address v-solver-815) (type (integer 0 1) v-redundant-816) (type (unsigned-byte 32) v-lit-817) (type (unsigned-byte 32) v-other-818) (ignorable v-solver-815 v-redundant-816 v-lit-817 v-other-818))
 (tagbody
    (setf v-solver-815 arg-v-solver-815)
    (setf v-redundant-816 arg-v-redundant-816)
    (setf v-lit-817 (m-u32 (+ (m-ptr (+ (+ v-solver-815 624) 0)) (* 4 (progn 0 0)))))
    (setf v-other-818 (m-u32 (+ (m-ptr (+ (+ v-solver-815 624) 0)) (* 4 (progn 0 1)))))
    (progn (|c/watch_binary| v-solver-815 (c-bool v-redundant-816) v-lit-817 v-other-818))
    (progn (|c/watch_binary| v-solver-815 (c-bool v-redundant-816) v-other-818 v-lit-817))
    (unless (c-true v-redundant-816) (go ELSE819))
    (progn (progn 0 (let* ((a821 (+ (+ v-solver-815 1016) 208)) (old822 (m-u64 a821))) (setf (m-u64 a821) (c-u64 (c-u64 (+ old822 (c-u64 1))))) (m-u64 a821))))
    (go ENDIF820)
    ELSE819
    (progn (progn 0 (let* ((a823 (+ (+ v-solver-815 1016) 120)) (old824 (m-u64 a823))) (setf (m-u64 a823) (c-u64 (c-u64 (+ old824 (c-u64 1))))) (m-u64 a823))))
    ENDIF820
  )
  0))

;;; upstream/satch.c:3300:1
(defun |c/really_delete_binary| (arg-v-solver-825 arg-v-redundant-826 arg-v-lit-827 arg-v-other-828)
 (declare  (type c-address arg-v-solver-825) (type (integer 0 1) arg-v-redundant-826) (type (unsigned-byte 32) arg-v-lit-827) (type (unsigned-byte 32) arg-v-other-828))
 (let ((v-solver-825 0) (v-redundant-826 0) (v-lit-827 0) (v-other-828 0))
 (declare (type c-address v-solver-825) (type (integer 0 1) v-redundant-826) (type (unsigned-byte 32) v-lit-827) (type (unsigned-byte 32) v-other-828) (ignorable v-solver-825 v-redundant-826 v-lit-827 v-other-828))
 (tagbody
    (setf v-solver-825 arg-v-solver-825)
    (setf v-redundant-826 arg-v-redundant-826)
    (setf v-lit-827 arg-v-lit-827)
    (setf v-other-828 arg-v-other-828)
    (progn v-solver-825)
    (progn (|c/trace_and_check_binary_deletion| v-solver-825 v-lit-827 v-other-828))
    (unless (c-true (if (c-true v-redundant-826) 0 1)) (go ELSE832))
    (progn (|c/mark_eliminate_literal| v-solver-825 v-lit-827))
    (progn (|c/mark_eliminate_literal| v-solver-825 v-other-828))
    (go ENDIF833)
    ELSE832
    ENDIF833
    (unless (c-true v-redundant-826) (go ELSE834))
    (progn (let* ((a839 (+ (+ v-solver-825 1016) 208)) (old840 (m-u64 a839))) (setf (m-u64 a839) (c-u64 (c-u64 (- old840 (c-u64 1))))) old840))
    (go ENDIF835)
    ELSE834
    (progn (let* ((a844 (+ (+ v-solver-825 1016) 120)) (old845 (m-u64 a844))) (setf (m-u64 a844) (c-u64 (c-u64 (- old845 (c-u64 1))))) old845))
    ENDIF835
  )
  0))

;;; upstream/satch.c:3319:1
(defun |c/delete_binary| (arg-v-solver-846 arg-v-redundant-847 arg-v-lit-848 arg-v-other-849)
 (declare  (type c-address arg-v-solver-846) (type (integer 0 1) arg-v-redundant-847) (type (unsigned-byte 32) arg-v-lit-848) (type (unsigned-byte 32) arg-v-other-849))
 (let ((v-solver-846 0) (v-redundant-847 0) (v-lit-848 0) (v-other-849 0))
 (declare (type c-address v-solver-846) (type (integer 0 1) v-redundant-847) (type (unsigned-byte 32) v-lit-848) (type (unsigned-byte 32) v-other-849) (ignorable v-solver-846 v-redundant-847 v-lit-848 v-other-849))
 (tagbody
    (setf v-solver-846 arg-v-solver-846)
    (setf v-redundant-847 arg-v-redundant-847)
    (setf v-lit-848 arg-v-lit-848)
    (setf v-other-849 arg-v-other-849)
    (unless (c-true (if (< v-lit-848 v-other-849) 1 0)) (go ELSE850))
    (progn (|c/really_delete_binary| v-solver-846 (c-bool v-redundant-847) v-lit-848 v-other-849))
    (go ENDIF851)
    ELSE850
    ENDIF851
  )
  0))

;;; upstream/satch.c:3353:1
(defun |c/mark_garbage| (arg-v-solver-852 arg-v-c-853 arg-v-msg-854)
 (declare  (type c-address arg-v-solver-852) (type c-address arg-v-c-853) (type c-address arg-v-msg-854))
 (let ((v-solver-852 0) (v-c-853 0) (v-msg-854 0))
 (declare (type c-address v-solver-852) (type c-address v-c-853) (type c-address v-msg-854) (ignorable v-solver-852 v-c-853 v-msg-854))
 (tagbody
    (setf v-solver-852 arg-v-solver-852)
    (setf v-c-853 arg-v-c-853)
    (setf v-msg-854 arg-v-msg-854)
    (progn v-solver-852)
    (progn (set-bits (+ v-c-853 0) 0 1 (c-bool 1)))
    (progn (|c/trace_and_check_deletion| v-solver-852 (m-u32 (+ v-c-853 12)) (+ v-c-853 16)))
    (unless (c-true (ldb (byte 1 2) (m-u8 (+ v-c-853 0)))) (go ELSE858))
    (progn (let* ((a863 (+ (+ v-solver-852 1016) 208)) (old864 (m-u64 a863))) (setf (m-u64 a863) (c-u64 (c-u64 (- old864 (c-u64 1))))) old864))
    (go ENDIF859)
    ELSE858
    (progn (let* ((a868 (+ (+ v-solver-852 1016) 120)) (old869 (m-u64 a868))) (setf (m-u64 a868) (c-u64 (c-u64 (- old869 (c-u64 1))))) old869))
    ENDIF859
    (unless (c-true (if (c-true (ldb (byte 1 2) (m-u8 (+ v-c-853 0)))) 0 1)) (go ELSE870))
    (progn (|c/mark_eliminate_clause| v-solver-852 v-c-853))
    (go ENDIF871)
    ELSE870
    ENDIF871
    (progn v-msg-854)
  )
  0))

;;; upstream/satch.c:3385:1
(defun |c/connect_literal| (arg-v-solver-872 arg-v-lit-873 arg-v-c-874)
 (declare  (type c-address arg-v-solver-872) (type (unsigned-byte 32) arg-v-lit-873) (type c-address arg-v-c-874))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-872 0) (v-lit-873 0) (v-c-874 0) (v-watch-875 (stack-alloc 8)) (v-old_size-884 0) (v-old_capacity-885 0) (v-new_capacity-886 0) (v-new_bytes-887 0))
 (declare (type c-address v-solver-872) (type (unsigned-byte 32) v-lit-873) (type c-address v-c-874) (type c-address v-watch-875) (type c-size v-old_size-884) (type c-size v-old_capacity-885) (type c-size v-new_capacity-886) (type c-size v-new_bytes-887) (ignorable v-solver-872 v-lit-873 v-c-874 v-watch-875 v-old_size-884 v-old_capacity-885 v-new_capacity-886 v-new_bytes-887))
 (tagbody
    (setf v-solver-872 arg-v-solver-872)
    (setf v-lit-873 arg-v-lit-873)
    (setf v-c-874 arg-v-c-874)
    (c-memset v-watch-875 0 8)
    (setf (m-ptr (+ v-watch-875 0)) v-c-874)
    (unless (c-true (if (= (m-ptr (+ (+ (m-ptr (+ v-solver-872 544)) (* 24 v-lit-873)) 8)) (m-ptr (+ (+ (m-ptr (+ v-solver-872 544)) (* 24 v-lit-873)) 16))) 1 0)) (go ELSE879))
    (setf v-old_size-884 (the c-size (truncate (- (m-ptr (+ (+ (m-ptr (+ v-solver-872 544)) (* 24 v-lit-873)) 8)) (m-ptr (+ (+ (m-ptr (+ v-solver-872 544)) (* 24 v-lit-873)) 0))) 8)))
    (setf v-old_capacity-885 (the c-size (truncate (- (m-ptr (+ (+ (m-ptr (+ v-solver-872 544)) (* 24 v-lit-873)) 16)) (m-ptr (+ (+ (m-ptr (+ v-solver-872 544)) (* 24 v-lit-873)) 0))) 8)))
    (setf v-new_capacity-886 (if (c-true v-old_capacity-885) (c-u64 (* (c-u64 2) v-old_capacity-885)) (c-u64 1)))
    (setf v-new_bytes-887 (c-u64 (* v-new_capacity-886 8)))
    (progn (setf (m-ptr (+ (+ (m-ptr (+ v-solver-872 544)) (* 24 v-lit-873)) 0)) (c-realloc (m-ptr (+ (+ (m-ptr (+ v-solver-872 544)) (* 24 v-lit-873)) 0)) v-new_bytes-887)))
    (unless (c-true (if (c-true (m-ptr (+ (+ (m-ptr (+ v-solver-872 544)) (* 24 v-lit-873)) 0))) 0 1)) (go ELSE888))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-887))
    (go ENDIF889)
    ELSE888
    ENDIF889
    (progn (setf (m-ptr (+ (+ (m-ptr (+ v-solver-872 544)) (* 24 v-lit-873)) 8)) (+ (m-ptr (+ (+ (m-ptr (+ v-solver-872 544)) (* 24 v-lit-873)) 0)) (* 8 v-old_size-884))))
    (progn (setf (m-ptr (+ (+ (m-ptr (+ v-solver-872 544)) (* 24 v-lit-873)) 16)) (+ (m-ptr (+ (+ (m-ptr (+ v-solver-872 544)) (* 24 v-lit-873)) 0)) (* 8 v-new_capacity-886))))
    (go ENDIF880)
    ELSE879
    ENDIF880
    (progn (copy-bytes (let* ((a890 (+ (+ (m-ptr (+ v-solver-872 544)) (* 24 v-lit-873)) 8)) (old891 (m-ptr a890))) (setf (m-ptr a890) (+ old891 (* 8 1))) old891) v-watch-875 8))
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:3407:1
(defun |c/connect_clause| (arg-v-solver-892 arg-v-c-893)
 (declare  (type c-address arg-v-solver-892) (type c-address arg-v-c-893))
 (let ((v-solver-892 0) (v-c-893 0) (v-lit-897 0) (v-P_lit-898 0) (v-END_lit-899 0))
 (declare (type c-address v-solver-892) (type c-address v-c-893) (type (unsigned-byte 32) v-lit-897) (type c-address v-P_lit-898) (type c-address v-END_lit-899) (ignorable v-solver-892 v-c-893 v-lit-897 v-P_lit-898 v-END_lit-899))
 (tagbody
    (setf v-solver-892 arg-v-solver-892)
    (setf v-c-893 arg-v-c-893)
    (setf v-P_lit-898 (+ v-c-893 16))
    (setf v-END_lit-899 (+ v-P_lit-898 (* 4 (m-u32 (+ v-c-893 12)))))
    LOOP894
    (unless (c-true (if (c-true (if (/= v-P_lit-898 v-END_lit-899) 1 0)) (c-bool (progn (setf v-lit-897 (m-u32 v-P_lit-898)) 1)) 0)) (go ENDLOOP895))
    (progn (|c/connect_literal| v-solver-892 v-lit-897 v-c-893))
    (let* ( (old901 v-P_lit-898)) (setf v-P_lit-898 (+ old901 (* 4 1))) v-P_lit-898)
    (go LOOP894)
    ENDLOOP895
  )
  0))

