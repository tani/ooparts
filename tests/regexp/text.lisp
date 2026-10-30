;;; POSIX ERE text-front-end regression module for ooparts/regexp.
(uiop:define-package #:ooparts-tests/regexp/text
  (:use #:cl)
  (:import-from #:ooparts-tests/regexp/support
    #:check #:result-spans #:run-for-backends)
  (:import-from #:ooparts/regexp
    #:compile-regexp #:compile-regexp-string #:match-regexp #:search-regexp
    #:regexp-p #:regexp-backend #:regexp-group-count
    #:regexp-error #:regexp-error-code)
  (:export #:run-tests #:run-text-tests))
(in-package #:ooparts-tests/regexp/text)

(defun run-text-case (pattern input expected
                      &key (mode :search) flags execution description)
  "Compile PATTERN with COMPILE-REGEXP-STRING for both backends."
  (run-for-backends
   (lambda (backend)
     (let* ((regexp (apply #'compile-regexp-string pattern
                           :backend backend flags))
            (match (ecase mode
                     (:match (apply #'match-regexp regexp input execution))
                     (:search (apply #'search-regexp regexp input execution))))
            (actual (result-spans match (regexp-group-count regexp))))
       (check (and (regexp-p regexp)
                   (eq backend (regexp-backend regexp)))
              (format nil "text ~S: backend ~A" pattern backend))
       (check (equal expected actual)
              (or description
                  (format nil "text ~S on ~S (~A): expected ~S, got ~S"
                          pattern input backend expected actual)))))))

(defun text-error-code (pattern)
  (handler-case
      (progn (compile-regexp-string pattern) :none)
    (regexp-error (condition) (regexp-error-code condition))
    (type-error () :type-error)))

(defun run-posix-text-tests ()
  (run-text-case "a|aa" "aa" '((0 2)))
  (run-text-case "(wee|week)(knights|night)" "xxweeknightsyy"
                 '((2 12) (2 5) (5 12)))
  (run-text-case "(a|aa)(a?)" "aa" '((0 2) (0 2) (2 2)))
  (run-text-case "(a|aa)*" "aa" '((0 2) (0 2)))
  (run-text-case "(a|aa)*" "aaa" '((0 3) (2 3)))
  (run-text-case "(a(b)?)*" "aba" '((0 3) (2 3) (nil nil)))
  (run-text-case "(a*)*" "a" '((0 1) (0 1)))
  (run-text-case "(a*)*" "b" '((0 0) (0 0)))
  (run-text-case "(a*){2}" "a" '((0 1) (1 1)))
  (run-text-case ".*?c" "abc abc" '((0 3)))
  (run-text-case "(.*?).*" "abcdef" '((0 6) (0 0)))
  (run-text-case "(a*?)b" "aaab" '((0 4) (0 3)))
  (run-text-case ".*?c|.*d" "abc abcd" '((0 8)))
  (run-text-case ".*c" "abc abc" '((0 3)) :flags '(:minimal t))
  (run-text-case ".*?c" "abc abc" '((0 7)) :flags '(:minimal t))
  (run-text-case "((a*)a*b)+?.*" "aabaaab" '((0 7) (0 3) (0 2))))

(defun run-syntax-text-tests ()
  (run-text-case "a{2}" "aa" '((0 2)))
  (run-text-case "a{2,}" "aaaa" '((0 4)))
  (run-text-case "a{1,3}" "aaab" '((0 3)))
  (run-text-case "a{0}" "b" '((0 0)))
  (run-text-case "a{0,1}b" "b" '((0 1)))
  (run-text-case "a{2}b" "aab" '((0 3)))
  (run-text-case "(ab){2}" "abab" '((0 4) (2 4)))
  (run-text-case "a{2,3}?" "aaaa" '((0 2)))
  (run-text-case "a*?" "aaa" '((0 0)))
  ;; Empty branches and empty pattern.
  (run-text-case "a|" "b" '((0 0)))
  (run-text-case "|a" "b" '((0 0)))
  (run-text-case "a||b" "a" '((0 1)))
  (run-text-case "" "" '((0 0)))
  ;; Bracket expressions.
  (run-text-case "[[:digit:]]+" "ab123" '((2 5)))
  (run-text-case "[^a-c]+" "abxyz" '((2 5)))
  (run-text-case "[[:alpha:][:digit:]]+" "!ab12" '((1 5)))
  (run-text-case "[[:space:]]" (string (code-char 9)) '((0 1)))
  (run-text-case "[[:blank:]]" (string (code-char 9)) '((0 1)))
  (run-text-case "[[:cntrl:]]" (string (code-char 127)) '((0 1)))
  (run-text-case "[[:punct:]]" "!" '((0 1)))
  (run-text-case "[]]" "]" '((0 1)))
  (run-text-case "[^]]" "]" nil)
  (run-text-case "[-a]" "-" '((0 1)))
  (run-text-case "[a-]" "-" '((0 1)))
  (run-text-case "[a-b-c]" "c" '((0 1)))
  (run-text-case "[[.x.]]" "x" '((0 1)))
  (run-text-case "[[=x=]]" "x" '((0 1)))
  (run-text-case "[[:alpha:]]" (string (code-char 200)) nil)
  (run-text-case "[^[:alpha:]]" (string (code-char 200)) '((0 1)))
  ;; Escapes and literal metacharacters.
  (run-text-case "\\*" "*" '((0 1)))
  (run-text-case "a\\|b" "a|b" '((0 3)))
  (run-text-case "\\^" "^" '((0 1)))
  (run-text-case "\\\\" "\\" '((0 1)))
  (run-text-case "\\n" "n" '((0 1)))
  (run-text-case "a{x}" "a{x}" '((0 4)))
  (run-text-case "{" "{" '((0 1)))
  ;; Anchors, dot, newline.
  (run-text-case "^a$" "a" '((0 1)))
  (run-text-case "^b$" (format nil "a~%b~%c") '((2 3))
                 :flags '(:newline t) :execution '(:not-bol t :not-eol t))
  (run-text-case "." (string #\Newline) '((0 1)))
  (run-text-case "." (string #\Newline) nil :flags '(:newline t))
  (run-text-case (format nil "[~C]" #\Newline) (string #\Newline)
                 '((0 1)) :flags '(:newline t))
  ;; Flags.
  (run-text-case "abc" "ABC" '((0 3)) :flags '(:case-insensitive t))
  (run-text-case "[[:lower:]]" "A" '((0 1)) :flags '(:case-insensitive t))
  (run-text-case "[^a]" "A" nil :flags '(:case-insensitive t))
  ;; Full match versus search.
  (run-text-case "a" "ba" nil :mode :match)
  (run-text-case "a" "ba" '((1 2)) :mode :search))

(defparameter +equivalence-pairs+
  '(("a|aa" (:or "a" "aa"))
    ("(a|aa)(a?)"
     (:seq (:capture (:or "a" "aa"))
           (:capture (:or :epsilon "a"))))
    ("(a*)*" (:repeat 0 nil (:capture (:repeat 0 nil "a"))))
    ("[[:digit:]]+"
     (:repeat 1 nil (:class (:posix :digit))))
    ("[a-c]+" (:repeat 1 nil (:class (:range #\a #\c))))))

(defparameter +equivalence-inputs+
  '("" "a" "aa" "aaa" "12" "a1" "abc"))

(defun run-equivalence-tests ()
  (dolist (pair +equivalence-pairs+)
    (run-for-backends
     (lambda (backend)
       (let* ((text (compile-regexp-string (first pair) :backend backend))
              (form (compile-regexp (second pair) :backend backend)))
         (dolist (input +equivalence-inputs+)
           (let ((left (result-spans (search-regexp text input)
                                     (regexp-group-count text)))
                 (right (result-spans (search-regexp form input)
                                      (regexp-group-count form))))
             (check (equal left right)
                    (format nil "text/form equivalence ~S on ~S (~A)"
                            (first pair) input backend)))))))))

(defun run-error-tests ()
  (let ((cases (list (list "*" :badpat)
                     (list "a**" :badpat)
                     (list "(" :badpat)
                     (list "[a" :badpat)
                     (list "[]" :badpat)
                     (list "\\" :badpat)
                     (list (string (code-char 0)) :badpat)
                     (list (string (code-char 256)) :badpat)
                     (list "a{3,2}" :badbr)
                     (list "a{256}" :badbr)
                     (list "[[:bogus:]]" :ectype)
                     (list "[z-a]" :erange)
                     (list "[[.xy.]]" :ecollate)
                     (list 42 :type-error))))
    (check (eq :type-error
             (handler-case
                 (progn (compile-regexp-string "a" :backend :not-a-backend) :none)
               (type-error () :type-error)))
         "text constructor rejects an unknown backend")
    (dolist (case cases)
      (let ((actual (text-error-code (first case))))
        (check (eq (second case) actual)
               (format nil "text error code for ~S: expected ~S, got ~S"
                       (first case) (second case) actual))))))

(defun run-tests ()
  (run-posix-text-tests)
  (run-syntax-text-tests)
  (run-equivalence-tests)
  (run-error-tests)
  t)

(defun run-text-tests ()
  (run-tests))
