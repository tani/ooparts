(uiop:define-package #:ooparts/prolog/kernel/gc
  (:use #:cl)
  (:import-from #:ooparts/prolog/kernel/model
    #:choice-args #:choice-continuation #:choice-handlers #:choice-heap #:choice-slots
    #:choice-trail #:continuation-handlers #:continuation-parent #:continuation-slots
    #:iso-handler-catcher #:iso-handler-parent #:iso-handler-recovery #:iso-handler-snapshot
    #:logic-var-binding #:logic-var-p #:machine-args #:machine-choices #:machine-closed
    #:machine-continuation #:machine-gc-count #:machine-gc-floor #:machine-gc-limit
    #:machine-gc-reclaimed #:machine-heap #:machine-iso-handlers #:machine-max-live
    #:machine-scan #:machine-slg-root #:machine-slots #:machine-trail #:machine-variables)
  (:import-from #:ooparts/prolog/kernel/protocol)
  (:import-from #:ooparts/prolog/api/state)
  (:import-from #:ooparts/prolog/kernel/instructions)
  (:import-from #:ooparts/prolog/kernel/engine)
  (:import-from #:ooparts/prolog/kernel/protocol #:register-provider)
  (:export #:collect-query-garbage #:maybe-collect))
(in-package #:ooparts/prolog/kernel/gc)

(defvar *collection-diagnostics* nil)

(defun collect-query-garbage (vm)
  "Nonmoving mark/compact of VM ownership vectors, at instruction boundaries.
Object identity and allocation age survive compaction. Lisp GC reclaims bytes."
  (when (machine-closed vm) (return-from collect-query-garbage 0))
  ;; Avoid throwing away and regrowing marker arrays during collection itself.
  ;; Foreign graph objects can still grow the ordinary EQ table as needed.
  (let ((marked (make-hash-table :test 'eq :size (max 16 (length (machine-heap vm)))))
        (frames (make-hash-table :test 'eq))
        (work (make-array 16 :adjustable t :fill-pointer 0 :initial-element nil))
        (heap (machine-heap vm)) (trail (machine-trail vm))
        (choices (machine-choices vm)) (handler-frames nil))
    (macrolet ((push-work (value)
                 `(vector-push-extend ,value work)))
      (labels ((root-handler (handler)
                 (loop while (and handler (not (gethash handler frames))) do
                   (setf (gethash handler frames) t)
                   (push (iso-handler-snapshot handler) handler-frames)
                   (push-work (iso-handler-catcher handler)) (push-work (iso-handler-recovery handler))
                   (let ((cp (iso-handler-snapshot handler)))
                     (root-vector (choice-args cp)) (root-vector (choice-slots cp))
                     (root-continuation (choice-continuation cp)))
                   (setf handler (iso-handler-parent handler))))
             (root-vector (vector)
               (when vector (loop for x across vector do (push-work x))))
             (root-continuation (c)
               (loop while (and c (not (gethash c frames))) do
                 (setf (gethash c frames) t)
                 (root-handler (continuation-handlers c))
                 (when (continuation-slots c)
                   (loop for x across (continuation-slots c) do (push-work x)))
                 (setf c (continuation-parent c)))))
        (root-handler (machine-iso-handlers vm))
        (push-work (machine-slg-root vm))
        (root-vector (machine-args vm)) (root-vector (machine-slots vm))
        (root-continuation (machine-continuation vm))
        (dolist (entry (machine-variables vm)) (push-work (cdr entry)))
        ;; Scan locations are roots even in the middle of a compound instruction sequence.
        (dolist (location (machine-scan vm)) (push-work (car location)))
        (loop for cp across choices do
          (root-handler (choice-handlers cp))
          (root-vector (choice-args cp)) (root-vector (choice-slots cp)) (root-continuation (choice-continuation cp))))
    ;; Do not dereference away variable cells: rollback and named query roots need them.
    (loop while (plusp (fill-pointer work)) do
      (let* ((index (1- (fill-pointer work))) (x (aref work index)))
        (setf (aref work index) nil (fill-pointer work) index)
        (when (and (or (logic-var-p x) (consp x)) (not (gethash x marked)))
          (setf (gethash x marked) t)
          (if (logic-var-p x) (push-work (logic-var-binding x))
              (progn (push-work (car x)) (push-work (cdr x))))))))
    (setf work nil)
    (when *collection-diagnostics*
      (funcall *collection-diagnostics* vm marked heap trail handler-frames))
    (let* ((old-heap-length (length heap)) (old-trail-length (length trail))
           (all-frames (append (coerce choices 'list) handler-frames))
           ;; A handler snapshot can also be an ordinary choice. Remap its old
           ;; offsets once, rather than treating the adjusted value as old data.
           (heap-frames
             (sort (if handler-frames
                       (let ((identities (make-hash-table :test 'eq)))
                         (loop for cp in all-frames
                               unless (gethash cp identities)
                                 do (setf (gethash cp identities) t)
                               and collect cp))
                       all-frames)
                   #'< :key #'choice-heap))
           (heap-remaining heap-frames) (live-heap-count 0) (live-trail-count 0)
           (first-trail (if (plusp (length choices)) (choice-trail (aref choices 0)) old-trail-length)))
      ;; Compact in place. Frame offsets are monotone, so sorted frames provide
      ;; the old-prefix counts without one heap-sized fixnum vector per owner.
      (loop initially
              (loop while (and heap-remaining (zerop (choice-heap (car heap-remaining)))) do
                (setf (choice-heap (pop heap-remaining)) 0))
            for cell across heap for i from 0 with live = 0 do
              (when (gethash cell marked)
                (setf (aref heap live) cell)
                (incf live))
              (loop while (and heap-remaining
                               (= (choice-heap (car heap-remaining)) (1+ i))) do
                (setf (choice-heap (pop heap-remaining)) live))
            finally
              (dolist (cp heap-remaining) (setf (choice-heap cp) live))
              (setf live-heap-count live)
              (loop for j from live below old-heap-length do (setf (aref heap j) nil)))
      ;; Unreachable trailed variables cannot be observed by any remaining alternative.
      ;; Entries before the oldest choice's trail mark can never be undone.
      (let ((trail-remaining (sort heap-frames #'< :key #'choice-trail)))
        (loop initially
                (loop while (and trail-remaining (zerop (choice-trail (car trail-remaining)))) do
                  (setf (choice-trail (pop trail-remaining)) 0))
              for cell across trail for i from 0 with live = 0 do
                (when (and (>= i first-trail) (gethash cell marked))
                  (setf (aref trail live) cell)
                  (incf live))
                (loop while (and trail-remaining
                                 (= (choice-trail (car trail-remaining)) (1+ i))) do
                  (setf (choice-trail (pop trail-remaining)) live))
              finally
                (dolist (cp trail-remaining) (setf (choice-trail cp) live))
                (setf live-trail-count live)
                (loop for j from live below old-trail-length do (setf (aref trail j) nil))))
      (let ((reclaimed (- old-heap-length live-heap-count))
            (heap-target (max 64 (* 2 live-heap-count)))
            (trail-target (max 64 (* 2 live-trail-count))))
        ;; Do not grow while mark metadata and old backing stores are live.
        ;; Existing capacity is already no greater than the usual target after
        ;; this branch, and VECTOR-PUSH-EXTEND can grow after collection returns.
        (setf marked nil (fill-pointer heap) live-heap-count
              (fill-pointer trail) live-trail-count)
        (when (> (array-total-size heap) heap-target)
          (setf heap (adjust-array heap heap-target :fill-pointer live-heap-count)))
        (when (> (array-total-size trail) trail-target)
          (setf trail (adjust-array trail trail-target :fill-pointer live-trail-count)))
        (setf (machine-heap vm) heap (machine-trail vm) trail
              (machine-max-live vm) (max (machine-max-live vm) live-heap-count))
        (when (machine-gc-floor vm)
          (setf (machine-gc-limit vm)
                (max (machine-gc-floor vm) (* 2 live-heap-count))))
        (incf (machine-gc-count vm)) (incf (machine-gc-reclaimed vm) reclaimed)
        reclaimed))))
(defun maybe-collect (vm)
  (when (and (machine-gc-limit vm) (>= (length (machine-heap vm)) (machine-gc-limit vm)))
    (collect-query-garbage vm)))

(eval-when (:load-toplevel :execute)
  (register-provider 'ooparts/prolog/kernel/protocol:maybe-collect 'maybe-collect)
)
