(uiop:define-package #:ooparts/readline/terminal
  (:use #:cl)
  (:import-from #:ooparts/curses/api)
  (:import-from #:ooparts/curses/terminfo)
  (:import-from #:ooparts/curses/terminal
                #:open-terminal #:close-terminal #:set-input-mode #:terminal-size #:write-terminal-text)
  (:import-from #:ooparts/curses/model #:screen-output)
  (:export #:supported-p #:call-with-terminal #:read-key #:columns
           #:capability #:text-out #:paste-mode #:newline-out))
(in-package #:ooparts/readline/terminal)

(defstruct terminal native input output)
(defun supported-p (input output)
  (and (eq input *standard-input*) (eq output *standard-output*)
       (interactive-stream-p input)
       (not (member (uiop:getenv "TERM") '(nil "" "dumb") :test #'equal))
       (handler-case
           (progn
             ;; Output stream predicates are unreliable on some hosts (ECL).
             ;; Probe both standard descriptors through the Curses TTY adapter.
             (dolist (entry (list (cons input 0) (cons output 1)))
               (let ((terminal (open-terminal :stream (car entry) :fd (cdr entry))))
                 (close-terminal terminal)))
             t)
         (error () nil))))
(defun text-out (terminal text) (write-terminal-text text (terminal-output terminal)))
(defun newline-out (terminal) (text-out terminal (format nil "~C~C" #\Return #\Newline)))
(defun columns (terminal)
  (max 4 (or (nth-value 1 (terminal-size (terminal-native terminal))) 80)))
(defun capability (terminal name &rest parameters)
  "Emit Curses' fixed-profile terminfo capability on the inline output stream."
  (let ((text (ooparts/curses/terminfo:tigetstr name)))
    (when (stringp text)
      (ooparts/curses/terminfo:tputs (if parameters (apply #'ooparts/curses/terminfo:tparm text parameters) text)
                            1 (lambda (char) (write-char char (terminal-output terminal)))))))
(defun paste-mode (terminal enabled)
  ;; Keep Curses' full-screen initialization and refresh output off the user's
  ;; normal screen. Only the explicitly requested inline capability is emitted.
  (let* ((screen ooparts/curses/api:*screen*) (saved (screen-output screen)))
    (unwind-protect
         (progn (setf (screen-output screen) (terminal-output terminal))
                (ooparts/curses/api:enable-paste enabled))
      (setf (screen-output screen) saved))))
(defun call-with-terminal (input output function)
  "Use Curses' native TTY lifecycle and key decoder without an alternate screen."
  (let ((native (open-terminal :stream input :fd 0))
        (reader input)
        (ooparts/curses/terminfo:*cur-term* nil))
    (unwind-protect
         (progn
           ;; Clasp's default C stdio stream can hide buffered UTF-8 bytes from
           ;; READ-CHAR-NO-HANG. Its POSIX stream avoids that extra buffering.
           #+clasp (setf reader (open #P"/dev/stdin" :direction :input
                                     :external-format :utf-8 :cstream nil))
           (ooparts/curses/api:with-screen (:native nil :input reader :output (make-broadcast-stream)
                                               :rows 1 :cols 80 :profile :xterm)
             (ooparts/curses/terminfo:setupterm "xterm")
             (ooparts/curses/api:noecho)
             (ooparts/curses/api:keypad ooparts/curses/api:*stdscr* t)
             (ooparts/curses/api:set-escdelay 50)
             (set-input-mode native :raw)
             (let ((terminal (make-terminal :native native :input reader :output output)))
               (unwind-protect
                    (progn (paste-mode terminal t) (funcall function terminal))
                 (paste-mode terminal nil) (newline-out terminal) (finish-output output)))))
      (unwind-protect
           (when (not (eq reader input)) (close reader))
        (close-terminal native)))))
(defun event (terminal delay)
  (ooparts/curses/api:timeout (if delay (ceiling (* delay 1000)) -1))
  (let ((key (ooparts/curses/api:get-wch)))
    (if (eql key ooparts/curses/api:+err+)
        ;; Curses uses ERR for both timeout and stream EOF. Inspect without
        ;; consuming the next character, and preserve any arrival in its queue.
        (let ((next (read-char-no-hang (terminal-input terminal) nil :eof)))
          (cond ((eq next :eof) :eof)
                ((characterp next) (ooparts/curses/api:unget-wch next) (event terminal 0))
                (t nil)))
        key)))
(defun read-key (terminal &optional timeout)
  (let ((key (event terminal timeout)))
    (cond
      ((eql key ooparts/curses/api:+key-paste-begin+)
       (cons :paste (with-output-to-string (stream)
                      (loop for char = (event terminal nil)
                            until (or (eq char :eof) (eql char ooparts/curses/api:+key-paste-end+))
                            when (characterp char) do (write-char char stream)))))
      ((eql key (code-char 27))
       (let ((next (event terminal 0.05)))
         (case next (#\b :backward-word) (#\f :forward-word) (#\d :delete-word)
           ((nil) :escape)
           (otherwise (when (characterp next) (ooparts/curses/api:unget-wch next)) :escape))))
      ((eql key ooparts/curses/api:+key-left+) :left)
      ((eql key ooparts/curses/api:+key-right+) :right)
      ((eql key ooparts/curses/api:+key-up+) :up)
      ((eql key ooparts/curses/api:+key-down+) :down)
      ((eql key ooparts/curses/api:+key-home+) :home)
      ((eql key ooparts/curses/api:+key-end+) :end)
      ((eql key ooparts/curses/api:+key-backspace+) :backspace)
      ((eql key ooparts/curses/api:+key-dc+) :delete)
      ((eql key ooparts/curses/api:+key-enter+) #\Return)
      ((characterp key) key)
      ((eq key :eof) :eof)
      (t nil))))
