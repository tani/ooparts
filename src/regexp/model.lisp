;;; Immutable data model and character tables for the regexp library.
(uiop:define-package #:ooparts/regexp/model
  (:use #:cl)
  (:export
   #:+re-dup-max+
   #:regexp-error #:regexp-error-code #:regexp-error-form
   #:regexp #:make-regexp #:regexp-p #:regexp-backend #:regexp-implementation
   #:regexp-metadata-of #:regexp-group-count
   #:regexp-match #:make-regexp-match #:regexp-match-p #:regexp-match-string
   #:regexp-match-offsets
   #:regexp-node #:make-regexp-node #:regexp-node-id #:regexp-node-kind
   #:regexp-node-parent #:regexp-node-children #:regexp-node-capture
   #:regexp-node-minimum #:regexp-node-maximum #:regexp-node-mode
   #:regexp-node-predicate
   #:regexp-metadata #:make-regexp-metadata #:regexp-metadata-nodes
   #:regexp-metadata-predicates #:regexp-metadata-group-count
   #:regexp-metadata-case-insensitive #:regexp-metadata-newline
   #:regexp-metadata-minimal #:regexp-metadata-node
   #:regexp-edge #:make-regexp-edge #:regexp-edge-source #:regexp-edge-label
   #:regexp-edge-destination
   #:compiled-graph #:make-compiled-graph #:compiled-graph-entry
   #:compiled-graph-state-count #:compiled-graph-edges
   #:compiled-graph-metadata
   #:predicate-matches-p #:character-code #:named-class-predicate
   #:assertion-satisfied-p #:predicate-from-items))
(in-package #:ooparts/regexp/model)

;;; The fixed C-locale character domain is 1..255.
(defconstant +re-dup-max+ 255)

(define-condition regexp-error (error)
  ((code :initarg :code :reader regexp-error-code)
   (form :initarg :form :reader regexp-error-form))
  (:report (lambda (condition stream)
             ;; Forms may be circular; never let reporting hang.
             (let ((*print-circle* t))
               (format stream "Regexp error ~S in ~S."
                       (regexp-error-code condition)
                       (regexp-error-form condition))))))

;;; Immutable public objects.

(defstruct (regexp (:constructor %make-regexp
                                 (&key backend implementation metadata-of))
                   (:conc-name regexp-))
  (backend nil :type t :read-only t)
  (implementation nil :type t :read-only t)
  (metadata-of nil :type t :read-only t))

(defun make-regexp (&key backend implementation (metadata nil metadata-p)
                         metadata-of)
  "Build the immutable REGEXP wrapper. Both :metadata and :metadata-of are
accepted for the compilation metadata."
  (%make-regexp :backend backend
                :implementation implementation
                :metadata-of (if metadata-p metadata metadata-of)))

(defstruct (regexp-match (:constructor make-regexp-match)
                         (:conc-name regexp-match-))
  (string "" :type string :read-only t)
  (offsets #() :type simple-vector :read-only t))

(defstruct (regexp-node (:constructor make-regexp-node)
                        (:conc-name regexp-node-))
  (id 0 :type (integer 0 *) :read-only t)
  (kind :epsilon :type keyword :read-only t)
  (parent nil :type (or null (integer 0 *)) :read-only t)
  (children #() :type simple-vector :read-only t)
  (capture nil :type (or null (integer 1 *)) :read-only t)
  (minimum nil :type (or null (integer 0 *)) :read-only t)
  (maximum nil :type (or null (integer 0 *) (eql :unbounded)) :read-only t)
  (mode nil :type (or null (integer 0 1)) :read-only t)
  (predicate nil :type (or null (integer 0 *)) :read-only t))

(defstruct (regexp-metadata (:constructor make-regexp-metadata)
                            (:conc-name regexp-metadata-))
  (nodes #() :type simple-vector :read-only t)
  (predicates #() :type simple-vector :read-only t)
  (group-count 0 :type (integer 0 *) :read-only t)
  (case-insensitive nil :type t :read-only t)
  (newline nil :type t :read-only t)
  (minimal nil :type t :read-only t))

(defun regexp-group-count (regexp)
  "Number of explicit capturing groups in REGEXP (group 0 is not counted)."
  (regexp-metadata-group-count (regexp-metadata-of regexp)))

(defun regexp-metadata-node (metadata id)
  "Return the node with structural ID from METADATA."
  (aref (regexp-metadata-nodes metadata) id))

(defstruct (regexp-edge (:constructor make-regexp-edge)
                        (:conc-name regexp-edge-))
  (source 0 :type (integer 0 *) :read-only t)
  (label nil :type t :read-only t)
  (destination 0 :type (integer 0 *) :read-only t))

(defstruct (compiled-graph (:constructor make-compiled-graph)
                           (:conc-name compiled-graph-))
  (entry 0 :type (integer 0 *) :read-only t)
  (state-count 0 :type (integer 0 *) :read-only t)
  (edges #() :type simple-vector :read-only t)
  (metadata nil :type t :read-only t))

;;; Bit-vector helpers. A predicate is a (simple-array bit (256)); index is
;;; the character code and code 0 is never a member.

(defun %make-bits ()
  (make-array 256 :element-type 'bit :initial-element 0))

(defun %set-range (bits start end)
  (loop for code from start to end
        do (setf (aref bits code) 1))
  bits)

(defun %fold-bits (bits)
  "Add the ASCII case counterpart of every member."
  (loop for code from 65 to 90
        when (= (aref bits code) 1)
          do (setf (aref bits (+ code 32)) 1))
  (loop for code from 97 to 122
        when (= (aref bits code) 1)
          do (setf (aref bits (- code 32)) 1))
  bits)

(defun predicate-matches-p (predicates id char-code)
  "True when predicate ID in PREDICATES admits CHAR-CODE."
  (and (integerp id)
       (<= 0 id)
       (< id (length predicates))
       (integerp char-code)
       (<= 0 char-code 255)
       (= (aref (aref predicates id) char-code) 1)))

(defun character-code (character)
  "Return the C-locale code of CHARACTER, signalling :badpat when invalid."
  (unless (characterp character)
    (error 'regexp-error :code :badpat :form character))
  (let ((code (char-code character)))
    (unless (<= 1 code 255)
      (error 'regexp-error :code :badpat :form character))
    code))

(defun %class-name (name)
  (if (or (symbolp name) (stringp name) (characterp name))
      (string-upcase (string name))
      (error 'regexp-error :code :ectype :form name)))

(defun named-class-predicate (name case-insensitive)
  "Return the fixed C-locale membership table for the named class NAME."
  (let* ((bits (%make-bits))
         (class (%class-name name)))
    (cond
      ((string= class "UPPER")
       (%set-range bits 65 90)
       (when case-insensitive (%set-range bits 97 122)))
      ((string= class "LOWER")
       (%set-range bits 97 122)
       (when case-insensitive (%set-range bits 65 90)))
      ((string= class "ALPHA")
       (%set-range bits 65 90)
       (%set-range bits 97 122))
      ((string= class "DIGIT")
       (%set-range bits 48 57))
      ((string= class "ALNUM")
       (%set-range bits 48 57)
       (%set-range bits 65 90)
       (%set-range bits 97 122))
      ((string= class "XDIGIT")
       (%set-range bits 48 57)
       (%set-range bits 65 70)
       (%set-range bits 97 102))
      ((string= class "BLANK")
       (%set-range bits 9 9)
       (%set-range bits 32 32))
      ((string= class "SPACE")
       (%set-range bits 9 13)
       (%set-range bits 32 32))
      ((string= class "CNTRL")
       (%set-range bits 1 31)
       (%set-range bits 127 127))
      ((string= class "PRINT")
       (%set-range bits 32 126))
      ((string= class "GRAPH")
       (%set-range bits 33 126))
      ((string= class "PUNCT")
       (%set-range bits 33 47)
       (%set-range bits 58 64)
       (%set-range bits 91 96)
       (%set-range bits 123 126))
      (t
       (error 'regexp-error :code :ectype :form name)))
    bits))

(defun assertion-satisfied-p (kind string pos length newline not-bol not-eol)
  "Test assertion KIND at POS in STRING of LENGTH."
  (ecase kind
    (:bol
     (or (and (zerop pos) (not not-bol))
         (and (plusp pos)
              newline
              (= (char-code (char string (1- pos))) 10))))
    (:eol
     (or (and (= pos length) (not not-eol))
         (and (< pos length)
              newline
              (= (char-code (char string pos)) 10))))))

;;; Bracket descriptors are canonical: (:char c), (:range a b), (:posix name),
;;; (:collating c) and (:equivalence c).

(defun %two-elements-p (list)
  (and (consp list) (consp (cdr list)) (null (cddr list))))

(defun %three-elements-p (list)
  (and (consp list) (consp (cdr list)) (consp (cddr list))
       (null (cdddr list))))

(defun %add-item (bits item case-insensitive)
  (cond
    ((and (consp item) (eq (car item) :char) (%two-elements-p item))
     (setf (aref bits (character-code (second item))) 1))
    ((and (consp item) (eq (car item) :range) (%three-elements-p item))
     (let ((start (second item))
           (end (third item)))
       (unless (and (characterp start) (characterp end))
         (error 'regexp-error :code :erange :form item))
       (let ((first-code (character-code start))
             (last-code (character-code end)))
         (unless (<= first-code last-code)
           (error 'regexp-error :code :erange :form item))
         (%set-range bits first-code last-code))))
    ((and (consp item) (eq (car item) :posix) (%two-elements-p item))
     (let ((class (named-class-predicate (second item) case-insensitive)))
       (loop for code from 0 below 256
             when (= (aref class code) 1)
               do (setf (aref bits code) 1))))
    ((and (consp item)
          (or (eq (car item) :collating) (eq (car item) :equivalence))
          (%two-elements-p item))
     (unless (characterp (second item))
       (error 'regexp-error :code :ecollate :form item))
     (setf (aref bits (character-code (second item))) 1))
    (t
     (error 'regexp-error :code :badpat :form item))))

(defun predicate-from-items (items case-insensitive newline complement-p)
  "Build a 256-bit predicate from canonical bracket descriptors."
  (let ((bits (%make-bits)))
    (dolist (item items)
      (%add-item bits item case-insensitive))
    (when case-insensitive
      (%fold-bits bits))
    (when complement-p
      (let ((complement (%make-bits)))
        (loop for code from 1 below 256
              unless (= (aref bits code) 1)
                do (setf (aref complement code) 1))
        (when newline
          (setf (aref complement 10) 0))
        (setf bits complement)))
    bits))
