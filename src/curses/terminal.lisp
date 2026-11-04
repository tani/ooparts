(uiop:define-package #:ooparts/curses/terminal
  (:use #:cl)
  (:import-from #:ooparts/curses/model #:first-codepoint)
  (:import-from #:ooparts/curses/ffi #:native-call #:with-memory #:octet)
  (:export #:terminal-state #:open-terminal #:close-terminal #:set-input-mode
           #:terminal-size #:terminal-stream #:terminal-fd #:terminal-open-p
           #:capture-mode #:restore-mode #:terminal-meta #:terminal-qiflush #:terminal-character
           #:terminal-speed #:terminal-flush #:input-ready-p #:write-terminal-text))
(in-package #:ooparts/curses/terminal)

(defstruct terminal-state stream (fd 0) saved abi (open-p nil))

(defun native-abi ()
  ;; Some hosts (notably CLISP) expose :UNIX without an OS-specific feature.
  (with-memory (pointer 4096)
    (unless (zerop (native-call "uname" :int :pointer pointer))
      (error "Cannot identify the native terminal ABI."))
    (let ((name (coerce (loop for i below 64 for byte = (octet pointer i)
                             until (zerop byte) collect (code-char byte)) 'string)))
      (cond ((string= name "Linux") :linux)
            ((string= name "Darwin") :darwin)
            (t (error "Native terminals currently support Linux and macOS, not ~A." name))))))

(defun terminal-stream (terminal) (terminal-state-stream terminal))
(defun terminal-fd (terminal) (terminal-state-fd terminal))
(defun terminal-open-p (terminal) (terminal-state-open-p terminal))

(defun copy-to-memory (bytes pointer)
  (dotimes (i (length bytes)) (setf (octet pointer i) (aref bytes i))))
(defun copy-from-memory (pointer count)
  (let ((bytes (make-array count :element-type '(unsigned-byte 8))))
    (dotimes (i count bytes) (setf (aref bytes i) (octet pointer i)))))

(defun open-terminal (&key (stream *terminal-io*) (fd 0))
  "Save the native TTY state. STREAM must refer to the TTY identified by FD."
  (let ((abi (native-abi)))
  (with-memory (pointer 256)
    (dotimes (i 256) (setf (octet pointer i) 0))
    (unless (zerop (native-call "tcgetattr" :int :int fd :pointer pointer))
      (error "Cannot read terminal attributes for descriptor ~D; use :native nil for stream tests." fd))
    (make-terminal-state :stream stream :fd fd :saved (copy-from-memory pointer 256) :abi abi :open-p t))))

(defun capture-mode (terminal)
  (with-memory (pointer 256)
    (unless (zerop (native-call "tcgetattr" :int :int (terminal-fd terminal) :pointer pointer))
      (error "Cannot read current terminal attributes."))
    (copy-from-memory pointer 256)))
(defun restore-mode (terminal bytes)
  (with-memory (pointer 256)
    (copy-to-memory bytes pointer)
    (unless (zerop (native-call "tcsetattr" :int :int (terminal-fd terminal) :int 0 :pointer pointer))
      (error "Cannot restore saved terminal mode.")))
  (setf (terminal-state-open-p terminal) t))

(defun close-terminal (terminal)
  "Restore the exact attributes saved at open, including after a mode change."
  (when (terminal-state-open-p terminal)
    (with-memory (pointer 256)
      (copy-to-memory (terminal-state-saved terminal) pointer)
      (unless (zerop (native-call "tcsetattr" :int :int (terminal-fd terminal)
                                            :int 0 :pointer pointer))
        (error "Cannot restore terminal attributes.")))
    (setf (terminal-state-open-p terminal) nil))
  t)

(defun word-at (pointer offset size)
  ;; Supported hosts are little endian; use byte operations rather than alignment assumptions.
  (loop for i below size sum (ash (octet pointer (+ offset i)) (* 8 i))))
(defun (setf word-at) (value pointer offset size)
  (dotimes (i size value)
    (setf (octet pointer (+ offset i)) (ldb (byte 8 (* 8 i)) value))))

(defun set-input-mode (terminal mode)
  "Select :RAW, :CBREAK or :COOKED. Curses implements echo in its input layer."
  (let ((linux (eq (terminal-state-abi terminal) :linux)))
  (with-memory (pointer 256)
    (copy-to-memory (terminal-state-saved terminal) pointer)
    (ecase mode
      (:cooked
       ;; Disable kernel echo: the window layer owns echo, including in cooked mode.
       (setf (word-at pointer (if linux 12 24) (if linux 4 8))
             (logandc2 (word-at pointer (if linux 12 24) (if linux 4 8))
                      #x8)))
      (:raw (native-call "cfmakeraw" :void :pointer pointer))
      (:cbreak
       ;; Preserve signals, flow control and input translations from the saved state.
       (setf (word-at pointer (if linux 12 24) (if linux 4 8))
             (logandc2 (word-at pointer (if linux 12 24) (if linux 4 8))
                      (if linux #xa #x108)))
       (setf (octet pointer (if linux 23 48)) 1
             (octet pointer (if linux 22 49)) 0)))
    (unless (zerop (native-call "tcsetattr" :int :int (terminal-fd terminal) :int 0 :pointer pointer))
      (error "Cannot set terminal mode ~S." mode))))
  (setf (terminal-state-open-p terminal) t)
  t)

(defun terminal-size (terminal)
  "Return rows and columns, or NIL values if the kernel query fails."
  (with-memory (pointer 8)
    (dotimes (i 8) (setf (octet pointer i) 0))
    (when (zerop (native-call "ioctl" :int :int (terminal-fd terminal)
                             :ulong (if (eq (terminal-state-abi terminal) :linux) #x5413 #x40087468) :pointer pointer))
      (let ((rows (word-at pointer 0 2)) (cols (word-at pointer 2 2)))
        (when (and (plusp rows) (plusp cols)) (values rows cols))))))

(defun edit-mode (terminal function)
  (with-memory (pointer 256)
    (copy-to-memory (capture-mode terminal) pointer)
    (funcall function pointer (eq (terminal-state-abi terminal) :linux))
    (unless (zerop (native-call "tcsetattr" :int :int (terminal-fd terminal) :int 0 :pointer pointer))
      (error "Cannot edit terminal attributes."))))
(defun terminal-meta (terminal enabled)
  (edit-mode terminal (lambda (p linux)
                       (let* ((size (if linux 4 8)) (flags (word-at p 0 size)))
                         (setf (word-at p 0 size) (if enabled (logandc2 flags 32) (logior flags 32)))))))
(defun terminal-qiflush (terminal enabled)
  (edit-mode terminal (lambda (p linux)
                       (let* ((offset (if linux 12 24)) (size (if linux 4 8))
                              (mask (if linux 128 #x80000000)) (flags (word-at p offset size)))
                         (setf (word-at p offset size) (if enabled (logandc2 flags mask) (logior flags mask)))))))
(defun terminal-character (terminal kind)
  (with-memory (pointer 256)
    (copy-to-memory (capture-mode terminal) pointer)
    (octet pointer (if (eq (terminal-state-abi terminal) :linux)
                       (ecase kind (:erase 19) (:kill 20)) (ecase kind (:erase 35) (:kill 37))))))
(defun terminal-speed (terminal)
  (with-memory (pointer 256)
    (copy-to-memory (capture-mode terminal) pointer)
    (let ((speed (native-call "cfgetospeed" :uint :pointer pointer)))
      (if (eq (terminal-state-abi terminal) :darwin) speed
          (or (nth speed '(0 50 75 110 134 150 200 300 600 1200 1800 2400 4800 9600 19200 38400))
              (cdr (assoc speed '((4097 . 57600) (4098 . 115200) (4099 . 230400)
                                 (4100 . 460800) (4101 . 500000) (4102 . 576000)
                                 (4103 . 921600) (4104 . 1000000)))) 0)))))
(defun terminal-flush (terminal)
  (zerop (native-call "tcflush" :int :int (terminal-fd terminal) :int 0)))
(defun input-ready-p (fd)
  (with-memory (pointer 8)
    (setf (word-at pointer 0 4) fd (word-at pointer 4 2) 1 (word-at pointer 6 2) 0)
    (and (plusp (native-call "poll" :int :pointer pointer :ulong 1 :int 0))
         (logtest (word-at pointer 6 2) 1))))
(export '(terminal-meta terminal-qiflush terminal-character terminal-speed terminal-flush input-ready-p))

#+cmucl
(defun output-fd (stream)
  (typecase stream
    (synonym-stream (output-fd (symbol-value (synonym-stream-symbol stream))))
    (two-way-stream (output-fd (two-way-stream-output-stream stream)))
    (system:fd-stream (system:fd-stream-fd stream))))
(defun write-terminal-text (text stream)
  "Use scalar UTF-8 on CMUCL, whose CHARACTER cannot represent non-BMP scalars."
  #+cmucl
  (when (and (find-if (lambda (c) (<= #xd800 (char-code c) #xdbff)) text) (output-fd stream))
    (force-output stream)
    (with-memory (pointer 4)
      (loop with i = 0 while (< i (length text)) do
        (let* ((code (first-codepoint (subseq text i)))
               (bytes (cond ((< code 128) (list code))
                            ((< code 2048) (list (logior #xc0 (ash code -6)) (logior #x80 (logand code 63))))
                            ((< code 65536) (list (logior #xe0 (ash code -12)) (logior #x80 (logand (ash code -6) 63)) (logior #x80 (logand code 63))))
                            (t (list (logior #xf0 (ash code -18)) (logior #x80 (logand (ash code -12) 63))
                                     (logior #x80 (logand (ash code -6) 63)) (logior #x80 (logand code 63)))))))
          (loop for byte in bytes for offset from 0 do (setf (octet pointer offset) byte))
          (unless (= (length bytes) (native-call "write" :long :int (output-fd stream) :pointer pointer :ulong (length bytes)))
            (error "Cannot write terminal UTF-8 scalar."))
          (incf i (if (> code 65535) 2 1)))))
    (return-from write-terminal-text text))
  (write-string text stream))
