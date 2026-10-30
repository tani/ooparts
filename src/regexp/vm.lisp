;;; Vector-backed bytecode virtual machine for the regexp library.
;;;
;;; A compiled graph is packed into a flat instruction vector.  Every state
;;; owns one dispatch slot; states with several outgoing edges hold a
;;; `(:split ...)` there and their edge alternatives occupy a second region
;;; after all dispatch slots.  A run dispatches iteratively with an explicit
;;; backtracking stack and never stores mutable state in the program.
(uiop:define-package #:ooparts/regexp/vm
  (:use #:cl)
  (:import-from #:ooparts/regexp/model
    #:compiled-graph-entry
    #:compiled-graph-state-count
    #:compiled-graph-edges
    #:compiled-graph-metadata
    #:regexp-edge-source
    #:regexp-edge-destination
    #:regexp-edge-label)
  (:import-from #:ooparts/regexp/selection
    #:make-arena
    #:apply-edge-label)
  (:export #:make-vm-program #:run-vm))
(in-package #:ooparts/regexp/vm)

(defstruct (vm-program (:constructor %make-vm-program
                                       (&key instructions blocks entry
                                             state-count metadata))
                       (:conc-name vm-program-))
  ;; Flat instruction vector: dispatch slots first, alternative blocks after.
  (instructions #() :type simple-vector :read-only t)
  ;; State -> instruction address.  State 0 is the sole accepting slot.
  (blocks #() :type simple-vector :read-only t)
  (entry 0 :type (integer 0 *) :read-only t)
  (state-count 0 :type (integer 0 *) :read-only t)
  (metadata nil :type t :read-only t))

(defun %group-edges (edges state-count)
  "Return a vector mapping each state to its outgoing edges, in edge order."
  (let ((groups (make-array state-count :initial-element '())))
    (loop for edge across edges
          for source = (regexp-edge-source edge)
          do (push edge (aref groups source)))
    (dotimes (state state-count)
      (setf (aref groups state) (nreverse (aref groups state))))
    groups))

(defun make-vm-program (graph)
  "Assemble a compact VM PROGRAM from the compiled GRAPH."
  (let* ((state-count (compiled-graph-state-count graph))
         (groups (%group-edges (compiled-graph-edges graph) state-count))
         (extra (loop for state from 1 below state-count
                      sum (let ((count (length (aref groups state))))
                            (if (> count 1) count 0))))
         (instructions (make-array (+ state-count extra)))
         (blocks (make-array state-count))
         (next-extra state-count))
    ;; State 0 is accepting.  Every other state occupies one dispatch slot.
    (setf (aref instructions 0) (list :accept)
          (aref blocks 0) 0)
    (loop for state from 1 below state-count
          for edges = (aref groups state)
          for count = (length edges)
          do (setf (aref blocks state) state)
             (cond
               ((zerop count)
                ;; Unreachable in a well-formed graph; an empty split fails.
                (setf (aref instructions state) (list :split)))
               ((= count 1)
                (let ((edge (first edges)))
                  (setf (aref instructions state)
                        (list :edge
                              (regexp-edge-label edge)
                              (regexp-edge-destination edge)))))
               (t
                ;; Allocate one edge alternative per outgoing edge after the
                ;; dispatch region, and dispatch to the first one.
                (let ((addresses '()))
                  (dolist (edge edges)
                    (let ((address next-extra))
                      (incf next-extra)
                      (push address addresses)
                      (setf (aref instructions address)
                            (list :edge
                                  (regexp-edge-label edge)
                                  (regexp-edge-destination edge)))))
                  (setf addresses (nreverse addresses))
                  (setf (aref instructions state)
                        (cons :split addresses))))))
    (%make-vm-program :instructions instructions
                      :blocks blocks
                      :entry (compiled-graph-entry graph)
                      :state-count state-count
                      :metadata (compiled-graph-metadata graph))))

;;; A backtracking choice is (pc position history frame).

(defun %push-alternatives (stack instruction position history frame)
  "Push alternatives 2..k of a split INSTRUCTION in reverse exploration order.
Returns (values first-address new-stack); the first alternative is continued
immediately by the caller."
  (let ((addresses (cdr instruction)))
    (dolist (address (reverse (rest addresses)))
      (setf stack (cons (list address position history frame) stack)))
    (values (first addresses) stack)))

(defun run-vm (program string start require-end not-bol not-eol)
  "Run PROGRAM from START over STRING.

Returns (values HISTORIES ARENA), where HISTORIES is a simple vector of
distinct accepted history handles and ARENA owns them.  With REQUIRE-END only
accepts at the end of STRING are recorded; otherwise every accept position is."
  (let* ((arena (make-arena))
         (metadata (vm-program-metadata program))
         (instructions (vm-program-instructions program))
         (blocks (vm-program-blocks program))
         (length (length string))
         (accepted (make-array 16 :adjustable t :fill-pointer 0))
         (seen (make-hash-table :test #'eql))
         (stack '())
         (position start)
         (history 0)
         (frame 0)
         (pc (aref blocks (vm-program-entry program))))
    (loop
      (let ((instruction (if pc (aref instructions pc) nil)))
        (when instruction
          (case (car instruction)
            (:accept
             (when (or (not require-end) (= position length))
               (unless (gethash history seen)
                 (setf (gethash history seen) t)
                 (vector-push-extend history accepted)))
             (setf pc nil))
            (:split
             (multiple-value-setq (pc stack)
               (%push-alternatives stack instruction position history
                                   frame)))
            (:edge
             (multiple-value-bind (success new-position new-history new-frame)
                 (apply-edge-label arena frame history (second instruction)
                                   position string metadata not-bol not-eol)
               (if success
                   (setf position new-position
                         history new-history
                         frame new-frame
                         pc (aref blocks (third instruction)))
                   (setf pc nil))))
            (otherwise
             (setf pc nil))))
        (when (null pc)
          (if stack
              (let ((choice (pop stack)))
                (setf pc (first choice)
                      position (second choice)
                      history (third choice)
                      frame (fourth choice)))
              (return)))))
    (values (coerce accepted 'simple-vector) arena)))
