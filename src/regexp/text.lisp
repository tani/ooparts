;;; POSIX ERE text front end for the regexp library.
;;;
;;; The parser turns a pattern string into the public S-expression language;
;;; normalization remains responsible for semantic validation.  The accepted
;;; dialect is POSIX extended regular-expression notation in the fixed C-locale
;;; character domain, plus the 2024 per-repetition minimal modifier.
(uiop:define-package #:ooparts/regexp/text
  (:use #:cl)
  (:import-from #:ooparts/regexp/model
    #:regexp-error)
  (:export #:parse-regexp-string))
(in-package #:ooparts/regexp/text)

(defstruct (%parser
             (:constructor make-%parser))
  (string "" :type string)
  (position 0 :type (integer 0 *)))

(defun %fail (parser &optional (code :badpat))
  (error 'regexp-error :code code :form (%parser-string parser)))

(defun %end-p (parser)
  (>= (%parser-position parser) (length (%parser-string parser))))

(defun %peek (parser &optional (offset 0))
  (let ((index (+ (%parser-position parser) offset)))
    (and (< index (length (%parser-string parser)))
         (char (%parser-string parser) index))))

(defun %advance (parser)
  (prog1 (char (%parser-string parser) (%parser-position parser))
    (incf (%parser-position parser))))

(defun %starts-with-p (parser prefix)
  (let ((start (%parser-position parser)))
    (and (<= (+ start (length prefix)) (length (%parser-string parser)))
         (string= prefix (%parser-string parser)
                  :start2 start :end2 (+ start (length prefix))))))

(defun %digit-p (character)
  (and character (digit-char-p character)))

(defun %check-domain (pattern)
  (loop for character across pattern
        for code = (char-code character)
        unless (<= 1 code 255)
          do (error 'regexp-error :code :badpat :form pattern))
  pattern)

;;; Recursive-descent grammar:
;;;   alternation  := concatenation ("|" concatenation)*
;;;   concatenation := repetition*
;;;   repetition   := atom (quantifier | interval) "?"?
;;;   atom         := group | bracket | "." | "^" | "$" | escape | ordinary

(defun parse-regexp-string (pattern)
  "Parse PATTERN as POSIX ERE text and return the S-expression language form."
  (unless (stringp pattern)
    (error 'type-error :datum pattern :expected-type 'string))
  (%check-domain pattern)
  (let ((parser (make-%parser :string pattern)))
    (let ((expression (%parse-alternation parser)))
      (unless (%end-p parser)
        (%fail parser))
      expression)))

(defun %parse-alternation (parser)
  (let ((branches (list (%parse-concatenation parser))))
    (loop while (eql (%peek parser) #\|)
          do (%advance parser)
             (push (%parse-concatenation parser) branches))
    (if (null (cdr branches))
        (first branches)
        `(:or ,@(nreverse branches)))))

(defun %parse-concatenation (parser)
  (let ((items '()))
    (loop for character = (%peek parser)
          while (and character (not (member character '(#\| #\)))))
          do (push (%parse-repeat parser) items))
    (cond ((null items) :epsilon)
          ((null (cdr items)) (first items))
          (t `(:seq ,@(nreverse items))))))

(defun %quantified (parser ordinary minimal)
  (if (eql (%peek parser) #\?)
      (progn (%advance parser) (list minimal))
      (list ordinary)))

(defun %parse-repeat (parser)
  (let ((atom (%parse-atom parser)))
    (when (and (member atom '(:bol :eol))
               (or (member (%peek parser) '(#\* #\+ #\?))
                   (and (eql (%peek parser) #\{) (%interval-ahead-p parser))))
      (%fail parser))
    (let ((quantified
            (case (%peek parser)
              (#\*
               (%advance parser)
               (cons (first (%quantified parser :* :*?))
                     (list atom)))
              (#\+
               (%advance parser)
               (cons (first (%quantified parser :+ :+?))
                     (list atom)))
              (#\?
               (%advance parser)
               (cons (first (%quantified parser :? :??))
                     (list atom)))
              (#\{
               (multiple-value-bind (minimum maximum modifier)
                   (%try-interval parser)
                 (if minimum
                     (list (if modifier :repeat? :repeat)
                           minimum maximum atom)
                     atom)))
              (t atom))))
      (unless (eq quantified atom)
        ;; A second quantifier or a valid interval directly after a quantified
        ;; atom is a malformed repetition.
        (when (or (member (%peek parser) '(#\* #\+ #\?))
                  (and (eql (%peek parser) #\{) (%interval-ahead-p parser)))
          (%fail parser)))
      quantified)))

(defun %parse-atom (parser)
  (let ((character (%peek parser)))
    (cond
      ((null character) (%fail parser))
      ((eql character #\()
       (%advance parser)
       (let ((expression (%parse-alternation parser)))
         (unless (eql (%peek parser) #\))
           (%fail parser))
         (%advance parser)
         `(:capture ,expression)))
      ((eql character #\[) (%parse-bracket parser))
      ((eql character #\.) (%advance parser) :any)
      ((eql character #\^) (%advance parser) :bol)
      ((eql character #\$) (%advance parser) :eol)
      ((eql character #\\)
       (%advance parser)
       (when (%end-p parser) (%fail parser))
       (%advance parser))
      ((member character '(#\* #\+ #\?)) (%fail parser))
      (t (%advance parser)))))

;;; Bracket expressions.

(defun %parse-bracket (parser)
  (%advance parser)                      ; "["
  (let ((negated (eql (%peek parser) #\^)))
    (when negated (%advance parser))
    (let ((items '())
          (first-p t))
      (loop
        (let ((character (%peek parser)))
          (cond
            ((null character) (%fail parser))
            ((and (eql character #\]) (not first-p))
             (%advance parser)
             (return))
            ((eql character #\])
             ;; A leading "]" is an ordinary character.
             (%advance parser)
             (push #\] items))
            ((%starts-with-p parser "[:")
             (push (%parse-posix-class parser) items))
            ((%starts-with-p parser "[.")
             (push (%parse-collating parser #\. :collating) items))
            ((%starts-with-p parser "[=")
             (push (%parse-collating parser #\= :equivalence) items))
            (t
             (let ((item (%parse-bracket-character parser)))
               (cond
                 ((and (characterp item)
                       (not (eql item #\-))
                       (eql (%peek parser) #\-)
                       (let ((next (%peek parser 1)))
                         (and next (not (eql next #\])))))
                  (%advance parser)     ; "-"
                  (let ((end (%parse-bracket-character parser)))
                    (unless (characterp end) (%fail parser))
                    (push (list :range item end) items)))
                 (t
                  (push item items))))))
          (setf first-p nil)))
      (when (null items) (%fail parser))
      (if negated
          `(:not-class ,@(nreverse items))
          `(:class ,@(nreverse items))))))

(defun %parse-bracket-character (parser)
  (let ((character (%peek parser)))
    (unless character (%fail parser))
    (if (eql character #\\)
        (progn
          (%advance parser)
          (when (%end-p parser) (%fail parser))
          (%advance parser))
        (%advance parser))))

(defun %parse-posix-class (parser)
  (%advance parser) (%advance parser)   ; "[:"
  (let ((start (%parser-position parser)))
    (loop until (or (%end-p parser)
                    (and (eql (%peek parser) #\:)
                         (eql (%peek parser 1) #\])))
          do (%advance parser))
    (when (%end-p parser) (%fail parser))
    (let ((name (subseq (%parser-string parser) start (%parser-position parser))))
      (when (zerop (length name)) (%fail parser))
      (%advance parser) (%advance parser) ; ":]"
      (list :posix (intern (string-upcase name) :keyword)))))

(defun %parse-collating (parser delimiter kind)
  (%advance parser) (%advance parser)   ; "[." or "[="
  (let ((start (%parser-position parser)))
    (loop until (or (%end-p parser)
                    (and (eql (%peek parser) delimiter)
                         (eql (%peek parser 1) #\])))
          do (%advance parser))
    (when (%end-p parser) (%fail parser))
    (let ((content (subseq (%parser-string parser) start (%parser-position parser))))
      (%advance parser) (%advance parser) ; ".]" or "=]"
      (if (= (length content) 1)
          (list kind (char content 0))
          ;; Multi-character collating elements are outside the fixed C locale;
          ;; normalization reports :ecollate for the string payload.
          (list kind content)))))

;;; Intervals.  A "{" that does not form a syntactically valid interval is left
;;; unconsumed and therefore parsed as an ordinary literal character.

(defun %interval-ahead-p (parser)
  (let ((index (%parser-position parser))
        (length (length (%parser-string parser)))
        (string (%parser-string parser)))
    (and (< index length)
         (eql (char string index) #\{)
         (let ((position (1+ index)))
           (loop while (and (< position length)
                            (digit-char-p (char string position)))
                 do (incf position))
           (and (> position (1+ index))
                (or (and (< position length)
                         (eql (char string position) #\}))
                    (and (< position length)
                         (eql (char string position) #\,)
                         (progn
                           (incf position)
                           (loop while (and (< position length)
                                            (digit-char-p (char string position)))
                                 do (incf position))
                           (and (< position length)
                                (eql (char string position) #\}))))))))))

(defun %try-interval (parser)
  "Parse an interval at the current \"{\"; return NIL when malformed."
  (unless (eql (%peek parser) #\{)
    (return-from %try-interval nil))
  (let ((start (%parser-position parser))
        (string (%parser-string parser))
        (length (length (%parser-string parser))))
    (labels ((digits ()
               (let ((begin (%parser-position parser)))
                 (loop while (and (< (%parser-position parser) length)
                                  (digit-char-p (char string (%parser-position parser))))
                       do (incf (%parser-position parser)))
                 (if (= begin (%parser-position parser))
                     nil
                     (parse-integer string :start begin :end (%parser-position parser))))))
      (%advance parser)                 ; "{"
      (let ((minimum (digits)))
        (unless minimum
          (setf (%parser-position parser) start)
          (return-from %try-interval nil))
        (let ((maximum minimum))
          (cond
            ((eql (%peek parser) #\}) (%advance parser))
            ((eql (%peek parser) #\,)
             (%advance parser)
             (setf maximum (digits))
             (unless (eql (%peek parser) #\})
               (setf (%parser-position parser) start)
               (return-from %try-interval nil))
             (%advance parser))
            (t
             (setf (%parser-position parser) start)
             (return-from %try-interval nil)))
          (let ((modifier (when (eql (%peek parser) #\?)
                            (%advance parser)
                            t)))
            (values minimum maximum modifier)))))))
