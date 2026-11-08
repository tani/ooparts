(uiop:define-package #:ooparts-tests/prolog/kernel/instantiate
  (:use #:cl #:ooparts/prolog)
  (:import-from #:ooparts/prolog/kernel/engine
    #:deref #:fresh-cons #:fresh-var #:instantiate #:map-term #:push-choice #:reify #:unify
    #:unwind-trail)
  (:import-from #:ooparts/prolog/kernel/model
    #:%make-machine #:logic-var-binding #:logic-var-id #:machine-heap #:machine-trail
    #:machine-variables #:make-host-goal #:slot-ref)
  (:import-from #:ooparts-tests/prolog/support/assertions #:check #:value-of)
  (:export #:run-instantiate-tests))
(in-package #:ooparts-tests/prolog/kernel/instantiate)

(defun run-instantiate-tests ()
  ;; Direct roots retain age-based orientation, conditional trails and rollback.
  (dolist (younger-left '(nil t))
    (let* ((vm (%make-machine))
           (older (fresh-var vm))
           (younger (fresh-var vm)))
      (push-choice vm 0)
      (unwind-protect
           (progn
             (check (eq t (unify vm (if younger-left younger older)
                                 (if younger-left older younger)))
                    "direct root variable unification returns exactly true")
             (check (and (= 1 (length (machine-trail vm)))
                         (eq younger (aref (machine-trail vm) 0))
                         (eq older (logic-var-binding younger))
                         (eq older (deref older)))
                    "direct root variables bind younger to older with one undo record")
             (unwind-trail vm 0)
             (check (and (eq older (deref older)) (eq younger (deref younger)))
                    "direct root variable rollback restores both original cells"))
        (close-query vm))))

  ;; Runtime slot values are inserted atomically, however complex or source-like.
  (let* ((vm (%make-machine))
         (opaque (make-array 3 :initial-contents '(:nominal 17 :opaque)))
         (leaf (cons opaque :shared))
         (value (list (list :source '(host-callback x) :line 23) leaf leaf))
         (template (cons (slot-ref 0) (slot-ref 0)))
         (slots (vector value))
         (first (instantiate template slots vm))
         (second (instantiate template slots vm)))
    (check (= 2 (length (machine-heap vm)))
           "INSTANTIATE allocates only original template conses")
    (check (and (eq (car first) value) (eq (cdr first) value)
                (eq (car second) value) (eq (cdr second) value))
           "slot values and their repeated aliases retain exact identity")
    (check (not (eq first second)) "instantiations have fresh template conses")
    (destructuring-bind (metadata left right) (car first)
      (check (and (eq left right) (eq (car left) opaque)
                  (eq :shared (cdr left))
                  (equal metadata '(:source (host-callback x) :line 23)))
             "slot DAG, opaque payload, and source-like metadata are intact"))
    (check (equalp opaque #(:nominal 17 :opaque))
           "mutable reference-like host array retains identity and contents")
    (check (equal (reify first) (cons value value))
           "atomic slot insertion preserves the external term shape")
    (let* ((shared-tail (cons (slot-ref 0) nil))
           (dag-template (cons shared-tail shared-tail))
           (dag-first (instantiate dag-template slots vm))
           (dag-second (instantiate dag-template slots vm)))
      (check (and (eq (car dag-first) (cdr dag-first))
                  (eq (car dag-second) (cdr dag-second))
                  (not (eq dag-first dag-second))
                  (not (eq (car dag-first) (car dag-second)))
                  (= 6 (length (machine-heap vm))))
             "shared template nodes stay aliased without sharing activations")))

  ;; A substituted cyclic value is already a runtime graph, not a template.
  (let ((vm (%make-machine))
        (ring (cons :slot nil))
        (template-ring (cons :template nil)))
    (setf (cdr ring) ring (cdr template-ring) template-ring)
    (let ((root (instantiate (slot-ref 0) (vector ring) vm))
          (copy (instantiate template-ring #() vm)))
      (check (eq root ring) "bare slot-ref root returns the existing cycle")
      (check (and (not (eq copy template-ring))
                  (eq :template (car copy)) (eq copy (cdr copy)))
             "cyclic original template gets a distinct template ring")
      (check (= 1 (length (machine-heap vm)))
             "cyclic slot values do not add managed clones")))

  ;; Distinct activations and slot arrays share only the intended logical cells.
  (let* ((vm (%make-machine))
         (left (fresh-var vm))
         (right (fresh-var vm))
         (template (cons (slot-ref 0) (slot-ref 1)))
         (first (instantiate template (vector left right) vm))
         (second (instantiate template (vector right left) vm)))
    (check (and (not (eq left right)) (not (eq first second))
                (eq left (car first)) (eq right (cdr first))
                (eq right (car second)) (eq left (cdr second)))
           "separate slots keep exact cell identities without template sharing")
    (check (= 4 (length (machine-heap vm)))
           "variable instantiation adds only activation-local template conses")
    (check (and (eq left (deref left)) (eq right (deref right)))
           "inserted variables start unbound")
    (let ((external (reify first)))
      (check (and (symbolp (car external)) (symbolp (cdr external))
                  (not (eq (car external) (cdr external))))
             "distinct slot cells reify as distinct unbound variables"))
    (let ((binding (fresh-cons vm :bound nil)))
      (setf (logic-var-binding left) binding)
      (check (and (eq binding (deref left))
                  (eq binding (deref (car first)))
                  (eq binding (deref (cdr second)))
                  (eq right (deref right)))
             "rebinding through either instantiation affects only its own cell")
      (setf (logic-var-binding left) left)
      (check (and (eq left (deref left)) (eq right (deref right)))
             "restoring a slot cell restores its unbound behavior")))

  ;; Host-supplied runtime conses retain identity across answer boundaries,
  ;; rather than being copied independently for each query variable.
  (let* ((pair (cons :left :right))
         (vm (make-query
              (list (make-host-goal :function (lambda () pair) :output '?x)
                    (make-host-goal :function (lambda () pair) :output '?y)))))
    (unwind-protect
         (multiple-value-bind (answer foundp) (next-solution vm)
           (check foundp "shared host pair query succeeds")
           (let ((left (value-of '?x answer))
                 (right (value-of '?y answer)))
             (check (and (consp left) (eq left right)
                         (eq :left (car left)) (eq :right (cdr left)))
                    "one physical host pair stays EQ in two answer fields")))
      (close-query vm)))

  (let* ((first-pair (cons :independent :pair))
         (second-pair (cons :independent :pair))
         (vm (make-query
              (list (make-host-goal :function (lambda () first-pair) :output '?x)
                    (make-host-goal :function (lambda () second-pair) :output '?y)))))
    (unwind-protect
         (multiple-value-bind (answer foundp) (next-solution vm)
           (check foundp "independent host pair query succeeds")
           (let ((left (value-of '?x answer))
                 (right (value-of '?y answer)))
             (check (and (consp left) (consp right) (equal left right)
                         (not (eq left right)))
                    "merely EQUAL independent host pairs remain non-EQ answers")))
      (close-query vm)))

  (let* ((ring (cons :ring nil))
         (vm (make-query
              (list (make-host-goal :function (lambda () ring) :output '?x)
                    (make-host-goal :function (lambda () ring) :output '?y)))))
    (setf (cdr ring) ring)
    (unwind-protect
         (multiple-value-bind (answer foundp) (next-solution vm)
           (check foundp "shared host cycle query succeeds")
           (let ((left (value-of '?x answer))
                 (right (value-of '?y answer)))
             (check (and (consp left) (eq left right) (eq :ring (car left))
                         (eq left (cdr left)))
                    "one supplied cycle remains EQ and cyclic across answers")))
      (close-query vm)))

  ;; These cycles are made by unification, not supplied by a host callback.
  (let ((vm (make-query '((= ?x (a . ?y)) (= ?y ?x)))))
    (unwind-protect
         (multiple-value-bind (answer foundp) (next-solution vm)
           (check foundp "cross-output cyclic unification succeeds")
           (let ((left (value-of '?x answer))
                 (right (value-of '?y answer)))
             (check (and (consp left) (eq left right) (eq 'a (car left))
                         (eq left (cdr left)))
                    "unification-created cross-output terms stay EQ and cyclic")))
      (close-query vm)))

  ;; A ground cursor can carry explicitly installed query cells.  Neither the
  ;; binding alias nor the cycle through that alias is flattened by reification.
  (let ((vm (make-query '((true)))))
    (unwind-protect
         (let* ((left (fresh-var vm))
                (right (fresh-var vm))
                (ring (fresh-cons vm :manual nil)))
           (setf (logic-var-binding left) ring
                 (logic-var-binding right) left
                 (cdr ring) right
                 (machine-variables vm)
                 (list (cons '?manual-left left) (cons '?manual-right right)))
           (multiple-value-bind (answer foundp) (next-solution vm)
             (check foundp "manual binding-cycle query succeeds")
             (let ((left-answer (value-of '?manual-left answer))
                   (right-answer (value-of '?manual-right answer)))
               (check (and (consp left-answer) (eq left-answer right-answer)
                           (eq :manual (car left-answer))
                           (eq left-answer (cdr left-answer)))
                      "manual cyclic variable bindings retain aliases and cycles"))))
      (close-query vm)))

  ;; Logic-variable serial numbers are allocation metadata, not source-cell
  ;; identities.  Aliased cells, in contrast, must still share one detached name.
  (let ((vm (make-query '((= ?joined-left ?joined-right)))))
    (unwind-protect
         (let* ((joined-left (cdr (assoc '?joined-left (machine-variables vm))))
                (joined-right (cdr (assoc '?joined-right (machine-variables vm))))
                (duplicate-left (fresh-var vm))
                (duplicate-right (fresh-var vm))
                (forward-left (fresh-var vm))
                (forward-right (fresh-var vm))
                (reverse-left (fresh-var vm))
                (reverse-right (fresh-var vm)))
           (setf (logic-var-id duplicate-left) 31
                 (logic-var-id duplicate-right) 31
                 (logic-var-id forward-left) 22
                 (logic-var-id forward-right) 23
                 (logic-var-id reverse-left) 23
                 (logic-var-id reverse-right) 22
                 (logic-var-id joined-left) 5
                 (logic-var-id joined-right) 5
                 (machine-variables vm)
                 (list (cons '?duplicate-left duplicate-left)
                       (cons '?duplicate-right duplicate-right)
                       (cons '?forward-left forward-left)
                       (cons '?forward-right forward-right)
                       (cons '?reverse-left reverse-left)
                       (cons '?reverse-right reverse-right)
                       (cons '?joined-left joined-left)
                       (cons '?joined-right joined-right)))
           (multiple-value-bind (answer foundp) (next-solution vm)
             (check foundp "detached variable identity query succeeds")
             (let* ((duplicate-left-name (value-of '?duplicate-left answer))
                    (duplicate-right-name (value-of '?duplicate-right answer))
                    (forward-left-name (value-of '?forward-left answer))
                    (forward-right-name (value-of '?forward-right answer))
                    (reverse-left-name (value-of '?reverse-left answer))
                    (reverse-right-name (value-of '?reverse-right answer))
                    (joined-left-name (value-of '?joined-left answer))
                    (joined-right-name (value-of '?joined-right answer))
                    (detached-names
                     (list duplicate-left-name duplicate-right-name
                           forward-left-name forward-right-name
                           reverse-left-name reverse-right-name)))
               (check (and (every (lambda (name)
                                    (and (symbolp name) (null (symbol-package name))))
                                  (append detached-names
                                          (list joined-left-name joined-right-name)))
                           (= 6 (length (remove-duplicates detached-names :test #'eq))))
                      "duplicate and reversed numeric IDs do not merge detached names")
               (check (and (eq joined-left-name joined-right-name)
                           (not (member joined-left-name detached-names :test #'eq)))
                      "genuinely unified query cells share only their own name"))))
      (close-query vm)))

  ;; MAP-TERM's copy table is scoped to one public call, with or without an
  ;; allocator; no source graph or earlier activation can leak into a later copy.
  (let* ((ring (cons :ring nil))
         (root (cons ring ring)))
    (setf (cdr ring) ring)
    (let ((plain-first (map-term root #'identity))
          (plain-second (map-term root #'identity)))
      (let ((allocations nil))
        (flet ((allocate ()
                 (let ((cell (cons nil nil)))
                   (push cell allocations)
                   cell)))
          (let ((allocated-first (map-term root #'identity #'allocate))
                (allocated-second (map-term root #'identity #'allocate)))
            (dolist (copy (list plain-first plain-second
                                allocated-first allocated-second))
              (check (and (consp copy) (consp (car copy))
                          (eq (car copy) (cdr copy))
                          (eq (car copy) (cdr (car copy)))
                          (eq :ring (car (car copy))))
                     "MAP-TERM preserves sharing and cycles within each call"))
            (check (and (not (eq plain-first root)) (not (eq plain-second root))
                        (not (eq plain-first plain-second))
                        (not (eq (car plain-first) (car plain-second))))
                   "ordinary MAP-TERM calls allocate independent graph copies")
            (check (and (not (eq allocated-first root))
                        (not (eq allocated-second root))
                        (not (eq allocated-first allocated-second))
                        (not (eq (car allocated-first) (car allocated-second)))
                        (not (eq (car allocated-first) ring))
                        (not (eq (car allocated-second) ring)))
                   "custom-allocator MAP-TERM calls do not share copy state")
            (check (and (= 4 (length allocations))
                        (member allocated-first allocations :test #'eq)
                        (member (car allocated-first) allocations :test #'eq)
                        (member allocated-second allocations :test #'eq)
                        (member (car allocated-second) allocations :test #'eq))
                   "custom MAP-TERM allocator supplies every fresh graph cons"))))))

  ;; A true answer is successful even though its binding alist is NIL.
  (let ((vm (make-query '((true)))))
    (unwind-protect
         (multiple-value-bind (bindings foundp truth delays) (next-solution vm)
           (check (and (null bindings) foundp (eq :true truth) (null delays))
                  "NIL ground bindings retain the success, truth, and delay protocol"))
      (close-query vm))))
