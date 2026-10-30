(uiop:define-package #:ooparts/regexp/api
  (:use #:cl)
  (:import-from #:ooparts/regexp/model
    #:+re-dup-max+ #:compiled-graph-metadata
    #:make-regexp #:make-regexp-match #:regexp #:regexp-backend #:regexp-error
    #:regexp-error-code #:regexp-error-form #:regexp-group-count #:regexp-implementation
    #:regexp-match #:regexp-match-offsets #:regexp-match-string #:regexp-match-p
    #:regexp-metadata-of
    #:regexp-p)
  (:import-from #:ooparts/regexp/compiler #:compile-graph)
  (:import-from #:ooparts/regexp/text #:parse-regexp-string)
  (:import-from #:ooparts/regexp/selection #:history-captures #:select-history)
  (:import-from #:ooparts/regexp/vm #:make-vm-program #:run-vm)
  (:import-from #:ooparts/regexp/automaton #:make-automaton #:run-automaton)
  (:export #:compile-regexp #:compile-regexp-string #:match-regexp #:search-regexp
    #:regexp-p #:regexp-backend #:regexp-group-count
    #:regexp-match-p #:match-start #:match-end #:match-string
    #:regexp #:regexp-match
    #:regexp-error #:regexp-error-code #:regexp-error-form
    #:+re-dup-max+))
(in-package #:ooparts/regexp/api)

(declaim (inline %check-group))

(defun %check-input (string)
  (unless (stringp string)
    (error 'type-error :datum string :expected-type 'string))
  (loop for character across string
        for code = (char-code character)
        unless (<= 1 code 255)
          do (error 'type-error :datum character :expected-type '(integer 1 255)))
  string)

(defun compile-regexp (expression &key (backend :vm) case-insensitive newline minimal)
  "Compile an S-expression regular expression into an immutable REGEXP object."
  (unless (member backend '(:vm :automaton))
    (error 'type-error :datum backend :expected-type '(member :vm :automaton)))
  (let* ((graph (compile-graph expression
                               :case-insensitive case-insensitive
                               :newline newline
                               :minimal minimal))
         (implementation (ecase backend
                           (:vm (make-vm-program graph))
                           (:automaton (make-automaton graph)))))
    (make-regexp :backend backend
                 :implementation implementation
                 :metadata (compiled-graph-metadata graph))))

(defun compile-regexp-string (pattern &key (backend :vm) case-insensitive newline minimal)
  "Compile POSIX ERE text PATTERN into an immutable REGEXP object."
  (compile-regexp (parse-regexp-string pattern)
                  :backend backend
                  :case-insensitive case-insensitive
                  :newline newline
                  :minimal minimal))

(defun %run-engine (regexp string start require-end not-bol not-eol)
  (ecase (regexp-backend regexp)
    (:vm (run-vm (regexp-implementation regexp) string start
                 require-end not-bol not-eol))
    (:automaton (run-automaton (regexp-implementation regexp) string start
                               require-end not-bol not-eol))))

(defun %match-at (regexp string start require-end not-bol not-eol)
  (let ((metadata (regexp-metadata-of regexp)))
    (multiple-value-bind (histories arena)
        (%run-engine regexp string start require-end not-bol not-eol)
      (let ((winner (select-history histories metadata arena)))
        (when winner
          (make-regexp-match
           :string string
           :offsets (history-captures winner metadata arena)))))))

(defun match-regexp (regexp string &key not-bol not-eol)
  "Match the whole of STRING against REGEXP, returning a REGEXP-MATCH or NIL."
  (check-type regexp regexp)
  (%check-input string)
  (%match-at regexp string 0 t not-bol not-eol))

(defun search-regexp (regexp string &key not-bol not-eol)
  "Return the leftmost REGEXP-MATCH in STRING, or NIL."
  (check-type regexp regexp)
  (%check-input string)
  (loop for start from 0 to (length string)
        for match = (%match-at regexp string start nil not-bol not-eol)
        when match return match))

(defun %group (group group-count)
  (unless (and (integerp group) (<= 0 group group-count))
    (error 'type-error :datum group :expected-type `(integer 0 ,group-count)))
  group)

(defun %group-boundary (match group which)
  (let* ((offsets (regexp-match-offsets match))
         (group (if (null group) 0 (%group group (1- (floor (length offsets) 2))))))
    (let ((value (aref offsets (+ (* 2 group) which))))
      (if (= value -1) nil value))))

(defun match-start (match &optional (group 0))
  "Start offset of GROUP in MATCH, or NIL when the group did not participate."
  (check-type match regexp-match)
  (%group-boundary match group 0))

(defun match-end (match &optional (group 0))
  "End offset of GROUP in MATCH, or NIL when the group did not participate."
  (check-type match regexp-match)
  (%group-boundary match group 1))

(defun match-string (match &optional (group 0))
  "Substring of the matched input for GROUP, or NIL when it did not participate."
  (check-type match regexp-match)
  (let ((start (match-start match group))
        (end (match-end match group)))
    (when (and start end)
      (subseq (regexp-match-string match) start end))))
