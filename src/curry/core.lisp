;;;; ANSI Common Lisp automatic partial application. No dependencies.
(uiop:define-package #:ooparts/curry/core
  (:use #:cl)
  (:export #:defun/c #:flet/c #:labels/c #:lambda/c
           #:defgeneric/c #:defmethod/c #:defclass/c #:defstruct/c #:define-condition/c
           #:uncurried-function #:curry))
(in-package #:ooparts/curry/core)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun %proper-list-p (object)
    (or (null object)
        (and (consp object)
             (handler-case (not (null (list-length object)))
               (type-error () nil)))))

  (defun %require-list (object description)
    (unless (%proper-list-p object)
      (error "~A must be a finite proper list." description))
    object)

  (defun %function-name-p (name)
    (or (symbolp name)
        (and (%proper-list-p name) (= (length name) 2)
             (eq (first name) 'setf) (symbolp (second name)))))

  (defun %required-count (lambda-list environment)
    (%require-list lambda-list "Lambda list")
    (let ((state :required) (required 0) (variables nil)
          (optional-seen nil) (rest-seen nil) (key-seen nil)
          (allow-seen nil) (aux-seen nil))
      (labels ((variable (name)
                 (unless (and (symbolp name)
                              (or (not (constantp name environment))
                                  (nth-value 1 (macroexpand-1 name environment)))
                              (not (member name lambda-list-keywords)))
                   (error "Invalid parameter variable: ~S" name))
                 (when (member name variables)
                   (error "Duplicate parameter variable: ~S" name))
                 (push name variables))
               (parameter (spec max-length keywordp)
                 (if (symbolp spec) (variable spec)
                     (progn
                       (%require-list spec "Parameter specifier")
                       (unless (<= 1 (length spec) max-length)
                         (error "Invalid parameter specifier: ~S" spec))
                       (let ((head (first spec)))
                         (if (and keywordp (consp head))
                             (progn
                               (%require-list head "Keyword parameter name")
                               (unless (and (= (length head) 2) (symbolp (first head)))
                                 (error "Invalid keyword parameter name: ~S" head))
                               (variable (second head)))
                             (variable head)))
                       (when (= (length spec) 3) (variable (third spec)))))))
        (dolist (item lambda-list)
          (cond
            ((eq state :rest-variable) (variable item) (setf state :after-rest))
            ((eq item '&optional)
             (unless (and (eq state :required) (not optional-seen))
               (error "Misplaced or repeated &OPTIONAL."))
             (setf optional-seen t state :optional))
            ((eq item '&rest)
             (unless (and (member state '(:required :optional)) (not rest-seen))
               (error "Misplaced or repeated &REST."))
             (setf rest-seen t state :rest-variable))
            ((eq item '&key)
             (unless (and (member state '(:required :optional :after-rest)) (not key-seen))
               (error "Misplaced or repeated &KEY."))
             (setf key-seen t state :key))
            ((eq item '&allow-other-keys)
             (unless (and (eq state :key) (not allow-seen))
               (error "Misplaced or repeated &ALLOW-OTHER-KEYS."))
             (setf allow-seen t state :after-allow))
            ((eq item '&aux)
             (when aux-seen (error "Repeated &AUX."))
             (setf aux-seen t state :aux))
            ((member item lambda-list-keywords)
             (error "Unsupported ordinary lambda-list keyword: ~S" item))
            (t (ecase state
                 (:required (variable item) (incf required))
                 (:optional (parameter item 3 nil))
                 (:key (parameter item 3 t))
                 (:aux (parameter item 2 nil))
                 (:after-rest (error "Parameter after &REST variable."))
                 (:after-allow (error "Parameter after &ALLOW-OTHER-KEYS."))))))
        (when (eq state :rest-variable) (error "Missing &REST variable.")))
      required))

  (defun %canonical-generic-lambda-list (lambda-list)
    (let ((keyp nil))
      (mapcar
       (lambda (item)
         (cond ((eq item '&key) (setf keyp t) item)
               ((member item lambda-list-keywords) (setf keyp nil) item)
               ((and keyp (consp item) (consp (first item))
                     (keywordp (caar item)))
                ;; GF key variable names do not bind method body variables.
                ;; An implicit keyword of the same name has identical protocol,
                ;; and also works on hosts lacking explicit GF keyword aliases.
                (make-symbol (symbol-name (caar item))))
               (t item))) lambda-list)))

  (defun %generic-required-count (lambda-list environment)
    ;; Generic keyword-name pairs have the ordinary outer parameter wrapper.
    ;; Restrictions on defaults and &AUX are checked by native DEFGENERIC.
    (%required-count lambda-list environment))

  (defun %split-body (body)
    (%require-list body "Function body")
    (let ((documentation nil) (declarations nil))
      (loop
        (cond
          ((and (consp (first body)) (eq (caar body) 'declare))
           (push (pop body) declarations))
          ((and (stringp (first body)) (rest body) (null documentation))
           (setf documentation (pop body)))
          (t (return))))
      (values documentation (nreverse declarations) body)))

  (defun %definition (name lambda-list body environment namedp)
    (when (and namedp (not (%function-name-p name)))
      (error "Invalid function name: ~S" name))
    (let ((required (%required-count lambda-list environment))
          (arguments (gensym "ARGUMENTS")) (worker (gensym "WORKER")))
      (multiple-value-bind (documentation declarations forms) (%split-body body)
        (let* ((block-name (if (symbolp name) name (second name)))
               ;; &AUX initializers are outside the wrapper's implicit BLOCK.
               ;; Thus original parameter initializers see exactly the outer
               ;; blocks, while only the original body sees BLOCK-NAME.
               (implementation `(lambda ,lambda-list
                                  ,@declarations
                                  ,@(if namedp
                                        `((block ,block-name ,@forms))
                                        forms))))
          `(,name (&rest ,arguments &aux (,worker (function ,implementation)))
             ,@(when documentation (list documentation))
             (%dispatch ,worker ,required ,arguments))))))

  (defun %local-definitions (definitions environment)
    (%require-list definitions "Local definitions")
    (let ((names nil))
      (mapcar (lambda (definition)
                (%require-list definition "Local function definition")
                (unless (>= (length definition) 2)
                  (error "A local definition needs a name and lambda list."))
                (destructuring-bind (name lambda-list &rest body) definition
                  (when (member name names :test #'equal)
                    (error "Duplicate local function name: ~S" name))
                  (push name names)
                  (%definition name lambda-list body environment t)))
              definitions))))

(defun %dispatch (worker required arguments)
  ;; APPLY may share its last argument's spine with an &REST list. Snapshot
  ;; that spine so later mutation by the caller cannot alter saved arguments.
  (let ((collected (copy-list arguments)))
    (if (< (length collected) required)
        (lambda (&rest more)
          (%dispatch worker required (append collected more)))
        (apply worker collected))))

(defun curry (function required)
  "Return an automatically curried callable with an explicit required arity.
Use this for variadic functions such as + when their native minimum is zero."
  (check-type required (integer 0 *))
  (let ((target (if (functionp function) function (fdefinition function))))
    (lambda (&rest arguments) (%dispatch target required arguments))))

(defmacro defun/c (name lambda-list &body body &environment environment)
  "Like DEFUN, returning a partial application while required arguments are missing."
  `(defun ,@(%definition name lambda-list body environment t)))

(defmacro lambda/c (lambda-list &body body &environment environment)
  "Return a closure with automatic partial application of required arguments."
  `(function ,(%definition 'lambda lambda-list body environment nil)))

(defmacro flet/c (definitions &body body &environment environment)
  "Like FLET, with automatic partial application."
  `(flet ,(%local-definitions definitions environment) ,@body))

(defmacro labels/c (definitions &body body &environment environment)
  "Like LABELS, with automatic partial application and mutual recursion."
  `(labels ,(%local-definitions definitions environment) ,@body))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defvar *generated-targets* (make-hash-table :test #'equal))
  (defvar *structure-slots* (make-hash-table :test #'eq))
  (defvar *structure-bindings* (make-hash-table :test #'eq))
  (defvar *uninterned-targets* (make-hash-table :test #'eq))

  (defun %native-symbol (symbol)
    (unless (symbolp symbol) (error "Expected a function-name symbol."))
    (if (symbol-package symbol)
        (let ((package (package-name (symbol-package symbol))))
          ;; Length-prefix the package component to avoid delimiter collisions.
          (intern (format nil "%NATIVE/~D:~A/~A" (length package) package
                          (symbol-name symbol))
                  (find-package '#:ooparts/curry/core)))
        (or (gethash symbol *uninterned-targets*)
            (setf (gethash symbol *uninterned-targets*) (gensym "NATIVE-")))))

  (defun %native-name (name)
    (unless (%function-name-p name) (error "Invalid function name: ~S" name))
    (if (symbolp name) (%native-symbol name)
        `(setf ,(%native-symbol (second name)))))

  (defun %proclaim-wrappers (bindings)
    `(declaim (ftype (function (&rest t) *)
                    ,@(remove-duplicates (mapcar #'first bindings) :test #'equal))))

  (defun %install-forms (bindings)
    (mapcar (lambda (binding)
              (destructuring-bind (public native required) binding
                `(%install-generated ',public ',native ,required)))
            (remove-duplicates bindings :key #'first :test #'equal)))

  (defun %canonical-class-name (name)
  (let ((entry (gethash name *generated-targets*)))
    (if (and entry (symbolp (first entry))
             (eq (symbol-package (first entry)) (find-package :cl))
             (find-class (first entry) nil))
        (first entry) name)))


  (defun %method-parts (definition environment)
    (%require-list definition "Method definition")
    (let ((qualifiers nil) (tail definition))
      (loop while (and tail (not (listp (first tail))))
            do (push (pop tail) qualifiers))
      (unless tail (error "A method needs a specialized lambda list."))
      (let ((lambda-list (pop tail)) (ordinary nil) (non-required nil))
        (%require-list lambda-list "Specialized lambda list")
        (let ((requiredp t))
          (setf lambda-list
                (mapcar (lambda (parameter)
                          (cond
                            ((member parameter lambda-list-keywords)
                             (setf requiredp nil) parameter)
                            ((and requiredp (consp parameter)
                                  (%proper-list-p parameter) (= (length parameter) 2))
                             (let* ((specializer (second parameter))
                                    (entry (and (consp specializer)
                                                (gethash (first specializer) *generated-targets*))))
                               (list (first parameter)
                                     (cond ((and entry (eq (first entry) 'eql))
                                            (cons 'eql (rest specializer)))
                                           ((symbolp specializer) (%canonical-class-name specializer))
                                           (t specializer)))))
                            (t parameter))) lambda-list)))
        (dolist (parameter lambda-list)
          (cond
            ((member parameter lambda-list-keywords) (setf non-required t) (push parameter ordinary))
            ((or non-required (atom parameter)) (push parameter ordinary))
            (t
             (%require-list parameter "Specialized parameter")
             (unless (= (length parameter) 2)
               (error "Invalid specialized parameter: ~S" parameter))
             (push (first parameter) ordinary))))
        (values (nreverse qualifiers) lambda-list tail
                (%required-count (nreverse ordinary) environment)))))

  (defun %method-body (name body)
    (multiple-value-bind (documentation declarations forms) (%split-body body)
      `(,@(when documentation (list documentation)) ,@declarations
        (block ,(if (symbolp name) name (second name)) ,@forms))))

  (defun %class-slots (slots)
    (%require-list slots "Class slots")
    (let ((bindings nil) (rewritten nil))
      (dolist (slot slots)
        (if (symbolp slot)
            (push slot rewritten)
            (progn
              (%require-list slot "Class slot")
              (unless (oddp (length slot)) (error "Invalid class slot options."))
              (let ((options nil))
                (loop for (key value) on (rest slot) by #'cddr do
                  (case key
                    ((:reader :writer)
                     (let ((native (%native-name value)))
                       (push (list value native (if (eq key :reader) 1 2)) bindings)
                       (setf value native)))
                    (:accessor
                     (unless (and value (symbolp value))
                       (error "An accessor name must be a non-NIL symbol."))
                     (let ((native (%native-name value)))
                       (push (list value native 1) bindings)
                       (push (list `(setf ,value) `(setf ,native) 2) bindings)
                       (setf value native))))
                  (push key options)
                  (push value options))
                (push (cons (first slot) (nreverse options)) rewritten)))))
      (values (nreverse rewritten) (nreverse bindings))))

  (defun %structure-slot (description &optional inherited)
    (if (symbolp description) (list description nil)
        (progn
          (%require-list description "Structure slot")
          (unless (and description (symbolp (first description)))
            (error "Invalid structure slot."))
          (list (first description)
                (getf (cddr description) :read-only (second inherited))))))

  (defun %structure-definition (name-and-options body environment)
    (let* ((name (if (symbolp name-and-options) name-and-options
                     (first (%require-list name-and-options "Structure options"))))
           (options (if (symbolp name-and-options) nil (rest name-and-options)))
           (documentation (when (stringp (first body)) (pop body)))
           (slots (mapcar #'%structure-slot body))
           (prefix (concatenate 'string (symbol-name name) "-"))
           (native-prefix (concatenate 'string "%CURRY-STRUCT/"
                                       (symbol-name (%native-symbol name)) "/"))
           (rewritten nil) (bindings nil) (writers nil)
           (constructor-seen nil) (copier-seen nil) (predicate-seen nil)
           (typed nil) (named nil) (inherited-bindings nil))
      (labels ((default-name (prefix &optional (suffix ""))
                 (intern (concatenate 'string prefix (symbol-name name) suffix) *package*))
               (bind-function (public required)
                 (when public
                   (let ((native (%native-name public)))
                     (push (list public native required) bindings)
                     native)))
               (option (raw)
                 (let ((value (if (symbolp raw) (list raw)
                                  (%require-list raw "Structure option"))))
                   (case (first value)
                     (:conc-name (setf prefix (second value)))
                     (:constructor
                      (setf constructor-seen t)
                      (let* ((public (if (rest value) (second value)
                                         (default-name "MAKE-")))
                             (boa-p (cddr value))
                             (required (if boa-p (%required-count (third value) environment) 0))
                             (native (bind-function public required)))
                        (push (if boa-p `(:constructor ,native ,(third value))
                                  `(:constructor ,native)) rewritten)))
                     (:copier
                      (setf copier-seen t)
                      (push `(:copier ,(bind-function (if (rest value) (second value)
                                                        (default-name "COPY-")) 1)) rewritten))
                     (:predicate
                      (setf predicate-seen t)
                      (push `(:predicate ,(bind-function (if (rest value) (second value)
                                                           (default-name "" "-P")) 1)) rewritten))
                     (:include
                      (setf inherited-bindings (gethash (second value) *structure-bindings*))
                      (multiple-value-bind (inherited present) (gethash (second value) *structure-slots*)
                        (unless present
                          (error "Include requires a parent previously defined by DEFSTRUCT/C."))
                        (let ((overrides (cddr value)))
                          (setf slots
                                (append
                                 (mapcar (lambda (slot)
                                           (let ((override (find (first slot) overrides
                                                                 :key (lambda (x) (if (symbolp x) x (first x))))))
                                             (if override (%structure-slot override slot) slot)))
                                         inherited)
                                 slots))))
                      (push raw rewritten))
                     (:type (setf typed t) (push raw rewritten))
                     (:named (setf named t) (push raw rewritten))
                     (otherwise (push raw rewritten))))))
        (unless (and name (symbolp name)) (error "Invalid structure name."))
        (mapc #'option options)
        (unless constructor-seen (option '(:constructor)))
        (unless copier-seen (option '(:copier)))
        (unless predicate-seen
          (option (if (and typed (not named)) '(:predicate nil) '(:predicate))))
        (dolist (slot slots)
          (let* ((public (if prefix
                             (intern (concatenate 'string (string prefix)
                                                  (symbol-name (first slot))) *package*)
                             (first slot)))
                 (inherited (assoc public inherited-bindings :test #'equal))
                 (native (if inherited (second inherited)
                             (intern (concatenate 'string native-prefix
                                                   (symbol-name (first slot))) *package*))))
            (push (list public native 1) bindings)
            (unless (second slot)
              ;; DEFSTRUCT may provide only a SETF expander, not a SETF function.
              ;; Compile a native writer through that standard generalized place.
              (let* ((inherited-writer (assoc `(setf ,public) inherited-bindings :test #'equal))
                     (writer (if inherited-writer (second inherited-writer)
                                 (%native-name `(setf ,public))))
                     (value (gensym "VALUE")) (object (gensym "OBJECT")))
                (unless inherited-writer
                  (push `(defun ,writer (,value ,object)
                           (setf (,native ,object) ,value)) writers))
                (push (list `(setf ,public) writer 2) bindings)))))
        (values
         `(defstruct (,name (:conc-name ,native-prefix) ,@(nreverse rewritten))
            ,@(when documentation (list documentation)) ,@body)
         (nreverse bindings) (nreverse writers) name slots)))))

(defvar *generated-targets* (make-hash-table :test #'equal))

(defun %find-class (name &rest arguments)
  (apply #'find-class (%canonical-class-name name) arguments))

(defun %call-standard (name arguments)
  ;; Resolve native entry points only after the required arguments are present.
  ;; Some hosts install condition readers lazily.
  (apply (if (eq name 'find-class) #'%find-class (fdefinition name)) arguments))

(defun %record-wrapper (public native required)
  (setf (gethash public *generated-targets*) (list native required))
  public)

(defun %install-generated (public native required)
  (let ((old (gethash public *generated-targets*)))
    (when (and (not old) (fboundp public))
      (error "~S is already defined outside the curried generated-function interface." public))
    (unless (and old (equal native (first old)) (= required (second old)))
      (setf (fdefinition public)
            (lambda (&rest arguments)
              (%dispatch (fdefinition native) required arguments))))
    (let ((public-symbol (if (symbolp public) public (second public)))
          (native-symbol (if (symbolp native) native (second native))))
      (unless (symbol-package public-symbol)
        (setf (gethash public-symbol *uninterned-targets*) native-symbol)))
    (setf (gethash public *generated-targets*) (list native required))
    (fdefinition native)))

(defun uncurried-function (name)
  "Return the native function or generic function behind a generated wrapper.
NAME is a symbol or (SETF symbol) installed by DEFGENERIC/C, DEFMETHOD/C,
DEFCLASS/C or DEFSTRUCT/C. The four ordinary-function macros are not registered."
  (let ((entry (gethash name *generated-targets*)))
    (unless entry (error "No generated curried function named ~S." name))
    (fdefinition (first entry))))

(defmacro defgeneric/c (name lambda-list &rest options &environment environment)
  "Define a native generic function and a public automatic-currying wrapper."
  (when (member '&aux lambda-list) (error "A generic lambda list cannot contain &AUX."))
  (let* ((required (%generic-required-count lambda-list environment))
         (native (%native-name name))
         (bindings (list (list name native required)))
         (rewritten
           (mapcar (lambda (option)
                     (if (and (consp option) (eq (first option) :method))
                         (multiple-value-bind (qualifiers parameters body count)
                             (%method-parts (rest option) environment)
                           (unless (= count required) (error "Incongruent inline method arity."))
                           `(:method ,@qualifiers ,parameters ,@(%method-body name body)))
                         option)) options)))
    `(progn ,(%proclaim-wrappers bindings)
            (defgeneric ,native ,(%canonical-generic-lambda-list lambda-list) ,@rewritten)
            ,@(%install-forms bindings))))

(defmacro defmethod/c (name &rest definition &environment environment)
  "Define a native method, implicitly creating its curried generic if needed."
  (multiple-value-bind (qualifiers lambda-list body required) (%method-parts definition environment)
    (let ((native (%native-name name)) (method (gensym "METHOD")))
      `(progn
         ,(%proclaim-wrappers (list (list name native required)))
         (let ((,method (defmethod ,native ,@qualifiers ,lambda-list
                          ,@(%method-body name body))))
           (%install-generated ',name ',native ,required)
           ,method)))))

(defmacro defclass/c (name superclasses slots &rest options)
  "Define a class, currying its explicitly requested readers and writers."
  (multiple-value-bind (rewritten bindings) (%class-slots slots)
    `(progn
       ,@(when bindings (list (%proclaim-wrappers bindings)))
       (defclass ,name ,superclasses ,rewritten ,@options)
       ,@(%install-forms bindings)
       (find-class ',name))))

(defmacro defstruct/c (name-and-options &body body &environment environment)
  "Define a structure with curried generated functions and standard data layout.
BOA constructors retain their ordinary lambda lists. Native keyword constructors
keep their keyword protocol and execute immediately (zero required arguments)."
  (multiple-value-bind (definition bindings writers name slots)
      (%structure-definition name-and-options body environment)
    `(progn
       ,(%proclaim-wrappers bindings)
       (eval-when (:compile-toplevel :load-toplevel :execute)
         (setf (gethash ',name *structure-slots*) ',slots
               (gethash ',name *structure-bindings*) ',bindings))
       ,definition
       ,@writers
       ,@(%install-forms bindings)
       ',name)))

(defmacro define-condition/c (name parents slots &rest options)
  "Define a condition and curried reader functions."
  (multiple-value-bind (rewritten bindings) (%class-slots slots)
    `(progn
       ,@(when bindings (list (%proclaim-wrappers bindings)))
       (define-condition ,name ,parents ,rewritten ,@options)
       ,@(%install-forms bindings)
       ',name)))
