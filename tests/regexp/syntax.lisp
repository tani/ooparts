;;; Pattern syntax, character classes and domain validation for ooparts/regexp.
(uiop:define-package #:ooparts-tests/regexp/syntax
  (:use #:cl)
  (:import-from #:ooparts-tests/regexp/support
    #:check #:run-case #:run-for-backends #:check-error-code #:check-type-error)
  (:import-from #:ooparts/regexp
    #:compile-regexp #:match-regexp #:search-regexp
    #:match-start #:match-end #:match-string)
  (:export #:run-tests #:run-syntax-tests))
(in-package #:ooparts-tests/regexp/syntax)

(defun one (character)
  (string character))

(defun class-form (name)
  (list :class (list :posix name)))

(defun run-named-class-tests ()
  (dolist (case
           '((:upper #\A #\a)
             (:lower #\a #\A)
             (:alpha #\A #\0)
             (:digit #\5 #\A)
             (:alnum #\5 #\-)
             (:xdigit #\f #\g)
             (:blank #\Tab #\Newline)
             (:space #\Newline #\A)
             (:cntrl #\Tab #\A)
             (:print #\Space #\Rubout)
             (:graph #\A #\Space)
             (:punct #\! #\A)))
    (destructuring-bind (name member nonmember) case
      (run-case (class-form name) (one member) '((0 1))
                :description (format nil "POSIX class ~S membership" name))
      (run-case (class-form name) (one nonmember) nil
                :description (format nil "POSIX class ~S non-membership" name))))
  ;; TAB is blank and space; newline is space but not blank.
  (run-case (class-form :blank) (one #\Space) '((0 1))
            :description "blank contains space")
  (run-case (class-form :blank) (one #\Tab) '((0 1))
            :description "blank contains tab")
  (run-case (class-form :blank) (one #\Newline) nil
            :description "blank excludes newline")
  (run-case (class-form :space) (one #\Tab) '((0 1))
            :description "space contains tab")
  (run-case (class-form :space) (one #\Space) '((0 1))
            :description "space contains space")
  (run-case (class-form :space) (one #\Newline) '((0 1))
            :description "space contains newline")
  ;; RUBOUT (DEL, code 127) is a control character, not printable or graphic.
  ;; The portable standard name is RUBOUT; DEL is an implementation extension.
  (run-case (class-form :cntrl) (one #\Rubout) '((0 1))
            :description "cntrl contains DEL")
  (run-case (class-form :cntrl) (one #\Space) nil
            :description "cntrl excludes space")
  (run-case (class-form :print) (one #\Rubout) nil
            :description "print excludes DEL")
  (run-case (class-form :graph) (one #\Rubout) nil
            :description "graph excludes DEL")
  ;; Punctuation covers each punctuation interval.
  (dolist (character '(#\! #\- #\_ #\{ #\~))
    (run-case (class-form :punct) (one character) '((0 1))
              :description (format nil "punct contains ~S" character)))
  (run-case (class-form :punct) (one #\A) nil :description "punct excludes letter")
  (run-case (class-form :punct) (one #\5) nil :description "punct excludes digit")
  ;; Case folding applies to upper and lower.
  (run-case (class-form :upper) "a" '((0 1))
            :flags '(:case-insensitive t)
            :description "case-insensitive upper matches lower")
  (run-case (class-form :lower) "A" '((0 1))
            :flags '(:case-insensitive t)
            :description "case-insensitive lower matches upper")
  (run-case (class-form :alpha) "Z" '((0 1))
            :flags '(:case-insensitive t)
            :description "case-insensitive alpha stays unchanged"))

(defun run-bracket-form-tests ()
  (run-case '(:class (:range #\a #\c)) "b" '((0 1)) :description "range membership")
  (run-case '(:class (:range #\a #\c)) "d" nil :description "range non-membership")
  (run-case '(:not-class (:range #\a #\c)) "d" '((0 1))
            :description "complemented range")
  (run-case '(:not-class (:range #\a #\c)) "b" nil
            :description "complemented range excludes member")
  (run-case '(:class (:collating #\x)) "x" '((0 1))
            :description "collating element")
  (run-case '(:class (:collating #\x)) "y" nil
            :description "collating element non-membership")
  (run-case '(:class (:equivalence #\x)) "x" '((0 1))
            :description "equivalence class")
  (run-case '(:class (:equivalence #\x)) "y" nil
            :description "equivalence class non-membership")
  (run-case '(:class #\a (:range #\c #\e)) "d" '((0 1))
            :description "mixed bracket items"))

(defun run-high-code-tests ()
  (let ((high (one (code-char 200)))
        (low (one (code-char 128)))
        (top (one (code-char 255))))
    (run-case (code-char 200) high '((0 1)) :description "literal high code")
    (run-case (list :class (code-char 200)) high '((0 1))
              :description "positive class high code")
    (run-case (list :class (list :range (code-char 128) (code-char 255)))
              high '((0 1)) :description "range high code")
    (run-case (list :class (list :range (code-char 128) (code-char 255)))
              low '((0 1)) :description "range lower boundary")
    (run-case :any high '((0 1)) :description "period high code")
    (run-case :any top '((0 1)) :description "period top code")
    (run-case '(:not-class #\a) high '((0 1))
              :description "complemented class high code")
    ;; Named classes have no members above code 127.
    (dolist (name '(:upper :lower :alpha :digit :alnum :xdigit
                    :blank :space :cntrl :print :graph :punct))
      (run-case (class-form name) high nil
                :description (format nil "class ~S excludes code 200" name))
      (run-case (class-form name) top nil
                :description (format nil "class ~S excludes code 255" name)))))

(defun run-domain-error-tests ()
  ;; NUL and codes above 255 are invalid pattern characters.
  (check-error-code (string (code-char 0)) :badpat "NUL string literal")
  (check-error-code (code-char 0) :badpat "NUL character literal")
  (check-error-code (string (code-char 256)) :badpat "code 256 string literal")
  (check-error-code (code-char 256) :badpat "code 256 character literal")
  (check-error-code (list :class (code-char 256)) :badpat
                    "code 256 in bracket")
  ;; The subject must be a string over codes 1..255.
  (run-for-backends
   (lambda (backend)
     (let ((regexp (compile-regexp "a" :backend backend)))
       (check-type-error (lambda () (search-regexp regexp (string (code-char 0))))
                         "NUL subject rejected")
       (check-type-error (lambda () (search-regexp regexp (string (code-char 256))))
                         "code 256 subject rejected")
       (check-type-error (lambda () (match-regexp regexp 42))
                         "non-string subject rejected"))))
  ;; Backend selection is validated.
  (check-type-error (lambda () (compile-regexp "a" :backend :bogus))
                    "unknown backend rejected"))

(defun run-group-index-tests ()
  (run-for-backends
   (lambda (backend)
     (let* ((regexp (compile-regexp '(:capture "a") :backend backend))
            (match (match-regexp regexp "a")))
       (check (not (null match)) "group index fixture matches")
       (check-type-error (lambda () (match-start match 2))
                         "group index above count rejected")
       (check-type-error (lambda () (match-start match -1))
                         "negative group index rejected")
       (check-type-error (lambda () (match-end match 1.5))
                         "non-integral group index rejected")
       (check-type-error (lambda () (match-string match 2))
                         "match-string group index rejected")))))

(defun run-malformed-tests ()
  (dolist (case
           '(((:foo "a") "unknown operator")
             ((:posix :alpha) "unknown top-level operator")
             ((:capture "a" "b") "capture arity")
             ((:or "a") "alternation arity")
             ((:repeat 0 1) "repeat arity")
             ((:class) "empty class")
             ((:not-class) "empty complemented class")
             ((:class (:class #\a)) "nested bracket form")
             ((:class (:posix :alpha) (:range #\a)) "range arity")))
    (destructuring-bind (expression description) case
      (check-error-code expression :badpat description)))
  ;; Improper and circular source structure.
  (check-error-code (cons :seq (cons "a" "b")) :badpat "improper list")
  (check-error-code
   (let ((form (list :seq "a")))
     (setf (cdr (last form)) form)
     form)
   :badpat "circular list")
  ;; Bracket-specific failures.
  (check-error-code '(:class (:range #\z #\a)) :erange "reversed range")
  (check-error-code '(:class (:range 1 #\a)) :erange "non-character range endpoint")
  (check-error-code '(:class (:posix :bogus)) :ectype "unknown class name")
  (check-error-code '(:class (:collating "ab")) :ecollate
                    "multi-character collating element")
  (check-error-code '(:class (:collating 1)) :ecollate
                    "non-character collating element")
  (check-error-code '(:class (:equivalence "ab")) :ecollate
                    "multi-character equivalence class")
  ;; Repetition bounds.
  (dolist (case
           '(((:repeat 3 2 #\a) "minimum above maximum")
             ((:repeat -1 2 #\a) "negative minimum")
             ((:repeat 0 -1 #\a) "negative maximum")
             ((:repeat 0 256 #\a) "maximum above 255")
             ((:repeat nil 2 #\a) "nil minimum")
             ((:repeat :x 2 #\a) "non-integer minimum")))
    (destructuring-bind (expression description) case
      (check-error-code expression :badbr description)))
  ;; Deeply nested nullable repetitions still terminate.
  (run-for-backends
   (lambda (backend)
     (let ((regexp
             (compile-regexp
              '(:repeat 0 nil
                (:capture (:repeat 0 nil (:repeat 0 nil "a"))))
              :backend backend)))
       (check (not (null (search-regexp regexp "aa")))
              "nested nullable repetitions terminate")))))

(defun run-tests ()
  (run-named-class-tests)
  (run-bracket-form-tests)
  (run-high-code-tests)
  (run-domain-error-tests)
  (run-group-index-tests)
  (run-malformed-tests)
  t)

(defun run-syntax-tests ()
  (run-tests))
