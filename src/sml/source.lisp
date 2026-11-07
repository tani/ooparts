;;; Immutable SML source text, source spans, and frontend conditions.
;;;
;;; Offsets are zero-based character offsets.  Span ends are exclusive and
;;; may equal the input length.  Lines and columns are one-based; only the
;;; Common Lisp #\Newline character advances the line number.
(uiop:define-package #:ooparts/sml/source
  (:use #:cl)
  (:shadow #:position)
  (:export
   #:source #:source-p #:make-source #:source-text #:source-name
   #:position #:position-p #:position-offset #:position-line #:position-column
   #:source-span #:source-span-p #:make-span
   #:source-span-source #:source-span-start #:source-span-end
   #:sml-source-error #:sml-lexical-error #:sml-syntax-error
   #:sml-error-span #:sml-error-message))
(in-package #:ooparts/sml/source)

(defstruct (source
             (:constructor %make-source (text name line-starts))
             (:conc-name source-))
  (text "" :type simple-string :read-only t)
  (name "<string>" :type string :read-only t)
  ;; Increasing offsets at which lines begin, including offset zero.  This
  ;; private index makes both positions of every span inexpensive to compute.
  (line-starts #(0) :type simple-vector :read-only t))

(defstruct (position
             (:constructor make-position (offset line column))
             (:conc-name position-))
  (offset 0 :type (integer 0 *) :read-only t)
  (line 1 :type (integer 1 *) :read-only t)
  (column 1 :type (integer 1 *) :read-only t))

(defstruct (source-span
             (:constructor %make-source-span (source start end))
             (:conc-name source-span-))
  (source nil :type source :read-only t)
  (start nil :type position :read-only t)
  (end nil :type position :read-only t))

(defun %source-line-starts (text)
  (let ((starts (make-array 16 :adjustable t :fill-pointer 0)))
    (vector-push-extend 0 starts)
    (loop for character across text
          for offset from 0
          when (char= character #\Newline)
            do (vector-push-extend (1+ offset) starts))
    (coerce starts 'simple-vector)))

(defun make-source (text &key (name "<string>"))
  "Return an immutable source named NAME, retaining a private copy of TEXT."
  (check-type text string)
  (check-type name string)
  ;; A private simple string prevents subsequent mutation of a caller's buffer
  ;; from changing offsets or token text.  The public accessor is for reading.
  (let ((copy (make-string (length text)))
        (name-copy (copy-seq name)))
    ;; MAKE-STRING is fresh even when TEXT is already a SIMPLE-STRING.
    (replace copy text)
    (%make-source copy name-copy (%source-line-starts copy))))

(defun %position-at (source offset)
  (let* ((starts (source-line-starts source))
         (low 0)
         (high (length starts)))
    ;; Find the greatest line start no greater than OFFSET.  Binary search is
    ;; used even for EOF, which may designate the empty final line.
    (loop while (< low high)
          for middle = (floor (+ low high) 2)
          do (if (<= (svref starts middle) offset)
                 (setf low (1+ middle))
                 (setf high middle)))
    (let ((line-index (1- low)))
      (make-position offset
                     (1+ line-index)
                     (1+ (- offset (svref starts line-index)))))))

(defun make-span (source start end)
  "Construct a span over SOURCE from inclusive START to exclusive END."
  (check-type source source)
  (check-type start (integer 0 *))
  (check-type end (integer 0 *))
  (let ((length (length (source-text source))))
    (unless (<= start end length)
      (error 'type-error
             :datum (list start end)
             :expected-type `(cons (integer 0 ,length)
                                   (cons (integer 0 ,length) null))))
    (%make-source-span source
                       (%position-at source start)
                       (%position-at source end))))

(defun %report-sml-error (condition stream)
  (let ((span (sml-error-span condition)))
    (if span
        (let ((start (source-span-start span)))
          (format stream "~A (~A:~D:~D, offsets ~D-~D)"
                  (sml-error-message condition)
                  (source-name (source-span-source span))
                  (position-line start)
                  (position-column start)
                  (position-offset start)
                  (position-offset (source-span-end span))))
        (write-string (sml-error-message condition) stream))))

(define-condition sml-source-error (error)
  ((span :initarg :span :initform nil :reader sml-error-span
         :type (or null source-span))
   (message :initarg :message :initform "SML frontend error"
            :reader sml-error-message :type string))
  (:report %report-sml-error)
  (:documentation "Base condition for errors tied to an optional SML span."))

(define-condition sml-lexical-error (sml-source-error)
  ()
  (:documentation "Invalid source characters, tokens, comments, or literals."))

(define-condition sml-syntax-error (sml-source-error)
  ()
  (:documentation "A token sequence that is not in the requested SML grammar."))
