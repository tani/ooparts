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


(defun collect-query-garbage (vm)
  "Nonmoving mark/compact of VM ownership vectors, at instruction boundaries.
Object identity and allocation age survive compaction. Lisp GC reclaims bytes."
  (when (machine-closed vm) (return-from collect-query-garbage 0))
  (let ((marked (make-hash-table :test 'eq)) (frames (make-hash-table :test 'eq))
        (work nil) (heap (machine-heap vm)) (trail (machine-trail vm))
        (choices (machine-choices vm)) (handler-frames nil))
    (labels ((root-handler (handler)
               (loop while (and handler (not (gethash handler frames))) do
                 (setf (gethash handler frames) t)
                 (push (iso-handler-snapshot handler) handler-frames)
                 (push (iso-handler-catcher handler) work) (push (iso-handler-recovery handler) work)
                 (let ((cp (iso-handler-snapshot handler)))
                   (root-vector (choice-args cp)) (root-vector (choice-slots cp))
                   (root-continuation (choice-continuation cp)))
                 (setf handler (iso-handler-parent handler))))
           (root-vector (vector) (when vector (loop for x across vector do (push x work))))
           (root-continuation (c)
             (loop while (and c (not (gethash c frames))) do
               (setf (gethash c frames) t)
               (root-handler (continuation-handlers c))
               (when (continuation-slots c)
                 (loop for x across (continuation-slots c) do (push x work)))
               (setf c (continuation-parent c)))))
      (root-handler (machine-iso-handlers vm))
      (push (machine-slg-root vm) work)
      (root-vector (machine-args vm)) (root-vector (machine-slots vm))
      (root-continuation (machine-continuation vm))
      (dolist (entry (machine-variables vm)) (push (cdr entry) work))
      ;; Scan locations are roots even in the middle of a compound instruction sequence.
      (dolist (location (machine-scan vm)) (push (car location) work))
      (loop for cp across choices do
        (root-handler (choice-handlers cp))
        (root-vector (choice-args cp)) (root-vector (choice-slots cp)) (root-continuation (choice-continuation cp))))
    ;; Do not dereference away variable cells: rollback and named query roots need them.
    (loop while work do
      (let* ((x (pop work)))
        (when (and (or (logic-var-p x) (consp x)) (not (gethash x marked)))
          (setf (gethash x marked) t)
          (if (logic-var-p x) (push (logic-var-binding x) work)
              (progn (push (car x) work) (push (cdr x) work))))))
    (let* ((heap-prefix (make-array (1+ (length heap)) :initial-element 0))
           (trail-prefix (make-array (1+ (length trail)) :initial-element 0))
           (live-heap (make-array (max 64 (length heap)) :adjustable t :fill-pointer 0))
           (live-trail (make-array (max 64 (length trail)) :adjustable t :fill-pointer 0))
           (first-trail (if (plusp (length choices)) (choice-trail (aref choices 0)) (length trail))))
      (loop for cell across heap for i from 0 do
        (when (gethash cell marked) (vector-push cell live-heap))
        (setf (aref heap-prefix (1+ i)) (length live-heap)))
      ;; Unreachable trailed variables cannot be observed by any remaining alternative.
      ;; Entries before the oldest choice's trail mark can never be undone.
      (loop for cell across trail for i from 0 do
        (when (and (>= i first-trail) (gethash cell marked)) (vector-push cell live-trail))
        (setf (aref trail-prefix (1+ i)) (length live-trail)))
      (loop for cp in (append (coerce choices 'list) handler-frames) do
        (setf (choice-heap cp) (aref heap-prefix (choice-heap cp))
              (choice-trail cp) (aref trail-prefix (choice-trail cp))))
      (let ((reclaimed (- (length heap) (length live-heap))))
        ;; Shrink capacity too; leaving NILs in a large backing vector wastes memory.
        (setf (machine-heap vm)
              (adjust-array live-heap (max 64 (* 2 (length live-heap))) :fill-pointer (length live-heap))
              (machine-trail vm)
              (adjust-array live-trail (max 64 (* 2 (length live-trail))) :fill-pointer (length live-trail))
              (machine-max-live vm) (max (machine-max-live vm) (length live-heap)))
        (when (machine-gc-floor vm)
          (setf (machine-gc-limit vm) (max (machine-gc-floor vm) (* 2 (length live-heap)))))
        (incf (machine-gc-count vm)) (incf (machine-gc-reclaimed vm) reclaimed)
        reclaimed))))
(defun maybe-collect (vm)
  (when (and (machine-gc-limit vm) (>= (length (machine-heap vm)) (machine-gc-limit vm)))
    (collect-query-garbage vm)))

(eval-when (:load-toplevel :execute)
  (register-provider 'ooparts/prolog/kernel/protocol:maybe-collect 'maybe-collect)
)
