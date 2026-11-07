;;; Public Core compilation, host loading, execution and basis lookup.

(uiop:define-package #:ooparts/sml/compiler
  (:use #:cl)
  (:import-from #:ooparts/prolog #:query)
  (:import-from #:ooparts/sml/source #:source #:source-name)
  (:import-from #:ooparts/sml/syntax #:ast-node-span)
  (:import-from #:ooparts/sml/parser #:parse-program)
  (:import-from #:ooparts/sml/grammar #:*grammar-database*)
  (:import-from #:ooparts/sml/types
    #:install-type-predicates #:type-to-string #:type-var #:scheme)
  (:import-from #:ooparts/sml/elaborate
    #:install-elaboration-predicates #:elaborate-program #:thaw-static #:freeze-static
    #:sml-elaboration-error)
  (:import-from #:ooparts/sml/emit #:install-emitter-predicates #:emit-program)
  (:import-from #:ooparts/sml/modules
    #:install-module-predicates #:module-program #:emit-module-program
    #:thaw-module-context #:freeze-module-context #:module-context-static)
  (:import-from #:ooparts/sml/basis
    #:basis #:basis-p #:make-initial-basis #:basis-static #:basis-dynamic
    #:basis-module-context #:basis-fixities #:resolve-basis-value
    #:basis-host-symbol #:extend-basis)
  (:import-from #:ooparts/sml/runtime #:render-value)
  (:export
   #:*core-compiler-database* #:basis #:basis-p #:make-initial-basis
   #:compiled-program #:compiled-program-p
   #:compiled-code #:compiled-semantic #:compiled-static
   #:compiled-module-context #:compiled-fixities
   #:compile-source #:run-program #:execute-compiled
   #:lookup-value #:lookup-type #:value-type #:value-to-string))
(in-package #:ooparts/sml/compiler)

(defparameter *core-compiler-database*
  (let ((database *grammar-database*))
    ;; This is the existing isolated grammar DB, not a replacement grammar.
    ;; The type/elaboration/codegen predicate groups have disjoint private
    ;; names and are explicitly installed beside the supplied productions.
    (install-type-predicates database)
    (install-elaboration-predicates database)
    (install-emitter-predicates database)
    (install-module-predicates database)
    database)
  "The supplied isolated grammar DB composed with Core types/elaboration/DCG emission.")

(defstruct (compiled-program
             (:constructor %make-compiled-program
                 (code semantic static source-basis module-context fixities))
             (:copier nil))
  "A fully type-elaborated native program and its host-compilable Curry code.
STATIC is the frozen candidate static basis; SOURCE-BASIS supplies old dynamic
bindings when execution begins.  No user evaluation has occurred at this point."
  (code nil :read-only t)
  (semantic nil :read-only t)
  (static nil :read-only t)
  (source-basis nil :type basis :read-only t)
  (module-context nil :type list :read-only t)
  (fixities nil :type list :read-only t)
  (host-function nil))

(defun compiled-code (program)
  (check-type program compiled-program)
  (compiled-program-code program))

(defun compiled-semantic (program)
  (check-type program compiled-program)
  (compiled-program-semantic program))

(defun compiled-static (program)
  (check-type program compiled-program)
  (compiled-program-static program))

(defun compiled-module-context (program)
  (check-type program compiled-program)
  (compiled-program-module-context program))

(defun compiled-fixities (program)
  (check-type program compiled-program)
  (compiled-program-fixities program))

(defun %binding (name solution)
  (let ((entry (assoc name solution)))
    (unless entry
      (error "The Core compiler query omitted ~S from ~S." name solution))
    (cdr entry)))

(defun %collect-frontend-garbage ()
  "Request host collection at an explicit frontend lifecycle boundary.
The caller keeps all required products and the source basis strongly reachable,
including their reachable graphs.  Unsupported hosts retain their prior
memory-management behavior; collection and reclamation are host operations,
not guarantees of the SML semantics."
  #+sbcl (sb-ext:gc :full t)
  #+ccl (ccl:gc)
  #+ecl (ext:gc t)
  #+clisp (ext:gc)
  #+abcl (ext:gc)
  (values))


(defun %prepare-module-emission (input span)
  "Finalize INPUT's complete native-context/semantic pair before emission.
The one Thaw map preserves aliases between both components.  This query ends
before native rule emission starts, so its continuations cannot retain the
frozen product throughout subsequent emitter work."
  (let* ((module-input (ooparts/sml/elaborate::%internal-query-variable))
         (emission-context (ooparts/sml/elaborate::%internal-query-variable))
         (answers
           (let ((ooparts/sml/modules::*module-emission-input* input))
             (query
              (list
               (list 'ooparts/sml/modules::%provided-module-emission-input
                     module-input)
               (list 'ooparts/sml/elaborate::%thaw-reified
                     module-input nil
                     (ooparts/sml/elaborate::%internal-query-variable)
                     (cons emission-context '?emission-semantic))
               (list 'freeze-module-context emission-context '?frozen-context)
               (list 'module-context-static '?frozen-context '?frozen-static))
              :limit 1 :database *core-compiler-database*))))
    (unless answers
      (error 'sml-elaboration-error
             :span span
             :message "SML elaboration did not produce a well-typed program."))
    (let ((answer (first answers)))
      (values (%binding '?emission-semantic answer)
              (%binding '?frozen-context answer)
              (%binding '?frozen-static answer)))))


(defun %produce-source-products (source source-name basis
                                 allow-omitted-final-semicolon)
  "Produce native-emission inputs while containing frontend temporaries.
Lexical references to the AST, goals, answers and raw semantic end with this
scope.  The returned products and separately retained source span remain
strongly reachable, together with every object reachable from those products."
  (multiple-value-bind (ast fixities)
      (parse-program source :source-name source-name
                     :fixity-environment (basis-fixities basis)
                     :allow-omitted-final-semicolon allow-omitted-final-semicolon)
    (%collect-frontend-garbage)
    (let* ((live-context (ooparts/sml/elaborate::%internal-query-variable))
           (native-static (ooparts/sml/elaborate::%internal-query-variable))
           (goals
             (list
              (list 'thaw-module-context (basis-module-context basis) live-context)
              (list 'phrase
                    (list 'module-program live-context ast
                          '?native-context native-static '?semantic)
                    nil nil)))
           (answers (query goals :limit 1 :database *core-compiler-database*)))
      (unless answers
        (error 'sml-elaboration-error
               :span (ast-node-span ast)
               :message "SML elaboration did not produce a well-typed program."))
      (let* ((answer (first answers))
             (semantic (%binding '?semantic answer))
             (native-context (%binding '?native-context answer))
             (semantic-image
               (ooparts/sml/elaborate::%compact-semantic-image semantic)))
        (multiple-value-bind (emission-semantic frozen-context frozen-static)
            (%prepare-module-emission
             (cons native-context semantic-image) (ast-node-span ast))
          (values emission-semantic semantic-image frozen-context frozen-static
                  fixities (ast-node-span ast)))))))

(defun compile-source (source &key (source-name "<string>")
                                   (basis (make-initial-basis))
                                   allow-omitted-final-semicolon)
  "Elaborate a complete program and return its host-compilable Curry image.
No user SML is evaluated here.  ALLOW-OMITTED-FINAL-SEMICOLON is the explicitly
opt-in MLton batch-input convention; the SML '97 default remains strict.  The
frozen module context and terminal fixity scope travel with the compiled object
and are committed only after normal execution.  Frontend production ends in a
separate lexical scope before a collection request and native emission.
Native emission likewise ends before a final collection request and return,
so host compilation starts with the completed program's actual products."
  (check-type basis basis)
  (check-type source-name string)
  (multiple-value-bind (emission-semantic semantic-image frozen-context
                        frozen-static fixities source-span)
      (%produce-source-products source source-name basis
                                allow-omitted-final-semicolon)
    (%collect-frontend-garbage)
    (let* ((provided (ooparts/sml/elaborate::%internal-query-variable))
           (emitted
             ;; Supply the immutable product through the established
             ;; native-input bridge instead of embedding its complete
             ;; graph in query templates and VM instructions.  The
             ;; special binding keeps it live for this query only.
             (let ((ooparts/sml/modules::*module-emission-input*
                     emission-semantic))
               (query
                (list
                 (list 'ooparts/sml/modules::%provided-module-emission-input
                       provided)
                 (list 'ooparts/sml/modules::emit-module-program-partitioned
                       provided *core-compiler-database* '?code))
                :limit 1 :database *core-compiler-database*))))
      (unless emitted
        (error 'sml-elaboration-error
               :span source-span
               :message "SML elaboration did not produce a well-typed program."))
      (let ((program
              (%make-compiled-program
               (%binding '?code (first emitted))
               semantic-image
               frozen-static
               basis
               frozen-context
               fixities)))
        ;; The emission query and its thawed input end here.  Retain only the
        ;; completed program's actual semantic/static/module products and native
        ;; code before the worker begins host compilation.
        (%collect-frontend-garbage)
        program))))

(defun %host-function (program)
  (or (compiled-program-host-function program)
      (setf (compiled-program-host-function program)
            (let* ((code (compiled-code program))
                   (expanded (macroexpand-1 code)))
              ;; LAMBDA/C macroexpands to (FUNCTION (LAMBDA ...)); host
              ;; compilation, rather than EVAL or a semantic tree walker, makes
              ;; the resulting old-environment function executable.
              (unless (and (consp expanded)
                           (eq (car expanded) 'function)
                           (consp (second expanded))
                           (eq (car (second expanded)) 'lambda))
                (error "Invalid generated Curry function: ~S" code))
              (compile nil (second expanded))))))

(defun run-program (program &key basis)
  "Host-compile if necessary and execute PROGRAM against its old bindings.
Returns `(VALUES VALUE NEW-BASIS)`.  NEW-BASIS commits the candidate static
basis together with all newly evaluated dynamic bindings and is suitable for
another COMPILE-SOURCE/RUN-PROGRAM cycle.  An optional BASIS must be the same
persistent line from which PROGRAM was compiled; it is primarily useful to
make that provenance explicit at call sites.  A language exception before normal
return produces no NEW-BASIS, so newly elaborated bindings are not committed.
Previously performed reference mutations remain in the shared runtime objects."
  (check-type program compiled-program)
  (when (and basis (not (eq basis (compiled-program-source-basis program))))
    (error "PROGRAM's old dynamic environment belongs to a different basis."))
  (let ((old (compiled-program-source-basis program)))
    (multiple-value-bind (value additions)
        (funcall (%host-function program) (basis-dynamic old))
      (values value
              (extend-basis old (compiled-static program) additions
                            :module-context (compiled-module-context program)
                            :fixities (compiled-fixities program))))))

(defun execute-compiled (program &key basis)
  "Compatibility spelling for RUN-PROGRAM, with identical two-value ordering."
  (run-program program :basis basis))

(defun lookup-value (basis name-or-path)
  "Return `(VALUES VALUE PRESENT-P)` for an executed binding in BASIS.
A present binding whose value is host NIL remains distinguishable from a missing
binding, and source names never double as constructor identities."
  (check-type basis basis)
  (multiple-value-bind (host present-p) (basis-host-symbol basis name-or-path)
    (if (not present-p)
        (values nil nil)
        (resolve-basis-value basis host))))

(defun %display-scheme (external)
  "Give persistent (:FV ID) cells temporary query names for TYPE-TO-STRING."
  (let ((names (make-hash-table :test #'equal)) (serial 0))
    (labels ((cell (id)
               (or (gethash id names)
                   (setf (gethash id names)
                         (intern (format nil "?F~D" (incf serial))
                                 (find-package '#:ooparts/sml/compiler)))))
             (walk (term)
               (cond
                 ((and (consp term) (eq (car term) 'type-var)
                       (consp (second term)) (eq (car (second term)) :fv))
                  (list 'type-var (cell (second (second term)))
                        (third term) (fourth term)))
                 ((and (consp term) (eq (car term) 'scheme))
                  (list 'scheme
                        (mapcar (lambda (quantifier)
                                  (destructuring-bind (tag id kind equality) quantifier
                                    (declare (ignore tag))
                                    (list 'type-var (cell id) kind equality)))
                                (second term))
                        (walk (third term))))
                 ((consp term) (cons (walk (car term)) (walk (cdr term))))
                 (t term))))
      (type-to-string (walk external)))))

(defun lookup-type (basis name-or-path)
  "Return `(VALUES TYPE-SCHEME-STRING PRESENT-P NATIVE-SCHEME)` in BASIS.
The third value permits structure/signature elaborators to inspect the exact
persistent native scheme; ordinary callers normally use only the first two."
  (check-type basis basis)
  (multiple-value-bind (host present-p) (basis-host-symbol basis name-or-path)
    (declare (ignore host))
    (if (not present-p)
        (values nil nil nil)
        (let* ((path (if (listp name-or-path)
                         (mapcar (lambda (component)
                                   (if (symbolp component)
                                       (symbol-name component)
                                       component))
                                 name-or-path)
                         (loop with text = (if (symbolp name-or-path)
                                               (symbol-name name-or-path)
                                               name-or-path)
                               with start = 0
                               for stop = (position #\. text :start start)
                               collect (subseq text start stop)
                               while stop do (setf start (1+ stop)))))
               (entry (find path (second (basis-static basis))
                            :key #'second :test #'equal)))
          (if entry
              (values (%display-scheme (third entry)) t (third entry))
              (values nil nil nil))))))

(defun value-type (basis name-or-path)
  "Return `(VALUES TYPE-SCHEME-STRING PRESENT-P)`; see LOOKUP-TYPE."
  (multiple-value-bind (text present-p scheme) (lookup-type basis name-or-path)
    (declare (ignore scheme))
    (values text present-p)))

(defun value-to-string (value)
  "Render an executed SML value without exposing implementation environments."
  (render-value value))
