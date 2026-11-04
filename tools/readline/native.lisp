(require :asdf)
(asdf:load-asd (truename "ooparts.asd"))
(asdf:load-system "ooparts/readline")
#+cmucl
(setf (lisp:stream-external-format system:*stdin*) :utf-8
      (lisp:stream-external-format system:*stdout*) :utf-8)
(unless (ooparts/curses/ffi:native-available-p)
  (format t "~&READLINE-NATIVE-UNAVAILABLE~%") (uiop:quit 77))
(defun checkpoint ()
  ;; Read the harness acknowledgement directly: some host REPL streams suppress
  ;; empty cooked lines. This is test synchronization, not the editor backend.
  (ooparts/curses/ffi:with-memory (pointer 1)
    (assert (= 1 (ooparts/curses/ffi:native-call "read" :long :int 0 :pointer pointer :ulong 1)))))
(format t "~&READLINE-STREAMS ~S ~S~%" (interactive-stream-p *standard-input*) (interactive-stream-p *standard-output*))
(format t "~&READLINE-BASELINE~%") (finish-output)
(checkpoint)
(let ((history (ooparts/readline:make-history)))
  (dotimes (i 10)
    (format t "~&CASE-~D~%" i) (finish-output)
    (let ((screen ooparts/curses/api:*screen*) (stdscr ooparts/curses/api:*stdscr*)
          (term ooparts/curses/terminfo:*cur-term*))
      (handler-case
          (let ((line (ooparts/readline:readline
                       "> " :edit t :history history :eof-value :eof
                       :completion (lambda (prefix)
                                     (when (= i 8) (error "Completion test failure"))
                                     (remove-if-not (lambda (s) (and (<= (length prefix) (length s))
                                                                     (string= prefix s :end2 (length prefix))))
                                                    '("hello" "help"))))))
            (format t "~&RESULT-~D:~S~%" i line))
        (ooparts/readline:readline-interrupted () (format t "~&INTERRUPTED-~D~%" i))
        (error (e) (if (and (= i 8) (search "Completion test failure" (princ-to-string e)))
                       (format t "~&CALLBACK-ERROR~%") (error e))))
      (assert (eq screen ooparts/curses/api:*screen*))
      (assert (eq stdscr ooparts/curses/api:*stdscr*))
      (assert (eq term ooparts/curses/terminfo:*cur-term*)))
    (format t "~&RESTORED-~D~%" i) (finish-output)
    (checkpoint)))
(format t "~&READLINE-PTY-COMPLETE~%") (finish-output)
