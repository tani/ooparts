(uiop:define-package #:ooparts/readline
  (:use #:cl)
  (:import-from #:ooparts/readline/editor
                #:make-editor #:editor-text #:editor-cursor #:apply-key #:render-line #:printable)
  (:import-from #:ooparts/readline/terminal
                #:supported-p #:call-with-terminal #:read-key #:columns
                #:capability #:text-out #:newline-out)
  (:import-from #:ooparts/host #:make-recursive-lock #:with-recursive-lock-held)
  (:export #:readline #:terminal-supported-p #:readline-interrupted
           #:make-history #:history-entries #:add-history #:clear-history
           #:read-history #:write-history #:*history*))
(in-package #:ooparts/readline)

(defstruct (history (:constructor %make-history)) (entries nil) (limit 500))
(defun make-history (&key (limit 500))
  (check-type limit (integer 0 *)) (%make-history :limit limit))
(defvar *history* (make-history))
(defvar *terminal-lock* (make-recursive-lock "OOPArts readline"))
(defvar *reading* nil)
(define-condition readline-interrupted (error) ()
  (:report (lambda (condition stream) (declare (ignore condition))
             (write-string "Line input interrupted." stream))))
(defun add-history (line &optional (history *history*))
  "Remember a nonempty line, newest first; suppress adjacent duplicates."
  (check-type line string)
  (let ((line (printable line)))
    (when (and (plusp (length line)) (plusp (history-limit history))
               (not (equal line (first (history-entries history)))))
      (push line (history-entries history))
      (when (> (length (history-entries history)) (history-limit history))
        (setf (cdr (nthcdr (1- (history-limit history)) (history-entries history))) nil))))
  line)
(defun clear-history (&optional (history *history*)) (setf (history-entries history) nil))
(defun read-history (pathname &optional (history *history*))
  "Append history from PATHNAME; ignore missing files."
  (with-open-file (stream pathname :direction :input :if-does-not-exist nil)
    (when stream (loop for line = (read-line stream nil nil) while line do (add-history line history))))
  history)
(defun write-history (pathname &optional (history *history*))
  "Write oldest first, using the host's default external format."
  (with-open-file (stream pathname :direction :output :if-exists :supersede :if-does-not-exist :create)
    (dolist (line (reverse (history-entries history))) (write-line line stream)))
  pathname)
(defun terminal-supported-p (&optional (input *standard-input*) (output *standard-output*))
  (supported-p input output))
(defun finish-eof (input eof-error-p eof-value)
  (if eof-error-p (error 'end-of-file :stream input) eof-value))
(defun redraw (editor prompt terminal)
  (multiple-value-bind (line cursor) (render-line editor prompt (columns terminal))
    (capability terminal "cr") (text-out terminal line) (capability terminal "el")
    (capability terminal "cr")
    (when (plusp cursor) (capability terminal "cuf" cursor))))
(defun edit-line (prompt initial history completion input output eof-error-p eof-value)
  (call-with-terminal
   input output
   (lambda (terminal)
     (let ((editor (make-editor :text (printable initial)
                                :history (and history (copy-list (history-entries history)))
                                :completion completion))
           (last-columns (columns terminal)))
       (setf (editor-cursor editor) (length (editor-text editor)))
       (redraw editor prompt terminal) (finish-output output)
       (loop for key = (read-key terminal 0.1) do
         (cond (key
                (multiple-value-bind (action candidates) (apply-key editor key)
                  (case action
                    (:accept (when history (add-history (editor-text editor) history))
                             (return (editor-text editor)))
                    (:eof (return (finish-eof input eof-error-p eof-value)))
                    (:abort (error 'readline-interrupted))
                    (:clear (capability terminal "clear"))
                    (:candidates
                     (newline-out terminal)
                     (dolist (candidate candidates) (text-out terminal candidate) (text-out terminal "  "))
                     (newline-out terminal))))
                (redraw editor prompt terminal))
               ((/= last-columns (columns terminal))
                (setf last-columns (columns terminal)) (redraw editor prompt terminal)))
         (finish-output output))))))
(defun readline-options (prompt &key
                   (input *standard-input*) (output *standard-output*)
                   (history *history*) completion (initial "") (edit :auto)
                   (eof-error-p nil) eof-value)
  "Read a line using OOPARTS/CURSES for native editing, or ordinary stream input.
EDIT is :AUTO, T (require native editing), or NIL. COMPLETION takes the current
whitespace-delimited prefix and returns candidate strings. HISTORY may be NIL.
Ctrl-C/Ctrl-G signal READLINE-INTERRUPTED, restoring terminal state on exit."
  (check-type prompt string) (check-type initial string)
  (unless (member edit '(nil t :auto)) (error "Invalid EDIT mode: ~S" edit))
  (when *reading* (error "Recursive readline is not supported."))
  (with-recursive-lock-held (*terminal-lock*)
    (let* ((*reading* t) (native (and edit (terminal-supported-p input output))))
      (when (and (eq edit t) (not native))
        (error "Native Curses editing unavailable; check the terminal and host FFI setup."))
      (if native
          (edit-line prompt initial history completion input output eof-error-p eof-value)
          (progn
            (write-string prompt output) (finish-output output)
            (let* ((sentinel (list :eof)) (line (read-line input nil sentinel)))
              (if (eq line sentinel) (finish-eof input eof-error-p eof-value)
                  (progn (when history (add-history line history)) line))))))))

(defun readline (&optional (prompt "") &rest options)
  "Read an inline editable line through OOPARTS/CURSES.
Options: :INPUT, :OUTPUT, :HISTORY, :COMPLETION, :INITIAL, :EDIT,
:EOF-ERROR-P and :EOF-VALUE. EDIT defaults to :AUTO; T requires a TTY.
COMPLETION receives a whitespace-delimited prefix and returns candidates."
  (apply #'readline-options prompt options))
