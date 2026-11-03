(uiop:define-package #:ooparts/advice/backend
  (:use #:cl)
  (:export #:attach #:detach #:present-p #:refresh-references #:*changing-definition* #:raw-definition))
(in-package #:ooparts/advice/backend)

(defvar *definition-reader* (symbol-function 'fdefinition))
(defun raw-definition (name) (funcall *definition-reader* name))
(defun (setf raw-definition) (function name) (setf (fdefinition name) function))

(defstruct installation kind name original wrapper marker dispatcher (enabled t))
(defvar *changing-definition* nil)

(defun deliver (installation next args)
  (unless (fboundp (installation-name installation))
    (setf (installation-enabled installation) nil))
  (if (installation-enabled installation)
      (apply (installation-dispatcher installation) next args)
      (apply next args)))

(defun present-p (name installation)
  (and installation (installation-enabled installation) (fboundp name)
       (case (installation-kind installation)
         #+sbcl (:sbcl (sb-int:encapsulated-p name (installation-marker installation)))
         #+ccl (:ccl (ccl::advisedp-1 name :around (installation-marker installation)))
         (:portable (eq (raw-definition name) (installation-wrapper installation))))))

(defun attach (name dispatcher)
  "Install a revocable dispatcher without modifying any other advice layer."
  (let* ((*changing-definition* t)
         (installation (make-installation :name (copy-tree name) :dispatcher dispatcher
                                          :marker (gensym "OOPARTS-ADVICE-"))))
    #+sbcl
    (progn
      (sb-ext:assert-version->= 2 6 6)
      (setf (installation-kind installation) :sbcl)
      (sb-int:encapsulate name (installation-marker installation)
                         (lambda (next &rest args) (deliver installation next args))))
    #+ccl
    (let ((inner (gensym "OOPARTS-NEXT-")))
      (setf (installation-kind installation) :ccl)
      (ccl::advise-2 (lambda (&rest args)
                      (deliver installation (raw-definition inner) args))
                    inner nil name :around (installation-marker installation) nil))
    #-(or sbcl ccl)
    (progn
      (setf (installation-kind installation) :portable
            (installation-original installation) (raw-definition name))
      (setf (raw-definition name)
            (lambda (&rest args)
              (deliver installation (installation-original installation) args)))
      ;; Some compilers materialize different closure objects at multiple uses
      ;; of a lexical function value. Retain the value actually installed.
      (setf (installation-wrapper installation) (raw-definition name)))
    installation))

(defun detach (name installation)
  "Revoke retained dispatchers even when another wrapper prevents physical removal."
  (when installation
    (let ((*changing-definition* t))
      (setf (installation-enabled installation) nil)
      (case (installation-kind installation)
        #+sbcl (:sbcl (sb-int:unencapsulate name (installation-marker installation)))
        #+ccl (:ccl (when (fboundp name)
                      (ccl::%unadvise-1 name :around (installation-marker installation))))
        (:portable
         (when (and (fboundp name)
                    (eq (raw-definition name) (installation-wrapper installation)))
           (setf (raw-definition name) (installation-original installation)))))))
  nil)

(defun user-function-name-p (symbol)
  (let ((package (symbol-package symbol)))
    (and package
         (let ((name (package-name package)))
           (or (string= name "COMMON-LISP-USER")
               (not (some (lambda (prefix) (or (string= prefix name)
                                             (uiop:string-prefix-p (concatenate 'string prefix "-") name)
                                             (uiop:string-prefix-p (concatenate 'string prefix "/") name)))
                      '("COMMON-LISP" "KEYWORD" "SI" "SYS" "COMPILER" "MKCL"
                        "CLOS" "MT" "FFI" "ASDF" "UIOP"))))))))

(defun refresh-references ()
  "Repair MKCL's cached references in discoverable user-named compiled functions.
Direct C calls and anonymous callers cannot be repaired by this operation."
  #+mkcl
  (do-all-symbols (symbol)
    (when (and (user-function-name-p symbol) (fboundp symbol)
               (not (macro-function symbol)) (not (special-operator-p symbol)))
      (let ((function (fdefinition symbol)))
        (when (compiled-function-p function)
          (si::update-function-references function)))))
  nil)
