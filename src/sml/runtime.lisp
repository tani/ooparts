;;; Explicit dynamic values and compiled deep continuations for SML Core.
(uiop:define-package #:ooparts/sml/runtime
  (:use #:cl)
  (:import-from #:ooparts/curry #:lambda/c #:labels/c)
  (:export
   #:sml-code #:sml-run #:sml-enter #:sml-function #:sml-application #:sml-or
   #:sml-native-rule
   #:register-sml-function
   #:+unit+ #:+true+ #:+false+ #:+no-match+
   #:+true-identity+ #:+false-identity+
   #:sml-true #:sml-false #:sml-boolean-p #:sml-truth-p #:sml-boolean
   #:make-sml-constructor #:make-sml-nullary-constructor
   #:sml-constructed-p #:sml-constructed-identity #:sml-constructed-name
   #:sml-constructed-payload #:constructor-identity #:constructor-payload
   #:constructor-payload-if
   #:make-sml-record #:sml-record-p #:sml-record-field #:sml-record-fields
   #:make-sml-module #:sml-module-p #:sml-module-field #:sml-module-path
   #:project-sml-module
   #:sml-reference #:make-sml-reference #:sml-reference-contents
   #:set-sml-reference-contents
   #:+sml-word-bits+ #:+sml-word-modulus+
   #:make-sml-word #:sml-word-p #:sml-word-value
   #:sml-raise #:sml-raise-value #:raise-sml
   #:+match-exception+ #:+bind-exception+
   #:+match-exception-identity+ #:+bind-exception-identity+
   #:raise-match #:raise-bind
   #:binding-value #:dynamic-value #:call-pattern #:sml-equal
   #:+list-nil-identity+ #:+list-cons-identity+ #:+reference-identity+
   #:make-sml-list #:sml-list-values #:render-value))
(in-package #:ooparts/sml/runtime)

;;; Compiled SML functions have two compatible views.  Called directly (for
;;; example by a higher-order Basis primitive), they return an ordinary raw SML
;;; value.  Called by generated code, they return a native computation which
;;; the caller's trampoline drives.  The registry is only call-protocol
;;; metadata; saved first-class closures and recursive/static cells, not weak
;;; keys, retain required functions and their ordinary host closure state.
(defvar *sml-functions*
  #+abcl (java:jnew "java.util.WeakHashMap")
  #+sbcl (make-hash-table :test #'eq :weakness :key :synchronized t)
  #+ccl (make-hash-table :test #'eq :weak :key)
  #+ecl (make-hash-table :test #'eq :weakness :key)
  #-(or abcl sbcl ccl ecl) (make-hash-table :test #'eq))
(defvar *sml-computation-context* nil)
(defvar *sml-handler-frames* nil)
#+sbcl
(defvar *sml-function-registrations* 0)

(defstruct (sml-computation
             (:constructor %make-sml-computation (function))
             (:copier nil))
  function)
(defstruct (sml-bounce
             (:constructor %make-sml-bounce (thunk))
             (:copier nil))
  thunk)
(defstruct (sml-tail-application
             (:constructor %make-sml-tail-application
                 (function argument continuation))
             (:copier nil))
  function argument continuation)
(defstruct (sml-resume
             (:constructor %make-sml-resume (continuation thunk))
             (:copier nil))
  continuation thunk)
(defstruct (sml-value-resume
             (:constructor %make-sml-value-resume (continuation value))
             (:copier nil))
  continuation value)
(defstruct (sml-finished
             (:constructor %make-sml-finished (values))
             (:copier nil))
  values)
(defstruct (sml-handler-frame
             (:constructor %make-sml-handler-frame (type continuation))
             (:copier nil))
  type continuation)
(defun %sml-function-registered-p (function)
  #+abcl (java:jcall "containsKey" *sml-functions* function)
  #-abcl (gethash function *sml-functions*))

(defun register-sml-function (function)
  "Mark FUNCTION as compiled user code and return the identical host closure."
  (unless (functionp function)
    (error 'type-error :datum function :expected-type 'function))
  #+sbcl
  (progn
    (incf *sml-function-registrations*)
    ;; Reclaim dead weak keys and their old bucket vectors before millions of
    ;; short-lived curried callbacks force a much larger table resize.  This
    ;; never removes a live function or changes calling-protocol metadata.
    (when (= *sml-function-registrations* 1000000)
      (setf *sml-function-registrations* 0)
      (sb-ext:gc :full t)))
  #+abcl (java:jcall "put" *sml-functions* function t)
  #-abcl (setf (gethash function *sml-functions*) t)
  function)

(defmacro sml-function (lambda-list &body body)
  "A direct Curry closure with compiled deep-continuation calling support."
  `(register-sml-function (lambda/c ,lambda-list ,@body)))

(defmacro sml-or (&rest forms)
  "Enter the ordered alternative computation in direct or generated code."
  `(sml-enter (sml-code (%sml-or-cps ,@forms))))

(defun sml-enter (computation)
  "Return COMPUTATION to generated code, or finish it for a direct caller."
  (check-type computation sml-computation)
  (if *sml-computation-context*
      computation
      (sml-run computation)))

(defun sml-application (function argument)
  "Call directly emitted code; CPS regions expand this operation specially."
  (funcall function argument))

(defun %sml-invoke-continuation (continuation value)
  "Resume one committed SML expression result."
  (funcall continuation value))

(defun %sml-resume-values (continuation thunk)
  "Resume THUNK, preserving the program terminal's multiple host values."
  (multiple-value-call continuation (funcall thunk)))

(defun %sml-finish-application (value continuation)
  (if (sml-computation-p value)
      (funcall (sml-computation-function value) continuation)
      (%make-sml-value-resume continuation value)))

(defun %sml-continue-application (function argument continuation)
  (if (%sml-function-registered-p function)
      (%sml-finish-application
       (let ((*sml-computation-context* t))
         (funcall function argument))
       continuation)
      ;; Basis higher-order primitives call their arguments directly.  Their
      ;; compiled callbacks must consequently produce raw values.  In
      ;; particular, do not normalize or translate their continuation here.
      (%sml-finish-application
       (let ((*sml-computation-context* nil))
         (funcall function argument))
       continuation)))

(defun %sml-continue-compiled-application (function argument continuation)
  (%sml-finish-application
   (let ((*sml-computation-context* t))
     (funcall function argument))
   continuation))

(defun %sml-resume-application (function argument continuation)
  "Start an application without a wrapper computation or needless call state."
  (if (%sml-function-registered-p function)
      ;; Only compiled calls need a fresh trampoline iteration: their next
      ;; action can itself be a tail call.  A Basis call returns raw control
      ;; before the continuation is resumed, just as an ordinary bounce did.
      (%make-sml-tail-application function argument continuation)
      (%sml-continue-application function argument continuation)))

(defun %sml-raw (thunk)
  "Lift a raw host-value computation, preserving its terminal values."
  (%make-sml-computation
   (lambda (continuation)
     (%make-sml-resume continuation thunk))))

(defun %sml-direct-call (function argument)
  "Create one native user/Basis application computation."
  (%make-sml-computation
   (lambda (continuation)
     (%sml-resume-application function argument continuation))))

(defun %sml-pop-handler (frame)
  (unless (eq frame (car *sml-handler-frames*))
    (error "Corrupt compiled SML exception-frame stack."))
  (pop *sml-handler-frames*))

(defun %sml-dispatch-raise (condition)
  ;; Handler functions receive the host condition, just as HANDLER-CASE does.
  ;; Removing the selected frame before entry means an exception in a handler
  ;; is seen by its parent, never recursively by that same handler.
  (let ((frames *sml-handler-frames*))
    (loop
      (unless frames
        (error condition))
      (let ((frame (pop frames)))
        (when (eq 'sml-raise (sml-handler-frame-type frame))
          (setf *sml-handler-frames* frames)
          (return
            (funcall (sml-handler-frame-continuation frame) condition)))))))

(defun sml-run (computation)
  "Drive one compiled computation without growing the host control stack."
  (check-type computation sml-computation)
  (let ((*sml-handler-frames* nil)
        (state
          (%make-sml-bounce
           (lambda ()
             (funcall
              (sml-computation-function computation)
              (lambda (&rest values) (%make-sml-finished values)))))))
    (loop
      (let ((next
              (handler-case
                  (cond
                    ((sml-bounce-p state)
                     (funcall (sml-bounce-thunk state)))
                    ((sml-resume-p state)
                     (%sml-resume-values
                      (sml-resume-continuation state)
                      (sml-resume-thunk state)))
                    ((sml-value-resume-p state)
                     (%sml-invoke-continuation
                      (sml-value-resume-continuation state)
                      (sml-value-resume-value state)))
                    ((sml-tail-application-p state)
                     (%sml-continue-compiled-application
                      (sml-tail-application-function state)
                      (sml-tail-application-argument state)
                      (sml-tail-application-continuation state)))
                    (t (error "Invalid compiled SML trampoline state ~S." state)))
                (sml-raise (condition) (%sml-dispatch-raise condition)))))
        (cond
          ((sml-finished-p next)
           (return (values-list (sml-finished-values next))))
          ((or (sml-bounce-p next) (sml-tail-application-p next)
               (sml-resume-p next) (sml-value-resume-p next))
           (setf state next))
          (t (error "Invalid compiled SML trampoline result ~S." next)))))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun %sml-resume-form (computation continuation)
    ;; Immediate application and raw-result requests avoid allocating a
    ;; computation and closure only to resume them immediately.  SML-RUN
    ;; performs every compiled call itself, so a chain ranging over only tail
    ;; calls never consumes host control stack.  Continuations retain all
    ;; non-tail work and compiled handler frames.
    (cond
      ((and (consp computation)
            (eq (car computation) '%sml-direct-call)
            (= (length computation) 3))
       `(%sml-resume-application
         ,(second computation) ,(third computation) ,continuation))
      ((and (consp computation)
            (eq (car computation) '%sml-raw)
            (= (length computation) 2))
       `(%make-sml-resume ,continuation ,(second computation)))
      (t `(funcall (sml-computation-function ,computation) ,continuation))))

  (defun %sml-cps-return (value continuation)
    (declare (ignore continuation))
    `(%sml-raw (lambda () ,value)))

  (defun %sml-cps-immediate-p (form)
    "True when FORM is synchronous generated host code with no SML call."
    (if (atom form)
        t
        (let ((operator (car form)))
          (cond
            ((member operator '(quote function lambda lambda/c sml-function) :test #'eq)
             ;; Creating a closure does not execute its compiled body.
             t)
            ((member operator
                     '(sml-application sml-code sml-or %sml-or-cps progn if let let* labels labels/c
                       loop handler-case values)
                     :test #'eq)
             nil)
            (t (every #'%sml-cps-immediate-p (cdr form)))))))

  (defun %sml-cps-sequence (forms continuation receiver)
    "Evaluate FORMS left-to-right; RECEIVER builds their final computation."
    (labels ((walk (remaining reversed-values)
               (if (null remaining)
                   (funcall receiver (reverse reversed-values))
                   (let* ((value (%fresh-cps-symbol "VALUE"))
                          (inner (%fresh-cps-symbol "INNER"))
                          (rest (walk (cdr remaining)
                                      (cons value reversed-values))))
                     (if (%sml-cps-immediate-p (car remaining))
                         `(let ((,value ,(car remaining))) ,rest)
                         `(%sml-chain
                           ,(%sml-cps (car remaining) inner)
                           (lambda (,value ,continuation)
                             ,(%sml-resume-form rest continuation))))))))
      (walk forms nil)))

  (defun %sml-cps-progn (forms continuation)
    (cond
      ((null forms) (%sml-cps-return nil continuation))
      ((and (consp (car forms)) (eq (caar forms) 'declare))
       `(locally ,(car forms) ,(%sml-cps-progn (cdr forms) continuation)))
      ((null (cdr forms)) (%sml-cps (car forms) continuation))
      ((%sml-cps-immediate-p (car forms))
       `(progn ,(car forms) ,(%sml-cps-progn (cdr forms) continuation)))
      (t
       (let ((inner (%fresh-cps-symbol "INNER"))
             (ignored (%fresh-cps-symbol "IGNORED")))
         `(%sml-chain
           ,(%sml-cps (car forms) inner)
           (lambda (,ignored ,continuation)
             (declare (ignore ,ignored))
             ,(%sml-resume-form
               (%sml-cps-progn (cdr forms) continuation)
               continuation)))))))

  (defun %sml-cps-let* (bindings body continuation)
    (if (null bindings)
        (%sml-cps `(progn ,@body) continuation)
        (destructuring-bind (name init) (car bindings)
          (if (%sml-cps-immediate-p init)
              `(let ((,name ,init))
                 ,(%sml-cps-let* (cdr bindings) body continuation))
              (let ((inner (%fresh-cps-symbol "INNER")))
                `(%sml-chain
                  ,(%sml-cps init inner)
                  (lambda (,name ,continuation)
                    ,(%sml-resume-form
                      (%sml-cps-let* (cdr bindings) body continuation)
                      continuation))))))))

  (defun %sml-cps-if (test then else continuation)
    (if (%sml-cps-immediate-p test)
        `(%make-sml-computation
          (lambda (,continuation)
            (if ,test
                ,(%sml-resume-form (%sml-cps then continuation) continuation)
                ,(%sml-resume-form (%sml-cps else continuation) continuation))))
        (let ((inner (%fresh-cps-symbol "INNER"))
              (value (%fresh-cps-symbol "CONDITION")))
          `(%sml-chain
            ,(%sml-cps test inner)
            (lambda (,value ,continuation)
              (if ,value
                  ,(%sml-resume-form (%sml-cps then continuation) continuation)
                  ,(%sml-resume-form (%sml-cps else continuation) continuation)))))))

  (defun %sml-cps-or (arguments continuation)
    "Compile ordered alternatives as a flat trampoline, not nested host IFs."
    (let ((branches nil) (remaining arguments))
      (loop
        (unless remaining (error "SML-OR needs at least one alternative."))
        (if (and (= (length remaining) 2)
                 (consp (second remaining))
                 (eq (car (second remaining)) 'sml-or))
            (progn
              (push (first remaining) branches)
              (setf remaining (cdr (second remaining))))
            (progn
              (dolist (branch remaining) (push branch branches))
              (return))))
      (let* ((branches (nreverse branches))
             (last-branch (first (last branches)))
             (last-native-p
               (and (consp last-branch) (eq (car last-branch) 'sml-native-rule)
                    (= (length last-branch) 5)))
             (native-branches (if last-native-p branches (butlast branches)))
             (fallback (unless last-native-p last-branch))
             (rules (gensym "SML-NATIVE-RULES"))
             (captures (gensym "SML-NATIVE-CAPTURES"))
             (entry (gensym "SML-NATIVE-RULE"))
             (frame (gensym "SML-MATCH-FRAME"))
             (dispatch (gensym "SML-MATCH-DISPATCH"))
             (fallback-k (gensym "SML-FALLBACK-CONTINUATION")))
        (dolist (branch native-branches)
          (unless (and (consp branch) (eq (car branch) 'sml-native-rule)
                       (= (length branch) 5))
            (error "Only a terminal SML-OR fallback may be non-native: ~S" branch)))
        (multiple-value-bind (table-form captures-form)
            (funcall (intern "%NATIVE-RULE-GROUP" (find-package '#:ooparts/sml/emit))
                     (mapcar #'cdr native-branches))
          `(let ((,rules ,table-form)
                 (,captures ,captures-form)
                 ,@(when fallback
                     `((,fallback-k
                        (lambda ()
                          (%make-sml-computation
                           (lambda (,fallback-k)
                             ,(%sml-resume-form (%sml-cps fallback fallback-k)
                                                fallback-k))))))))
             (%make-sml-computation
              (lambda (,continuation)
                (%make-sml-bounce
                 (lambda ()
                   (block ,dispatch
                     (loop for ,entry across ,rules
                           for ,frame = (funcall (car ,entry) ,captures)
                           unless (eq ,frame +no-match+)
                             do (return-from ,dispatch
                                  (funcall
                                   (sml-computation-function
                                    (funcall (cdr ,entry) ,frame ,captures))
                                   ,continuation)))
                     ,(if fallback
                          `(funcall
                            (sml-computation-function (funcall ,fallback-k))
                            ,continuation)
                          '(error "SML-OR exhausted without a failure alternative."))))))))))))

  (defun %sml-cps-labels (operator definitions body continuation)
    `(,operator ,definitions ,(%sml-cps-progn body continuation)))

  (defun %sml-cps-loop (test body continuation)
    (let ((condition-k (%fresh-cps-symbol "CONDITION-K"))
          (body-k (%fresh-cps-symbol "BODY-K"))
          (value (%fresh-cps-symbol "LOOP-CONDITION"))
          (ignored (%fresh-cps-symbol "IGNORED"))
          (iterate (%fresh-cps-symbol "ITERATE")))
      `(%make-sml-computation
        (lambda (,continuation)
          (labels ((,iterate ()
                     ,(%sml-resume-form
                       (%sml-cps test condition-k)
                       `(lambda (,value)
                          (if ,value
                              ,(%sml-resume-form
                                (%sml-cps body body-k)
                                `(lambda (,ignored)
                                   (declare (ignore ,ignored))
                                   (,iterate)))
                              (%make-sml-bounce
                               (lambda ()
                                 (%sml-invoke-continuation ,continuation nil))))))))
            (%make-sml-bounce (lambda () (,iterate))))))))

  (defun %sml-cps-handle (protected name handler continuation)
    (let ((protected-k (%fresh-cps-symbol "PROTECTED-K"))
          (handler-k (%fresh-cps-symbol "HANDLER-K"))
          (frame (%fresh-cps-symbol "HANDLER-FRAME"))
          (condition-object (%fresh-cps-symbol "CONDITION"))
          (value (%fresh-cps-symbol "VALUE")))
      `(%make-sml-computation
        (lambda (,continuation)
          (%make-sml-bounce
           (lambda ()
             (let ((,frame
                     (%make-sml-handler-frame
                      'sml-raise
                      (lambda (,condition-object)
                        (let ((,name ,condition-object))
                          ,(%sml-resume-form
                            (%sml-cps handler handler-k)
                            continuation))))))
               (push ,frame *sml-handler-frames*)
               ,(%sml-resume-form
                 (%sml-cps protected protected-k)
                 `(lambda (,value)
                    (%sml-pop-handler ,frame)
                    (%sml-invoke-continuation ,continuation ,value))))))))))

  (defun %fresh-cps-symbol (prefix)
    (gensym (concatenate 'string "SML-" prefix "-")))

  (defun %sml-native-lambda-parts (form)
    "Return the two receiver arguments and body of a generated receiver."
    (when (and (consp form) (eq (car form) 'lambda)
               (or (= (length form) 3)
                   (and (= (length form) 4) (consp (third form))
                        (eq (car (third form)) 'declare)))
               (listp (second form)) (= (length (second form)) 2))
      (values (first (second form)) (second (second form))
              (car (last form)) t)))

  (defun %sml-native-reference-p (form symbol)
    (cond ((atom form) (eq form symbol))
          ((eq (car form) 'quote) nil)
          (t (or (%sml-native-reference-p (car form) symbol)
                 (%sml-native-reference-p (cdr form) symbol)))))

  (defun %sml-raw-receiver-parts (receiver)
    "Recognize single-result raw host work preceding a trampoline resume."
    (multiple-value-bind (value continuation body receiver-p)
        (%sml-native-lambda-parts receiver)
      (when (and receiver-p (= (length receiver) 3))
        (let ((bindings nil))
          (loop
            (if (and (consp body) (eq (car body) 'let) (= (length body) 3)
                     (listp (second body)) (= (length (second body)) 1)
                     (listp (first (second body)))
                     (= (length (first (second body))) 2))
                (progn
                  (push (first (second body)) bindings)
                  (setf body (third body)))
                (return)))
          (when (and (consp body) (eq (car body) '%make-sml-resume)
                     (= (length body) 3) (eq (second body) continuation)
                     (consp (third body)) (eq (car (third body)) 'lambda)
                     (= (length (third body)) 3) (null (second (third body))))
            (let ((bindings (nreverse bindings))
                  (expression (third (third body))))
              (unless (some (lambda (binding)
                              (%sml-native-reference-p (second binding) continuation))
                            bindings)
                (unless (%sml-native-reference-p expression continuation)
                  (values value continuation bindings expression t)))))))))

  (defun %sml-wrap-native-bindings (bindings body)
    (if (null bindings)
        body
        `(let (,(first bindings))
           ,(%sml-wrap-native-bindings (rest bindings) body))))

  (defun %sml-compose-native-receivers (first second)
    "Fuse raw work in FIRST directly into SECOND without a resume cycle."
    (multiple-value-bind (value continuation bindings expression raw-p)
        (%sml-raw-receiver-parts first)
      (declare (ignore continuation))
      (when raw-p
        (multiple-value-bind (next-value next-continuation body next-p)
            (%sml-native-lambda-parts second)
          (when (and next-p (= (length second) 3))
            `(lambda (,value ,next-continuation)
               ,(%sml-wrap-native-bindings
                 bindings `(let ((,next-value ,expression)) ,body))))))))

  (defun %sml-fuse-native-chain (computation receiver)
    "Find adjacent raw receivers through generated value-saving LET forms."
    (cond
      ((and (consp computation) (eq (car computation) '%sml-chain)
            (= (length computation) 3))
       (let ((composed (%sml-compose-native-receivers (third computation) receiver)))
         (when composed
           (multiple-value-bind (fused changed)
               (%sml-fuse-native-chain (second computation) composed)
             (values (if changed fused `(%sml-chain ,(second computation) ,composed))
                     t)))))
      ((and (consp computation) (eq (car computation) 'let)
            (= (length computation) 3))
       (multiple-value-bind (fused changed)
           (%sml-fuse-native-chain (third computation) receiver)
         (when changed
           (values `(let ,(second computation) ,fused) t))))
      (t (values nil nil))))

  (defun %sml-fuse-native-chains (form)
    "Compose generated native resume code, never source-level SML syntax."
    (cond
      ((atom form) form)
      ((eq (car form) 'quote) form)
      ((and (eq (car form) '%sml-chain) (= (length form) 3))
       (let ((computation (%sml-fuse-native-chains (second form)))
             (receiver (%sml-fuse-native-chains (third form))))
         (multiple-value-bind (fused changed)
             (%sml-fuse-native-chain computation receiver)
           (if changed fused `(%sml-chain ,computation ,receiver)))))
      (t
       (cons (%sml-fuse-native-chains (car form))
             (%sml-fuse-native-chains (cdr form))))))

  (defun %sml-lower-native-chains (form)
    "Install each composed receiver directly as its pending native closure."
    (cond
      ((atom form) form)
      ((eq (car form) 'quote) form)
      ((and (eq (car form) '%sml-chain) (= (length form) 3))
       (let ((computation (%sml-lower-native-chains (second form)))
             (receiver (%sml-lower-native-chains (third form)))
             (computation-cell (%fresh-cps-symbol "CHAIN-COMPUTATION"))
             (outer (%fresh-cps-symbol "CHAIN-CONTINUATION")))
         (multiple-value-bind (value continuation body receiver-p)
             (%sml-native-lambda-parts receiver)
           (unless receiver-p
             (error "Unexpected non-literal SML receiver: ~S" receiver))
           `(let ((,computation-cell ,computation))
              (%make-sml-computation
               (lambda (,outer)
                 (%make-sml-bounce
                  (lambda ()
                    (funcall
                     (sml-computation-function ,computation-cell)
                     (lambda (,value)
                       ,@(when (= (length receiver) 4) (list (third receiver)))
                       (let ((,continuation ,outer)) ,body)))))))))))
      (t
       (cons (%sml-lower-native-chains (car form))
             (%sml-lower-native-chains (cdr form))))))

  (defun %sml-cps (form continuation)
    "Compile generated direct code to native continuation-passing host code."
    (cond
      ((atom form) (%sml-cps-return form continuation))
      (t
       (let ((operator (car form))
             (arguments (cdr form)))
         (cond
           ;; These forms create raw synchronous host functions.  User function
           ;; bodies already contain their own SML-CODE conversion.
           ((member operator '(quote function lambda lambda/c sml-function) :test #'eq)
            (%sml-cps-return form continuation))
           ((eq operator 'progn)
            (%sml-cps-progn arguments continuation))
           ((eq operator 'sml-enter)
            (destructuring-bind (computation) arguments
              (unless (and (consp computation) (eq (car computation) 'sml-code))
                (error "Unexpected nested SML computation: ~S" computation))
              (%sml-cps (second computation) continuation)))
           ((eq operator 'sml-or)
            (%sml-cps (macroexpand-1 form) continuation))
           ((eq operator '%sml-or-cps)
            (%sml-cps-or arguments continuation))
           ((eq operator 'if)
            (destructuring-bind (test then else) arguments
              (%sml-cps-if test then else continuation)))
           ((eq operator 'let)
            (let ((bindings (car arguments))
                  (body (cdr arguments)))
              (%sml-cps-sequence
               (mapcar #'second bindings) continuation
               (lambda (values)
                 `(let ,(mapcar (lambda (binding value)
                                  (list (car binding) value))
                                bindings values)
                    ,(%sml-cps-progn body continuation))))))
           ((eq operator 'let*)
            (%sml-cps-let* (car arguments) (cdr arguments) continuation))
           ((member operator '(labels labels/c) :test #'eq)
            (%sml-cps-labels operator (car arguments) (cdr arguments) continuation))
           ((and (eq operator 'loop)
                 (= (length arguments) 4)
                 (eq (first arguments) 'while)
                 (eq (third arguments) 'do))
            (%sml-cps-loop (second arguments) (fourth arguments) continuation))
           ((eq operator 'handler-case)
            (destructuring-bind (protected clause) arguments
              (destructuring-bind (type (name) handler) clause
                (unless (eq type 'sml-raise)
                  (error "Unexpected generated host condition type ~S." type))
                (%sml-cps-handle protected name handler continuation))))
           ((eq operator 'values)
            (%sml-cps-sequence
             arguments continuation
             (lambda (values)
               (%sml-cps-return `(values ,@values) continuation))))
           ((eq operator 'sml-application)
            (destructuring-bind (function argument) arguments
              (%sml-cps-sequence
               (list function argument) continuation
               (lambda (values)
                 (destructuring-bind (function-value argument-value) values
                   `(%sml-direct-call ,function-value ,argument-value))))))
           ((eq operator 'funcall)
            (%sml-cps-sequence
             arguments continuation
             (lambda (values)
               (%sml-cps-return `(funcall ,@values) continuation))))
           (t
            (%sml-cps-sequence
             arguments continuation
             (lambda (values)
               (%sml-cps-return `(,operator ,@values) continuation)))))))))

  (defmacro sml-code (form)
    "Expand emitted code to compact independently host-compiled native CPS."
    (%sml-lower-native-chains
     (%sml-fuse-native-chains
      (%sml-cps form (%fresh-cps-symbol "CONTINUATION"))))))

;; Quoted interned identities remain EQ across source and fasl loading.  None
;; of these runtime sentinels is either of the host boolean objects NIL or T.
(defconstant +unit+ '%unit)
(defconstant +true+ '%true)
(defconstant +false+ '%false)
(defconstant +no-match+ '%no-match)
(defconstant +true-identity+ '%true-constructor)
(defconstant +false-identity+ '%false-constructor)
(defconstant +list-nil-identity+ '%list-nil-constructor)
(defconstant +list-cons-identity+ '%list-cons-constructor)
(defconstant +match-exception-identity+ '%match-exception)
(defconstant +bind-exception-identity+ '%bind-exception)
(defconstant +reference-identity+ '%reference-constructor)

(defun sml-true (value)
  "Return host true precisely when VALUE is the SML true value."
  (eq value +true+))

(defun sml-false (value)
  "Return host true precisely when VALUE is the SML false value."
  (eq value +false+))

(defun sml-boolean-p (value)
  (or (sml-true value) (sml-false value)))

(defun sml-truth-p (value)
  "Convert an SML boolean to host truth, rejecting every other value."
  (cond ((sml-true value) t)
        ((sml-false value) nil)
        (t (error "Expected an SML boolean, got ~S." value))))

(defun sml-boolean (value)
  "Convert host generalized boolean VALUE to an SML boolean."
  (if value +true+ +false+))

(defstruct (sml-constructed
             (:constructor %make-sml-constructed (identity name payload))
             (:conc-name sml-constructed-))
  (identity nil :read-only t)
  (name "" :type string :read-only t)
  (payload +unit+ :read-only t))

(defstruct (sml-reference
             (:constructor make-sml-reference (contents))
             (:predicate sml-reference)
             (:conc-name sml-reference-))
  contents)

(defun %constructor-name (name)
  ;; In particular, do not infer constructor status or spelling from case.
  (if (stringp name) name (princ-to-string name)))

(defun make-sml-constructor (name &optional (identity (make-symbol "CONSTRUCTOR")))
  "Return a unary constructor carrying fresh, or explicitly supplied, IDENTITY."
  (let ((name (%constructor-name name)))
    (lambda/c (payload)
      (%make-sml-constructed identity name payload))))

(defun make-sml-nullary-constructor
    (name &optional (identity (make-symbol "CONSTRUCTOR")))
  "Return a nullary construction; its language payload is the unique unit value."
  (%make-sml-constructed identity (%constructor-name name) +unit+))

;; The exceptions used by generated Match and Bind failures are shared with the
;; initial basis.  Their identities are stable while their names are only for
;; diagnostics and rendering.
(defparameter +match-exception+
  (%make-sml-constructed +match-exception-identity+ "Match" +unit+))
(defparameter +bind-exception+
  (%make-sml-constructed +bind-exception-identity+ "Bind" +unit+))

(defun constructor-identity (value)
  "Return the identity of a constructed value or an SML boolean."
  (cond ((sml-constructed-p value) (sml-constructed-identity value))
        ((sml-reference value) +reference-identity+)
        ((sml-true value) +true-identity+)
        ((sml-false value) +false-identity+)
        (t (error "Expected an SML construction, got ~S." value))))

(defun constructor-payload-if (value)
  "Return constructor payload and host true, or NIL and host false if not one."
  (cond ((sml-constructed-p value)
         (values (sml-constructed-payload value) t))
        ((sml-reference value) (values (sml-reference-contents value) t))
        ((sml-boolean-p value) (values +unit+ t))
        (t (values nil nil))))

(defun constructor-payload (value)
  "Return the payload of a constructed value or an SML boolean."
  (multiple-value-bind (payload present-p) (constructor-payload-if value)
    (unless present-p
      (error "Expected an SML construction, got ~S." value))
    payload))

(defstruct (sml-record
             (:constructor %make-sml-record (fields))
             (:conc-name sml-record-))
  ;; The alist is private to the record and must not be mutated by callers.
  (fields nil :type list :read-only t))

(defun make-sml-record (fields)
  "Make an immutable record from a host alist, preserving label order."
  (%make-sml-record (copy-alist fields)))

(defun %record-binding (record label)
  (assoc label (sml-record-fields record) :test #'equal))

(defun sml-record-field (record label)
  "Return LABEL's value in RECORD, preserving arbitrary SML label spellings."
  (let ((field (%record-binding record label)))
    (unless field
      (error "SML record has no field ~S." label))
    (cdr field)))

(defstruct (sml-module
             (:constructor %make-sml-module (fields))
             (:predicate sml-module-p)
             (:conc-name sml-module-))
  "An immutable namespace-tagged structure view, not an SML record value."
  (fields nil :type list :read-only t))

(defun make-sml-module (fields)
  "Snapshot FIELD alist without copying any contained value or reference cell."
  (dolist (field fields)
    (unless (and (consp (car field)) (keywordp (caar field))
                 (stringp (cdar field)))
      (error "Invalid namespace-tagged SML module field: ~S." field)))
  (%make-sml-module (copy-alist fields)))

(defun sml-module-field (module field)
  "Select FIELD, a (NAMESPACE . SPELLING) key, from an exposed module view."
  (unless (sml-module-p module)
    (error "Expected an SML structure view, got ~S." module))
  (let ((binding (assoc field (sml-module-fields module) :test #'equal)))
    (unless binding
      (error "SML structure view has no ~S field." field))
    (cdr binding)))

(defun sml-module-path (root fields)
  "Walk FIELDS from ROOT; an empty path returns the identical structure object."
  (dolist (field fields root)
    (setf root (sml-module-field root field))))

(defun project-sml-module (module fields)
  "Return a smaller immutable view while sharing every selected field value."
  (%make-sml-module
   (mapcar (lambda (field) (cons field (sml-module-field module field))) fields)))

(defun set-sml-reference-contents (reference value)
  "Replace REFERENCE's contents and return VALUE."
  (setf (sml-reference-contents reference) value))

(defstruct (sml-word
             (:constructor %make-sml-word (value))
             (:conc-name sml-word-))
  (value 0 :type integer :read-only t))

;; Basic Word is explicitly 32-bit and unsigned.  Source-literal range checks
;; use the modulus before emission; construction and arithmetic canonicalize
;; with the corresponding power-of-two mask.
(defconstant +sml-word-bits+ 32)
(defconstant +sml-word-modulus+ (ash 1 +sml-word-bits+))
(defconstant +sml-word-mask+ (1- +sml-word-modulus+))

(defun make-sml-word (value)
  "Canonicalize integer VALUE as an unsigned 32-bit SML Word."
  (check-type value integer)
  (%make-sml-word (logand value +sml-word-mask+)))

(define-condition sml-raise (error)
  ((value :initarg :value :reader sml-raise-value))
  (:report (lambda (condition stream)
             (format stream "SML exception: ~A"
                     (render-value (sml-raise-value condition))))))

(defun raise-sml (value)
  "Signal the language exception VALUE as a host condition."
  (error 'sml-raise :value value))

(defun raise-match ()
  (raise-sml +match-exception+))

(defun raise-bind ()
  (raise-sml +bind-exception+))

(defun binding-value (name frame)
  "Retrieve NAME from a successful matcher's host alist FRAME."
  (let ((binding (assoc name frame :test #'equal)))
    (unless binding
      (error "Matcher frame has no binding named ~S." name))
    (cdr binding)))

(defun dynamic-value (environment name)
  "Read an old compiled binding by its interned host identity.
The environment alist is persistent; updating it never copies reference cells."
  (let ((binding (assoc name environment :test #'eq)))
    (unless binding
      (error "Missing compiled SML dynamic binding ~S." name))
    (cdr binding)))

(defun call-pattern (matcher value failure-value continuation)
  "Run MATCHER, passing its alist to CONTINUATION or raising FAILURE-VALUE."
  (let ((frame (funcall matcher value)))
    (if (eq frame +no-match+)
        (raise-sml failure-value)
        (funcall continuation frame))))

(defun %equality-value-p (value)
  (or (eq value +unit+) (sml-boolean-p value)
      (integerp value) (stringp value) (characterp value)
      (sml-word-p value) (sml-record-p value)
      (sml-constructed-p value) (sml-reference value)))

(defun sml-equal (left right)
  "Implement admissible SML equality; reference values compare by identity."
  (labels ((equality-error (value)
             (error "SML equality is not admissible for ~S." value))
           (equal-value (left right)
             ;; Check before every kind test so even identical functions and
             ;; reals are rejected rather than admitted by an EQ shortcut.
             (unless (%equality-value-p left) (equality-error left))
             (unless (%equality-value-p right) (equality-error right))
             (cond
               ((or (sml-reference left) (sml-reference right))
                (and (sml-reference left) (sml-reference right) (eq left right)))
               ((or (eq left +unit+) (eq right +unit+)
                    (sml-boolean-p left) (sml-boolean-p right))
                (eq left right))
               ((or (integerp left) (integerp right))
                (and (integerp left) (integerp right) (= left right)))
               ((or (stringp left) (stringp right))
                (and (stringp left) (stringp right) (string= left right)))
               ((or (characterp left) (characterp right))
                (and (characterp left) (characterp right) (char= left right)))
               ((or (sml-word-p left) (sml-word-p right))
                (and (sml-word-p left) (sml-word-p right)
                     (= (sml-word-value left) (sml-word-value right))))
               ((or (sml-record-p left) (sml-record-p right))
                (and (sml-record-p left) (sml-record-p right)
                     (let ((left-fields (sml-record-fields left))
                           (right-fields (sml-record-fields right)))
                       (and (= (length left-fields) (length right-fields))
                            (dolist (field left-fields t)
                              (let ((other (assoc (car field) right-fields
                                                  :test #'equal)))
                                (unless (and other
                                             (equal-value (cdr field) (cdr other)))
                                  (return nil))))))))
               (t
                (and (sml-constructed-p left) (sml-constructed-p right)
                     (eq (sml-constructed-identity left)
                         (sml-constructed-identity right))
                     (equal-value (sml-constructed-payload left)
                                  (sml-constructed-payload right)))))))
    (equal-value left right)))

(defun make-sml-list (values)
  "Convert a host list to the canonical nil/:: constructed representation."
  (let ((result (make-sml-nullary-constructor "nil" +list-nil-identity+)))
    (dolist (value (reverse values) result)
      (setf result
            (%make-sml-constructed
             +list-cons-identity+ "::"
             (make-sml-record (list (cons "1" value) (cons "2" result))))))))

(defun sml-list-values (value)
  "Return the host elements of an SML list and true, or NIL and false if not one."
  (let ((values nil)
        (seen (make-hash-table :test #'eq)))
    (loop
      (unless (and (sml-constructed-p value)
                   (not (gethash value seen)))
        (return (values nil nil)))
      (setf (gethash value seen) t)
      (let ((identity (sml-constructed-identity value)))
        (cond
          ((eq identity +list-nil-identity+)
           (return (values (nreverse values) t)))
          ((eq identity +list-cons-identity+)
           (let ((payload (sml-constructed-payload value)))
             (unless (sml-record-p payload)
               (return (values nil nil)))
             (let* ((fields (sml-record-fields payload))
                    (head (assoc "1" fields :test #'equal))
                    (tail (assoc "2" fields :test #'equal)))
               (unless (and head tail (null (cddr fields)))
                 (return (values nil nil)))
               (push (cdr head) values)
               (setf value (cdr tail)))))
          (t (return (values nil nil))))))))

(defun %render-construction (value stream active)
  (write-string (sml-constructed-name value) stream)
  (let ((payload (sml-constructed-payload value)))
    (unless (eq payload +unit+)
      (write-char #\( stream)
      (%render-value payload stream active)
      (write-char #\) stream))))

(defun %render-value (value stream active)
  (let ((composite (or (sml-record-p value) (sml-reference value)
                       (sml-constructed-p value))))
    (cond
      ((and composite (gethash value active))
       (write-string "#<cycle>" stream))
      (t
       (when composite (setf (gethash value active) t))
       (unwind-protect
            (cond
              ((eq value +unit+) (write-string "()" stream))
              ((sml-true value) (write-string "true" stream))
              ((sml-false value) (write-string "false" stream))
              ((integerp value) (write value :stream stream :escape t))
              ((realp value) (write value :stream stream :escape t))
              ((stringp value) (write value :stream stream :escape t))
              ((characterp value) (write value :stream stream :escape t))
              ((sml-word-p value)
               (format stream "0w~D" (sml-word-value value)))
              ((sml-reference value)
               (write-string "ref " stream)
               (%render-value (sml-reference-contents value) stream active))
              ((sml-record-p value)
               (write-char #\{ stream)
               (loop for field in (sml-record-fields value)
                     for first-p = t then nil
                     unless first-p do (write-string ", " stream)
                     do (write-string (princ-to-string (car field)) stream)
                        (write-string " = " stream)
                        (%render-value (cdr field) stream active))
               (write-char #\} stream))
              ((and (sml-constructed-p value)
                    (or (eq (sml-constructed-identity value)
                            +list-nil-identity+)
                        (eq (sml-constructed-identity value)
                            +list-cons-identity+)))
               (multiple-value-bind (values properp) (sml-list-values value)
                 (if properp
                     (progn
                       (write-char #\[ stream)
                       (loop for element in values
                             for first-p = t then nil
                             unless first-p do (write-string ", " stream)
                             do (%render-value element stream active))
                       (write-char #\] stream))
                     (%render-construction value stream active))))
              ((sml-constructed-p value)
               (%render-construction value stream active))
              ((functionp value) (write-string "#<function>" stream))
              (t (error "Cannot render ~S as an SML value." value)))
         (when composite (remhash value active)))))))

(defun render-value (value)
  "Return a deterministic readable representation of an SML runtime VALUE."
  (with-output-to-string (stream)
    (%render-value value stream (make-hash-table :test #'eq))))
