(uiop:define-package #:ooparts/sml/parser
  (:use #:cl)
  (:import-from #:ooparts/prolog #:phrase)
  (:import-from #:ooparts/sml/source
    #:source #:make-source #:make-span #:sml-syntax-error)
  (:import-from #:ooparts/sml/lexer #:tokenize #:token-span #:token-text)
  (:import-from #:ooparts/sml/grammar
    #:*grammar-database* #:initial-fixity-environment
    #:fixity-lookup #:infix-identifier-p
    #:sml-program #:sml-expression #:sml-declaration
    #:sml-structure-expression #:sml-signature-expression #:sml-specification)
  (:export
    #:initial-fixity-environment #:fixity-lookup #:infix-identifier-p
    #:parse-program #:parse-expression #:parse-declaration
    #:parse-structure-expression #:parse-signature-expression #:parse-specification))
(in-package #:ooparts/sml/parser)

(defun %source (designator source-name)
  (etypecase designator
    (source designator)
    (string (make-source designator :name source-name))))

(defun %token-list (tokens)
  ;; Native Prolog lists are host CONSes.  The lexer may use a vector for its
  ;; public random-access interface; this is the single conversion at the DCG
  ;; boundary, rather than one fresh suffix per terminal.
  (if (listp tokens) tokens (coerce tokens 'list)))

(defun %failure-token (tokens)
  ;; Failed DCG derivations carry no automatic source positions.  EOF is the
  ;; least misleading fallback for an incomplete construct; grammar semantic
  ;; restrictions may signal more specific errors themselves.
  (cond ((vectorp tokens) (aref tokens (1- (length tokens))))
        ((consp tokens) (car (last tokens)))
        (t nil)))

(defun %parse (entry designator source-name description)
  (let* ((source (%source designator source-name))
         (tokens (tokenize source))
         (input (%token-list tokens)))
    (let ((solutions
            (phrase (list entry '?value) input nil
                    :limit 1 :database *grammar-database*)))
      ;; PHRASE returns NIL for failure and possibly (NIL) for a successful
      ;; ground derivation.  Every public entry binds ?VALUE, so look up the
      ;; binding rather than using NULL as a success test.
      (let ((binding (and solutions (assoc '?value (first solutions)))))
        (if binding
            (cdr binding)
            (let ((token (%failure-token tokens)))
              (error 'sml-syntax-error
                     :span (if token
                               (token-span token)
                               (make-span source 0 0))
                     :message (format nil "Expected ~A~@[, found ~S~]."
                                      description (and token (token-text token))))))))))

(defun parse-program (source &key (source-name "<string>")
                                  (fixity-environment
                                   (initial-fixity-environment))
                                  allow-omitted-final-semicolon)
  "Parse a complete program with explicit immutable input/output fixities.
When ALLOW-OMITTED-FINAL-SEMICOLON is true, use the separate MLton batch-input
DCG: only a complete final topdec or interactive expression may end at EOF.
The default remains the strict SML '97 semicolon-terminated grammar."
  (let* ((source (%source source source-name))
         (tokens (tokenize source))
         (input (%token-list tokens))
         (entry (if allow-omitted-final-semicolon
                    'ooparts/sml/grammar::sml-program-with-omitted-final-semicolon
                    'ooparts/sml/grammar::sml-program-with-fixities))
         (solutions
           (phrase (list entry fixity-environment '?fixities '?value)
                   input nil :limit 1 :database *grammar-database*))
         (answer (first solutions))
         (binding (and answer (assoc '?value answer))))
    (unless binding
      (let ((token (%failure-token tokens)))
        (error 'sml-syntax-error
               :span (if token (token-span token) (make-span source 0 0))
               :message (format nil "Expected an SML program~@[, found ~S~]."
                                (and token (token-text token))))))
    (values (cdr binding) (cdr (assoc '?fixities answer)))))

(defun parse-expression (source &key (source-name "<string>"))
  "Parse one complete SML '97 Core expression."
  (%parse 'sml-expression source source-name "an expression"))

(defun parse-declaration (source &key (source-name "<string>"))
  "Parse one complete SML '97 Core declaration."
  (%parse 'sml-declaration source source-name "a Core declaration"))

(defun parse-structure-expression (source &key (source-name "<string>"))
  "Parse one complete SML '97 structure expression."
  (%parse 'sml-structure-expression source source-name "a structure expression"))

(defun parse-signature-expression (source &key (source-name "<string>"))
  "Parse one complete SML '97 signature expression."
  (%parse 'sml-signature-expression source source-name "a signature expression"))

(defun parse-specification (source &key (source-name "<string>"))
  "Parse one complete SML '97 signature specification."
  (%parse 'sml-specification source source-name "a specification"))
