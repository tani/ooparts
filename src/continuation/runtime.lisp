(uiop:define-package #:ooparts/continuation/runtime
  (:use #:cl)
  ;; MKCL has no FUNCALLABLE-STANDARD-OBJECT class; its CLOS makes any
  ;; standard instance funcallable instead (see the class definitions below).
  #-mkcl
  (:import-from
   #+sbcl #:sb-mop
   #+ccl #:ccl
   #+cmucl #:pcl
   #+abcl #:mop
   #+(or clisp ecl clasp) #:clos
   #:funcallable-standard-object #:funcallable-standard-class
   #:set-funcallable-instance-function)
  (:import-from #:ooparts/continuation/conditions #:cps-error #:missing-reset #:native-boundary #:unsupported-form #:inactive-control-target #:unsupported-form-form #:unsupported-form-reason)
  (:export #:push-restart-condition #:restart-condition #:*native-call* #:run #:bounce #:deliver #:frame #:perform-shift #:push-specials #:invoke #:control-return #:control-go #:make-cps-function #:shift #:dynamic-wind #:register-cps-adapter #:cps-function-p #:continuation-p))
(in-package #:ooparts/continuation/runtime)

;; Each frame is immutable. Capturing retains a segment; invocation copies its
;; spine and attaches a fresh prompt and the caller's continuation. The closures
;; in frames take NEXT explicitly: none closes over the old continuation tail.
(defstruct (restart-binding (:constructor restart-binding (installer))) installer)
(defstruct (frame (:constructor %frame (kind data next bindings handlers)))
  kind data next bindings handlers)
(defun frame (kind data next)
  ;; Each activation owns its restart identity, even when the installer code
  ;; is shared by several invocations of the same captured continuation.
  (case kind
    (:restarts
     (setf data (restart-binding (if (restart-binding-p data)
                                    (restart-binding-installer data) data))))
    (:restart-condition (setf data (cons (car data) (cdr data)))))
  (%frame kind data next
          (if (eq kind :special)
              (append (reverse data) (when next (frame-bindings next)))
              (when next (frame-bindings next)))
          (case kind
            (:handlers (cons data (when next (frame-handlers next))))
            ((:restarts :restart-condition)
             (cons (cons kind data) (when next (frame-handlers next))))
            (otherwise (when next (frame-handlers next))))))
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
(defstruct driver-context stack tag (activep t))
(defvar *drivers* nil)
(defvar *native-unwinding-prompts* nil)
#+(or abcl ecl) (defvar *pending-unbindings* nil)

#-mkcl
(defclass cps-function (funcallable-standard-object)
  ((code :initarg :code :reader cps-code))
  (:metaclass funcallable-standard-class))
#-mkcl
(defclass captured-continuation (cps-function)
  ((segment :initarg :segment :reader captured-segment))
  (:metaclass funcallable-standard-class))
;; MKCL's CLOS has no funcallable metaobject: every standard instance can be
;; given a funcallable definition, individually, after allocation.  Ordinary
;; slot accessors stop reading such an instance, so the readers below use the
;; primitive that still reaches its slot vector.
#+mkcl
(defclass cps-function ()
  ((code :initarg :code)))
#+mkcl
(defclass captured-continuation (cps-function)
  ((segment :initarg :segment)))
#+mkcl
(defun cps-code (function)
  (clos::funcallable-standard-instance-access function 0))
#+mkcl
(defun captured-segment (function)
  (clos::funcallable-standard-instance-access function 1))
(defun cps-function-p (x) (typep x 'cps-function))
(defun continuation-p (x) (typep x 'captured-continuation))

(defun restart-condition (datum arguments default-type)
  "Resolve a standard condition designator before associating its restarts."
  (etypecase datum
    (condition
     (when (and arguments (eq default-type 'simple-warning))
       (error 'type-error :datum arguments :expected-type 'null))
     datum)
    (symbol (apply #'make-condition datum arguments))
    ((or string function)
     (make-condition default-type :format-control datum :format-arguments arguments))))
(defun make-cps-function (code &optional segment capturedp)
  (let ((f (if capturedp
               (make-instance 'captured-continuation :code code :segment segment)
               (make-instance 'cps-function :code code))))
    ;; MKCL accepts any standard instance, but its setter is an internal
    ;; CLOS entry point rather than an exported MOP generic function.
    #+mkcl
    (clos::set-funcallable-instance-function
     f #'(lambda (&rest args) (run (lambda (k) (apply code k args)))))
    ;; CMUCL requires INSTANCE-LAMBDA to recover a funcallable object's
    ;; closure environment; an ordinary closure uses a different convention.
    #-mkcl
    (set-funcallable-instance-function
     f #'(#+cmucl kernel:instance-lambda #-cmucl lambda
          (&rest args) (run (lambda (k) (apply code k args)))))
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
              ((:prompt :special :catch :block :tagbody :handlers :restarts :restart-condition)
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
                  (unless (and (driver-context-activep driver)
                               (member driver *drivers* :test #'eq))
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
  ;; Pending transfers and restart associations refer to captured identities.
  (unless (some (lambda (p) (member (frame-kind p) '(:transition :enter :restart-condition))) segment)
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
                 (when (eq (frame-kind old) :restarts)
                   (setf (gethash (frame-data old) mapping) (frame-data new)))
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
                 (:restart-condition
                  (let* ((association (frame-data new))
                         (binding (gethash (car association) mapping)))
                    (when binding (setf (car association) binding))))
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
  (let ((cells (visible-bindings stack))
        #+(or abcl ecl) (*pending-unbindings* nil))
    (labels ((execute ()
               (unwind-protect (funcall thunk)
                 (dolist (cell cells)
                   (unless #+(or abcl ecl) (member cell *pending-unbindings* :test #'eq)
                           #-(or abcl ecl) nil
                     (let ((symbol (binding-cell-symbol cell)))
                       (setf (binding-cell-boundp cell) (boundp symbol))
                       (when (boundp symbol)
                         (setf (binding-cell-value cell) (symbol-value symbol)))))))))
      ;; Each symbol occurs once, so initial binding order is immaterial.
      ;; Missing trailing values establish unbound dynamic bindings directly.
      (let ((symbols (loop for cell in cells
                           unless (binding-cell-boundp cell)
                             collect (binding-cell-symbol cell)))
            (values nil))
        (dolist (cell cells)
          (when (binding-cell-boundp cell)
            (push (binding-cell-symbol cell) symbols)
            (push (binding-cell-value cell) values)))
        (progv symbols values (execute))))))

(defun call-with-handlers (stack thunk)
  (let* ((installers (when stack (frame-handlers stack)))
         (conditions (loop for entry in installers
                           when (and (consp entry) (eq (car entry) :restart-condition))
                             collect (cdr entry))))
    (labels ((install (remaining)
               (cond ((null remaining) (funcall thunk))
                     ((functionp (car remaining))
                      (funcall (car remaining) (lambda () (install (cdr remaining)))))
                     ((eq (caar remaining) :restarts)
                      (let ((binding (cdar remaining)))
                        (funcall (restart-binding-installer binding)
                                 (lambda () (install (cdr remaining)))
                                 (cdr (assoc binding conditions :test #'eq)))))
                     (t (install (cdr remaining))))))
      (install (reverse installers)))))

(defun push-restart-condition (condition k body)
  (let ((binding (loop for p = k then (frame-next p) while p
                         when (eq (frame-kind p) :restarts) return (frame-data p))))
    (unless binding (error "No virtual restart binding for condition ~S" condition))
    (funcall body (frame :restart-condition (cons binding condition) k))))

(defun push-specials (symbols values k body)
  (let ((cells (loop for sym in symbols for tail = values then (cdr tail)
                     collect (binding-cell sym (car tail) (not (null tail))))))
    ;; PROGV checks binding legality too (constants, keywords, non-symbols).
    (dolist (sym symbols)
      (unless (and (symbolp sym) (not (constantp sym)))
        (error 'type-error :datum sym :expected-type '(and symbol (not (satisfies constantp))))))
    (funcall body (frame :special cells k))))

(defun run (entry)
  (let* ((callers (remove-if-not #'driver-context-activep *drivers*))
         ;; A native boundary needs a suspended virtual caller. A direct
         ;; outer region can set the guard before entering a fresh root driver.
         (*native-call* (and *native-call* (not (null callers))))
         (*running* t) (*stack* nil) (*driver-tag* (list nil))
         (driver (make-driver-context :tag *driver-tag*))
         (*drivers* (cons driver callers))
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
                               (if (and current (frame-handlers current))
                                   (call-with-bindings
                                    current (lambda () (call-with-handlers current (task-thunk result))))
                                   (call-with-bindings current (task-thunk result)))))))
                    (t (error "CPS code did not return a trampoline task: ~S" result))))
      (unwind-protect
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
                   (transfer nil (lambda (target) (declare (ignore target)) (done nil)) current))))))
        (setf (driver-context-activep driver) nil)))))

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
#+(or abcl ecl)
(install-adapter 'makunbound
  (lambda (k arguments)
    (destructuring-bind (symbol) arguments
      (check-type symbol symbol)
      ;; These implementations clear the global value through MAKUNBOUND.
      ;; Update the virtual binding and install it unbound in the next task,
      ;; without touching the global value or relying on private runtime APIs.
      (let ((cell (find symbol (when *stack* (frame-bindings *stack*))
                        :key #'binding-cell-symbol :test #'eq)))
        (if cell
            (progn (setf (binding-cell-boundp cell) nil)
                   (push cell *pending-unbindings*))
            (makunbound symbol)))
      (deliver (list symbol) k))))

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
