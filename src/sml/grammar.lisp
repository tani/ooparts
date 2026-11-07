;;; Native DCG grammar for Standard ML '97.
;;;
;;; Every syntax object returned by this file is an OOPARTS/SML/SYNTAX object.
;;; MAKE-AST-NODE supplies the native list representation (:NODE KIND SPAN
;;; SLOTS), where SLOTS is an immutable keyword/value alist.  This native
;;; representation is the grammar/elaboration/code-generation DCG interface;
;;; there is no separate lowering pipeline.  Other collection fields are also
;;; immutable native lists.  Identifier, literal, and span leaves remain their
;;; dedicated structures.  Optional fields contain NIL when absent.  Identifier-valued fields contain
;;; IDENTIFIER objects, literal fields contain LITERAL objects, and row labels
;;; contain :LABEL nodes whose :NAME is the source spelling.  The :OP-P fields
;;; record explicit `op`; qualified identifiers never acquire infix status.
;;;
;;; AST node conventions (all nodes also have their source span):
;;; Expressions: :LITERAL-EXPRESSION (:LITERAL), :IDENTIFIER-EXPRESSION
;;; (:IDENTIFIER :OP-P), :RECORD-EXPRESSION (:ROWS :EXPRESSION-ROW),
;;; :SELECTOR-EXPRESSION (:LABEL), :UNIT-EXPRESSION, :TUPLE-EXPRESSION,
;;; :SEQUENCE-EXPRESSION and :LIST-EXPRESSION (:EXPRESSIONS),
;;; :GROUPED-EXPRESSION (:EXPRESSION), :LET-EXPRESSION (:DECLARATIONS
;;; :EXPRESSIONS), :APPLICATION-EXPRESSION (:FUNCTION :ARGUMENT),
;;; :INFIX-EXPRESSION (:OPERATOR :LEFT :RIGHT), :TYPED-EXPRESSION
;;; (:EXPRESSION :TYPE), :ANDALSO-EXPRESSION and :ORELSE-EXPRESSION (:LEFT
;;; :RIGHT), :HANDLE-EXPRESSION (:EXPRESSION :MATCH), :RAISE-EXPRESSION,
;;; :IF-EXPRESSION (:CONDITION :THEN :ELSE), :WHILE-EXPRESSION
;;; (:CONDITION :BODY), :CASE-EXPRESSION (:EXPRESSION :MATCH), and
;;; :FN-EXPRESSION (:MATCH).  :MATCH contains :RULES; :MATCH-RULE contains
;;; :PATTERN and :EXPRESSION.
;;; Patterns parallel expressions with :WILDCARD-PATTERN, :LITERAL-PATTERN,
;;; :IDENTIFIER-PATTERN, :RECORD-PATTERN (:ROWS :WILDCARD-P),
;;; :PATTERN-ROW (:LABEL :PATTERN), :UNIT-PATTERN, :TUPLE-PATTERN,
;;; :LIST-PATTERN (:PATTERNS), :GROUPED-PATTERN,
;;; :CONSTRUCT-PATTERN (:CONSTRUCTOR :OP-P :ARGUMENT), :INFIX-PATTERN,
;;; :TYPED-PATTERN, and :LAYERED-PATTERN (:IDENTIFIER :OP-P :TYPE :PATTERN).
;;; Pattern-row puns retain :PUN-P and their optional :TYPE and :AS-PATTERN.
;;; Types: :TYPE-VARIABLE (:IDENTIFIER), :RECORD-TYPE (:ROWS :TYPE-ROW),
;;; :CONSTRUCTED-TYPE (:ARGUMENTS :CONSTRUCTOR), :TUPLE-TYPE (:TYPES),
;;; :FUNCTION-TYPE (:DOMAIN :RANGE), :GROUPED-TYPE (:TYPE).
;;; Bindings: :VALUE-BINDING (:PATTERN :EXPRESSION), :FUNCTION-BINDING
;;; (:CLAUSES), :FUNCTION-CLAUSE (:NAME :OP-P :ARGUMENTS :RESULT-TYPE
;;; :EXPRESSION :INFIX-HEAD-P), :TYPE-BINDING (:VARIABLES :NAME :TYPE),
;;; :DATATYPE-BINDING (:VARIABLES :NAME :CONSTRUCTORS),
;;; :CONSTRUCTOR-BINDING (:NAME :OP-P :TYPE), :EXCEPTION-BINDING (:NAME
;;; :OP-P :TYPE :ALIAS :ALIAS-OP-P).  Description nodes use the same shapes;
;;; descriptions have :TYPE NIL for abstract type descriptions.  Value
;;; descriptions are :VALUE-DESCRIPTION (:NAME :TYPE), structure descriptions
;;; are :STRUCTURE-DESCRIPTION (:NAME :SIGNATURE).  :EXPRESSION-ROW and
;;; :TYPE-ROW carry :LABEL plus :EXPRESSION or :TYPE respectively.
;;; Core declarations retain their source form as :VALUE-DECLARATION
;;; (:VARIABLES :BINDINGS :RECURSIVE-P), :FUNCTION-DECLARATION (:VARIABLES
;;; :BINDINGS :DECLARATION-FORM, either :FUN or derived :VAL-REC),
;;; :TYPE-DECLARATION (:BINDINGS), :DATATYPE-DECLARATION
;;; (:BINDINGS :WITHTYPES), :DATATYPE-REPLICATION (:NAME :SOURCE),
;;; :ABSTYPE-DECLARATION (:BINDINGS :WITHTYPES :DECLARATIONS),
;;; :EXCEPTION-DECLARATION (:BINDINGS), :LOCAL-DECLARATION (:LOCAL
;;; :BODY), :OPEN-DECLARATION (:IDENTIFIERS), and :FIXITY-DECLARATION
;;; (:FIXITY :PRECEDENCE :IDENTIFIERS).  Multiple declarations are returned in
;;; :DECLARATIONS lists; :DECLARATION-SEQUENCE is used by the public entry.
;;; Modules: :BASIC-STRUCTURE (:DECLARATIONS), :STRUCTURE-IDENTIFIER
;;; (:IDENTIFIER), :CONSTRAINED-STRUCTURE (:STRUCTURE :SIGNATURE :OPAQUE-P),
;;; :FUNCTOR-APPLICATION (:FUNCTOR :ARGUMENT or :DECLARATIONS), and
;;; :LET-STRUCTURE (:DECLARATIONS :BODY).  :STRUCTURE-DECLARATION adds
;;; :BINDINGS of :STRUCTURE-BINDING (:NAME :SIGNATURE :OPAQUE-P :STRUCTURE).
;;; :LOCAL-STRUCTURE-DECLARATION has :LOCAL and :BODY declaration lists.
;;; Signatures: :BASIC-SIGNATURE (:SPECIFICATION), :SIGNATURE-IDENTIFIER
;;; (:IDENTIFIER), :WHERE-TYPE-SIGNATURE (:SIGNATURE :REFINEMENTS), and
;;; :TYPE-REFINEMENT (:VARIABLES :CONSTRUCTOR :TYPE).
;;; Specifications: :SPECIFICATION-SEQUENCE (:SPECIFICATIONS),
;;; :VALUE-SPECIFICATION (:DESCRIPTIONS), :TYPE-SPECIFICATION (:EQUALITY-P
;;; :DESCRIPTIONS), :DATATYPE-SPECIFICATION (:DESCRIPTIONS),
;;; :DATATYPE-REPLICATION-SPECIFICATION (:NAME :SOURCE),
;;; :EXCEPTION-SPECIFICATION (:DESCRIPTIONS), :STRUCTURE-SPECIFICATION
;;; (:DESCRIPTIONS), :INCLUDE-SPECIFICATION (:SIGNATURES),
;;; :TYPE-SHARING-SPECIFICATION and :STRUCTURE-SHARING-SPECIFICATION
;;; (:SPECIFICATION :IDENTIFIERS).  No OPEN, LOCAL, or fixity specification is
;;; admitted by SML'97.
;;; :SIGNATURE-DECLARATION and :FUNCTOR-DECLARATION contain :BINDINGS, whose
;;; entries are :SIGNATURE-BINDING (:NAME :SIGNATURE) and :FUNCTOR-BINDING
;;; (:NAME :PARAMETER :PARAMETER-SIGNATURE or :OPENED-PARAMETER,
;;; :RESULT-SIGNATURE :OPAQUE-P :BODY).  :PROGRAM contains :TOPDECLARATIONS;
;;; each ordinary topdec is :TOPDEC-STRUCTURE (:DECLARATIONS); adjacent
;;; no-semicolon components are one :TOPDEC-SEQUENCE (:TOPDECLARATIONS).
;;; Empty topdecs before `;` use :TOPDEC-STRUCTURE with an empty list.  The
;;; interactive expression form is :TOPLEVEL-EXPRESSION (:EXPRESSION
;;; :BINDING-NAME), with :BINDING-NAME the identifier `it`.

(uiop:define-package #:ooparts/sml/grammar
  (:use #:cl)
  (:import-from #:ooparts/prolog
                #:*database* #:make-database #:--> #:--->)
  (:import-from #:ooparts/sml/source
                #:make-span #:position-offset
                #:source-span-source #:source-span-start #:source-span-end)
  (:import-from #:ooparts/sml/syntax
                #:make-identifier #:identifier-p #:identifier-path #:identifier-name
                #:identifier-span #:qualified-identifier-p
                #:literal-p #:literal-kind #:literal-span
                #:make-ast-node #:ast-node-p #:ast-node-kind #:ast-node-span
                #:ast-node-slots #:ast-ref)
  (:import-from #:ooparts/sml/lexer
                #:token-p #:token-kind #:token-text #:token-value #:token-span)
  (:export #:*grammar-database*
           #:initial-fixity-environment #:fixity-lookup #:infix-identifier-p
           #:sml-program #:sml-expression #:sml-declaration
           #:sml-structure-expression #:sml-signature-expression
           #:sml-specification))

(in-package #:ooparts/sml/grammar)

(defparameter *grammar-database*
  (make-database :term-model :native :execution-mode :wam)
  "Isolated native-term, interpreted-WAM database for the SML DCG.")

(defun make-initial-fixities ()
  (flet ((entries (associativity precedence names)
           (mapcar (lambda (name) (list name associativity precedence)) names)))
    (append
     (entries :left 7 '("*" "/" "div" "mod"))
     (entries :left 6 '("+" "-" "^"))
     (entries :right 5 '("::" "@"))
     (entries :left 4 '("=" "<>" "<" ">" "<=" ">="))
     (entries :left 3 '(":=" "o"))
     (entries :left 0 '("before")))))

(defparameter %initial-fixity-environment% (make-initial-fixities)
  "Private storage for INITIAL-FIXITY-ENVIRONMENT.")

(defun initial-fixity-environment ()
  "Return the immutable initial Basis fixity environment.
Public usage is the function call (INITIAL-FIXITY-ENVIRONMENT)."
  %initial-fixity-environment%)

(defun fixity-lookup (environment identifier-or-name)
  "Return (NAME ASSOCIATIVITY PRECEDENCE), or NIL for an unlisted/qualified name.
An entry with :NONFIX associativity is returned for an explicitly cancelled name."
  (let ((name (cond ((identifier-p identifier-or-name)
                     (and (not (qualified-identifier-p identifier-or-name))
                          (identifier-name identifier-or-name)))
                    ((stringp identifier-or-name) identifier-or-name)
                    (t nil))))
    (and name (assoc name environment :test #'string=))))

(defun infix-identifier-p (environment identifier &optional op-p)
  (and (not op-p)
       (let ((entry (fixity-lookup environment identifier)))
         (and entry (member (second entry) '(:left :right)) t))))

(defun value-span (value)
  (cond ((token-p value) (token-span value))
        ((ast-node-p value) (ast-node-span value))
        ((identifier-p value) (identifier-span value))
        ((literal-p value) (literal-span value))
        (t (error "No source span for ~S" value))))

(defun join-spans (first last)
  (let ((left (value-span first)) (right (value-span last)))
    (make-span (source-span-source left)
               (position-offset (source-span-start left))
               (position-offset (source-span-end right)))))

(defun ast (kind first last &rest slots)
  (apply #'make-ast-node kind (join-spans first last) slots))

(defun empty-ast (kind token &rest slots)
  (let ((span (token-span token))
        (offset (position-offset (source-span-start (token-span token)))))
    (apply #'make-ast-node kind
           (make-span (source-span-source span) offset offset)
           slots)))

(defun sequence-ast (kind items fallback &rest slots)
  (if items
      (apply #'ast kind (first items) (car (last items)) slots)
      (apply #'empty-ast kind fallback slots)))

(defun token-kind-in-p (token kinds)
  (and (token-p token) (member (token-kind token) kinds :test #'eq) t))

(defun keyword-token-p (token text)
  (and (token-kind-in-p token '(:keyword :reserved))
       (stringp (token-text token)) (string= (token-text token) text)))

(defun symbol-token-p (token text)
  ;; `*' is a value identifier lexically but punctuation in a type; `=' is both.
  (and (token-kind-in-p token '(:keyword :reserved :symbol :operator
                                :punctuation :identifier))
       (stringp (token-text token)) (string= (token-text token) text)))

(defun eof-token-p (token)
  (and (token-kind-in-p token '(:eof)) (string= (token-text token) "")))

(defun any-token-p (token)
  (and (token-p token) (not (eof-token-p token))))

(defun literal-token-kind (token)
  (and (token-p token)
       (let ((value (token-value token)))
         (and (literal-p value)
              (member (token-kind token)
                      '(:literal :integer :real :word :character :string) :test #'eq)
              (literal-kind value)))))

(defun make-token-identifier (token &optional qualified-ok)
  (and (token-kind-in-p token '(:identifier))
       (let ((value (token-value token)))
         (and (identifier-p value)
              (or qualified-ok (not (qualified-identifier-p value)))
              value))))

(defun equality-token-identifier (token)
  (and (symbol-token-p token "=")
       (make-identifier (list "=") (token-span token))))

(defun value-token-identifier (token &optional qualified-ok)
  (let ((identifier (or (make-token-identifier token qualified-ok)
                        (equality-token-identifier token))))
    (and identifier (valid-identifier-qualification-p identifier) identifier)))

(defun alphanumeric-name-p (name)
  (and (plusp (length name))
       (alpha-char-p (char name 0))
       (loop for char across name
             always (or (alphanumericp char) (char= char #\_) (char= char #\')))))

(defun valid-identifier-qualification-p (identifier)
  (loop for components on (identifier-path identifier)
        while (cdr components)
        always (alphanumeric-name-p (car components))))

(defun type-constructor-token-identifier (token &optional qualified-ok)
  (let ((identifier (value-token-identifier token qualified-ok)))
    (and identifier
         (not (member (identifier-name identifier) '("*" "=") :test #'string=))
         (not (char= (char (identifier-name identifier) 0) #\'))
         identifier)))

(defun module-token-identifier (token &optional qualified-ok)
  (let ((identifier (value-token-identifier token qualified-ok)))
    (and identifier
         (every #'alphanumeric-name-p (identifier-path identifier))
         identifier)))

(defun type-variable-token-identifier (token)
  (and (token-kind-in-p token '(:tyvar :type-variable))
       (let ((value (token-value token)))
         (cond ((identifier-p value) value)
               ((and (stringp value) (plusp (length value))
                     (char= (char value 0) #\'))
                (make-identifier (list value) (token-span token)))
               ((and (stringp (token-text token))
                     (plusp (length (token-text token)))
                     (char= (char (token-text token) 0) #\'))
                (make-identifier (list (token-text token)) (token-span token)))))))

(defun numeric-label-text (text)
  (and (stringp text) (plusp (length text))
       (char<= #\1 (char text 0) #\9)
       (every #'digit-char-p text)
       text))

(defun label-token-name (token)
  (let ((identifier (make-token-identifier token)))
    (cond (identifier
           (let ((name (identifier-name identifier)))
             (and (not (string= name "="))
                  (plusp (length name))
                  (char/= (char name 0) #\')
                  name)))
          ((eq (literal-token-kind token) :integer)
           (numeric-label-text (token-text token))))))


(defun make-label-node (token)
  (let ((name (label-token-name token)))
    (and name (ast :label token token :name name))))

(defun fold-application (function arguments)
  (dolist (argument arguments function)
    (setf function (ast :application-expression function argument
                        :function function :argument argument))))

(defun unique-strings-p (strings)
  (let ((seen (make-hash-table :test #'equal)))
    (dolist (string strings t)
      (when (gethash string seen) (return nil))
      (setf (gethash string seen) t))))

(defun identifier-names (identifiers)
  (mapcar #'identifier-name identifiers))

(defun unique-identifiers-p (identifiers)
  (unique-strings-p (identifier-names identifiers)))

(defun unique-rows-p (rows)
  (unique-strings-p (mapcar (lambda (row) (ast-ref (ast-ref row :label) :name)) rows)))

(defun extend-fixity (environment identifiers fixity precedence)
  (append (mapcar (lambda (identifier)
                    (list (identifier-name identifier) fixity precedence))
                  identifiers)
          environment))

(defun fixity-declaration (keyword identifiers precedence fixity)
  (ast :fixity-declaration keyword (car (last identifiers))
       :fixity fixity :precedence precedence :identifiers identifiers))

(defun semantic-bindings (bindings key)
  (mapcar (lambda (binding) (ast-ref binding key)) bindings))

(defparameter +reserved-value-bindings+ '("true" "false" "nil" "::" "ref" "="))
(defparameter +reserved-module-value-bindings+ '("true" "false" "nil" "::" "ref" "="))

(defun allowed-bound-name-p (identifier &optional it-forbidden module-description)
  (let ((name (identifier-name identifier)))
    (and (not (member name (if module-description
                               +reserved-module-value-bindings+
                               +reserved-value-bindings+)
                      :test #'string=))
         (not (and it-forbidden (string= name "it"))))))

(defun pattern-bound-identifiers (pattern)
  "Collect variable positions, excluding constructor positions and labels.
Without static identifier status, a bare unqualified name is a variable except
for the reserved nullary constructors; lower elaboration remains authoritative
about constructor arity and identifier status."
  (when (ast-node-p pattern)
    (case (ast-node-kind pattern)
      (:identifier-pattern
       (let ((identifier (ast-ref pattern :identifier)))
         (cond
           ((qualified-identifier-p identifier) nil)
           ;; Bare "=" has identifier status but cannot be rebound (Definition §2.4).
           ((string= (identifier-name identifier) "=") (list identifier))
           ((member (identifier-name identifier) +reserved-module-value-bindings+
                    :test #'string=) nil)
           (t (list identifier)))))
      (:layered-pattern
       (append (list (ast-ref pattern :identifier))
               (pattern-bound-identifiers (ast-ref pattern :pattern))))
      (:record-pattern
       (loop for row in (ast-ref pattern :rows)
             append (pattern-bound-identifiers (ast-ref row :pattern))))
      ((:tuple-pattern :list-pattern)
       (loop for child in (ast-ref pattern :patterns) append (pattern-bound-identifiers child)))
      (:grouped-pattern (pattern-bound-identifiers (ast-ref pattern :pattern)))
      (:construct-pattern (pattern-bound-identifiers (ast-ref pattern :argument)))
      (:infix-pattern (append (pattern-bound-identifiers (ast-ref pattern :left))
                              (pattern-bound-identifiers (ast-ref pattern :right))))
      (:typed-pattern (pattern-bound-identifiers (ast-ref pattern :pattern)))
      (otherwise nil))))

(defun recursive-value-pattern-valid-p (pattern)
  "Recognize the variable or explicitly typed variable required by VAL REC.
Reserved constructor identifiers remain valid ordinary patterns, but cannot be
made recursive value bindings."
  (case (ast-node-kind pattern)
    (:identifier-pattern
     (let ((identifier (ast-ref pattern :identifier)))
       (and (not (qualified-identifier-p identifier))
            (allowed-bound-name-p identifier))))
    (:typed-pattern
     (recursive-value-pattern-valid-p (ast-ref pattern :pattern)))
    (:grouped-pattern
     (recursive-value-pattern-valid-p (ast-ref pattern :pattern)))
    (:layered-pattern
     (let ((identifier (ast-ref pattern :identifier)))
       (and (not (qualified-identifier-p identifier))
            (allowed-bound-name-p identifier)
            (recursive-value-pattern-valid-p (ast-ref pattern :pattern)))))
    (otherwise nil)))

(defun %value-binding-with-recursion (binding recursive-p)
  "Preserve one native AST node while recording its effective REC scope."
  (destructuring-bind (node-kind kind span slots) binding
    (declare (ignore node-kind))
    (list :node kind span
          (append (remove :recursive-p slots :key #'car)
                  (list (cons :recursive-p recursive-p))))))

(defun %normalize-value-bindings (bindings recursive-p)
  "A marker makes its own binding and the rest of that suffix recursive."
  (let ((recursive-suffix-p recursive-p))
    (mapcar (lambda (binding)
              (setf recursive-suffix-p
                    (or recursive-suffix-p (ast-ref binding :recursive-p)))
              (%value-binding-with-recursion binding recursive-suffix-p))
            bindings)))

(defun value-bindings-valid-p (bindings recursive-p)
  (and (every (lambda (binding)
                (or (not (or recursive-p (ast-ref binding :recursive-p)))
                    (and (recursive-value-pattern-valid-p (ast-ref binding :pattern))
                         (eq (ast-node-kind (ast-ref binding :expression))
                             :fn-expression))))
              bindings)
       (let ((identifiers (loop for binding in bindings
                                append (pattern-bound-identifiers (ast-ref binding :pattern)))))
         (and (unique-identifiers-p identifiers)
              (every #'allowed-bound-name-p identifiers)))))

(defun type-bindings-valid-p (bindings &optional withtypes)
  (let ((names (semantic-bindings bindings :name))
        (withnames (semantic-bindings withtypes :name)))
    (and (unique-identifiers-p names) (unique-identifiers-p withnames)
         (not (intersection (identifier-names names) (identifier-names withnames)
                            :test #'string=)))))

(defun datatype-bindings-valid-p (bindings &optional withtypes description-p)
  (let ((tynames (semantic-bindings bindings :name))
        (constructors (loop for binding in bindings
                            append (semantic-bindings (ast-ref binding :constructors) :name))))
    (and (unique-identifiers-p tynames)
         (unique-identifiers-p constructors)
         (every (lambda (name) (allowed-bound-name-p name t description-p)) constructors)
         (type-bindings-valid-p bindings withtypes))))

(defun function-bindings-valid-p (bindings)
  (and (unique-identifiers-p (semantic-bindings bindings :name))
       (every (lambda (binding)
                (let ((clauses (ast-ref binding :clauses)))
                  (and clauses
                       (let ((name (identifier-name (ast-ref (first clauses) :name)))
                             (arity (length (ast-ref (first clauses) :arguments))))
                         (every (lambda (clause)
                                  (and (string= name (identifier-name (ast-ref clause :name)))
                                       (= arity (length (ast-ref clause :arguments)))))
                                clauses))
                       (allowed-bound-name-p (ast-ref (first clauses) :name))
                       (every (lambda (clause)
                                (unique-identifiers-p
                                 (loop for argument in (ast-ref clause :arguments)
                                       append (pattern-bound-identifiers argument))))
                              clauses))))
              bindings)))

(defun exception-bindings-valid-p (bindings &optional description-p)
  (let ((names (semantic-bindings bindings :name)))
    (and (unique-identifiers-p names)
         (every (lambda (name) (allowed-bound-name-p name t description-p)) names))))

(defun descriptions-valid-p (descriptions &optional value-p)
  (let ((names (semantic-bindings descriptions :name)))
    (and (unique-identifiers-p names)
         (or (not value-p)
             (every (lambda (name) (allowed-bound-name-p name nil t)) names)))))

(defun type-tree-variables (type)
  (when (ast-node-p type)
    (case (ast-node-kind type)
      (:type-variable (list (identifier-name (ast-ref type :identifier))))
      (:record-type (loop for row in (ast-ref type :rows)
                          append (type-tree-variables (ast-ref row :type))))
      (:constructed-type (loop for argument in (ast-ref type :arguments)
                               append (type-tree-variables argument)))
      ((:tuple-type) (loop for child in (ast-ref type :types)
                           append (type-tree-variables child)))
      (:function-type (append (type-tree-variables (ast-ref type :domain))
                              (type-tree-variables (ast-ref type :range))))
      (:grouped-type (type-tree-variables (ast-ref type :type)))
      (otherwise nil))))

(defun explicitly-closed-type-p (variables type)
  (subsetp (type-tree-variables type) (identifier-names variables) :test #'string=))

(defun datatype-descriptions-closed-p (descriptions)
  (every (lambda (description)
           (every (lambda (constructor)
                    (or (null (ast-ref constructor :type))
                        (explicitly-closed-type-p (ast-ref description :variables)
                                                  (ast-ref constructor :type))))
                  (ast-ref description :constructors)))
         descriptions))

(defun refinements-closed-p (refinements)
  (every (lambda (refinement)
           (explicitly-closed-type-p (ast-ref refinement :variables)
                                     (ast-ref refinement :type)))
         refinements))

(defun value-declaration-kind-p (kind)
  (member kind '(:value-declaration :function-declaration) :test #'eq))

(defun direct-value-type-variables (value)
  "Type variables unguarded by a nested VAL/FUN value declaration."
  (cond ((ast-node-p value)
         (cond ((or (value-declaration-kind-p (ast-node-kind value))
                    (member (ast-node-kind value)
                            '(:datatype-declaration :datatype-specification)
                            :test #'eq))
                nil)
               ((eq (ast-node-kind value) :type-variable)
                (list (identifier-name (ast-ref value :identifier))))
               (t (loop for entry in (ast-node-slots value)
                        append (direct-value-type-variables (cdr entry))))))
        ((consp value)
         (append (direct-value-type-variables (car value))
                 (direct-value-type-variables (cdr value))))
        (t nil)))

(defun value-type-scopes-valid-p (value)
  "Validate Definition 2.9's disjoint nested VAL scopes, after implicit scope.
At a nested declaration its unguarded occurrences belong to an enclosing VAL
when the same variable is also unguarded there; otherwise they are implicitly
added to the nested declaration's explicit TYVARSEQ for this restriction."
  (labels ((walk (current inherited-effective inherited-unguarded)
             (cond ((ast-node-p current)
                    (if (value-declaration-kind-p (ast-node-kind current))
                        (let* ((declared (identifier-names (ast-ref current :variables)))
                               (unguarded (direct-value-type-variables
                                           (ast-ref current :bindings)))
                               (implicit (set-difference unguarded inherited-unguarded
                                                         :test #'string=))
                               (effective (union declared implicit :test #'string=)))
                          (and (not (intersection effective inherited-effective
                                                  :test #'string=))
                                (loop for entry in (ast-node-slots current)
                                     always (walk (cdr entry)
                                                  (union effective inherited-effective
                                                         :test #'string=)
                                                  (union declared
                                                         (union unguarded inherited-unguarded
                                                                :test #'string=)
                                                         :test #'string=)))))
                        (loop for entry in (ast-node-slots current)
                              always (walk (cdr entry) inherited-effective
                                           inherited-unguarded))))
                   ((consp current)
                    (and (walk (car current) inherited-effective inherited-unguarded)
                         (walk (cdr current) inherited-effective inherited-unguarded)))
                   (t t))))
    (walk value nil nil)))

(defun make-value-declaration (keyword bindings variables recursive-p)
  (let* ((last (car (last bindings)))
         (normalized (and bindings
                          (%normalize-value-bindings bindings recursive-p)))
         (flags (mapcar (lambda (binding) (ast-ref binding :recursive-p))
                        normalized))
         (mode (cond ((notany #'identity flags) nil)
                     ((every #'identity flags) t)
                     (t :mixed))))
    (and normalized (value-bindings-valid-p normalized recursive-p)
         (let ((node (ast :value-declaration keyword last
                          :variables variables :bindings normalized
                          :recursive-p mode)))
           (and (value-type-scopes-valid-p node) node)))))

(defun make-function-binding (clauses)
  (and clauses
       (ast :function-binding (first clauses) (car (last clauses))
            :name (ast-ref (first clauses) :name) :clauses clauses)))

(defun make-function-declaration (keyword bindings variables)
  (and bindings (function-bindings-valid-p bindings)
       (let ((node (ast :function-declaration keyword (car (last bindings))
                        :variables variables :bindings bindings
                        :declaration-form (if (and (token-p keyword)
                                                   (string= (token-text keyword) "val"))
                                              :val-rec
                                              :fun))))
         (and (value-type-scopes-valid-p node) node))))

;;; Intermediate series are host conses of a native AST and (IDENTIFIER OP-P
;;; native-AST) tails.  This envelope is not an AST node and never escapes a
;;; completed production; the nodes themselves retain (:NODE KIND SPAN SLOTS).
(defun make-series (first rest) (cons first rest))
(defun series-first (series) (car series))
(defun series-tail (series) (cdr series))
(defun make-series-tail (identifier op-p operand)
  (list identifier op-p operand))

(defun resolve-infix (series environment kind)
  "Resolve a flat DCG-recognized infix sequence without mutating ENVIRONMENT."
  (let ((first (series-first series)) (tail (series-tail series)))
    (if (null tail)
        first
        (let ((operators
                (mapcar (lambda (item)
                          (let ((identifier (first item)) (op-p (second item)))
                            (unless (infix-identifier-p environment identifier op-p)
                              (return-from resolve-infix nil))
                            (destructuring-bind (name associativity precedence)
                                (fixity-lookup environment identifier)
                              (declare (ignore name))
                              (list associativity precedence identifier))))
                        tail)))
          (loop for (left right) on operators
                for left-associativity = (first left)
                for left-precedence = (second left)
                when (and right (= left-precedence (second right))
                          (not (eq left-associativity (first right))))
                  do (return-from resolve-infix nil))
          (let ((stack-operands (list first))
                (stack-operators nil))
            (labels ((reduce-top ()
                       (let* ((operator (pop stack-operators))
                              (right (pop stack-operands))
                              (left (pop stack-operands))
                              (node (ast kind left right
                                         :operator (third operator)
                                         :left left :right right)))
                         (push node stack-operands)))
                     (ready-p (incoming)
                       (and stack-operators
                            (let ((top (first stack-operators)))
                              (or (> (second top) (second incoming))
                                  (and (= (second top) (second incoming))
                                       (eq (first incoming) :left)))))))
              (loop for item in tail
                    for operator in operators
                    do (loop while (ready-p operator) do (reduce-top))
                       (push operator stack-operators)
                       (push (third item) stack-operands))
              (loop while stack-operators do (reduce-top))
              (and (null (cdr stack-operands)) (first stack-operands))))))))

(defun resolve-expression-infix (series environment)
  (resolve-infix series environment :infix-expression))

(defun resolve-pattern-infix (series environment)
  (resolve-infix series environment :infix-pattern))

(defun make-fnode (kind left right)
  (ast kind left right :left left :right right))

(defun valid-type-base-p (base constructors)
  (or constructors (not (eq (ast-node-kind base) :type-argument-sequence))))

(defun fold-type-constructors (base constructors)
  (when (valid-type-base-p base constructors)
    (if (null constructors)
        base
        (let* ((arguments (if (eq (ast-node-kind base) :type-argument-sequence)
                              (ast-ref base :types)
                              (list base)))
               (result nil))
          (dolist (constructor constructors result)
            (setf result (ast :constructed-type base constructor
                              :arguments arguments :constructor constructor)
                  arguments (list result)
                  base result))))))

(defun binding-start (variables fallback)
  (if variables (first variables) fallback))

(defun specification-direct-names (items class)
  (loop for item in items append
    (case (ast-node-kind item)
      (:value-specification
       (and (eq class :value) (identifier-names (semantic-bindings
                                                 (ast-ref item :descriptions) :name))))
      (:type-specification
       (and (eq class :type) (identifier-names (semantic-bindings
                                                (ast-ref item :descriptions) :name))))
      (:datatype-specification
       (let ((descriptions (ast-ref item :descriptions)))
         (append (and (eq class :type)
                      (identifier-names (semantic-bindings descriptions :name)))
                 (and (eq class :value)
                      (loop for description in descriptions
                            append (identifier-names
                                    (semantic-bindings (ast-ref description :constructors)
                                                       :name)))))))
      (:datatype-replication-specification
       (and (eq class :type) (list (identifier-name (ast-ref item :name)))))
      (:exception-specification
       (and (eq class :value) (identifier-names (semantic-bindings
                                                 (ast-ref item :descriptions) :name))))
      (:structure-specification
       (and (eq class :structure) (identifier-names (semantic-bindings
                                                     (ast-ref item :descriptions) :name))))
      (otherwise nil))))

(defun specification-items-valid-p (items)
  (and (unique-strings-p (specification-direct-names items :value))
       (unique-strings-p (specification-direct-names items :type))
       (unique-strings-p (specification-direct-names items :structure))))

(defun make-specification-ast (items clauses fallback)
  (let ((result (sequence-ast :specification-sequence items fallback
                              :specifications items)))
    (dolist (clause clauses result)
      (setf result (ast (if (ast-ref clause :type-p)
                            :type-sharing-specification
                            :structure-sharing-specification)
                        result (car (last (ast-ref clause :identifiers)))
                        :specification result
                        :identifiers (ast-ref clause :identifiers))))))

;; Install each rule in its own top-level database binding.  Combining all
;; expanded rules in one outer LET leaves their temporaries unbound in ABCL FASLs.
(macrolet ((--> (&whole form &rest arguments)
             (declare (ignore arguments))
             `(let ((*database* *grammar-database*))
                ,(macroexpand-1 form nil)))
           (---> (&whole form &rest arguments)
             (declare (ignore arguments))
             `(let ((*database* *grammar-database*))
                ,(macroexpand-1 form nil))))


;;; Tokens and terminals.  No token spelling is compared with EQL/EQ.
(---> (token ?token)
     '(?token)
     (do (lispp (any-token-p ?token))))
(--> (end-of-input ?token)
     '(?token)
     (do (lispp (eof-token-p ?token))))
(--> (keyword ?text ?token)
     '(?token)
     (do (lispp (keyword-token-p ?token ?text))))
(--> (symbol ?text ?token)
     '(?token)
     (do (lispp (symbol-token-p ?token ?text))))
(--> (semicolon ?token) (symbol ";" ?token))
(--> (comma ?token) (symbol "," ?token))
(--> (vertical-bar ?token) (symbol "|" ?token))
(--> (long-value-identifier ?identifier ?token)
     '(?token)
     (do (lisp ?identifier (value-token-identifier ?token t))
         (lispp ?identifier)))
(--> (value-identifier ?identifier ?token)
     '(?token)
     (do (lisp ?identifier (value-token-identifier ?token nil))
         (lispp ?identifier)))
(--> (long-type-constructor ?identifier ?token)
     '(?token)
     (do (lisp ?identifier (type-constructor-token-identifier ?token t))
         (lispp ?identifier)))
(--> (type-constructor ?identifier ?token)
     '(?token)
     (do (lisp ?identifier (type-constructor-token-identifier ?token nil))
         (lispp ?identifier)))
(--> (long-module-identifier ?identifier ?token)
     '(?token)
     (do (lisp ?identifier (module-token-identifier ?token t))
         (lispp ?identifier)))
(--> (module-identifier ?identifier ?token)
     '(?token)
     (do (lisp ?identifier (module-token-identifier ?token nil))
         (lispp ?identifier)))
(--> (type-variable ?identifier ?token)
     '(?token)
     (do (lisp ?identifier (type-variable-token-identifier ?token))
         (lispp ?identifier)))
(--> (label ?label)
     '(?token)
     (do (lisp ?label (make-label-node ?token))
         (lispp ?label)))
(--> (special-constant ?literal ?token)
     '(?token)
     (do (lisp ?kind (literal-token-kind ?token))
         (lispp ?kind)
         (lisp ?literal (token-value ?token))))

;; VALUE-REFERENCE returns the first source object as well as OP-P/value.
(--> (value-reference ?identifier ?op-p ?start)
     (keyword "op" ?op)
     (long-value-identifier ?identifier ?token)
     (do (= ?op-p t) (= ?start ?op)))
(--> (value-reference ?identifier ?op-p ?start)
     (long-value-identifier ?identifier ?start)
     (do (= ?op-p nil)))
(--> (atomic-value-reference ?environment ?identifier ?op-p ?start)
     (value-reference ?identifier ?op-p ?start)
     (do (lispp (or ?op-p
                    (qualified-identifier-p ?identifier)
                    (not (infix-identifier-p ?environment ?identifier))))))


;;; Explicit fixity entries preserve the strict Definition grammar.  The
;;; separate batch-mode DCG admits only a complete final component/expression
;;; immediately before the existing EOF token; it is never a recovery rule.
(--> (batch-program-topdeclarations ?environment ?out-environment ?items ?end)
     (program-topdec-components ?environment ?next-environment ?components)
     (batch-program-components-tail ?environment ?next-environment ?out-environment
                                    ?components ?items ?end))
(--> (batch-program-components-tail ?environment ?next-environment ?out-environment
                                    ?components ?items ?end)
     (semicolon ?semicolon)
     (batch-program-topdeclarations ?next-environment ?out-environment ?rest ?end)
     (do (lisp ?item (if (cdr ?components)
                         (sequence-ast :topdec-sequence ?components (car (last ?components))
                                       :topdeclarations ?components)
                         (first ?components)))
         (= ?items (?item . ?rest))))
(--> (batch-program-components-tail ?environment ?next-environment ?out-environment
                                    ?components ?items ?end)
     (do (= ?out-environment ?next-environment))
     (end-of-input ?end)
     (do (lisp ?item (if (cdr ?components)
                         (sequence-ast :topdec-sequence ?components ?end
                                       :topdeclarations ?components)
                         (first ?components)))
         (= ?items (?item))))
(--> (batch-program-topdeclarations ?environment ?out-environment ?items ?end)
     (expression ?environment ?expression)
     (semicolon ?semicolon)
     (batch-program-topdeclarations ?environment ?out-environment ?rest ?end)
     (do (lisp ?it (make-identifier (list "it") (ast-node-span ?expression)))
         (lisp ?item (ast :toplevel-expression ?expression ?semicolon
                          :expression ?expression :binding-name ?it))
         (lisp ?items (cons ?item ?rest))))
(--> (batch-program-topdeclarations ?environment ?out-environment ?items ?end)
     (expression ?environment ?expression)
     (end-of-input ?end)
     (do (lisp ?it (make-identifier (list "it") (ast-node-span ?expression)))
         (lisp ?item (ast :toplevel-expression ?expression ?end
                          :expression ?expression :binding-name ?it))
         (lisp ?items (list ?item))))
(--> (batch-program-topdeclarations ?environment ?out-environment ?items ?end)
     (semicolon ?semicolon)
     (batch-program-topdeclarations ?environment ?out-environment ?rest ?end)
     (do (lisp ?item (empty-ast :topdec-structure ?semicolon :declarations nil))
         (lisp ?items (cons ?item ?rest))))
(--> (batch-program-topdeclarations ?environment ?environment nil ?end)
     (end-of-input ?end))

(--> (sml-program-with-fixities ?environment ?out-environment ?ast)
     (program-topdeclarations ?environment ?out-environment ?items)
     (end-of-input ?end)
     (do (lispp ?items)
         (lisp ?ast (ast :program (first ?items) ?end
                         :topdeclarations ?items))))
(--> (sml-program-with-omitted-final-semicolon ?environment ?out-environment ?ast)
     (batch-program-topdeclarations ?environment ?out-environment ?items ?end)
     (do (lisp ?ast (if ?items
                        (make-ast-node :program
                                       (join-spans (first ?items) ?end)
                                       :topdeclarations ?items)
                        (make-ast-node :program (token-span ?end)
                                       :topdeclarations nil)))))

;;; Public entries: each has a private initial fixity scope and consumes EOF.
(--> (sml-expression ?ast)
     (do (lisp ?environment (initial-fixity-environment)))
     (expression ?environment ?body)
     (end-of-input ?end)
     (do (= ?ast ?body)))
(--> (sml-declaration ?ast)
     (do (lisp ?environment (initial-fixity-environment)))
     (core-declaration-items ?environment ?ignored-environment ?items)
     (end-of-input ?end)
     (do (lisp ?ast (sequence-ast :declaration-sequence ?items ?end
                                  :declarations ?items))))
(--> (sml-structure-expression ?ast)
     (do (lisp ?environment (initial-fixity-environment)))
     (structure-expression ?environment ?body)
     (end-of-input ?end)
     (do (= ?ast ?body)))
(--> (sml-signature-expression ?ast)
     (do (lisp ?environment (initial-fixity-environment)))
     (signature-expression ?environment ?body)
     (end-of-input ?end)
     (do (= ?ast ?body)))
(--> (sml-specification ?ast)
     (do (lisp ?environment (initial-fixity-environment)))
     (specification-content ?environment ?ignored-environment ?items ?clauses)
     (end-of-input ?end)
     (do (lisp ?ast (make-specification-ast ?items ?clauses ?end))))
(--> (sml-program ?ast)
     (do (lisp ?environment (initial-fixity-environment)))
     (program-topdeclarations ?environment ?ignored-environment ?items)
     (end-of-input ?end)
     (do (lispp ?items)
         (lisp ?ast (ast :program (first ?items) ?end
                         :topdeclarations ?items))))


;;; Core expressions: layered exactly as Appendix B, with right-recursive DCG
;;; recognition for iterative forms and pure host construction afterward.
(--> (atomic-expression ?environment ?ast)
     (special-constant ?literal ?token)
     (do (lisp ?ast (ast :literal-expression ?token ?token :literal ?literal))))
(--> (atomic-expression ?environment ?ast)
     (atomic-value-reference ?environment ?identifier ?op-p ?start)
     (do (lisp ?ast (ast :identifier-expression ?start ?identifier
                         :identifier ?identifier :op-p ?op-p))))
(--> (atomic-expression ?environment ?ast)
     (symbol "{" ?open)
     (expression-record-rows ?environment ?rows)
     (symbol "}" ?close)
     (do (lispp (unique-rows-p ?rows))
         (lisp ?ast (ast :record-expression ?open ?close :rows ?rows))))
(--> (atomic-expression ?environment ?ast)
     (symbol "{" ?open)
     (symbol "}" ?close)
     (do (lisp ?ast (ast :record-expression ?open ?close :rows nil))))
(--> (atomic-expression ?environment ?ast)
     (symbol "#" ?sharp)
     (label ?label)
     (do (lisp ?ast (ast :selector-expression ?sharp ?label :label ?label))))
(--> (atomic-expression ?environment ?ast)
     (symbol "(" ?open)
     (symbol ")" ?close)
     (do (lisp ?ast (ast :unit-expression ?open ?close))))
(--> (atomic-expression ?environment ?ast)
     (symbol "(" ?open)
     (expression ?environment ?first)
     (parenthesized-expression-tail ?environment ?close ?kind ?rest)
     !
     (do (lisp ?ast
               (case ?kind
                 (:grouped (ast :grouped-expression ?open ?close :expression ?first))
                 (:tuple (ast :tuple-expression ?open ?close
                              :expressions (cons ?first ?rest)))
                 (:sequence (ast :sequence-expression ?open ?close
                                 :expressions (cons ?first ?rest)))))))
(--> (parenthesized-expression-tail ?environment ?close :grouped nil)
     (symbol ")" ?close))
(--> (parenthesized-expression-tail ?environment ?close :tuple ?rest)
     (comma ?comma)
     (comma-separated-expressions ?environment ?rest)
     (symbol ")" ?close))
(--> (parenthesized-expression-tail ?environment ?close :sequence ?rest)
     (semicolon ?semicolon)
     (semicolon-separated-expressions ?environment ?rest)
     (symbol ")" ?close))
(--> (atomic-expression ?environment ?ast)
     (symbol "[" ?open)
     (optional-comma-expressions ?environment ?expressions)
     (symbol "]" ?close)
     (do (lisp ?ast (ast :list-expression ?open ?close
                         :expressions ?expressions))))
(--> (atomic-expression ?environment ?ast)
     (keyword "let" ?let)
     (core-declaration-items ?environment ?inner-environment ?declarations)
     (keyword "in" ?in)
     (semicolon-separated-expressions-with-environment ?inner-environment ?expressions)
     (keyword "end" ?end)
     (do (lisp ?ast (ast :let-expression ?let ?end
                         :declarations ?declarations :expressions ?expressions))))

(--> (expression-record-rows ?environment ?rows)
     (expression-record-row ?environment ?row)
     (comma ?comma)
     (expression-record-rows ?environment ?rest)
     (do (lisp ?rows (cons ?row ?rest))))
(--> (expression-record-rows ?environment ?rows)
     (expression-record-row ?environment ?row)
     (do (lisp ?rows (list ?row))))
(--> (expression-record-row ?environment ?row)
     (label ?label)
     (symbol "=" ?equals)
     (expression ?environment ?expression)
     (do (lisp ?row (ast :expression-row ?label ?expression
                         :label ?label :expression ?expression))))

(--> (comma-separated-expressions ?environment ?expressions)
     (expression ?environment ?expression)
     (comma-expression-tail ?environment ?rest)
     (do (lisp ?expressions (cons ?expression ?rest))))
(--> (comma-expression-tail ?environment ?expressions)
     (comma ?comma)
     (expression ?environment ?expression)
     (comma-expression-tail ?environment ?rest)
     (do (lisp ?expressions (cons ?expression ?rest))))
(--> (comma-expression-tail ?environment ?expressions)
     (do (= ?expressions nil)))
(--> (optional-comma-expressions ?environment ?expressions)
     (comma-separated-expressions ?environment ?expressions))
(--> (optional-comma-expressions ?environment ?expressions)
     (do (= ?expressions nil)))
(--> (semicolon-separated-expressions-with-environment ?environment ?expressions)
     (expression ?environment ?expression)
     (semicolon-expression-tail ?environment ?rest)
     (do (lisp ?expressions (cons ?expression ?rest))))
(--> (semicolon-separated-expressions ?environment ?expressions)
     (semicolon-separated-expressions-with-environment ?environment ?expressions))
(--> (semicolon-expression-tail ?environment ?expressions)
     (semicolon ?semicolon)
     (expression ?environment ?expression)
     (semicolon-expression-tail ?environment ?rest)
     (do (lisp ?expressions (cons ?expression ?rest))))
(--> (semicolon-expression-tail ?environment ?expressions)
     (do (= ?expressions nil)))

(--> (application-expression ?environment ?ast)
     (atomic-expression ?environment ?function)
     (application-arguments ?environment ?arguments)
     !
     (do (lisp ?ast (fold-application ?function ?arguments))))
(--> (application-arguments ?environment ?arguments)
     (atomic-expression ?environment ?argument)
     (application-arguments ?environment ?rest)
     (do (lisp ?arguments (cons ?argument ?rest))))
(--> (application-arguments ?environment ?arguments)
     (do (= ?arguments nil)))

(--> (infix-expression ?environment ?ast)
     (application-expression ?environment ?first)
     (infix-expression-tail ?environment ?tail)
     (do (lisp ?series (make-series ?first ?tail))
         (lisp ?ast (resolve-expression-infix ?series ?environment))
         (lispp ?ast)))
(--> (infix-expression-tail ?environment ?tail)
     (value-reference ?identifier ?op-p ?operator-start)
     (do (lispp (infix-identifier-p ?environment ?identifier ?op-p)))
     (application-expression ?environment ?operand)
     (infix-expression-tail ?environment ?rest)
     (do (lisp ?item (make-series-tail ?identifier ?op-p ?operand))
         (lisp ?tail (cons ?item ?rest))))
(--> (infix-expression-tail ?environment ?tail)
     (do (= ?tail nil)))

(--> (typed-expression ?environment ?ast)
     (infix-expression ?environment ?base)
     (typed-expression-tail ?environment ?base ?ast))
(--> (typed-expression-tail ?environment ?base ?ast)
     (symbol ":" ?colon)
     (type-expression ?type)
     (do (lisp ?typed (ast :typed-expression ?base ?type
                           :expression ?base :type ?type)))
     (typed-expression-tail ?environment ?typed ?ast))
(--> (typed-expression-tail ?environment ?base ?ast)
     (do (= ?ast ?base)))

(--> (andalso-expression ?environment ?ast)
     (typed-expression ?environment ?left)
     (andalso-expression-tail ?environment ?left ?ast))
(--> (andalso-expression-tail ?environment ?left ?ast)
     (keyword "andalso" ?andalso)
     (andalso-expression ?environment ?right)
     (do (lisp ?ast (make-fnode :andalso-expression ?left ?right))))
(--> (andalso-expression-tail ?environment ?base ?ast)
     (do (= ?ast ?base)))
(--> (orelse-expression ?environment ?ast)
     (andalso-expression ?environment ?left)
     (orelse-expression-tail ?environment ?left ?ast))
(--> (orelse-expression-tail ?environment ?left ?ast)
     (keyword "orelse" ?orelse)
     (orelse-expression ?environment ?right)
     (do (lisp ?ast (make-fnode :orelse-expression ?left ?right))))
(--> (orelse-expression-tail ?environment ?base ?ast)
     (do (= ?ast ?base)))
(--> (handled-expression ?environment ?ast)
     (orelse-expression ?environment ?expression)
     (handled-expression-tail ?environment ?expression ?ast))
(--> (handled-expression-tail ?environment ?expression ?ast)
     (keyword "handle" ?handle)
     (match ?environment ?match)
     (do (lisp ?ast (ast :handle-expression ?expression ?match
                         :expression ?expression :match ?match))))
(--> (handled-expression-tail ?environment ?base ?ast)
     (do (= ?ast ?base)))

(--> (expression ?environment ?ast)
     (keyword "raise" ?raise)
     (expression ?environment ?expression)
     (do (lisp ?ast (ast :raise-expression ?raise ?expression
                         :expression ?expression))))
(--> (expression ?environment ?ast)
     (keyword "if" ?if)
     (expression ?environment ?condition)
     (keyword "then" ?then)
     (expression ?environment ?then-expression)
     (keyword "else" ?else)
     (expression ?environment ?else-expression)
     (do (lisp ?ast (ast :if-expression ?if ?else-expression
                         :condition ?condition :then ?then-expression
                         :else ?else-expression))))
(--> (expression ?environment ?ast)
     (keyword "while" ?while)
     (expression ?environment ?condition)
     (keyword "do" ?do)
     (expression ?environment ?body)
     (do (lisp ?ast (ast :while-expression ?while ?body
                         :condition ?condition :body ?body))))
(--> (expression ?environment ?ast)
     (keyword "case" ?case)
     (expression ?environment ?scrutinee)
     (keyword "of" ?of)
     (match ?environment ?match)
     (do (lisp ?ast (ast :case-expression ?case ?match
                         :expression ?scrutinee :match ?match))))
(--> (expression ?environment ?ast)
     (keyword "fn" ?fn)
     (match ?environment ?match)
     (do (lisp ?ast (ast :fn-expression ?fn ?match :match ?match))))
(--> (expression ?environment ?ast)
     (handled-expression ?environment ?ast))

(--> (match ?environment ?ast)
     (match-rule ?environment ?first)
     (match-tail ?environment ?first ?rest ?last)
     (do (lisp ?ast (ast :match ?first ?last
                         :rules (cons ?first ?rest)))))
(--> (match-tail ?environment ?previous ?rules ?last)
     (vertical-bar ?bar)
     (match-rule ?environment ?rule)
     (match-tail ?environment ?rule ?rest ?last)
     !
     (do (= ?rules (?rule . ?rest))))
(--> (match-tail ?environment ?previous ?rules ?last)
     (do (= ?rules nil)
         (= ?last ?previous)))
(--> (match-rule ?environment ?ast)
     (pattern ?environment ?pattern)
     (symbol "=>" ?arrow)
     (expression ?environment ?expression)
     (do (lisp ?ast (ast :match-rule ?pattern ?expression
                         :pattern ?pattern :expression ?expression))))

;;; Core patterns.  Application has exactly one atomic argument, as in SML'97;
;;; apparent curried construction is deliberately not accepted.
(--> (atomic-pattern ?environment ?ast)
     (symbol "_" ?underscore)
     (do (lisp ?ast (ast :wildcard-pattern ?underscore ?underscore))))
(--> (atomic-pattern ?environment ?ast)
     (special-constant ?literal ?token)
     (do (lispp (not (eq (literal-kind ?literal) :real)))
         (lisp ?ast (ast :literal-pattern ?token ?token :literal ?literal))))
(--> (atomic-pattern ?environment ?ast)
     (atomic-value-reference ?environment ?identifier ?op-p ?start)
     (do (lisp ?ast (ast :identifier-pattern ?start ?identifier
                         :identifier ?identifier :op-p ?op-p))))
(--> (atomic-pattern ?environment ?ast)
     (symbol "{" ?open)
     (pattern-record-content ?environment ?rows ?wildcard-p)
     (symbol "}" ?close)
     (do (lispp (unique-rows-p ?rows))
         (lisp ?ast (ast :record-pattern ?open ?close
                         :rows ?rows :wildcard-p ?wildcard-p))))
(--> (atomic-pattern ?environment ?ast)
     (symbol "{" ?open)
     (symbol "}" ?close)
     (do (lisp ?ast (ast :record-pattern ?open ?close
                         :rows nil :wildcard-p nil))))
(--> (atomic-pattern ?environment ?ast)
     (symbol "(" ?open)
     (symbol ")" ?close)
     (do (lisp ?ast (ast :unit-pattern ?open ?close))))
(--> (atomic-pattern ?environment ?ast)
     (symbol "(" ?open)
     (comma-separated-patterns ?environment ?patterns)
     (symbol ")" ?close)
     (do (lisp ?ast (if (cdr ?patterns)
                        (ast :tuple-pattern ?open ?close :patterns ?patterns)
                        (ast :grouped-pattern ?open ?close
                             :pattern (first ?patterns))))))
(--> (atomic-pattern ?environment ?ast)
     (symbol "[" ?open)
     (optional-comma-patterns ?environment ?patterns)
     (symbol "]" ?close)
     (do (lisp ?ast (ast :list-pattern ?open ?close :patterns ?patterns))))

(--> (pattern-record-content ?environment ?rows ?wildcard-p)
     (symbol "..." ?ellipsis)
     (do (= ?rows nil) (= ?wildcard-p t)))
(--> (pattern-record-content ?environment ?rows ?wildcard-p)
     (pattern-record-rows ?environment ?rows)
     (optional-pattern-record-wildcard ?wildcard-p))
(--> (optional-pattern-record-wildcard ?wildcard-p)
     (comma ?comma)
     (symbol "..." ?ellipsis)
     (do (= ?wildcard-p t)))
(--> (optional-pattern-record-wildcard ?wildcard-p)
     (do (= ?wildcard-p nil)))
(--> (pattern-record-rows ?environment ?rows)
     (pattern-record-row ?environment ?row)
     (comma ?comma)
     (pattern-record-rows ?environment ?rest)
     (do (lisp ?rows (cons ?row ?rest))))
(--> (pattern-record-rows ?environment ?rows)
     (pattern-record-row ?environment ?row)
     (do (lisp ?rows (list ?row))))
(--> (pattern-record-row ?environment ?row)
     (label ?label)
     (symbol "=" ?equals)
     (pattern ?environment ?pattern)
     (do (lisp ?row (ast :pattern-row ?label ?pattern
                         :label ?label :pattern ?pattern :pun-p nil))))
(--> (pattern-record-row ?environment ?row)
     (value-identifier ?identifier ?token)
     (optional-pattern-type ?type)
     (optional-as-pattern ?environment ?as-pattern)
     (do (lisp ?label (ast :label ?token ?token
                           :name (identifier-name ?identifier)))
         (lisp ?base (ast :identifier-pattern ?token ?identifier
                          :identifier ?identifier :op-p nil))
         (lisp ?typed (if ?type
                          (ast :typed-pattern ?base ?type :pattern ?base :type ?type)
                          ?base))
         (lisp ?pattern (if ?as-pattern
                            (ast :layered-pattern ?token ?as-pattern
                                 :identifier ?identifier :op-p nil :type ?type
                                 :pattern ?as-pattern)
                            ?typed))
         (lisp ?row (ast :pattern-row ?label ?pattern
                         :label ?label :pattern ?pattern :pun-p t))))
(--> (optional-pattern-type ?type)
     (symbol ":" ?colon)
     (type-expression ?type))
(--> (optional-pattern-type ?type)
     (do (= ?type nil)))
(--> (optional-as-pattern ?environment ?pattern)
     (keyword "as" ?as)
     (pattern ?environment ?pattern))
(--> (optional-as-pattern ?environment ?pattern)
     (do (= ?pattern nil)))

(--> (comma-separated-patterns ?environment ?patterns)
     (pattern ?environment ?pattern)
     (comma-pattern-tail ?environment ?rest)
     (do (lisp ?patterns (cons ?pattern ?rest))))
(--> (comma-pattern-tail ?environment ?patterns)
     (comma ?comma)
     (pattern ?environment ?pattern)
     (comma-pattern-tail ?environment ?rest)
     (do (lisp ?patterns (cons ?pattern ?rest))))
(--> (comma-pattern-tail ?environment ?patterns)
     (do (= ?patterns nil)))
(--> (optional-comma-patterns ?environment ?patterns)
     (comma-separated-patterns ?environment ?patterns))
(--> (optional-comma-patterns ?environment ?patterns)
     (do (= ?patterns nil)))

(--> (constructed-or-atomic-pattern ?environment ?ast)
     (atomic-value-reference ?environment ?constructor ?op-p ?start)
     (atomic-pattern ?environment ?argument)
     (do (lisp ?ast (ast :construct-pattern ?start ?argument
                         :constructor ?constructor :op-p ?op-p :argument ?argument))))
(--> (constructed-or-atomic-pattern ?environment ?ast)
     (atomic-pattern ?environment ?ast))
(--> (infix-pattern ?environment ?ast)
     (constructed-or-atomic-pattern ?environment ?first)
     (infix-pattern-tail ?environment ?tail)
     (do (lisp ?series (make-series ?first ?tail))
         (lisp ?ast (resolve-pattern-infix ?series ?environment))
         (lispp ?ast)))
(--> (infix-pattern-tail ?environment ?tail)
     (value-reference ?identifier ?op-p ?operator-start)
     ;; Equality is not a constructor; in particular, do not consume VAL's
     ;; delimiter as an infix-pattern operator before parsing its expression.
     (do (lispp (not (string= "=" (identifier-name ?identifier)))))
     (constructed-or-atomic-pattern ?environment ?operand)
     (infix-pattern-tail ?environment ?rest)
     (do (lisp ?item (make-series-tail ?identifier ?op-p ?operand))
         (lisp ?tail (cons ?item ?rest))))
(--> (infix-pattern-tail ?environment ?tail)
     (do (= ?tail nil)))

(--> (typed-pattern ?environment ?ast)
     (infix-pattern ?environment ?base)
     (typed-pattern-tail ?base ?ast))
(--> (typed-pattern-tail ?base ?ast)
     (symbol ":" ?colon)
     (type-expression ?type)
     (do (lisp ?typed (ast :typed-pattern ?base ?type
                           :pattern ?base :type ?type)))
     (typed-pattern-tail ?typed ?ast))
(--> (typed-pattern-tail ?base ?ast)
     (do (= ?ast ?base)))
(--> (pattern ?environment ?ast)
     (atomic-value-reference ?environment ?identifier ?op-p ?start)
     (do (lispp (not (qualified-identifier-p ?identifier))))
     (optional-pattern-type ?type)
     (keyword "as" ?as)
     (pattern ?environment ?nested)
     (do (lisp ?ast (ast :layered-pattern ?start ?nested
                         :identifier ?identifier :op-p ?op-p
                         :type ?type :pattern ?nested))))
(--> (pattern ?environment ?ast)
     (typed-pattern ?environment ?ast))

;;; Type expressions.  :TYPE-ARGUMENT-SEQUENCE is a transient native node for
;;; `(ty1,...,tyn) longtycon`; VALID-TYPE-BASE-P prevents it escaping without
;;; the required constructor.  Function arrows associate right, tuples are flat.
(--> (type-expression ?ast)
     (product-type ?domain)
     (symbol "->" ?arrow)
     (type-expression ?range)
     (do (lisp ?ast (ast :function-type ?domain ?range
                         :domain ?domain :range ?range))))
(--> (type-expression ?ast)
     (product-type ?ast))
(--> (product-type ?ast)
     (postfix-type ?first)
     (product-type-tail ?rest)
     (do (lisp ?ast (if ?rest
                        (ast :tuple-type ?first (car (last ?rest))
                             :types (cons ?first ?rest))
                        ?first))))
(--> (product-type-tail ?rest)
     (symbol "*" ?star)
     (postfix-type ?next)
     (product-type-tail ?tail)
     (do (lisp ?rest (cons ?next ?tail))))
(--> (product-type-tail ?rest)
     (do (= ?rest nil)))
(--> (postfix-type ?ast)
     (type-atom ?base)
     (type-constructor-suffix ?constructors)
     (do (lispp (valid-type-base-p ?base ?constructors))
         (lisp ?ast (fold-type-constructors ?base ?constructors))))
(--> (type-constructor-suffix ?constructors)
     (long-type-constructor ?constructor ?token)
     (type-constructor-suffix ?rest)
     (do (lisp ?constructors (cons ?constructor ?rest))))
(--> (type-constructor-suffix ?constructors)
     (do (= ?constructors nil)))
(--> (type-atom ?ast)
     (type-variable ?identifier ?token)
     (do (lisp ?ast (ast :type-variable ?token ?identifier
                         :identifier ?identifier))))
(--> (type-atom ?ast)
     (long-type-constructor ?constructor ?token)
     (do (lisp ?ast (ast :constructed-type ?token ?constructor
                         :arguments nil :constructor ?constructor))))
(--> (type-atom ?ast)
     (symbol "{" ?open)
     (type-record-rows ?rows)
     (symbol "}" ?close)
     (do (lispp (unique-rows-p ?rows))
         (lisp ?ast (ast :record-type ?open ?close :rows ?rows))))
(--> (type-atom ?ast)
     (symbol "{" ?open)
     (symbol "}" ?close)
     (do (lisp ?ast (ast :record-type ?open ?close :rows nil))))
(--> (type-atom ?ast)
     (symbol "(" ?open)
     (comma-separated-types ?types)
     (symbol ")" ?close)
     (do (lisp ?ast (if (cdr ?types)
                        (ast :type-argument-sequence ?open ?close :types ?types)
                        (ast :grouped-type ?open ?close :type (first ?types))))))
(--> (type-record-rows ?rows)
     (type-record-row ?row)
     (comma ?comma)
     (type-record-rows ?rest)
     (do (lisp ?rows (cons ?row ?rest))))
(--> (type-record-rows ?rows)
     (type-record-row ?row)
     (do (lisp ?rows (list ?row))))
(--> (type-record-row ?row)
     (label ?label)
     (symbol ":" ?colon)
     (type-expression ?type)
     (do (lisp ?row (ast :type-row ?label ?type :label ?label :type ?type))))
(--> (comma-separated-types ?types)
     (type-expression ?type)
     (comma-type-tail ?rest)
     (do (lisp ?types (cons ?type ?rest))))
(--> (comma-type-tail ?types)
     (comma ?comma)
     (type-expression ?type)
     (comma-type-tail ?rest)
     (do (lisp ?types (cons ?type ?rest))))
(--> (comma-type-tail ?types)
     (do (= ?types nil)))

(--> (typed-variable-sequence ?variables)
     (type-variable ?variable ?token)
     (do (lisp ?variables (list ?variable))))
(--> (typed-variable-sequence ?variables)
     (symbol "(" ?open)
     (comma-separated-type-variables ?variables)
     (symbol ")" ?close)
     (do (lispp (unique-identifiers-p ?variables))))
(--> (typed-variable-sequence ?variables)
     (do (= ?variables nil)))
(--> (comma-separated-type-variables ?variables)
     (type-variable ?variable ?token)
     (comma-type-variable-tail ?rest)
     (do (lisp ?variables (cons ?variable ?rest))))
(--> (comma-type-variable-tail ?variables)
     (comma ?comma)
     (type-variable ?variable ?token)
     (comma-type-variable-tail ?rest)
     (do (lisp ?variables (cons ?variable ?rest))))
(--> (comma-type-variable-tail ?variables)
     (do (= ?variables nil)))

;;; Value and function-value bindings.  Prefix function names which have
;;; fixity require OP; infix heads require actual unqualified infix status.
(--> (value-binding ?environment ?binding)
     (pattern ?environment ?pattern)
     (symbol "=" ?equals)
     (expression ?environment ?expression)
     (do (lisp ?binding (ast :value-binding ?pattern ?expression
                             :pattern ?pattern :expression ?expression
                             :recursive-p nil))))
(--> (value-binding ?environment ?binding)
     (keyword "rec" ?rec)
     (pattern ?environment ?pattern)
     (symbol "=" ?equals)
     (expression ?environment ?expression)
     (do (lisp ?binding (ast :value-binding ?pattern ?expression
                             :pattern ?pattern :expression ?expression
                             :recursive-p t))))
(--> (value-bindings ?environment ?bindings)
     (value-binding ?environment ?binding)
     (value-bindings-tail ?environment ?binding ?bindings))
(--> (value-bindings-tail ?environment ?binding ?bindings)
     (keyword "and" ?and)
     (value-bindings ?environment ?rest)
     (do (= ?bindings (?binding . ?rest))))
(--> (value-bindings-tail ?environment ?binding ?bindings)
     (do (= ?bindings (?binding))))
(--> (optional-recursive-marker ?recursive-p)
     (keyword "rec" ?rec)
     (do (= ?recursive-p t)))
(--> (optional-recursive-marker ?recursive-p)
     (do (= ?recursive-p nil)))

(--> (function-name ?identifier ?op-p ?start)
     (keyword "op" ?op)
     (value-identifier ?identifier ?token)
     (do (= ?op-p t) (= ?start ?op)))
(--> (function-name ?identifier ?op-p ?start)
     (value-identifier ?identifier ?start)
     (do (= ?op-p nil)))
(--> (prefix-function-name ?environment ?identifier ?op-p ?start)
     (function-name ?identifier ?op-p ?start)
     (do (lispp (or ?op-p (not (infix-identifier-p ?environment ?identifier))))))
(--> (atomic-pattern-arguments ?environment ?arguments)
     (atomic-pattern ?environment ?argument)
     (atomic-pattern-arguments ?environment ?rest)
     (do (lisp ?arguments (cons ?argument ?rest))))
(--> (atomic-pattern-arguments ?environment ?arguments)
     (do (= ?arguments nil)))
(--> (required-atomic-pattern-arguments ?environment ?arguments)
     (atomic-pattern ?environment ?argument)
     (atomic-pattern-arguments ?environment ?rest)
     (do (lisp ?arguments (cons ?argument ?rest))))
(--> (optional-result-type ?type)
     (symbol ":" ?colon)
     (type-expression ?type))
(--> (optional-result-type ?type)
     (do (= ?type nil)))

(--> (function-clause ?environment ?clause)
     (prefix-function-name ?environment ?name ?op-p ?start)
     (required-atomic-pattern-arguments ?environment ?arguments)
     (optional-result-type ?result-type)
     (symbol "=" ?equals)
     (expression ?environment ?expression)
     (do (lisp ?clause (ast :function-clause ?start ?expression
                            :name ?name :op-p ?op-p :arguments ?arguments
                            :result-type ?result-type :expression ?expression
                            :infix-head-p nil))))
(--> (function-clause ?environment ?clause)
     (symbol "(" ?open)
     (atomic-pattern ?environment ?left)
     (value-identifier ?name ?name-token)
     (do (lispp (infix-identifier-p ?environment ?name)))
     (atomic-pattern ?environment ?right)
     (symbol ")" ?close)
     (atomic-pattern-arguments ?environment ?extra)
     (optional-result-type ?result-type)
     (symbol "=" ?equals)
     (expression ?environment ?expression)
     (do (lisp ?arguments (append (list ?left ?right) ?extra))
         (lisp ?clause (ast :function-clause ?open ?expression
                            :name ?name :op-p nil :arguments ?arguments
                            :result-type ?result-type :expression ?expression
                            :infix-head-p t))))
(--> (function-clause ?environment ?clause)
     (atomic-pattern ?environment ?left)
     (value-identifier ?name ?name-token)
     (do (lispp (infix-identifier-p ?environment ?name)))
     (atomic-pattern ?environment ?right)
     (optional-result-type ?result-type)
     (symbol "=" ?equals)
     (expression ?environment ?expression)
     (do (lisp ?arguments (list ?left ?right))
         (lisp ?clause (ast :function-clause ?left ?expression
                            :name ?name :op-p nil :arguments ?arguments
                            :result-type ?result-type :expression ?expression
                            :infix-head-p t))))
(--> (function-clauses ?environment ?clauses)
     (function-clause ?environment ?clause)
     (function-clauses-tail ?environment ?clause ?clauses))
(--> (function-clauses-tail ?environment ?clause ?clauses)
     (vertical-bar ?bar)
     (function-clauses ?environment ?rest)
     (do (= ?clauses (?clause . ?rest))))
(--> (function-clauses-tail ?environment ?clause ?clauses)
     (do (= ?clauses (?clause))))
(--> (function-bindings ?environment ?bindings)
     (function-clauses ?environment ?clauses)
     (function-bindings-tail ?environment ?clauses ?bindings))
(--> (function-bindings-tail ?environment ?clauses ?bindings)
     (keyword "and" ?and)
     (function-bindings ?environment ?rest)
     (do (lisp ?binding (make-function-binding ?clauses))
         (= ?bindings (?binding . ?rest))))
(--> (function-bindings-tail ?environment ?clauses ?bindings)
     (do (lisp ?binding (make-function-binding ?clauses))
         (= ?bindings (?binding))))

;;; Type, datatype, constructor, and exception bindings.
(--> (type-binding ?binding)
     (typed-variable-sequence ?variables)
     (type-constructor ?name ?name-token)
     (symbol "=" ?equals)
     (type-expression ?type)
     (do (lisp ?binding (ast :type-binding (binding-start ?variables ?name-token) ?type
                             :variables ?variables :name ?name :type ?type))))
(--> (type-bindings ?bindings)
     (type-binding ?binding)
     (keyword "and" ?and)
     (type-bindings ?rest)
     (do (lisp ?bindings (cons ?binding ?rest))))
(--> (type-bindings ?bindings)
     (type-binding ?binding)
     (do (lisp ?bindings (list ?binding))))
(--> (optional-withtypes ?bindings)
     (keyword "withtype" ?withtype)
     (type-bindings ?bindings))
(--> (optional-withtypes ?bindings)
     (do (= ?bindings nil)))

(--> (constructor-binding ?binding)
     (function-name ?name ?op-p ?start)
     (keyword "of" ?of)
     (type-expression ?type)
     (do (lisp ?binding (ast :constructor-binding ?start ?type
                             :name ?name :op-p ?op-p :type ?type))))
(--> (constructor-binding ?binding)
     (function-name ?name ?op-p ?start)
     (do (lisp ?binding (ast :constructor-binding ?start ?name
                             :name ?name :op-p ?op-p :type nil))))
(--> (constructor-bindings ?bindings)
     (constructor-binding ?binding)
     (constructor-bindings-tail ?binding ?bindings))
(--> (constructor-bindings-tail ?binding ?bindings)
     (vertical-bar ?bar)
     (constructor-bindings ?rest)
     (do (= ?bindings (?binding . ?rest))))
(--> (constructor-bindings-tail ?binding ?bindings)
     (do (= ?bindings (?binding))))
(--> (datatype-binding ?binding)
     (typed-variable-sequence ?variables)
     (type-constructor ?name ?name-token)
     (symbol "=" ?equals)
     (constructor-bindings ?bindings)
     (do (lisp ?binding (ast :datatype-binding (binding-start ?variables ?name-token)
                             (car (last ?bindings))
                             :variables ?variables :name ?name
                             :constructors ?bindings))))
(--> (datatype-bindings ?bindings)
     (datatype-binding ?binding)
     (datatype-bindings-tail ?binding ?bindings))
(--> (datatype-bindings-tail ?binding ?bindings)
     (keyword "and" ?and)
     (datatype-bindings ?rest)
     (do (= ?bindings (?binding . ?rest))))
(--> (datatype-bindings-tail ?binding ?bindings)
     (do (= ?bindings (?binding))))

(--> (exception-binding ?environment ?binding)
     (function-name ?name ?op-p ?start)
     (keyword "of" ?of)
     (type-expression ?type)
     (do (lisp ?binding (ast :exception-binding ?start ?type
                             :name ?name :op-p ?op-p :type ?type
                             :alias nil :alias-op-p nil))))
(--> (exception-binding ?environment ?binding)
     (function-name ?name ?op-p ?start)
     (symbol "=" ?equals)
     (atomic-value-reference ?environment ?alias ?alias-op-p ?alias-start)
     (do (lisp ?binding (ast :exception-binding ?start ?alias
                             :name ?name :op-p ?op-p :type nil
                             :alias ?alias :alias-op-p ?alias-op-p))))
(--> (exception-binding ?environment ?binding)
     (function-name ?name ?op-p ?start)
     (do (lisp ?binding (ast :exception-binding ?start ?name
                             :name ?name :op-p ?op-p :type nil
                             :alias nil :alias-op-p nil))))
(--> (exception-bindings ?environment ?bindings)
     (exception-binding ?environment ?binding)
     (keyword "and" ?and)
     (exception-bindings ?environment ?rest)
     (do (lisp ?bindings (cons ?binding ?rest))))
(--> (exception-bindings ?environment ?bindings)
     (exception-binding ?environment ?binding)
     (do (lisp ?bindings (list ?binding))))

;;; Identifier repetition and fixity directives.
(--> (value-identifiers ?identifiers)
     (value-identifier ?identifier ?token)
     (value-identifiers ?rest)
     (do (lisp ?identifiers (cons ?identifier ?rest))))
(--> (value-identifiers ?identifiers)
     (value-identifier ?identifier ?token)
     (do (lisp ?identifiers (list ?identifier))))
(--> (long-module-identifiers ?identifiers)
     (long-module-identifier ?identifier ?token)
     (long-module-identifiers ?rest)
     (do (lisp ?identifiers (cons ?identifier ?rest))))
(--> (long-module-identifiers ?identifiers)
     (long-module-identifier ?identifier ?token)
     (do (lisp ?identifiers (list ?identifier))))
(--> (optional-fixity-precedence ?precedence)
     '(?token)
     (do (lispp (eq (literal-token-kind ?token) :integer))
         (lispp (= (length (token-text ?token)) 1))
         (lisp ?precedence (digit-char-p (char (token-text ?token) 0)))
         (lispp ?precedence)))
(--> (optional-fixity-precedence ?precedence)
     (do (= ?precedence 0)))

;;; Core declarations.  Fixity state threads from left to right; LOCAL scopes
;;; both declaration parts, and non-fixity declarations preserve it exactly.
(--> (core-declaration-item ?environment ?environment ?ast)
     (keyword "val" ?val)
     (typed-variable-sequence ?variables)
     (keyword "rec" ?rec)
     (function-bindings ?environment ?bindings)
     (do (lisp ?ast (make-function-declaration ?val ?bindings ?variables))
         (lispp ?ast)))
(--> (core-declaration-item ?environment ?environment ?ast)
     (keyword "val" ?val)
     (typed-variable-sequence ?variables)
     (optional-recursive-marker ?recursive-p)
     (value-bindings ?environment ?bindings)
     (do (lisp ?ast (make-value-declaration ?val ?bindings ?variables ?recursive-p))
         (lispp ?ast)))
(--> (core-declaration-item ?environment ?environment ?ast)
     (keyword "fun" ?fun)
     (typed-variable-sequence ?variables)
     (function-bindings ?environment ?bindings)
     (do (lisp ?ast (make-function-declaration ?fun ?bindings ?variables))
         (lispp ?ast)))
(--> (core-declaration-item ?environment ?environment ?ast)
     (keyword "type" ?type)
     (type-bindings ?bindings)
     (do (lispp (type-bindings-valid-p ?bindings nil))
         (lisp ?ast (ast :type-declaration ?type (car (last ?bindings))
                         :bindings ?bindings))))
(--> (core-declaration-item ?environment ?environment ?ast)
     (keyword "datatype" ?datatype)
     (type-constructor ?name ?name-token)
     (symbol "=" ?equals)
     (keyword "datatype" ?second-datatype)
     (long-type-constructor ?source ?source-token)
     (do (lisp ?ast (ast :datatype-replication ?datatype ?source
                         :name ?name :source ?source))))
(--> (core-declaration-item ?environment ?environment ?ast)
     (keyword "datatype" ?datatype)
     (datatype-bindings ?bindings)
     (optional-withtypes ?withtypes)
     (do (lispp (datatype-bindings-valid-p ?bindings ?withtypes nil))
         (lisp ?last (if ?withtypes (car (last ?withtypes)) (car (last ?bindings))))
         (lisp ?ast (ast :datatype-declaration ?datatype ?last
                         :bindings ?bindings :withtypes ?withtypes))))
(--> (core-declaration-item ?environment ?out-environment ?ast)
     (keyword "abstype" ?abstype)
     (datatype-bindings ?bindings)
     (optional-withtypes ?withtypes)
     (keyword "with" ?with)
     (core-declaration-items ?environment ?out-environment ?declarations)
     (keyword "end" ?end)
     (do (lispp (datatype-bindings-valid-p ?bindings ?withtypes nil))
         (lisp ?ast (ast :abstype-declaration ?abstype ?end
                         :bindings ?bindings :withtypes ?withtypes
                         :declarations ?declarations))))
(--> (core-declaration-item ?environment ?environment ?ast)
     (keyword "exception" ?exception)
     (exception-bindings ?environment ?bindings)
     (do (lispp (exception-bindings-valid-p ?bindings nil))
         (lisp ?ast (ast :exception-declaration ?exception (car (last ?bindings))
                         :bindings ?bindings))))
(--> (core-declaration-item ?environment ?environment ?ast)
     (keyword "local" ?local)
     (core-declaration-items ?environment ?local-environment ?local-declarations)
     (keyword "in" ?in)
     (core-declaration-items ?local-environment ?ignored-environment ?body-declarations)
     (keyword "end" ?end)
     (do (lisp ?ast (ast :local-declaration ?local ?end
                         :local ?local-declarations :body ?body-declarations))))
(--> (core-declaration-item ?environment ?environment ?ast)
     (keyword "open" ?open)
     (long-module-identifiers ?identifiers)
     (do (lisp ?ast (ast :open-declaration ?open (car (last ?identifiers))
                         :identifiers ?identifiers))))
(--> (core-declaration-item ?environment ?out-environment ?ast)
     (keyword "infix" ?infix)
     (optional-fixity-precedence ?precedence)
     (value-identifiers ?identifiers)
     (do (lisp ?out-environment (extend-fixity ?environment ?identifiers :left ?precedence))
         (lisp ?ast (fixity-declaration ?infix ?identifiers ?precedence :left))))
(--> (core-declaration-item ?environment ?out-environment ?ast)
     (keyword "infixr" ?infix)
     (optional-fixity-precedence ?precedence)
     (value-identifiers ?identifiers)
     (do (lisp ?out-environment (extend-fixity ?environment ?identifiers :right ?precedence))
         (lisp ?ast (fixity-declaration ?infix ?identifiers ?precedence :right))))
(--> (core-declaration-item ?environment ?out-environment ?ast)
     (keyword "nonfix" ?nonfix)
     (value-identifiers ?identifiers)
     (do (lisp ?out-environment (extend-fixity ?environment ?identifiers :nonfix nil))
         (lisp ?ast (fixity-declaration ?nonfix ?identifiers nil :nonfix))))

(--> (core-declaration-items ?environment ?out-environment ?items)
     (core-declaration-item ?environment ?next-environment ?item)
     (core-declaration-tail ?next-environment ?out-environment ?rest)
     (do (= ?items (?item . ?rest))))
(--> (core-declaration-items ?environment ?out-environment ?items)
     (semicolon ?semicolon)
     (core-declaration-items ?environment ?out-environment ?items))
(--> (core-declaration-items ?environment ?environment ?items)
     (do (= ?items nil)))
(--> (core-declaration-tail ?environment ?out-environment ?items)
     (semicolon ?semicolon)
     (core-declaration-item ?environment ?next-environment ?item)
     (core-declaration-tail ?next-environment ?out-environment ?rest)
     (do (= ?items (?item . ?rest))))
(--> (core-declaration-tail ?environment ?out-environment ?items)
     (semicolon ?semicolon)
     (core-declaration-tail ?environment ?out-environment ?items))
(--> (core-declaration-tail ?environment ?out-environment ?items)
     (core-declaration-item ?environment ?next-environment ?item)
     (core-declaration-tail ?next-environment ?out-environment ?rest)
     (do (= ?items (?item . ?rest))))
(--> (core-declaration-tail ?environment ?environment ?items)
     (do (= ?items nil)))

;;; Structure expressions and structure-level declarations.  A basic STRUCT,
;;; structure LET, and structure LOCAL all delimit fixity scope (Definition 3.3).
(--> (structure-expression ?environment ?ast)
     (structure-primary ?environment ?base)
     (structure-constraint-tail ?environment ?base ?ast))
(--> (structure-primary ?environment ?ast)
     (keyword "struct" ?struct)
     (structure-declaration-items ?environment ?inner-environment ?declarations)
     (keyword "end" ?end)
     (do (lisp ?ast (ast :basic-structure ?struct ?end :declarations ?declarations))))
(--> (structure-primary ?environment ?ast)
     (keyword "let" ?let)
     (structure-declaration-items ?environment ?inner-environment ?declarations)
     (keyword "in" ?in)
     (structure-expression ?inner-environment ?body)
     (keyword "end" ?end)
     (do (lisp ?ast (ast :let-structure ?let ?end
                         :declarations ?declarations :body ?body))))
(--> (structure-primary ?environment ?ast)
     (module-identifier ?functor ?functor-token)
     (symbol "(" ?open)
     (structure-expression ?environment ?argument)
     (symbol ")" ?close)
     (do (lisp ?ast (ast :functor-application ?functor ?close
                         :functor ?functor :argument ?argument :declarations nil))))
(--> (structure-primary ?environment ?ast)
     (module-identifier ?functor ?functor-token)
     (symbol "(" ?open)
     (structure-declaration-items ?environment ?inner-environment ?declarations)
     (symbol ")" ?close)
     (do (lisp ?ast (ast :functor-application ?functor ?close
                         :functor ?functor :argument nil :declarations ?declarations))))
(--> (structure-primary ?environment ?ast)
     (long-module-identifier ?identifier ?token)
     (do (lisp ?ast (ast :structure-identifier ?token ?identifier
                         :identifier ?identifier))))
(--> (structure-constraint-tail ?environment ?base ?ast)
     (symbol ":" ?colon)
     (signature-expression ?environment ?signature)
     (do (lisp ?constrained (ast :constrained-structure ?base ?signature
                                 :structure ?base :signature ?signature
                                 :opaque-p nil)))
     (structure-constraint-tail ?environment ?constrained ?ast))
(--> (structure-constraint-tail ?environment ?base ?ast)
     (symbol ":>" ?colon)
     (signature-expression ?environment ?signature)
     (do (lisp ?constrained (ast :constrained-structure ?base ?signature
                                 :structure ?base :signature ?signature
                                 :opaque-p t)))
     (structure-constraint-tail ?environment ?constrained ?ast))
(--> (structure-constraint-tail ?environment ?base ?ast)
     (do (= ?ast ?base)))

(--> (optional-structure-signature ?environment ?signature ?opaque-p)
     (symbol ":" ?colon)
     (signature-expression ?environment ?signature)
     (do (= ?opaque-p nil)))
(--> (optional-structure-signature ?environment ?signature ?opaque-p)
     (symbol ":>" ?colon)
     (signature-expression ?environment ?signature)
     (do (= ?opaque-p t)))
(--> (optional-structure-signature ?environment ?signature ?opaque-p)
     (do (= ?signature nil) (= ?opaque-p nil)))
(--> (structure-binding ?environment ?binding)
     (module-identifier ?name ?name-token)
     (optional-structure-signature ?environment ?signature ?opaque-p)
     (symbol "=" ?equals)
     (structure-expression ?environment ?structure)
     (do (lisp ?binding (ast :structure-binding ?name-token ?structure
                             :name ?name :signature ?signature :opaque-p ?opaque-p
                             :structure ?structure))))
(--> (structure-bindings ?environment ?bindings)
     (structure-binding ?environment ?binding)
     (keyword "and" ?and)
     (structure-bindings ?environment ?rest)
     (do (lisp ?bindings (cons ?binding ?rest))))
(--> (structure-bindings ?environment ?bindings)
     (structure-binding ?environment ?binding)
     (do (lisp ?bindings (list ?binding))))

(--> (structure-declaration-item ?environment ?out-environment ?ast)
     (core-declaration-item ?environment ?out-environment ?ast))
(--> (structure-declaration-item ?environment ?environment ?ast)
     (keyword "structure" ?structure)
     (structure-bindings ?environment ?bindings)
     (do (lispp (unique-identifiers-p (semantic-bindings ?bindings :name)))
         (lisp ?ast (ast :structure-declaration ?structure (car (last ?bindings))
                         :bindings ?bindings))))
(--> (structure-declaration-item ?environment ?environment ?ast)
     (keyword "local" ?local)
     (structure-declaration-items ?environment ?local-environment ?local-declarations)
     (keyword "in" ?in)
     (structure-declaration-items ?local-environment ?ignored-environment ?body-declarations)
     (keyword "end" ?end)
     (do (lisp ?ast (ast :local-structure-declaration ?local ?end
                         :local ?local-declarations :body ?body-declarations))))
(--> (structure-declaration-items ?environment ?out-environment ?items)
     (structure-declaration-item ?environment ?next-environment ?item)
     (structure-declaration-tail ?next-environment ?out-environment ?rest)
     (do (= ?items (?item . ?rest))))
(--> (structure-declaration-items ?environment ?out-environment ?items)
     (semicolon ?semicolon)
     (structure-declaration-items ?environment ?out-environment ?items))
(--> (structure-declaration-items ?environment ?environment ?items)
     (do (= ?items nil)))
(--> (structure-declaration-tail ?environment ?out-environment ?items)
     (semicolon ?semicolon)
     (structure-declaration-item ?environment ?next-environment ?item)
     ! (structure-declaration-tail ?next-environment ?out-environment ?rest)
     (do (= ?items (?item . ?rest))))
(--> (structure-declaration-tail ?environment ?out-environment ?items)
     (semicolon ?semicolon)
     (structure-declaration-tail ?environment ?out-environment ?items))
(--> (structure-declaration-tail ?environment ?out-environment ?items)
     (structure-declaration-item ?environment ?next-environment ?item)
     ! (structure-declaration-tail ?next-environment ?out-environment ?rest)
     (do (= ?items (?item . ?rest))))
(--> (structure-declaration-tail ?environment ?environment ?items)
     (do (= ?items nil)))

;;; Descriptions and specifications.  Description groups and consecutive
;;; explicit specifications enforce their respective uniqueness restrictions.
(--> (value-description ?description)
     (value-identifier ?name ?name-token)
     (symbol ":" ?colon)
     (type-expression ?type)
     (do (lisp ?description (ast :value-description ?name-token ?type
                                 :name ?name :type ?type))))
(--> (value-descriptions ?descriptions)
     (value-description ?description)
     (keyword "and" ?and)
     (value-descriptions ?rest)
     (do (lisp ?descriptions (cons ?description ?rest))))
(--> (value-descriptions ?descriptions)
     (value-description ?description)
     (do (lisp ?descriptions (list ?description))))
(--> (optional-type-definition ?type)
     (symbol "=" ?equals)
     (type-expression ?type))
(--> (optional-type-definition ?type)
     (do (= ?type nil)))
(--> (type-description ?description)
     (typed-variable-sequence ?variables)
     (type-constructor ?name ?name-token)
     (optional-type-definition ?type)
     (do (lisp ?last (or ?type ?name))
         (lisp ?description (ast :type-binding (binding-start ?variables ?name-token)
                                 ?last :variables ?variables :name ?name :type ?type))))
(--> (type-descriptions ?descriptions)
     (type-description ?description)
     (keyword "and" ?and)
     (type-descriptions ?rest)
     (do (lisp ?descriptions (cons ?description ?rest))))
(--> (type-descriptions ?descriptions)
     (type-description ?description)
     (do (lisp ?descriptions (list ?description))))
(--> (closed-type-descriptions-p ?descriptions)
     (do (lispp (every (lambda (description)
                         (or (null (ast-ref description :type))
                             (explicitly-closed-type-p (ast-ref description :variables)
                                                       (ast-ref description :type))))
                       ?descriptions))))

(--> (constructor-description ?description)
     (value-identifier ?name ?name-token)
     (keyword "of" ?of)
     (type-expression ?type)
     (do (lisp ?description (ast :constructor-binding ?name-token ?type
                                 :name ?name :op-p nil :type ?type))))
(--> (constructor-description ?description)
     (value-identifier ?name ?name-token)
     (do (lisp ?description (ast :constructor-binding ?name-token ?name
                                 :name ?name :op-p nil :type nil))))
(--> (constructor-descriptions ?descriptions)
     (constructor-description ?description)
     (vertical-bar ?bar)
     (constructor-descriptions ?rest)
     (do (lisp ?descriptions (cons ?description ?rest))))
(--> (constructor-descriptions ?descriptions)
     (constructor-description ?description)
     (do (lisp ?descriptions (list ?description))))
(--> (datatype-description ?description)
     (typed-variable-sequence ?variables)
     (type-constructor ?name ?name-token)
     (symbol "=" ?equals)
     (constructor-descriptions ?constructors)
     (do (lisp ?description (ast :datatype-binding (binding-start ?variables ?name-token)
                                 (car (last ?constructors))
                                 :variables ?variables :name ?name
                                 :constructors ?constructors))))
(--> (datatype-descriptions ?descriptions)
     (datatype-description ?description)
     (keyword "and" ?and)
     (datatype-descriptions ?rest)
     (do (lisp ?descriptions (cons ?description ?rest))))
(--> (datatype-descriptions ?descriptions)
     (datatype-description ?description)
     (do (lisp ?descriptions (list ?description))))

(--> (exception-description ?description)
     (value-identifier ?name ?name-token)
     (keyword "of" ?of)
     (type-expression ?type)
     (do (lisp ?description (ast :exception-binding ?name-token ?type
                                 :name ?name :op-p nil :type ?type
                                 :alias nil :alias-op-p nil))))
(--> (exception-description ?description)
     (value-identifier ?name ?name-token)
     (do (lisp ?description (ast :exception-binding ?name-token ?name
                                 :name ?name :op-p nil :type nil
                                 :alias nil :alias-op-p nil))))
(--> (exception-descriptions ?descriptions)
     (exception-description ?description)
     (keyword "and" ?and)
     (exception-descriptions ?rest)
     (do (lisp ?descriptions (cons ?description ?rest))))
(--> (exception-descriptions ?descriptions)
     (exception-description ?description)
     (do (lisp ?descriptions (list ?description))))

(--> (structure-description ?environment ?description)
     (module-identifier ?name ?name-token)
     (symbol ":" ?colon)
     (signature-expression ?environment ?signature)
     (do (lisp ?description (ast :structure-description ?name-token ?signature
                                 :name ?name :signature ?signature))))
(--> (structure-descriptions ?environment ?descriptions)
     (structure-description ?environment ?description)
     (keyword "and" ?and)
     (structure-descriptions ?environment ?rest)
     (do (lisp ?descriptions (cons ?description ?rest))))
(--> (structure-descriptions ?environment ?descriptions)
     (structure-description ?environment ?description)
     (do (lisp ?descriptions (list ?description))))
(--> (required-module-identifiers ?identifiers)
     (module-identifier ?identifier ?token)
     (required-module-identifiers ?rest)
     (do (lisp ?identifiers (cons ?identifier ?rest))))
(--> (required-module-identifiers ?identifiers)
     (module-identifier ?identifier ?token)
     (do (lisp ?identifiers (list ?identifier))))

(--> (specification-item ?environment ?environment ?ast)
     (keyword "val" ?val)
     (value-descriptions ?descriptions)
     (do (lispp (descriptions-valid-p ?descriptions t))
         (lisp ?ast (ast :value-specification ?val (car (last ?descriptions))
                         :descriptions ?descriptions))))
(--> (specification-item ?environment ?environment ?ast)
     (keyword "type" ?type)
     (type-descriptions ?descriptions)
     (closed-type-descriptions-p ?descriptions)
     (do (lispp (unique-identifiers-p (semantic-bindings ?descriptions :name)))
         (lisp ?ast (ast :type-specification ?type (car (last ?descriptions))
                         :equality-p nil :descriptions ?descriptions))))
(--> (specification-item ?environment ?environment ?ast)
     (keyword "eqtype" ?eqtype)
     (type-descriptions ?descriptions)
     (do (lispp (every (lambda (description) (null (ast-ref description :type)))
                       ?descriptions))
         (lispp (unique-identifiers-p (semantic-bindings ?descriptions :name)))
         (lisp ?ast (ast :type-specification ?eqtype (car (last ?descriptions))
                         :equality-p t :descriptions ?descriptions))))
(--> (specification-item ?environment ?environment ?ast)
     (keyword "datatype" ?datatype)
     (datatype-descriptions ?descriptions)
     (do (lispp (datatype-bindings-valid-p ?descriptions nil t))
         (lispp (datatype-descriptions-closed-p ?descriptions))
         (lisp ?ast (ast :datatype-specification ?datatype (car (last ?descriptions))
                         :descriptions ?descriptions))))
(--> (specification-item ?environment ?environment ?ast)
     (keyword "datatype" ?datatype)
     (type-constructor ?name ?name-token)
     (symbol "=" ?equals)
     (keyword "datatype" ?second-datatype)
     (long-type-constructor ?source ?source-token)
     (do (lisp ?ast (ast :datatype-replication-specification ?datatype ?source
                         :name ?name :source ?source))))
(--> (specification-item ?environment ?environment ?ast)
     (keyword "exception" ?exception)
     (exception-descriptions ?descriptions)
     (do (lispp (exception-bindings-valid-p ?descriptions t))
         (lisp ?ast (ast :exception-specification ?exception (car (last ?descriptions))
                         :descriptions ?descriptions))))
(--> (specification-item ?environment ?environment ?ast)
     (keyword "structure" ?structure)
     (structure-descriptions ?environment ?descriptions)
     (do (lispp (descriptions-valid-p ?descriptions nil))
         (lisp ?ast (ast :structure-specification ?structure (car (last ?descriptions))
                         :descriptions ?descriptions))))
(--> (specification-item ?environment ?environment ?ast)
     (keyword "include" ?include)
     (signature-expression ?environment ?signature)
     (do (lisp ?ast (ast :include-specification ?include ?signature
                         :signatures (list ?signature)))))
(--> (specification-item ?environment ?environment ?ast)
     (keyword "include" ?include)
     (module-identifier ?first ?first-token)
     (required-module-identifiers ?rest)
     (do (lisp ?identifiers (cons ?first ?rest))
         (lisp ?signatures
               (mapcar (lambda (identifier)
                         (ast :signature-identifier identifier identifier
                              :identifier identifier))
                       ?identifiers))
         (lisp ?ast (ast :include-specification ?include (car (last ?signatures))
                         :signatures ?signatures))))

(--> (specification-items ?environment ?out-environment ?items)
     (specification-item ?environment ?next-environment ?item)
     (specification-tail ?next-environment ?out-environment ?rest)
     (do (lisp ?items (cons ?item ?rest))))
(--> (specification-items ?environment ?out-environment ?items)
     (semicolon ?semicolon)
     (specification-items ?environment ?out-environment ?items))
(--> (specification-items ?environment ?environment ?items)
     (do (= ?items nil)))
(--> (specification-tail ?environment ?out-environment ?items)
     (semicolon ?semicolon)
     (specification-item ?environment ?next-environment ?item)
     (specification-tail ?next-environment ?out-environment ?rest)
     (do (lisp ?items (cons ?item ?rest))))
(--> (specification-tail ?environment ?out-environment ?items)
     (semicolon ?semicolon)
     (specification-tail ?environment ?out-environment ?items))
(--> (specification-tail ?environment ?out-environment ?items)
     (specification-item ?environment ?next-environment ?item)
     (specification-tail ?next-environment ?out-environment ?rest)
     (do (lisp ?items (cons ?item ?rest))))
(--> (specification-tail ?environment ?environment ?items)
     (do (= ?items nil)))

(--> (long-type-constructor-equality-tail ?identifiers)
     (symbol "=" ?equals)
     (long-type-constructor ?identifier ?token)
     (long-type-constructor-equality-tail ?rest)
     (do (lisp ?identifiers (cons ?identifier ?rest))))
(--> (long-type-constructor-equality-tail ?identifiers)
     (do (= ?identifiers nil)))
(--> (long-module-identifier-equality-tail ?identifiers)
     (symbol "=" ?equals)
     (long-module-identifier ?identifier ?token)
     (long-module-identifier-equality-tail ?rest)
     (do (lisp ?identifiers (cons ?identifier ?rest))))
(--> (long-module-identifier-equality-tail ?identifiers)
     (do (= ?identifiers nil)))
(--> (specification-sharing-clauses ?clauses)
     (keyword "sharing" ?sharing)
     (keyword "type" ?type)
     (long-type-constructor ?first ?first-token)
     (symbol "=" ?equals)
     (long-type-constructor ?second ?second-token)
     (long-type-constructor-equality-tail ?rest)
     (specification-sharing-clauses ?tail)
     (do (lisp ?identifiers (append (list ?first ?second) ?rest))
         (lisp ?clause (ast :sharing-clause ?sharing (car (last ?identifiers))
                            :identifiers ?identifiers :type-p t))
         (lisp ?clauses (cons ?clause ?tail))))
(--> (specification-sharing-clauses ?clauses)
     (keyword "sharing" ?sharing)
     (long-module-identifier ?first ?first-token)
     (symbol "=" ?equals)
     (long-module-identifier ?second ?second-token)
     (long-module-identifier-equality-tail ?rest)
     (specification-sharing-clauses ?tail)
     (do (lisp ?identifiers (append (list ?first ?second) ?rest))
         (lisp ?clause (ast :sharing-clause ?sharing (car (last ?identifiers))
                            :identifiers ?identifiers :type-p nil))
         (lisp ?clauses (cons ?clause ?tail))))
(--> (specification-sharing-clauses ?clauses)
     (do (= ?clauses nil)))
;;; A sharing clause qualifies the specification before it, but does not end
;;; the enclosing sequence.  Parse each following group separately so a later
;;; VAL/TYPE/STRUCTURE specification is never mistaken for the signature's
;;; terminator.  HAVE-ITEMS-P prevents the nullable item grammar from admitting
;;; an initial `sharing' with no preceding specification.
(--> (specification-qualified-tail ?environment ?out-environment ?have-items-p
                                    ?item-groups ?clauses)
     (do (lispp ?have-items-p))
     (specification-sharing-clauses ?first-clauses)
     (do (lispp ?first-clauses))
     (specification-items ?environment ?next-environment ?group-items)
     (do (lisp ?next-have-items-p (or ?have-items-p (not (null ?group-items)))))
     (specification-qualified-tail ?next-environment ?out-environment
                                    ?next-have-items-p ?remaining-groups ?remaining-clauses)
     (do (lisp ?item-groups (cons ?group-items ?remaining-groups))
         (lisp ?clauses (append ?first-clauses ?remaining-clauses))))
(--> (specification-qualified-tail ?environment ?environment ?have-items-p
                                    ?item-groups ?clauses)
     (do (= ?item-groups nil)
         (= ?clauses nil)))
(--> (specification-content ?environment ?out-environment ?items ?clauses)
     (specification-items ?environment ?next-environment ?first-items)
     (do (lisp ?have-items-p (and ?first-items t)))
     (specification-qualified-tail ?next-environment ?out-environment ?have-items-p
                                    ?remaining-groups ?clauses)
     (do (lisp ?item-groups (cons ?first-items ?remaining-groups))
         (lisp ?items (apply #'append ?item-groups))
         (lispp (specification-items-valid-p ?items))))

;;; Signature expressions and the derived `and type` refinement list.
(--> (signature-expression ?environment ?ast)
     (signature-primary ?environment ?base)
     (where-type-signature-tail ?environment ?base ?ast))
(--> (signature-primary ?environment ?ast)
     (keyword "sig" ?sig)
     (specification-content ?environment ?inner-environment ?items ?clauses)
     (keyword "end" ?end)
     (do (lisp ?specification (make-specification-ast ?items ?clauses ?end))
         (lisp ?ast (ast :basic-signature ?sig ?end :specification ?specification))))
(--> (signature-primary ?environment ?ast)
     (module-identifier ?identifier ?token)
     (do (lisp ?ast (ast :signature-identifier ?token ?identifier
                         :identifier ?identifier))))
(--> (type-refinement ?refinement)
     (typed-variable-sequence ?variables)
     (long-type-constructor ?constructor ?constructor-token)
     (symbol "=" ?equals)
     (type-expression ?type)
     (do (lisp ?refinement
               (ast :type-refinement (binding-start ?variables ?constructor-token) ?type
                    :variables ?variables :constructor ?constructor :type ?type))))
(--> (type-refinements ?refinements)
     (type-refinement ?refinement)
     (keyword "and" ?and)
     (keyword "type" ?type)
     (type-refinements ?rest)
     (do (lisp ?refinements (cons ?refinement ?rest))))
(--> (type-refinements ?refinements)
     (type-refinement ?refinement)
     (do (lisp ?refinements (list ?refinement))))
(--> (where-type-signature-tail ?environment ?base ?ast)
     (keyword "where" ?where)
     (keyword "type" ?type)
     (type-refinements ?refinements)
     (do (lispp (refinements-closed-p ?refinements))
         (lisp ?where-node (ast :where-type-signature ?base (car (last ?refinements))
                                :signature ?base :refinements ?refinements)))
     (where-type-signature-tail ?environment ?where-node ?ast))
(--> (where-type-signature-tail ?environment ?base ?ast)
     (do (= ?ast ?base)))

;;; Signature declarations, functors (plain and opened specifications), and
;;; Programs.  Opened parameters retain the specification rather than being
;;; rewritten to LET/OPEN.  RESULT constraints likewise retain transparent or
;;; opaque spelling through :OPAQUE-P.
(--> (signature-binding ?environment ?binding)
     (module-identifier ?name ?name-token)
     (symbol "=" ?equals)
     (signature-expression ?environment ?signature)
     (do (lisp ?binding (ast :signature-binding ?name-token ?signature
                             :name ?name :signature ?signature))))
(--> (signature-bindings ?environment ?bindings)
     (signature-binding ?environment ?binding)
     (keyword "and" ?and)
     (signature-bindings ?environment ?rest)
     (do (lisp ?bindings (cons ?binding ?rest))))
(--> (signature-bindings ?environment ?bindings)
     (signature-binding ?environment ?binding)
     (do (lisp ?bindings (list ?binding))))
(--> (signature-declaration ?environment ?ast)
     (keyword "signature" ?signature)
     (signature-bindings ?environment ?bindings)
     (do (lispp (unique-identifiers-p (semantic-bindings ?bindings :name)))
         (lisp ?ast (ast :signature-declaration ?signature (car (last ?bindings))
                         :bindings ?bindings))))

(--> (functor-binding ?environment ?binding)
     (module-identifier ?name ?name-token)
     (symbol "(" ?open)
     (module-identifier ?parameter ?parameter-token)
     (symbol ":" ?colon)
     (signature-expression ?environment ?parameter-signature)
     (symbol ")" ?close)
     (optional-structure-signature ?environment ?result-signature ?opaque-p)
     (symbol "=" ?equals)
     (structure-expression ?environment ?body)
     (do (lisp ?binding (ast :functor-binding ?name-token ?body
                             :name ?name :parameter ?parameter
                             :parameter-signature ?parameter-signature
                             :opened-parameter nil
                             :result-signature ?result-signature :opaque-p ?opaque-p
                             :body ?body))))
(--> (functor-binding ?environment ?binding)
     (module-identifier ?name ?name-token)
     (symbol "(" ?open)
     (specification-content ?environment ?inner-environment ?items ?clauses)
     (symbol ")" ?close)
     (optional-structure-signature ?environment ?result-signature ?opaque-p)
     (symbol "=" ?equals)
     (structure-expression ?environment ?body)
     (do (lisp ?opened (make-specification-ast ?items ?clauses ?close))
         (lisp ?binding (ast :functor-binding ?name-token ?body
                             :name ?name :parameter nil :parameter-signature nil
                             :opened-parameter ?opened
                             :result-signature ?result-signature :opaque-p ?opaque-p
                             :body ?body))))
(--> (functor-bindings ?environment ?bindings)
     (functor-binding ?environment ?binding)
     (keyword "and" ?and)
     (functor-bindings ?environment ?rest)
     (do (lisp ?bindings (cons ?binding ?rest))))
(--> (functor-bindings ?environment ?bindings)
     (functor-binding ?environment ?binding)
     (do (lisp ?bindings (list ?binding))))
(--> (functor-declaration ?environment ?ast)
     (keyword "functor" ?functor)
     (functor-bindings ?environment ?bindings)
     (do (lispp (unique-identifiers-p (semantic-bindings ?bindings :name)))
         (lisp ?ast (ast :functor-declaration ?functor (car (last ?bindings))
                         :bindings ?bindings))))

(--> (topdeclaration-item ?environment ?environment ?ast)
     (signature-declaration ?environment ?ast))
(--> (topdeclaration-item ?environment ?environment ?ast)
     (functor-declaration ?environment ?ast))
(--> (topdeclaration-item ?environment ?out-environment ?ast)
     (program-structure-items ?environment ?out-environment ?declarations)
     (do (lisp ?ast (sequence-ast :topdec-structure ?declarations
                                  (car (last ?declarations))
                                  :declarations ?declarations))))
;; A maximal structure-level topdec consumes a semicolon only together with a
;; following structure declaration.  It therefore contains no initial STRDEC
;; followed by a semicolon, satisfying the Figure 8 topdec restriction.
(--> (program-structure-items ?environment ?out-environment ?items)
     (structure-declaration-item ?environment ?next-environment ?item)
     (program-structure-tail ?next-environment ?out-environment ?rest)
     (do (= ?items (?item . ?rest))))
(--> (program-structure-tail ?environment ?out-environment ?items)
     (semicolon ?semicolon)
     (structure-declaration-item ?environment ?next-environment ?item)
     ! (program-structure-tail ?next-environment ?out-environment ?rest)
     (do (= ?items (?item . ?rest))))
(--> (program-structure-tail ?environment ?out-environment ?items)
     (structure-declaration-item ?environment ?next-environment ?item)
     ! (program-structure-tail ?next-environment ?out-environment ?rest)
     (do (= ?items (?item . ?rest))))
(--> (program-structure-tail ?environment ?environment ?items)
     (do (= ?items nil)))

;; Figure 8 TOPDEC admits adjacent structure/signature/functor components.
;; They remain one topdec until its mandatory Program semicolon.
(--> (program-topdec-components ?environment ?out-environment ?items)
     (topdeclaration-item ?environment ?next-environment ?item)
     (program-topdec-component-tail ?next-environment ?out-environment ?rest)
     (do (= ?items (?item . ?rest))))
(--> (program-topdec-component-tail ?environment ?out-environment ?items)
     (topdeclaration-item ?environment ?next-environment ?item)
     (program-topdec-component-tail ?next-environment ?out-environment ?rest)
     (do (= ?items (?item . ?rest))))
(--> (program-topdec-component-tail ?environment ?environment ?items)
     (do (= ?items nil)))

;; PROGRAM is exactly `topdec ; [program]` plus the interactive expression
;; derived form.  The epsilon alternative is visible to the entry only at EOF;
;; every component, expression, and empty topdec has crossed its own semicolon.
(--> (program-topdeclarations ?environment ?out-environment ?items)
     (program-topdec-components ?environment ?next-environment ?components)
     (semicolon ?semicolon)
     (program-topdeclarations ?next-environment ?out-environment ?rest)
     (do (lisp ?item (if (cdr ?components)
                         (sequence-ast :topdec-sequence ?components (car (last ?components))
                                       :topdeclarations ?components)
                         (first ?components)))
         (lisp ?items (cons ?item ?rest))))
(--> (program-topdeclarations ?environment ?out-environment ?items)
     (expression ?environment ?expression)
     (semicolon ?semicolon)
     (program-topdeclarations ?environment ?out-environment ?rest)
     (do (lisp ?it (make-identifier (list "it") (ast-node-span ?expression)))
         (lisp ?item (ast :toplevel-expression ?expression ?semicolon
                          :expression ?expression :binding-name ?it))
         (lisp ?items (cons ?item ?rest))))
(--> (program-topdeclarations ?environment ?out-environment ?items)
     (semicolon ?semicolon)
     (program-topdeclarations ?environment ?out-environment ?rest)
     (do (lisp ?item (empty-ast :topdec-structure ?semicolon :declarations nil))
         (lisp ?items (cons ?item ?rest))))
(--> (program-topdeclarations ?environment ?environment ?items)
     (do (= ?items nil)))

) ; Close the local grammar-definition binding wrappers.
