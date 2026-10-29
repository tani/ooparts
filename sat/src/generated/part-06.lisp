(in-package #:ooparts/sat/impl)
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 2) (safety 1) (debug 0) (compilation-speed 1)))
;;; upstream/satch.c:5099:1
(defun |c/sort_deduced_clause| (arg-v-solver-1701)
 (declare  (type c-address arg-v-solver-1701))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-1701 0) (v-levels-1702 0) (v-N_RANK-1706 0) (v-V_RANK-1709 0) (v-LENGTH_RANK-1710 0) (v-WIDTH_RANK-1711 0) (v-MASK_RANK-1712 0) (v-COUNT_RANK-1713 (stack-alloc 2048)) (v-TMP_RANK-1714 0) (v-BYTES_TMP_RANK-1715 0) (v-A_RANK-1716 0) (v-B_RANK-1717 0) (v-C_RANK-1718 0) (v-MLOWER_RANK-1719 0) (v-MUPPER_RANK-1720 0) (v-BOUNDED_RANK-1721 0) (v-UPPER_RANK-1722 0) (v-LOWER_RANK-1723 0) (v-SHIFT_RANK-1724 0) (v-I_RANK-1728 0) (v-END_RANK-1731 0) (v-SORTED_RANK-1732 0) (v-LAST_RANK-1733 0) (v-P_RANK-1737 0) (v-R_RANK-1738 0) (v-S_RANK-1743 0) (v-M_RANK-1744 0) (v-POS_RANK-1757 0) (v-J_RANK-1761 0) (v-DELTA_RANK-1762 0) (v-D_RANK-1770 0) (v-P_RANK-1774 0) (v-R_RANK-1775 0) (v-S_RANK-1776 0) (v-M_RANK-1777 0) (v-POS_RANK-1778 0))
 (declare (type c-address v-solver-1701) (type c-address v-levels-1702) (type c-size v-N_RANK-1706) (type c-address v-V_RANK-1709) (type c-size v-LENGTH_RANK-1710) (type c-size v-WIDTH_RANK-1711) (type (unsigned-byte 32) v-MASK_RANK-1712) (type c-address v-COUNT_RANK-1713) (type c-address v-TMP_RANK-1714) (type c-size v-BYTES_TMP_RANK-1715) (type c-address v-A_RANK-1716) (type c-address v-B_RANK-1717) (type c-address v-C_RANK-1718) (type (unsigned-byte 32) v-MLOWER_RANK-1719) (type (unsigned-byte 32) v-MUPPER_RANK-1720) (type (integer 0 1) v-BOUNDED_RANK-1721) (type (unsigned-byte 32) v-UPPER_RANK-1722) (type (unsigned-byte 32) v-LOWER_RANK-1723) (type (unsigned-byte 32) v-SHIFT_RANK-1724) (type c-size v-I_RANK-1728) (type c-address v-END_RANK-1731) (type (integer 0 1) v-SORTED_RANK-1732) (type (unsigned-byte 32) v-LAST_RANK-1733) (type c-address v-P_RANK-1737) (type (unsigned-byte 32) v-R_RANK-1738) (type (unsigned-byte 32) v-S_RANK-1743) (type (unsigned-byte 32) v-M_RANK-1744) (type c-size v-POS_RANK-1757) (type c-size v-J_RANK-1761) (type c-size v-DELTA_RANK-1762) (type c-address v-D_RANK-1770) (type c-address v-P_RANK-1774) (type (unsigned-byte 32) v-R_RANK-1775) (type (unsigned-byte 32) v-S_RANK-1776) (type (unsigned-byte 32) v-M_RANK-1777) (type c-size v-POS_RANK-1778) (ignorable v-solver-1701 v-levels-1702 v-N_RANK-1706 v-V_RANK-1709 v-LENGTH_RANK-1710 v-WIDTH_RANK-1711 v-MASK_RANK-1712 v-COUNT_RANK-1713 v-TMP_RANK-1714 v-BYTES_TMP_RANK-1715 v-A_RANK-1716 v-B_RANK-1717 v-C_RANK-1718 v-MLOWER_RANK-1719 v-MUPPER_RANK-1720 v-BOUNDED_RANK-1721 v-UPPER_RANK-1722 v-LOWER_RANK-1723 v-SHIFT_RANK-1724 v-I_RANK-1728 v-END_RANK-1731 v-SORTED_RANK-1732 v-LAST_RANK-1733 v-P_RANK-1737 v-R_RANK-1738 v-S_RANK-1743 v-M_RANK-1744 v-POS_RANK-1757 v-J_RANK-1761 v-DELTA_RANK-1762 v-D_RANK-1770 v-P_RANK-1774 v-R_RANK-1775 v-S_RANK-1776 v-M_RANK-1777 v-POS_RANK-1778))
 (tagbody
    (setf v-solver-1701 arg-v-solver-1701)
    (setf v-levels-1702 (m-ptr (+ v-solver-1701 32)))
    (setf v-N_RANK-1706 (the c-size (truncate (- (m-ptr (+ (+ v-solver-1701 624) 8)) (m-ptr (+ (+ v-solver-1701 624) 0))) 4)))
    (unless (c-true (if (<= v-N_RANK-1706 (c-u64 1)) 1 0)) (go ELSE1707))
    (go ENDLOOP1704)
    ELSE1707
    (setf v-V_RANK-1709 (m-ptr (+ (+ v-solver-1701 624) 0)))
    (setf v-LENGTH_RANK-1710 (c-u64 8))
    (setf v-WIDTH_RANK-1711 (c-u64 (c-s32 (ash (c-s32 1) v-LENGTH_RANK-1710))))
    (setf v-MASK_RANK-1712 (c-u32 (c-u64 (- v-WIDTH_RANK-1711 (c-u64 1)))))
    (setf v-TMP_RANK-1714 0)
    (setf v-BYTES_TMP_RANK-1715 (c-u64 (* v-N_RANK-1706 4)))
    (setf v-A_RANK-1716 v-V_RANK-1709)
    (setf v-B_RANK-1717 0)
    (setf v-C_RANK-1718 v-A_RANK-1716)
    (setf v-MLOWER_RANK-1719 (c-u32 0))
    (setf v-MUPPER_RANK-1720 v-MASK_RANK-1712)
    (setf v-BOUNDED_RANK-1721 (c-bool 0))
    (setf v-UPPER_RANK-1722 (c-u32 0))
    (setf v-LOWER_RANK-1723 (c-u32 (lognot v-UPPER_RANK-1722)))
    (setf v-SHIFT_RANK-1724 v-MASK_RANK-1712)
    (setf v-I_RANK-1728 (c-u64 0))
    LOOP1725
    (unless (c-true (if (< v-I_RANK-1728 (c-u64 (* (c-u64 8) 4))) 1 0)) (go ENDLOOP1726))
    (unless (c-true (if (c-true v-BOUNDED_RANK-1721) (c-bool (if (= (c-u32 (logand v-LOWER_RANK-1723 v-SHIFT_RANK-1724)) (c-u32 (logand v-UPPER_RANK-1722 v-SHIFT_RANK-1724))) 1 0)) 0)) (go ELSE1729))
    (go CONTINUE1727)
    ELSE1729
    (progn (c-memset (+ v-COUNT_RANK-1713 (* 8 v-MLOWER_RANK-1719)) 0 (c-u64 (* (c-u32 (+ (c-u32 (- v-MUPPER_RANK-1720 v-MLOWER_RANK-1719)) (c-u32 1))) 8))))
    (setf v-END_RANK-1731 (+ v-C_RANK-1718 (* 4 v-N_RANK-1706)))
    (setf v-SORTED_RANK-1732 (c-bool 1))
    (setf v-LAST_RANK-1733 (c-u32 0))
    (setf v-P_RANK-1737 v-C_RANK-1718)
    LOOP1734
    (unless (c-true (if (/= v-P_RANK-1737 v-END_RANK-1731) 1 0)) (go ENDLOOP1735))
    (setf v-R_RANK-1738 (c-u32 (lognot (m-u32 (+ v-levels-1702 (* 4 (|c/INDEX| (m-u32 v-P_RANK-1737))))))))
    (unless (c-true (if (c-true v-BOUNDED_RANK-1721) 0 1)) (go ELSE1739))
    (progn (setf v-LOWER_RANK-1723 (c-u32 (c-u32 (logand v-LOWER_RANK-1723 v-R_RANK-1738)))))
    (progn (setf v-UPPER_RANK-1722 (c-u32 (c-u32 (logior v-UPPER_RANK-1722 v-R_RANK-1738)))))
    (go ENDIF1740)
    ELSE1739
    ENDIF1740
    (setf v-S_RANK-1743 (c-u32 (ash (c-u32 v-R_RANK-1738) (- v-I_RANK-1728))))
    (setf v-M_RANK-1744 (c-u32 (logand v-S_RANK-1743 v-MASK_RANK-1712)))
    (unless (c-true (if (c-true v-SORTED_RANK-1732) (c-bool (if (> v-LAST_RANK-1733 v-M_RANK-1744) 1 0)) 0)) (go ELSE1745))
    (progn (setf v-SORTED_RANK-1732 (c-bool 0)))
    (go ENDIF1746)
    ELSE1745
    (progn (setf v-LAST_RANK-1733 v-M_RANK-1744))
    ENDIF1746
    (progn (let* ((a1747 (+ v-COUNT_RANK-1713 (* 8 v-M_RANK-1744))) (old1748 (m-size a1747))) (setf (m-size a1747) (c-u64 (c-u64 (+ old1748 (c-u64 1))))) old1748))
    (let* ( (old1750 v-P_RANK-1737)) (setf v-P_RANK-1737 (+ old1750 (* 4 1))) old1750)
    (go LOOP1734)
    ENDLOOP1735
    (progn (setf v-MLOWER_RANK-1719 (c-u32 (logand (c-u32 (ash (c-u32 v-LOWER_RANK-1723) (- v-I_RANK-1728))) v-MASK_RANK-1712))))
    (progn (setf v-MUPPER_RANK-1720 (c-u32 (logand (c-u32 (ash (c-u32 v-UPPER_RANK-1722) (- v-I_RANK-1728))) v-MASK_RANK-1712))))
    (unless (c-true (if (c-true v-BOUNDED_RANK-1721) 0 1)) (go ELSE1751))
    (progn (setf v-BOUNDED_RANK-1721 (c-bool 1)))
    (unless (c-true (if (= (c-u32 (logand v-LOWER_RANK-1723 v-SHIFT_RANK-1724)) (c-u32 (logand v-UPPER_RANK-1722 v-SHIFT_RANK-1724))) 1 0)) (go ELSE1753))
    (go CONTINUE1727)
    ELSE1753
    (go ENDIF1752)
    ELSE1751
    ENDIF1752
    (unless (c-true v-SORTED_RANK-1732) (go ELSE1755))
    (go CONTINUE1727)
    ELSE1755
    (setf v-POS_RANK-1757 (c-u64 0))
    (setf v-J_RANK-1761 v-MLOWER_RANK-1719)
    LOOP1758
    (unless (c-true (if (<= v-J_RANK-1761 v-MUPPER_RANK-1720) 1 0)) (go ENDLOOP1759))
    (setf v-DELTA_RANK-1762 (m-size (+ v-COUNT_RANK-1713 (* 8 v-J_RANK-1761))))
    (progn (setf (m-size (+ v-COUNT_RANK-1713 (* 8 v-J_RANK-1761))) v-POS_RANK-1757))
    (progn (setf v-POS_RANK-1757 (c-u64 (c-u64 (+ v-POS_RANK-1757 v-DELTA_RANK-1762)))))
    (let* ( (old1765 v-J_RANK-1761)) (setf v-J_RANK-1761 (c-u64 (c-u64 (+ old1765 (c-u64 1))))) old1765)
    (go LOOP1758)
    ENDLOOP1759
    (unless (c-true (if (c-true v-TMP_RANK-1714) 0 1)) (go ELSE1766))
    (progn (setf v-TMP_RANK-1714 (c-malloc v-BYTES_TMP_RANK-1715)))
    (unless (c-true (if (c-true v-TMP_RANK-1714) 0 1)) (go ELSE1768))
    (progn (|c/out_of_memory| v-BYTES_TMP_RANK-1715))
    (go ENDIF1769)
    ELSE1768
    ENDIF1769
    (progn (setf v-B_RANK-1717 v-TMP_RANK-1714))
    (go ENDIF1767)
    ELSE1766
    ENDIF1767
    (setf v-D_RANK-1770 (if (c-true (if (= v-C_RANK-1718 v-A_RANK-1716) 1 0)) v-B_RANK-1717 v-A_RANK-1716))
    (setf v-P_RANK-1774 v-C_RANK-1718)
    LOOP1771
    (unless (c-true (if (/= v-P_RANK-1774 v-END_RANK-1731) 1 0)) (go ENDLOOP1772))
    (setf v-R_RANK-1775 (c-u32 (lognot (m-u32 (+ v-levels-1702 (* 4 (|c/INDEX| (m-u32 v-P_RANK-1774))))))))
    (setf v-S_RANK-1776 (c-u32 (ash (c-u32 v-R_RANK-1775) (- v-I_RANK-1728))))
    (setf v-M_RANK-1777 (c-u32 (logand v-S_RANK-1776 v-MASK_RANK-1712)))
    (setf v-POS_RANK-1778 (let* ((a1779 (+ v-COUNT_RANK-1713 (* 8 v-M_RANK-1777))) (old1780 (m-size a1779))) (setf (m-size a1779) (c-u64 (c-u64 (+ old1780 (c-u64 1))))) old1780))
    (progn (setf (m-u32 (+ v-D_RANK-1770 (* 4 v-POS_RANK-1778))) (m-u32 v-P_RANK-1774)))
    (let* ( (old1782 v-P_RANK-1774)) (setf v-P_RANK-1774 (+ old1782 (* 4 1))) old1782)
    (go LOOP1771)
    ENDLOOP1772
    (progn (setf v-C_RANK-1718 v-D_RANK-1770))
    CONTINUE1727
    (progn (setf v-I_RANK-1728 (c-u64 (c-u64 (+ v-I_RANK-1728 v-LENGTH_RANK-1710)))) (setf v-SHIFT_RANK-1724 (c-u32 (c-u32 (ash (c-u32 v-SHIFT_RANK-1724) v-LENGTH_RANK-1710)))))
    (go LOOP1725)
    ENDLOOP1726
    (unless (c-true (if (= v-C_RANK-1718 v-B_RANK-1717) 1 0)) (go ELSE1785))
    (progn (c-memcpy v-A_RANK-1716 v-B_RANK-1717 (c-u64 (* v-N_RANK-1706 4))))
    (go ENDIF1786)
    ELSE1785
    ENDIF1786
    (unless (c-true v-TMP_RANK-1714) (go ELSE1787))
    (progn (c-free v-TMP_RANK-1714))
    (go ENDIF1788)
    ELSE1787
    ENDIF1788
    ENDLOOP1704
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:5179:1
(defun |c/mark_removable| (arg-v-solver-1792 arg-v-idx-1793)
 (declare  (type c-address arg-v-solver-1792) (type (unsigned-byte 32) arg-v-idx-1793))
 (let ((v-solver-1792 0) (v-idx-1793 0) (v-old_size-1803 0) (v-old_capacity-1804 0) (v-new_capacity-1805 0) (v-new_bytes-1806 0))
 (declare (type c-address v-solver-1792) (type (unsigned-byte 32) v-idx-1793) (type c-size v-old_size-1803) (type c-size v-old_capacity-1804) (type c-size v-new_capacity-1805) (type c-size v-new_bytes-1806) (ignorable v-solver-1792 v-idx-1793 v-old_size-1803 v-old_capacity-1804 v-new_capacity-1805 v-new_bytes-1806))
 (tagbody
    (setf v-solver-1792 arg-v-solver-1792)
    (setf v-idx-1793 arg-v-idx-1793)
    (progn (let ((a1794 (+ (m-ptr (+ v-solver-1792 96)) (* 1 v-idx-1793)))) (setf (m-s8 a1794) (c-s8 (c-s32 (logior (m-s8 a1794) 2))))))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-1792 176) 8)) (m-ptr (+ (+ v-solver-1792 176) 16))) 1 0)) (go ELSE1798))
    (setf v-old_size-1803 (the c-size (truncate (- (m-ptr (+ (+ v-solver-1792 176) 8)) (m-ptr (+ (+ v-solver-1792 176) 0))) 4)))
    (setf v-old_capacity-1804 (the c-size (truncate (- (m-ptr (+ (+ v-solver-1792 176) 16)) (m-ptr (+ (+ v-solver-1792 176) 0))) 4)))
    (setf v-new_capacity-1805 (if (c-true v-old_capacity-1804) (c-u64 (* (c-u64 2) v-old_capacity-1804)) (c-u64 1)))
    (setf v-new_bytes-1806 (c-u64 (* v-new_capacity-1805 4)))
    (progn (setf (m-ptr (+ (+ v-solver-1792 176) 0)) (c-realloc (m-ptr (+ (+ v-solver-1792 176) 0)) v-new_bytes-1806)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-1792 176) 0))) 0 1)) (go ELSE1807))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-1806))
    (go ENDIF1808)
    ELSE1807
    ENDIF1808
    (progn (setf (m-ptr (+ (+ v-solver-1792 176) 8)) (+ (m-ptr (+ (+ v-solver-1792 176) 0)) (* 4 v-old_size-1803))))
    (progn (setf (m-ptr (+ (+ v-solver-1792 176) 16)) (+ (m-ptr (+ (+ v-solver-1792 176) 0)) (* 4 v-new_capacity-1805))))
    (go ENDIF1799)
    ELSE1798
    ENDIF1799
    (progn (setf (m-u32 (let* ((a1809 (+ (+ v-solver-1792 176) 8)) (old1810 (m-ptr a1809))) (setf (m-ptr a1809) (+ old1810 (* 4 1))) old1810)) v-idx-1793))
    (progn v-solver-1792)
  )
  0))

;;; upstream/satch.c:5188:1
(defun |c/mark_poisoned| (arg-v-solver-1814 arg-v-idx-1815)
 (declare  (type c-address arg-v-solver-1814) (type (unsigned-byte 32) arg-v-idx-1815))
 (let ((v-solver-1814 0) (v-idx-1815 0) (v-old_size-1825 0) (v-old_capacity-1826 0) (v-new_capacity-1827 0) (v-new_bytes-1828 0))
 (declare (type c-address v-solver-1814) (type (unsigned-byte 32) v-idx-1815) (type c-size v-old_size-1825) (type c-size v-old_capacity-1826) (type c-size v-new_capacity-1827) (type c-size v-new_bytes-1828) (ignorable v-solver-1814 v-idx-1815 v-old_size-1825 v-old_capacity-1826 v-new_capacity-1827 v-new_bytes-1828))
 (tagbody
    (setf v-solver-1814 arg-v-solver-1814)
    (setf v-idx-1815 arg-v-idx-1815)
    (progn (let ((a1816 (+ (m-ptr (+ v-solver-1814 96)) (* 1 v-idx-1815)))) (setf (m-s8 a1816) (c-s8 (c-s32 (logior (m-s8 a1816) 4))))))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-1814 152) 8)) (m-ptr (+ (+ v-solver-1814 152) 16))) 1 0)) (go ELSE1820))
    (setf v-old_size-1825 (the c-size (truncate (- (m-ptr (+ (+ v-solver-1814 152) 8)) (m-ptr (+ (+ v-solver-1814 152) 0))) 4)))
    (setf v-old_capacity-1826 (the c-size (truncate (- (m-ptr (+ (+ v-solver-1814 152) 16)) (m-ptr (+ (+ v-solver-1814 152) 0))) 4)))
    (setf v-new_capacity-1827 (if (c-true v-old_capacity-1826) (c-u64 (* (c-u64 2) v-old_capacity-1826)) (c-u64 1)))
    (setf v-new_bytes-1828 (c-u64 (* v-new_capacity-1827 4)))
    (progn (setf (m-ptr (+ (+ v-solver-1814 152) 0)) (c-realloc (m-ptr (+ (+ v-solver-1814 152) 0)) v-new_bytes-1828)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-1814 152) 0))) 0 1)) (go ELSE1829))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-1828))
    (go ENDIF1830)
    ELSE1829
    ENDIF1830
    (progn (setf (m-ptr (+ (+ v-solver-1814 152) 8)) (+ (m-ptr (+ (+ v-solver-1814 152) 0)) (* 4 v-old_size-1825))))
    (progn (setf (m-ptr (+ (+ v-solver-1814 152) 16)) (+ (m-ptr (+ (+ v-solver-1814 152) 0)) (* 4 v-new_capacity-1827))))
    (go ENDIF1821)
    ELSE1820
    ENDIF1821
    (progn (setf (m-u32 (let* ((a1831 (+ (+ v-solver-1814 152) 8)) (old1832 (m-ptr a1831))) (setf (m-ptr a1831) (+ old1832 (* 4 1))) old1832)) v-idx-1815))
    (progn v-solver-1814)
  )
  0))

;;; upstream/satch.c:5210:1
(defun |c/minimize_literal| (arg-v-solver-1836 arg-v-lit-1837 arg-v-depth-1838)
 (declare  (type c-address arg-v-solver-1836) (type (unsigned-byte 32) arg-v-lit-1837) (type (unsigned-byte 32) arg-v-depth-1838))
 (let ((v-solver-1836 0) (v-lit-1837 0) (v-depth-1838 0) (v-idx-1839 0) (v-mark-1840 0) (v-level-1847 0) (v-reason-1856 0) (v-res-1861 0) (v-not_lit-1866 0) (v-other-1873 0) (v-P_other-1874 0) (v-END_other-1875 0))
 (declare (type c-address v-solver-1836) (type (unsigned-byte 32) v-lit-1837) (type (unsigned-byte 32) v-depth-1838) (type (unsigned-byte 32) v-idx-1839) (type (signed-byte 8) v-mark-1840) (type (unsigned-byte 32) v-level-1847) (type c-address v-reason-1856) (type (signed-byte 32) v-res-1861) (type (unsigned-byte 32) v-not_lit-1866) (type (unsigned-byte 32) v-other-1873) (type c-address v-P_other-1874) (type c-address v-END_other-1875) (ignorable v-solver-1836 v-lit-1837 v-depth-1838 v-idx-1839 v-mark-1840 v-level-1847 v-reason-1856 v-res-1861 v-not_lit-1866 v-other-1873 v-P_other-1874 v-END_other-1875))
 (tagbody
    (setf v-solver-1836 arg-v-solver-1836)
    (setf v-lit-1837 arg-v-lit-1837)
    (setf v-depth-1838 arg-v-depth-1838)
    (setf v-idx-1839 (|c/INDEX| v-lit-1837))
    (setf v-mark-1840 (m-s8 (+ (m-ptr (+ v-solver-1836 96)) (* 1 v-idx-1839))))
    (unless (c-true (c-s32 (logand v-mark-1840 4))) (go ELSE1841))
    (return-from |c/minimize_literal| 4)
    ELSE1841
    (unless (c-true (c-s32 (logand v-mark-1840 2))) (go ELSE1843))
    (return-from |c/minimize_literal| 2)
    ELSE1843
    (unless (c-true (if (c-true v-depth-1838) (c-bool (c-s32 (logand v-mark-1840 1))) 0)) (go ELSE1845))
    (return-from |c/minimize_literal| 2)
    ELSE1845
    (setf v-level-1847 (m-u32 (+ (m-ptr (+ v-solver-1836 32)) (* 4 v-idx-1839))))
    (unless (c-true (if (c-true v-level-1847) 0 1)) (go ELSE1848))
    (return-from |c/minimize_literal| 2)
    ELSE1848
    (unless (c-true (if (> (float v-depth-1838 1d0) 10000.0d0) 1 0)) (go ELSE1850))
    (return-from |c/minimize_literal| 4)
    ELSE1850
    (unless (c-true (if (c-true (if (c-true v-depth-1838) 0 1)) (c-bool (if (< (m-u32 (+ (+ (+ (m-ptr (+ (+ v-solver-1836 576) 0)) (* 24 (progn 0 (c-u32 (- v-level-1847 (c-u32 1)))))) 12) 4)) (c-u32 2)) 1 0)) 0)) (go ELSE1852))
    (return-from |c/minimize_literal| 4)
    ELSE1852
    (unless (c-true (if (<= (m-u32 (+ (m-ptr (+ v-solver-1836 224)) (* 4 v-idx-1839))) (m-u32 (+ (+ (+ (m-ptr (+ (+ v-solver-1836 576) 0)) (* 24 (progn 0 (c-u32 (- v-level-1847 (c-u32 1)))))) 12) 0))) 1 0)) (go ELSE1854))
    (return-from |c/minimize_literal| 4)
    ELSE1854
    (setf v-reason-1856 (m-ptr (+ (m-ptr (+ v-solver-1836 416)) (* 8 v-idx-1839))))
    (unless (c-true (if (c-true v-reason-1856) 0 1)) (go ELSE1857))
    (return-from |c/minimize_literal| 4)
    ELSE1857
    (unless (c-true (if (c-true (m-s8 (+ (m-ptr (+ v-solver-1836 232)) (* 1 v-level-1847)))) 0 1)) (go ELSE1859))
    (return-from |c/minimize_literal| 4)
    ELSE1859
    (setf v-res-1861 2)
    (unless (c-true (|c/is_tagged_clause| v-reason-1856)) (go ELSE1862))
    (progn (setf v-reason-1856 (|c/untag_clause| v-solver-1836 (c-u32 0) (|c/NOT| v-lit-1837) v-reason-1856)))
    (go ENDIF1863)
    ELSE1862
    (progn (progn 0 (let* ((a1864 (+ (+ v-solver-1836 1016) 360)) (old1865 (m-u64 a1864))) (setf (m-u64 a1864) (c-u64 (c-u64 (+ old1865 (c-u64 1))))) (m-u64 a1864))))
    ENDIF1863
    (setf v-not_lit-1866 (|c/NOT| v-lit-1837))
    (progn v-solver-1836)
    (setf v-P_other-1874 (+ v-reason-1856 16))
    (setf v-END_other-1875 (+ v-P_other-1874 (* 4 (m-u32 (+ v-reason-1856 12)))))
    LOOP1870
    (unless (c-true (if (c-true (if (/= v-P_other-1874 v-END_other-1875) 1 0)) (c-bool (progn (setf v-other-1873 (m-u32 v-P_other-1874)) 1)) 0)) (go ENDLOOP1871))
    (unless (c-true (if (= v-other-1873 v-not_lit-1866) 1 0)) (go ELSE1876))
    (go CONTINUE1872)
    ELSE1876
    (unless (c-true (if (= (|c/minimize_literal| v-solver-1836 v-other-1873 (c-u32 (+ v-depth-1838 (c-u32 1)))) 2) 1 0)) (go ELSE1878))
    (go CONTINUE1872)
    ELSE1878
    (progn (setf v-res-1861 4))
    (go ENDLOOP1871)
    CONTINUE1872
    (let* ( (old1881 v-P_other-1874)) (setf v-P_other-1874 (+ old1881 (* 4 1))) v-P_other-1874)
    (go LOOP1870)
    ENDLOOP1871
    (unless (c-true v-depth-1838) (go ELSE1882))
    (unless (c-true (if (= v-res-1861 2) 1 0)) (go ELSE1884))
    (progn (|c/mark_removable| v-solver-1836 v-idx-1839))
    (go ENDIF1885)
    ELSE1884
    (progn (|c/mark_poisoned| v-solver-1836 v-idx-1839))
    ENDIF1885
    (go ENDIF1883)
    ELSE1882
    ENDIF1883
    (progn v-solver-1836)
    (return-from |c/minimize_literal| v-res-1861)
  )
  0))

;;; upstream/satch.c:5311:1
(defun |c/reset_removable_and_poisoned| (arg-v-solver-1889)
 (declare  (type c-address arg-v-solver-1889))
 (let ((v-solver-1889 0) (v-idx-1893 0) (v-PTR_idx-1894 0) (v-END_idx-1895 0) (v-idx-1905 0) (v-PTR_idx-1906 0) (v-END_idx-1907 0))
 (declare (type c-address v-solver-1889) (type (unsigned-byte 32) v-idx-1893) (type c-address v-PTR_idx-1894) (type c-address v-END_idx-1895) (type (unsigned-byte 32) v-idx-1905) (type c-address v-PTR_idx-1906) (type c-address v-END_idx-1907) (ignorable v-solver-1889 v-idx-1893 v-PTR_idx-1894 v-END_idx-1895 v-idx-1905 v-PTR_idx-1906 v-END_idx-1907))
 (tagbody
    (setf v-solver-1889 arg-v-solver-1889)
    (setf v-PTR_idx-1894 (m-ptr (+ (+ v-solver-1889 152) 0)))
    (setf v-END_idx-1895 (m-ptr (+ (+ v-solver-1889 152) 8)))
    LOOP1890
    (unless (c-true (if (c-true (if (/= v-PTR_idx-1894 v-END_idx-1895) 1 0)) (c-bool (progn (setf v-idx-1893 (m-u32 v-PTR_idx-1894)) 1)) 0)) (go ENDLOOP1891))
    (progn (let ((a1896 (+ (m-ptr (+ v-solver-1889 96)) (* 1 v-idx-1893)))) (setf (m-s8 a1896) (c-s8 (c-s32 (logand (m-s8 a1896) (c-s32 (lognot 4))))))))
    (let* ( (old1898 v-PTR_idx-1894)) (setf v-PTR_idx-1894 (+ old1898 (* 4 1))) v-PTR_idx-1894)
    (go LOOP1890)
    ENDLOOP1891
    (progn (setf (m-ptr (+ (+ v-solver-1889 152) 8)) (m-ptr (+ (+ v-solver-1889 152) 0))))
    (setf v-PTR_idx-1906 (m-ptr (+ (+ v-solver-1889 176) 0)))
    (setf v-END_idx-1907 (m-ptr (+ (+ v-solver-1889 176) 8)))
    LOOP1902
    (unless (c-true (if (c-true (if (/= v-PTR_idx-1906 v-END_idx-1907) 1 0)) (c-bool (progn (setf v-idx-1905 (m-u32 v-PTR_idx-1906)) 1)) 0)) (go ENDLOOP1903))
    (progn (let ((a1908 (+ (m-ptr (+ v-solver-1889 96)) (* 1 v-idx-1905)))) (setf (m-s8 a1908) (c-s8 (c-s32 (logand (m-s8 a1908) (c-s32 (lognot 2))))))))
    (let* ( (old1910 v-PTR_idx-1906)) (setf v-PTR_idx-1906 (+ old1910 (* 4 1))) v-PTR_idx-1906)
    (go LOOP1902)
    ENDLOOP1903
    (progn (setf (m-ptr (+ (+ v-solver-1889 176) 8)) (m-ptr (+ (+ v-solver-1889 176) 0))))
  )
  0))

;;; upstream/satch.c:5334:1
(defun |c/mark_analyzed| (arg-v-solver-1914 arg-v-idx-1915)
 (declare  (type c-address arg-v-solver-1914) (type (unsigned-byte 32) arg-v-idx-1915))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-1914 0) (v-idx-1915 0) (v-analyzed-1917 (stack-alloc 8)) (v-old_size-1926 0) (v-old_capacity-1927 0) (v-new_capacity-1928 0) (v-new_bytes-1929 0))
 (declare (type c-address v-solver-1914) (type (unsigned-byte 32) v-idx-1915) (type c-address v-analyzed-1917) (type c-size v-old_size-1926) (type c-size v-old_capacity-1927) (type c-size v-new_capacity-1928) (type c-size v-new_bytes-1929) (ignorable v-solver-1914 v-idx-1915 v-analyzed-1917 v-old_size-1926 v-old_capacity-1927 v-new_capacity-1928 v-new_bytes-1929))
 (tagbody
    (setf v-solver-1914 arg-v-solver-1914)
    (setf v-idx-1915 arg-v-idx-1915)
    (progn (let ((a1916 (+ (m-ptr (+ v-solver-1914 96)) (* 1 v-idx-1915)))) (setf (m-s8 a1916) (c-s8 (c-s32 (logior (m-s8 a1916) 1))))))
    (progn (setf (m-u32 (+ v-analyzed-1917 0)) v-idx-1915))
    (progn (setf (m-u32 (+ v-analyzed-1917 4)) 4294967295))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-1914 600) 8)) (m-ptr (+ (+ v-solver-1914 600) 16))) 1 0)) (go ELSE1921))
    (setf v-old_size-1926 (the c-size (truncate (- (m-ptr (+ (+ v-solver-1914 600) 8)) (m-ptr (+ (+ v-solver-1914 600) 0))) 8)))
    (setf v-old_capacity-1927 (the c-size (truncate (- (m-ptr (+ (+ v-solver-1914 600) 16)) (m-ptr (+ (+ v-solver-1914 600) 0))) 8)))
    (setf v-new_capacity-1928 (if (c-true v-old_capacity-1927) (c-u64 (* (c-u64 2) v-old_capacity-1927)) (c-u64 1)))
    (setf v-new_bytes-1929 (c-u64 (* v-new_capacity-1928 8)))
    (progn (setf (m-ptr (+ (+ v-solver-1914 600) 0)) (c-realloc (m-ptr (+ (+ v-solver-1914 600) 0)) v-new_bytes-1929)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-1914 600) 0))) 0 1)) (go ELSE1930))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-1929))
    (go ENDIF1931)
    ELSE1930
    ENDIF1931
    (progn (setf (m-ptr (+ (+ v-solver-1914 600) 8)) (+ (m-ptr (+ (+ v-solver-1914 600) 0)) (* 8 v-old_size-1926))))
    (progn (setf (m-ptr (+ (+ v-solver-1914 600) 16)) (+ (m-ptr (+ (+ v-solver-1914 600) 0)) (* 8 v-new_capacity-1928))))
    (go ENDIF1922)
    ELSE1921
    ENDIF1922
    (progn (copy-bytes (let* ((a1932 (+ (+ v-solver-1914 600) 8)) (old1933 (m-ptr a1932))) (setf (m-ptr a1932) (+ old1933 (* 8 1))) old1933) v-analyzed-1917 8))
    (progn v-solver-1914)
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:5348:1
(defun |c/analyze_literal| (arg-v-solver-1937 arg-v-lit-1938)
 (declare  (type c-address arg-v-solver-1937) (type (unsigned-byte 32) arg-v-lit-1938))
 (let ((v-solver-1937 0) (v-lit-1938 0) (v-idx-1939 0) (v-lit_level-1940 0))
 (declare (type c-address v-solver-1937) (type (unsigned-byte 32) v-lit-1938) (type (unsigned-byte 32) v-idx-1939) (type (unsigned-byte 32) v-lit_level-1940) (ignorable v-solver-1937 v-lit-1938 v-idx-1939 v-lit_level-1940))
 (tagbody
    (setf v-solver-1937 arg-v-solver-1937)
    (setf v-lit-1938 arg-v-lit-1938)
    (setf v-idx-1939 (|c/INDEX| v-lit-1938))
    (setf v-lit_level-1940 (m-u32 (+ (m-ptr (+ v-solver-1937 32)) (* 4 v-idx-1939))))
    (unless (c-true (if (c-true v-lit_level-1940) 0 1)) (go ELSE1941))
    (return-from |c/analyze_literal| 4294967295)
    ELSE1941
    (unless (c-true (m-s8 (+ (m-ptr (+ v-solver-1937 96)) (* 1 v-idx-1939)))) (go ELSE1943))
    (return-from |c/analyze_literal| 4294967295)
    ELSE1943
    (progn (|c/mark_analyzed| v-solver-1937 v-idx-1939))
    (return-from |c/analyze_literal| v-lit_level-1940)
  )
  0))

;;; upstream/satch.c:5373:1
(defun |c/mark_shrunken| (arg-v-solver-1945 arg-v-idx-1946)
 (declare  (type c-address arg-v-solver-1945) (type (unsigned-byte 32) arg-v-idx-1946))
 (let ((v-solver-1945 0) (v-idx-1946 0) (v-old_size-1956 0) (v-old_capacity-1957 0) (v-new_capacity-1958 0) (v-new_bytes-1959 0))
 (declare (type c-address v-solver-1945) (type (unsigned-byte 32) v-idx-1946) (type c-size v-old_size-1956) (type c-size v-old_capacity-1957) (type c-size v-new_capacity-1958) (type c-size v-new_bytes-1959) (ignorable v-solver-1945 v-idx-1946 v-old_size-1956 v-old_capacity-1957 v-new_capacity-1958 v-new_bytes-1959))
 (tagbody
    (setf v-solver-1945 arg-v-solver-1945)
    (setf v-idx-1946 arg-v-idx-1946)
    (progn (let ((a1947 (+ (m-ptr (+ v-solver-1945 96)) (* 1 v-idx-1946)))) (setf (m-s8 a1947) (c-s8 (c-s32 (logior (m-s8 a1947) 8))))))
    (unless (c-true (if (= (m-ptr (+ (+ v-solver-1945 200) 8)) (m-ptr (+ (+ v-solver-1945 200) 16))) 1 0)) (go ELSE1951))
    (setf v-old_size-1956 (the c-size (truncate (- (m-ptr (+ (+ v-solver-1945 200) 8)) (m-ptr (+ (+ v-solver-1945 200) 0))) 4)))
    (setf v-old_capacity-1957 (the c-size (truncate (- (m-ptr (+ (+ v-solver-1945 200) 16)) (m-ptr (+ (+ v-solver-1945 200) 0))) 4)))
    (setf v-new_capacity-1958 (if (c-true v-old_capacity-1957) (c-u64 (* (c-u64 2) v-old_capacity-1957)) (c-u64 1)))
    (setf v-new_bytes-1959 (c-u64 (* v-new_capacity-1958 4)))
    (progn (setf (m-ptr (+ (+ v-solver-1945 200) 0)) (c-realloc (m-ptr (+ (+ v-solver-1945 200) 0)) v-new_bytes-1959)))
    (unless (c-true (if (c-true (m-ptr (+ (+ v-solver-1945 200) 0))) 0 1)) (go ELSE1960))
    (progn (|c/fatal_error| |c/string/98| v-new_bytes-1959))
    (go ENDIF1961)
    ELSE1960
    ENDIF1961
    (progn (setf (m-ptr (+ (+ v-solver-1945 200) 8)) (+ (m-ptr (+ (+ v-solver-1945 200) 0)) (* 4 v-old_size-1956))))
    (progn (setf (m-ptr (+ (+ v-solver-1945 200) 16)) (+ (m-ptr (+ (+ v-solver-1945 200) 0)) (* 4 v-new_capacity-1958))))
    (go ENDIF1952)
    ELSE1951
    ENDIF1952
    (progn (setf (m-u32 (let* ((a1962 (+ (+ v-solver-1945 200) 8)) (old1963 (m-ptr a1962))) (setf (m-ptr a1962) (+ old1963 (* 4 1))) old1963)) v-idx-1946))
    (progn v-solver-1945)
  )
  0))

;;; upstream/satch.c:5384:1
(defun |c/reset_shrunken| (arg-v-solver-1967)
 (declare  (type c-address arg-v-solver-1967))
 (let ((v-solver-1967 0) (v-marks-1971 0) (v-idx-1975 0) (v-PTR_idx-1976 0) (v-END_idx-1977 0))
 (declare (type c-address v-solver-1967) (type c-address v-marks-1971) (type (unsigned-byte 32) v-idx-1975) (type c-address v-PTR_idx-1976) (type c-address v-END_idx-1977) (ignorable v-solver-1967 v-marks-1971 v-idx-1975 v-PTR_idx-1976 v-END_idx-1977))
 (tagbody
    (setf v-solver-1967 arg-v-solver-1967)
    (progn v-solver-1967)
    (setf v-marks-1971 (m-ptr (+ v-solver-1967 96)))
    (setf v-PTR_idx-1976 (m-ptr (+ (+ v-solver-1967 200) 0)))
    (setf v-END_idx-1977 (m-ptr (+ (+ v-solver-1967 200) 8)))
    LOOP1972
    (unless (c-true (if (c-true (if (/= v-PTR_idx-1976 v-END_idx-1977) 1 0)) (c-bool (progn (setf v-idx-1975 (m-u32 v-PTR_idx-1976)) 1)) 0)) (go ENDLOOP1973))
    (progn (let ((a1978 (+ v-marks-1971 (* 1 v-idx-1975)))) (setf (m-s8 a1978) (c-s8 (c-s32 (logand (m-s8 a1978) (c-s32 (lognot 8))))))))
    (let* ( (old1980 v-PTR_idx-1976)) (setf v-PTR_idx-1976 (+ old1980 (* 4 1))) v-PTR_idx-1976)
    (go LOOP1972)
    ENDLOOP1973
    (progn (setf (m-ptr (+ (+ v-solver-1967 200) 8)) (m-ptr (+ (+ v-solver-1967 200) 0))))
  )
  0))

;;; upstream/satch.c:5396:1
(defun |c/mark_shrunken_as_removable| (arg-v-solver-1984)
 (declare  (type c-address arg-v-solver-1984))
 (let ((v-solver-1984 0) (v-marks-1985 0) (v-idx-1989 0) (v-PTR_idx-1990 0) (v-END_idx-1991 0))
 (declare (type c-address v-solver-1984) (type c-address v-marks-1985) (type (unsigned-byte 32) v-idx-1989) (type c-address v-PTR_idx-1990) (type c-address v-END_idx-1991) (ignorable v-solver-1984 v-marks-1985 v-idx-1989 v-PTR_idx-1990 v-END_idx-1991))
 (tagbody
    (setf v-solver-1984 arg-v-solver-1984)
    (setf v-marks-1985 (m-ptr (+ v-solver-1984 96)))
    (setf v-PTR_idx-1990 (m-ptr (+ (+ v-solver-1984 200) 0)))
    (setf v-END_idx-1991 (m-ptr (+ (+ v-solver-1984 200) 8)))
    LOOP1986
    (unless (c-true (if (c-true (if (/= v-PTR_idx-1990 v-END_idx-1991) 1 0)) (c-bool (progn (setf v-idx-1989 (m-u32 v-PTR_idx-1990)) 1)) 0)) (go ENDLOOP1987))
    (unless (c-true (if (c-true (c-s32 (logand (m-s8 (+ v-marks-1985 (* 1 v-idx-1989))) 2))) 0 1)) (go ELSE1992))
    (progn (|c/mark_removable| v-solver-1984 v-idx-1989))
    (go ENDIF1993)
    ELSE1992
    ENDIF1993
    (let* ( (old1995 v-PTR_idx-1990)) (setf v-PTR_idx-1990 (+ old1995 (* 4 1))) v-PTR_idx-1990)
    (go LOOP1986)
    ENDLOOP1987
  )
  0))

;;; upstream/satch.c:5417:1
(defun |c/shrink_literal| (arg-v-solver-1996 arg-v-block_level-1997 arg-v-lit-1998)
 (declare  (type c-address arg-v-solver-1996) (type (unsigned-byte 32) arg-v-block_level-1997) (type (unsigned-byte 32) arg-v-lit-1998))
 (let ((v-solver-1996 0) (v-block_level-1997 0) (v-lit-1998 0) (v-idx-1999 0) (v-lit_level-2000 0))
 (declare (type c-address v-solver-1996) (type (unsigned-byte 32) v-block_level-1997) (type (unsigned-byte 32) v-lit-1998) (type (unsigned-byte 32) v-idx-1999) (type (unsigned-byte 32) v-lit_level-2000) (ignorable v-solver-1996 v-block_level-1997 v-lit-1998 v-idx-1999 v-lit_level-2000))
 (tagbody
    (setf v-solver-1996 arg-v-solver-1996)
    (setf v-block_level-1997 arg-v-block_level-1997)
    (setf v-lit-1998 arg-v-lit-1998)
    (setf v-idx-1999 (|c/INDEX| v-lit-1998))
    (setf v-lit_level-2000 (m-u32 (+ (m-ptr (+ v-solver-1996 32)) (* 4 v-idx-1999))))
    (unless (c-true (if (c-true v-lit_level-2000) 0 1)) (go ELSE2001))
    (return-from |c/shrink_literal| 0)
    ELSE2001
    (unless (c-true (c-s32 (logand (m-s8 (+ (m-ptr (+ v-solver-1996 96)) (* 1 v-idx-1999))) 8))) (go ELSE2003))
    (return-from |c/shrink_literal| 0)
    ELSE2003
    (unless (c-true (if (< v-lit_level-2000 v-block_level-1997) 1 0)) (go ELSE2005))
    (return-from |c/shrink_literal| (if (c-true (if (= (|c/minimize_literal| v-solver-1996 v-lit-1998 (c-u32 1)) 2) 1 0)) 0 (c-s32 (- 1))))
    ELSE2005
    (progn (|c/mark_shrunken| v-solver-1996 v-idx-1999))
    (return-from |c/shrink_literal| 1)
  )
  0))

;;; upstream/satch.c:5436:1
(defun |c/shrunken_block| (arg-v-solver-2007 arg-v-begin-2008 arg-v-end-2009 arg-v-uip-2010)
 (declare  (type c-address arg-v-solver-2007) (type c-address arg-v-begin-2008) (type c-address arg-v-end-2009) (type (unsigned-byte 32) arg-v-uip-2010))
 (let ((v-solver-2007 0) (v-begin-2008 0) (v-end-2009 0) (v-uip-2010 0) (v-p-2014 0) (v-idx-2017 0) (v-level-2020 0) (v-saved-2023 0))
 (declare (type c-address v-solver-2007) (type c-address v-begin-2008) (type c-address v-end-2009) (type (unsigned-byte 32) v-uip-2010) (type c-address v-p-2014) (type (unsigned-byte 32) v-idx-2017) (type (unsigned-byte 32) v-level-2020) (type c-address v-saved-2023) (ignorable v-solver-2007 v-begin-2008 v-end-2009 v-uip-2010 v-p-2014 v-idx-2017 v-level-2020 v-saved-2023))
 (tagbody
    (setf v-solver-2007 arg-v-solver-2007)
    (setf v-begin-2008 arg-v-begin-2008)
    (setf v-end-2009 arg-v-end-2009)
    (setf v-uip-2010 arg-v-uip-2010)
    (setf v-p-2014 v-begin-2008)
    LOOP2011
    (unless (c-true (if (/= v-p-2014 v-end-2009) 1 0)) (go ENDLOOP2012))
    (progn (setf (m-u32 v-p-2014) 4294967295))
    (let* ( (old2016 v-p-2014)) (setf v-p-2014 (+ old2016 (* 4 1))) old2016)
    (go LOOP2011)
    ENDLOOP2012
    (progn (setf (m-u32 v-begin-2008) (|c/NOT| v-uip-2010)))
    (setf v-idx-2017 (|c/INDEX| v-uip-2010))
    (unless (c-true (if (c-true (c-s32 (logand (m-s8 (+ (m-ptr (+ v-solver-2007 96)) (* 1 v-idx-2017))) 1))) 0 1)) (go ELSE2018))
    (progn (|c/mark_analyzed| v-solver-2007 v-idx-2017))
    (go ENDIF2019)
    ELSE2018
    ENDIF2019
    (setf v-level-2020 (m-u32 (+ (m-ptr (+ v-solver-2007 32)) (* 4 v-idx-2017))))
    (unless (c-true (if (/= v-level-2020 (c-u32 0)) 1 0)) (go ELSE2021))
    (setf v-saved-2023 (+ (m-ptr (+ (+ v-solver-2007 576) 0)) (* 24 (progn 0 (c-u32 (- v-level-2020 (c-u32 1)))))))
    (unless (c-true (if (> (m-u32 (+ (+ v-saved-2023 12) 0)) (m-u32 (+ (m-ptr (+ v-solver-2007 224)) (* 4 v-idx-2017)))) 1 0)) (go ELSE2024))
    (progn (setf (m-u32 (+ (+ v-saved-2023 12) 0)) (m-u32 (+ (m-ptr (+ v-solver-2007 224)) (* 4 v-idx-2017)))))
    (go ENDIF2025)
    ELSE2024
    ENDIF2025
    (progn (let* ((a2026 (+ (+ v-saved-2023 12) 4)) (old2027 (m-u32 a2026))) (setf (m-u32 a2026) (c-u32 (c-u32 (+ old2027 (c-u32 1))))) (m-u32 a2026)))
    (progn v-solver-2007)
    (go ENDIF2022)
    ELSE2021
    ENDIF2022
    (progn (|c/mark_shrunken_as_removable| v-solver-2007))
    (progn (|c/reset_shrunken| v-solver-2007))
  )
  0))

;;; upstream/satch.c:5465:1
(defun |c/next_block| (arg-v-solver-2031 arg-v-end-2032)
 (declare  (type c-address arg-v-solver-2031) (type c-address arg-v-end-2032))
 (let ((v-solver-2031 0) (v-end-2032 0) (v-levels-2033 0) (v-block_level-2034 0) (v-begin-2035 0) (v-lit-2039 0) (v-idx-2040 0) (v-lit_level-2041 0))
 (declare (type c-address v-solver-2031) (type c-address v-end-2032) (type c-address v-levels-2033) (type (unsigned-byte 32) v-block_level-2034) (type c-address v-begin-2035) (type (unsigned-byte 32) v-lit-2039) (type (unsigned-byte 32) v-idx-2040) (type (unsigned-byte 32) v-lit_level-2041) (ignorable v-solver-2031 v-end-2032 v-levels-2033 v-block_level-2034 v-begin-2035 v-lit-2039 v-idx-2040 v-lit_level-2041))
 (tagbody
    (setf v-solver-2031 arg-v-solver-2031)
    (setf v-end-2032 arg-v-end-2032)
    (setf v-levels-2033 (m-ptr (+ v-solver-2031 32)))
    (setf v-block_level-2034 4294967295)
    (setf v-begin-2035 v-end-2032)
    LOOP2036
    (unless (c-true (if (< (m-ptr (+ (+ v-solver-2031 624) 0)) v-begin-2035) 1 0)) (go ENDLOOP2037))
    (setf v-lit-2039 (m-u32 (+ v-begin-2035 (* 4 (c-s32 (- 1))))))
    (setf v-idx-2040 (|c/INDEX| v-lit-2039))
    (setf v-lit_level-2041 (m-u32 (+ v-levels-2033 (* 4 v-idx-2040))))
    (unless (c-true (if (> v-lit_level-2041 v-block_level-2034) 1 0)) (go ELSE2042))
    (go ENDLOOP2037)
    ELSE2042
    (progn (setf v-block_level-2034 v-lit_level-2041))
    (progn (let* ( (old2045 v-begin-2035)) (setf v-begin-2035 (- old2045 (* 4 1))) old2045))
    (go LOOP2036)
    ENDLOOP2037
    (return-from |c/next_block| v-begin-2035)
  )
  0))

;;; upstream/satch.c:5487:1
(defun |c/shrink_block| (arg-v-solver-2046 arg-v-begin-2047 arg-v-end-2048)
 (declare  (type c-address arg-v-solver-2046) (type c-address arg-v-begin-2047) (type c-address arg-v-end-2048))
 (let ((v-solver-2046 0) (v-begin-2047 0) (v-end-2048 0) (v-open-2049 0) (v-block_level-2052 0) (v-trail-2056 0) (v-position-2057 0) (v-p-2061 0) (v-lit-2062 0) (v-idx-2063 0) (v-pos-2064 0) (v-t-2069 0) (v-uip-2070 0) (v-failed-2071 0) (v-marks-2072 0) (v-reasons-2073 0) (v-idx-2077 0) (v-reason-2087 0) (v-lit-2098 0) (v-P_lit-2099 0) (v-END_lit-2100 0) (v-tmp-2103 0))
 (declare (type c-address v-solver-2046) (type c-address v-begin-2047) (type c-address v-end-2048) (type (unsigned-byte 32) v-open-2049) (type (unsigned-byte 32) v-block_level-2052) (type (unsigned-byte 32) v-trail-2056) (type c-address v-position-2057) (type c-address v-p-2061) (type (unsigned-byte 32) v-lit-2062) (type (unsigned-byte 32) v-idx-2063) (type (unsigned-byte 32) v-pos-2064) (type c-address v-t-2069) (type (unsigned-byte 32) v-uip-2070) (type (integer 0 1) v-failed-2071) (type c-address v-marks-2072) (type c-address v-reasons-2073) (type (unsigned-byte 32) v-idx-2077) (type c-address v-reason-2087) (type (unsigned-byte 32) v-lit-2098) (type c-address v-P_lit-2099) (type c-address v-END_lit-2100) (type (signed-byte 32) v-tmp-2103) (ignorable v-solver-2046 v-begin-2047 v-end-2048 v-open-2049 v-block_level-2052 v-trail-2056 v-position-2057 v-p-2061 v-lit-2062 v-idx-2063 v-pos-2064 v-t-2069 v-uip-2070 v-failed-2071 v-marks-2072 v-reasons-2073 v-idx-2077 v-reason-2087 v-lit-2098 v-P_lit-2099 v-END_lit-2100 v-tmp-2103))
 (tagbody
    (setf v-solver-2046 arg-v-solver-2046)
    (setf v-begin-2047 arg-v-begin-2047)
    (setf v-end-2048 arg-v-end-2048)
    (setf v-open-2049 (c-u32 (truncate (- v-end-2048 v-begin-2047) 4)))
    (unless (c-true (if (< v-open-2049 (c-u32 2)) 1 0)) (go ELSE2050))
    (return-from |c/shrink_block| (c-bool 1))
    ELSE2050
    (setf v-block_level-2052 (m-u32 (+ (m-ptr (+ v-solver-2046 32)) (* 4 (|c/INDEX| (m-u32 v-begin-2047))))))
    (progn v-solver-2046)
    (setf v-trail-2056 (c-u32 0))
    (setf v-position-2057 (m-ptr (+ v-solver-2046 224)))
    (setf v-p-2061 v-begin-2047)
    LOOP2058
    (unless (c-true (if (/= v-p-2061 v-end-2048) 1 0)) (go ENDLOOP2059))
    (setf v-lit-2062 (m-u32 v-p-2061))
    (setf v-idx-2063 (|c/INDEX| v-lit-2062))
    (progn (|c/mark_shrunken| v-solver-2046 v-idx-2063))
    (setf v-pos-2064 (m-u32 (+ v-position-2057 (* 4 v-idx-2063))))
    (unless (c-true (if (> v-pos-2064 v-trail-2056) 1 0)) (go ELSE2065))
    (progn (setf v-trail-2056 v-pos-2064))
    (go ENDIF2066)
    ELSE2065
    ENDIF2066
    (let* ( (old2068 v-p-2061)) (setf v-p-2061 (+ old2068 (* 4 1))) old2068)
    (go LOOP2058)
    ENDLOOP2059
    (setf v-t-2069 (+ (m-ptr (+ (+ v-solver-2046 552) 0)) (* 4 v-trail-2056)))
    (setf v-uip-2070 4294967295)
    (setf v-failed-2071 (c-bool 0))
    (setf v-marks-2072 (m-ptr (+ v-solver-2046 96)))
    (setf v-reasons-2073 (m-ptr (+ v-solver-2046 416)))
    LOOP2074
    (unless (c-true (if (c-true v-failed-2071) 0 1)) (go ENDLOOP2075))
    LOOP2078
    (progn (progn 0 (setf v-uip-2070 (m-u32 (let* ( (old2082 v-t-2069)) (setf v-t-2069 (- old2082 (* 4 1))) old2082)))))
    (when (c-true (if (c-true (c-s32 (logand (m-s8 (+ v-marks-2072 (* 1 (setf v-idx-2077 (|c/INDEX| v-uip-2070))))) 8))) 0 1)) (go LOOP2078))
    (unless (c-true (if (c-true (let* ( (old2086 v-open-2049)) (setf v-open-2049 (c-u32 (c-u32 (- old2086 (c-u32 1))))) v-open-2049)) 0 1)) (go ELSE2083))
    (go ENDLOOP2075)
    ELSE2083
    (setf v-reason-2087 (m-ptr (+ v-reasons-2073 (* 8 v-idx-2077))))
    (unless (c-true (|c/is_tagged_clause| v-reason-2087)) (go ELSE2088))
    (progn (setf v-reason-2087 (|c/untag_clause| v-solver-2046 (c-u32 0) v-uip-2070 v-reason-2087)))
    (go ENDIF2089)
    ELSE2088
    (progn (progn 0 (let* ((a2090 (+ (+ v-solver-2046 1016) 360)) (old2091 (m-u64 a2090))) (setf (m-u64 a2090) (c-u64 (c-u64 (+ old2091 (c-u64 1))))) (m-u64 a2090))))
    ENDIF2089
    (progn v-solver-2046)
    (setf v-P_lit-2099 (+ v-reason-2087 16))
    (setf v-END_lit-2100 (+ v-P_lit-2099 (* 4 (m-u32 (+ v-reason-2087 12)))))
    LOOP2095
    (unless (c-true (if (c-true (if (/= v-P_lit-2099 v-END_lit-2100) 1 0)) (c-bool (progn (setf v-lit-2098 (m-u32 v-P_lit-2099)) 1)) 0)) (go ENDLOOP2096))
    (unless (c-true (if (/= v-lit-2098 v-uip-2070) 1 0)) (go ELSE2101))
    (setf v-tmp-2103 (|c/shrink_literal| v-solver-2046 v-block_level-2052 v-lit-2098))
    (unless (c-true (setf v-failed-2071 (c-bool (if (< v-tmp-2103 0) 1 0)))) (go ELSE2104))
    (go ENDLOOP2096)
    ELSE2104
    (progn (setf v-open-2049 (c-u32 (c-u32 (+ v-open-2049 (c-u32 (if (> v-tmp-2103 0) 1 0)))))))
    (go ENDIF2102)
    ELSE2101
    ENDIF2102
    (let* ( (old2108 v-P_lit-2099)) (setf v-P_lit-2099 (+ old2108 (* 4 1))) v-P_lit-2099)
    (go LOOP2095)
    ENDLOOP2096
    (go LOOP2074)
    ENDLOOP2075
    (unless (c-true v-failed-2071) (go ELSE2109))
    (progn (|c/reset_shrunken| v-solver-2046))
    (go ENDIF2110)
    ELSE2109
    (progn (|c/shrunken_block| v-solver-2046 v-begin-2047 v-end-2048 v-uip-2070))
    ENDIF2110
    (progn v-solver-2046)
    (return-from |c/shrink_block| (c-bool (if (c-true v-failed-2071) 0 1)))
  )
  0))

;;; upstream/satch.c:5578:1
(defun |c/minimize_block| (arg-v-solver-2114 arg-v-begin-2115 arg-v-end-2116)
 (declare  (type c-address arg-v-solver-2114) (type c-address arg-v-begin-2115) (type c-address arg-v-end-2116))
 (let ((v-solver-2114 0) (v-begin-2115 0) (v-end-2116 0) (v-minimized-2117 0) (v-p-2121 0))
 (declare (type c-address v-solver-2114) (type c-address v-begin-2115) (type c-address v-end-2116) (type (unsigned-byte 32) v-minimized-2117) (type c-address v-p-2121) (ignorable v-solver-2114 v-begin-2115 v-end-2116 v-minimized-2117 v-p-2121))
 (tagbody
    (setf v-solver-2114 arg-v-solver-2114)
    (setf v-begin-2115 arg-v-begin-2115)
    (setf v-end-2116 arg-v-end-2116)
    (setf v-minimized-2117 (c-u32 0))
    (setf v-p-2121 v-begin-2115)
    LOOP2118
    (unless (c-true (if (/= v-p-2121 v-end-2116) 1 0)) (go ENDLOOP2119))
    (unless (c-true (if (= (|c/minimize_literal| v-solver-2114 (m-u32 v-p-2121) (c-u32 0)) 2) 1 0)) (go ELSE2122))
    (progn (progn (setf (m-u32 v-p-2121) 4294967295) (let* ( (old2125 v-minimized-2117)) (setf v-minimized-2117 (c-u32 (c-u32 (+ old2125 (c-u32 1))))) old2125)))
    (go ENDIF2123)
    ELSE2122
    ENDIF2123
    (let* ( (old2127 v-p-2121)) (setf v-p-2121 (+ old2127 (* 4 1))) old2127)
    (go LOOP2118)
    ENDLOOP2119
    (progn (let ((a2131 (+ (+ v-solver-2114 1016) 152))) (setf (m-u64 a2131) (c-u64 (c-u64 (+ (m-u64 a2131) v-minimized-2117))))))
    (progn v-solver-2114)
  )
  0))

;;; upstream/satch.c:5593:1
(defun |c/shrink_deduced_clause| (arg-v-solver-2135)
 (declare  (type c-address arg-v-solver-2135))
 (let ((v-solver-2135 0) (v-end-2136 0) (v-begin-2140 0) (v-end-2143 0) (v-q-2144 0) (v-lit-2145 0) (v-p-2149 0) (v-shrunken-2156 0))
 (declare (type c-address v-solver-2135) (type c-address v-end-2136) (type c-address v-begin-2140) (type c-address v-end-2143) (type c-address v-q-2144) (type (unsigned-byte 32) v-lit-2145) (type c-address v-p-2149) (type (unsigned-byte 32) v-shrunken-2156) (ignorable v-solver-2135 v-end-2136 v-begin-2140 v-end-2143 v-q-2144 v-lit-2145 v-p-2149 v-shrunken-2156))
 (tagbody
    (setf v-solver-2135 arg-v-solver-2135)
    (setf v-end-2136 (m-ptr (+ (+ v-solver-2135 624) 8)))
    LOOP2137
    (unless (c-true (if (/= v-end-2136 (m-ptr (+ (+ v-solver-2135 624) 0))) 1 0)) (go ENDLOOP2138))
    (setf v-begin-2140 (|c/next_block| v-solver-2135 v-end-2136))
    (unless (c-true (if (c-true (|c/shrink_block| v-solver-2135 v-begin-2140 v-end-2136)) 0 1)) (go ELSE2141))
    (progn (|c/minimize_block| v-solver-2135 v-begin-2140 v-end-2136))
    (go ENDIF2142)
    ELSE2141
    ENDIF2142
    (progn (setf v-end-2136 v-begin-2140))
    (go LOOP2137)
    ENDLOOP2138
    (setf v-end-2143 (m-ptr (+ (+ v-solver-2135 624) 8)))
    (setf v-q-2144 (m-ptr (+ (+ v-solver-2135 624) 0)))
    (setf v-p-2149 v-q-2144)
    LOOP2146
    (unless (c-true (if (/= v-p-2149 v-end-2143) 1 0)) (go ENDLOOP2147))
    (unless (c-true (if (/= (setf v-lit-2145 (m-u32 v-p-2149)) 4294967295) 1 0)) (go ELSE2150))
    (progn (setf (m-u32 (let* ( (old2153 v-q-2144)) (setf v-q-2144 (+ old2153 (* 4 1))) old2153)) v-lit-2145))
    (go ENDIF2151)
    ELSE2150
    ENDIF2151
    (let* ( (old2155 v-p-2149)) (setf v-p-2149 (+ old2155 (* 4 1))) old2155)
    (go LOOP2146)
    ENDLOOP2147
    (setf v-shrunken-2156 (c-u32 (truncate (- v-end-2143 v-q-2144) 4)))
    (progn (setf (m-ptr (+ (+ v-solver-2135 624) 8)) v-q-2144))
    (progn v-solver-2135)
    (progn (let ((a2163 (+ (+ v-solver-2135 1016) 280))) (setf (m-u64 a2163) (c-u64 (c-u64 (+ (m-u64 a2163) v-shrunken-2156))))))
    (progn v-solver-2135)
  )
  0))

;;; upstream/satch.c:5642:1
(defun |c/bump_reason_side_literals| (arg-v-solver-2167)
 (declare  (type c-address arg-v-solver-2167))
 (let ((v-solver-2167 0) (v-a-2168 0) (v-reasons-2171 0) (v-lit-2175 0) (v-PTR_lit-2176 0) (v-END_lit-2177 0) (v-idx-2178 0) (v-reason-2179 0) (v-other-2187 0) (v-P_other-2188 0) (v-END_other-2189 0))
 (declare (type c-address v-solver-2167) (type c-address v-a-2168) (type c-address v-reasons-2171) (type (unsigned-byte 32) v-lit-2175) (type c-address v-PTR_lit-2176) (type c-address v-END_lit-2177) (type (unsigned-byte 32) v-idx-2178) (type c-address v-reason-2179) (type (unsigned-byte 32) v-other-2187) (type c-address v-P_other-2188) (type c-address v-END_other-2189) (ignorable v-solver-2167 v-a-2168 v-reasons-2171 v-lit-2175 v-PTR_lit-2176 v-END_lit-2177 v-idx-2178 v-reason-2179 v-other-2187 v-P_other-2188 v-END_other-2189))
 (tagbody
    (setf v-solver-2167 arg-v-solver-2167)
    (setf v-a-2168 (|c/averages| v-solver-2167))
    (unless (c-true (if (>= (|c/unbiased_slow_average| v-a-2168 (m-f64 (+ v-a-2168 32))) (float 10 1d0)) 1 0)) (go ELSE2169))
    (return-from |c/bump_reason_side_literals| 0)
    ELSE2169
    (setf v-reasons-2171 (m-ptr (+ v-solver-2167 416)))
    (setf v-PTR_lit-2176 (m-ptr (+ (+ v-solver-2167 624) 0)))
    (setf v-END_lit-2177 (m-ptr (+ (+ v-solver-2167 624) 8)))
    LOOP2172
    (unless (c-true (if (c-true (if (/= v-PTR_lit-2176 v-END_lit-2177) 1 0)) (c-bool (progn (setf v-lit-2175 (m-u32 v-PTR_lit-2176)) 1)) 0)) (go ENDLOOP2173))
    (setf v-idx-2178 (|c/INDEX| v-lit-2175))
    (setf v-reason-2179 (m-ptr (+ v-reasons-2171 (* 8 v-idx-2178))))
    (unless (c-true (|c/is_tagged_clause| v-reason-2179)) (go ELSE2180))
    (progn (setf v-reason-2179 (|c/untag_clause| v-solver-2167 (c-u32 0) (|c/NOT| v-lit-2175) v-reason-2179)))
    (go ENDIF2181)
    ELSE2180
    ENDIF2181
    (unless (c-true (if (c-true v-reason-2179) 0 1)) (go ELSE2182))
    (go CONTINUE2174)
    ELSE2182
    (setf v-P_other-2188 (+ v-reason-2179 16))
    (setf v-END_other-2189 (+ v-P_other-2188 (* 4 (m-u32 (+ v-reason-2179 12)))))
    LOOP2184
    (unless (c-true (if (c-true (if (/= v-P_other-2188 v-END_other-2189) 1 0)) (c-bool (progn (setf v-other-2187 (m-u32 v-P_other-2188)) 1)) 0)) (go ENDLOOP2185))
    (unless (c-true (if (/= (|c/analyze_literal| v-solver-2167 v-other-2187) 4294967295) 1 0)) (go ELSE2190))
    (progn (progn 0 (let* ((a2192 (+ (+ v-solver-2167 1016) 176)) (old2193 (m-u64 a2192))) (setf (m-u64 a2192) (c-u64 (c-u64 (+ old2193 (c-u64 1))))) (m-u64 a2192))))
    (go ENDIF2191)
    ELSE2190
    ENDIF2191
    (let* ( (old2195 v-P_other-2188)) (setf v-P_other-2188 (+ old2195 (* 4 1))) v-P_other-2188)
    (go LOOP2184)
    ENDLOOP2185
    CONTINUE2174
    (let* ( (old2197 v-PTR_lit-2176)) (setf v-PTR_lit-2176 (+ old2197 (* 4 1))) v-PTR_lit-2176)
    (go LOOP2172)
    ENDLOOP2173
  )
  0))

;;; upstream/satch.c:5683:1
(defun |c/add_stamps| (arg-v-solver-2198)
 (declare  (type c-address arg-v-solver-2198))
 (let ((v-solver-2198 0) (v-queue-2199 0) (v-links-2200 0) (v-end-2201 0) (v-begin-2202 0) (v-p-2206 0))
 (declare (type c-address v-solver-2198) (type c-address v-queue-2199) (type c-address v-links-2200) (type c-address v-end-2201) (type c-address v-begin-2202) (type c-address v-p-2206) (ignorable v-solver-2198 v-queue-2199 v-links-2200 v-end-2201 v-begin-2202 v-p-2206))
 (tagbody
    (setf v-solver-2198 arg-v-solver-2198)
    (setf v-queue-2199 (|c/get_queue| v-solver-2198))
    (setf v-links-2200 (m-ptr (+ v-queue-2199 0)))
    (setf v-end-2201 (m-ptr (+ (+ v-solver-2198 600) 8)))
    (setf v-begin-2202 (m-ptr (+ (+ v-solver-2198 600) 0)))
    (setf v-p-2206 v-begin-2202)
    LOOP2203
    (unless (c-true (if (/= v-p-2206 v-end-2201) 1 0)) (go ENDLOOP2204))
    (progn (setf (m-u32 (+ v-p-2206 4)) (m-u32 (+ (+ v-links-2200 (* 12 (m-u32 (+ v-p-2206 0)))) 8))))
    (let* ( (old2208 v-p-2206)) (setf v-p-2206 (+ old2208 (* 8 1))) old2208)
    (go LOOP2203)
    ENDLOOP2204
  )
  0))

;;; upstream/satch.c:5724:1
(defun |c/sort_analyzed| (arg-v-solver-2209)
 (declare (optimize (speed 1) (compilation-speed 3)) (notinline checked-address) (type c-address arg-v-solver-2209))
 (let ((frame *stack-top*)) (unwind-protect
(let ((v-solver-2209 0) (v-N_RANK-2213 0) (v-V_RANK-2216 0) (v-LENGTH_RANK-2217 0) (v-WIDTH_RANK-2218 0) (v-MASK_RANK-2219 0) (v-COUNT_RANK-2220 (stack-alloc 2048)) (v-TMP_RANK-2221 0) (v-BYTES_TMP_RANK-2222 0) (v-A_RANK-2223 0) (v-B_RANK-2224 0) (v-C_RANK-2225 0) (v-MLOWER_RANK-2226 0) (v-MUPPER_RANK-2227 0) (v-BOUNDED_RANK-2228 0) (v-UPPER_RANK-2229 0) (v-LOWER_RANK-2230 0) (v-SHIFT_RANK-2231 0) (v-I_RANK-2235 0) (v-END_RANK-2238 0) (v-SORTED_RANK-2239 0) (v-LAST_RANK-2240 0) (v-P_RANK-2244 0) (v-R_RANK-2245 0) (v-S_RANK-2250 0) (v-M_RANK-2251 0) (v-POS_RANK-2264 0) (v-J_RANK-2268 0) (v-DELTA_RANK-2269 0) (v-D_RANK-2277 0) (v-P_RANK-2281 0) (v-R_RANK-2282 0) (v-S_RANK-2283 0) (v-M_RANK-2284 0) (v-POS_RANK-2285 0))
 (declare (type c-address v-solver-2209) (type c-size v-N_RANK-2213) (type c-address v-V_RANK-2216) (type c-size v-LENGTH_RANK-2217) (type c-size v-WIDTH_RANK-2218) (type (unsigned-byte 32) v-MASK_RANK-2219) (type c-address v-COUNT_RANK-2220) (type c-address v-TMP_RANK-2221) (type c-size v-BYTES_TMP_RANK-2222) (type c-address v-A_RANK-2223) (type c-address v-B_RANK-2224) (type c-address v-C_RANK-2225) (type (unsigned-byte 32) v-MLOWER_RANK-2226) (type (unsigned-byte 32) v-MUPPER_RANK-2227) (type (integer 0 1) v-BOUNDED_RANK-2228) (type (unsigned-byte 32) v-UPPER_RANK-2229) (type (unsigned-byte 32) v-LOWER_RANK-2230) (type (unsigned-byte 32) v-SHIFT_RANK-2231) (type c-size v-I_RANK-2235) (type c-address v-END_RANK-2238) (type (integer 0 1) v-SORTED_RANK-2239) (type (unsigned-byte 32) v-LAST_RANK-2240) (type c-address v-P_RANK-2244) (type (unsigned-byte 32) v-R_RANK-2245) (type (unsigned-byte 32) v-S_RANK-2250) (type (unsigned-byte 32) v-M_RANK-2251) (type c-size v-POS_RANK-2264) (type c-size v-J_RANK-2268) (type c-size v-DELTA_RANK-2269) (type c-address v-D_RANK-2277) (type c-address v-P_RANK-2281) (type (unsigned-byte 32) v-R_RANK-2282) (type (unsigned-byte 32) v-S_RANK-2283) (type (unsigned-byte 32) v-M_RANK-2284) (type c-size v-POS_RANK-2285) (ignorable v-solver-2209 v-N_RANK-2213 v-V_RANK-2216 v-LENGTH_RANK-2217 v-WIDTH_RANK-2218 v-MASK_RANK-2219 v-COUNT_RANK-2220 v-TMP_RANK-2221 v-BYTES_TMP_RANK-2222 v-A_RANK-2223 v-B_RANK-2224 v-C_RANK-2225 v-MLOWER_RANK-2226 v-MUPPER_RANK-2227 v-BOUNDED_RANK-2228 v-UPPER_RANK-2229 v-LOWER_RANK-2230 v-SHIFT_RANK-2231 v-I_RANK-2235 v-END_RANK-2238 v-SORTED_RANK-2239 v-LAST_RANK-2240 v-P_RANK-2244 v-R_RANK-2245 v-S_RANK-2250 v-M_RANK-2251 v-POS_RANK-2264 v-J_RANK-2268 v-DELTA_RANK-2269 v-D_RANK-2277 v-P_RANK-2281 v-R_RANK-2282 v-S_RANK-2283 v-M_RANK-2284 v-POS_RANK-2285))
 (tagbody
    (setf v-solver-2209 arg-v-solver-2209)
    (progn (|c/add_stamps| v-solver-2209))
    (setf v-N_RANK-2213 (the c-size (truncate (- (m-ptr (+ (+ v-solver-2209 600) 8)) (m-ptr (+ (+ v-solver-2209 600) 0))) 8)))
    (unless (c-true (if (<= v-N_RANK-2213 (c-u64 1)) 1 0)) (go ELSE2214))
    (go ENDLOOP2211)
    ELSE2214
    (setf v-V_RANK-2216 (m-ptr (+ (+ v-solver-2209 600) 0)))
    (setf v-LENGTH_RANK-2217 (c-u64 8))
    (setf v-WIDTH_RANK-2218 (c-u64 (c-s32 (ash (c-s32 1) v-LENGTH_RANK-2217))))
    (setf v-MASK_RANK-2219 (c-u32 (c-u64 (- v-WIDTH_RANK-2218 (c-u64 1)))))
    (setf v-TMP_RANK-2221 0)
    (setf v-BYTES_TMP_RANK-2222 (c-u64 (* v-N_RANK-2213 8)))
    (setf v-A_RANK-2223 v-V_RANK-2216)
    (setf v-B_RANK-2224 0)
    (setf v-C_RANK-2225 v-A_RANK-2223)
    (setf v-MLOWER_RANK-2226 (c-u32 0))
    (setf v-MUPPER_RANK-2227 v-MASK_RANK-2219)
    (setf v-BOUNDED_RANK-2228 (c-bool 0))
    (setf v-UPPER_RANK-2229 (c-u32 0))
    (setf v-LOWER_RANK-2230 (c-u32 (lognot v-UPPER_RANK-2229)))
    (setf v-SHIFT_RANK-2231 v-MASK_RANK-2219)
    (setf v-I_RANK-2235 (c-u64 0))
    LOOP2232
    (unless (c-true (if (< v-I_RANK-2235 (c-u64 (* (c-u64 8) 4))) 1 0)) (go ENDLOOP2233))
    (unless (c-true (if (c-true v-BOUNDED_RANK-2228) (c-bool (if (= (c-u32 (logand v-LOWER_RANK-2230 v-SHIFT_RANK-2231)) (c-u32 (logand v-UPPER_RANK-2229 v-SHIFT_RANK-2231))) 1 0)) 0)) (go ELSE2236))
    (go CONTINUE2234)
    ELSE2236
    (progn (c-memset (+ v-COUNT_RANK-2220 (* 8 v-MLOWER_RANK-2226)) 0 (c-u64 (* (c-u32 (+ (c-u32 (- v-MUPPER_RANK-2227 v-MLOWER_RANK-2226)) (c-u32 1))) 8))))
    (setf v-END_RANK-2238 (+ v-C_RANK-2225 (* 8 v-N_RANK-2213)))
    (setf v-SORTED_RANK-2239 (c-bool 1))
    (setf v-LAST_RANK-2240 (c-u32 0))
    (setf v-P_RANK-2244 v-C_RANK-2225)
    LOOP2241
    (unless (c-true (if (/= v-P_RANK-2244 v-END_RANK-2238) 1 0)) (go ENDLOOP2242))
    (setf v-R_RANK-2245 (m-u32 (+ v-P_RANK-2244 4)))
    (unless (c-true (if (c-true v-BOUNDED_RANK-2228) 0 1)) (go ELSE2246))
    (progn (setf v-LOWER_RANK-2230 (c-u32 (c-u32 (logand v-LOWER_RANK-2230 v-R_RANK-2245)))))
    (progn (setf v-UPPER_RANK-2229 (c-u32 (c-u32 (logior v-UPPER_RANK-2229 v-R_RANK-2245)))))
    (go ENDIF2247)
    ELSE2246
    ENDIF2247
    (setf v-S_RANK-2250 (c-u32 (ash (c-u32 v-R_RANK-2245) (- v-I_RANK-2235))))
    (setf v-M_RANK-2251 (c-u32 (logand v-S_RANK-2250 v-MASK_RANK-2219)))
    (unless (c-true (if (c-true v-SORTED_RANK-2239) (c-bool (if (> v-LAST_RANK-2240 v-M_RANK-2251) 1 0)) 0)) (go ELSE2252))
    (progn (setf v-SORTED_RANK-2239 (c-bool 0)))
    (go ENDIF2253)
    ELSE2252
    (progn (setf v-LAST_RANK-2240 v-M_RANK-2251))
    ENDIF2253
    (progn (let* ((a2254 (+ v-COUNT_RANK-2220 (* 8 v-M_RANK-2251))) (old2255 (m-size a2254))) (setf (m-size a2254) (c-u64 (c-u64 (+ old2255 (c-u64 1))))) old2255))
    (let* ( (old2257 v-P_RANK-2244)) (setf v-P_RANK-2244 (+ old2257 (* 8 1))) old2257)
    (go LOOP2241)
    ENDLOOP2242
    (progn (setf v-MLOWER_RANK-2226 (c-u32 (logand (c-u32 (ash (c-u32 v-LOWER_RANK-2230) (- v-I_RANK-2235))) v-MASK_RANK-2219))))
    (progn (setf v-MUPPER_RANK-2227 (c-u32 (logand (c-u32 (ash (c-u32 v-UPPER_RANK-2229) (- v-I_RANK-2235))) v-MASK_RANK-2219))))
    (unless (c-true (if (c-true v-BOUNDED_RANK-2228) 0 1)) (go ELSE2258))
    (progn (setf v-BOUNDED_RANK-2228 (c-bool 1)))
    (unless (c-true (if (= (c-u32 (logand v-LOWER_RANK-2230 v-SHIFT_RANK-2231)) (c-u32 (logand v-UPPER_RANK-2229 v-SHIFT_RANK-2231))) 1 0)) (go ELSE2260))
    (go CONTINUE2234)
    ELSE2260
    (go ENDIF2259)
    ELSE2258
    ENDIF2259
    (unless (c-true v-SORTED_RANK-2239) (go ELSE2262))
    (go CONTINUE2234)
    ELSE2262
    (setf v-POS_RANK-2264 (c-u64 0))
    (setf v-J_RANK-2268 v-MLOWER_RANK-2226)
    LOOP2265
    (unless (c-true (if (<= v-J_RANK-2268 v-MUPPER_RANK-2227) 1 0)) (go ENDLOOP2266))
    (setf v-DELTA_RANK-2269 (m-size (+ v-COUNT_RANK-2220 (* 8 v-J_RANK-2268))))
    (progn (setf (m-size (+ v-COUNT_RANK-2220 (* 8 v-J_RANK-2268))) v-POS_RANK-2264))
    (progn (setf v-POS_RANK-2264 (c-u64 (c-u64 (+ v-POS_RANK-2264 v-DELTA_RANK-2269)))))
    (let* ( (old2272 v-J_RANK-2268)) (setf v-J_RANK-2268 (c-u64 (c-u64 (+ old2272 (c-u64 1))))) old2272)
    (go LOOP2265)
    ENDLOOP2266
    (unless (c-true (if (c-true v-TMP_RANK-2221) 0 1)) (go ELSE2273))
    (progn (setf v-TMP_RANK-2221 (c-malloc v-BYTES_TMP_RANK-2222)))
    (unless (c-true (if (c-true v-TMP_RANK-2221) 0 1)) (go ELSE2275))
    (progn (|c/out_of_memory| v-BYTES_TMP_RANK-2222))
    (go ENDIF2276)
    ELSE2275
    ENDIF2276
    (progn (setf v-B_RANK-2224 v-TMP_RANK-2221))
    (go ENDIF2274)
    ELSE2273
    ENDIF2274
    (setf v-D_RANK-2277 (if (c-true (if (= v-C_RANK-2225 v-A_RANK-2223) 1 0)) v-B_RANK-2224 v-A_RANK-2223))
    (setf v-P_RANK-2281 v-C_RANK-2225)
    LOOP2278
    (unless (c-true (if (/= v-P_RANK-2281 v-END_RANK-2238) 1 0)) (go ENDLOOP2279))
    (setf v-R_RANK-2282 (m-u32 (+ v-P_RANK-2281 4)))
    (setf v-S_RANK-2283 (c-u32 (ash (c-u32 v-R_RANK-2282) (- v-I_RANK-2235))))
    (setf v-M_RANK-2284 (c-u32 (logand v-S_RANK-2283 v-MASK_RANK-2219)))
    (setf v-POS_RANK-2285 (let* ((a2286 (+ v-COUNT_RANK-2220 (* 8 v-M_RANK-2284))) (old2287 (m-size a2286))) (setf (m-size a2286) (c-u64 (c-u64 (+ old2287 (c-u64 1))))) old2287))
    (progn (copy-bytes (+ v-D_RANK-2277 (* 8 v-POS_RANK-2285)) v-P_RANK-2281 8))
    (let* ( (old2289 v-P_RANK-2281)) (setf v-P_RANK-2281 (+ old2289 (* 8 1))) old2289)
    (go LOOP2278)
    ENDLOOP2279
    (progn (setf v-C_RANK-2225 v-D_RANK-2277))
    CONTINUE2234
    (progn (setf v-I_RANK-2235 (c-u64 (c-u64 (+ v-I_RANK-2235 v-LENGTH_RANK-2217)))) (setf v-SHIFT_RANK-2231 (c-u32 (c-u32 (ash (c-u32 v-SHIFT_RANK-2231) v-LENGTH_RANK-2217)))))
    (go LOOP2232)
    ENDLOOP2233
    (unless (c-true (if (= v-C_RANK-2225 v-B_RANK-2224) 1 0)) (go ELSE2292))
    (progn (c-memcpy v-A_RANK-2223 v-B_RANK-2224 (c-u64 (* v-N_RANK-2213 8))))
    (go ENDIF2293)
    ELSE2292
    ENDIF2293
    (unless (c-true v-TMP_RANK-2221) (go ELSE2294))
    (progn (c-free v-TMP_RANK-2221))
    (go ENDIF2295)
    ELSE2294
    ENDIF2295
    ENDLOOP2211
  )
  0) (setf *stack-top* frame))))

;;; upstream/satch.c:5763:1
(defun |c/find_conflict_level| (arg-v-solver-2299 arg-v-conflict-2300 arg-v-forced-2301)
 (declare  (type c-address arg-v-solver-2299) (type c-address arg-v-conflict-2300) (type c-address arg-v-forced-2301))
 (let ((v-solver-2299 0) (v-conflict-2300 0) (v-forced-2301 0) (v-res-2302 0) (v-count-2303 0) (v-lits-2304 0) (v-size-2305 0) (v-end-2306 0) (v-begin-2307 0) (v-p-2311 0) (v-idx-2315 0) (v-level-2316 0) (v-i-2333 0) (v-lit-2334 0) (v-highest_position-2335 0) (v-highest_literal-2336 0) (v-idx-2337 0) (v-highest_level-2338 0) (v-j-2342 0) (v-other-2343 0) (v-idx_other-2344 0) (v-tmp-2345 0))
 (declare (type c-address v-solver-2299) (type c-address v-conflict-2300) (type c-address v-forced-2301) (type (unsigned-byte 32) v-res-2302) (type (signed-byte 32) v-count-2303) (type c-address v-lits-2304) (type (signed-byte 32) v-size-2305) (type c-address v-end-2306) (type c-address v-begin-2307) (type c-address v-p-2311) (type (unsigned-byte 32) v-idx-2315) (type (unsigned-byte 32) v-level-2316) (type (unsigned-byte 32) v-i-2333) (type (unsigned-byte 32) v-lit-2334) (type (unsigned-byte 32) v-highest_position-2335) (type (unsigned-byte 32) v-highest_literal-2336) (type (unsigned-byte 32) v-idx-2337) (type (unsigned-byte 32) v-highest_level-2338) (type (signed-byte 32) v-j-2342) (type (signed-byte 32) v-other-2343) (type (unsigned-byte 32) v-idx_other-2344) (type (unsigned-byte 32) v-tmp-2345) (ignorable v-solver-2299 v-conflict-2300 v-forced-2301 v-res-2302 v-count-2303 v-lits-2304 v-size-2305 v-end-2306 v-begin-2307 v-p-2311 v-idx-2315 v-level-2316 v-i-2333 v-lit-2334 v-highest_position-2335 v-highest_literal-2336 v-idx-2337 v-highest_level-2338 v-j-2342 v-other-2343 v-idx_other-2344 v-tmp-2345))
 (tagbody
    (setf v-solver-2299 arg-v-solver-2299)
    (setf v-conflict-2300 arg-v-conflict-2300)
    (setf v-forced-2301 arg-v-forced-2301)
    (progn (m-u32 v-forced-2301))
    (setf v-res-2302 (c-u32 0))
    (setf v-count-2303 0)
    (setf v-lits-2304 (+ v-conflict-2300 16))
    (setf v-size-2305 (c-s32 (m-u32 (+ v-conflict-2300 12))))
    (setf v-end-2306 (+ v-lits-2304 (* 4 v-size-2305)))
    (setf v-begin-2307 v-lits-2304)
    (setf v-p-2311 v-begin-2307)
    LOOP2308
    (unless (c-true (if (/= v-p-2311 v-end-2306) 1 0)) (go ENDLOOP2309))
    (progn v-solver-2299)
    (setf v-idx-2315 (|c/INDEX| (m-u32 v-p-2311)))
    (setf v-level-2316 (m-u32 (+ (m-ptr (+ v-solver-2299 32)) (* 4 v-idx-2315))))
    (unless (c-true (if (> v-level-2316 v-res-2302) 1 0)) (go ELSE2317))
    (progn (setf v-res-2302 v-level-2316))
    (progn (setf (m-u32 v-forced-2301) (m-u32 v-p-2311)))
    (progn (setf v-count-2303 1))
    (go ENDIF2318)
    ELSE2317
    (unless (c-true (if (= v-level-2316 v-res-2302) 1 0)) (go ELSE2319))
    (progn (let* ( (old2322 v-count-2303)) (setf v-count-2303 (c-s32 (c-s32 (+ old2322 1)))) old2322))
    (go ENDIF2320)
    ELSE2319
    ENDIF2320
    ENDIF2318
    (let* ( (old2324 v-p-2311)) (setf v-p-2311 (+ old2324 (* 4 1))) v-p-2311)
    (go LOOP2308)
    ENDLOOP2309
    (progn v-solver-2299)
    (unless (c-true (if (c-true (|c/is_temporary_binary| v-solver-2299 v-conflict-2300)) 0 1)) (go ELSE2328))
    (setf v-i-2333 (c-u32 0))
    LOOP2330
    (unless (c-true (if (< v-i-2333 (c-u32 2)) 1 0)) (go ENDLOOP2331))
    (setf v-lit-2334 (m-u32 (+ v-lits-2304 (* 4 v-i-2333))))
    (setf v-highest_position-2335 v-i-2333)
    (setf v-highest_literal-2336 v-lit-2334)
    (setf v-idx-2337 (|c/INDEX| v-lit-2334))
    (setf v-highest_level-2338 (m-u32 (+ (m-ptr (+ v-solver-2299 32)) (* 4 v-idx-2337))))
    (setf v-j-2342 (c-s32 (c-u32 (+ v-i-2333 (c-u32 1)))))
    LOOP2339
    (unless (c-true (if (< v-j-2342 v-size-2305) 1 0)) (go ENDLOOP2340))
    (setf v-other-2343 (c-s32 (m-u32 (+ v-lits-2304 (* 4 v-j-2342)))))
    (setf v-idx_other-2344 (|c/INDEX| (c-u32 v-other-2343)))
    (setf v-tmp-2345 (m-u32 (+ (m-ptr (+ v-solver-2299 32)) (* 4 v-idx_other-2344))))
    (unless (c-true (if (>= v-highest_level-2338 v-tmp-2345) 1 0)) (go ELSE2346))
    (go CONTINUE2341)
    ELSE2346
    (progn (setf v-highest_literal-2336 (c-u32 v-other-2343)))
    (progn (setf v-highest_position-2335 (c-u32 v-j-2342)))
    (progn (setf v-highest_level-2338 v-tmp-2345))
    (unless (c-true (if (= v-highest_level-2338 v-res-2302) 1 0)) (go ELSE2348))
    (go ENDLOOP2340)
    ELSE2348
    CONTINUE2341
    (let* ( (old2351 v-j-2342)) (setf v-j-2342 (c-s32 (c-s32 (+ old2351 1)))) old2351)
    (go LOOP2339)
    ENDLOOP2340
    (unless (c-true (if (= v-highest_position-2335 v-i-2333) 1 0)) (go ELSE2352))
    (go CONTINUE2332)
    ELSE2352
    (unless (c-true (if (> v-highest_position-2335 (c-u32 1)) 1 0)) (go ELSE2354))
    (progn v-solver-2299)
    (progn (|c/unwatch_literal| v-solver-2299 v-lit-2334 v-conflict-2300))
    (go ENDIF2355)
    ELSE2354
    ENDIF2355
    (progn (setf (m-u32 (+ v-lits-2304 (* 4 v-highest_position-2335))) v-lit-2334))
    (progn (setf (m-u32 (+ v-lits-2304 (* 4 v-i-2333))) v-highest_literal-2336))
    (unless (c-true (if (> v-highest_position-2335 (c-u32 1)) 1 0)) (go ELSE2359))
    (progn (|c/watch_literal| v-solver-2299 (c-bool (ldb (byte 1 2) (m-u8 (+ v-conflict-2300 0)))) v-highest_literal-2336 (m-u32 (+ v-lits-2304 (* 4 (if (c-true v-i-2333) 0 1)))) v-conflict-2300))
    (go ENDIF2360)
    ELSE2359
    ENDIF2360
    CONTINUE2332
    (let* ( (old2362 v-i-2333)) (setf v-i-2333 (c-u32 (c-u32 (+ old2362 (c-u32 1))))) old2362)
    (go LOOP2330)
    ENDLOOP2331
    (go ENDIF2329)
    ELSE2328
    ENDIF2329
    (unless (c-true (if (/= v-count-2303 1) 1 0)) (go ELSE2363))
    (progn (setf (m-u32 v-forced-2301) 4294967295))
    (progn v-solver-2299)
    (go ENDIF2364)
    ELSE2363
    ENDIF2364
    (return-from |c/find_conflict_level| (c-s32 v-res-2302))
  )
  0))

