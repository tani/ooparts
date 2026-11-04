(uiop:define-package #:ooparts/advice/core
  (:use #:cl)
  (:import-from #:ooparts/advice/backend #:attach #:detach #:present-p
                #:refresh-references #:*changing-definition* #:raw-definition)
  (:import-from #:ooparts/host #:make-recursive-lock #:with-recursive-lock-held)
  (:export #:advice-add #:advice-remove #:advice-member-p #:advice-mapc
           #:call-with-detached-advice #:*prepare-function* #:define-advice #:advice-status #:resolve-function #:reconcile-definitions))
(in-package #:ooparts/advice/core)

(defstruct piece function where properties)
(defstruct target entries chain installation dispatcher)
(defvar *reconciling* nil)
(defvar *prepare-function* nil)
(defvar *targets* (make-hash-table :test #'equal))
(defvar *registry-lock* (make-recursive-lock "OOPArts advice registry"))

(defun wrap (piece rest)
  "Compose an independently implemented combinator with REST."
  (let ((function (piece-function piece)))
    (ecase (piece-where piece)
      (:before
       (lambda (base &rest args)
         (apply function args)
         (apply rest base args)))
      (:after
       (lambda (base &rest args)
         (multiple-value-prog1 (apply rest base args)
           (apply function args))))
      (:around
       (lambda (base &rest args)
         (apply function (lambda (&rest next-args) (apply rest base next-args)) args)))
      (:override
       (lambda (base &rest args)
         (declare (ignore base))
         (apply function args)))
      (:filter-args
       (lambda (base &rest args)
         (apply rest base (funcall function args))))
      (:filter-return
       (lambda (base &rest args)
         (funcall function (apply rest base args))))
      ((:before-while :before-until)
       (let ((while-p (eq (piece-where piece) :before-while)))
         (lambda (base &rest args)
           (let ((results (multiple-value-list (apply function args))))
             (if (eq (not (null (first results))) while-p)
                 (apply rest base args)
                 (values-list results))))))
      ((:after-while :after-until)
       (let ((while-p (eq (piece-where piece) :after-while)))
         (lambda (base &rest args)
           (let ((results (multiple-value-list (apply rest base args))))
             (if (eq (not (null (first results))) while-p)
                 (apply function args)
                 (values-list results)))))))))

(defun compose-chain (entries)
  (reduce #'wrap entries :from-end t
          :initial-value (lambda (base &rest args) (apply base args))))

(defun piece-name (piece)
  (getf (piece-properties piece) :name))

(defun matches-p (piece key)
  (or (eq key (piece-function piece))
      (and (piece-name piece) (equal key (piece-name piece)))))

(defun check-target (name)
  (unless (or (symbolp name)
              (and (consp name) (eq (first name) 'setf)
                   (consp (rest name)) (symbolp (second name))
                   (null (cddr name))))
    (error "Not a global function name: ~S" name))
  (when (and (symbolp name)
             (or (special-operator-p name) (macro-function name)))
    (error "Advice requires a function, not a macro or special operator: ~S" name))
  name)

(defun check-piece (where function properties)
  (unless (member where '(:before :after :around :override :filter-args
                         :filter-return :before-while :before-until
                         :after-while :after-until))
    (error "Unknown advice position: ~S" where))
  (unless (or (functionp function)
              (and (symbolp function) (fboundp function)
                   (not (macro-function function)) (not (special-operator-p function))))
    (error "Not a function designator: ~S" function))
  (unless (evenp (length properties))
    (error "Advice properties must be a property list: ~S" properties))
  (unless (realp (getf properties :depth 0))
    (error "Advice depth must be a real number."))
  (let ((name (getf properties :name)))
    (unless (or (null name) (symbolp name) (stringp name))
      (error "Advice name must be a symbol or string: ~S" name))))

(defun ordinary-binding-p (name)
  (and (fboundp name)
       (or (not (symbolp name))
           (and (not (macro-function name)) (not (special-operator-p name))))))

(defun reconcile-state (name state)
  (unless (or *changing-definition* *reconciling*)
    (let ((*reconciling* t))
      (cond
        ((not (ordinary-binding-p name))
         (detach name (target-installation state))
         (setf (target-installation state) nil)
         (refresh-references))
        ((not (present-p name (target-installation state)))
         (detach name (target-installation state))
         (setf (target-installation state) (attach name (target-dispatcher state)))
         (refresh-references (target-installation state))))))
  state)

(defun reconcile-definitions (&optional name)
  "Reconnect registered advice after a definition change; preserve undefined targets as pending."
  (unless (or *changing-definition* *reconciling*)
    (with-recursive-lock-held (*registry-lock*)
      (if name
          (let ((state (gethash name *targets*)))
            (when state (reconcile-state name state)))
          (maphash #'reconcile-state *targets*))))
  name)

(defun call-with-detached-advice (names function)
  "Expose native TRACE wrappers to UNTRACE, then reconnect registered advice."
  (with-recursive-lock-held (*registry-lock*)
    (unwind-protect
         (let ((*changing-definition* t))
           (flet ((suspend (name state)
                    (when state
                      (detach name (target-installation state))
                      (setf (target-installation state) nil))))
             (if names
                 (dolist (name names) (suspend name (gethash name *targets*)))
                 (maphash #'suspend *targets*)))
           (funcall function))
      (reconcile-definitions))))

(defun resolve-function (name)
  "Resolve NAME dynamically, first repairing any registered dispatcher."
  (reconcile-definitions name)
  ;; CMUCL's native getter intentionally omits FWRAPPERS. Keep that getter
  ;; intact for host internals, but include native TRACE in application calls.
  #+cmucl (kernel:fdefn-function (kernel:fdefn-or-lose name))
  #-cmucl (raw-definition name))

(defun advice-status (name)
  "Return :ACTIVE, :PENDING, or NIL for registered advice on NAME."
  (with-recursive-lock-held (*registry-lock*)
    (let ((state (gethash name *targets*)))
      (when state
        (reconcile-state name state)
        (if (present-p name (target-installation state)) :active :pending)))))

(defun advice-add (name where function &optional properties)
  "Add FUNCTION at WHERE to global function NAME, pending if NAME is undefined.
PROPERTIES is a plist; :NAME identifies an advice and :DEPTH defaults to zero.
Lower depths are outermost; the newest advice is outermost at equal depth.
An existing name is replaced, or an existing function when :NAME is absent."
  (check-target name)
  (check-piece where function properties)
  (when *prepare-function* (funcall *prepare-function* name))
  (with-recursive-lock-held (*registry-lock*)
    (let* ((state (or (gethash name *targets*) (make-target)))
           (new-name (getf properties :name))
           (entries (stable-sort
                     (cons (make-piece :function function :where where
                                       :properties (copy-list properties))
                           (remove-if (lambda (piece)
                                        (if new-name
                                            (equal new-name (piece-name piece))
                                            (eq function (piece-function piece))))
                                      (target-entries state)))
                     #'< :key (lambda (piece) (getf (piece-properties piece) :depth 0))))
           (chain (compose-chain entries)))
      (unless (target-dispatcher state)
        (setf (target-dispatcher state)
              (lambda (base &rest args) (apply (target-chain state) base args))))
      (setf (target-chain state) chain)
      (reconcile-state name state)
      (setf (target-entries state) entries
            (gethash (copy-tree name) *targets*) state)
      (refresh-references (target-installation state))))
  nil)

(defun advice-remove (name function-or-name)
  "Remove all advice matching FUNCTION-OR-NAME from NAME; absent advice is harmless."
  (with-recursive-lock-held (*registry-lock*)
    (let ((state (gethash name *targets*)))
      (when state
        (let ((entries (remove-if (lambda (piece) (matches-p piece function-or-name))
                                  (target-entries state))))
          (if entries
              (setf (target-chain state) (compose-chain entries)
                    (target-entries state) entries)
              (progn
                (setf (target-chain state) (compose-chain nil)
                      (target-entries state) nil)
                (detach name (target-installation state))
                (remhash name *targets*))))))
    (refresh-references))
  nil)

(defun advice-member-p (function-or-name name)
  "Return true if NAME has advice matching FUNCTION-OR-NAME."
  (with-recursive-lock-held (*registry-lock*)
    (let ((state (gethash name *targets*)))
      (when state (reconcile-state name state))
      (and state
           (not (null (find-if (lambda (piece) (matches-p piece function-or-name))
                               (target-entries state))))))))

(defun advice-mapc (function name)
  "Call FUNCTION with each advice designator and copied properties, outermost first.
Iterate over a snapshot, so callbacks may safely add or remove advice."
  (let ((entries (with-recursive-lock-held (*registry-lock*)
                   (let ((state (gethash name *targets*)))
                     (when state
                       (reconcile-state name state)
                       (copy-list (target-entries state)))))))
    (dolist (piece entries)
      (funcall function (piece-function piece) (copy-list (piece-properties piece)))))
  nil)

(defmacro define-advice (name (where lambda-list &optional advice-name (depth 0)) &body body)
  "Define and install advice, naming its function NAME@ADVICE-NAME when supplied."
  (let ((function-name
          (when advice-name
            (unless (or (symbolp advice-name) (stringp advice-name))
              (error "Advice name must be a symbol or string: ~S" advice-name))
            (intern (format nil "~A@~A"
                            (if (symbolp name) (symbol-name name)
                                (format nil "(SETF ~A)" (second name)))
                            (if (symbolp advice-name) (symbol-name advice-name) advice-name))
                    *package*))))
    (if function-name
        `(progn
           (defun ,function-name ,lambda-list ,@body)
           (advice-add ',name ,where ',function-name
                       (list :name ',advice-name :depth ,depth))
           ',function-name)
        `(progn
           (advice-add ',name ,where (lambda ,lambda-list ,@body)
                       (list :depth ,depth))
           nil))))
