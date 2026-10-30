;;; Graph construction for the regexp library.
;;;
;;; The canonical AST is lowered directly into an immutable edge graph.  State
;;; 0 is accepting and every canonical node is tagged with (:open id) before
;;; and (:close id) after its fragment.  Repetition loops carry iteration tags;
;;; bounds are enforced by the execution engines, not here.
(uiop:define-package #:ooparts/regexp/compiler
  (:use #:cl)
  (:import-from #:ooparts/regexp/model
    #:make-compiled-graph
    #:make-regexp-edge
    #:regexp-edge-source
    #:regexp-edge-destination)
  (:import-from #:ooparts/regexp/syntax
    #:normalize-regexp)
  (:export #:compile-graph))
(in-package #:ooparts/regexp/compiler)

(defun internal-error (format-control &rest arguments)
  (error "Regexp compiler internal error: ~?" format-control arguments))

(defstruct (%builder
             (:constructor make-%builder))
  (counter 0 :type (integer 0 *))
  (edges (make-array 32 :adjustable t :fill-pointer 0)))

(declaim (inline %alloc %connect))

(defun %alloc (builder)
  (incf (%builder-counter builder)))

(defun %connect (builder source label destination)
  (vector-push-extend (make-regexp-edge :source source
                                        :label label
                                        :destination destination)
                      (%builder-edges builder))
  destination)

(defun %child-id (form)
  (let ((id (and (consp form) (second form))))
    (unless (integerp id)
      (internal-error "malformed canonical child ~S" form))
    id))

(defun %emit (builder ast continuation)
  "Emit the fragment for AST ending at CONTINUATION; return its entry state."
  (unless (consp ast)
    (internal-error "malformed canonical node ~S" ast))
  (let ((kind (car ast))
        (id (second ast)))
    (unless (and (integerp id) (not (minusp id)))
      (internal-error "malformed canonical node id in ~S" ast))
    (ecase kind
      (:epsilon
       (let ((entry (%alloc builder))
             (close-state (%alloc builder)))
         (%connect builder entry (list :open id) close-state)
         (%connect builder close-state (list :close id) continuation)
         entry))
      (:consume
       (let ((predicate (third ast)))
         (unless (and (integerp predicate) (not (minusp predicate)))
           (internal-error "malformed predicate in ~S" ast))
         (let ((entry (%alloc builder))
               (consume-state (%alloc builder))
               (close-state (%alloc builder)))
           (%connect builder entry (list :open id) consume-state)
           (%connect builder consume-state (list :consume predicate) close-state)
           (%connect builder close-state (list :close id) continuation)
           entry)))
      (:assert
       (let ((assertion (third ast)))
         (unless (member assertion '(:bol :eol))
           (internal-error "malformed assertion in ~S" ast))
         (let ((entry (%alloc builder))
               (assert-state (%alloc builder))
               (close-state (%alloc builder)))
           (%connect builder entry (list :open id) assert-state)
           (%connect builder assert-state (list :assert assertion) close-state)
           (%connect builder close-state (list :close id) continuation)
           entry)))
      (:seq
       (let* ((left (third ast))
              (right (fourth ast))
              (entry (%alloc builder))
              (close-state (%alloc builder))
              ;; The right fragment is emitted first so its entry state is
              ;; known when the left continuation is fixed.
              (right-entry (%emit builder right close-state))
              (left-entry (%emit builder left right-entry)))
         (%connect builder entry (list :open id) left-entry)
         (%connect builder close-state (list :close id) continuation)
         entry))
      (:or
       (let* ((left (third ast))
              (right (fourth ast))
              (left-id (%child-id left))
              (right-id (%child-id right))
              (entry (%alloc builder))
              (split (%alloc builder))
              (close-state (%alloc builder))
              (left-entry (%emit builder left close-state))
              (right-entry (%emit builder right close-state)))
         (%connect builder entry (list :open id) split)
         (%connect builder split (list :absent right-id) left-entry)
         (%connect builder split (list :absent left-id) right-entry)
         (%connect builder close-state (list :close id) continuation)
         entry))
      (:capture
       (let* ((child (fourth ast))
              (entry (%alloc builder))
              (close-state (%alloc builder))
              (child-entry (%emit builder child close-state)))
         (%connect builder entry (list :open id) child-entry)
         (%connect builder close-state (list :close id) continuation)
         entry))
      (:repeat
       (let* ((minimum (third ast))
              (maximum (fourth ast))
              (mode (fifth ast))
              (child (sixth ast)))
         (declare (ignore minimum maximum mode))
         (let* ((child-id (%child-id child))
                (entry (%alloc builder))
                (loop-state (%alloc builder))
                (close-state (%alloc builder))
                (after-iteration (%alloc builder))
                (child-entry (%emit builder child after-iteration)))
           (%connect builder entry (list :open id) loop-state)
           (%connect builder loop-state (list :iteration-open id) child-entry)
           (%connect builder after-iteration (list :iteration-close id) loop-state)
           (%connect builder loop-state (list :absent child-id) close-state)
           (%connect builder loop-state :epsilon close-state)
           (%connect builder close-state (list :close id) continuation)
           entry))))))

(defun compile-graph (expression &key case-insensitive newline minimal)
  "Normalize EXPRESSION and lower it into an immutable COMPILED-GRAPH."
  (multiple-value-bind (ast metadata)
      (normalize-regexp expression
                        :case-insensitive case-insensitive
                        :newline newline
                        :minimal minimal)
    (let* ((builder (make-%builder))
           (entry (%emit builder ast 0))
           (edges (%builder-edges builder))
           (state-count (1+ (%builder-counter builder))))
      (loop for edge across edges
            do (when (or (>= (regexp-edge-source edge) state-count)
                         (>= (regexp-edge-destination edge) state-count))
                 (internal-error "edge outside state range for ~S" ast)))
      (make-compiled-graph :entry entry
                           :state-count state-count
                           :edges (coerce edges 'simple-vector)
                           :metadata metadata))))
