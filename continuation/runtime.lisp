(in-package #:ooparts/continuation)

;; Each frame is immutable. Capturing retains a segment; invocation copies its
;; spine and attaches a fresh prompt and the caller's continuation. The closures
;; in frames take NEXT explicitly: none closes over the old continuation tail.
(defstruct (frame (:constructor %frame (kind data next bindings))) kind data next bindings)
(defun frame (kind data next)
  (%frame kind data next
          (if (eq kind :special)
              (append (reverse data) (when next (frame-bindings next)))
              (when next (frame-bindings next)))))
(defstruct (task (:constructor task (thunk stack))) thunk stack)
(defstruct (done (:constructor done (values))) values)
(defstruct (transfer-goal (:constructor transfer-goal (target action anchor))) target action anchor)
(defstruct (entry-state (:constructor entry-state (goal remaining))) goal remaining)
(defstruct (binding-cell (:constructor binding-cell (symbol value boundp)))
  symbol value boundp)
(defvar *stack* nil)
(defvar *running* nil)
(defvar *native-call* nil)
(defvar *driver-tag* nil)
(defstruct driver-context stack tag)
(defvar *drivers* nil)
(defvar *native-unwinding-prompts* nil)

(defclass cps-function (sb-mop:funcallable-standard-object)
  ((code :initarg :code :reader cps-code))
  (:metaclass sb-mop:funcallable-standard-class))
(defclass captured-continuation (cps-function)
  ((segment :initarg :segment :reader captured-segment))
  (:metaclass sb-mop:funcallable-standard-class))
(defun cps-function-p (x) (typep x 'cps-function))
(defun continuation-p (x) (typep x 'captured-continuation))
(defun make-cps-function (code &optional segment capturedp)
  (let ((f (if capturedp
               (make-instance 'captured-continuation :code code :segment segment)
               (make-instance 'cps-function :code code))))
    (sb-mop:set-funcallable-instance-function
     f (lambda (&rest args) (run (lambda (k) (apply code k args)))))
    f))

(defun bounce (k thunk) (task thunk k))
(defun deliver (values k)
  (bounce k
    (lambda ()
      (if (null k) (done values)
          (let ((next (frame-next k)) (data (frame-data k)))
            (case (frame-kind k)
              (:bind (funcall data values next))
              (:transition (transfer-goal-step data next))
              (:enter (enter-goal (entry-state-goal data) (entry-state-remaining data)))
              ((:prompt :special :catch :block :tagbody :handlers)
               (deliver values next))
              (:cleanup
               (funcall data
                        (frame :bind (lambda (ignored next)
                                       (declare (ignore ignored))
                                       (deliver values next)) next)))
              (:wind
               (invoke (cdr data)
                       (frame :bind (lambda (ignored next)
                                      (declare (ignore ignored))
                                      (deliver values next)) next) nil))
              (otherwise (error "Invalid CPS frame ~S" (frame-kind k)))))))))

(defun common-tail (a b)
  ;; Persistent acyclic spines: align lengths, then advance in lockstep.
  ;; No hash table is needed, including for empty/identical spines.
  (cond ((eq a b) a) ((or (null a) (null b)) nil)
        (t (let ((na (loop for p = a then (frame-next p) while p count p))
                 (nb (loop for p = b then (frame-next p) while p count p)))
             (loop while (> na nb) do (setf a (frame-next a)) (decf na))
             (loop while (> nb na) do (setf b (frame-next b)) (decf nb))
             (loop until (eq a b) do (setf a (frame-next a) b (frame-next b)))
             a))))

(defun stack-contains-p (needle stack)
  (loop for p = stack then (frame-next p) while p thereis (eq p needle)))
(defun transfer (target action &optional (source *stack*) anchor)
  "Exit extents, enter winders, then call ACTION with the current target."
  (transfer-goal-step (transfer-goal target action anchor) source))
(defun transfer-goal-step (goal source)
  (let ((anchor (transfer-goal-anchor goal)))
    (when (and anchor (not (stack-contains-p anchor source)))
      (dolist (driver (cdr *drivers*))
        (when (stack-contains-p anchor (driver-context-stack driver))
          (return-from transfer-goal-step
            (driver-transfer driver (transfer-goal-target goal)
                             (transfer-goal-action goal) anchor source))))
      (error 'inactive-control-target :name (frame-data anchor))))
  (let* ((target (transfer-goal-target goal))
         (common (common-tail source target))
         (leaving (loop for p = source then (frame-next p)
                        until (eq p common)
                        when (member (frame-kind p) '(:cleanup :wind))
                          return p)))
    (if leaving
        (let* ((outside (frame-next leaving))
               (resume (frame :transition goal outside)))
          (if (eq (frame-kind leaving) :cleanup)
              (funcall (frame-data leaving) resume)
              (invoke (cdr (frame-data leaving)) resume nil)))
        (let ((entering (loop for p = target then (frame-next p)
                             until (eq p common)
                             when (eq (frame-kind p) :wind) collect p)))
          (enter-goal goal (reverse entering))))))
(defun enter-goal (goal remaining)
  (if (null remaining)
      (let ((target (transfer-goal-target goal)))
        (bounce target (lambda () (funcall (transfer-goal-action goal) target))))
      (let* ((p (car remaining)) (outside (frame-next p)))
        (invoke (car (frame-data p))
                (frame :enter (entry-state goal (cdr remaining)) outside) nil))))

(defun lookup-frame (kind key stack)
  (loop for p = stack then (frame-next p) while p
            when (and (eq (frame-kind p) kind)
                      (funcall (if (eq kind :catch) #'eq #'eql)
                               (if (eq kind :tagbody) (car (frame-data p)) (frame-data p)) key))
              return p))
(defun resolve-frame (kind key)
  (let ((here (lookup-frame kind key *stack*)))
    (when here (return-from resolve-frame (values here nil)))
    ;; Aborting a native callback is safe; capturing its frames is not.
    (dolist (driver (cdr *drivers*))
      (let ((p (lookup-frame kind key (driver-context-stack driver))))
        (when p (return-from resolve-frame (values p driver)))))
    (unless (eq kind :catch) (error 'inactive-control-target :name key))))
(defun driver-transfer (driver target action anchor &optional (source *stack*))
  (if driver
      ;; First unwind virtual extents *in this driver*. Thus a SHIFT in a
      ;; cleanup can capture the pending escape before any native unwinding.
      (transfer nil
                (lambda (ignored)
                  (declare (ignore ignored))
                  (unless (member driver *drivers* :test #'eq)
                    (error 'inactive-control-target :name (frame-data anchor)))
                  (throw (driver-context-tag driver)
                    (bounce (driver-context-stack driver)
                            (lambda () (transfer target action *stack* anchor)))))
                source)
      (transfer target action source anchor)))
(defun control-return (kind key values)
  (multiple-value-bind (p driver) (resolve-frame kind key)
    (if p
        (let ((target (frame-next p)))
          (driver-transfer driver target (lambda (target) (deliver values target)) p))
        (throw key (values-list values)))))
(defun control-go (key index)
  (multiple-value-bind (target driver) (resolve-frame :tagbody key)
    (let ((code (nth index (cdr (frame-data target)))))
      (driver-transfer driver target (lambda (target) (funcall code target)) target))))

(defun clone-segment (segment old-prompt tail)
  ;; Only pending transitions contain frame references requiring rebasing.
  (unless (some (lambda (p) (member (frame-kind p) '(:transition :enter))) segment)
    (let ((next tail))
      (dolist (p (reverse segment))
        (setf next (frame (frame-kind p) (frame-data p) next)))
      (return-from clone-segment next)))
  ;; Pending exits/entries are data, rather than closures over an old target.
  ;; Rebase those targets as well, so SHIFT inside a cleanup or before/after
  ;; thunk remains composable. Shared lexical/special locations are retained.
  (let ((mapping (make-hash-table :test #'eq)) (pending nil) (head tail))
    (setf (gethash old-prompt mapping) tail)
    (labels ((copy-one (old next)
               (let ((new (frame (frame-kind old) (frame-data old) next)))
                 (setf (gethash old mapping) new)
                 (push (cons old new) pending) new))
             (rebase (old)
               (or (gethash old mapping)
                   (let ((prefix nil) (p old))
                     (loop while (and p (not (gethash p mapping)))
                           do (push p prefix) (setf p (frame-next p)))
                     ;; A target outside the captured prompt is not resurrected.
                     (if (null p) old
                         (let ((next (gethash p mapping)))
                           (dolist (item prefix next) (setf next (copy-one item next))))))))
             (rebase-goal (g)
               (transfer-goal (rebase (transfer-goal-target g))
                              (transfer-goal-action g)
                              (when (transfer-goal-anchor g) (rebase (transfer-goal-anchor g))))))
      (dolist (old (reverse segment)) (setf head (copy-one old head)))
      (loop while pending
            for pair = (pop pending) for old = (car pair) for new = (cdr pair)
            do (case (frame-kind old)
                 (:transition (setf (frame-data new) (rebase-goal (frame-data old))))
                 (:enter
                  (let* ((state (frame-data old)) (goal (rebase-goal (entry-state-goal state))))
                    (setf (frame-data new)
                          (entry-state goal (mapcar #'rebase (entry-state-remaining state))))))))
      head)))
(defun perform-shift (body k)
  (let ((prompt (loop for p = k then (frame-next p) while p
                      when (eq (frame-kind p) :prompt) return p)))
    (unless prompt (error (if *native-call* 'native-boundary 'missing-reset)))
    (when (member prompt *native-unwinding-prompts* :test #'eq)
      (error 'native-boundary))
    (let* ((segment (loop for p = k then (frame-next p)
                          until (eq p prompt) collect p))
           (captured
             (make-cps-function
              (lambda (caller &rest values)
                (let* ((delimiter (frame :prompt nil caller))
                       (resumed (clone-segment segment prompt delimiter)))
                  (transfer resumed (lambda (target) (deliver values target)))))
              segment t)))
      (transfer prompt (lambda (target) (funcall body captured target)) k))))

(defun visible-bindings (stack)
  (let ((seen (make-hash-table :test #'eq)) (cells nil))
    (dolist (cell (when stack (frame-bindings stack)))
      (unless (gethash (binding-cell-symbol cell) seen)
        (setf (gethash (binding-cell-symbol cell) seen) t)
        (push cell cells)))
    cells))
(defun call-with-bindings (stack thunk)
  (unless (and stack (frame-bindings stack))
    (return-from call-with-bindings (funcall thunk)))
  (let ((cells (visible-bindings stack)))
    (progv (mapcar #'binding-cell-symbol cells)
           (mapcar #'binding-cell-value cells)
      (dolist (cell cells)
        (unless (binding-cell-boundp cell) (makunbound (binding-cell-symbol cell))))
      (unwind-protect (funcall thunk)
        (dolist (cell cells)
          (let ((sym (binding-cell-symbol cell)))
            (setf (binding-cell-boundp cell) (boundp sym))
            (when (boundp sym) (setf (binding-cell-value cell) (symbol-value sym)))))))))
(defun push-specials (symbols values k body)
  (let ((cells (loop for sym in symbols for tail = values then (cdr tail)
                     collect (binding-cell sym (car tail) (not (null tail))))))
    ;; PROGV checks binding legality too (constants, keywords, non-symbols).
    (dolist (sym symbols)
      (unless (and (symbolp sym) (not (constantp sym)))
        (error 'type-error :datum sym :expected-type '(and symbol (not (satisfies constantp))))))
    (funcall body (frame :special cells k))))

(defun run (entry)
  (let* ((*running* t) (*stack* nil) (*driver-tag* (list nil))
         (driver (make-driver-context :tag *driver-tag*))
         (*drivers* (cons driver *drivers*))
         (finished nil) (current nil))
    (unwind-protect
         (loop with result = (funcall entry nil)
               do (typecase result
                    (done (setf finished t) (return (values-list (done-values result))))
                    (task
                     (setf current (task-stack result) (driver-context-stack driver) current)
                     (let ((*stack* current))
                       (setf result
                             (catch *driver-tag*
                               (call-with-bindings
                                current (task-thunk result))))))
                    (t (error "CPS code did not return a trampoline task: ~S" result))))
      (unless finished
        ;; Native errors/nonlocal exits still leave virtual UNWIND-PROTECTs.
        (when current
          (let ((*native-call* t)
                (*native-unwinding-prompts*
                  (append (loop for p = current then (frame-next p) while p
                                when (eq (frame-kind p) :prompt) collect p)
                          *native-unwinding-prompts*)))
            (run (lambda (ignored)
                   (declare (ignore ignored))
                   (transfer nil (lambda (target) (declare (ignore target)) (done nil)) current)))))))))

(defvar *adapters* (make-hash-table :test #'eq))

(defun invoke (designator k args)
  (bounce k
    (lambda ()
      (let* ((f (if (symbolp designator) (fdefinition designator) designator))
             (adapter (gethash f *adapters*)))
        (cond ((cps-function-p f) (apply (cps-code f) k args))
              (adapter (funcall adapter k args))
              (t (let ((*native-call* t))
                   (deliver (multiple-value-list (apply f args)) k))))))))

(defun install-adapter (name code) (setf (gethash (fdefinition name) *adapters*) code))
(defun register-cps-adapter (name replacement)
  "Route transformed calls to NAME's current function object to REPLACEMENT.
REPLACEMENT has the original argument list, usually made by LAMBDA/CPS."
  (check-type replacement function)
  (install-adapter name (lambda (k args) (invoke replacement k args)))
  name)
(install-adapter 'funcall (lambda (k args) (invoke (car args) k (cdr args))))
(install-adapter 'apply
                 (lambda (k args)
                   (unless (cdr args) (error "APPLY needs its final list argument."))
                   (invoke (car args) k
                           (append (butlast (cdr args)) (car (last args))))))

(defun map-adapter (mode k args)
  (let ((f (car args)) (lists (cdr args)))
    (unless lists (error "Mapping needs at least one list."))
    (labels ((step-map (tails acc continuation)
               (if (some #'null tails)
                   (deliver (list (case mode
                                    ((mapc mapl) (car lists))
                                    ((mapcan mapcon) (apply #'nconc (reverse acc)))
                                    (t (reverse acc)))) continuation)
                   (invoke f
                           (frame :bind
                                  (lambda (vs next)
                                    (step-map (mapcar #'cdr tails)
                                              (cons (car vs) acc) next)) continuation)
                           (if (member mode '(maplist mapl mapcon))
                               tails (mapcar #'car tails))))))
      (step-map lists nil k))))
(dolist (name '(mapcar maplist mapc mapl mapcan mapcon))
  (let ((mode name)) (install-adapter name (lambda (k args) (map-adapter mode k args)))))

(defun sequence-map-adapter (k args)
  (destructuring-bind (type function &rest sequences) args
    (unless sequences (error "MAP needs at least one sequence."))
    (let ((limit (apply #'min (mapcar #'length sequences))))
      (labels ((walk (i acc continuation)
                 (if (= i limit)
                     (deliver (list (when type (coerce (reverse acc) type))) continuation)
                     (invoke function
                             (frame :bind (lambda (vs next)
                                            (walk (1+ i) (cons (car vs) acc) next)) continuation)
                             (mapcar (lambda (seq) (elt seq i)) sequences)))))
        (walk 0 nil k)))))
(install-adapter 'map #'sequence-map-adapter)
(defun quantifier-adapter (mode k args)
  (let ((predicate (car args)) (sequences (cdr args)))
    (unless sequences (error "Sequence quantifiers need a sequence."))
    (let ((limit (apply #'min (mapcar #'length sequences)))
          (somep (member mode '(some notany)))
          (negatep (member mode '(notany notevery))))
      (labels ((finish (value continuation)
                 (deliver (list (if negatep (not value) value)) continuation))
               (walk (i continuation)
                 (if (= i limit) (finish (not somep) continuation)
                     (invoke predicate
                             (frame :bind
                                    (lambda (vs next)
                                      (let ((v (car vs)))
                                        (if (if somep v (not v)) (finish v next)
                                            (walk (1+ i) next)))) continuation)
                             (mapcar (lambda (seq) (elt seq i)) sequences)))))
        (walk 0 k)))))
(dolist (name '(some every notany notevery))
  (let ((mode name))
    (install-adapter name (lambda (k args) (quantifier-adapter mode k args)))))
(install-adapter
 'maphash
 (lambda (k args)
   (destructuring-bind (f table) args
     (let ((keys (loop for key being the hash-keys of table collect key)))
       (labels ((walk (keys continuation)
                  (if (null keys) (deliver (list nil) continuation)
                      (invoke f
                              (frame :bind (lambda (vs next)
                                             (declare (ignore vs))
                                             (walk (cdr keys) next)) continuation)
                              (list (car keys) (gethash (car keys) table))))))
         (walk keys k))))))

(install-adapter
 'reduce
 (lambda (k args)
   (destructuring-bind (f seq &key from-end (start 0) end (key #'identity)
                         (initial-value nil initialp)) args
     (let ((items (coerce (subseq seq start end) 'list)))
       (when from-end (setf items (reverse items)))
       (labels ((loop-reduce (rest acc continuation)
                  (if (null rest) (deliver (list acc) continuation)
                      (invoke key
                              (frame :bind
                                     (lambda (vs next)
                                       (invoke f
                                               (frame :bind
                                                      (lambda (vs next)
                                                        (loop-reduce (cdr rest) (car vs) next)) next)
                                               (if from-end (list (car vs) acc)
                                                   (list acc (car vs))))) continuation)
                              (list (car rest))))))
         (cond (initialp (loop-reduce items initial-value k))
               ((null items) (invoke f k nil))
               (t (invoke key
                          (frame :bind (lambda (vs next)
                                         (loop-reduce (cdr items) (car vs) next)) k)
                          (list (car items))))))))))

(defmacro shift (&rest args)
  (declare (ignore args))
  (error 'missing-reset))
(defmacro dynamic-wind (&rest args)
  (error 'unsupported-form :form `(dynamic-wind ,@args)
         :reason "Use inside WITH-CPS, RESET, or a CPS function."))
