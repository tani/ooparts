(uiop:define-package #:ooparts/continuation/compiler
  (:use #:cl)
  (:import-from #:sb-cltl2)
  (:import-from #:ooparts/continuation/conditions #:cps-error #:missing-reset #:native-boundary #:unsupported-form #:inactive-control-target #:unsupported-form-form #:unsupported-form-reason)
  (:import-from #:ooparts/continuation/runtime #:*native-call* #:run #:bounce #:deliver #:frame #:perform-shift #:push-specials #:invoke #:control-return #:control-go #:make-cps-function #:shift #:dynamic-wind #:register-cps-adapter #:cps-function-p #:continuation-p)
  (:export #:reset #:with-cps #:lambda/cps #:defun/cps #:transform #:analyze #:*transformation-mode*))
(in-package #:ooparts/continuation/compiler)

(defparameter *transformation-mode* :selective
  "Either :SELECTIVE or :FULL. FULL disables direct islands for differential testing.")
(defstruct effect impure dependencies)
(defstruct (ir (:constructor %ir (op args effect))) op args effect)
(defstruct var-info name native specialp)
(defstruct fun-info name native effect lambda)
(defstruct target-info name token used effect native-tags depth)
(defstruct (context (:constructor %context)) env vars funcs blocks tags specials (control-depth 0))
(defvar *effects*)
(defvar *nodes*)
;; Compile-time emission contexts only. Neither changes the runtime protocol.
(defvar *direct-region* nil)
(defvar *native-functions* nil)

;; Only these fixed CL entry points are known not to invoke user callbacks or
;; transfer control. Other calls always go through the runtime dispatcher.
;; "Pure" here means free of control effects, not free of mutation or I/O.
(defparameter *direct-functions*
  '(+ - * / 1+ 1- = /= < > <= >= zerop plusp minusp oddp evenp
    abs signum max min mod rem floor ceiling truncate round ffloor fceiling
    ftruncate fround numerator denominator rational rationalize float
    exp expt log sqrt isqrt sin cos tan asin acos atan sinh cosh tanh
    ash logand logior logxor lognot logbitp logcount integer-length
    not null eq eql equal equalp identity values values-list
    cons car cdr caar cadr cdar cddr caaar caadr cadar caddr cdaar cdadr
    cddar cdddr first second third fourth fifth sixth seventh eighth ninth
    tenth rest list list* append reverse nreverse copy-list copy-tree
    last nth nthcdr butlast nbutlast length list-length endp
    atom consp listp symbolp keywordp numberp integerp rationalp realp
    floatp complexp characterp stringp vectorp arrayp functionp
    char char-code code-char char= char/= char< char> char<= char>=
    string= string/= string< string> string<= string>= string-equal
    string-upcase string-downcase string-capitalize string-trim
    concatenate subseq elt aref row-major-aref svref bit sbit
    array-dimensions array-dimension array-rank array-total-size
    make-array make-string make-list vector coerce
    symbol-name symbol-package symbol-value symbol-function boundp fboundp
    fdefinition makunbound fmakunbound get getf remprop
    gethash remhash clrhash hash-table-count make-hash-table
    rplaca rplacd set char-name name-char
    (setf car) (setf cdr) (setf nth) (setf get) (setf getf)
    (setf aref) (setf row-major-aref) (setf svref) (setf elt)
    (setf char) (setf bit) (setf sbit) (setf gethash)
    (setf symbol-value) (setf symbol-function) (setf fdefinition)))

(defun new-effect (&optional impure deps)
  (let ((e (make-effect :impure impure :dependencies deps)))
    (push e *effects*) e))
(defun node (op args &optional impure deps)
  (let ((n (%ir op args (new-effect impure deps)))) (push n *nodes*) n))
(defun child-effects (nodes) (mapcar #'ir-effect nodes))
(defun seq-node (nodes) (node :progn nodes nil (child-effects nodes)))
(defun reject (form reason) (error 'unsupported-form :form form :reason reason))
(defun solve-effects ()
  ;; Least fixed point of monotone inequalities p < i. Function bodies feed
  ;; latent effects, including recursive LABELS SCCs. Unknown callees start i.
  (loop for changed = nil
        do (dolist (e *effects*)
             (when (and (not (effect-impure e))
                        (some #'effect-impure (effect-dependencies e)))
               (setf (effect-impure e) t changed t)))
        while changed))
(defun directp (n)
  (and (eq *transformation-mode* :selective)
       (not (effect-impure (ir-effect n)))))

(defun copy-ctx (c) (copy-context c))
(defun declarations-and-body (body &optional docp)
  (when (and docp (stringp (car body)) (cdr body)) (setf body (cdr body)))
  (let ((decls nil))
    (loop while (and (consp (car body)) (eq (caar body) 'declare))
          do (setf decls (append decls (cdar body)) body (cdr body)))
    (values decls body)))
(defun declared-context (c decls &optional names functions)
  (let ((out (copy-ctx c)))
    (setf (context-env out)
          (sb-ext:without-package-locks
            (sb-cltl2:augment-environment (context-env c) :variable names
                                       :function functions
                                       :declare (append
                                                 (when (some (lambda (name)
                                                               (eq :special (sb-cltl2:variable-information name nil))) names)
                                                   (list `(special ,@(remove-if-not
                                                                      (lambda (name)
                                                                        (eq :special (sb-cltl2:variable-information name nil))) names))))
                                                 (remove-if-not (lambda (d) (eq (car d) 'special)) decls))))
          (context-specials out)
          (append (loop for d in decls when (eq (car d) 'special) append (cdr d))
                  (context-specials c)))
    out))
(defun special-variable-p (name c)
  (or (member name (context-specials c))
      ;; AUGMENT-ENVIRONMENT's provisional variable entries are lexical; a
      ;; global SPECIAL proclamation nevertheless applies to every CL binding.
      (eq :special (sb-cltl2:variable-information name nil))
      (eq :special (sb-cltl2:variable-information name (context-env c)))))
(defun bind-variable (name c)
  (unless (and (symbolp name) (not (constantp name (context-env c))))
    (reject name "Illegal binding variable."))
  (let ((v (make-var-info :name name :native (gensym (symbol-name name))
                          :specialp (special-variable-p name c))))
    (push (cons name v) (context-vars c)) v))
(defun var-node (name c)
  (let ((v (cdr (assoc name (context-vars c)))))
    (cond ((and v (not (member name (context-specials c)))) (node :var (list v)))
          ((or (and v (var-info-specialp v)) (special-variable-p name c))
           (node :special-var (list name)))
          (v (node :var (list v)))
          (t (node :host-var (list name))))))
(defun variable-form (v)
  (if (var-info-specialp v) `(symbol-value ',(var-info-name v)) (var-info-native v)))
(defun normalize-seq (forms c) (seq-node (mapcar (lambda (x) (normalize x c)) forms)))

(defun declared-node (n c decls)
  (if decls (node :locally (list decls c n) nil (list (ir-effect n))) n))

(defun emit-declarations (decls c)
  (labels ((variable (name)
             (let ((v (cdr (assoc name (context-vars c)))))
               (if v (unless (var-info-specialp v) (var-info-native v))
                   (unless (special-variable-p name c) name))))
           (function-name (name)
             (let ((f (cdr (assoc name (context-funcs c) :test #'equal))))
               (if f (cdr (assoc f *native-functions*)) name))))
    (loop for d in decls append
      (case (car d)
        (type (let ((names (remove nil (mapcar #'variable (cddr d)))))
                (when names (list `(type ,(cadr d) ,@names)))))
        (optimize (list d))
        ((ftype inline notinline)
         (let* ((typed (eq (car d) 'ftype))
                (names (remove nil (mapcar #'function-name (if typed (cddr d) (cdr d))))))
           (when names (list (if typed `(ftype ,(cadr d) ,@names)
                                `(,(car d) ,@names))))))
        ;; SPECIAL is already implemented by virtual bindings. Extent and
        ;; implementation-specific declarations are deliberately not copied.
        (otherwise nil)))))

(defun normalize-let (form c sequentialp)
  (destructuring-bind (op bindings &rest body) form
    (declare (ignore op))
    (multiple-value-bind (decls forms) (declarations-and-body body)
      (if sequentialp
          (labels ((walk (bs cc)
                     (if (null bs)
                         (declared-node (normalize-seq forms (declared-context cc decls)) cc decls)
                         (let* ((b (car bs)) (name (if (consp b) (car b) b))
                                (init (normalize (if (consp b) (cadr b) nil) cc))
                                (inner (declared-context cc
                                         (loop for d in decls
                                               when (and (eq (car d) 'special)
                                                         (member name (cdr d)))
                                                 collect `(special ,name)) (list name)))
                                (v (bind-variable name inner))
                                (rest (walk (cdr bs) inner)))
                           (node :let (list (list (list v init)) rest)
                                 (var-info-specialp v)
                                 (list (ir-effect init) (ir-effect rest)))))))
            (walk bindings c))
          (let* ((names (mapcar (lambda (b) (if (consp b) (car b) b)) bindings))
                 (inner (declared-context c decls names))
                 (pairs (mapcar (lambda (b)
                                  (list (bind-variable (if (consp b) (car b) b) inner)
                                        (normalize (if (consp b) (cadr b) nil) c))) bindings))
                 (result (declared-node (normalize-seq forms inner) inner decls)))
            (unless (= (length names) (length (remove-duplicates names)))
              (reject form "Duplicate LET binding."))
            (node :let (list pairs result) (some (lambda (p) (var-info-specialp (car p))) pairs)
                  (cons (ir-effect result) (child-effects (mapcar #'cadr pairs)))))))))

(defun normalize-lambda (expression c &optional name)
  (destructuring-bind (lambda-symbol lambda-list &rest body) expression
    (declare (ignore lambda-symbol))
    (multiple-value-bind (decls forms) (declarations-and-body body t)
      (let ((cc (copy-ctx c)) (raw-list nil) (bindings nil) (mode :required)
            (key-seen nil) (all-specials nil))
        (incf (context-control-depth cc))
        ;; Parsing/arity/keyword checking is delegated to an ordinary native
        ;; lambda. Every initform is then evaluated in CPS, in specified order.
        (labels ((add (source init raw)
                   (let* ((inner (declared-context cc
                                   (loop for d in decls
                                         when (and (eq (car d) 'special) (member source (cdr d)))
                                           collect `(special ,source)) (list source)))
                          (v (bind-variable source inner)))
                     (push (list v init raw) bindings)
                     (when (var-info-specialp v) (push v all-specials))
                     (setf cc inner)))
                 (raw-node (sym) (node :raw (list sym))))
          (dolist (spec lambda-list)
            (cond ((member spec '(&optional &key &aux))
                   (when (eq spec '&key) (setf key-seen t))
                   (setf mode (ecase spec (&optional :optional) (&key :key) (&aux :aux)))
                   (unless (eq spec '&aux) (push spec raw-list)))
                  ((eq spec '&rest) (setf mode :rest) (push spec raw-list))
                  ((eq spec '&allow-other-keys)
                   (unless key-seen (reject expression "&ALLOW-OTHER-KEYS without &KEY."))
                   (push spec raw-list))
                  ((member spec lambda-list-keywords) (reject expression "Unsupported ordinary lambda-list marker."))
                  (t
                   (let* ((s (if (consp spec) spec (list spec)))
                          (head (car s))
                          (source (if (and (eq mode :key) (consp head)) (cadr head) head))
                          (raw (gensym "ARG")) (sup (gensym "SUPPLIED"))
                          (init (when (member mode '(:optional :key :aux))
                                  (normalize (cadr s) cc))))
                     (ecase mode
                       (:required
                        (when (consp spec) (reject expression "Malformed required argument."))
                        (push raw raw-list) (add source (raw-node raw) raw))
                       (:rest
                        (when (consp spec) (reject expression "Malformed &REST argument."))
                        (push raw raw-list) (add source (raw-node raw) raw)
                        (setf mode :after-rest))
                       (:after-rest (reject expression "Only &KEY or &AUX may follow &REST variable."))
                       ((:optional :key)
                        (push (list (if (eq mode :key)
                                        (list (if (consp head) (car head)
                                                  (intern (symbol-name source) :keyword)) raw)
                                        raw) nil sup) raw-list)
                        (let ((choice (node :if (list (raw-node sup) (raw-node raw) init)
                                            nil (list (ir-effect init)))))
                          (add source choice raw))
                        (when (caddr s) (add (caddr s) (raw-node sup) sup)))
                       (:aux (add source init nil)))))))
          (when (eq mode :rest) (reject expression "Missing &REST variable."))
          (setf cc (declared-context cc decls))
          (let* ((result (if name (normalize `(block ,(if (consp name) (cadr name) name) ,@forms) cc)
                             (normalize-seq forms cc)))
                 (result (declared-node result cc decls))
                 (deps (cons (ir-effect result)
                             (child-effects (mapcar #'cadr bindings))))
                 (latent (new-effect (not (null all-specials)) deps)))
            (node :lambda (list (nreverse raw-list) (nreverse bindings) result latent)
                  nil nil)))))))

(defun normalize-local-functions (form c)
  (destructuring-bind (op definitions &rest body) form
    (let* ((names (mapcar #'car definitions))
           (inner (declared-context c nil nil (remove-if-not #'symbolp names)))
           (infos (mapcar (lambda (name)
                            (make-fun-info :name name :native (gensym "FUN")
                                           :effect (new-effect))) names)))
      (loop for name in names for info in infos do (push (cons name info) (context-funcs inner)))
      (loop for def in definitions for info in infos
            do (let ((lam (normalize-lambda `(lambda ,(cadr def) ,@(cddr def))
                                           (if (eq op 'labels) inner c) (car def))))
                 (setf (fun-info-lambda info) lam
                       (effect-dependencies (fun-info-effect info))
                       (list (fourth (ir-args lam))))))
      (multiple-value-bind (decls forms) (declarations-and-body body)
        (let ((result (declared-node (normalize-seq forms (declared-context inner decls)) inner decls)))
          (node :functions (list infos result op) nil (list (ir-effect result))))))))

(defun normalize (form c)
  ;; Recognize operators before macroexpansion: in particular SHIFT, RESET,
  ;; MULTIPLE-VALUE-*, and dynamic constructs are semantic compiler forms.
  (cond
    ((symbolp form)
     (multiple-value-bind (exp expanded) (macroexpand-1 form (context-env c))
       (if expanded (normalize exp c)
           (if (constantp form (context-env c)) (node :literal (list form)) (var-node form c)))))
    ((atom form) (node :literal (list form)))
    ((eq (car form) 'quote) (node :quote (list (cadr form))))
    ((eq (car form) 'function)
     (let ((f (cadr form)))
       (cond ((and (consp f) (eq (car f) 'lambda)) (normalize-lambda f c))
             ((cdr (assoc f (context-funcs c) :test #'equal))
              (node :fref (list (cdr (assoc f (context-funcs c) :test #'equal)))))
             (t (node :global-function (list f))))))
    ((eq (car form) 'lambda) (normalize `(function ,form) c))
    ((eq (car form) 'reset)
     ;; RESET seals its body's control effect, as in the paper's reset rule.
     (let ((inner (copy-ctx c)))
       (incf (context-control-depth inner))
       (let ((b (normalize-seq (cdr form) inner))) (node :reset (list b)))))
    ((eq (car form) 'with-cps) (normalize-seq (cdr form) c))
    ((eq (car form) 'shift)
     (unless (and (cdr form) (symbolp (cadr form))) (reject form "SHIFT needs a variable."))
     (multiple-value-bind (decls forms) (declarations-and-body (cddr form))
       (let* ((inner (declared-context c decls (list (cadr form))))
              (v (bind-variable (cadr form) inner)) (b (normalize-seq forms inner)))
         (node :shift (list v b) t))))
    ((eq (car form) 'dynamic-wind)
     (unless (= (length form) 4) (reject form "DYNAMIC-WIND needs three function values."))
     (node :wind (mapcar (lambda (x) (normalize x c)) (cdr form)) t))
    ((eq (car form) 'progn) (normalize-seq (cdr form) c))
    ((eq (car form) 'if)
     (unless (<= 3 (length form) 4) (reject form "Malformed IF."))
     (let ((ns (mapcar (lambda (x) (normalize x c)) (list (cadr form) (caddr form) (cadddr form)))))
       (node :if ns nil (child-effects ns))))
    ((member (car form) '(let let*)) (normalize-let form c (eq (car form) 'let*)))
    ((member (car form) '(flet labels)) (normalize-local-functions form c))
    ((eq (car form) 'setq)
     (when (oddp (length (cdr form))) (reject form "Odd SETQ argument count."))
     (normalize-seq
      ;; Expand assignment to symbol macros as SETF before normalizing RHS.
      (loop for (v value) on (cdr form) by #'cddr
            collect (multiple-value-bind (exp expanded) (macroexpand-1 v (context-env c))
                      (if expanded `(setf ,exp ,value) `(%assignment ,v ,value)))) c))
    ((eq (car form) '%assignment)
     (let ((v (var-node (cadr form) c)) (value (normalize (caddr form) c)))
       (node :setq (list v value) nil (list (ir-effect value)))))
    ((eq (car form) 'block)
     (let* ((target (make-target-info :name (cadr form) :token (gensym "BLOCK")
                                      :effect (new-effect) :depth (context-control-depth c)))
            (inner (copy-ctx c)))
       (push (cons (cadr form) target) (context-blocks inner))
       (let ((b (normalize-seq (cddr form) inner)))
         (if (target-info-used target)
             (let ((n (node :block (list target b) nil
                            (list (target-info-effect target) (ir-effect b)))))
               (setf (effect-dependencies (target-info-effect target)) (list (ir-effect n)))
               n)
             b))))
    ((eq (car form) 'return-from)
     (let ((target (cdr (assoc (cadr form) (context-blocks c)))))
       (unless target (reject form "No lexically visible block. Put the BLOCK inside the transformed region."))
       (setf (target-info-used target) t)
       (unless (= (context-control-depth c) (target-info-depth target))
         (setf (effect-impure (target-info-effect target)) t))
       (let ((value (normalize (caddr form) c)))
         (node :return (list target value) nil
               (list (target-info-effect target) (ir-effect value))))))
    ((eq (car form) 'tagbody)
     (let* ((target (make-target-info :token (gensym "TAGBODY")
                                      :effect (new-effect) :depth (context-control-depth c)))
            (inner (copy-ctx c)) (groups (list nil)) (tags nil) (index 0))
       (dolist (x (cdr form))
         (if (atom x)
             (progn
               (unless (or (symbolp x) (integerp x)) (reject form "Invalid GO tag."))
               (when (assoc x tags) (reject form "Duplicate GO tag."))
               (incf index) (push (cons x index) tags) (push nil groups))
             (push x (car groups))))
       (dolist (tag tags)
         (push (list (car tag) target (cdr tag)) (context-tags inner)))
       (let* ((bodies (mapcar (lambda (g) (normalize-seq (nreverse g) inner))
                             (nreverse groups)))
              (n (node :tagbody (list target bodies) nil
                       (cons (target-info-effect target) (child-effects bodies)))))
         (setf (target-info-native-tags target)
               (mapcar (lambda (g) (declare (ignore g)) (gensym "GO")) bodies)
               (effect-dependencies (target-info-effect target)) (list (ir-effect n)))
         n)))
    ((eq (car form) 'go)
     (let* ((tag (assoc (cadr form) (context-tags c))) (target (cadr tag)))
       (unless tag (reject form "No lexically visible GO tag."))
       ;; Cross-lambda/reset jumps retain explicit dynamic target checks.
       (unless (= (context-control-depth c) (target-info-depth target))
         (setf (effect-impure (target-info-effect target)) t))
       (node :go (cdr tag) nil (list (target-info-effect target)))))
    ((eq (car form) 'catch)
     (node :catch (list (normalize (cadr form) c) (normalize-seq (cddr form) c)) t))
    ((eq (car form) 'throw)
     (node :throw (list (normalize (cadr form) c) (normalize (caddr form) c)) t))
    ((eq (car form) 'unwind-protect)
     (node :cleanup (list (normalize (cadr form) c) (normalize-seq (cddr form) c)) t))
    ((eq (car form) 'progv)
     (node :progv (list (normalize (cadr form) c) (normalize (caddr form) c)
                        (normalize-seq (cdddr form) c)) t))
    ((eq (car form) 'multiple-value-call)
     (node :mv-call (mapcar (lambda (x) (normalize x c)) (cdr form)) t))
    ((eq (car form) 'multiple-value-prog1)
     (let ((first (normalize (cadr form) c)) (rest (normalize-seq (cddr form) c)))
       (node :mv-prog1 (list first rest) nil (list (ir-effect first) (ir-effect rest)))))
    ((eq (car form) 'the)
     (let ((n (normalize (caddr form) c))) (node :the (list (cadr form) n) nil (list (ir-effect n)))))
    ((eq (car form) 'locally)
     (multiple-value-bind (decls body) (declarations-and-body (cdr form))
       (let ((inner (declared-context c decls)))
         (declared-node (normalize-seq body inner) inner decls))))
    ((eq (car form) 'symbol-macrolet)
     (let ((inner (copy-ctx c)))
       (setf (context-env inner)
             (sb-cltl2:augment-environment (context-env c) :symbol-macro (cadr form)))
       (normalize `(locally ,@(cddr form)) inner)))
    ((eq (car form) 'macrolet)
     (let* ((inner (copy-ctx c))
            (macros (mapcar (lambda (def)
                              (list (car def)
                                    (sb-cltl2:enclose
                                     (sb-cltl2:parse-macro (car def) (cadr def) (cddr def)
                                                           (context-env c))
                                     (context-env c)))) (cadr form))))
       (setf (context-env inner) (sb-cltl2:augment-environment (context-env c) :macro macros))
       (normalize `(locally ,@(cddr form)) inner)))
    ((eq (car form) 'eval-when)
     (normalize-seq (when (intersection (cadr form) '(:execute eval)) (cddr form)) c))
    ((eq (car form) 'load-time-value) (node :host (list form)))
    (t
     (multiple-value-bind (exp expanded) (macroexpand-1 form (context-env c))
       (cond (expanded (normalize exp c))
             ((and (symbolp (car form)) (special-operator-p (car form)))
              (reject form "Unknown compiler special operator; refusing an unsound expansion."))
             (t
              (let* ((operator (car form))
                     (local (cdr (assoc operator (context-funcs c) :test #'equal)))
                     (direct (and (not local) (member operator *direct-functions* :test #'equal)
                                  (not (nth-value 1 (sb-cltl2:function-information operator (context-env c))))))
                     (callee (normalize `(function ,operator) c))
                     (args (mapcar (lambda (x) (normalize x c)) (cdr form))))
                (node :call (list callee args direct local)
                      (not (or direct local))
                      (append (child-effects args) (list (ir-effect callee))
                              (when local (list (fun-info-effect local))))))))))))

(defun emit-direct (n)
  ;; A guard encloses the maximal directly executed region, not each primitive.
  ;; Lambda bodies establish their own region because closures may escape.
  (if (or *direct-region*
          (member (ir-op n) '(:literal :quote :var :host-var :raw :host
                              :special-var :global-function :fref :lambda :reset)))
      (emit-direct-body n)
      (let ((*direct-region* t))
        `(let ((*native-call* t)) ,(emit-direct-body n)))))

(defun emit-direct-body (n)
  (let ((a (ir-args n)))
    (case (ir-op n)
      ((:literal :host-var :raw :host) (car a))
      (:quote `(quote ,(car a)))
      (:var (variable-form (car a)))
      (:special-var `(symbol-value ',(car a)))
      (:global-function `(function ,(car a)))
      (:fref (let ((name (cdr (assoc (car a) *native-functions*))))
               (if name `(function ,name) (fun-info-native (car a)))))
      (:lambda (emit-lambda n))
      (:reset
       (if (directp (car a)) (emit-direct (car a))
           (let ((root (gensym "ROOT")) (prompt (gensym "PROMPT")))
             `(run (lambda (,root)
                     (let ((,prompt (frame :prompt nil ,root))) ,(let ((*direct-region* nil)) (emit-cps (car a) prompt))))))))
      (:block `(block ,(target-info-token (car a)) ,(emit-direct (cadr a))))
      (:return `(return-from ,(target-info-token (car a)) ,(emit-direct (cadr a))))
      (:tagbody
       `(tagbody ,@(loop for label in (target-info-native-tags (car a))
                        for body in (cadr a) append (list label (emit-direct body)))))
      (:go `(go ,(nth (cadr a) (target-info-native-tags (car a)))))
      (:progn `(progn ,@(mapcar #'emit-direct a)))
      (:if `(if ,@(mapcar #'emit-direct a)))
      (:let
       `(let ,(mapcar (lambda (p) (list (var-info-native (car p)) (emit-direct (cadr p)))) (car a))
          (declare (ignorable ,@(mapcar (lambda (p) (var-info-native (car p))) (car a))))
          ,(emit-direct (cadr a))))
      (:setq `(setf ,(emit-direct (car a)) ,(emit-direct (cadr a))))
      (:call `(funcall ,(emit-direct (car a)) ,@(mapcar #'emit-direct (cadr a))))
      (:functions (emit-functions n (lambda (body) (emit-direct body))))
      (:locally `(locally (declare ,@(emit-declarations (car a) (cadr a)))
                    ,(emit-direct (caddr a))))
      (:mv-prog1 `(multiple-value-prog1 ,(emit-direct (car a)) ,(emit-direct (cadr a))))
      (:the `(the ,(car a) ,(emit-direct (cadr a))))
      (otherwise (error "No direct emitter for ~S" (ir-op n))))))

(defun emit-functions (n emit-body)
  (destructuring-bind (infos body kind) (ir-args n)
    (if (and (eq *transformation-mode* :selective)
             (every (lambda (f) (not (effect-impure (fun-info-effect f)))) infos))
        (let* ((outer *native-functions*)
               (entries (mapcar (lambda (f) (cons f (fun-info-native f))) infos)))
          `(,kind
            ,(mapcar (lambda (f)
                       (let* ((*native-functions* (if (eq kind 'labels)
                                                     (append entries outer) outer))
                              (lam (emit-lambda (fun-info-lambda f))))
                         `(,(fun-info-native f) ,@(cdr lam)))) infos)
            ,(let ((*native-functions* (append entries outer)))
               (funcall emit-body body))))
        `(let ,(mapcar (lambda (f) (list (fun-info-native f) nil)) infos)
           (declare (ignorable ,@(mapcar #'fun-info-native infos)))
           ,@(mapcar (lambda (f) `(setf ,(fun-info-native f)
                                       ,(emit-lambda (fun-info-lambda f)))) infos)
           ,(funcall emit-body body)))))

(defun emit-bind (n k receiver)
  (let ((vs (gensym "VALUES")) (next (gensym "NEXT")) (stack (gensym "BIND")))
    `(let ((,stack (frame :bind (lambda (,vs ,next) ,(funcall receiver vs next)) ,k)))
       ,(emit-cps n stack))))
(defun emit-single (n k receiver)
  (if (directp n)
      (let ((v (gensym "VALUE")))
        `(bounce ,k (lambda () (let ((,v ,(emit-direct n))) ,(funcall receiver v k)))))
      (emit-bind n k (lambda (vs next) (funcall receiver `(car ,vs) next)))))
(defun emit-singles (nodes k receiver &optional acc)
  (cond ((null nodes) (funcall receiver (reverse acc) k))
        ((directp (car nodes))
         ;; A maximal direct prefix needs neither continuation frames nor value
         ;; lists. One scheduled step establishes the correct dynamic bindings.
         (let ((bindings nil) (rest nodes) (values acc))
           (loop while (and rest (directp (car rest)))
                 do (let ((v (gensym "VALUE")))
                      (push (list v (emit-direct (pop rest))) bindings)
                      (push v values)))
           `(bounce ,k (lambda ()
                         (let* ,(nreverse bindings)
                           ,(emit-singles rest k receiver values))))))
        (t (emit-single (car nodes) k
                        (lambda (v next)
                          (let ((x (gensym "VALUE")))
                            `(let ((,x ,v))
                               ,(emit-singles (cdr nodes) next receiver (cons x acc)))))))))
(defun emit-sequence (nodes k)
  (cond ((null nodes) `(deliver (list nil) ,k))
        ((null (cdr nodes)) (emit-cps (car nodes) k))
        ((directp (car nodes))
         (let ((prefix nil) (rest nodes))
           (loop while (and rest (directp (car rest)))
                 do (push (emit-direct (pop rest)) prefix))
           `(bounce ,k (lambda () (progn ,@(nreverse prefix) ,(emit-sequence rest k))))))
        (t (emit-bind (car nodes) k
                      (lambda (ignored next)
                        `(progn ,ignored ,(emit-sequence (cdr nodes) next)))))))

(defun emit-variable-bindings (pairs values k body)
  (let ((lex nil) (symbols nil) (specials nil))
    (loop for pair in pairs for value in values for v = (car pair)
          do (if (var-info-specialp v)
                 (progn (push (var-info-name v) symbols) (push value specials))
                 (push (list (var-info-native v) value) lex)))
    `(let ,(nreverse lex)
       ,@(when lex `((declare (ignorable ,@(mapcar #'car lex)))))
       ,(if specials
            (let ((next (gensym "DYNAMIC")))
              `(push-specials ',(nreverse symbols) (list ,@(nreverse specials)) ,k
                              (lambda (,next) ,(funcall body next))))
            (funcall body k)))))

(defun emit-lambda (n)
  (let ((*direct-region* nil))
  (destructuring-bind (raw-list bindings body latent) (ir-args n)
    (labels ((init-cps (bindings k)
               (if (null bindings) (emit-cps body k)
                   (let ((p (car bindings)))
                     (emit-single (cadr p) k
                                  (lambda (v next)
                                    (emit-variable-bindings
                                     (list p) (list v) next
                                     (lambda (k) (init-cps (cdr bindings) k))))))))
             (init-direct (bindings)
               (if (null bindings) (emit-direct body)
                   `(let ((,(var-info-native (caar bindings)) ,(emit-direct (cadar bindings))))
                      (declare (ignorable ,(var-info-native (caar bindings))))
                      ,(init-direct (cdr bindings))))))
      (if (and (eq *transformation-mode* :selective) (not (effect-impure latent)))
          `(lambda ,raw-list ,(let ((*direct-region* nil)) (init-direct bindings)))
          (let ((k (gensym "K")) (args (gensym "ARGS")))
            `(make-cps-function
              (lambda (,k &rest ,args)
                (bounce ,k (lambda ()
                             (apply (lambda ,raw-list ,(init-cps bindings k)) ,args))))))))))
)

(defun emit-cps (n k)
  (if (directp n)
      `(bounce ,k (lambda () (deliver (multiple-value-list ,(emit-direct n)) ,k)))
      (let ((a (ir-args n)))
        (case (ir-op n)
          ((:literal :quote :var :host-var :raw :host :special-var :global-function :fref :lambda)
           `(bounce ,k (lambda () (deliver (multiple-value-list ,(emit-direct n)) ,k))))
          (:locally `(locally (declare ,@(emit-declarations (car a) (cadr a)))
                        ,(emit-cps (caddr a) k)))
          (:progn (emit-sequence a k))
          (:if (emit-single (car a) k
                            (lambda (v next) `(if ,v ,(emit-cps (cadr a) next) ,(emit-cps (caddr a) next)))))
          (:let (emit-singles (mapcar #'cadr (car a)) k
                              (lambda (vs next)
                                (emit-variable-bindings (car a) vs next (lambda (k) (emit-cps (cadr a) k))))))
          (:setq (emit-single (cadr a) k
                               (lambda (v next) `(deliver (list (setf ,(emit-direct (car a)) ,v)) ,next))))
          (:call
           (if (and (eq (ir-op (car a)) :global-function)
                    (eq (car (ir-args (car a))) 'funcall))
               ;; FUNCALL is a fixed CL primitive, so avoid redispatch through
               ;; its adapter and evaluating its function object as an operand.
               (emit-singles (cadr a) k
                             (lambda (vs next) `(invoke ,(car vs) ,next (list ,@(cdr vs)))))
               (emit-singles (cons (car a) (cadr a)) k
                             (lambda (vs next)
                               (if (caddr a)
                                   `(bounce ,next
                                      (lambda ()
                                        (let ((*native-call* t))
                                          (deliver (multiple-value-list
                                                    (funcall ,(car vs) ,@(cdr vs))) ,next))))
                                   `(invoke ,(car vs) ,next (list ,@(cdr vs))))))))
          (:functions
           `(bounce ,k (lambda ()
                          ,(emit-functions n (lambda (body) (emit-cps body k))))))
          (:reset
           (let ((prompt (gensym "PROMPT")))
             `(let ((,prompt (frame :prompt nil ,k))) ,(emit-cps (car a) prompt))))
          (:shift
           (let ((captured (gensym "CAPTURED")) (prompt (gensym "PROMPT")))
             `(bounce ,k
                (lambda ()
                  (perform-shift
                   (lambda (,captured ,prompt)
                     ,(emit-variable-bindings (list (list (car a))) (list captured) prompt
                                              (lambda (k) (emit-cps (cadr a) k)))) ,k)))))
          (:block
           (let ((next (gensym "BLOCK-K")) (target (car a)))
             `(let* ((,(target-info-token target) (list nil))
                     (,next (frame :block ,(target-info-token target) ,k)))
                ,(emit-cps (cadr a) next))))
          (:return
           (emit-bind (cadr a) k
                      (lambda (vs next)
                        `(bounce ,next (lambda () (control-return :block ,(target-info-token (car a)) ,vs))))))
          (:tagbody
           (let* ((target (car a)) (groups (cadr a))
                  (names (mapcar (lambda (x) (declare (ignore x)) (gensym "TAG")) groups))
                  (arg (gensym "TAG-K")) (stack (gensym "TAGS")))
             `(let ((,(target-info-token target) (list nil)))
                (labels ,(loop for g in groups for tail on names
                               collect `(,(car tail) (,arg)
                                         ,(emit-bind g arg
                                                      (lambda (ignored next)
                                                        `(progn ,ignored
                                                                ,(if (cdr tail) `(,(cadr tail) ,next)
                                                                     `(deliver (list nil) ,next)))))))
                  (let ((,stack (frame :tagbody
                                      (list ,(target-info-token target) ,@(mapcar (lambda (x) `#',x) names)) ,k)))
                    (,(car names) ,stack))))))
          (:go `(bounce ,k (lambda () (control-go ,(target-info-token (car a)) ,(cadr a)))))
          (:catch (emit-single (car a) k
                                (lambda (tag next)
                                  (let ((stack (gensym "CATCH")))
                                    `(let ((,stack (frame :catch ,tag ,next))) ,(emit-cps (cadr a) stack))))))
          (:throw
           (emit-single (car a) k
                        (lambda (tag next)
                          (let ((name (gensym "THROW-TAG")))
                            `(let ((,name ,tag))
                               ,(emit-bind (cadr a) next
                                           (lambda (vs next)
                                             `(bounce ,next (lambda () (control-return :catch ,name ,vs))))))))))
          (:cleanup
           (let ((next (gensym "CLEANUP-K")) (stack (gensym "PROTECTED")))
             `(let ((,stack (frame :cleanup (lambda (,next) ,(emit-cps (cadr a) next)) ,k)))
                ,(emit-cps (car a) stack))))
          (:progv
           (emit-singles (subseq a 0 2) k
                         (lambda (vs next)
                           (let ((stack (gensym "PROGV")))
                             `(push-specials ,(car vs) ,(cadr vs) ,next
                                             (lambda (,stack) ,(emit-cps (caddr a) stack)))))))
          (:mv-call
           (emit-single (car a) k
                        (lambda (f next)
                          (let ((function (gensym "FUNCTION")))
                            (labels ((args (ns k acc)
                                       (if (null ns) `(invoke ,function ,k (append ,@(reverse acc)))
                                           (emit-bind (car ns) k
                                                      (lambda (vs next) (args (cdr ns) next (cons vs acc)))))))
                              `(let ((,function ,f)) ,(args (cdr a) next nil)))))))
          (:mv-prog1
           (emit-bind (car a) k
                      (lambda (vs next)
                        (emit-bind (cadr a) next
                                   (lambda (ignored next) `(progn ,ignored (deliver ,vs ,next)))))))
          (:the
           (emit-bind (cadr a) k
                      (lambda (vs next) `(deliver (multiple-value-list (the ,(car a) (values-list ,vs))) ,next))))
          (:wind
           (emit-singles a k
                         (lambda (vs next)
                           (let ((stack (gensym "WIND-K")) (ignored (gensym "IGNORED"))
                                 (tail (gensym "NEXT")))
                             `(invoke ,(car vs)
                                      (frame :bind
                                             (lambda (,ignored ,tail)
                                               (declare (ignore ,ignored))
                                               (let ((,stack (frame :wind (cons ,(car vs) ,(caddr vs)) ,tail)))
                                                 (invoke ,(cadr vs) ,stack nil))) ,next) nil)))))
          (otherwise (error "No CPS emitter for ~S" (ir-op n)))))))

(defun prepare-ir (form env)
  (let ((ctx (%context))) (setf (context-env ctx) env)
    (let ((n (normalize form ctx))) (solve-effects) n)))
(defun transform (form &optional environment (mode *transformation-mode*))
  "Return ordinary Lisp implementing FORM. No implicit prompt is introduced."
  (unless (member mode '(:selective :full)) (error "Invalid transformation mode ~S" mode))
  (let ((*effects* nil) (*nodes* nil) (*transformation-mode* mode))
    (let ((n (prepare-ir form environment)) (k (gensym "ROOT")))
      (if (directp n) (emit-direct n) `(run (lambda (,k) ,(emit-cps n k)))))))
(defun analyze (form &optional environment)
  "Report conservative control effect counts (construction and latent effects differ)."
  (let ((*effects* nil) (*nodes* nil))
    (let ((n (prepare-ir form environment)))
      (list :effect (if (effect-impure (ir-effect n)) :cps :direct)
            :nodes (length *nodes*)
            :direct-nodes (count-if-not (lambda (n) (effect-impure (ir-effect n))) *nodes*)
            :cps-nodes (count-if (lambda (n) (effect-impure (ir-effect n))) *nodes*)))))
(defmacro with-cps (&body body &environment env) (transform `(progn ,@body) env))
(defmacro reset (&body body &environment env) (transform `(reset ,@body) env))
(defmacro lambda/cps (lambda-list &body body &environment env)
  (let ((*effects* nil) (*nodes* nil))
    (let ((ctx (%context)))
      (setf (context-env ctx) env)
      (let ((n (normalize-lambda `(lambda ,lambda-list ,@body) ctx)))
        (solve-effects) (emit-lambda n)))))
(defmacro defun/cps (name lambda-list &body body &environment env)
  (let ((*effects* nil) (*nodes* nil))
    (let ((ctx (%context)))
      (setf (context-env ctx) env)
      (let ((n (normalize-lambda `(lambda ,lambda-list ,@body) ctx name)))
        (solve-effects)
        `(progn (declaim (ftype function ,name))
                (setf (fdefinition ',name) ,(emit-lambda n)) ',name)))))
