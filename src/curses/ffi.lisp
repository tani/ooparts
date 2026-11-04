;;; Minimal host FFI adapter. No foreign portability library is loaded.
(uiop:define-package #:ooparts/curses/ffi
  (:use #:cl)
  (:export #:native-call #:allocate #:deallocate #:octet #:with-memory))
(in-package #:ooparts/curses/ffi)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun host-type (type)
    #+sbcl (ecase type (:int 'sb-alien:int) (:uint 'sb-alien:unsigned-int)
                     (:ulong 'sb-alien:unsigned-long) (:pointer 'sb-alien:system-area-pointer)
                     (:void 'sb-alien:void))
    #+cmucl (ecase type (:int 'c-call:int) (:uint 'c-call:unsigned-int)
                      (:ulong 'c-call:unsigned-long) (:pointer 'system:system-area-pointer)
                      (:void '(values)))
    #+ccl (ecase type (:int :signed-fullword) (:uint :unsigned-fullword)
                    (:ulong :unsigned-long)
                    (:pointer :address) (:void :void))
    #+(or ecl mkcl) (ecase type (:int :int) (:uint :unsigned-int)
                               (:ulong :unsigned-long) (:pointer :pointer-void) (:void :void))
    #+clisp (ecase type (:int 'ffi:int) (:uint 'ffi:uint)
                       (:ulong 'ffi:ulong) (:pointer 'ffi:c-pointer) (:void nil))
    #+clasp (ecase type (:int :int) (:uint :unsigned-int)
                       (:ulong :unsigned-long) (:pointer :pointer) (:void :void))
    #+abcl type))

(defmacro native-call (name result &rest arguments)
  "Call a fixed OS interface; ARGUMENTS alternate type keywords and values."
  (let ((types (loop for tail on arguments by #'cddr collect (host-type (first tail))))
        (values (loop for tail on arguments by #'cddr collect (second tail))))
    #+sbcl `(sb-alien:alien-funcall
             (sb-alien:extern-alien ,name (function ,(host-type result)
               ,@(if (and (string= name "ioctl") #+(and darwin arm64) t #-(and darwin arm64) nil)
                     (append (subseq types 0 2) (list '&optional) (nthcdr 2 types)) types))) ,@values)
    #+cmucl `(alien:alien-funcall
              (alien:extern-alien ,name (function ,(host-type result) ,@types)) ,@values)
    #+ccl `(ccl:external-call ,name ,@(loop for type in types for value in values for index from 0
                                          append (append
                                                  (when (and (string= name "ioctl") (= index 2)
                                                             #+(and darwin-target arm64-target) t
                                                             #-(and darwin-target arm64-target) nil)
                                                    (list :variadic)) (list type value))) ,(host-type result))
    #+(or ecl mkcl)
    (if (and (string= name "ioctl") (uiop:os-macosx-p))
        `(progn (ffi:clines "#include <sys/ioctl.h>")
                (ffi:c-inline ,values ,types :int "ioctl(#0,#1,#2)" :one-liner t :side-effects t))
        `(si:call-cfun (si:find-foreign-symbol ,name :default :pointer-void 0)
                      ,(host-type result) ',types (list ,@values)))
    #+clisp
    `(funcall (load-time-value
               (ffi::find-foreign-function
                ,name (ffi:parse-c-type
                       '(ffi:c-function
                         (:arguments ,@(loop for type in types for i from 0
                                            collect (list (intern (format nil "ARG~D" i)) type)))
                         (:return-type ,(host-type result))
                         (:language :stdc))) nil :default nil nil)) ,@values)
    #+clasp
    (if (and (string= name "ioctl") (uiop:os-macosx-p))
        (let ((operator (find-symbol "%FOREIGN-FUNCALL-VARARGS" :clasp-ffi)))
          (unless (and operator (macro-function operator))
            (error "Clasp on macOS requires native variadic FFI support."))
          `(,operator ,name 2 :int ,(first values) :unsigned-long ,(second values)
                      :pointer ,(third values) :int))
        `(clasp-ffi:%foreign-funcall ,name
           ,@(loop for type in types for value in values append (list type value))
           ,(host-type result)))
    #+abcl `(incubator-call ,name ,result ',types (list ,@values))))

#+abcl
(progn
  (defvar *linker* nil)
  (defvar *scopes* (make-hash-table :test #'eq))
  (defvar *lookup* nil)
  (defvar *calls* (make-hash-table :test #'equal))
  (defun ensure-incubator ()
    (unless *linker*
      (handler-case
          (setf *linker* (java:jstatic "getInstance" "jdk.incubator.foreign.CLinker")
                *lookup* (java:jstatic "systemLookup" "jdk.incubator.foreign.CLinker"))
        (error (condition)
          (error "ABCL native terminals require JDK 17 with --add-modules=jdk.incubator.foreign and --enable-native-access=ALL-UNNAMED: ~A" condition)))))
  (defun layout (type)
    (java:jfield "jdk.incubator.foreign.CLinker"
                 (ecase type (:int "C_INT") (:uint "C_INT")
                        (:ulong "C_LONG") (:pointer "C_POINTER"))))
  (defun carrier (type)
    (if (eq type :pointer) (java:jclass "jdk.incubator.foreign.MemoryAddress")
        (java:jfield (ecase type (:int "java.lang.Integer") (:uint "java.lang.Integer")
                               (:ulong "java.lang.Long") (:void "java.lang.Void")) "TYPE")))
  (defun incubator-call (name result types arguments)
    (ensure-incubator)
    (let* ((key (list name result types))
           (handle
             (or (gethash key *calls*)
                 (setf (gethash key *calls*)
                       (let* ((args
                                (java:jnew-array-from-list
                                 "jdk.incubator.foreign.MemoryLayout"
                                 (loop for type in types for index from 0
                                       for layout = (layout type)
                                       collect (if (and (string= name "ioctl") (>= index 2))
                                                   (java:jstatic "asVarArg" "jdk.incubator.foreign.CLinker" layout)
                                                   layout))))
                              (descriptor
                                ;; Avoid ABCL 1.9.0's single-array static-varargs conversion.
                                (if (eq result :void)
                                    (java:jcall "withVoidReturnLayout"
                                                (java:jstatic "of" "jdk.incubator.foreign.FunctionDescriptor" (layout :int) args))
                                    (java:jstatic "of" "jdk.incubator.foreign.FunctionDescriptor" (layout result) args)))
                              (signature
                                (java:jstatic "methodType" "java.lang.invoke.MethodType"
                                              (carrier result)
                                              (java:jnew-array-from-list "java.lang.Class" (mapcar #'carrier types))))
                              (symbol (java:jcall "orElseThrow" (java:jcall "lookup" *lookup* name))))
                         (java:jcall
                          (java:jmethod "jdk.incubator.foreign.CLinker" "downcallHandle"
                                        "jdk.incubator.foreign.Addressable" "java.lang.invoke.MethodType"
                                        "jdk.incubator.foreign.FunctionDescriptor")
                          *linker* symbol signature descriptor)))))
           (args (java:jnew-array-from-list
                  "java.lang.Object"
                  (loop for type in types for value in arguments collect
                    (ecase type
                      ((:int :uint) (java:jnew "java.lang.Integer"
                                               (if (> value #x7fffffff) (- value #x100000000) value)))
                      (:ulong (java:jnew "java.lang.Long" value))
                      (:pointer (java:jcall (java:jmethod "jdk.incubator.foreign.MemorySegment" "address") value)))))))
      (java:jcall "invokeWithArguments" handle args))))

(defun allocate (size)
  #+sbcl (sb-sys:allocate-system-memory size)
  #+cmucl (system:allocate-system-memory size)
  #+ccl (native-call "malloc" :pointer :ulong size)
  #+(or ecl mkcl) (si:allocate-foreign-data :void size)
  #+clisp (ffi:foreign-address (ffi:allocate-shallow 'ffi:uint8 :count size))
  #+clasp (clasp-ffi:%foreign-alloc size)
  #+abcl (progn (ensure-incubator)
                (let* ((scope (java:jstatic "newConfinedScope" "jdk.incubator.foreign.ResourceScope"))
                       (pointer (java:jstatic "allocateNative" "jdk.incubator.foreign.MemorySegment"
                                              (java:jnew "java.lang.Long" size) scope)))
                  (setf (gethash pointer *scopes*) scope) pointer)))

(defun deallocate (pointer size)
  (declare (ignorable pointer size))
  #+sbcl (sb-sys:deallocate-system-memory pointer size)
  #+cmucl (system:deallocate-system-memory pointer size)
  #+ccl (native-call "free" :void :pointer pointer)
  #+(or ecl mkcl) (si:free-foreign-data pointer)
  #+clisp (ffi:foreign-free pointer)
  #+clasp (clasp-ffi:%foreign-free pointer)
  #+abcl (let ((scope (gethash pointer *scopes*)))
           (when scope
             (java:jcall (java:jmethod "jdk.incubator.foreign.ResourceScope" "close") scope)
             (remhash pointer *scopes*))))

(defun octet (pointer offset)
  #+sbcl (sb-sys:sap-ref-8 pointer offset)
  #+cmucl (system:sap-ref-8 pointer offset)
  #+ccl (ccl:%get-unsigned-byte pointer offset)
  #+ecl (si:foreign-data-ref-elt (si:foreign-data-recast pointer (1+ offset) :void) offset :unsigned-byte)
  #+mkcl (si:foreign-ref-elt (si:foreign-recast pointer (1+ offset) :void) offset :unsigned-byte)
  #+clisp (ffi:memory-as pointer 'ffi:uint8 offset)
  #+clasp (clasp-ffi:%mem-ref pointer :unsigned-char offset)
  #+abcl (logand 255 (java:jstatic "getByteAtOffset" "jdk.incubator.foreign.MemoryAccess"
                                    pointer (java:jnew "java.lang.Long" offset))))

(defun (setf octet) (value pointer offset)
  #+sbcl (setf (sb-sys:sap-ref-8 pointer offset) value)
  #+cmucl (setf (system:sap-ref-8 pointer offset) value)
  #+ccl (setf (ccl:%get-unsigned-byte pointer offset) value)
  #+ecl (si:foreign-data-set-elt (si:foreign-data-recast pointer (1+ offset) :void) offset :unsigned-byte value)
  #+mkcl (si:foreign-set-elt (si:foreign-recast pointer (1+ offset) :void) offset :unsigned-byte value)
  #+clisp (setf (ffi:memory-as pointer 'ffi:uint8 offset) value)
  #+clasp (clasp-ffi:%mem-set pointer :unsigned-char value offset)
  #+abcl (java:jstatic "setByteAtOffset" "jdk.incubator.foreign.MemoryAccess"
                       pointer (java:jnew "java.lang.Long" offset)
                       (java:jstatic-raw "valueOf" "java.lang.Byte"
                                         (format nil "~D" (if (> value 127) (- value 256) value))))
  value)

(defmacro with-memory ((pointer size) &body body)
  (let ((n (gensym "SIZE")))
    `(let* ((,n ,size) (,pointer (allocate ,n)))
       (unwind-protect (progn ,@body) (deallocate ,pointer ,n)))))
