;;; Inspectable immutable values shared by the SML lexer, parser, and later DCGs.
;;;
;;; IDENTIFIER-PATH contains all structure qualifiers and the final identifier,
;;; in source order.  A generic AST node is exactly the native host list
;;; (:NODE KIND SPAN SLOTS), so later DCGs can unify and compile it directly
;;; while Lisp code inspects the same value without decoding or copying.  SLOTS
;;; is an alist whose entries are
;;; (KEYWORD . VALUE); nested ASTs and repeated children are ordinary host conses
;;; in source order.  AST lists follow an immutable convention: constructors
;;; allocate fresh structure and clients must not use destructive list/string
;;; operations on returned values.  Identifiers, decoded literals, and source
;;; spans remain distinct leaf objects, never ambiguous AST-like lists.  Every
;;; node span covers its complete source form, including enclosing punctuation.
;;;
;;; Grammar-node convention: every generic node has a production-specific
;;; keyword kind, a SOURCE-SPAN, and only the documented keyword slots attached
;;; to that kind.  Lexical leaves use IDENTIFIER or LITERAL directly in an
;;; :IDENTIFIER or :LITERAL slot, rather than wrapping them in host symbols or
;;; strings.  Repeated grammar components are proper lists in source order;
;;; optional components whose slot is present use NIL for absence.  Operator
;;; nodes retain :OPERATOR as an IDENTIFIER and operands as explicit child ASTs,
;;; so infix fixity resolution never has to recover structure from token text.
;;;
;;; Core expression nodes use :EXPRESSION or explicitly named children for
;;; operands, :BODY for bodies, :BINDINGS for local bindings, :CLAUSES for
;;; ordered match/function clauses, and :ROWS for record rows.  Pattern nodes
;;; follow the same convention; a clause carries :PATTERN and :EXPRESSION (and
;;; :PATTERNS for a multi-argument function clause).  Type nodes carry :NAME or
;;; :CONSTRUCTOR, :ARGUMENTS, :DOMAIN/:RANGE, and :FIELDS as appropriate.
;;; Declaration nodes carry :DECLARATIONS for declaration sequences, :BINDINGS
;;; for val/type/datatype/exception groups, and :PARAMETER/:RESULT for module
;;; binders.  Module nodes use :STRUCTURE, :SIGNATURE, :SPECIFICATIONS, and
;;; :CONSTRAINT where those phrases occur.  The grammar definitions next to
;;; each node constructor document the precise kind-specific slots; this layer
;;; intentionally does not attach dynamic, evaluator, or typechecker semantics.
(uiop:define-package #:ooparts/sml/syntax
  (:use #:cl)
  (:import-from #:ooparts/sml/source #:source-span)
  (:export
   #:identifier #:identifier-p #:make-identifier
   #:identifier-path #:identifier-name #:identifier-span
   #:qualified-identifier-p
   #:real-literal #:real-literal-p #:make-real-literal
   #:real-literal-negative-p #:real-literal-significand #:real-literal-scale
   #:literal #:literal-p #:make-literal
   #:literal-kind #:literal-value #:literal-text #:literal-span #:literal-base
   #:ast-node #:ast-node-p #:make-ast-node
   #:ast-node-kind #:ast-node-span #:ast-node-slots #:ast-ref))
(in-package #:ooparts/sml/syntax)

(defstruct (identifier
             (:constructor %make-identifier (path span))
             (:conc-name identifier-))
  (path nil :type (cons string list) :read-only t)
  (span nil :type source-span :read-only t))

(defun make-identifier (path span)
  "Make an identifier from nonempty PATH of strings and its complete SPAN."
  (check-type span source-span)
  (unless (and (consp path) (listp path) (every #'stringp path))
    (error 'type-error :datum path :expected-type '(cons string list)))
  (%make-identifier (copy-list path) span))

(defun identifier-name (identifier)
  "Return the unqualified final component of IDENTIFIER."
  (check-type identifier identifier)
  (car (last (identifier-path identifier))))

(defun qualified-identifier-p (identifier)
  "True when IDENTIFIER has at least one structure-qualifier component."
  (check-type identifier identifier)
  (not (null (cdr (identifier-path identifier)))))

(defstruct (real-literal
             (:constructor make-real-literal (negative-p significand scale))
             (:conc-name real-literal-))
  "Exact decimal value (-1)^NEGATIVE-P * SIGNIFICAND * 10^SCALE."
  (negative-p nil :type boolean :read-only t)
  (significand 0 :type (integer 0 *) :read-only t)
  (scale 0 :type integer :read-only t))

(defstruct (literal
             (:constructor %make-literal (kind value text span base))
             (:conc-name literal-))
  (kind nil :type (member :integer :real :word :character :string)
        :read-only t)
  (value nil :read-only t)
  (text "" :type string :read-only t)
  (span nil :type source-span :read-only t)
  ;; 10 or 16 for integer/word input notation, NIL for other literal classes.
  (base nil :type (or null (member 10 16)) :read-only t))

(defun make-literal (kind value text span &key base)
  "Construct one SML special-constant value without converting it to a float.
INTEGER values include their optional SML negation; WORD values are nonnegative;
CHARACTER values are characters; STRING values are decoded strings; and REAL
values are REAL-LITERAL objects.  BASE records integer/word radix notation."
  (check-type span source-span)
  (check-type text string)
  (unless (member kind '(:integer :real :word :character :string))
    (error 'type-error
           :datum kind
           :expected-type '(member :integer :real :word :character :string)))
  (ecase kind
    (:integer (check-type value integer))
    (:real (check-type value real-literal))
    (:word (check-type value (integer 0 *)))
    (:character (check-type value character))
    (:string (check-type value string)))
  (when base
    (check-type base (member 10 16)))
  (%make-literal kind value text span base))

(deftype ast-node ()
  '(cons (eql :node)
         (cons keyword (cons source-span (cons list null)))))

(defun ast-node-p (object)
  "True for exactly (:NODE KIND SPAN SLOTS), with an alist-shaped SLOTS list."
  (typep object 'ast-node))

(defun ast-node-kind (node)
  (check-type node ast-node)
  (second node))

(defun ast-node-span (node)
  (check-type node ast-node)
  (third node))

(defun ast-node-slots (node)
  (check-type node ast-node)
  (fourth node))

(defun make-ast-node (kind span &rest alternating-keys-values)
  "Return a fresh (:NODE KIND SPAN SLOTS) list from alternating keys and values.
The stored slots form a fresh alist.  Callers and recipients must not mutate the
node, its slot cells, or its list-valued children.  Duplicate keys are rejected
so that AST-REF is unambiguous; a present key whose value is NIL remains distinct
from an absent key."
  (check-type kind keyword)
  (check-type span source-span)
  (unless (evenp (length alternating-keys-values))
    (error 'simple-error
           :format-control "AST slots require alternating keywords and values: ~S"
           :format-arguments (list alternating-keys-values)))
  (let ((seen '())
        (slots '()))
    (loop for (key value) on alternating-keys-values by #'cddr
          do (check-type key keyword)
             (when (member key seen)
               (error 'simple-error
                      :format-control "Duplicate AST slot ~S for kind ~S."
                      :format-arguments (list key kind)))
             (push key seen)
             (push (cons key value) slots))
    (list :node kind span (nreverse slots))))

(defun ast-ref (node key &optional default)
  "Return NODE's value for KEY, or DEFAULT when KEY is absent."
  (check-type node ast-node)
  (check-type key keyword)
  (let ((entry (assoc key (ast-node-slots node))))
    (if entry (cdr entry) default)))
