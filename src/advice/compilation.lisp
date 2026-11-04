(uiop:define-package #:ooparts/advice/compilation
  (:use #:cl)
  (:import-from #:ooparts/advice/core #:call-with-detached-advice #:resolve-function #:reconcile-definitions #:*prepare-function*)
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
#+mkcl (defvar *mkcl-c1funcall* nil)
#+mkcl (defvar *installed-mkcl-hook* nil)
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

(defun install-compiler-macro (name expander)
  ;; CMUCL may materialize another closure when registering the expander.
  ;; Ownership must compare against the value actually installed.
  (setf (compiler-macro-function name) expander)
  (setf (gethash (copy-tree name) *compiler-macros*)
        (compiler-macro-function name)))

(defun managed-call-p (name)
  (and (application-package-p *package*) (application-name-p name)
       (or (not (compiler-macro-function name))
           (eq (compiler-macro-function name) (gethash name *compiler-macros*)))))

(defun literal-call-name (form)
  (when (and (consp form) (eq (first form) 'funcall)
             (consp (second form)) (eq (first (second form)) 'function)
             (null (cddr (second form))))
    (let ((name (second (second form))))
      (when (or (symbolp name)
                (and (consp name) (eq (first name) 'setf)
                     (symbolp (second name)) (null (cddr name))))
        name))))

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
      (install-compiler-macro name expander)))
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
          #+cmucl
          ((and (consp form) (application-package-p *package*)
                (eq (first form) 'trace) (rest form))
           ;; Prefer CMUCL's supported binding-based tracer to breakpoints in
           ;; shared closure code. An explicit :ENCAPSULATE option still wins.
           (let ((debug:*trace-encapsulate-default* t))
             `(multiple-value-prog1 ,(funcall *previous-hook* expander form environment)
                (reconcile-definitions))))
          #+(or ecl mkcl clisp clasp)
          ((and (consp form) (application-package-p *package*)
                (member (first form) '(trace untrace))
                (or (rest form) (eq (first form) 'untrace)))
           `(call-with-detached-advice
             ',(mapcar (lambda (spec)
                         (if (and (consp spec) (not (eq (first spec) 'setf)))
                             (first spec) spec))
                       (rest form))
             (lambda () ,(funcall *previous-hook* expander form environment))))
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
  (let* ((literal (literal-call-name form))
         (name (or literal (first form)))
         (local (and pre::*precompile-env*
                     (assoc name (sys:environment-all-functions pre::*precompile-env*)
                            :test #'equal))))
    (cond
      ((and *enabled* literal local (managed-call-p name))
       ;; ABCL's FUNCALL source transform can apply global INLINE information
       ;; even to a local literal. Keep its lexical function value explicit.
       (let ((function (gensym "LEXICAL-FUNCTION-")))
         (pre::precompile1 `(let ((,function (function ,name)))
                             (funcall ,function ,@(cddr form))))))
      ((and *enabled* (symbolp name) (managed-call-p name) (not local))
       (prepare-advice-function name)
       (pre::precompile1 `(funcall (resolve-function ',name)
                                 ,@(if literal (cddr form) (rest form)))))
      (t (funcall (or previous *abcl-precompile-call*) form)))))

#+mkcl
(defun mkcl-c1funcall (arguments previous)
  ;; C1FUNCALL bypasses ordinary compiler macros for literal global functions.
  ;; Consult the compiler's current lexical environment before redirecting.
  (let ((name (literal-call-name (cons 'funcall arguments))))
    (if (and *enabled* name (managed-call-p name)
             (not (compiler::cmp-env-search-function name)))
        (compiler::c1expr `(funcall (resolve-function ',name) ,@(rest arguments)))
        (funcall previous arguments))))

#+cmucl
(defun cmucl-funcall-expander (form environment)
  (let ((name (literal-call-name form)))
    (if (and *enabled* name (managed-call-p name)
             (not (and environment
                       (let ((c::*lexical-environment* environment))
                         (c::lexenv-find-function name)))))
        `(funcall (resolve-function ',name) ,@(cddr form))
        form)))

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
              (install-compiler-macro name expander))))))
    #-(or sbcl ccl cmucl)
    (with-definition-package-writable
      (setf *saved-definition-reader* (symbol-function 'fdefinition)
            (symbol-function 'fdefinition) #'managed-definition))
    #+abcl
    (let ((previous (symbol-function 'pre::precompile-function-call)))
      (setf *abcl-precompile-call* previous
            (symbol-function 'pre::precompile-function-call)
            (lambda (form) (abcl-precompile-call form previous))
            *installed-abcl-hook* (symbol-function 'pre::precompile-function-call)))
    #+abcl (pushnew #'fset-notification sys::*fset-hooks*)
    #+mkcl
    (let ((previous (symbol-function 'compiler::c1funcall))
          (closed (si::package-closed-p "COMPILER")))
      (unwind-protect
           (progn
             (when closed (si::reopen-package "COMPILER"))
             (setf *mkcl-c1funcall* previous
                   (symbol-function 'compiler::c1funcall)
                   (lambda (arguments) (mkcl-c1funcall arguments previous))
                   *installed-mkcl-hook* (symbol-function 'compiler::c1funcall)))
        (when closed (si::close-package "COMPILER"))))
    #+cmucl
    (with-definition-package-writable
      (unless (compiler-macro-function 'funcall)
        (install-compiler-macro 'funcall #'cmucl-funcall-expander))))
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
    #-(or sbcl ccl cmucl)
    (with-definition-package-writable
      (when (and *saved-definition-reader*
                 (eq (symbol-function 'fdefinition) #'managed-definition))
        (setf (symbol-function 'fdefinition) *saved-definition-reader*
              *saved-definition-reader* nil)))
    #+abcl
    (when (eq (symbol-function 'pre::precompile-function-call) *installed-abcl-hook*)
      (setf (symbol-function 'pre::precompile-function-call) *abcl-precompile-call*))
    #+abcl (setf sys::*fset-hooks* (remove #'fset-notification sys::*fset-hooks*))
    #+mkcl
    (when (eq (symbol-function 'compiler::c1funcall) *installed-mkcl-hook*)
      (let ((closed (si::package-closed-p "COMPILER")))
        (unwind-protect
             (progn
               (when closed (si::reopen-package "COMPILER"))
               (setf (symbol-function 'compiler::c1funcall) *mkcl-c1funcall*))
          (when closed (si::close-package "COMPILER")))))
    #+ccl
    (when (null ccl::*loading-removes-encapsulation*)
      (setf ccl::*loading-removes-encapsulation* *ccl-loading-removes-encapsulation*))
    (setf *enabled* nil *prepare-function* nil))
  nil)
