(uiop:define-package #:ooparts/prolog/text/cli
  (:import-from #:ooparts/prolog/script)
  (:use #:cl)
  (:import-from #:ooparts/prolog/kernel/engine
    #:*database* #:close-query #:next-solution)
  (:import-from #:ooparts/prolog/kernel/model
    #:make-database #:disjunction-goal-p)
  (:import-from #:ooparts/prolog/kernel/runtime #:iso-goal)
  (:import-from #:ooparts/prolog/syntax/compiler #:make-query #:query #:variable-symbol-p)
  (:import-from #:ooparts/prolog/api/interface #:interactive-query #:query-more-p)
  (:import-from #:ooparts/prolog/text/loader #:load-prolog-file)
  (:import-from #:ooparts/prolog/text/reader #:read-prolog-term)
  (:import-from #:ooparts/prolog/text/writer #:write-prolog-term)
  (:export #:main))
(in-package #:ooparts/prolog/text/cli)

;;; Command line interface, launched by tools/prolog/cli.lisp or the root flake.
;;; MAIN dispatches to the script runner or the REPL.

(defparameter *usage* "usage: ooparts-prolog [--lisp | --iso] [file]

  --lisp  S-expression Prolog (native term model; default)
  --iso   strict ISO term model with Prolog text syntax
  file    run a script: Lisp forms in --lisp mode, Prolog text in --iso mode
  no file start an interactive REPL (type an end of file to exit)")

(defun named-form-p (term name arity)
  ;; Same shape test the loader applies to source directives.
  (and (consp term) (symbolp (car term)) (= (length (cdr term)) arity)
       (string-equal (symbol-name (car term)) name)))

(defun source-goal (term)
  ;; Loader-local normalisation, duplicated to keep loader exports closed.
  (if (or (variable-symbol-p term) (disjunction-goal-p term)) term (iso-goal term)))

(defun comma-items (term)
  (let ((work (list term)) (items nil))
    (loop while work do
      (let ((item (pop work)))
        (if (named-form-p item "," 2)
            (progn (push (third item) work) (push (second item) work))
            (push item items))))
    (nreverse items)))

;;; --iso answer presentation: Prolog text via write-prolog-term, one
;;; binding per line, ;/Enter enumeration like interactive-query.

(defun binding-name (symbol)
  (subseq (symbol-name symbol) 1))

(defun iso-display-answer (solution truth delays stream)
  (let ((*print-pretty* nil))
    (fresh-line stream)
    (if (null solution)
        (write-string "true." stream)
        (dolist (binding solution)
          (write-string (binding-name (car binding)) stream)
          (write-string " = " stream)
          (write-prolog-term stream (cdr binding) *database* :quoted t)
          (terpri stream)))
    (when (eq truth :undefined)
      (format stream "undefined; delayed negation: ~S~%" delays))
    (finish-output stream)))

(defun isolate-goals (term)
  (mapcar #'source-goal (comma-items term)))

(defun iso-interactive-query (goals)
  "interactive-query with ISO text output through *QUERY-IO*."
  (let ((vm (make-query goals)))
    (unwind-protect
         (loop
           (multiple-value-bind (solution foundp truth delays) (next-solution vm)
             (unless foundp
               (format *query-io* "~&false.~%") (finish-output *query-io*)
               (return))
             (iso-display-answer solution truth delays *query-io*)
             (unless (query-more-p *query-io*) (return))))
      (close-query vm)))
  (values))

;;; --lisp mode: scripts and the REPL both read ordinary Lisp forms in a
;;; scratch package that uses CL and the public facade, then evaluate them.

(defvar *script-package* nil)

(defun script-package ()
  (or *script-package*
      (setf *script-package*
            (find-package :ooparts/prolog/script))))

(defun eval-lisp-stream (stream)
  (let ((*package* (script-package)))
    (loop for form = (read stream nil :eof)
          until (eq form :eof) do (eval form)))
  (values))

(defun lisp-repl ()
  (format *query-io* "~&OOPArts Prolog REPL (--lisp); end of file to exit.~%")
  (let ((*package* (script-package)))
    (loop
      (format *query-io* "~&?- ") (finish-output *query-io*)
      (handler-case
          (let ((form (read *query-io* nil :eof)))
            (when (eq form :eof) (fresh-line *query-io*) (return))
            (eval form))
        (error (condition) (format *query-io* "ERROR: ~A~%" condition)))
      (finish-output *query-io*)))
  (values))

;;; --iso mode: strict term model, Prolog text for both file and REPL.

(defun iso-read-repl-term ()
  (format *query-io* "~&?- ") (finish-output *query-io*)
  (read-prolog-term *query-io* :database *database* :package *package* :source "<repl>"))

(defun iso-repl ()
  (format *query-io* "~&OOPArts Prolog REPL (--iso); end of file to exit.~%")
  (loop
    ;; Reader failures (syntax_error) return to the prompt like goal errors.
    (handler-case
        (multiple-value-bind (term present marks) (iso-read-repl-term)
          (declare (ignore marks))
          (unless present (fresh-line *query-io*) (return))
          (cond ((or (named-form-p term "?-" 1) (named-form-p term ":-" 1))
                 (iso-interactive-query (isolate-goals (second term))))
                ((or (named-form-p term ":-" 2) (named-form-p term "-->" 2))
                 ;; Rules typed at the prompt are asserted through assertz/1.
                 (unless (query (list (source-goal (list 'assertz term))) :limit 1)
                   (format *query-io* "ERROR: assertion failed.~%")))
                (t (iso-interactive-query (isolate-goals term)))))
      (error (condition) (format *query-io* "ERROR: ~A~%" condition)))
    (finish-output *query-io*))
  (values))

(defun configure-iso (database)
  (setf *database* database)
  (query '((set_prolog_flag read_syntax prolog)))
  (query '((set_prolog_flag write_syntax prolog))))

(defun parse-arguments (arguments)
  "Return (values mode file); quit with status on -h/--help or a usage error."
  (let ((mode nil) (file nil))
    (dolist (argument arguments)
      (cond ((member argument '("--lisp" "--iso") :test #'string=)
             (let ((requested (intern (string-upcase (string-left-trim "-" argument)) :keyword)))
               (when (and mode (not (eq mode requested)))
                 (format *error-output* "~&ooparts-prolog: --lisp and --iso are exclusive~%~A" *usage*)
                 (uiop:quit 2))
               (setf mode requested)))
            ((member argument '("-h" "--help") :test #'string=)
             (write-string *usage*) (uiop:quit 0))
            ((and (plusp (length argument)) (char= (char argument 0) #\-))
             (format *error-output* "~&ooparts-prolog: unknown option ~A~%~A" argument *usage*)
             (uiop:quit 2))
            (file
             (format *error-output* "~&ooparts-prolog: at most one file~%~A" *usage*)
             (uiop:quit 2))
            (t (setf file argument))))
    (values (or mode :lisp) file)))

(defun run-file (mode file database)
  (setf *database* database)
  (if (eq mode :iso)
      (progn (configure-iso database)
             (load-prolog-file file :database database))
      (with-open-file (stream file) (eval-lisp-stream stream))))

(defun main ()
  (let ((*database* nil))
    (handler-case
        (multiple-value-bind (mode file) (parse-arguments (uiop:command-line-arguments))
          (let ((database (if (eq mode :iso)
                              (make-database :term-model :iso)
                              (make-database))))
            (if file
                (run-file mode file database)
                (progn (when (eq mode :iso) (configure-iso database))
                       (setf *database* database)
                       (funcall (if (eq mode :iso) #'iso-repl #'lisp-repl))))))
      (error (condition)
        (format *error-output* "~&ooparts-prolog: ~A~%" condition)
        (uiop:quit 1))))
  (uiop:quit 0))
