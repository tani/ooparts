(uiop:define-package #:ooparts/continuation/environment
  (:use #:cl)
  #+sbcl
  (:import-from #:sb-cltl2 #:augment-environment #:variable-information
                #:function-information #:parse-macro #:enclose)
  #+ccl
  (:import-from #:ccl #:augment-environment #:variable-information
                #:function-information #:parse-macro #:enclose)
  #+cmucl
  (:import-from #:extensions #:augment-environment #:variable-information
                #:function-information #:parse-macro)
  #+clasp
  (:import-from #:clasp-cltl2 #:augment-environment #:parse-macro #:enclose)
  (:export #:augment-context #:variable-information #:function-information
           #:expand-once #:constant-form-p #:place-expansion))
(in-package #:ooparts/continuation/environment)

#+clasp
(defun clasp-binding-information (name environment variablep)
  ;; Clasp 2.7 also exposes bytecode CMP queries, but its CLTL2 environments
  ;; use the Cleavir protocol. Prefer that protocol whenever it is present.
  (let* ((package (find-package "CLEAVIR-ENV"))
         (accessor (and package (find-symbol (if variablep "VARIABLE-INFO" "FUNCTION-INFO") package))))
    (if (and accessor (fboundp accessor))
        (funcall accessor
                 (symbol-value (find-symbol "*CLASP-SYSTEM*" "CLASP-CLEAVIR"))
                 environment name)
        (uiop:symbol-call :cmp (if variablep :var-info :fun-info) name environment))))

#+clasp
(defun clasp-information-p (information modern legacy)
  (loop for (package-name class-name) in `(("CMP" ,modern) ("CLEAVIR-ENV" ,legacy))
        for package = (find-package package-name)
        for symbol = (and package (find-symbol class-name package))
        thereis (and symbol (find-class symbol nil) (typep information symbol))))

#+clasp
(defun variable-information (name &optional environment)
  ;; Clasp 2.6's full CLTL2 query reads optional TYPE slots even when unbound.
  ;; CPS needs only the category, so leave that unrelated metadata untouched.
  (let ((information (clasp-binding-information name environment t)))
    (values (cond ((clasp-information-p information "SPECIAL-VAR-INFO" "SPECIAL-VARIABLE-INFO") :special)
                  ((clasp-information-p information "CONSTANT-VAR-INFO" "CONSTANT-VARIABLE-INFO") :constant)
                  ((clasp-information-p information "SYMBOL-MACRO-VAR-INFO" "SYMBOL-MACRO-INFO") :symbol-macro)
                  ((clasp-information-p information "LEXICAL-VAR-INFO" "LEXICAL-VARIABLE-INFO") :lexical))
            nil)))

#+clasp
(defun function-information (name &optional environment)
  (let* ((information (clasp-binding-information name environment nil))
         (local-function (clasp-information-p information "LOCAL-FUN-INFO" "LOCAL-FUNCTION-INFO"))
         (local-macro (clasp-information-p information "LOCAL-MACRO-INFO" "LOCAL-MACRO-INFO")))
    (values (cond ((or local-function
                       (clasp-information-p information "GLOBAL-FUN-INFO" "GLOBAL-FUNCTION-INFO")) :function)
                  ((or local-macro
                       (clasp-information-p information "GLOBAL-MACRO-INFO" "GLOBAL-MACRO-INFO")) :macro)
                  ((clasp-information-p information "SPECIAL-OPERATOR-INFO" "SPECIAL-OPERATOR-INFO") :special-form))
            (or local-function local-macro))))

#+clasp
(defun clasp-macro-context (environment)
  (let* ((package (find-package "CLEAVIR-ENV"))
         (converter (and package (find-symbol "COMPILE-TIME" package))))
    (if (and converter (fboundp converter)) (funcall converter environment) environment)))

#+clasp
(defun clasp-augment-environment (environment &rest arguments)
  (let* ((definitions (getf arguments :symbol-macro))
         (package (find-package "CLEAVIR-ENV"))
         (constructor (and package (find-symbol "ADD-LOCAL-SYMBOL-MACRO" package))))
    (if (and definitions constructor (fboundp constructor))
        ;; Clasp 2.7's CLTL2 symbol-macro helper rejects ordinary unbound and
        ;; lexical names. Use its native persistent constructor directly.
        (let ((options (copy-list arguments)))
          (remf options :symbol-macro)
          (setf environment (apply #'augment-environment environment options))
          (dolist (definition definitions environment)
            (destructuring-bind (name expansion) definition
              (check-type name symbol)
              (when (member (variable-information name environment) '(:constant :special))
                (error "Cannot bind ~S as a symbol macro." name))
              (setf environment (funcall constructor environment name expansion)))))
        (apply #'augment-environment environment arguments))))

#+cmucl
(defun enclose (expression environment)
  ;; The native walker removes lexical macro and symbol-macro dependencies
  ;; before COMPILE, which accepts no lexical-environment argument.
  (compile nil
           (walker:macroexpand-all
            (walker:walk-form expression environment
              (lambda (form context environment)
                (declare (ignore context))
                (if (symbolp form) (macroexpand-1 form environment) form)))
            environment)))

#+(or ecl abcl clisp)
(defmacro context-result (&environment environment)
  `',environment)

#+abcl
(defvar *native-evaluator*
  (java:jmethod "org.armedbear.lisp.Lisp" "eval"
                "org.armedbear.lisp.LispObject"
                "org.armedbear.lisp.Environment"
                "org.armedbear.lisp.LispThread"))

#+(or ecl abcl clisp)
(defun evaluate-in-context (form environment)
  ;; Only synthetic binding forms and macro definitions are evaluated here;
  ;; user initializers and CPS bodies are never executed during conversion.
  #+ecl (si:eval-with-env form environment nil environment)
  #+abcl (java:jstatic *native-evaluator* "org.armedbear.lisp.Lisp"
                       form (or environment (sys:make-environment))
                       (threads:current-thread))
  #+clisp
  (ext:eval-env form
    ;; Macro expansion supplies VENV/FENV; EVAL-ENV additionally expects
    ;; block, tagbody and declaration slots in its interpreter environment.
    (vector (when environment (aref environment 0))
            (when environment (aref environment 1)) nil nil nil)))

#+(or ecl abcl clisp)
(defun variable-information (name &optional environment)
  "Return the binding category needed by CPS special-variable analysis."
  (cond
    #+clisp ((ext:special-variable-p name environment) (values :special t))
    #+abcl
    ((or (java:jcall "isSpecialVariable" name)
         (and environment (java:jcall "isDeclaredSpecial" environment name)))
     (values :special (not (null environment))))
    #+ecl
    ((or (si:specialp name)
         (let* ((environment (or environment c::*cmp-env-root*))
                (binding (c::cmp-env-search-var name environment)))
           (if (c::var-p binding)
               (eq (c::var-kind binding) 'special)
               (let ((entry (find-if (lambda (entry)
                                      (and (consp entry) (eq (car entry) name)))
                                    (c::cmp-env-variables environment))))
                 (eq (second entry) 'special)))))
     (values :special (not (null environment))))
    ((constantp name environment) (values :constant nil))
    (t (values nil nil))))

#+(or ecl abcl clisp)
(defun function-information (name &optional environment)
  "Report whether a function name is shadowed by a local binding."
  (let ((local
          #+ecl (and environment (c::cmp-env-search-function name environment))
          #+abcl (and environment (assoc name (sys:environment-all-functions environment) :test #'equal))
          #+clisp
          (and environment
               (loop for bindings = (aref environment 1)
                       then (aref bindings (1- (length bindings)))
                     while (vectorp bindings)
                     thereis (loop for index from 0 below (1- (length bindings)) by 2
                                   thereis (equal name (aref bindings index)))))))
    (values (cond ((and (symbolp name) (macro-function name environment)) :macro)
                  ((or local (fboundp name)) :function))
            (not (null local)))))

(defun augment-context (environment &key variable function symbol-macro macro-definitions declare)
  #+(or sbcl ccl cmucl clasp)
  (let* (#+cmucl (environment (or environment (c::make-null-environment)))
         (macros
           (mapcar (lambda (definition)
                     (destructuring-bind (name arguments &rest body) definition
                       (list name
                             (enclose (parse-macro name arguments
                                                  #+cmucl `((block ,name ,@body))
                                                  #-cmucl body
                                                  environment)
                                      environment))))
                   macro-definitions)))
    #+sbcl
    (sb-ext:without-package-locks
      (augment-environment environment :variable variable :function function
                           :symbol-macro symbol-macro :macro macros :declare declare))
    #-sbcl
    (#+clasp clasp-augment-environment #-clasp augment-environment environment
                         :variable #+clasp (union variable
                                                 (loop for declaration in declare
                                                       when (eq (car declaration) 'special)
                                                         append (cdr declaration)))
                                   #-clasp variable
                         :function function :symbol-macro symbol-macro
                         :macro macros :declare declare))
  #+(or ecl abcl clisp)
  (evaluate-in-context
   `(let ,(mapcar (lambda (name) `(,name nil)) variable)
      ,@(when (or variable declare)
          `((declare ,@(when variable `((ignorable ,@variable))) ,@declare)))
      (flet ,(mapcar (lambda (name)
                       `(,name (&rest arguments) (declare (ignore arguments)) nil))
                     function)
        (symbol-macrolet ,symbol-macro
          (macrolet ,macro-definitions (context-result)))))
   environment))

(defun expand-once (form environment)
  (macroexpand-1 form #+clasp (clasp-macro-context environment) #-clasp environment))

(defun constant-form-p (form environment)
  (constantp form #+clasp (clasp-macro-context environment) #-clasp environment))

(defun place-expansion (place environment)
  (get-setf-expansion place #+clasp (clasp-macro-context environment) #-clasp environment))
