(uiop:define-package #:ooparts/advice/compilation
  (:use #:cl)
  (:import-from #:ooparts/advice/core #:resolve-function #:reconcile-definitions #:*prepare-function*)
  (:import-from #:ooparts/advice/backend #:*changing-definition*)
  (:export #:enable-advice-compilation #:disable-advice-compilation #:prepare-advice-function))
(in-package #:ooparts/advice/compilation)

(defvar *enabled* nil)
(defvar *previous-hook* nil)
(defvar *installed-hook* nil)
(defvar *compiler-macros* (make-hash-table :test #'equal))
(defvar *inside-hook* nil)
(defvar *saved-definition-reader* nil)
#+abcl (defvar *abcl-precompile-call* nil)
#+abcl (defvar *installed-abcl-hook* nil)
#+ccl (defvar *ccl-loading-removes-encapsulation* nil)

(defmacro with-definition-package-writable (&body body)
  #+sbcl `(sb-ext:without-package-locks ,@body)
  #+ccl `(progn ,@body)
  #+ecl `(let ((si::*ignore-package-locks* t)) ,@body)
  #+mkcl `(let ((closed (si::package-closed-p "COMMON-LISP")))
            (unwind-protect
                 (progn (when closed (si::reopen-package "COMMON-LISP")) ,@body)
              (when closed (si::close-package "COMMON-LISP"))))
  #+clisp `(ext:without-package-lock ("COMMON-LISP") ,@body)
  #+cmucl `(ext:without-package-locks ,@body)
  #+clasp `(ext:with-unlocked-packages ("COMMON-LISP") ,@body)
  #-(or sbcl ccl ecl mkcl clisp cmucl clasp) `(progn ,@body))

(defun managed-definition (name) (resolve-function name))

(defvar *original-fmakunbound* (symbol-function 'fmakunbound))

(defun application-package-p (package)
  ;; Sibling ASDF libraries must remain independently loadable even when an
  ;; aggregate build loads advice first. Check caller packages as well as names.
  (and package
       (not (uiop:string-prefix-p "OOPARTS/" (package-name package)))
       (or (not (uiop:string-prefix-p "OOPARTS-TESTS/" (package-name package)))
           (uiop:string-prefix-p "OOPARTS-TESTS/ADVICE" (package-name package)))
       (or (string= (package-name package) "COMMON-LISP-USER")
           (not (some (lambda (prefix)
                        (let ((text (package-name package)))
                          (or (string= text prefix)
                              (uiop:string-prefix-p (concatenate 'string prefix "/") text)
                              (uiop:string-prefix-p (concatenate 'string prefix "-") text))))
                      '("COMMON-LISP" "KEYWORD" "SB" "CCL" "C" "COMPILER" "SYSTEM"
                        "SYS" "SI" "EXT" "CORE" "CLOS" "MP" "MT" "JAVA" "FFI"
                        "UIOP" "ASDF"))))))

(defun application-name-p (name)
  (application-package-p
   (symbol-package (if (symbolp name) name (second name)))))

(defun prepare-advice-function (name)
  "Give future calls to NAME a dynamic lookup without a NOTINLINE declaration.
Do not replace a compiler macro supplied by the application."
  (when (and (application-name-p name)
             (not (compiler-macro-function name)))
    (let ((expander (lambda (form environment)
                      (declare (ignore environment))
                      (if (application-package-p *package*)
                          `(funcall (resolve-function ',name)
                                    ,@(if (eq (first form) 'funcall) (cddr form) (cdr form)))
                          form))))
      (setf (compiler-macro-function name) expander
            (gethash (copy-tree name) *compiler-macros*) expander)))
  name)

(defun managed-fmakunbound (name)
  (multiple-value-prog1 (funcall *original-fmakunbound* name)
    (reconcile-definitions name)))

(defun definition-place-p (form)
  (and (consp form) (member (first form) '(fdefinition symbol-function))))

(defun expansion-hook (expander form environment)
  (if (or *inside-hook* *changing-definition* (not *enabled*))
      (funcall *previous-hook* expander form environment)
      (let ((*inside-hook* t))
        (cond
          ((and (consp form) (eq (first form) 'defun)
                (application-name-p (second form)))
           (prepare-advice-function (second form))
           `(progn ,(funcall *previous-hook* expander form environment)
                   (eval-when (:load-toplevel :execute)
                     (prepare-advice-function ',(second form))
                     (reconcile-definitions ',(second form)))))
          ((and (consp form) (application-package-p *package*)
                (or (member (first form) '(trace untrace))
                    (and (eq (first form) 'setf)
                         (loop for tail on (rest form) by #'cddr
                               thereis (definition-place-p (first tail))))))
           `(multiple-value-prog1 ,(funcall *previous-hook* expander form environment)
              (reconcile-definitions)))
          (t (funcall *previous-hook* expander form environment))))))

#+abcl
(defun fset-notification (name function)
  (declare (ignore function))
  (unless *changing-definition* (reconcile-definitions name)))

#+abcl
(defun abcl-precompile-call (form &optional previous)
  ;; ABCL precompiles inline and self calls before consulting compiler macros.
  ;; Rewrite only global function positions; preserve lexical FLET/LABELS.
  (let ((name (first form)))
    (if (and *enabled* (application-package-p *package*)
             (symbolp name) (application-name-p name)
             (or (not (compiler-macro-function name))
                 (eq (compiler-macro-function name) (gethash name *compiler-macros*)))
             (not (and pre::*precompile-env*
                       (assoc name (sys:environment-all-functions pre::*precompile-env*)
                              :test #'equal))))
        (progn
          (prepare-advice-function name)
          (pre::precompile1 `(funcall (resolve-function ',name) ,@(rest form))))
        (funcall (or previous *abcl-precompile-call*) form))))

(defun enable-advice-compilation ()
  "Enable dynamic global calls and definition notifications for future DEFUN forms.
Already compiled direct/inline calls are not rewritten. Reversible with DISABLE."
  (unless *enabled*
    #+ccl
    (setf *ccl-loading-removes-encapsulation* ccl::*loading-removes-encapsulation*
          ccl::*loading-removes-encapsulation* nil)
    (setf *prepare-function* #'prepare-advice-function)
    (setf *previous-hook* *macroexpand-hook* *enabled* t)
    (let ((previous *macroexpand-hook*))
      (setf *macroexpand-hook*
            (lambda (expander form environment)
              (let ((*previous-hook* previous))
                (expansion-hook expander form environment)))))
    (setf *installed-hook* *macroexpand-hook*)
    (with-definition-package-writable
      (dolist (name '(fdefinition fmakunbound))
        (unless (compiler-macro-function name)
          (let ((target (if (eq name 'fdefinition) 'resolve-function 'managed-fmakunbound)))
            (let ((expander (lambda (form environment)
                              (declare (ignore environment))
                              (if (application-package-p *package*)
                                  `(,target ,@(if (eq (first form) 'funcall)
                                                  (cddr form) (rest form)))
                                  form))))
              (setf (compiler-macro-function name) expander
                    (gethash name *compiler-macros*) expander))))))
    #-(or sbcl ccl)
    (with-definition-package-writable
      (setf *saved-definition-reader* (symbol-function 'fdefinition)
            (symbol-function 'fdefinition) #'managed-definition))
    #+abcl
    (let ((previous (symbol-function 'pre::precompile-function-call)))
      (setf *abcl-precompile-call* previous
            (symbol-function 'pre::precompile-function-call)
            (lambda (form) (abcl-precompile-call form previous))
            *installed-abcl-hook* (symbol-function 'pre::precompile-function-call)))
    #+abcl (pushnew #'fset-notification sys::*fset-hooks*))
  t)

(defun disable-advice-compilation ()
  "Restore compiler macros owned by this module, leaving application changes intact."
  (when *enabled*
    (when (eq *macroexpand-hook* *installed-hook*)
      (setf *macroexpand-hook* *previous-hook*))
    (with-definition-package-writable
      (maphash (lambda (name expander)
                 (when (eq (compiler-macro-function name) expander)
                   (setf (compiler-macro-function name) nil)))
               *compiler-macros*))
    (clrhash *compiler-macros*)
    #-(or sbcl ccl)
    (with-definition-package-writable
      (when (and *saved-definition-reader*
                 (eq (symbol-function 'fdefinition) #'managed-definition))
        (setf (symbol-function 'fdefinition) *saved-definition-reader*
              *saved-definition-reader* nil)))
    #+abcl
    (when (eq (symbol-function 'pre::precompile-function-call) *installed-abcl-hook*)
      (setf (symbol-function 'pre::precompile-function-call) *abcl-precompile-call*))
    #+abcl (setf sys::*fset-hooks* (remove #'fset-notification sys::*fset-hooks*))
    #+ccl
    (when (null ccl::*loading-removes-encapsulation*)
      (setf ccl::*loading-removes-encapsulation* *ccl-loading-removes-encapsulation*))
    (setf *enabled* nil *prepare-function* nil))
  nil)
