;;; Prolog-native static types for Standard ML '97.
;;;
;;; The logical cell in TYPE-VAR is the Prolog variable.  The surrounding
;;; native term carries only its kind and equality attribute; there are no
;;; mutable Lisp type-variable objects.  All collection fields are native
;;; lists (therefore the native empty list is NIL).
;;;
;;;   (type-name spelling identity arity equality flexibility)
;;;   (type-var cell :type equality-attribute)
;;;   (type-var cell :row equality-attribute)
;;;   (=> domain result)
;;;   (@ type-name argument-types)
;;;   (record (field label type) ... row-tail)
;;;   (scheme quantified-variables body)
;;;   (type-function parameter-variables body)
;;;   (realization (name-map source target) ...)
;;;   (variable-map source-variable replacement)
;;;   (type-env (binding identifier type-or-scheme) ...)
;;;
;;; A record's FIELDS argument above is a list of FIELD terms.  Its ROW-TAIL is
;;; :CLOSED or an unbound :ROW TYPE-VAR.  A row cell may later be bound to a
;;; residual RECORD.  Ordinary variable equality attributes are fresh unbound
;;; variables; :EQUALITY marks an equality variable.  Bare Prolog variables are
;;; also accepted as unconstrained ordinary type variables, which is useful for
;;; DCG output arguments.  Use TYPE-VAR whenever kind or equality must persist.
;;;
;;; INSTALL-TYPE-PREDICATES installs these relations into the explicitly
;;; supplied database, leaving unrelated DCG predicates and the shared Prolog
;;; library untouched.  Host callbacks below are deliberately restricted to
;;; fresh name identities, identifier/label comparison, diagnostics and display.
;;; The static-semantics algorithms themselves are ordinary Prolog relations.

(uiop:define-package #:ooparts/sml/types
  (:use #:cl)
  (:import-from #:ooparts/prolog
                #:*database* #:<- #:<-- #:make-database)
  (:import-from #:ooparts/sml/runtime #:+reference-identity+)
  (:export
    #:*types-database* #:make-types-database #:install-type-predicates
    ;; Native constructors (also predicate/term names used by DCG rules).
    #:make-type-name #:type-name #:type-var #:=> #:@ #:record #:field
    #:scheme #:type-function #:realization #:name-map #:variable-map
    #:type-env #:binding #:field-pair
    #:type-variable #:equality-type-variable #:row-variable
    #:arrow-type #:type-application #:record-type #:record-field
    #:well-formed-type #:type-unify #:ensure-equality #:type-equality
    #:free-type-variables #:free-type-names
    #:generalize-type #:instantiate-type-scheme
    #:substitute-type-variables #:apply-type-function
    #:realize-type #:substitute-type-names
    #:empty-type-environment #:extend-type-environment
    #:lookup-type-environment #:require-type-environment
    #:render-type #:type-to-string #:write-type
    ;; Typed structural diagnostics.
    #:sml-type-error #:type-error-left #:type-error-right
    #:malformed-type-error #:cyclic-type-error
    #:occurs-check-error #:occurs-check-error-variable
    #:kind-mismatch-error #:arity-mismatch-error
    #:arity-mismatch-error-name #:arity-mismatch-error-expected
    #:arity-mismatch-error-actual #:unification-error
    #:type-name-unification-error #:equality-type-error
    #:record-conflict-error #:record-conflict-error-label
    #:duplicate-record-label-error #:row-tail-conflict-error
    #:unbound-identifier-error #:unbound-identifier-error-identifier))
(in-package #:ooparts/sml/types)

(define-condition sml-type-error (error)
  ((left :initarg :left :initform nil :reader type-error-left)
   (right :initarg :right :initform nil :reader type-error-right)
   (message :initarg :message :initform "Invalid SML static type."
            :reader %type-error-message))
  (:report (lambda (condition stream)
             (let ((*print-circle* t) (*print-pretty* nil))
               (format stream "~A~@[~%Left:  ~S~]~@[~%Right: ~S~]"
                       (%type-error-message condition)
                       (type-error-left condition)
                       (type-error-right condition))))))

(define-condition malformed-type-error (sml-type-error) ())
(define-condition cyclic-type-error (sml-type-error)
  ((message :initform "SML types must be finite, not rational/cyclic terms.")))
(define-condition occurs-check-error (sml-type-error)
  ((variable :initarg :variable :initform nil
             :reader occurs-check-error-variable)
   (message :initform "The occurs check rejected a cyclic SML type.")))
(define-condition kind-mismatch-error (sml-type-error)
  ((expected :initarg :expected :initform nil :reader kind-mismatch-error-expected)
   (actual :initarg :actual :initform nil :reader kind-mismatch-error-actual)
   (message :initform "A type variable and a row variable have incompatible kinds.")))
(define-condition arity-mismatch-error (sml-type-error)
  ((name :initarg :name :initform nil :reader arity-mismatch-error-name)
   (expected :initarg :expected :initform nil :reader arity-mismatch-error-expected)
   (actual :initarg :actual :initform nil :reader arity-mismatch-error-actual)
   (message :initform "The type constructor received the wrong number of arguments.")))
(define-condition unification-error (sml-type-error)
  ((message :initform "The two SML types cannot be unified.")))
(define-condition type-name-unification-error (unification-error)
  ((message :initform "Distinct type-name identities cannot be unified by spelling.")))
(define-condition equality-type-error (sml-type-error)
  ((message :initform "The type does not admit equality.")))
(define-condition record-conflict-error (unification-error)
  ((label :initarg :label :initform nil :reader record-conflict-error-label)
   (message :initform "The record rows have incompatible labels or fields.")))
(define-condition duplicate-record-label-error (record-conflict-error)
  ((message :initform "A record row contains the same label more than once.")))
(define-condition row-tail-conflict-error (record-conflict-error)
  ((message :initform "A shared record-row tail cannot supply inconsistent extensions.")))
(define-condition unbound-identifier-error (sml-type-error)
  ((identifier :initarg :identifier :initform nil
               :reader unbound-identifier-error-identifier)
   (message :initform "The identifier is absent from the type environment.")))

(let ((serial 0))
  (defun make-type-name (spelling arity
                         &key identity
                              (equality nil equality-supplied-p)
                              (status nil status-supplied-p)
                              (flexibility :flexible))
    "Return a native TYPE-NAME with a fresh identity unless IDENTITY is supplied.
EQUALITY is :EQUALITY or :NON-EQUALITY.  STATUS is accepted as a synonym so a
signature elaborator can pass its equality attribute directly.  FLEXIBILITY is
:FLEXIBLE or :RIGID and is metadata, not a spelling-based identity."
    (check-type spelling string)
    (unless (and (integerp arity) (not (minusp arity)))
      (error 'arity-mismatch-error :name spelling :expected "a nonnegative arity"
             :actual arity))
    (let ((attribute (cond (equality-supplied-p equality)
                           (status-supplied-p status)
                           (t :non-equality))))
      (unless (member attribute '(:equality :non-equality))
        (error 'malformed-type-error :left attribute
               :message "A type-name equality attribute is :EQUALITY or :NON-EQUALITY."))
      (unless (member flexibility '(:flexible :rigid))
        (error 'malformed-type-error :left flexibility
               :message "A type-name flexibility is :FLEXIBLE or :RIGID."))
      (list 'type-name spelling (or identity (incf serial)) arity attribute flexibility))))

(defun %canonical-label (label)
  "Canonicalize SML source labels for label lookup, not for type identity."
  (cond ((stringp label) label)
        ((symbolp label) (string-downcase (symbol-name label)))
        ((and (integerp label) (plusp label)) (write-to-string label))
        (t (error 'malformed-type-error :left label
                  :message "A record label must be a string, symbol, or positive integer."))))

(defun %same-label-p (left right)
  (and (string= (%canonical-label left) (%canonical-label right)) t))

(defun %same-identifier-p (left right)
  (cond ((or (stringp left) (stringp right) (symbolp left) (symbolp right))
         (and (or (stringp left) (symbolp left))
              (or (stringp right) (symbolp right))
              (string= (string left) (string right)) t))
        (t (equal left right))))

;;; Printing is a host boundary adapter only.  Query answers have reified ?G
;;; symbols in logical cells, so numbering by traversal gives stable, distinct
;;; names without ever consulting or mutating a VM variable.
(defun %query-variable-p (value)
  (and (symbolp value)
       (plusp (length (symbol-name value)))
       (char= #\? (char (symbol-name value) 0))))

(defun type-to-string (type)
  "Render a native type deterministically, including equality-variable markers.
TYPE is normally a term returned in a Prolog query binding.  Distinct free
cells receive distinct names even if their original source spellings agreed."
  (let ((names (make-hash-table :test #'eq)) (serial 0))
    (labels ((variable-name (cell equality)
               (multiple-value-bind (index presentp) (gethash cell names)
                 (unless presentp
                   (setf index serial
                         (gethash cell names) serial)
                   (incf serial))
                 (format nil "~A~A~@[~D~]"
                         (if (eq equality :equality) "''" "'")
                         (code-char (+ (char-code #\a) (mod index 26)))
                         (and (>= index 26) (floor index 26)))))
             (atomic-cell-p (cell) (%query-variable-p cell))
             (render (term)
               (cond
                 ((%query-variable-p term) (variable-name term nil))
                 ((and (consp term) (eq (car term) 'type-var))
                  (destructuring-bind (cell kind equality) (cdr term)
                    (declare (ignore kind))
                    (if (atomic-cell-p cell)
                        (variable-name cell equality)
                        (render cell))))
                 ((and (consp term) (eq (car term) '=>))
                  (format nil "~A -> ~A" (render-left (second term))
                          (render (third term))))
                 ((and (consp term) (eq (car term) '@))
                  (let* ((name (second term)) (arguments (third term))
                         (spelling (if (and (consp name)
                                           (eq (car name) 'type-name))
                                       (format nil "~A#~A" (second name) (third name))
                                       (princ-to-string name))))
                    (cond ((null arguments) spelling)
                          ((null (cdr arguments))
                           (format nil "~A ~A" (render-left (car arguments)) spelling))
                          (t (format nil "(~{~A~^ * ~}) ~A"
                                     (mapcar #'render arguments) spelling)))))
                 ((and (consp term) (eq (car term) 'record))
                  (let ((fields (mapcar #'render-field (second term)))
                        (openp (not (eq (third term) :closed))))
                    (format nil "{~{~A~^, ~}~A}" fields
                            (cond ((not openp) "") (fields ", ...") (t "...")))))
                 ((and (consp term) (eq (car term) 'scheme))
                  (format nil "forall ~{~A~^, ~}. ~A"
                          (mapcar #'render (second term)) (render (third term))))
                 ((and (consp term) (eq (car term) 'type-function))
                  (format nil "lambda ~{~A~^, ~}. ~A"
                          (mapcar #'render (second term)) (render (third term))))
                 (t (let ((*print-circle* t)) (princ-to-string term)))))
             (render-left (term)
               (if (and (consp term) (member (car term) '(=> @ record)))
                   (format nil "(~A)" (render term)) (render term)))
             (render-field (field)
               (if (and (consp field) (eq (car field) 'field))
                   (format nil "~A : ~A" (second field) (render (third field)))
                   (princ-to-string field))))
      (render type))))

(defun write-type (type &optional (stream *standard-output*))
  "Write TYPE's deterministic native representation to STREAM."
  (write-string (type-to-string type) stream)
  type)

(defun make-types-database ()
  "Create and populate an isolated native-WAM database for the type relations."
  (install-type-predicates
   (make-database :term-model :native :execution-mode :wam)))

(defun install-type-predicates (database)
  "Install/replace only SML type predicates in DATABASE and return DATABASE.
Other local predicates (including a caller's DCG grammar) are preserved."
  (let ((*database* database))
    ;;; Fresh logical variables.
    (<-- (type-variable ?kind (type-var ?cell ?kind ?equality)))
    (<-- (equality-type-variable (type-var ?cell :type :equality)))
    (<-- (row-variable (type-var ?cell :row ?equality)))

    ;;; Finite native lists and arity validation.
    (<-- (%list-length nil 0) !)
    (<- (%list-length (?head . ?tail) ?length)
        !
        (%list-length ?tail ?tail-length)
        (is ?length (+ ?tail-length 1)))
    (<- (%list-length ?open ?actual)
        (lisp (error 'malformed-type-error :left ?open
                     :message "Type argument lists and field lists must be finite and proper.")))

    (<-- (%require-kind ?kind ?kind ?term) !)
    (<- (%require-kind ?expected ?actual ?term)
        (lisp (error 'kind-mismatch-error :left ?term :expected ?expected :actual ?actual)))
    (<-- (%wf-equality-attribute ?attribute) (var ?attribute) !)
    (<- (%wf-equality-attribute :equality) !)
    (<- (%wf-equality-attribute ?attribute)
        (lisp (error 'malformed-type-error :left ?attribute
                     :message "A variable equality attribute must be free or :EQUALITY.")))

    (<-- (%wf-name-equality :equality) !)
    (<- (%wf-name-equality :non-equality) !)
    (<- (%wf-name-equality ?attribute)
        (lisp (error 'malformed-type-error :left ?attribute
                     :message "Unknown type-name equality attribute.")))
    (<-- (%wf-name-flexibility :flexible) !)
    (<- (%wf-name-flexibility :rigid) !)
    (<- (%wf-name-flexibility ?flexibility)
        (lisp (error 'malformed-type-error :left ?flexibility
                     :message "Unknown type-name flexibility.")))
    (<-- (%wf-type-name (type-name ?spelling ?identity ?arity ?equality ?flexibility))
        (lispp (and (stringp ?spelling) (integerp ?arity) (not (minusp ?arity))))
        (ground ?identity) (ground ?equality) (ground ?flexibility)
        (%wf-name-equality ?equality)
        (%wf-name-flexibility ?flexibility) !)
    (<- (%wf-type-name ?name)
        (lisp (error 'malformed-type-error :left ?name
                     :message "Malformed SML type name.")))

    (<-- (%acyclic-type ?type)
        (or (-> (acyclic_term ?type) true)
            (lisp (error 'cyclic-type-error :left ?type))))
    (<-- (well-formed-type ?type)
        (%acyclic-type ?type)
        (%wf ?type))

    (<-- (%wf ?type) (var ?type) !)
    (<- (%wf (type-var ?cell ?kind ?equality))
        (%require-kind :type ?kind ?cell)
        (%wf-equality-attribute ?equality)
        (or (-> (var ?cell) true) (%wf ?cell)) !)
    (<- (%wf (=> ?domain ?result)) ! (%wf ?domain) (%wf ?result))
    (<- (%wf (@ ?name ?arguments))
        !
        (%wf-type-name ?name)
        (%check-application-arity ?name ?arguments)
        (%wf-types ?arguments))
    (<- (%wf (record ?fields ?tail))
        !
        (%normalize-fields ?fields ?normalized)
        (%unique-fields ?normalized)
        (%wf-fields ?normalized)
        (%wf-row-tail ?tail))
    (<- (%wf ?type)
        (lisp (error 'malformed-type-error :left ?type
                     :message "Malformed SML type term.")))

    (<-- (%wf-types nil) !)
    (<- (%wf-types (?type . ?rest)) ! (%wf ?type) (%wf-types ?rest))
    (<- (%wf-types ?open)
        (lisp (error 'malformed-type-error :left ?open
                     :message "Type arguments must form a finite native list.")))
    (<-- (%wf-fields nil) !)
    (<- (%wf-fields ((field ?label ?type) . ?rest))
        (%wf ?type) (%wf-fields ?rest))

    (<-- (%wf-row-tail :closed) !)
    (<- (%wf-row-tail (type-var ?cell ?kind ?equality))
        (%require-kind :row ?kind ?cell)
        (%wf-equality-attribute ?equality)
        (%wf-row-cell ?cell) !)
    (<- (%wf-row-tail ?tail)
        (lisp (error 'kind-mismatch-error :left ?tail :expected :row :actual :type)))
    (<-- (%wf-row-cell ?cell) (var ?cell) !)
    (<- (%wf-row-cell (record ?fields ?tail))
        ! (%wf (record ?fields ?tail)))
    (<- (%wf-row-cell ?cell)
        (lisp (error 'malformed-type-error :left ?cell
                     :message "A row tail must denote a residual record.")))

    (<-- (%check-application-arity (type-name ?spelling ?id ?expected ?eq ?flex)
                                   ?arguments)
        (%list-length ?arguments ?actual)
        (or (-> (= ?actual ?expected) true)
            (lisp (error 'arity-mismatch-error :name ?spelling
                         :expected ?expected :actual ?actual))))

    ;;; Validating constructors.  These are relations so DCG rules can use the
    ;;; same terms as input or output without allocating host type objects.
    (<-- (arrow-type ?domain ?result ?arrow)
        (= ?arrow (=> ?domain ?result))
        (well-formed-type ?arrow))
    (<-- (type-application ?name ?arguments ?application)
        (= ?application (@ ?name ?arguments))
        (well-formed-type ?application))
    (<-- (record-type ?fields ?tail ?record)
        (= ?record (record ?fields ?tail))
        (%acyclic-type ?record)
        (%normalize-fields ?fields ?normalized)
        (= ?record (record ?normalized ?tail))
        (well-formed-type ?record))

    ;;; Label normalization and duplicate rejection.
    (<-- (%normalize-fields nil nil) !)
    (<- (%normalize-fields ((field ?label ?type) . ?rest)
                           ((field ?canonical ?type) . ?normalized))
        !
        (lisp ?canonical (%canonical-label ?label))
        (%normalize-fields ?rest ?normalized))
    (<- (%normalize-fields ?fields ?normalized)
        (lisp (error 'malformed-type-error :left ?fields
                     :message "Record fields must be FIELD terms in a finite native list.")))
    (<-- (%unique-fields nil) !)
    (<- (%unique-fields ((field ?label ?type) . ?rest))
        (or (-> (%field-with-label ?label ?rest ?other)
                (lisp (error 'duplicate-record-label-error :label ?label)))
            true)
        (%unique-fields ?rest))

    ;;; Unification with explicit finite-term and kind discipline.
    (<-- (type-unify ?left ?right)
        (%acyclic-type ?left) (%acyclic-type ?right)
        (%wf ?left) (%wf ?right)
        (%unify ?left ?right))
    (<-- (%unify ?left ?right) (== ?left ?right) !)
    (<- (%unify ?left ?right) (var ?left) ! (%checked-bind ?left ?right ?left ?right))
    (<- (%unify ?left ?right) (var ?right) ! (%checked-bind ?right ?left ?right ?left))
    (<- (%unify (type-var ?cell ?kind ?equality) ?right)
        (nonvar ?cell) !
        (%constrain-variable-equality ?equality ?kind ?cell)
        (%check-bound-variable-target ?kind ?right ?cell)
        (%unify ?cell ?right))
    (<- (%unify ?left (type-var ?cell ?kind ?equality))
        (nonvar ?cell) !
        (%constrain-variable-equality ?equality ?kind ?cell)
        (%check-bound-variable-target ?kind ?left ?cell)
        (%unify ?left ?cell))
    (<- (%unify (type-var ?left-cell ?left-kind ?left-equality)
                (type-var ?right-cell ?right-kind ?right-equality))
        (var ?left-cell) (var ?right-cell) !
        (%require-kind ?left-kind ?right-kind ?left-cell)
        (%unify-equality-attributes ?left-equality ?right-equality)
        (%checked-bind ?left-cell ?right-cell
                       (type-var ?left-cell ?left-kind ?left-equality)
                       (type-var ?right-cell ?right-kind ?right-equality)))
    (<- (%unify ?left (type-var ?cell ?kind ?equality))
        (var ?cell) !
        (%check-variable-target ?kind ?left ?cell)
        (%constrain-variable-equality ?equality ?kind ?left)
        (%checked-bind ?cell ?left (type-var ?cell ?kind ?equality) ?left))
    (<- (%unify (type-var ?cell ?kind ?equality) ?right)
        (var ?cell) !
        (%check-variable-target ?kind ?right ?cell)
        (%constrain-variable-equality ?equality ?kind ?right)
        (%checked-bind ?cell ?right (type-var ?cell ?kind ?equality) ?right))
    (<- (%unify (=> ?left-domain ?left-result) (=> ?right-domain ?right-result))
        !
        (%unify ?left-domain ?right-domain)
        (%unify ?left-result ?right-result))
    (<- (%unify (@ ?left-name ?left-arguments) (@ ?right-name ?right-arguments))
        !
        (%unify-type-names ?left-name ?right-name)
        (%unify-type-lists ?left-arguments ?right-arguments))
    (<- (%unify (record ?left-fields ?left-tail)
                (record ?right-fields ?right-tail))
        ! (%unify-records (record ?left-fields ?left-tail)
                          (record ?right-fields ?right-tail)))
    (<- (%unify ?left ?right)
        (lisp (error 'unification-error :left ?left :right ?right)))

    (<-- (%checked-bind ?variable ?term ?left ?right)
        (or (-> (unify_with_occurs_check ?variable ?term) true)
            (lisp (error 'occurs-check-error :variable ?variable
                         :left ?left :right ?right))))
    (<-- (%unify-equality-attributes ?left ?right)
        (or (-> (unify_with_occurs_check ?left ?right) true)
            (lisp (error 'unification-error :left ?left :right ?right
                         :message "Incompatible equality-variable attributes."))))

    (<-- (%check-bound-variable-target ?kind (type-var ?cell ?other-kind ?eq) ?term)
        ! (%require-kind ?kind ?other-kind ?term))
    (<- (%check-bound-variable-target :row ?target ?term)
        (or (-> (= ?target (record ?fields ?tail)) true)
            (lisp (error 'kind-mismatch-error :left ?term :right ?target
                         :expected :row :actual :type))))
    (<- (%check-bound-variable-target :type ?target ?term) !)
    (<-- (%check-variable-target ?kind (type-var ?cell ?other-kind ?eq) ?term)
        ! (%require-kind ?kind ?other-kind ?term))
    (<- (%check-variable-target :row ?target ?term)
        ! (or (-> (= ?target (record ?fields ?tail)) true)
              (lisp (error 'kind-mismatch-error :left ?term :right ?target
                           :expected :row :actual :type))))
    (<- (%check-variable-target :type ?target ?term) !)

    (<-- (%constrain-variable-equality ?equality ?kind ?type)
        (== ?equality :equality) ! (%ensure-equality ?type))
    (<- (%constrain-variable-equality ?equality ?kind ?type) !)

    (<-- (%unify-type-names (type-name ?ls ?identity ?la ?le ?lf)
                            (type-name ?rs ?identity ?ra ?re ?rf))
        !)
    (<- (%unify-type-names ?left ?right)
        (lisp (error 'type-name-unification-error :left ?left :right ?right)))
    (<-- (%unify-type-lists nil nil) !)
    (<- (%unify-type-lists (?left . ?left-rest) (?right . ?right-rest))
        ! (%unify ?left ?right) (%unify-type-lists ?left-rest ?right-rest))
    (<- (%unify-type-lists ?left ?right)
        (lisp (error 'unification-error :left ?left :right ?right
                     :message "Type constructor argument arities differ.")))

    ;;; Equality attributes and status are relations over the same native terms.
    (<-- (ensure-equality ?type)
        (%acyclic-type ?type) (%wf ?type) (%ensure-equality ?type))
    (<-- (%ensure-equality ?type)
        (var ?type) ! (= ?type (type-var ?fresh :type :equality)))
    (<- (%ensure-equality (type-var ?cell ?kind ?equality))
        (nonvar ?cell) ! (%ensure-equality ?cell))
    (<- (%ensure-equality (type-var ?cell ?kind ?equality))
        ! (unify_with_occurs_check ?equality :equality))
    (<- (%ensure-equality (=> ?domain ?result))
        ! (lisp (error 'equality-type-error :left (list '=> ?domain ?result))))
    (<- (%ensure-equality (@ (type-name ?spelling ?id ?arity :equality ?flex) ?arguments))
        (lispp (eq ?id +reference-identity+)) !)
    (<- (%ensure-equality (@ (type-name ?spelling ?id ?arity :equality ?flex) ?arguments))
        ! (%ensure-equality-types ?arguments))
    (<- (%ensure-equality (@ ?name ?arguments))
        ! (lisp (error 'equality-type-error :left (list '@ ?name ?arguments))))
    (<- (%ensure-equality (record ?fields ?tail))
        ! (%ensure-equality-fields ?fields) (%ensure-equality-row-tail ?tail))
    (<-- (%ensure-equality-types nil) !)
    (<- (%ensure-equality-types (?type . ?rest))
        (%ensure-equality ?type) (%ensure-equality-types ?rest))
    (<-- (%ensure-equality-fields nil) !)
    (<- (%ensure-equality-fields ((field ?label ?type) . ?rest))
        (%ensure-equality ?type) (%ensure-equality-fields ?rest))
    (<-- (%ensure-equality-row-tail :closed) !)
    (<- (%ensure-equality-row-tail ?tail) (%ensure-equality ?tail))

    (<-- (type-equality ?type ?status)
        (%acyclic-type ?type) (%wf ?type) (%type-equality ?type ?status))
    (<-- (%type-equality ?type :undetermined) (var ?type) !)
    (<- (%type-equality (type-var ?cell ?kind ?equality) ?status)
        (nonvar ?cell) ! (%type-equality ?cell ?status))
    (<- (%type-equality (type-var ?cell ?kind ?equality) :equality)
        (== ?equality :equality) !)
    (<- (%type-equality (type-var ?cell ?kind ?equality) :undetermined) !)
    (<- (%type-equality (=> ?domain ?result) :non-equality) !)
    (<- (%type-equality (@ (type-name ?s ?id ?a ?e ?f) ?args) :equality)
        (lispp (eq ?id +reference-identity+)) !)
    (<- (%type-equality (@ (type-name ?s ?id ?a :non-equality ?f) ?args) :non-equality) !)
    (<- (%type-equality (@ ?name ?arguments) ?status)
        (%type-equality-types ?arguments ?status))
    (<- (%type-equality (record ?fields ?tail) ?status)
        (%type-equality-fields ?fields ?field-status)
        (%type-equality-row-tail ?tail ?tail-status)
        (%combine-equality-status ?field-status ?tail-status ?status))
    (<-- (%type-equality-types nil :equality) !)
    (<- (%type-equality-types (?type . ?rest) ?status)
        (%type-equality ?type ?head-status)
        (%type-equality-types ?rest ?rest-status)
        (%combine-equality-status ?head-status ?rest-status ?status))
    (<-- (%type-equality-fields nil :equality) !)
    (<- (%type-equality-fields ((field ?label ?type) . ?rest) ?status)
        (%type-equality ?type ?head-status)
        (%type-equality-fields ?rest ?rest-status)
        (%combine-equality-status ?head-status ?rest-status ?status))
    (<-- (%type-equality-row-tail :closed :equality) !)
    (<- (%type-equality-row-tail ?tail ?status) (%type-equality ?tail ?status))
    (<-- (%combine-equality-status :non-equality ?right :non-equality) !)
    (<- (%combine-equality-status ?left :non-equality :non-equality) !)
    (<- (%combine-equality-status :undetermined ?right :undetermined) !)
    (<- (%combine-equality-status ?left :undetermined :undetermined) !)
    (<- (%combine-equality-status :equality :equality :equality) !)

    ;;; Record rows.  Partitioning is order independent.  Open/closed equations
    ;;; bind the open tail to exactly the closed remainder.  Distinct open tails
    ;;; receive opposite unique fields and one fresh shared residual tail.
    (<-- (%normalize-record (record ?fields ?tail) (record ?normalized ?tail))
        (%normalize-fields ?fields ?normalized) (%unique-fields ?normalized))
    (<-- (%flatten-record (record ?fields ?tail) ?flat-fields ?flat-tail)
        (%normalize-record (record ?fields ?tail) ?normalized)
        (%flatten-normal-record ?normalized nil ?flat-fields ?flat-tail)
        (%unique-fields ?flat-fields))
    (<-- (%flatten-normal-record (record ?fields :closed) ?before ?all :closed)
        ! (%append-fields ?before ?fields ?all))
    (<- (%flatten-normal-record (record ?fields (type-var ?cell :row ?equality))
                                ?before ?all ?tail)
        (var ?cell) !
        (%append-fields ?before ?fields ?all)
        (= ?tail (type-var ?cell :row ?equality)))
    (<- (%flatten-normal-record
         (record ?fields (type-var ?cell :row ?equality)) ?before ?all ?tail)
        (nonvar ?cell)
        (= ?cell (record ?next-fields ?next-tail))
        (%append-fields ?before ?fields ?combined)
        (%flatten-normal-record (record ?next-fields ?next-tail)
                                ?combined ?all ?tail))
    (<-- (%append-fields nil ?right ?right) !)
    (<- (%append-fields (?head . ?left) ?right (?head . ?rest))
        (%append-fields ?left ?right ?rest))

    (<-- (%unify-records ?left ?right)
        (%flatten-record ?left ?left-fields ?left-tail)
        (%flatten-record ?right ?right-fields ?right-tail)
        (%partition-fields ?left-fields ?right-fields
                           ?common ?left-only ?right-only)
        (%unify-field-pairs ?common)
        (%unify-row-partitions ?left-tail ?right-tail ?left-only ?right-only
                               ?left ?right))
    (<-- (%unify-row-partitions :closed :closed nil nil ?left ?right) !)
    (<- (%unify-row-partitions :closed :closed ?left-only ?right-only ?left ?right)
        ! (%closed-row-error ?left-only ?right-only ?left ?right))
    (<- (%unify-row-partitions (type-var ?cell :row ?equality) :closed
                               nil ?right-only ?left ?right)
        ! (%bind-row-tail (type-var ?cell :row ?equality)
                          (record ?right-only :closed)))
    (<- (%unify-row-partitions (type-var ?cell :row ?equality) :closed
                               ?left-only ?right-only ?left ?right)
        ! (%open-row-error ?left-only))
    (<- (%unify-row-partitions :closed (type-var ?cell :row ?equality)
                               ?left-only nil ?left ?right)
        ! (%bind-row-tail (type-var ?cell :row ?equality)
                          (record ?left-only :closed)))
    (<- (%unify-row-partitions :closed (type-var ?cell :row ?equality)
                               ?left-only ?right-only ?left ?right)
        ! (%open-row-error ?right-only))
    (<- (%unify-row-partitions (type-var ?lc :row ?le) (type-var ?rc :row ?re)
                               ?left-only ?right-only ?left ?right)
        (== ?lc ?rc) !
        (%unify-equality-attributes ?le ?re)
        (or (-> (and (= ?left-only nil) (= ?right-only nil)) true)
            (lisp (error 'row-tail-conflict-error :left ?left :right ?right
                         :label ?left-only))))
    (<- (%unify-row-partitions (type-var ?lc :row ?le) (type-var ?rc :row ?re)
                               ?left-only ?right-only ?left ?right)
        (%unify-equality-attributes ?le ?shared-equality)
        (%unify-equality-attributes ?re ?shared-equality)
        (%bind-row-tail (type-var ?lc :row ?le)
                        (record ?right-only
                                (type-var ?shared :row ?shared-equality)))
        (%bind-row-tail (type-var ?rc :row ?re)
                        (record ?left-only
                                (type-var ?shared :row ?shared-equality))))
    (<-- (%bind-row-tail (type-var ?cell :row ?equality) ?residual)
        (%constrain-variable-equality ?equality :row ?residual)
        (%checked-bind ?cell ?residual (type-var ?cell :row ?equality) ?residual))
    (<-- (%closed-row-error nil ?right-only ?left ?right)
        ! (%open-row-error ?right-only))
    (<- (%closed-row-error ?left-only ?right-only ?left ?right)
        (%open-row-error ?left-only))
    (<-- (%open-row-error ((field ?label ?type) . ?rest))
        (lisp (error 'record-conflict-error :label ?label :left ?label)))
    (<- (%open-row-error ?fields)
        (lisp (error 'record-conflict-error :left ?fields
                     :message "A record row has inconsistent extensions.")))

    ;;; Take/partition helpers are deterministic and never mutate their inputs.
    (<-- (%take-field ?label ((field ?found-label ?type) . ?rest)
                      (field ?found-label ?type) ?rest)
        (lispp (%same-label-p ?label ?found-label)) !)
    (<- (%take-field ?label (?field . ?fields) ?found (?field . ?remaining))
        (%take-field ?label ?fields ?found ?remaining))
    (<- (%take-field ?label nil nil nil))
    (<-- (%partition-fields nil ?right nil nil ?right) !)
    (<- (%partition-fields ((field ?label ?type) . ?left) ?right
                           ?common ?left-only ?right-only)
        (%take-field ?label ?right ?found ?right-rest)
        (or (-> (== ?found nil)
                (and (%partition-fields ?left ?right ?common ?rest-left ?right-only)
                     (= ?left-only ((field ?label ?type) . ?rest-left))))
            (and (= ?found (field ?right-label ?right-type))
                 (and (%partition-fields ?left ?right-rest ?rest-common
                                         ?left-only ?right-only)
                      (= ?common ((field-pair ?label ?type ?right-type) . ?rest-common))))))
    (<-- (%unify-field-pairs nil) !)
    (<- (%unify-field-pairs ((field-pair ?label ?left ?right) . ?rest))
        (%unify ?left ?right) (%unify-field-pairs ?rest))
    (<-- (%field-with-label ?label ((field ?other-label ?type) . ?rest)
                            (field ?other-label ?type))
        (lispp (%same-label-p ?label ?other-label)) !)
    (<- (%field-with-label ?label (?other . ?rest) ?found)
        (%field-with-label ?label ?rest ?found))
    (<-- (record-field ?record ?label ?type)
        (%acyclic-type ?record) (%wf ?record)
        (= ?record (record ?fields ?tail))
        (%flatten-record ?record ?flat-fields ?flat-tail)
        (%field-with-label ?label ?flat-fields (field ?found-label ?type)))

    ;;; Free variables and names.  Identity uses Prolog == on logical cells,
    ;;; never variable spelling and never type-name spelling.
    (<-- (free-type-variables ?object ?variables)
        (%acyclic-type ?object)
        (%free-variables ?object ?raw)
        (%unique-variables ?raw ?variables))
    (<-- (%free-variables ?type (?type)) (var ?type) !)
    (<- (%free-variables (type-var ?cell ?kind ?equality) ?variables)
        (or (-> (var ?cell)
                (= ?variables ((type-var ?cell ?kind ?equality))))
            (%free-variables ?cell ?variables)) !)
    (<- (%free-variables (=> ?domain ?result) ?variables)
        (%free-variables ?domain ?left) (%free-variables ?result ?right)
        (%append-fields ?left ?right ?variables) !)
    (<- (%free-variables (@ ?name ?arguments) ?variables)
        (%free-variable-types ?arguments ?variables) !)
    (<- (%free-variables (record ?fields ?tail) ?variables)
        (%free-variable-fields ?fields ?field-vars)
        (or (-> (= ?tail :closed) (= ?tail-vars nil))
            (%free-variables ?tail ?tail-vars))
        (%append-fields ?field-vars ?tail-vars ?variables) !)
    (<- (%free-variables (scheme ?quantified ?body) ?variables)
        (%free-variables ?body ?body-vars)
        (%subtract-variables ?body-vars ?quantified ?variables) !)
    (<- (%free-variables (type-function ?parameters ?body) ?variables)
        (%free-variables ?body ?body-vars)
        (%subtract-variables ?body-vars ?parameters ?variables) !)
    (<- (%free-variables (type-env ?bindings) ?variables)
        (%free-variable-bindings ?bindings ?variables) !)
    (<- (%free-variables ?other nil) !)
    (<-- (%free-variable-types nil nil) !)
    (<- (%free-variable-types (?type . ?rest) ?variables)
        (%free-variables ?type ?head) (%free-variable-types ?rest ?tail)
        (%append-fields ?head ?tail ?variables))
    (<-- (%free-variable-fields nil nil) !)
    (<- (%free-variable-fields ((field ?label ?type) . ?rest) ?variables)
        (%free-variables ?type ?head) (%free-variable-fields ?rest ?tail)
        (%append-fields ?head ?tail ?variables))
    (<-- (%free-variable-bindings nil nil) !)
    (<- (%free-variable-bindings ((binding ?identifier ?value) . ?rest) ?variables)
        (%free-variables ?value ?head) (%free-variable-bindings ?rest ?tail)
        (%append-fields ?head ?tail ?variables))
    (<-- (%variable-cell ?variable ?variable) (var ?variable) !)
    (<- (%variable-cell (type-var ?cell ?kind ?equality) ?cell) !)
    (<- (%variable-cell ?variable ?variable))
    (<-- (%same-variable ?left ?right)
        (%variable-cell ?left ?left-cell) (%variable-cell ?right ?right-cell)
        (== ?left-cell ?right-cell))
    (<-- (%unique-variables nil nil) !)
    (<- (%unique-variables (?variable . ?rest) ?unique)
        (%unique-variables ?rest ?rest-unique)
        (or (-> (%variable-member ?variable ?rest-unique)
                (= ?unique ?rest-unique))
            (= ?unique (?variable . ?rest-unique))))
    (<-- (%variable-member ?variable (?other . ?rest))
        (%same-variable ?variable ?other) !)
    (<- (%variable-member ?variable (?other . ?rest))
        (%variable-member ?variable ?rest))
    (<-- (%subtract-variables nil ?excluded nil) !)
    (<- (%subtract-variables (?variable . ?rest) ?excluded ?remaining)
        (%subtract-variables ?rest ?excluded ?rest-remaining)
        (or (-> (%variable-member ?variable ?excluded)
                (= ?remaining ?rest-remaining))
            (= ?remaining (?variable . ?rest-remaining))))

    (<-- (free-type-names ?object ?names)
        (%acyclic-type ?object) (%free-names ?object ?raw)
        (%unique-names ?raw ?names))
    (<-- (%free-names ?type nil) (var ?type) !)
    (<- (%free-names (type-var ?cell ?kind ?equality) ?names)
        (or (-> (var ?cell) (= ?names nil)) (%free-names ?cell ?names)) !)
    (<- (%free-names (=> ?domain ?result) ?names)
        (%free-names ?domain ?left) (%free-names ?result ?right)
        (%append-fields ?left ?right ?names) !)
    (<- (%free-names (@ ?name ?arguments) (?name . ?rest))
        (%free-name-types ?arguments ?rest) !)
    (<- (%free-names (record ?fields ?tail) ?names)
        (%free-name-fields ?fields ?field-names)
        (or (-> (= ?tail :closed) (= ?tail-names nil)) (%free-names ?tail ?tail-names))
        (%append-fields ?field-names ?tail-names ?names) !)
    (<- (%free-names (scheme ?quantified ?body) ?names)
        (%free-names ?body ?names) !)
    (<- (%free-names (type-function ?parameters ?body) ?names)
        (%free-names ?body ?names) !)
    (<- (%free-names (type-env ?bindings) ?names)
        (%free-name-bindings ?bindings ?names) !)
    (<- (%free-names ?other nil) !)
    (<-- (%free-name-types nil nil) !)
    (<- (%free-name-types (?type . ?rest) ?names)
        (%free-names ?type ?head) (%free-name-types ?rest ?tail)
        (%append-fields ?head ?tail ?names))
    (<-- (%free-name-fields nil nil) !)
    (<- (%free-name-fields ((field ?label ?type) . ?rest) ?names)
        (%free-names ?type ?head) (%free-name-fields ?rest ?tail)
        (%append-fields ?head ?tail ?names))
    (<-- (%free-name-bindings nil nil) !)
    (<- (%free-name-bindings ((binding ?identifier ?value) . ?rest) ?names)
        (%free-names ?value ?head) (%free-name-bindings ?rest ?tail)
        (%append-fields ?head ?tail ?names))
    (<-- (%same-name (type-name ?ls ?identity ?la ?le ?lf)
                     (type-name ?rs ?identity ?ra ?re ?rf)) !)
    ;;; Keep the last occurrence in source order, exactly as the recursive
    ;;; formulation did, without nesting all older list suffixes in WAM frames.
    (<-- (%unique-names ?names ?out)
        (%reverse-names ?names nil ?reversed)
        (%unique-names-seen ?reversed nil ?seen)
        (%reverse-names ?seen nil ?out))
    (<-- (%unique-names-seen nil ?seen ?seen) !)
    (<- (%unique-names-seen (?name . ?rest) ?seen ?out)
        (or (-> (%name-member ?name ?seen) (= ?next-seen ?seen))
            (= ?next-seen (?name . ?seen)))
        (%unique-names-seen ?rest ?next-seen ?out))
    (<-- (%reverse-names nil ?out ?out) !)
    (<- (%reverse-names (?name . ?rest) ?reversed ?out)
        (%reverse-names ?rest (?name . ?reversed) ?out))
    (<-- (%name-member ?name (?other . ?rest)) (%same-name ?name ?other) !)
    (<- (%name-member ?name (?other . ?rest)) (%name-member ?name ?rest))

    ;;; Generalization and capture-free specialization.  COPY-TYPE's mappings
    ;;; are simultaneous: a replacement is returned as-is, not traversed again.
    (<-- (%fresh-variable-map nil nil nil) !)
    (<- (%fresh-variable-map (?old . ?rest) ?map (?new . ?new-rest))
        (%fresh-variable ?old ?new)
        (%variable-cell ?old ?old-cell)
        (%fresh-variable-map ?rest ?rest-map ?new-rest)
        (= ?map ((variable-map ?old-cell ?new) . ?rest-map)))
    (<-- (%fresh-variable ?old ?fresh) (var ?old) !)
    (<- (%fresh-variable (type-var ?cell ?kind ?equality)
                          (type-var ?fresh ?kind :equality))
        (== ?equality :equality) !)
    (<- (%fresh-variable (type-var ?cell ?kind ?equality)
                         (type-var ?fresh ?kind ?fresh-equality))
        (var ?equality) !)
    (<-- (%lookup-variable-map ?key ((variable-map ?old ?new) . ?rest) ?new)
        (== ?key ?old) !)
    (<- (%lookup-variable-map ?key (?entry . ?rest) ?new)
        (%lookup-variable-map ?key ?rest ?new))
    (<-- (%copy-type ?type ?map ?new)
        (var ?type) !
        (or (-> (%lookup-variable-map ?type ?map ?replacement) (= ?new ?replacement))
            (= ?new ?type)))
    (<- (%copy-type (type-var ?cell :row ?equality) ?map ?new)
        (nonvar ?cell) !
        (%copy-type ?cell ?map ?copied-cell)
        (= ?new (type-var ?copied-cell :row ?equality)))
    (<- (%copy-type (type-var ?cell ?kind ?equality) ?map ?new)
        (or (-> (var ?cell)
                (or (-> (%lookup-variable-map ?cell ?map ?replacement)
                        (= ?new ?replacement))
                    (= ?new (type-var ?cell ?kind ?equality))))
            (%copy-type ?cell ?map ?new)))
    (<- (%copy-type (=> ?domain ?result) ?map (=> ?new-domain ?new-result))
        (%copy-type ?domain ?map ?new-domain) (%copy-type ?result ?map ?new-result))
    (<- (%copy-type (@ ?name ?arguments) ?map (@ ?name ?new-arguments))
        (%copy-type-list ?arguments ?map ?new-arguments))
    (<- (%copy-type (record ?fields ?tail) ?map (record ?new-fields ?new-tail))
        (%copy-type-fields ?fields ?map ?new-fields)
        (or (-> (= ?tail :closed) (= ?new-tail :closed))
            (%copy-type ?tail ?map ?new-tail)))
    (<-- (%copy-type-list nil ?map nil) !)
    (<- (%copy-type-list (?type . ?rest) ?map (?new . ?new-rest))
        (%copy-type ?type ?map ?new) (%copy-type-list ?rest ?map ?new-rest))
    (<-- (%copy-type-fields nil ?map nil) !)
    (<- (%copy-type-fields ((field ?label ?type) . ?rest) ?map
                           ((field ?label ?new) . ?new-rest))
        (%copy-type ?type ?map ?new) (%copy-type-fields ?rest ?map ?new-rest))

    (<-- (generalize-type ?type ?environment ?excluded ?scheme)
        (generalize-type ?type ?environment ?excluded :nonexpansive ?scheme))
    (<-- (generalize-type ?type ?environment ?excluded ?eligibility ?scheme)
        (%acyclic-type ?type) (%acyclic-type ?environment)
        (%acyclic-type ?excluded) (%wf ?type)
        (%free-variables ?type ?all-raw) (%unique-variables ?all-raw ?all)
        (%free-variables ?environment ?environment-raw)
        (%append-fields ?environment-raw ?excluded ?excluded-raw)
        (%unique-variables ?excluded-raw ?excluded-unique)
        (%subtract-variables ?all ?excluded-unique ?eligible)
        (%restricted-variables ?eligibility ?eligible ?quantified)
        (%fresh-variable-map ?quantified ?map ?new-quantified)
        (%copy-type ?type ?map ?body)
        (= ?scheme (scheme ?new-quantified ?body)))
    (<-- (%restricted-variables :nonexpansive ?variables ?variables) !)
    (<- (%restricted-variables :expansive ?variables nil) !)
    (<- (%restricted-variables :value-restriction ?variables nil) !)
    (<- (%restricted-variables ?eligibility ?variables ?quantified)
        (lisp (error 'malformed-type-error :left ?eligibility
                     :message "Generalization eligibility is :NONEXPANSIVE, :EXPANSIVE, or :VALUE-RESTRICTION.")))
    (<-- (instantiate-type-scheme (scheme ?quantified ?body) ?instance)
        (%acyclic-type ?quantified) (%acyclic-type ?body) (%wf ?body)
        (%fresh-variable-map ?quantified ?map ?fresh)
        (%copy-type ?body ?map ?instance))

    (<-- (%substitution-map nil nil) !)
    (<- (%substitution-map ((variable-map ?old ?replacement) . ?rest) ?map)
        (%variable-cell ?old ?cell)
        (%substitution-map ?rest ?rest-map)
        (= ?map ((variable-map ?cell ?replacement) . ?rest-map)))
    (<-- (substitute-type-variables ?type ?substitutions ?result)
        (%acyclic-type ?type) (%acyclic-type ?substitutions) (%wf ?type)
        (%substitution-map ?substitutions ?map)
        (%copy-type ?type ?map ?result))
    (<-- (apply-type-function (type-function ?parameters ?body) ?arguments ?result)
        (%acyclic-type ?parameters) (%acyclic-type ?body) (%wf ?body)
        (%acyclic-type ?arguments) (%wf-types ?arguments)
        (%list-length ?parameters ?expected)
        (%list-length ?arguments ?actual)
        (or (-> (= ?actual ?expected) true)
            (lisp (error 'arity-mismatch-error :name 'type-function
                         :expected ?expected :actual ?actual
                         :left (list 'type-function ?parameters ?body) :right ?arguments)))
        (%substitution-map-arguments ?parameters ?arguments ?map)
        (%copy-type ?body ?map ?result))
    (<-- (%substitution-map-arguments nil nil nil) !)
    (<- (%substitution-map-arguments (?parameter . ?parameters) (?argument . ?arguments)
                                     ((variable-map ?cell ?argument) . ?map))
        (%variable-cell ?parameter ?cell)
        (%substitution-map-arguments ?parameters ?arguments ?map))

    ;;; Signature realization maps identity-bearing names, including arbitrary
    ;;; arity/type-function targets.  Same-spelling declarations do not match.
    (<-- (substitute-type-names ?type ?bindings ?result)
        (realize-type ?type (realization ?bindings) ?result))
    (<-- (realize-type ?type (realization ?bindings) ?result)
        (%acyclic-type ?type) (%acyclic-type ?bindings) (%wf ?type)
        (%realize ?type ?bindings ?result))
    (<-- (%realize ?type ?bindings ?type) (var ?type) !)
    (<- (%realize (type-var ?cell :row ?equality) ?bindings ?result)
        (nonvar ?cell) !
        (%realize ?cell ?bindings ?realized-cell)
        (= ?result (type-var ?realized-cell :row ?equality)))
    (<- (%realize (type-var ?cell ?kind ?equality) ?bindings ?result)
        (or (-> (var ?cell)
                (= ?result (type-var ?cell ?kind ?equality)))
            (%realize ?cell ?bindings ?result)))
    (<- (%realize (=> ?domain ?result) ?bindings (=> ?new-domain ?new-result))
        (%realize ?domain ?bindings ?new-domain) (%realize ?result ?bindings ?new-result))
    (<- (%realize (@ ?name ?arguments) ?bindings ?result)
        (%realize-type-list ?arguments ?bindings ?new-arguments)
        (or (-> (%lookup-name-map ?name ?bindings ?target)
                (%apply-name-target ?name ?target ?new-arguments ?result))
            (= ?result (@ ?name ?new-arguments))))
    (<- (%realize (record ?fields ?tail) ?bindings (record ?new-fields ?new-tail))
        (%realize-fields ?fields ?bindings ?new-fields)
        (or (-> (= ?tail :closed) (= ?new-tail :closed))
            (%realize ?tail ?bindings ?new-tail)))
    (<-- (%lookup-name-map (type-name ?spelling ?identity ?arity ?eq ?flex)
                           ((name-map (type-name ?ss ?identity ?sa ?se ?sf) ?target) . ?rest)
                           ?target)
        !)
    (<- (%lookup-name-map ?name (?mapping . ?rest) ?target)
        (%lookup-name-map ?name ?rest ?target))
    (<-- (%apply-name-target ?source (type-name ?spelling ?id ?arity ?eq ?flex) ?arguments
                             (@ (type-name ?spelling ?id ?arity ?eq ?flex) ?arguments))
        (%check-application-arity (type-name ?spelling ?id ?arity ?eq ?flex) ?arguments) !)
    (<- (%apply-name-target ?source (type-function ?parameters ?body) ?arguments ?result)
        ! (apply-type-function (type-function ?parameters ?body) ?arguments ?result))
    (<-- (%realize-type-list nil ?bindings nil) !)
    (<- (%realize-type-list (?type . ?rest) ?bindings (?new . ?new-rest))
        (%realize ?type ?bindings ?new) (%realize-type-list ?rest ?bindings ?new-rest))
    (<-- (%realize-fields nil ?bindings nil) !)
    (<- (%realize-fields ((field ?label ?type) . ?rest) ?bindings
                         ((field ?label ?new) . ?new-rest))
        (%realize ?type ?bindings ?new) (%realize-fields ?rest ?bindings ?new-rest))

    ;;; Persistent native finite environments, including same-key shadowing.
    (<-- (empty-type-environment (type-env nil)))
    (<-- (extend-type-environment (type-env ?entries) ?identifier ?value
                                  (type-env ((binding ?identifier ?value) . ?entries))))
    (<-- (%lookup-binding ?identifier ((binding ?key ?value) . ?rest) ?value)
        (lispp (%same-identifier-p ?identifier ?key)) !)
    (<- (%lookup-binding ?identifier (?entry . ?rest) ?value)
        (%lookup-binding ?identifier ?rest ?value))
    (<-- (lookup-type-environment (type-env ?entries) ?identifier ?value)
        (%lookup-binding ?identifier ?entries ?value))
    (<-- (require-type-environment (type-env ?entries) ?identifier ?value)
        (or (-> (%lookup-binding ?identifier ?entries ?found) (= ?value ?found))
            (lisp (error 'unbound-identifier-error :identifier ?identifier :left ?identifier))))

    ;;; Explicit display relation for DCG diagnostics.
    (<-- (render-type ?type ?string)
        (%acyclic-type ?type)
        (lisp ?string (type-to-string ?type)))
    database))

(defparameter *types-database* (make-types-database)
  "A private native type database, not the caller's ambient PROLOG:*DATABASE*.")
