;;; The immutable native initial basis and its executable primitive values.
;;;
;;; Static terms use stable, interned identities rather than fresh host
;;; objects.  Elaboration is responsible for thawing the external (FV ...)
;;; variables in each scheme before use.  Dynamic alists are newest-first;
;;; their spines are replaced, never destructively changed, at a commit.
(uiop:define-package #:ooparts/sml/basis
  (:use #:cl)
  (:import-from #:ooparts/curry #:lambda/c)
  (:import-from #:ooparts/sml/types
                #:type-name #:type-var #:scheme #:type-function
                #:=> #:@ #:record #:field)
  (:import-from #:ooparts/sml/grammar #:initial-fixity-environment)
  (:import-from #:ooparts/sml/runtime
                #:sml-module-path #:make-sml-module
                #:+unit+ #:+true+ #:+false+
                #:+list-nil-identity+ #:+list-cons-identity+
                #:+true-identity+ #:+false-identity+ #:+reference-identity+
                #:+match-exception+ #:+bind-exception+
                #:+match-exception-identity+ #:+bind-exception-identity+
                #:make-sml-constructor #:make-sml-nullary-constructor
                #:make-sml-record #:sml-record-field
                #:make-sml-list #:sml-list-values
                #:make-sml-reference #:sml-reference-contents
                #:set-sml-reference-contents
                #:make-sml-word #:sml-word-p #:sml-word-value
                #:sml-boolean #:sml-truth-p #:sml-equal #:raise-sml)
  (:export #:basis #:basis-p #:make-initial-basis
           #:basis-static #:basis-dynamic #:basis-module-context #:basis-fixities
           #:extend-basis #:basis-host-symbol #:resolve-basis-value))
(in-package #:ooparts/sml/basis)

(defstruct (basis
             (:constructor %make-basis
                 (static dynamic index &optional module-context
                         (fixities (initial-fixity-environment))))
             (:copier nil))
  "An immutable static/dynamic basis plus parser and module metadata."
  (static nil :type list :read-only t)
  (dynamic nil :type list :read-only t)
  (index nil :type list :read-only t)
  (module-context nil :type list :read-only t)
  (fixities nil :type list :read-only t))

;;; ---------------------------------------------------------------------------
;;; External native terms

(defun %type-name (spelling identity arity equality)
  (list 'type-name spelling identity arity equality :flexible))

(defun %type-application (name &optional (arguments nil))
  (list '@ name arguments))

(defun %arrow (domain range)
  (list '=> domain range))

(defun %pair (left right)
  (list 'record
        (list (list 'field "1" left) (list 'field "2" right))
        :closed))

(defun %type-variable (id &optional (equality :ordinary))
  (list 'type-var (list :fv id) :type equality))

(defun %mono (type)
  (list 'scheme nil type))

(defun %poly (type variables)
  "Make a scheme whose VARIABLES are (ID EQUALITY-ATTRIBUTE) pairs."
  (list 'scheme
        (mapcar (lambda (variable)
                  (destructuring-bind (id equality) variable
                    (list :fv id :type equality)))
                variables)
        type))

(defun %value (name scheme host-symbol status)
  (list :value (list name) scheme host-symbol status))

(defun %tycon (name type-name)
  (list :tycon (list name) type-name))

(defun %constructor (identity payload-arity &optional exception-p)
  (list :constructor identity payload-arity exception-p))

(defun %initial-static ()
  (let* ((unit (list 'type-function nil (list 'record nil :closed)))
         (bool (%type-name "bool" 'sml-bool-type 0 :equality))
         (int (%type-name "int" 'sml-int-type 0 :equality))
         (real (%type-name "real" 'sml-real-type 0 :non-equality))
         (word (%type-name "word" 'sml-word-type 0 :equality))
         (char (%type-name "char" 'sml-char-type 0 :equality))
         (string (%type-name "string" 'sml-string-type 0 :equality))
         (exn (%type-name "exn" 'sml-exn-type 0 :non-equality))
         (list-name (%type-name "list" 'sml-list-type 1 :equality))
         (ref-name (%type-name "ref" +reference-identity+ 1 :equality))
         (option-name (%type-name "option" 'sml-option-type 1 :equality))
         (unit-type (list 'record nil :closed))
         (bool-type (%type-application bool))
         (int-type (%type-application int))
         (real-type (%type-application real))
         (char-type (%type-application char))
         (string-type (%type-application string))
         (exn-type (%type-application exn)))
    (flet ((application (name &rest arguments)
             (%type-application name arguments))
           (variable (id &optional (equality :ordinary))
             (%type-variable id equality)))
      (let* ((a (variable :a))
             (b (variable :b))
             (c (variable :c))
             (equality-a (variable :a :equality))
             (a-list (application list-name a))
             (a-ref (application ref-name a))
             (a-option (application option-name a))
             (types
               (list (%tycon "unit" unit) (%tycon "bool" bool)
                     (%tycon "int" int) (%tycon "real" real)
                     (%tycon "word" word) (%tycon "char" char)
                     (%tycon "string" string) (%tycon "exn" exn)
                     (%tycon "list" list-name) (%tycon "ref" ref-name)
                     (%tycon "option" option-name)))
             (values
               (list
                ;; Initial datatype constructors and references.
                (%value "nil" (%poly a-list '((:a :ordinary)))
                        'sml-nil (%constructor +list-nil-identity+ 0))
                (%value "::"
                        (%poly (%arrow (%pair a a-list) a-list)
                               '((:a :ordinary)))
                        'sml-cons (%constructor +list-cons-identity+ 1))
                (%value "true" (%mono bool-type) 'sml-true
                        (%constructor +true-identity+ 0))
                (%value "false" (%mono bool-type) 'sml-false
                        (%constructor +false-identity+ 0))
                (%value "NONE" (%poly a-option '((:a :ordinary)))
                        'sml-none (%constructor 'sml-none-constructor 0))
                (%value "SOME" (%poly (%arrow a a-option) '((:a :ordinary)))
                        'sml-some (%constructor 'sml-some-constructor 1))
                ;; References have their dedicated runtime representation but
                ;; genuine constructor status for pattern elaboration.
                (%value "ref" (%poly (%arrow a a-ref) '((:a :ordinary)))
                        'sml-ref (%constructor +reference-identity+ 1))

                ;; Pervasive exception constructors.
                (%value "Match" (%mono exn-type) 'sml-match
                        (%constructor +match-exception-identity+ 0 t))
                (%value "Bind" (%mono exn-type) 'sml-bind
                        (%constructor +bind-exception-identity+ 0 t))
                (%value "Div" (%mono exn-type) 'sml-div
                        (%constructor 'sml-div-constructor 0 t))
                (%value "Overflow" (%mono exn-type) 'sml-overflow
                        (%constructor 'sml-overflow-constructor 0 t))
                (%value "Size" (%mono exn-type) 'sml-size-exception
                        (%constructor 'sml-size-constructor 0 t))
                (%value "Subscript" (%mono exn-type) 'sml-subscript
                        (%constructor 'sml-subscript-constructor 0 t))
                (%value "Domain" (%mono exn-type) 'sml-domain
                        (%constructor 'sml-domain-constructor 0 t))
                (%value "Chr" (%mono exn-type) 'sml-chr
                        (%constructor 'sml-chr-constructor 0 t))
                (%value "Fail" (%mono (%arrow string-type exn-type)) 'sml-fail
                        (%constructor 'sml-fail-constructor 1 t))
                (%value "Option" (%mono exn-type) 'sml-option-exception
                        (%constructor 'sml-option-constructor 0 t))
                (%value "Empty" (%mono exn-type) 'sml-empty
                        (%constructor 'sml-empty-constructor 0 t))

                ;; Exact integer arithmetic, real division, and comparisons.
                (%value "+" (%poly (%arrow (%pair a a) a) '((:a :ordinary)))
                        'sml-add '(:overloaded :numeric))
                (%value "-" (%poly (%arrow (%pair a a) a) '((:a :ordinary)))
                        'sml-subtract '(:overloaded :numeric))
                (%value "*" (%poly (%arrow (%pair a a) a) '((:a :ordinary)))
                        'sml-multiply '(:overloaded :numeric))
                (%value "/" (%mono (%arrow (%pair real-type real-type) real-type))
                        'sml-divide :variable)
                (%value "div" (%poly (%arrow (%pair a a) a) '((:a :ordinary)))
                        'sml-word-int-div '(:overloaded :word-int))
                (%value "mod" (%poly (%arrow (%pair a a) a) '((:a :ordinary)))
                        'sml-word-int-mod '(:overloaded :word-int))
                (%value "="
                        (%poly (%arrow (%pair equality-a equality-a) bool-type)
                               '((:a :equality)))
                        'sml-equal-value :variable)
                (%value "<>"
                        (%poly (%arrow (%pair equality-a equality-a) bool-type)
                               '((:a :equality)))
                        'sml-not-equal :variable)
                (%value "<" (%poly (%arrow (%pair a a) bool-type) '((:a :ordinary)))
                        'sml-less '(:overloaded :ordered))
                (%value ">" (%poly (%arrow (%pair a a) bool-type) '((:a :ordinary)))
                        'sml-greater '(:overloaded :ordered))
                (%value "<=" (%poly (%arrow (%pair a a) bool-type) '((:a :ordinary)))
                        'sml-less-equal '(:overloaded :ordered))
                (%value ">=" (%poly (%arrow (%pair a a) bool-type) '((:a :ordinary)))
                        'sml-greater-equal '(:overloaded :ordered))
                (%value "^"
                        (%mono (%arrow (%pair string-type string-type) string-type))
                        'sml-concatenate :variable)
                (%value "concat"
                        (%mono (%arrow (application list-name string-type)
                                       string-type))
                        'sml-string-concat :variable)
                (%value "@"
                        (%poly (%arrow (%pair a-list a-list) a-list)
                               '((:a :ordinary)))
                        'sml-append :variable)
                (%value "o"
                        (%poly (%arrow (%pair (%arrow b c) (%arrow a b))
                                       (%arrow a c))
                               '((:a :ordinary) (:b :ordinary) (:c :ordinary)))
                        'sml-compose :variable)
                (%value ":=" (%poly (%arrow (%pair a-ref a) unit-type)
                                    '((:a :ordinary)))
                        'sml-assign :variable)
                (%value "!" (%poly (%arrow a-ref a) '((:a :ordinary)))
                        'sml-dereference :variable)
                (%value "before"
                        (%poly (%arrow (%pair a b) a)
                               '((:a :ordinary) (:b :ordinary)))
                        'sml-before :variable)

                ;; Pervasive scalar, list/string, and conversion operations.
                (%value "abs" (%poly (%arrow a a) '((:a :ordinary)))
                        'sml-abs '(:overloaded :real-int))
                (%value "~" (%poly (%arrow a a) '((:a :ordinary)))
                        'sml-negate '(:overloaded :real-int))
                (%value "not" (%mono (%arrow bool-type bool-type)) 'sml-not :variable)
                (%value "print" (%mono (%arrow string-type unit-type))
                        'sml-print :variable)
                (%value "explode" (%mono (%arrow string-type
                                                  (application list-name char-type)))
                        'sml-explode :variable)
                (%value "implode" (%mono (%arrow (application list-name char-type)
                                                  string-type))
                        'sml-implode :variable)
                (%value "size" (%mono (%arrow string-type int-type))
                        'sml-string-size :variable)
                (%value "ord" (%mono (%arrow char-type int-type)) 'sml-ord :variable)
                (%value "chr" (%mono (%arrow int-type char-type)) 'sml-chr-value
                        :variable)
                (%value "real" (%mono (%arrow int-type real-type)) 'sml-real-value
                        :variable)
                (%value "floor" (%mono (%arrow real-type int-type)) 'sml-floor
                        :variable)
                (%value "ceiling" (%mono (%arrow real-type int-type)) 'sml-ceiling
                        :variable)
                (%value "trunc" (%mono (%arrow real-type int-type)) 'sml-trunc
                        :variable))))
        (list :static values types)))))

;;; ---------------------------------------------------------------------------
;;; Primitive values.  Every stored SML function is unary and created by
;;; LAMBDA/C; host functions below are merely implementations of those values.

(defun %pair-arguments (record)
  (values (sml-record-field record "1") (sml-record-field record "2")))

(defun %pair-record (left right)
  (make-sml-record (list (cons "1" left) (cons "2" right))))

(defun %binary-primitive (function)
  (lambda/c (operands)
    (multiple-value-bind (left right) (%pair-arguments operands)
      (funcall function left right))))

(defun %unary-primitive (function)
  (lambda/c (value)
    (funcall function value)))

(defun %boolean-primitive (predicate)
  (%binary-primitive
   (lambda (left right)
     (sml-boolean (funcall predicate left right)))))

(defun %numeric-call (function left right)
  (if (or (sml-word-p left) (sml-word-p right))
      (progn
        (unless (and (sml-word-p left) (sml-word-p right))
          (error "SML numeric operands have inconsistent word representations."))
        (make-sml-word (funcall function (sml-word-value left)
                                (sml-word-value right))))
      (funcall function left right)))

(defun %word-int-call (operation left right exception)
  "Divide two Int values, or two canonical unsigned Word values."
  (let ((word-operands (or (sml-word-p left) (sml-word-p right))))
    (when word-operands
      (unless (and (sml-word-p left) (sml-word-p right))
        (error "SML division operands have inconsistent word representations."))
      (setf left (sml-word-value left)
            right (sml-word-value right)))
    (when (zerop right)
      (raise-sml exception))
    (multiple-value-bind (quotient remainder) (floor left right)
      (let ((result (ecase operation
                      (:quotient quotient)
                      (:remainder remainder))))
        (if word-operands (make-sml-word result) result)))))

(defun %ordered-call (relation left right)
  (flet ((call (integer string character)
           (cond ((or (sml-word-p left) (sml-word-p right))
                  (unless (and (sml-word-p left) (sml-word-p right))
                    (error "SML ordered operands have inconsistent representations."))
                  (funcall integer (sml-word-value left) (sml-word-value right)))
                 ((and (stringp left) (stringp right)) (funcall string left right))
                 ((and (characterp left) (characterp right))
                  (funcall character left right))
                 (t (funcall integer left right)))))
    (ecase relation
      (:< (call #'< #'string< #'char<))
      (:> (call #'> #'string> #'char>))
      (:<= (call #'<= #'string<= #'char<=))
      (:>= (call #'>= #'string>= #'char>=)))))

(defun %initial-dynamic ()
  (let* ((nil-value
           (make-sml-nullary-constructor "nil" +list-nil-identity+))
         (cons-value (make-sml-constructor "::" +list-cons-identity+))
         (none-value
           (make-sml-nullary-constructor "NONE" 'sml-none-constructor))
         (some-value (make-sml-constructor "SOME" 'sml-some-constructor))
         (div-value
           (make-sml-nullary-constructor "Div" 'sml-div-constructor))
         (overflow-value
           (make-sml-nullary-constructor "Overflow" 'sml-overflow-constructor))
         (size-value
           (make-sml-nullary-constructor "Size" 'sml-size-constructor))
         (subscript-value
           (make-sml-nullary-constructor "Subscript" 'sml-subscript-constructor))
         (domain-value
           (make-sml-nullary-constructor "Domain" 'sml-domain-constructor))
         (chr-value
           (make-sml-nullary-constructor "Chr" 'sml-chr-constructor))
         (fail-value (make-sml-constructor "Fail" 'sml-fail-constructor))
         (option-value
           (make-sml-nullary-constructor "Option" 'sml-option-constructor))
         (empty-value
           (make-sml-nullary-constructor "Empty" 'sml-empty-constructor)))
    (list
     (cons 'sml-nil nil-value)
     (cons 'sml-cons cons-value)
     (cons 'sml-true +true+)
     (cons 'sml-false +false+)
     (cons 'sml-none none-value)
     (cons 'sml-some some-value)
     (cons 'sml-ref (%unary-primitive #'make-sml-reference))
     (cons 'sml-match +match-exception+)
     (cons 'sml-bind +bind-exception+)
     (cons 'sml-div div-value)
     (cons 'sml-overflow overflow-value)
     (cons 'sml-size-exception size-value)
     (cons 'sml-subscript subscript-value)
     (cons 'sml-domain domain-value)
     (cons 'sml-chr chr-value)
     (cons 'sml-fail fail-value)
     (cons 'sml-option-exception option-value)
     (cons 'sml-empty empty-value)
     (cons 'sml-add (%binary-primitive (lambda (left right) (%numeric-call #'+ left right))))
     (cons 'sml-subtract (%binary-primitive (lambda (left right) (%numeric-call #'- left right))))
     (cons 'sml-multiply (%binary-primitive (lambda (left right) (%numeric-call #'* left right))))
     (cons 'sml-divide
           (lambda/c (operands)
             (multiple-value-bind (left right) (%pair-arguments operands)
               (when (zerop right)
                 (raise-sml div-value))
               (handler-case
                   (/ (coerce left 'double-float) (coerce right 'double-float))
                 (floating-point-overflow () (raise-sml overflow-value))))))
     (cons 'sml-word-int-div
           (%binary-primitive
            (lambda (left right) (%word-int-call :quotient left right div-value))))
     (cons 'sml-word-int-mod
           (%binary-primitive
            (lambda (left right) (%word-int-call :remainder left right div-value))))
     (cons 'sml-equal-value (%boolean-primitive #'sml-equal))
     (cons 'sml-not-equal
           (%boolean-primitive (lambda (left right) (not (sml-equal left right)))))
     (cons 'sml-less (%boolean-primitive (lambda (left right) (%ordered-call :< left right))))
     (cons 'sml-greater (%boolean-primitive (lambda (left right) (%ordered-call :> left right))))
     (cons 'sml-less-equal (%boolean-primitive (lambda (left right) (%ordered-call :<= left right))))
     (cons 'sml-greater-equal (%boolean-primitive (lambda (left right) (%ordered-call :>= left right))))
     (cons 'sml-concatenate
           (%binary-primitive
            (lambda (left right) (concatenate 'string left right))))
     (cons 'sml-append
           (%binary-primitive
            (lambda (left right)
              (make-sml-list
               (append (sml-list-values left) (sml-list-values right))))))
     (cons 'sml-compose
           (lambda/c (operands)
             (multiple-value-bind (outer inner) (%pair-arguments operands)
               (lambda/c (value)
                 (funcall outer (funcall inner value))))))
     (cons 'sml-assign
           (lambda/c (operands)
             (multiple-value-bind (reference value) (%pair-arguments operands)
               (set-sml-reference-contents reference value)
               +unit+)))
     (cons 'sml-dereference (%unary-primitive #'sml-reference-contents))
     (cons 'sml-before (%binary-primitive (lambda (left right)
                                            (declare (ignore right))
                                            left)))
     (cons 'sml-abs (%unary-primitive #'abs))
     (cons 'sml-negate (%unary-primitive #'-))
     (cons 'sml-int-to-string
           (%unary-primitive
            (lambda (value)
              (if (minusp value)
                  (format nil "~~~D" (abs value))
                  (format nil "~D" value)))))
     (cons 'sml-bool-to-string
           (%unary-primitive
            (lambda (value) (if (sml-truth-p value) "true" "false"))))
     (cons 'sml-not (lambda/c (value) (sml-boolean (not (sml-truth-p value)))))
     (cons 'sml-print
           (lambda/c (value)
             (write-string value *standard-output*)
             +unit+))
     (cons 'sml-string-concat
           (%unary-primitive
            (lambda (value)
              (with-output-to-string (output)
                (dolist (part (sml-list-values value))
                  (write-string part output))))))
     (cons 'sml-explode
           (%unary-primitive
            (lambda (value) (make-sml-list (coerce value 'list)))))
     (cons 'sml-implode
           (%unary-primitive
            (lambda (value) (coerce (sml-list-values value) 'string))))
     (cons 'sml-string-size (%unary-primitive #'length))
     (cons 'sml-list-map
           (lambda/c (function)
             (lambda/c (value)
               (let ((mapped nil))
                 (dolist (element (sml-list-values value))
                   (push (funcall function element) mapped))
                 (make-sml-list (nreverse mapped))))))
     (cons 'sml-list-length
           (%unary-primitive
            (lambda (value) (length (sml-list-values value)))))
     (cons 'sml-list-foldl
           (lambda/c (function)
             (lambda/c (initial)
               (lambda/c (value)
                 (let ((accumulator initial))
                   (dolist (element (sml-list-values value) accumulator)
                     (setf accumulator
                           (funcall function (%pair-record element accumulator)))))))))
     (cons 'sml-list-foldr
           (lambda/c (function)
             (lambda/c (initial)
               (lambda/c (value)
                 (let ((accumulator initial))
                   (dolist (element (reverse (sml-list-values value)) accumulator)
                     (setf accumulator
                           (funcall function (%pair-record element accumulator)))))))))
     (cons 'sml-ord (%unary-primitive #'char-code))
     ;; The initial character alphabet has N = 256 characters.  Its literals
     ;; and CHR conversion therefore share the inclusive ordinal range 0..255.
     (cons 'sml-chr-value
           (lambda/c (value)
             (let ((character
                     (and (integerp value) (<= 0 value 255) (code-char value))))
               (unless character
                 (raise-sml chr-value))
               character)))
     (cons 'sml-real-value
           (lambda/c (value)
             (handler-case (coerce value 'double-float)
               (floating-point-overflow () (raise-sml overflow-value)))))
     (cons 'sml-floor (%unary-primitive (lambda (value) (values (floor value)))))
     (cons 'sml-ceiling (%unary-primitive (lambda (value) (values (ceiling value)))))
     (cons 'sml-trunc (%unary-primitive (lambda (value) (values (truncate value))))))))

;;; ---------------------------------------------------------------------------
;;; Structured initial Basis

(defun %static-value (static name)
  (or (find (list name) (second static) :key #'second :test #'equal)
      (error "The initial Core basis has no value ~S." name)))

(defun %static-type (static name)
  (let ((entry (find (list name) (third static) :key #'second :test #'equal)))
    (unless entry
      (error "The initial Core basis has no type ~S." name))
    (third entry)))


(defun %prefix-static (name static)
  "Prefix the relative value and type paths in an initial structure view."
  (destructuring-bind (tag values types) static
    (declare (ignore tag))
    (list
     :static
     (mapcar (lambda (entry)
               (destructuring-bind (tag path scheme host status) entry
                 (list tag (cons name path) scheme host status)))
             values)
     (mapcar (lambda (entry)
               (destructuring-bind (tag path definition) entry
                 (list tag (cons name path) definition)))
             types))))

(defun %initial-structure (name root types values dynamic)
  "Return (STRUCTURE-BINDING ROOT-BINDING STATIC) for one initial structure.
VALUES use their ordinary primitive host symbols before this view reroots their
public static descriptors.  The runtime module shares those primitive values."
  (let ((projected-values nil)
        (fields nil)
        (module-fields nil))
    (dolist (entry values)
      (destructuring-bind (tag path scheme host status) entry
        (declare (ignore tag))
        (let* ((field-name (first path))
               (key (cons :value field-name))
               (binding (assoc host dynamic :test #'eq)))
          (unless (and (null (rest path)) binding)
            (error "Invalid initial structure value ~S in ~A." entry name))
          (push (%value field-name scheme
                        (list :module-ref root (list key)) status)
                projected-values)
          (push (list :field key host) fields)
          (push (cons key (cdr binding)) module-fields))))
    (let* ((static (list :static (nreverse projected-values) types))
           (view (list :view root static nil (nreverse fields)
                       (list :generations nil nil)))
           (module (make-sml-module (nreverse module-fields))))
      (list (list :structure name view) (cons root module) static))))

(defun %project-initial-modules (core modules)
  "Mirror %CONTEXT-STATIC's immutable projection for the initial structure forest."
  (let ((projected
          (mapcar (lambda (module)
                    (%prefix-static (second (first module)) (third module)))
                  modules)))
    (list :static
          (append (loop for static in projected append (second static))
                  (second core))
          (append (loop for static in projected append (third static))
                  (third core)))))

(defun %initial-modules (core dynamic)
  "Build the bounded ordinary structures without realizing any new nominal type."
  (let* ((int-name (%static-type core "int"))
         (bool-name (%static-type core "bool"))
         (string-name (%static-type core "string"))
         (list-name (%static-type core "list"))
         (int-type (%type-application int-name))
         (string-type (%type-application string-name))
         (a (%type-variable :a))
         (b (%type-variable :b))
         (a-list (%type-application list-name (list a)))
         (b-list (%type-application list-name (list b)))
         (variables '((:a :ordinary) (:b :ordinary)))
         (map-type (%poly (%arrow (%arrow a b) (%arrow a-list b-list)) variables))
         (length-type (%poly (%arrow a-list int-type) '((:a :ordinary))))
         (fold-type (%poly (%arrow (%arrow (%pair a b) b)
                                   (%arrow b (%arrow a-list b)))
                           variables))
         (modules
           (list
            (%initial-structure
             "Int" 'sml-int-structure
             (list (%tycon "int"
                           (list 'type-function nil int-type)))
             (list (%value "toString" (%mono (%arrow int-type string-type))
                           'sml-int-to-string :variable))
             dynamic)
            (%initial-structure
             "Bool" 'sml-bool-structure
             (list (%tycon "bool"
                           (list 'type-function nil (%type-application bool-name))))
             (list (%value "toString"
                           (%mono (%arrow (%type-application bool-name) string-type))
                           'sml-bool-to-string :variable)
                   (%static-value core "not"))
             dynamic)
            (%initial-structure
             "String" 'sml-string-structure
             (list (%tycon "string"
                           (list 'type-function nil string-type)))
             (list (%static-value core "concat")
                   (%static-value core "size")
                   (%static-value core "explode")
                   (%static-value core "implode"))
             dynamic)
            (%initial-structure
             "TextIO" 'sml-text-io-structure nil
             (list (%static-value core "print")) dynamic)
            (%initial-structure
             "List" 'sml-list-structure nil
             (list (%value "map" map-type 'sml-list-map :variable)
                   (%value "length" length-type 'sml-list-length :variable)
                   (%value "foldl" fold-type 'sml-list-foldl :variable)
                   (%value "foldr" fold-type 'sml-list-foldr :variable))
             dynamic))))
    (values (mapcar #'first modules)
            (mapcar #'second modules)
            (%project-initial-modules core modules))))

;;; ---------------------------------------------------------------------------
;;; Public persistent basis operations

(defun %name-index (static)
  (mapcar (lambda (entry)
            (destructuring-bind (tag path scheme host-symbol status) entry
              (declare (ignore tag scheme status))
              (cons (copy-list path) host-symbol)))
          (second static)))

(defun %query-path (name-or-path)
  (flet ((split (name)
           (loop with start = 0
                 for stop = (position #\. name :start start)
                 collect (subseq name start stop)
                 while stop
                 do (setf start (1+ stop)))))
    (cond ((stringp name-or-path) (split name-or-path))
          ((symbolp name-or-path) (list (symbol-name name-or-path)))
          ((and (listp name-or-path) name-or-path)
           (mapcar (lambda (component)
                     (etypecase component
                       (string component)
                       (symbol (symbol-name component))))
                   name-or-path))
          (t (error "An SML source path must be a name or a nonempty path: ~S"
                    name-or-path)))))

(defun make-initial-basis ()
  "Return a fresh deterministic initial Core and structured ordinary Basis.
The external schemes share only stable interned identities; their list structure
and the dynamic alist are newly allocated for each basis."
  (let ((core (%initial-static))
        (core-dynamic (%initial-dynamic)))
    (multiple-value-bind (structures roots static)
        (%initial-modules core core-dynamic)
      (let ((dynamic (append roots core-dynamic)))
        (%make-basis static dynamic (%name-index static)
                     (list :module-context core structures nil nil)
                     (initial-fixity-environment))))))

(defun extend-basis (basis new-static dynamic-additions
                     &key (module-context (basis-module-context basis))
                          (fixities (basis-fixities basis)))
  "Commit static/dynamic bindings and metadata without changing BASIS.
DYNAMIC-ADDITIONS are newest-first; values, module views, and reference cells
remain shared.  Metadata is supplied by a successful module compilation and is
preserved unchanged by the legacy three-argument calling convention."
  (check-type basis basis)
  (%make-basis new-static
               (append (copy-alist dynamic-additions)
                       (copy-alist (basis-dynamic basis)))
               (%name-index new-static) module-context fixities))

(defun basis-host-symbol (basis name-or-path)
  "Return the host binding for source NAME-OR-PATH and a found flag.
A name may be a string (including dotted qualification), a symbol, or a nonempty
path of string/symbol components.  The lookup data is immutable."
  (check-type basis basis)
  (let* ((path (%query-path name-or-path))
         (entry (assoc path (slot-value basis 'index) :test #'equal)))
    (if entry
        (values (cdr entry) t)
        (values nil nil))))

(defun resolve-basis-value (basis descriptor)
  "Resolve an ordinary host symbol or a qualified module descriptor in BASIS."
  (check-type basis basis)
  (let* ((root (if (and (consp descriptor) (eq (car descriptor) :module-ref))
                   (second descriptor) descriptor))
         (entry (assoc root (basis-dynamic basis) :test #'eq)))
    (if (null entry)
        (values nil nil)
        (values (if (eq root descriptor)
                    (cdr entry)
                    (sml-module-path (cdr entry) (third descriptor)))
                t))))

;;; BASIS-STATIC and BASIS-DYNAMIC are read-only structure readers created by
;;; DEFSTRUCT.  They are exported for the compiler and elaborator, not as public
;;; mutable environment access.  Their native terms/alists are persistent data
;;; and callers must not destructively modify them.
