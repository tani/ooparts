;;; Standard ML '97 lexical analysis using fixed-cursor immutable regexps.
;;;
;;; TOKEN-KIND is :KEYWORD for reserved spellings (token text distinguishes
;;; them), :IDENTIFIER, :TYVAR, :INTEGER, :REAL, :WORD, :CHARACTER, :STRING,
;;; or :EOF.  Exactly "=" is an :IDENTIFIER, as required by the Definition;
;;; other nonreserved symbolic identifiers are also :IDENTIFIER.  Identifier
;;; and type-variable token values are IDENTIFIER objects, literal values are
;;; LITERAL objects, and keywords/EOF have NIL values.  Long identifiers are
;;; single tokens whose IDENTIFIER-PATH includes each qualifier.
;;;
;;; Numeric labels overlap decimal integer constants lexically.  They therefore
;;; remain :INTEGER literal tokens; NUMERIC-LABEL-P recognizes a canonical
;;; unsigned, nonzero decimal numeral (a nonzero first digit and no leading 0).
(uiop:define-package #:ooparts/sml/lexer
  (:use #:cl)
  (:import-from #:ooparts/sml/source
    #:source #:source-span #:source-span-end #:position-offset
    #:make-source #:make-span #:source-text #:sml-lexical-error)
  (:import-from #:ooparts/sml/syntax
    #:make-identifier #:make-literal #:make-real-literal #:literal-kind)
  (:import-from #:ooparts/regexp/api #:compile-regexp #:match-end)
  (:export
   #:token #:token-p #:make-token #:tokenize
   #:token-kind #:token-text #:token-value #:token-span
   #:reserved-word-p #:type-variable-p #:equality-type-variable-p
   #:numeric-label-p))
(in-package #:ooparts/sml/lexer)

(defstruct (token
             (:constructor %make-token (kind text value span))
             (:conc-name token-))
  (kind nil :type keyword :read-only t)
  (text "" :type string :read-only t)
  (value nil :read-only t)
  (span nil :type source-span :read-only t))

(defun make-token (kind text value span)
  "Construct an immutable token; TOKENIZE supplies the decoded VALUE normally."
  (check-type kind keyword)
  (check-type text string)
  (check-type span source-span)
  (%make-token kind (copy-seq text) value span))

;;; ---------------------------------------------------------------------------
;;; Compiled lexical expressions.  No expression is compiled while tokenizing.

(defparameter +digit-class+ '(:class (:range #\0 #\9)))
(defparameter +hex-digit-class+
  '(:class (:range #\0 #\9) (:range #\a #\f) (:range #\A #\F)))
(defparameter +letter-class+ '(:class (:range #\a #\z) (:range #\A #\Z)))
(defparameter +identifier-tail-class+
  '(:class (:range #\a #\z) (:range #\A #\Z) (:range #\0 #\9)
           #\_ #\'))
(defparameter +formatting-class+
  `(:class #\Space #\Tab #\Newline #\Return #\Page ,(code-char 11)))
(defparameter +symbolic-class+
  '(:class #\! #\% #\& #\$ #\# #\+ #\- #\/ #\: #\< #\= #\> #\?
           #\@ #\\ #\~ #\` #\^ #\| #\*))
(defparameter +optional-negative-sign+
  `(:? "~"))

(defparameter +layout-regexp+
  (load-time-value (compile-regexp `(:+ ,+formatting-class+))))
(defparameter +comment-open-regexp+
  (load-time-value (compile-regexp "(*")))
(defparameter +comment-close-regexp+
  (load-time-value (compile-regexp "*)")))

(defparameter +identifier-tail-regexp-expression+
  `(:* ,+identifier-tail-class+))
(defparameter +alphanumeric-expression+
  `(:seq ,+letter-class+ ,+identifier-tail-regexp-expression+))
(defparameter +symbolic-expression+ `(:+ ,+symbolic-class+))
(defparameter +identifier-regexp+
  (load-time-value (compile-regexp +alphanumeric-expression+)))
(defparameter +qualified-identifier-regexp+
  (load-time-value
   (compile-regexp
    `(:seq ,+alphanumeric-expression+
           (:* (:seq "." ,+alphanumeric-expression+))
           "." (:or ,+alphanumeric-expression+ ,+symbolic-expression+)))))
(defparameter +type-variable-regexp+
  (load-time-value
   (compile-regexp `(:seq #\' ,+identifier-tail-regexp-expression+))))
(defparameter +symbolic-identifier-regexp+
  (load-time-value (compile-regexp +symbolic-expression+)))

(defparameter +digits-expression+ `(:+ ,+digit-class+))
(defparameter +hex-digits-expression+ `(:+ ,+hex-digit-class+))
(defparameter +exponent-expression+
  `(:seq (:class #\E #\e) (:? "~") ,+digits-expression+))
(defparameter +number-regexp+
  (load-time-value
   (compile-regexp
    `(:or
      (:seq "0wx" ,+hex-digits-expression+)
      (:seq "0w" ,+digits-expression+)
      (:seq ,+optional-negative-sign+ "0x" ,+hex-digits-expression+)
      (:seq ,+optional-negative-sign+ ,+digits-expression+ "."
            ,+digits-expression+ (:? ,+exponent-expression+))
      (:seq ,+optional-negative-sign+ ,+digits-expression+
            ,+exponent-expression+)
      (:seq ,+optional-negative-sign+ ,+digits-expression+)))))

(defparameter +punctuation-regexp+
  (load-time-value
   (compile-regexp
    '(:or "..." "(" ")" "[" "]" "{" "}" "," ";" "_"))))
(defparameter +string-quote-regexp+
  (load-time-value (compile-regexp "\"")))
(defparameter +character-open-regexp+
  (load-time-value (compile-regexp "#\"")))

(defparameter +ordinary-string-character-regexp+
  (load-time-value
   (compile-regexp
    '(:class (:range #\Space #\!) (:range #\# #\[) (:range #\] #\~)))))
(defparameter +string-escape-regexp+
  (load-time-value
   (compile-regexp
    `(:or
      (:seq "\\" (:class #\a #\b #\t #\n #\v #\f #\r #\" #\\))
      (:seq "\\^" (:class (:range #\@ #\_)))
      (:seq "\\" ,+digit-class+ ,+digit-class+ ,+digit-class+)
      (:seq "\\u" ,+hex-digit-class+ ,+hex-digit-class+
            ,+hex-digit-class+ ,+hex-digit-class+)
      (:seq "\\" (:+ ,+formatting-class+) "\\")))))

;; All ordinary candidates are consulted at the same absolute cursor and the
;; greatest end wins.  Ties have no differing interpretations except two paths
;; toward the same identifier kind.
(defparameter +ordinary-token-patterns+
  (load-time-value
   (vector
    (cons :identifier +qualified-identifier-regexp+)
    (cons :identifier +identifier-regexp+)
    (cons :identifier +symbolic-identifier-regexp+)
    (cons :tyvar +type-variable-regexp+)
    (cons :number +number-regexp+)
    (cons :punctuation +punctuation-regexp+))))

(defun %fixed-match-end (regexp text cursor)
  "Match REGEXP exactly at absolute CURSOR, returning its exclusive end.
%MATCH-AT is intentionally used directly, without SEARCH-REGEXP, suffix copies,
or a cursor reset to zero.  NFA/DFA choice remains entirely in the Regexp API."
  (let ((match (ooparts/regexp/api::%match-at
                regexp text cursor nil nil nil)))
    (and match (match-end match))))

;;; ---------------------------------------------------------------------------
;;; Reserved words and small public classifiers.

(defparameter +reserved-spellings+
  '("abstype" "and" "andalso" "as" "case" "datatype" "do" "else" "end"
    "eqtype" "exception" "fn" "fun" "functor" "handle" "if" "in" "include"
    "infix" "infixr" "let" "local" "nonfix" "of" "op" "open" "orelse"
    "raise" "rec" "sharing" "sig" "signature" "struct" "structure" "then"
    "type" "val" "where" "while" "with" "withtype"
    "(" ")" "[" "]" "{" "}" "," ":" ";" "..." "_" "|" "=" "=>" "->" ":>" "#"))

(defun reserved-word-p (designator)
  "True when token or string DESIGNATOR is an SML reserved spelling, including =."
  (let ((text (etypecase designator
                (token (token-text designator))
                (string designator))))
    (not (null (member text +reserved-spellings+ :test #'string=)))))

(defun type-variable-p (token)
  "True for both ordinary and equality type-variable tokens."
  (and (token-p token) (eq (token-kind token) :tyvar)))

(defun equality-type-variable-p (designator)
  "True for a TYVAR token or type-variable spelling beginning with two primes."
  (let ((text (etypecase designator
                (token (if (eq (token-kind designator) :tyvar)
                           (token-text designator)
                           (return-from equality-type-variable-p nil)))
                (string designator))))
    (and (every (lambda (character) (<= 1 (char-code character) 255)) text)
         (let ((end (%fixed-match-end +type-variable-regexp+ text 0)))
           (and end (= end (length text))
                (>= (length text) 2)
                (char= (char text 1) #\'))))))

(defun numeric-label-p (token)
  "True when TOKEN can occupy an SML numeric-label position."
  (and (token-p token)
       (eq (token-kind token) :integer)
       (let ((text (token-text token)))
         (and (plusp (length text))
              (char/= (char text 0) #\0)
              (char/= (char text 0) #\~)
              (every (lambda (character) (digit-char-p character 10)) text)))))

(defun %lexical-error (source start end format-control &rest arguments)
  (error 'sml-lexical-error
         :span (make-span source start end)
         :message (apply #'format nil format-control arguments)))

(defun %identifier-path (text start end)
  (let ((path '())
        (component-start start))
    (loop for offset from start below end
          when (char= (char text offset) #\.)
            do (push (subseq text component-start offset) path)
               (setf component-start (1+ offset)))
    (push (subseq text component-start end) path)
    (nreverse path)))

(defun %identifier-token (source text start end kind)
  (let ((path (%identifier-path text start end))
        (span (make-span source start end)))
    (if (and (null (cdr path)) (reserved-word-p (first path))
             (string/= (first path) "="))
        (%make-token :keyword (subseq text start end) nil span)
        (progn
          (when (and (eq kind :identifier) (cdr path))
            (dolist (component path)
              (when (and (reserved-word-p component) (string/= component "="))
                (%lexical-error source start end
                                "Reserved word ~S cannot be an identifier component."
                                component))))
          (%make-token kind (subseq text start end)
                       (make-identifier path span) span)))))

;;; ---------------------------------------------------------------------------
;;; Layout and nested comments.

(defun %skip-comment (source text start open-end)
  (let ((depth 1)
        (cursor open-end)
        (length (length text)))
    (loop
      (when (>= cursor length)
        (%lexical-error source start length
                        "Unclosed comment; ~D comment level~:P remain open."
                        depth))
      (let ((close (%fixed-match-end +comment-close-regexp+ text cursor))
            (open (%fixed-match-end +comment-open-regexp+ text cursor)))
        (cond
          (close
           (setf cursor close)
           (decf depth)
           (when (zerop depth) (return cursor)))
          (open
           (setf cursor open)
           (incf depth))
          (t
           (incf cursor)))))))

(defun %skip-layout (source text start)
  (let ((cursor start))
    (loop
      (let ((layout-end (%fixed-match-end +layout-regexp+ text cursor)))
        (if layout-end
            (setf cursor layout-end)
            (let ((comment-end
                    (%fixed-match-end +comment-open-regexp+ text cursor)))
              (if comment-end
                  (setf cursor (%skip-comment source text cursor comment-end))
                  (return cursor))))))))

;;; ---------------------------------------------------------------------------
;;; Numeric decoding.  Integers are host bignums when necessary; no reader or
;;; floating-point conversion participates, and REAL-LITERAL retains exact scale.

(defun %signed-decimal-value (text start end)
  (let* ((negative (and (< start end) (char= (char text start) #\~)))
         (digits-start (if negative (1+ start) start)))
    (let ((value (parse-integer text :start digits-start :end end :radix 10)))
      (if negative (- value) value))))

(defun %real-value (text start end)
  (let* ((negative (char= (char text start) #\~))
         (body-start (if negative (1+ start) start))
         (exponent-position nil)
         (point-position nil))
    (loop for offset from body-start below end
          for character = (char text offset)
          do (cond
               ((or (char= character #\E) (char= character #\e))
                (setf exponent-position offset)
                (return))
               ((char= character #\.) (setf point-position offset))))
    (let* ((mantissa-end (or exponent-position end))
           (exponent (if exponent-position
                         (%signed-decimal-value text (1+ exponent-position) end)
                         0))
           (fraction-digits (if point-position
                                (- mantissa-end (1+ point-position))
                                0))
           (integral (parse-integer text :start body-start
                                    :end (or point-position mantissa-end)
                                    :radix 10))
           (fraction (if point-position
                         (parse-integer text :start (1+ point-position)
                                        :end mantissa-end :radix 10)
                         0))
           (significand (+ (* integral (expt 10 fraction-digits)) fraction)))
      (make-real-literal negative significand (- exponent fraction-digits)))))

(defun %number-literal (text span)
  (let* ((length (length text))
         (negative (char= (char text 0) #\~))
         (start (if negative 1 0)))
    (cond
      ((and (<= (+ start 3) length)
            (char= (char text start) #\0)
            (char= (char text (1+ start)) #\w)
            (char= (char text (+ start 2)) #\x))
       (make-literal :word (parse-integer text :start (+ start 3) :radix 16)
                     text span :base 16))
      ((and (<= (+ start 2) length)
            (char= (char text start) #\0)
            (char= (char text (1+ start)) #\w))
       (make-literal :word (parse-integer text :start (+ start 2) :radix 10)
                     text span :base 10))
      ((and (<= (+ start 2) length)
            (char= (char text start) #\0)
            (char= (char text (1+ start)) #\x))
       (make-literal :integer
                     (let ((value (parse-integer text :start (+ start 2)
                                                 :radix 16)))
                       (if negative (- value) value))
                     text span :base 16))
      ((loop for offset from start below length
             thereis (let ((character (char text offset)))
                       (or (char= character #\.)
                           (char= character #\E)
                           (char= character #\e))))
       (make-literal :real (%real-value text 0 length) text span))
      (t
       (make-literal :integer (%signed-decimal-value text 0 length)
                     text span :base 10)))))

(defun %check-number-boundary (source text start end)
  "Reject prefixes that would otherwise silently become an integer plus text."
  (when (and (= end (1+ start))
             (char= (char text start) #\0)
             (< end (length text))
             (member (char text end) '(#\x #\w)))
    (%lexical-error source start (min (length text) (+ start 2))
                    "Numeric base marker ~C requires at least one digit."
                    (char text end)))
  (when (and (= end (+ start 2))
             (char= (char text start) #\~)
             (char= (char text (1+ start)) #\0)
             (< end (length text))
             (member (char text end) '(#\x #\w)))
    (%lexical-error source start (min (length text) (+ start 3))
                    "Signed numeric base marker ~C requires digits."
                    (char text end)))
  (when (and (< end (length text))
             (member (char text end) '(#\E #\e)))
    (%lexical-error source end (1+ end)
                    "Exponent marker requires decimal digits, optionally after ~~."))
  (when (and (< end (length text))
             (char= (char text end) #\.)
             (not (%fixed-match-end +punctuation-regexp+ text end)))
    (%lexical-error source end (1+ end)
                    "A real decimal point requires at least one following digit.")))

(defun %number-token (source text start end)
  (%check-number-boundary source text start end)
  (let ((span (make-span source start end))
        (token-text (subseq text start end)))
    (let ((literal (%number-literal token-text span)))
      (%make-token (literal-kind literal) token-text literal span))))

;;; ---------------------------------------------------------------------------
;;; String and character constants.  The opening quote is matched as a token;
;;; escape matching then remains anchored at the current absolute source cursor.

(defun %decode-escape (source text start end)
  (let ((marker (char text (1+ start))))
    (cond
      ((digit-char-p marker 10)
       (let ((code (parse-integer text :start (1+ start) :end end :radix 10)))
         (unless (<= code 255)
           (%lexical-error source start end
                           "Decimal character escape ~D exceeds the 0-255 range."
                           code))
         (code-char code)))
      ((char= marker #\u)
       (let ((code (parse-integer text :start (+ start 2) :end end :radix 16)))
         (unless (<= code 255)
           (%lexical-error source start end
                           "Unicode character escape U+~4,'0X exceeds U+00FF."
                           code))
         (code-char code)))
      ((char= marker #\^)
       (code-char (- (char-code (char text (+ start 2))) 64)))
      ((member marker '(#\Space #\Tab #\Newline #\Return #\Page)
               :test #'char=)
       nil)
      ((= (char-code marker) 11) nil)
      (t
       (case marker
         (#\a (code-char 7))
         (#\b (code-char 8))
         (#\t (code-char 9))
         (#\n (code-char 10))
         (#\v (code-char 11))
         (#\f (code-char 12))
         (#\r (code-char 13))
         ((#\" #\\) marker)
         (otherwise
          (%lexical-error source start end "Unknown string escape.")))))))

(defun %scan-string (source text token-start quote-start)
  "Return (values decoded-string token-end), diagnosing all malformed strings."
  (let ((end nil)
        (length (length text)))
    (let ((value
            (with-output-to-string (out)
              (loop with cursor = (1+ quote-start)
                    do
                (when (>= cursor length)
                  (%lexical-error source token-start length
                                  "Unclosed string constant at end of input."))
                (let ((quote-end (%fixed-match-end +string-quote-regexp+
                                                   text cursor))
                      (escape-end (%fixed-match-end +string-escape-regexp+
                                                    text cursor))
                      (character-end
                        (%fixed-match-end +ordinary-string-character-regexp+
                                          text cursor)))
                  (cond
                    (quote-end
                     (setf end quote-end)
                     (return))
                    (escape-end
                     (let ((decoded (%decode-escape source text cursor escape-end)))
                       (when decoded (write-char decoded out)))
                     (setf cursor escape-end))
                    (character-end
                     (write-char (char text cursor) out)
                     (setf cursor character-end))
                    ((char= (char text cursor) #\\)
                     (if (= (1+ cursor) length)
                         (%lexical-error source cursor length
                                         "Unclosed escape at end of string.")
                         (%lexical-error
                          source cursor (min length (+ cursor 2))
                          "Illegal string escape; expected a simple, control, decimal, Unicode, or formatting escape.")))
                    (t
                     (%lexical-error
                      source cursor (1+ cursor)
                      "Unescaped character U+~4,'0X is not allowed in an SML string."
                      (char-code (char text cursor))))))))))
      (values value end))))

(defun %string-token (source text start)
  (multiple-value-bind (value end) (%scan-string source text start start)
    (let* ((span (make-span source start end))
         (token-text (subseq text start end)))
      (%make-token :string token-text
                  (make-literal :string value token-text span)
                  span))))

(defun %character-token (source text start quote-start)
  (multiple-value-bind (value end)
      (%scan-string source text start quote-start)
    (unless (= (length value) 1)
      (%lexical-error
       source start end
       "Character constant must decode to exactly one character, not ~D."
       (length value)))
    (let* ((span (make-span source start end))
         (token-text (subseq text start end)))
      (%make-token :character token-text
                  (make-literal :character (char value 0) token-text span)
                  span))))

;;; ---------------------------------------------------------------------------
;;; Main scanner.

(defun %next-token (source text start)
  (let ((character-open (%fixed-match-end +character-open-regexp+ text start)))
    (when character-open
      (return-from %next-token
        (%character-token source text start (1+ start)))))
  (when (%fixed-match-end +string-quote-regexp+ text start)
    (return-from %next-token (%string-token source text start)))
  (let ((best-kind nil)
        (best-end nil))
    (loop for pattern across +ordinary-token-patterns+
          for end = (%fixed-match-end (cdr pattern) text start)
          when (and end (or (null best-end) (> end best-end)))
            do (setf best-kind (car pattern) best-end end))
    (unless best-end
      (%lexical-error source start (1+ start)
                      "Illegal character or token beginning with U+~4,'0X."
                      (char-code (char text start))))
    ;; A selector marker starts a new token even without preceding whitespace.
    ;; Keep it out of a preceding symbolic identifier, as in =#a or =>#a.
    (when (and (eq best-kind :identifier)
               (> best-end (1+ start))
               (char/= (char text start) #\#)
               (char= (char text (1- best-end)) #\#)
               (< best-end (length text))
               (let ((character (char text best-end)))
                 (or (char<= #\a character #\z)
                     (char<= #\A character #\Z)
                     (digit-char-p character 10))))
      (decf best-end))
    (ecase best-kind
      (:identifier (%identifier-token source text start best-end :identifier))
      (:tyvar (%identifier-token source text start best-end :tyvar))
      (:number (%number-token source text start best-end))
      (:punctuation
       (%make-token :keyword (subseq text start best-end) nil
                   (make-span source start best-end))))))

(defun %validate-source-characters (source text)
  (loop for character across text
        for offset from 0
        for code = (char-code character)
        unless (<= 1 code 255)
          do (%lexical-error
              source offset (1+ offset)
              "Source character U+~4,'0X is outside the required 1-255 input range."
              code)))

(defun tokenize (input &key (source-name "<string>"))
  "Tokenize a SOURCE or string INPUT, returning a simple vector ending with EOF.
STRING input is made into a source named SOURCE-NAME.  Comments and formatting
are discarded.  Every match is anchored by the Regexp engine at its absolute
source cursor, and the longest candidate is selected.  The source alphabet is
the 256-character ordinal range 0-255 for decoded escapes; raw regexp input is
restricted to character codes 1-255 as required by the internal Regexp API.
Space, tab, newline, return, page, and vertical tab are formatting characters."
  (let* ((source (etypecase input
                   (source input)
                   (string (make-source input :name source-name))))
         (text (source-text source))
         (length (length text))
         (tokens '()))
    (%validate-source-characters source text)
    (loop with cursor = 0
          do
      (setf cursor (%skip-layout source text cursor))
      (if (= cursor length)
          (let ((token (%make-token :eof "" nil (make-span source cursor cursor))))
            (push token tokens)
            (return (coerce (nreverse tokens) 'simple-vector)))
          (let ((token (%next-token source text cursor)))
            (push token tokens)
            (setf cursor
                  (position-offset (source-span-end (token-span token)))))))))
