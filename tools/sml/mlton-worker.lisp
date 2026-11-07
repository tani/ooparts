;;;; One process-isolated MLton regression case.

(require :asdf)
(let* ((*compile-verbose* nil)
       (*load-verbose* nil)
       (root (merge-pathnames "../../"
                              (uiop:pathname-directory-pathname *load-truename*))))
  (asdf:load-asd (merge-pathnames "ooparts.asd" root))
  (asdf:load-system "ooparts/sml/compiler"))

(defun mlton-worker-condition-type (condition)
  (let ((*package* (find-package :keyword)))
    (prin1-to-string (type-of condition))))

(defun mlton-worker-identifier-path (identifier)
  "Return source identifier components without spelling or case conversion."
  (cond
    ;; Current native elaboration signals a list such as ("TextIO" "openIn").
    ;; Accept the public syntax object and an already-dotted spelling as well,
    ;; but do not guess at host symbols or arbitrary condition data.
    ((typep identifier 'ooparts/sml/syntax:identifier)
     (copy-list (ooparts/sml/syntax:identifier-path identifier)))
    ((stringp identifier) (list identifier))
    ((and identifier
          (handler-case (integerp (list-length identifier))
            (type-error () nil))
          (every #'stringp identifier))
     (copy-list identifier))
    (t nil)))

(defun mlton-worker-normalized-identifier (identifier)
  (let ((path (mlton-worker-identifier-path identifier)))
    (when path
      (values (format nil "~{~A~^.~}" path) path))))

(defun mlton-worker-elaboration-message (condition)
  "Recover the exact message beneath the public elaboration report's span suffix."
  (let ((rendered (princ-to-string condition))
        (span (ooparts/sml/source:sml-error-span condition)))
    (if (null span)
        (values rendered t)
        (let* ((source (ooparts/sml/source:source-span-source span))
               (suffix (format nil " at ~S"
                               (ooparts/sml/source:source-name source)))
               (prefix-length (- (length rendered) (length suffix))))
          (if (and (not (minusp prefix-length))
                   (string= suffix rendered :start2 prefix-length))
              (values (subseq rendered 0 prefix-length) t)
              (values nil nil))))))

(defun mlton-worker-unresolved-elaboration-p (condition)
  "Identify only the known no-answer fallback, not arbitrary SML diagnostics."
  (when (typep condition 'ooparts/sml/elaborate:sml-elaboration-error)
    (multiple-value-bind (message known-p)
        (mlton-worker-elaboration-message condition)
      (and known-p
           (member message
                   '("SML elaboration did not produce a well-typed program."
                     "Core elaboration did not produce a well-typed program.")
                   :test #'string=)))))

(defun mlton-worker-message-unbound-name (message prefix)
  "Extract a name from one exact FORMAT template used by the elaborator."
  (let ((prefix-length (length prefix))
        (message-length (length message)))
    (when (and (> message-length (1+ prefix-length))
               (string= prefix message :end2 prefix-length)
               (char= #\. (char message (1- message-length))))
      (subseq message prefix-length (1- message-length)))))

(defun mlton-worker-elaboration-unbound (condition)
  "Return :KNOWN and a name, :UNKNOWN, or NIL for an elaboration condition."
  (multiple-value-bind (message known-p)
      (mlton-worker-elaboration-message condition)
    (cond
      ((not known-p) :unknown)
      (t
       (dolist (prefix '("Unbound value identifier "
                         "Unbound type constructor "
                         "Unbound structure identifier "
                         "Unbound signature identifier "
                         "Unbound functor "))
         (let ((identifier (mlton-worker-message-unbound-name message prefix)))
           (when identifier
             (return-from mlton-worker-elaboration-unbound
               (values :known identifier)))))
       ;; Other diagnostics about unbound entities provide no exact name.  Keep
       ;; them out of generic elaboration passes rather than guessing a name.
       (when (or (search "Unbound" message) (search "unbound" message))
         :unknown)))))

(defun mlton-worker-unbound-failure (condition identifier)
  (multiple-value-bind (name path)
      (mlton-worker-normalized-identifier identifier)
    (mlton-worker-failure
     :missing-prerequisite condition
     :rejection-category :elaboration
     :unbound-identifier name
     :unbound-identifier-path path)))

(defun mlton-worker-rejection-category (condition)
  "Classify only the public source conditions, with explicit range evidence."
  (cond
    ;; SML-ELABORATION-ERROR is a subtype of SML-TYPE-ERROR.  Check its
    ;; deliberate :RANGE kind before the broader static-elaboration case.
    ((and (typep condition 'ooparts/sml/elaborate:sml-elaboration-error)
          (eq :range (ooparts/sml/elaborate:elaboration-error-kind condition)))
     :representation)
    ((typep condition 'ooparts/sml/source:sml-source-error) :syntax)
    ((typep condition 'ooparts/sml/types:sml-type-error) :elaboration)
    (t nil)))

(defun mlton-worker-rejection-failure (condition)
  (append
   (mlton-worker-failure :source-rejected condition
                         :rejection-category
                         (mlton-worker-rejection-category condition))
   (when (typep condition 'ooparts/sml/elaborate:sml-elaboration-error)
     (list :elaboration-kind
           (ooparts/sml/elaborate:elaboration-error-kind condition)))))

(defun mlton-worker-failure (status condition &rest details)
  (list* :status status
         :condition-type (mlton-worker-condition-type condition)
         :message (princ-to-string condition)
         details))

(defun mlton-worker-response (terminal request input frontend host-compilation execution)
  (list :response-version 1
        :case (getf request :case)
        :terminal terminal
        :rejection (getf request :rejection)
        :expected-unbound-identifiers (getf request :expected-unbound-identifiers)
        :input input
        :parse/elaboration frontend
        :host-compilation host-compilation
        :execution execution))

(defun mlton-worker-read-request (path)
  (with-open-file (stream path :direction :input :external-format :utf-8)
    (let ((*read-eval* nil)
          (eof (make-symbol "EOF")))
      (let ((request (read stream nil eof)))
        (when (eq request eof)
          (error "The MLton worker request is empty."))
        (unless (eq (read stream nil eof) eof)
          (error "The MLton worker request contains more than one form."))
        (unless (and (listp request)
                     (eql (getf request :request-version) 1))
          (error "Unsupported MLton worker request: ~S" request))
        request))))

(defun mlton-worker-write-response (path response)
  (with-open-file (stream path
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create
                          :element-type 'character
                          :external-format :utf-8)
    (write response :stream stream :readably t :circle t :pretty nil)
    (terpri stream)
    (finish-output stream)))

(defun mlton-worker-read-source (path)
  ;; Corpus bytes are source characters one-for-one, including bytes which are
  ;; not valid UTF-8.  In particular, do not use a character input stream here.
  (with-open-file (stream path
                          :direction :input
                          :element-type '(unsigned-byte 8))
    (let* ((length (file-length stream))
           (source (make-string length)))
      (dotimes (index length source)
        (setf (char source index)
              (code-char (read-byte stream)))))))

(defun mlton-worker-host-compile (program)
  (let* ((code (ooparts/sml/compiler:compiled-code program))
         (expanded (macroexpand-1 code)))
    ;; LAMBDA/C expands to (FUNCTION (LAMBDA ...)); only the lambda expression
    ;; is passed to the host compiler, as in the public RUN-PROGRAM contract.
    (unless (and (consp expanded)
                 (eq (car expanded) 'function)
                 (consp (second expanded))
                 (eq (car (second expanded)) 'lambda))
      (error "Invalid generated Curry function: ~S" code))
    (multiple-value-bind (function warnings-p failure-p)
        (compile nil (second expanded))
      (declare (ignore warnings-p))
      (when (or failure-p (null function))
        (error "Host compilation failed for the generated Curry function."))
      function)))

(defun mlton-worker-execute (request program basis host-function)
  ;; Both runtime streams designate the same Latin-1 file stream.  The output
  ;; file is finished and closed before the response is returned to the writer.
  (handler-case
      (with-open-file (stream (getf request :output)
                              :direction :output
                              :if-exists :supersede
                              :if-does-not-exist :create
                              :element-type 'character
                              :external-format :latin-1)
        (let ((*standard-output* stream)
              (*error-output* stream))
          (unwind-protect
               (handler-case
                   (multiple-value-bind (value additions)
                       (funcall host-function
                                (ooparts/sml/basis:basis-dynamic basis))
                     (declare (ignore value))
                     ;; A persistent commit is observable only after generated
                     ;; execution returns normally.  This worker needs neither
                     ;; the returned SML value nor the committed basis itself.
                     (ooparts/sml/basis:extend-basis
                      basis
                      (ooparts/sml/compiler:compiled-static program)
                      additions
                      :module-context
                      (ooparts/sml/compiler:compiled-module-context program)
                      :fixities
                      (ooparts/sml/compiler:compiled-fixities program))
                     (values :executed '(:status :completed)))
                 (ooparts/sml/runtime:sml-raise (condition)
                   (format stream "unhandled exception: ~A~%"
                           (ooparts/sml/runtime:render-value
                            (ooparts/sml/runtime:sml-raise-value condition)))
                   (values :sml-nonzero
                           (mlton-worker-failure
                            :nonzero condition
                            :termination :uncaught-sml-exception)))
                 (error (condition)
                   (values :execution-error
                           (mlton-worker-failure :execution-error condition))))
            (finish-output stream))))
    (error (condition)
      (values :execution-error
              (mlton-worker-failure :execution-error condition)))))

(defun mlton-worker-run-case (request)
  (let ((input '(:status :not-attempted))
        (frontend '(:status :not-attempted))
        (host-compilation '(:status :not-attempted))
        (execution '(:status :not-attempted)))
    (labels ((respond (terminal)
               (mlton-worker-response terminal request input frontend
                                      host-compilation execution)))
      (let ((source
              (handler-case
                  (progn
                    (uiop:chdir (getf request :working-directory))
                    (mlton-worker-read-source (getf request :source)))
                (error (condition)
                  (setf input (mlton-worker-failure :input-error condition))
                  (return-from mlton-worker-run-case (respond :input-error))))))
        (setf input (list :status :completed :bytes (length source)))
        (multiple-value-bind (basis program)
            (handler-case
                (let ((basis (ooparts/sml/compiler:make-initial-basis)))
                  (values basis
                          (ooparts/sml/compiler:compile-source
                           source
                           :source-name (getf request :case)
                           :basis basis
                           :allow-omitted-final-semicolon
                           (getf request :allow-omitted-final-semicolon))))
              (ooparts/sml/types:unbound-identifier-error (condition)
                (setf frontend
                      (mlton-worker-unbound-failure
                       condition
                       (ooparts/sml/types:unbound-identifier-error-identifier condition)))
                (return-from mlton-worker-run-case
                  (respond :missing-prerequisite)))
              (ooparts/sml/elaborate:sml-elaboration-error (condition)
                (when (mlton-worker-unresolved-elaboration-p condition)
                  (setf frontend
                        (mlton-worker-failure
                         :compiler-error condition
                         :rejection-category nil
                         :failure-kind :unresolved-elaboration))
                  (return-from mlton-worker-run-case (respond :compiler-error)))
                (multiple-value-bind (unbound identifier)
                    (mlton-worker-elaboration-unbound condition)
                  (case unbound
                    (:known
                     (setf frontend (mlton-worker-unbound-failure condition identifier))
                     (return-from mlton-worker-run-case
                       (respond :missing-prerequisite)))
                    (:unknown
                     (setf frontend
                           (mlton-worker-failure
                            :unknown-prerequisite condition
                            :rejection-category nil
                            :failure-kind :unresolved-unbound-diagnostic))
                     (return-from mlton-worker-run-case
                       (respond :unknown-prerequisite)))
                    (otherwise
                     (setf frontend (mlton-worker-rejection-failure condition))
                     (return-from mlton-worker-run-case
                       (respond :source-rejected))))))
              (ooparts/sml/source:sml-source-error (condition)
                (setf frontend (mlton-worker-rejection-failure condition))
                (return-from mlton-worker-run-case (respond :source-rejected)))
              (ooparts/sml/types:sml-type-error (condition)
                (setf frontend (mlton-worker-rejection-failure condition))
                (return-from mlton-worker-run-case (respond :source-rejected)))
              (error (condition)
                (setf frontend (mlton-worker-failure :compiler-error condition))
                (return-from mlton-worker-run-case (respond :compiler-error))))
          (setf frontend '(:status :completed))
          (when (eq (getf request :suite) :fail)
            (return-from mlton-worker-run-case (respond :accepted)))
          (let ((host-function
                  (handler-case
                      (mlton-worker-host-compile program)
                    (error (condition)
                      (setf host-compilation
                            (mlton-worker-failure :host-compilation-error condition))
                      (return-from mlton-worker-run-case
                        (respond :host-compilation-error))))))
            (setf host-compilation '(:status :completed))
            (when (getf request :nonterm)
              (return-from mlton-worker-run-case (respond :compiled)))
            (multiple-value-bind (terminal phase)
                (mlton-worker-execute request program basis host-function)
              (setf execution phase)
              (return-from mlton-worker-run-case (respond terminal)))))))))

(defun mlton-worker-main (arguments)
  (unless (= (length arguments) 2)
    (format *error-output*
            "Usage: sbcl --script tools/sml/mlton-worker.lisp REQUEST RESPONSE~%")
    (finish-output *error-output*)
    (uiop:quit 2))
  (destructuring-bind (request-path response-path) arguments
    ;; Errors outside the per-case protocol (including request reading and
    ;; response writing) deliberately produce a nonzero worker exit.
    (handler-case
        (mlton-worker-write-response
         response-path
         (mlton-worker-run-case (mlton-worker-read-request request-path)))
      (error (condition)
        (format *error-output* "MLton worker failure: ~A~%" condition)
        (finish-output *error-output*)
        (uiop:quit 1)))))

(mlton-worker-main (uiop:command-line-arguments))
