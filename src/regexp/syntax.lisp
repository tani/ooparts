;;; S-expression validation and normalization for the regexp library.
(uiop:define-package #:ooparts/regexp/syntax
  (:use #:cl)
  (:import-from #:ooparts/regexp/model
    #:+re-dup-max+
    #:regexp-error
    #:make-regexp-node
    #:make-regexp-metadata
    #:character-code
    #:predicate-from-items)
  (:export #:normalize-regexp))
(in-package #:ooparts/regexp/syntax)

(defvar *active-conses* nil
  "Cons cells on the current source path; used to reject cyclic input.")
(defvar *case-insensitive* nil)
(defvar *newline* nil)
(defvar *minimal* nil)

;;; A raw node keeps the source structure before flattening and lowering.
;;; The :consume kind stores its completed predicate table directly, so the
;;; canonical pass only has to assign predicate identifiers.
(defstruct (%raw (:constructor %make-raw) (:conc-name %raw-))
  (kind :epsilon)
  (children nil)
  (minimum nil)
  (maximum nil)
  (mode 0)
  (predicate nil)
  (assertion nil))

(defun %fail (code form)
  (error 'regexp-error :code code :form form))

(defun %badpat (form)
  (%fail :badpat form))

(defun %bits ()
  (make-array 256 :element-type 'bit :initial-element 0))

(defun %literal-bits (code)
  (let ((bits (%bits)))
    (setf (aref bits code) 1)
    (when *case-insensitive*
      (cond
        ((<= 65 code 90) (setf (aref bits (+ code 32)) 1))
        ((<= 97 code 122) (setf (aref bits (- code 32)) 1))))
    bits))

(defun %any-bits ()
  (let ((bits (%bits)))
    (loop for code from 1 to 255
          do (setf (aref bits code) 1))
    (when *newline*
      (setf (aref bits 10) 0))
    bits))

;;; Safe list walking. Every cons on the spine is marked while its elements
;;; are dispatched, so cycles are found even across element/form boundaries.

(defun %collect-list (form)
  "Return the elements and the newly active cons cells of FORM."
  (let ((elements '())
        (cells '())
        (tail form))
    (loop
      (cond
        ((null tail)
         (return (values (nreverse elements) cells)))
        ((not (consp tail))
         (%badpat form))
        ((gethash tail *active-conses*)
         (%badpat form))
        (t
         (setf (gethash tail *active-conses*) t)
         (push tail cells)
         (push (car tail) elements)
         (setf tail (cdr tail)))))))

(defun %safe-elements (form)
  "Read a proper acyclic list, leaving any mark removed before returning."
  (when (and (consp form) (gethash form *active-conses*))
    (%badpat form))
  (multiple-value-bind (elements cells)
      (%collect-list form)
    (unwind-protect
         elements
      (dolist (cell cells)
        (remhash cell *active-conses*)))))

(defun %parse-list (form)
  (multiple-value-bind (elements cells)
      (%collect-list form)
    (unwind-protect
         (%dispatch-list elements form)
      (dolist (cell cells)
        (remhash cell *active-conses*)))))

;;; Parsing.

(defun %parse (form)
  (cond
    ((characterp form)
     (%make-raw :kind :consume :predicate (%literal-bits (character-code form))))
    ((stringp form)
     (if (zerop (length form))
         (%make-raw :kind :epsilon)
         (%make-raw
          :kind :seq
          :children (loop for character across form
                          collect (%make-raw
                                   :kind :consume
                                   :predicate (%literal-bits
                                               (character-code character)))))))
    ((consp form)
     (when (gethash form *active-conses*)
       (%badpat form))
     (%parse-list form))
    ((eq form :epsilon)
     (%make-raw :kind :epsilon))
    ((eq form :any)
     (%make-raw :kind :consume :predicate (%any-bits)))
    ((eq form :bol)
     (%make-raw :kind :assert :assertion :bol))
    ((eq form :eol)
     (%make-raw :kind :assert :assertion :eol))
    (t
     (%badpat form))))

(defun %expect-arity (args count form)
  (unless (= (length args) count)
    (%badpat form)))

(defun %repeat-bounds (minimum maximum form)
  (unless (and (integerp minimum) (<= 0 minimum +re-dup-max+))
    (%fail :badbr form))
  (when maximum
    (unless (and (integerp maximum) (<= 0 maximum +re-dup-max+))
      (%fail :badbr form)))
  (when (and maximum (< maximum minimum))
    (%fail :badbr form))
  (values minimum (if maximum maximum :unbounded)))

(defun %repeat-mode (modifier)
  (logxor modifier (if *minimal* 1 0)))

(defun %simple-repeat (args minimum maximum modifier form)
  (%expect-arity args 1 form)
  (%make-raw :kind :repeat
             :children (list (%parse (first args)))
             :minimum minimum
             :maximum maximum
             :mode (%repeat-mode modifier)))

(defun %repeat (args modifier form)
  (%expect-arity args 3 form)
  (destructuring-bind (minimum maximum expression) args
    (multiple-value-bind (minimum maximum)
        (%repeat-bounds minimum maximum form)
      (%make-raw :kind :repeat
                 :children (list (%parse expression))
                 :minimum minimum
                 :maximum maximum
                 :mode (%repeat-mode modifier)))))

(defun %bracket-item (item form)
  (cond
    ((characterp item)
     (character-code item)
     (list :char item))
    ((consp item)
     (%bracket-item-list (%safe-elements item) item form))
    (t
     (%badpat form))))

(defun %bracket-item-list (elements item form)
  (when (null elements)
    (%badpat form))
  (let ((operator (first elements))
        (args (rest elements)))
    (unless (keywordp operator)
      (%badpat item))
    (case operator
      (:range
       (%expect-arity args 2 item)
       (let ((first (first args))
             (last (second args)))
         (unless (and (characterp first) (characterp last))
           (%fail :erange item))
         (let ((first-code (character-code first))
               (last-code (character-code last)))
           (unless (<= first-code last-code)
             (%fail :erange item))
           (list :range first last))))
      (:posix
       (%expect-arity args 1 item)
       (list :posix (first args)))
      ((:collating :equivalence)
       (%expect-arity args 1 item)
       (let ((character (first args)))
         (unless (characterp character)
           (%fail :ecollate item))
         (character-code character)
         (list operator character)))
      (t
       (%badpat item)))))

(defun %class-predicate (items form complement-p)
  (let ((descriptors (mapcar (lambda (item) (%bracket-item item form)) items)))
    (predicate-from-items descriptors *case-insensitive* *newline* complement-p)))

(defun %dispatch-list (elements form)
  (when (null elements)
    (%badpat form))
  (let ((operator (first elements))
        (args (rest elements)))
    (unless (keywordp operator)
      (%badpat form))
    (case operator
      (:seq
       (if (null args)
           (%make-raw :kind :epsilon)
           (%make-raw :kind :seq :children (mapcar #'%parse args))))
      (:or
       (when (< (length args) 2)
         (%badpat form))
       (%make-raw :kind :or :children (mapcar #'%parse args)))
      (:capture
       (%expect-arity args 1 form)
       (%make-raw :kind :capture :children (list (%parse (first args)))))
      (:*
       (%simple-repeat args 0 :unbounded 0 form))
      (:+
       (%simple-repeat args 1 :unbounded 0 form))
      (:?
       (%simple-repeat args 0 1 0 form))
      (:repeat
       (%repeat args 0 form))
      (:repeat?
       (%repeat args 1 form))
      (:*?
       (%simple-repeat args 0 :unbounded 1 form))
      (:+?
       (%simple-repeat args 1 :unbounded 1 form))
      (:??
       (%simple-repeat args 0 1 1 form))
      (:class
       (when (null args)
         (%badpat form))
       (%make-raw :kind :consume
                  :predicate (%class-predicate args form nil)))
      (:not-class
       (when (null args)
         (%badpat form))
       (%make-raw :kind :consume
                  :predicate (%class-predicate args form t)))
      (t
       (%badpat form)))))

;;; Flattening and left-associative lowering.

(defun %flatten (kind raws)
  (loop for raw in raws
        if (eq (%raw-kind raw) kind)
          append (%flatten kind (%raw-children raw))
        else
          collect raw))

(defun %lower-nary (kind raws)
  (let ((parts (mapcar #'%lower raws)))
    (cond
      ((null parts)
       (%make-raw :kind :epsilon))
      ((null (rest parts))
       (first parts))
      (t
       (reduce (lambda (left right)
                 (%make-raw :kind kind :children (list left right)))
               parts)))))

(defun %lower (raw)
  (case (%raw-kind raw)
    ((:epsilon :consume :assert)
     raw)
    (:capture
     (%make-raw :kind :capture
                :children (list (%lower (first (%raw-children raw))))))
    (:repeat
     (%make-raw :kind :repeat
                :children (list (%lower (first (%raw-children raw))))
                :minimum (%raw-minimum raw)
                :maximum (%raw-maximum raw)
                :mode (%raw-mode raw)))
    (:seq
     (%lower-nary :seq (%flatten :seq (%raw-children raw))))
    (:or
     (%lower-nary :or (%flatten :or (%raw-children raw))))
    (t
     (%badpat raw))))

;;; Canonical emission: preorder identifiers, capture numbers and predicates.

(defun %emit (raw parent nodes predicates groups)
  (let ((id (fill-pointer nodes)))
    (vector-push-extend nil nodes)
    (case (%raw-kind raw)
      (:epsilon
       (setf (aref nodes id)
             (make-regexp-node :id id :kind :epsilon :parent parent))
       (values `(:epsilon ,id) id))
      (:consume
       (let ((predicate (fill-pointer predicates)))
         (vector-push-extend (%raw-predicate raw) predicates)
         (setf (aref nodes id)
               (make-regexp-node :id id :kind :consume :parent parent
                                 :predicate predicate))
         (values `(:consume ,id ,predicate) id)))
      (:assert
       (setf (aref nodes id)
             (make-regexp-node :id id :kind :assert :parent parent))
       (values `(:assert ,id ,(%raw-assertion raw)) id))
      (:seq
       (multiple-value-bind (left left-id)
           (%emit (first (%raw-children raw)) id nodes predicates groups)
         (multiple-value-bind (right right-id)
             (%emit (second (%raw-children raw)) id nodes predicates groups)
           (setf (aref nodes id)
                 (make-regexp-node :id id :kind :seq :parent parent
                                   :children (vector left-id right-id)))
           (values `(:seq ,id ,left ,right) id))))
      (:or
       (multiple-value-bind (left left-id)
           (%emit (first (%raw-children raw)) id nodes predicates groups)
         (multiple-value-bind (right right-id)
             (%emit (second (%raw-children raw)) id nodes predicates groups)
           (setf (aref nodes id)
                 (make-regexp-node :id id :kind :or :parent parent
                                   :children (vector left-id right-id)))
           (values `(:or ,id ,left ,right) id))))
      (:capture
       (let ((group (incf (car groups))))
         (multiple-value-bind (child child-id)
             (%emit (first (%raw-children raw)) id nodes predicates groups)
           (setf (aref nodes id)
                 (make-regexp-node :id id :kind :capture :parent parent
                                   :capture group
                                   :children (vector child-id)))
           (values `(:capture ,id ,group ,child) id))))
      (:repeat
       (multiple-value-bind (child child-id)
           (%emit (first (%raw-children raw)) id nodes predicates groups)
         (setf (aref nodes id)
               (make-regexp-node :id id :kind :repeat :parent parent
                                 :minimum (%raw-minimum raw)
                                 :maximum (%raw-maximum raw)
                                 :mode (%raw-mode raw)
                                 :children (vector child-id)))
         (values `(:repeat ,id ,(%raw-minimum raw) ,(%raw-maximum raw)
                   ,(%raw-mode raw) ,child)
                 id)))
      (t
       (%badpat raw)))))

(defun normalize-regexp (expression &key case-insensitive newline minimal)
  "Validate EXPRESSION and return (values CANONICAL-AST METADATA)."
  (let* ((*active-conses* (make-hash-table :test #'eq))
         (*case-insensitive* case-insensitive)
         (*newline* newline)
         (*minimal* minimal)
         (raw (%parse expression))
         (shape (%lower raw))
         (nodes (make-array 16 :adjustable t :fill-pointer 0))
         (predicates (make-array 8 :adjustable t :fill-pointer 0))
         (groups (list 0)))
    (multiple-value-bind (ast id)
        (%emit shape nil nodes predicates groups)
      (declare (ignore id))
      (values ast
              (make-regexp-metadata
               :nodes (coerce nodes 'simple-vector)
               :predicates (coerce predicates 'simple-vector)
               :group-count (car groups)
               :case-insensitive case-insensitive
               :newline newline
               :minimal minimal)))))
