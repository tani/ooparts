(uiop:define-package #:ooparts/c99/lexer
  (:use #:cl)
  (:import-from #:ooparts/regexp #:compile-regexp-string #:search-regexp
                #:match-start #:match-end #:match-string)
  (:export #:tokenize-c99))
(in-package #:ooparts/c99/lexer)

;; This lexer is a deliberately bounded bootstrap, not a C99 preprocessor.
(defparameter *identifier* (compile-regexp-string "[A-Za-z_][A-Za-z_0-9]*"))
(defparameter *integer* (compile-regexp-string "[0-9]+"))
(defparameter *punctuation* (compile-regexp-string "[(){};]"))
(defparameter *keywords* '(("int" . :int) ("return" . :return)))
(defparameter *punctuators* '((#\( . :lparen) (#\) . :rparen)
                              (#\{ . :lbrace) (#\} . :rbrace)
                              (#\; . :semicolon)))

(defun %prefix-match (regexp source offset)
  (let ((match (search-regexp regexp (subseq source offset))))
    (when (and match (zerop (match-start match)))
      (values (match-string match) (+ offset (match-end match))))))

(defun tokenize-c99 (source)
  "Tokenize the supported C99 bootstrap subset; reject unsupported characters."
  (check-type source string)
  (let ((offset 0) (tokens nil) (length (length source)))
    (loop while (< offset length) do
      (cond
        ((find (char source offset) '(#\Space #\Tab #\Newline #\Return #\Page))
         (incf offset))
        ((and (< (1+ offset) length)
              (char= (char source offset) #\/)
              (char= (char source (1+ offset)) #\/))
         (setf offset (or (position #\Newline source :start offset) length)))
        ((and (< (1+ offset) length)
              (char= (char source offset) #\/)
              (char= (char source (1+ offset)) #\*))
         (let ((end (search "*/" source :start2 (+ offset 2))))
           (unless end (error "Unterminated C comment at offset ~D" offset))
           (setf offset (+ end 2))))
        (t
         (multiple-value-bind (word end) (%prefix-match *identifier* source offset)
           (cond
             (word
              (push (or (cdr (assoc word *keywords* :test #'string=))
                        (list :identifier word)) tokens)
              (setf offset end))
             (t
              (multiple-value-bind (digits next) (%prefix-match *integer* source offset)
                (cond
                  (digits
                   (push (list :number (parse-integer digits)) tokens)
                   (setf offset next))
                  (t
                   (multiple-value-bind (punctuation after)
                       (%prefix-match *punctuation* source offset)
                     (unless punctuation
                       (error "Unsupported C99 token at offset ~D: ~S"
                              offset (subseq source offset (min length (+ offset 12)))))
                     (push (cdr (assoc (char punctuation 0) *punctuators*)) tokens)
                     (setf offset after)))))))))))
    (nreverse tokens)))
