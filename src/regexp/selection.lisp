;;; Interning arenas for engine histories and POSIX selection over parse trees.
(uiop:define-package #:ooparts/regexp/selection
  (:use #:cl)
  (:import-from #:ooparts/regexp/model
    #:regexp-metadata-nodes #:regexp-metadata-group-count #:regexp-metadata-node
    #:regexp-metadata-predicates
    #:regexp-metadata-newline
    #:regexp-node-id #:regexp-node-kind #:regexp-node-parent
    #:regexp-node-children #:regexp-node-capture #:regexp-node-minimum
    #:regexp-node-maximum #:regexp-node-mode
    #:predicate-matches-p #:assertion-satisfied-p)
  (:export
   #:make-arena
   #:arena-history #:arena-history-parent #:arena-history-kind
   #:arena-history-node-id #:arena-history-position #:arena-history-occurrence
   #:arena-path #:arena-path-parent #:arena-path-node #:arena-path-ordinal
   #:arena-frame-root #:arena-frame-open
   #:arena-frame-iteration-open #:arena-frame-iteration-close
   #:arena-frame-parent #:arena-frame-node #:arena-frame-iterations
   #:arena-frame-nonempty #:arena-frame-empty #:arena-frame-iteration-start
   #:arena-frame-effective-path #:arena-frame-iteration-path
   #:arena-frame-outer-path #:arena-frame-absent-children
   #:arena-frame-mark-absent #:repetition-frame-closable-p
   #:apply-edge-label
   #:select-history #:history-captures))
(in-package #:ooparts/regexp/selection)

;;; ---------------------------------------------------------------------------
;;; Append-only interning arena.
;;;
;;; Histories, dynamic paths and repetition-frame snapshots are immutable
;;; entries in adjustable vectors.  Handle 0 is the empty history chain, the
;;; root path and the root frame.  Equal keys share one handle.

(defstruct (%history (:constructor %make-history
                                  (&key parent kind node-id position
                                        occurrence)))
  (parent nil :type (or null (integer 0 *)))
  (kind nil :type t)
  (node-id nil :type (or null (integer 0 *)))
  (position nil :type (or null (integer 0 *)))
  (occurrence nil :type (or null (integer 0 *))))

(defstruct (%path (:constructor %make-path
                                (&key parent-path repeat-node-id ordinal)))
  (parent-path nil :type (or null (integer 0 *)))
  (repeat-node-id nil :type (or null (integer 0 *)))
  (ordinal nil :type (or null (integer 1 *))))

(defstruct (%frame (:constructor %make-frame
                                 (&key parent node cap iterations nonempty empty
                                       iteration-start outer-path
                                       iteration-path absent-children)))
  (parent nil :type (or null (integer 0 *)))
  (node nil :type (or null (integer 0 *)))
  (cap 0 :type (integer 0 *))
  (iterations 0 :type (integer 0 *))
  (nonempty 0 :type (integer 0 *))
  (empty 0 :type (integer 0 *))
  (iteration-start nil :type (or null (integer 0 *)))
  (outer-path 0 :type (integer 0 *))
  (iteration-path nil :type (or null (integer 0 *)))
  (absent-children nil :type t))

(defstruct (%arena (:constructor %make-arena
                                (&key histories history-table
                                      paths path-table
                                      frames frame-table)))
  (histories #() :type vector)
  (history-table #() :type hash-table)
  (paths #() :type vector)
  (path-table #() :type hash-table)
  (frames #() :type vector)
  (frame-table #() :type hash-table))

(defun %new-store (&optional root)
  "Return (values vector table), pre-populated with ROOT at handle 0."
  (let ((vector (make-array 16 :adjustable t :fill-pointer 0))
        (table (make-hash-table :test #'equal)))
    (when root
      (vector-push-extend root vector))
    (values vector table)))

(defun %intern (vector table key entry)
  (or (gethash key table)
      (let ((handle (fill-pointer vector)))
        (vector-push-extend entry vector)
        (setf (gethash key table) handle)
        handle)))

(defun make-arena ()
  "Return a fresh arena with root history, root path and root frame at 0."
  (multiple-value-bind (histories history-table)
      (%new-store (%make-history))
    (multiple-value-bind (paths path-table)
        (%new-store (%make-path))
      (multiple-value-bind (frames frame-table)
          (%new-store (%make-frame :outer-path 0))
        (%make-arena :histories histories :history-table history-table
                     :paths paths :path-table path-table
                     :frames frames :frame-table frame-table)))))

;;; History entries.

(defun arena-history (arena parent kind node-id position occurrence)
  "Intern one history event in ARENA and return its handle."
  (let ((key (list parent kind node-id position occurrence)))
    (%intern (%arena-histories arena)
             (%arena-history-table arena)
             key
             (%make-history :parent parent :kind kind :node-id node-id
                            :position position :occurrence occurrence))))

(defun %history-entry (arena handle)
  (aref (%arena-histories arena) handle))

(defun arena-history-parent (arena handle)
  (%history-parent (%history-entry arena handle)))

(defun arena-history-kind (arena handle)
  (%history-kind (%history-entry arena handle)))

(defun arena-history-node-id (arena handle)
  (%history-node-id (%history-entry arena handle)))

(defun arena-history-position (arena handle)
  (%history-position (%history-entry arena handle)))

(defun arena-history-occurrence (arena handle)
  (%history-occurrence (%history-entry arena handle)))

;;; Dynamic paths: (parent-path repeat-node-id ordinal).

(defun arena-path (arena parent-path repeat-node-id ordinal)
  "Intern a dynamic repetition path in ARENA and return its handle."
  (let ((key (list parent-path repeat-node-id ordinal)))
    (%intern (%arena-paths arena)
             (%arena-path-table arena)
             key
             (%make-path :parent-path parent-path
                         :repeat-node-id repeat-node-id
                         :ordinal ordinal))))

(defun %path-entry (arena handle)
  (aref (%arena-paths arena) handle))

(defun arena-path-parent (arena handle)
  (%path-parent-path (%path-entry arena handle)))

(defun arena-path-node (arena handle)
  (%path-repeat-node-id (%path-entry arena handle)))

(defun arena-path-ordinal (arena handle)
  (%path-ordinal (%path-entry arena handle)))

;;; Repetition frame snapshots.

(defun %intern-frame (arena parent node cap iterations nonempty empty
                            iteration-start outer-path iteration-path
                            absent-children)
  (let ((key (list parent node cap iterations nonempty empty iteration-start
                   outer-path iteration-path absent-children)))
    (%intern (%arena-frames arena)
             (%arena-frame-table arena)
             key
             (%make-frame :parent parent :node node :cap cap :iterations iterations
                          :nonempty nonempty :empty empty
                          :iteration-start iteration-start
                          :outer-path outer-path
                          :iteration-path iteration-path
                          :absent-children absent-children))))

(defun arena-frame-root (arena)
  "Root frame handle; always 0."
  (declare (ignore arena))
  0)

(defun arena-frame-open (arena frame node-id position cap)
  "Snapshot of a repetition frame opened at FRAME for NODE-ID.

POSITION is the repetition entry position; CAP is the precomputed admission
bound for the total number of iterations."
  (declare (ignore position))
  (%intern-frame arena
                 frame
                 node-id
                 cap
                 0 0 0
                 nil
                 (arena-frame-effective-path arena frame)
                 nil
                 nil))

(defun arena-frame-iteration-open (arena frame position)
  "Snapshot entering one iteration of the repetition in FRAME at POSITION."
  (let ((entry (%frame-entry arena frame)))
    (%intern-frame arena
                   (%frame-parent entry)
                   (%frame-node entry)
                   (%frame-cap entry)
                   (%frame-iterations entry)
                   (%frame-nonempty entry)
                   (%frame-empty entry)
                   position
                   (%frame-outer-path entry)
                   (arena-path arena
                               (%frame-outer-path entry)
                               (%frame-node entry)
                               (1+ (%frame-iterations entry)))
                   nil)))

(defun arena-frame-iteration-close (arena frame end-position)
  "Snapshot leaving the current iteration of FRAME at END-POSITION."
  (let* ((entry (%frame-entry arena frame))
         (start (%frame-iteration-start entry))
         (nonempty (if (and start (> end-position start))
                       (1+ (%frame-nonempty entry))
                       (%frame-nonempty entry)))
         (empty (if (and start (= end-position start))
                    (1+ (%frame-empty entry))
                    (%frame-empty entry))))
    (%intern-frame arena
                   (%frame-parent entry)
                   (%frame-node entry)
                   (%frame-cap entry)
                   (1+ (%frame-iterations entry))
                   nonempty
                   empty
                   nil
                   (%frame-outer-path entry)
                   nil
                   nil)))

(defun %frame-entry (arena handle)
  (aref (%arena-frames arena) handle))

(defun arena-frame-parent (arena handle)
  (%frame-parent (%frame-entry arena handle)))

(defun arena-frame-node (arena handle)
  (%frame-node (%frame-entry arena handle)))

(defun arena-frame-cap (arena handle)
  "Precomputed iteration admission bound for the repetition in FRAME."
  (%frame-cap (%frame-entry arena handle)))

(defun arena-frame-iterations (arena handle)
  (%frame-iterations (%frame-entry arena handle)))

(defun arena-frame-nonempty (arena handle)
  (%frame-nonempty (%frame-entry arena handle)))

(defun arena-frame-empty (arena handle)
  (%frame-empty (%frame-entry arena handle)))

(defun arena-frame-iteration-start (arena handle)
  (%frame-iteration-start (%frame-entry arena handle)))

(defun arena-frame-iteration-path (arena handle)
  (%frame-iteration-path (%frame-entry arena handle)))

(defun arena-frame-outer-path (arena handle)
  (%frame-outer-path (%frame-entry arena handle)))

(defun arena-frame-absent-children (arena handle)
  (%frame-absent-children (%frame-entry arena handle)))

(defun arena-frame-effective-path (arena handle)
  "Current dynamic path: the iteration path when inside an iteration."
  (let ((entry (%frame-entry arena handle)))
    (or (%frame-iteration-path entry)
        (%frame-outer-path entry))))

(defun arena-frame-mark-absent (arena frame child-id metadata)
  "Record the zero-iteration placeholder for CHILD-ID on FRAME.
Only the sole metadata child of a repetition frame that is not inside an
iteration qualifies; otherwise FRAME is returned unchanged."
  (let* ((entry (%frame-entry arena frame))
         (node (%frame-node entry)))
    (if (and node
             (null (%frame-iteration-start entry))
             (let* ((metadata-node (regexp-metadata-node metadata node))
                    (children (regexp-node-children metadata-node)))
               (and (= (length children) 1)
                    (= (aref children 0) child-id))))
        (%intern-frame arena
                       (%frame-parent entry)
                       node
                       (%frame-cap entry)
                       (%frame-iterations entry)
                       (%frame-nonempty entry)
                       (%frame-empty entry)
                       (%frame-iteration-start entry)
                       (%frame-outer-path entry)
                       (%frame-iteration-path entry)
                       t)
        frame)))

(defun repetition-frame-closable-p (arena frame metadata)
  "True when FRAME is a valid completed repetition for METADATA."
  (let* ((entry (%frame-entry arena frame))
         (node (%frame-node entry)))
    (when node
      (let* ((metadata-node (regexp-metadata-node metadata node))
             (minimum (regexp-node-minimum metadata-node))
             (maximum (regexp-node-maximum metadata-node))
             (nonempty (%frame-nonempty entry))
             (empty (%frame-empty entry))
             (total (+ nonempty empty))
             (absent (%frame-absent-children entry))
             (nullable
               (cond
                 ((> nonempty 0)
                  (= empty (max 0 (- minimum nonempty))))
                 ((> minimum 0)
                  (= empty minimum))
                 (t
                  (or (= empty 0) (= empty 1)))))
             (placeholders
               (if (zerop total)
                   absent
                   (not absent))))
        (and (>= total minimum)
             (or (eq maximum :unbounded)
                 (<= total maximum))
             nullable
             placeholders)))))

(defun apply-edge-label (arena frame history label position string metadata
                         not-bol not-eol)
  "Apply one compiled edge LABEL at POSITION.

Returns (values success-p new-position new-history new-frame).  Consuming an
input character advances the position; every other label leaves it alone.
Invalid completion or assertion failure yields NIL for SUCCESS-P."
  (let ((length (length string)))
    (cond
      ((eq label :epsilon)
       (values t position history frame))
      ((and (consp label) (eq (car label) :consume))
       (if (and (< position length)
                (predicate-matches-p (regexp-metadata-predicates metadata)
                                     (second label)
                                     (char-code (char string position))))
           (values t (1+ position) history frame)
           (values nil position history frame)))
      ((and (consp label) (eq (car label) :assert))
       (values (assertion-satisfied-p (second label) string position length
                                      (regexp-metadata-newline metadata)
                                      not-bol not-eol)
               position history frame))
      ((and (consp label) (eq (car label) :open))
       (let* ((id (second label))
              (path (arena-frame-effective-path arena frame))
              (history (arena-history arena history :open id position path))
              (node (regexp-metadata-node metadata id))
              (kind (regexp-node-kind node)))
         (values t position history
                 (if (eq kind :repeat)
                     (let* ((minimum (regexp-node-minimum node))
                            (maximum (regexp-node-maximum node))
                            ;; One nonempty iteration consumes at least one
                            ;; character, and at most the characters remaining
                            ;; at repetition entry are available; the minimum
                            ;; and the singleton empty iteration keep nullable
                            ;; repetitions finite.
                            (bound (max (- length position) minimum 1))
                            (cap (if (eq maximum :unbounded)
                                     bound
                                     (min maximum bound))))
                       (arena-frame-open arena frame id position cap))
                     frame))))
      ((and (consp label) (eq (car label) :close))
       (let* ((id (second label))
              (path (arena-frame-effective-path arena frame))
              (history (arena-history arena history :close id position path))
              (kind (regexp-node-kind (regexp-metadata-node metadata id))))
         (if (eq kind :repeat)
             (if (and (= (arena-frame-node arena frame) id)
                      (repetition-frame-closable-p arena frame metadata))
                 (values t position history (arena-frame-parent arena frame))
                 (values nil position history frame))
             (values t position history frame))))
      ((and (consp label) (eq (car label) :absent))
       (let* ((id (second label))
              (path (arena-frame-effective-path arena frame))
              (history (arena-history arena history :absent id position path)))
         (values t position history
                 (arena-frame-mark-absent arena frame id metadata))))
      ((and (consp label) (eq (car label) :iteration-open))
       (let* ((id (second label))
              (total (arena-frame-iterations arena frame)))
         (if (and (eq (arena-frame-node arena frame) id)
                  (< total (arena-frame-cap arena frame)))
             (let* ((frame (arena-frame-iteration-open arena frame position))
                    (path (arena-frame-effective-path arena frame))
                    (history (arena-history arena history :iteration-open id
                                            position path)))
               (values t position history frame))
             (values nil position history frame))))
      ((and (consp label) (eq (car label) :iteration-close))
       (let* ((id (second label))
              (path (or (arena-frame-iteration-path arena frame)
                        (arena-frame-effective-path arena frame)))
              (history (arena-history arena history :iteration-close id position path)))
         (if (= (arena-frame-node arena frame) id)
             (values t position history
                     (arena-frame-iteration-close arena frame position))
             (values nil position history frame))))
      (t
       (values nil position history frame)))))

;;; ---------------------------------------------------------------------------
;;; Parse-tree reconstruction.
;;;
;;; A pnode is one structural occurrence.  ADDRESS-R and BRANCH-R hold the
;;; enclosing repetition path and :or choices in reverse (inner to outer)
;;; order; they are filled once per reconstructed tree.  ABSENT placeholders
;;; have PRESENT nil and norm -1.

(defstruct (%pnode (:constructor %make-pnode))
  (id 0 :type (integer 0 *))
  (start 0 :type (integer 0 *))
  (end 0 :type (integer 0 *))
  (present t :type t)
  (children #() :type vector)
  (capture nil :type (or null (integer 1 *)))
  (address-r nil :type list)
  (branch-r nil :type list))

(defstruct (%open (:constructor %make-open
                               (&key id children pnode)))
  (id 0 :type (integer 0 *))
  (children nil :type list)
  (pnode nil :type t))

;;; Events oldest first, excluding the empty-chain handle 0.

(defun %history-chain (arena handle)
  (let ((events '())
        (current handle))
    (loop while (plusp current)
          do (push (%history-entry arena current) events)
             (setf current (%history-parent (%history-entry arena current))))
    events))

(defun %metadata-kind (metadata id)
  (regexp-node-kind (regexp-metadata-node metadata id)))

(defun %metadata-capture (metadata id)
  (regexp-node-capture (regexp-metadata-node metadata id)))

(defun %or-children (metadata id children)
  "Place the chosen child and the absent placeholder in their metadata slots."
  (let* ((node (regexp-metadata-node metadata id))
         (ids (regexp-node-children node))
         (slots (make-array 2 :initial-element nil)))
    (dolist (child children)
      (let ((slot (position (%pnode-id child) ids)))
        (when slot
          (setf (aref slots slot) child))))
    slots))

(defun %finalize-pnode (metadata pnode children)
  (let ((id (%pnode-id pnode)))
    (setf (%pnode-children pnode)
          (if (eq (%metadata-kind metadata id) :or)
              (%or-children metadata id children)
              (coerce (nreverse children) 'simple-vector)))))

(defun %reconstruct (arena history metadata)
  "Build the pnode tree for HISTORY, or NIL for the empty chain."
  (let ((stack '())
        (root nil))
    (dolist (event (%history-chain arena history))
      (let ((kind (%history-kind event))
            (id (%history-node-id event))
            (position (%history-position event)))
        (case kind
          (:open
           (let ((pnode (%make-pnode :id id :start position :present t
                                     :children #()
                                     :capture (%metadata-capture metadata id))))
             (when stack
               (push pnode (%open-children (first stack))))
             (push (%make-open :id id :children '() :pnode pnode) stack)))
          (:close
           (let ((open (first stack)))
             (when (and open (= (%open-id open) id))
               (pop stack)
               (setf (%pnode-end (%open-pnode open)) position)
               (%finalize-pnode metadata (%open-pnode open)
                                (%open-children open))
               (when (null stack)
                 (setf root (%open-pnode open))))))
          (:absent
           (when stack
             (push (%make-pnode :id id :start position :end position
                                :present nil :children #()
                                :capture (%metadata-capture metadata id))
                   (%open-children (first stack)))))
          (otherwise nil))))
    (when root
      (%annotate root metadata))
    root))

;;; Assign the enclosing repetition path and :or branch choices.  Contexts
;;; are accumulated in reverse (a cons onto the existing list is O(1)).
(defun %annotate (root metadata)
  (let ((stack (list (list root nil nil))))
    (loop while stack
          do (destructuring-bind (pnode address-r branch-r) (pop stack)
               (setf (%pnode-address-r pnode) address-r
                     (%pnode-branch-r pnode) branch-r)
               (let ((children (%pnode-children pnode))
                     (id (%pnode-id pnode)))
                 (case (%metadata-kind metadata id)
                   (:or
                    (loop for index from (1- (length children)) downto 0
                          do (push (list (aref children index)
                                         address-r
                                         (cons (cons id index) branch-r))
                                   stack)))
                   (:repeat
                    (loop for index from (1- (length children)) downto 0
                          do (push (list (aref children index)
                                         (cons (cons id (1+ index)) address-r)
                                         branch-r)
                                   stack)))
                   (otherwise
                    (loop for index from (1- (length children)) downto 0
                          do (push (list (aref children index)
                                         address-r branch-r)
                                   stack))))))))
  root)

;;; ---------------------------------------------------------------------------
;;; Selection.

(defun %minimal-repeat-ids (metadata)
  (let ((ids '()))
    (loop for node across (regexp-metadata-nodes metadata)
          when (and (eq (regexp-node-kind node) :repeat)
                    (eql (regexp-node-mode node) 1))
            do (push (regexp-node-id node) ids))
    (nreverse ids)))

(defun %occurrences (root node-id)
  "Present occurrences of NODE-ID in ROOT's tree, iterative DFS order."
  (let ((result '())
        (stack (list root)))
    (loop while stack
          do (let ((pnode (pop stack)))
               (when (and (%pnode-present pnode)
                          (= (%pnode-id pnode) node-id))
                 (push pnode result))
               (let ((children (%pnode-children pnode)))
                 (loop for index from (1- (length children)) downto 0
                       do (push (aref children index) stack)))))
    (nreverse result)))

(defun %occurrence-key (pnode)
  (list (reverse (%pnode-address-r pnode))
        (reverse (%pnode-branch-r pnode))
        (%pnode-start pnode)))

(defun %filter-minimal (survivors trees node-id)
  "One simultaneous minimal-mode pass for repeat NODE-ID."
  (let ((occurrences '())
        (minima (make-hash-table :test #'equal)))
    (dolist (candidate survivors)
      (dolist (pnode (%occurrences (aref trees candidate) node-id))
        (let* ((key (%occurrence-key pnode))
               (span (- (%pnode-end pnode) (%pnode-start pnode)))
               (minimum (gethash key minima)))
          (push (list candidate key span) occurrences)
          (when (or (null minimum) (< span minimum))
            (setf (gethash key minima) span)))))
    (let ((removed (make-hash-table :test #'eql)))
      (dolist (occurrence occurrences)
        (destructuring-bind (candidate key span) occurrence
          (when (> span (gethash key minima))
            (setf (gethash candidate removed) t))))
      (remove-if (lambda (candidate) (gethash candidate removed)) survivors))))

(defun %norm (pnode)
  (if (%pnode-present pnode)
      (- (%pnode-end pnode) (%pnode-start pnode))
      -1))

(defun %p-order-greater-p (left right)
  "True when LEFT's parse tree is greater in P-order than RIGHT's.

Compares subtree norms at positions in lexicographic (preorder) order.  A
nonexistent position (the other tree has fewer children at that index) has
norm +infinity and therefore wins over any existing subtree."
  (let ((left-norm (%norm left))
        (right-norm (%norm right)))
    (cond
      ((> left-norm right-norm) t)
      ((< left-norm right-norm) nil)
      (t
       (let* ((left-children (%pnode-children left))
              (right-children (%pnode-children right))
              (left-length (length left-children))
              (right-length (length right-children))
              (length (max left-length right-length)))
         (dotimes (index length)
           (cond
             ((>= index left-length)
              ;; LEFT has no position here: +infinity outranks RIGHT.
              (return-from %p-order-greater-p t))
             ((>= index right-length)
              (return-from %p-order-greater-p nil))
             (t
              (let ((left-child (aref left-children index))
                    (right-child (aref right-children index)))
                (cond
                  ((%p-order-greater-p left-child right-child)
                   (return-from %p-order-greater-p t))
                  ((%p-order-greater-p right-child left-child)
                   (return-from %p-order-greater-p nil)))))))
         nil)))))

(defun select-history (histories metadata arena)
  "Select the POSIX-preferred history from HISTORIES at one fixed start."
  (let* ((count (length histories))
         (trees (make-array count :initial-element nil))
         (survivors '()))
    (dotimes (index count)
      (let ((tree (%reconstruct arena (aref histories index) metadata)))
        (setf (aref trees index) tree)
        (when tree
          (push index survivors))))
    (setf survivors (nreverse survivors))
    ;; Minimal-mode filtering, ascending canonical node id.
    (dolist (node-id (%minimal-repeat-ids metadata))
      (when survivors
        (setf survivors (%filter-minimal survivors trees node-id))))
    (when (null survivors)
      (return-from select-history nil))
    ;; Prefer the maximum whole-match end.
    (let ((maximum-end -1))
      (dolist (candidate survivors)
        (setf maximum-end
              (max maximum-end (%pnode-end (aref trees candidate)))))
      (setf survivors
            (remove-if-not
             (lambda (candidate)
               (= (%pnode-end (aref trees candidate)) maximum-end))
             survivors)))
    (when (null survivors)
      (return-from select-history nil))
    ;; Prefer the P-order-greater tree; equal captures are free.
    (let ((winner (first survivors)))
      (dolist (candidate (rest survivors))
        (when (%p-order-greater-p (aref trees candidate)
                                  (aref trees winner))
          (setf winner candidate)))
      (aref histories winner))))

;;; ---------------------------------------------------------------------------
;;; Capture reporting.

(defun %nearest-capture-group (metadata id)
  "Nearest capturing ancestor of node ID, or NIL."
  (let ((parent (regexp-node-parent (regexp-metadata-node metadata id))))
    (loop while parent
          do (let ((node (regexp-metadata-node metadata parent)))
               (when (eq (regexp-node-kind node) :capture)
                 (return-from %nearest-capture-group
                   (regexp-node-capture node)))
               (setf parent (regexp-node-parent node))))
    nil))

(defun %last-occurrence (scope node-id)
  "Chronologically last preorder occurrence of NODE-ID inside SCOPE."
  (let ((last nil)
        (stack (list scope)))
    (loop while stack
          do (let ((pnode (pop stack)))
               (when (= (%pnode-id pnode) node-id)
                 (setf last pnode))
               (let ((children (%pnode-children pnode)))
                 (loop for index from (1- (length children)) downto 0
                       do (push (aref children index) stack)))))
    last))

(defun history-captures (history metadata arena)
  "Return POSIX subexpression offsets for HISTORY as a simple vector."
  (let* ((group-count (regexp-metadata-group-count metadata))
         (offsets (make-array (* 2 (1+ group-count)) :initial-element -1))
         (group-node (make-array (1+ group-count) :initial-element nil))
         (reported (make-array (1+ group-count) :initial-element nil))
         (tree (%reconstruct arena history metadata)))
    (loop for node across (regexp-metadata-nodes metadata)
          when (and (eq (regexp-node-kind node) :capture)
                    (regexp-node-capture node))
            do (setf (aref group-node (regexp-node-capture node))
                     (regexp-node-id node)))
    (when tree
      (setf (aref offsets 0) (%pnode-start tree)
            (aref offsets 1) (%pnode-end tree)))
    (loop for group from 1 to group-count
          do (let* ((id (aref group-node group))
                    (parent-group (%nearest-capture-group metadata id))
                    (scope (if parent-group
                               (aref reported parent-group)
                               tree)))
               (when (and scope (%pnode-present scope))
                 (let ((occurrence (%last-occurrence scope id)))
                   (setf (aref reported group) occurrence)
                   (when (and occurrence (%pnode-present occurrence))
                     (setf (aref offsets (* 2 group))
                           (%pnode-start occurrence)
                           (aref offsets (1+ (* 2 group)))
                           (%pnode-end occurrence)))))))
    offsets))
