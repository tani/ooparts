;;; Tagged epsilon-closure automaton backend for the regexp library.
;;;
;;; The compiled graph is frozen once into per-state adjacency: consuming
;;; edges are separated from every other label (epsilon, tags, assertions,
;;; absent placeholders and repetition frames).  A run keeps a set of full
;;; configurations (state history frame) instead of collapsing to one thread
;;; per control state, so every distinct parse history survives to the
;;; selector.
(uiop:define-package #:ooparts/regexp/automaton
  (:use #:cl)
  (:import-from #:ooparts/regexp/model
    #:compiled-graph-entry #:compiled-graph-state-count
    #:compiled-graph-edges #:compiled-graph-metadata
    #:regexp-edge-source #:regexp-edge-label #:regexp-edge-destination)
  (:import-from #:ooparts/regexp/selection
    #:make-arena #:apply-edge-label)
  (:export #:make-automaton #:run-automaton))
(in-package #:ooparts/regexp/automaton)

;;; ---------------------------------------------------------------------------
;;; Immutable program.

(defstruct (automaton (:constructor %make-automaton)
                      (:conc-name automaton-))
  (entry 0 :type (integer 0 *) :read-only t)
  (state-count 0 :type (integer 0 *) :read-only t)
  (metadata nil :read-only t)
  (consume-edges #() :type simple-vector :read-only t)
  (non-consume-edges #() :type simple-vector :read-only t))

(defun %freeze-adjacency (table state-count)
  "Turn a state-indexed list TABLE into simple vectors of edges."
  (let ((result (make-array state-count)))
    (dotimes (state state-count result)
      (setf (aref result state)
            (coerce (nreverse (aref table state)) 'simple-vector)))))

(defun make-automaton (graph)
  "Freeze GRAPH into an immutable tagged automaton.

CONSUME-EDGES holds (PREDICATE-ID . DESTINATION) pairs and
NON-CONSUME-EDGES holds (LABEL . DESTINATION) pairs, both indexed by source
state.  GRAPH itself is never retained except for its metadata."
  (let* ((state-count (compiled-graph-state-count graph))
         (consume (make-array state-count :initial-element nil))
         (other (make-array state-count :initial-element nil)))
    (loop for edge across (compiled-graph-edges graph)
          for source = (regexp-edge-source edge)
          for label = (regexp-edge-label edge)
          for destination = (regexp-edge-destination edge)
          do (if (and (consp label) (eq (car label) :consume))
                 (push (cons (second label) destination) (aref consume source))
                 (push (cons label destination) (aref other source))))
    (%make-automaton :entry (compiled-graph-entry graph)
                     :state-count state-count
                     :metadata (compiled-graph-metadata graph)
                     :consume-edges (%freeze-adjacency consume state-count)
                     :non-consume-edges (%freeze-adjacency other state-count))))

;;; ---------------------------------------------------------------------------
;;; Tagged epsilon closure.
;;;
;;; The work queue holds configurations still to expand; the VISITED table
;;; deduplicates exactly equal (STATE HISTORY FRAME) triples, never state
;;; alone, so epsilon cycles terminate without merging distinct histories.

(defun %close-at-position (automaton arena string position require-end
                           not-bol not-eol recorded seeds)
  "Expand non-consume edges from SEEDS at POSITION.

Return a simple vector of the distinct closed configurations at POSITION and
record every accepting history in the RECORDED table."
  (let* ((metadata (automaton-metadata automaton))
         (edges (automaton-non-consume-edges automaton))
         (length (length string))
         (visited (make-hash-table :test #'equal))
         (queue (make-array 16 :adjustable t :fill-pointer 0))
         (configs '()))
    (labels ((enqueue (config)
               (unless (gethash config visited)
                 (setf (gethash config visited) t)
                 (vector-push-extend config queue))))
      (dolist (seed seeds)
        (enqueue seed))
      (do ((index 0 (1+ index)))
          ((>= index (fill-pointer queue)))
        (let ((config (aref queue index)))
          (destructuring-bind (state history frame) config
            (when (and (zerop state)
                       (or (not require-end) (= position length)))
              (setf (gethash history recorded) t))
            (push config configs)
            (loop for (label . destination) across (aref edges state)
                  do (multiple-value-bind (success new-position
                                           new-history new-frame)
                         (apply-edge-label arena frame history label
                                           position string metadata
                                           not-bol not-eol)
                       (declare (ignore new-position))
                       (when success
                         (enqueue (list destination new-history
                                        new-frame))))))))
      (coerce (nreverse configs) 'simple-vector))))

(defun %step-consume (automaton arena string position not-bol not-eol configs)
  "Advance every configuration in CONFIGS over matching consume edges.

Return the distinct configurations at POSITION+1."
  (let ((metadata (automaton-metadata automaton))
        (edges (automaton-consume-edges automaton))
        (visited (make-hash-table :test #'equal))
        (next '()))
    (loop for config across configs
          do (destructuring-bind (state history frame) config
               (loop for (predicate . destination) across (aref edges state)
                     do (multiple-value-bind (success new-position
                                              new-history new-frame)
                            (apply-edge-label arena frame history
                                              (list :consume predicate)
                                              position string metadata
                                              not-bol not-eol)
                          (declare (ignore new-position))
                          (when success
                            (let ((config (list destination new-history
                                                new-frame)))
                              (unless (gethash config visited)
                                (setf (gethash config visited) t)
                                (push config next))))))))
    (nreverse next)))

(defun run-automaton (automaton string start require-end not-bol not-eol)
  "Run AUTOMATON on STRING from START.

Return (values HISTORIES ARENA); HISTORIES is a simple vector of distinct
history handles accepted within the REQUIRE-END rule.  The arena is fresh and
owns every history recorded by this call."
  (let* ((arena (make-arena))
         (length (length string))
         (recorded (make-hash-table :test #'eql))
         (seeds (list (list (automaton-entry automaton) 0 0)))
         (position start))
    (loop
      (let ((closed (%close-at-position automaton arena string position
                                        require-end not-bol not-eol
                                        recorded seeds)))
        (when (or (>= position length) (zerop (length closed)))
          (return))
        (let ((next (%step-consume automaton arena string position
                                   not-bol not-eol closed)))
          (when (null next)
            (return))
          (setf seeds next)
          (incf position))))
    (values (let ((histories (make-array (hash-table-count recorded))))
              (loop for history being the hash-keys of recorded
                    for index from 0
                    do (setf (aref histories index) history))
              histories)
            arena)))
