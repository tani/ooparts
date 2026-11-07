;;; Direct DCG generation of executable Curry/Common Lisp from typed Core terms.
;;; No syntax recognition or type inference is performed here.  Every input
;;; expression has already passed OOPARTS/SML/ELABORATE's static relations.

(uiop:define-package #:ooparts/sml/emit
  (:use #:cl)
  (:import-from #:ooparts/prolog #:*database* #:query #:<- #:<-- #:-->)
  (:import-from #:ooparts/curry #:lambda/c)
  (:import-from #:ooparts/sml/syntax
    #:literal-kind #:literal-value #:real-literal-negative-p
    #:real-literal-significand #:real-literal-scale)
  (:import-from #:ooparts/sml/runtime
    #:+unit+ #:+true+ #:+false+ #:+no-match+ #:+bind-exception+
    #:+match-exception+
    #:sml-code #:sml-enter #:sml-function #:sml-application #:sml-or
    #:sml-native-rule
    #:register-sml-function
    #:make-sml-word #:make-sml-list #:make-sml-record #:sml-module-path
    #:make-sml-nullary-constructor #:make-sml-constructor
    #:sml-record-field #:sml-record-p #:sml-truth-p #:sml-equal
    #:constructor-identity #:constructor-payload-if #:raise-sml
    #:sml-raise #:sml-raise-value #:binding-value #:dynamic-value)
  (:export #:install-emitter-predicates #:emit-program))
(in-package #:ooparts/sml/emit)

(let ((serial 0))
  (defun %fresh-code-symbol (&optional (prefix "G"))
    (intern (format nil "~A.~D" prefix (incf serial))
            (find-package '#:ooparts/sml/emit))))

(defun %real-number (literal)
  (let ((real (literal-value literal)))
    (if (zerop (real-literal-significand real))
        (if (real-literal-negative-p real) -0.0d0 0.0d0)
        (* (if (real-literal-negative-p real) -1 1)
           (coerce (* (real-literal-significand real)
                      (expt 10 (real-literal-scale real)))
                   'double-float)))))

(defun %factory-reference-p (form host)
  "True when generated code reads HOST outside quoted factory source."
  (cond
    ((atom form) (eq form host))
    ((eq (car form) 'quote) nil)
    (t (or (%factory-reference-p (car form) host)
           (%factory-reference-p (cdr form) host)))))

(defun %factory-captures (lexicals definitions)
  "Return only value cells read by this independently compiled factory."
  (let ((captures nil))
    (dolist (entry lexicals (nreverse captures))
      (let ((host (if (consp entry) (second entry) entry)))
        (when (and (%factory-reference-p definitions host)
                   (not (member host captures :test #'eq)))
          (push host captures))))))

(defun %rewrite-factory-functions (form)
  "Map recursive function-namespace references to lexical VALUE cells."
  (cond
    ((atom form) form)
    ((eq (car form) 'quote) form)
    ((and (eq (car form) 'function)
          (symbolp (second form))
          (null (cddr form)))
     (second form))
    (t
     (let ((head (%rewrite-factory-functions (car form)))
           (tail (%rewrite-factory-functions (cdr form))))
       (if (and (eq head (car form)) (eq tail (cdr form)))
           form
           (cons head tail))))))

(defun %irrefutable-pattern-p (pattern)
  (and (consp pattern)
       (case (car pattern)
         ((:p-wildcard :p-variable) t)
         (:p-typed (%irrefutable-pattern-p (fifth pattern)))
         (:p-layered (%irrefutable-pattern-p (sixth pattern)))
         (:p-record
          (every (lambda (row)
                   (and (consp row) (eq (car row) :p-row)
                        (%irrefutable-pattern-p (third row))))
                 (fifth pattern)))
         (otherwise nil))))

(defun %irrefutable-pattern-list-p (patterns)
  (every #'%irrefutable-pattern-p patterns))

(defun %factory-call (hosts captures factory)
  "Bind factory results without a one-value MULTIPLE-VALUE-SETQ temporary."
  (let ((application `(funcall (load-time-value (compile nil ',factory))
                               %environment ,@captures)))
    (if (and (consp hosts) (null (cdr hosts)))
        `(setq ,(first hosts) ,application)
        `(multiple-value-setq ,hosts ,application))))

(defun %factory-initializer (hosts definitions lexicals)
  "Compile one recursive group independently with explicit lexical captures."
  (let* ((captures (%factory-captures lexicals definitions))
         (definitions (%rewrite-factory-functions definitions))
         (factory
           `(lambda (%environment ,@captures)
              (declare (ignorable %environment ,@captures))
              (let ,(mapcar (lambda (host) `(,host nil)) hosts)
                (setq
                 ,@(mapcan
                    (lambda (definition)
                      (destructuring-bind (host (argument) body) definition
                        (list host `(register-sml-function
                                       (lambda (,argument) ,body)))))
                    definitions))
                ,(if (and (consp hosts) (null (cdr hosts)))
                     (first hosts)
                     `(values ,@hosts))))))
    (%factory-call hosts captures factory)))

(defun %native-context-bindings (captures shared-captures context)
  "Project only required immutable values from one shared activation vector."
  (cons `(%environment (svref ,context 0))
        (mapcar (lambda (host)
                  `(,host (svref ,context
                                 ,(1+ (position host shared-captures :test #'eq)))))
                captures)))

(defun %native-rule-group (rules)
  "Compile every rule independently around one static table and capture vector."
  (let ((shared-captures nil)
        (code-groups nil))
    ;; Compute the complete immutable layout before compiling any code group.
    (dolist (rule rules)
      (destructuring-bind (lexicals matcher frame body) rule
        (declare (ignore frame))
        (dolist (host (%factory-captures lexicals (list matcher body)))
          (unless (member host shared-captures :test #'eq)
            (push host shared-captures)))))
    (setf shared-captures (nreverse shared-captures))
    (dolist (rule rules)
      (destructuring-bind (lexicals matcher frame body) rule
        (let* ((captures (%factory-captures lexicals (list matcher body)))
               (matcher (%rewrite-factory-functions matcher))
               (body (%rewrite-factory-functions body))
               (context (%fresh-code-symbol "NATIVE-CONTEXT"))
               (bindings (%native-context-bindings captures shared-captures context))
               (matcher-code
                 `(lambda (,context)
                    (let ,bindings
                      (declare (ignorable %environment ,@captures))
                      ,matcher)))
               (body-code
                 `(lambda (,frame ,context)
                    (declare (ignorable ,frame))
                    (let ,bindings
                      (declare (ignorable %environment ,@captures))
                      (sml-code ,body)))))
          (push `(cons (compile nil ',matcher-code) (compile nil ',body-code))
                code-groups))))
    (values `(load-time-value (vector ,@(nreverse code-groups)))
            `(vector %environment ,@shared-captures))))

(defun %partition-query-variable ()
  ;; Keep injected packet roots out of the query's named output bindings.
  (let ((symbol (gensym "?EMISSION-PART-")))
    (setf (get symbol 'dcg-internal) t)
    symbol))

(defun %module-emission-symbol (name)
  (let ((package (find-package '#:ooparts/sml/modules)))
    (unless package
      (error "Module emission input is unavailable while partitioning rules."))
    (intern name package)))

(defun %call-with-rule-emission-input (input thunk)
  ;; Rebind the existing per-query input channel, including for nested groups.
  (progv (list (%module-emission-symbol "*MODULE-EMISSION-INPUT*"))
      (list input)
    (funcall thunk)))

(defun %rule-part-query (input goals)
  (let ((answers
          (%call-with-rule-emission-input
           input (lambda ()
                   (query goals :limit 1 :database *database*)))))
    (unless answers
      (error "A partitioned native rule emission step failed."))
    (let ((answer (assoc '?partitioned-output (first answers))))
      (unless answer
        (error "A partitioned native rule emission step omitted its output."))
      (cdr answer))))

(defun %partitioned-rule-head (rule values outer-lexicals finalp)
  (let ((packet (%partition-query-variable))
        (source-rule (%partition-query-variable))
        (arguments (%partition-query-variable))
        (lexicals (%partition-query-variable))
        (operation (if (and finalp (consp rule) (eq (car rule) :fc))
                       :final-function-head
                       :head)))
    (%rule-part-query
     (list operation rule values outer-lexicals)
     (list
      (list (%module-emission-symbol "%PROVIDED-MODULE-EMISSION-INPUT") packet)
      (list '= packet (list operation source-rule arguments lexicals))
      (list (if (eq operation :final-function-head)
                '%emit-final-function-head
                '%emit-rule-head)
            source-rule arguments lexicals '?partitioned-output)))))

(defun %partitioned-rule-finish (operation descriptor values outer-lexicals
                                           failure marker)
  (let ((packet (%partition-query-variable))
        (source (%partition-query-variable))
        (arguments (%partition-query-variable))
        (lexicals (%partition-query-variable))
        (original-failure (%partition-query-variable))
        (rest (%partition-query-variable)))
    (let ((part
            (%rule-part-query
             (list operation descriptor values outer-lexicals failure marker)
             (list
              (list (%module-emission-symbol "%PROVIDED-MODULE-EMISSION-INPUT") packet)
              (list '= packet
                    (list operation source arguments lexicals original-failure rest))
              (ecase operation
                (:ordinary
                 (list '%emit-ordinary-finish source arguments lexicals rest
                       '?partitioned-output))
                (:final-ordinary
                 (list '%emit-final-ordinary-finish source arguments lexicals
                       original-failure rest '?partitioned-output))
                (:function
                 (list '%emit-function-finish source arguments lexicals rest
                       '?partitioned-output))
                (:final-function
                 (list '%emit-final-function-finish source arguments lexicals
                       rest '?partitioned-output)))))))
      (values part
              (loop for remaining on values
                    for position upfrom 0
                    collect (cons position (car remaining)))))))

(defun %exact-list-length-p (value expected)
  (loop repeat expected
        do (unless (consp value) (return-from %exact-list-length-p nil))
           (setf value (cdr value))
        finally (return (null value))))

(defun %immutable-lexical-tail-eq-p (left right)
  "Compare only a reified lexical split with its immutable supplied tail.
Cons mappings are bijective, atoms retain identity, and a pending revisit is a
cycle rather than a successful ground comparison."
  (let ((left-to-right (make-hash-table :test #'eq))
        (right-to-left (make-hash-table :test #'eq))
        (active (make-hash-table :test #'eq))
        (work (list (list left right nil))))
    (catch 'different-lexical-tail
      (loop while work do
        (destructuring-bind (a b exitp) (pop work)
          (if exitp
              (remhash a active)
              (cond
                ((consp a)
                 (unless (consp b) (throw 'different-lexical-tail nil))
                 (multiple-value-bind (mapped a-presentp)
                     (gethash a left-to-right)
                   (multiple-value-bind (reverse b-presentp)
                     (gethash b right-to-left)
                     (when (or (and a-presentp
                                    (or (not b-presentp) (not (eq mapped b))))
                               (and b-presentp
                                    (or (not a-presentp) (not (eq reverse a)))))
                       (throw 'different-lexical-tail nil))
                     (if a-presentp
                         (when (gethash a active)
                           (throw 'different-lexical-tail nil))
                         (progn
                           (setf (gethash a left-to-right) b
                                 (gethash b right-to-left) a
                                 (gethash a active) t)
                           (push (list a b t) work)
                           (push (list (cdr a) (cdr b) nil) work)
                           (push (list (car a) (car b) nil) work))))))
                ((consp b) (throw 'different-lexical-tail nil))
                ((not (eq a b)) (throw 'different-lexical-tail nil))))))
      t)))

(defun %native-rule-matcher-reference-p (carrier matcher)
  "Check CARRIER's actual matcher input by identity, not printed equality."
  (let ((seen (make-hash-table :test #'eq))
        (work (list matcher)))
    (loop while work do
      (let ((value (pop work)))
        (when (eq value carrier) (return t))
        (when (consp value)
          (unless (gethash value seen)
            (setf (gethash value seen) t)
            (push (car value) work)
            (push (cdr value) work)))))))

(defun %restore-part-capture-references (part mapping)
  "Install source argument identities in every alias in coordinator-owned PART.
MAPPING is a bijection from reified compound carriers to supplied source cells.
Shared references and cycles are handled without copying any argument or body."
  (let ((seen (make-hash-table :test #'eq))
        (work (list part)))
    (loop while work do
      (let ((value (pop work)))
        (when (and (consp value) (not (gethash value seen)))
          (setf (gethash value seen) t)
          (multiple-value-bind (replacement mappedp) (gethash (car value) mapping)
            (if mappedp
                (setf (car value) replacement)
                (when (consp (car value)) (push (car value) work))))
          (multiple-value-bind (replacement mappedp) (gethash (cdr value) mapping)
            (if mappedp
                (setf (cdr value) replacement)
                (when (consp (cdr value)) (push (cdr value) work))))))))
  part)

(defun %restore-native-lexical-tail
    (part values argument-map outer-lexicals)
  "Restore the exact positional source arguments and the supplied lexical tail.
QUERY reification copies compound carriers.  ARGUMENT-MAP is the partition
finisher's explicit ordinal relation to its raw supplied argument cells; it is
not a spelling comparison or an independently materialized source value."
  (unless (and (%exact-list-length-p part 3) (eq (first part) 'sml-or))
    (error "A native partitioned rule has no ordered SML-OR wrapper."))
  (let ((native (second part)))
    (unless (and (%exact-list-length-p native 5)
                 (eq (first native) 'sml-native-rule))
      (error "A partitioned ordered alternative has no native rule."))
    (let ((prefix (second native))
          (expected values)
          (remaining-map argument-map)
          (position 0)
          (last-prefix nil)
          (part-to-source (make-hash-table :test #'eq))
          (source-to-part (make-hash-table :test #'eq)))
      (loop while (consp expected) do
        (unless (consp prefix)
          (error "A native capture prefix ends before its source arguments."))
        (unless (and (consp remaining-map)
                     (consp (car remaining-map))
                     (eql (caar remaining-map) position)
                     (eq (cdar remaining-map) (car expected)))
          (error "A native part's positional source argument map is invalid."))
        (let ((carrier (car prefix))
              (source (car expected)))
          (unless (eq carrier source)
            ;; The handler's SML-RAISE-VALUE carrier is a compound code form.
            ;; Accept its reification only through the explicit position map,
            ;; and only when this exact carrier is its own matcher's input.
            ;; Bare symbol mismatches remain hard identity failures.
            (unless (and (consp carrier)
                         (%native-rule-matcher-reference-p carrier (third native)))
              (error "A native capture prefix differs from its source arguments."))
            (multiple-value-bind (prior-source presentp)
                (gethash carrier part-to-source)
              (when (and presentp (not (eq prior-source source)))
                (error "One part carrier maps to multiple source arguments.")))
            (multiple-value-bind (prior-carrier presentp)
                (gethash source source-to-part)
              (when (and presentp (not (eq prior-carrier carrier)))
                (error "One source argument has inconsistent part carriers.")))
            (setf (gethash carrier part-to-source) source
                  (gethash source source-to-part) carrier)))
        (incf position)
        (setf remaining-map (cdr remaining-map)
              last-prefix prefix
              prefix (cdr prefix)
              expected (cdr expected)))
      (when (or expected remaining-map)
        (error "Native rule arguments and positional maps have different lengths."))
      (unless (%immutable-lexical-tail-eq-p prefix outer-lexicals)
        (error "A native capture suffix is not the supplied lexical tail."))
      (%restore-part-capture-references part part-to-source)
      ;; RULE-PART-QUERY reifies every result cons, so only this fresh
      ;; coordinator-owned output is rewired, never a supplied/frozen input.
      (if last-prefix
          (setf (cdr last-prefix) outer-lexicals)
          (setf (second native) outer-lexicals)))
    part))

(defun %assemble-rule-part (part marker successor expected-holes)
  "Fill the one fresh continuation hole without copying any source subgraph."
  (let ((states (make-hash-table :test #'eq))
        (work (list (list part nil)))
        (holes 0))
    (loop while work do
      (destructuring-bind (value exitp) (pop work)
        (if exitp
            (progn
              (unless (eq (gethash value states) :visiting)
                (error "Invalid pending state while assembling a native rule."))
              (setf (gethash value states) :done))
            (cond
              ((consp value)
               (case (gethash value states)
                 (:visiting
                  (error "A cyclic native rule template is not ground code."))
                 (:done nil)
                 (otherwise
                  (setf (gethash value states) :visiting)
                  (push (list value t) work)
                  (push (list (cdr value) nil) work)
                  (push (list (car value) nil) work))))
              ((eq value marker) (incf holes))))))
    (unless (= holes expected-holes)
      (error "Partitioned rule continuation holes: expected ~D, found ~D."
             expected-holes holes))
    (when (plusp expected-holes)
      (unless (and (%exact-list-length-p part 3)
                   (eq (first part) 'sml-or)
                   (eq (third part) marker))
        (error "The partitioned continuation hole is outside SML-OR's rest slot."))
      (setf (third part) successor))
    part))

(defun %emit-rules-partitioned (rules values outer-lexicals failure)
  "Emit heads in source order and finish the same rule chain on unwind."
  (let ((descriptors
          (loop for remaining on rules
                for rule = (car remaining)
                collect (%partitioned-rule-head
                         rule values outer-lexicals (null (cdr remaining)))))
        (marker (make-symbol "SML-RULE-REST")))
    (let ((code failure)
          (finalp t))
      (dolist (descriptor (nreverse descriptors) code)
        (let ((operation
                (case (first descriptor)
                  (:ordinary-head
                   (if finalp :final-ordinary :ordinary))
                  (:function-head
                   (if finalp :final-function :function))
                  (otherwise
                   (error "Unknown partitioned rule head descriptor.")))))
          (multiple-value-bind (part argument-map)
              (%partitioned-rule-finish
               operation descriptor values outer-lexicals failure marker)
            (let ((direct-final-p
                    (and (eq operation :final-function)
                         (not (and (consp part) (eq (car part) 'sml-or))))))
              (when direct-final-p
                (unless (and (consp part) (eq (car part) 'let))
                  (error "A final direct function rule has no direct LET body.")))
              (unless direct-final-p
                (%restore-native-lexical-tail
                 part values argument-map outer-lexicals))
              (setf code (%assemble-rule-part
                          part marker code (if direct-final-p 0 1))
                    finalp nil))))))))

(defun install-emitter-predicates (database)
  (let ((*database* database))
    (<-- (%append nil ?right ?right) !)
    (<- (%append (?head . ?left) ?right (?head . ?rest))
        (%append ?left ?right ?rest))
    (<-- (%symbol-member ?symbol (?symbol . ?rest)) !)
    (<- (%symbol-member ?symbol (?other . ?rest)) (%symbol-member ?symbol ?rest))
    (<-- (%remove-symbols nil ?symbols nil) !)
    (<- (%remove-symbols (?symbol . ?symbols) ?removed ?rest)
        (or (-> (%symbol-member ?symbol ?removed) (= ?rest ?tail))
            (= ?rest (?symbol . ?tail)))
        (%remove-symbols ?symbols ?removed ?tail))

    ;;; One dynamic old-binding environment is an explicit argument of the
    ;;; outer Curry function.  Lexical bindings generated by this compilation
    ;;; remain lexical; only earlier basis bindings consult that environment.
    (<-- (%function-marker-member ?symbol ((:sml-function ?symbol) . ?rest)) !)
    (<- (%function-marker-member ?symbol (?other . ?rest))
        (%function-marker-member ?symbol ?rest))
    (<-- (%function-markers nil nil) !)
    (<- (%function-markers (?host . ?hosts) ((:sml-function ?host) . ?markers))
        (%function-markers ?hosts ?markers))

    (<-- (%emit-variable (:module-ref (:module-ref ?root ?prefix) ?fields) ?lexicals ?code)
        (%append ?prefix ?fields ?path)
        (%emit-variable (:module-ref ?root ?path) ?lexicals ?code))
    (<- (%emit-variable (:module-ref ?root ?fields) ?lexicals
                         (sml-module-path ?root (quote ?fields)))
        (%symbol-member ?root ?lexicals) !)
    (<- (%emit-variable (:module-ref ?root ?fields) ?lexicals
                        (sml-module-path
                         (dynamic-value %environment (quote ?root)) (quote ?fields))) !)
    (<- (%emit-variable ?symbol ?lexicals (function ?symbol))
        (%function-marker-member ?symbol ?lexicals) !)
    (<- (%emit-variable ?symbol ?lexicals ?symbol)
        (%symbol-member ?symbol ?lexicals) !)
    (<- (%emit-variable ?symbol ?lexicals (dynamic-value %environment (quote ?symbol))))

    (<-- (%emit-expression (:x-literal ?span ?type ?literal) ?lexicals ?code)
        ! (%emit-literal ?literal ?code))
    (<- (%emit-expression (:x-variable ?span ?type ?symbol ?status) ?lexicals ?code)
        ! (%emit-variable ?symbol ?lexicals ?code))
    (<- (%emit-expression (:x-unit ?span ?type) ?lexicals +unit+) !)
    (<- (%emit-expression (:x-typed ?span ?type ?child) ?lexicals ?code)
        ! (%emit-expression ?child ?lexicals ?code))
    (<- (%emit-expression (:x-record ?span ?type ?rows) ?lexicals (make-sml-record (list . ?fields)))
        ! (%emit-expression-rows ?rows ?lexicals ?fields))
    (<- (%emit-expression (:x-selector ?span ?type ?label ?record) ?lexicals
                          (lambda/c (?value) (sml-record-field ?value ?label)))
        ! (lisp ?value (%fresh-code-symbol "RECORD")))
    (<- (%emit-expression (:x-sequence ?span ?type ?items) ?lexicals (progn . ?forms))
        ! (%emit-expressions ?items ?lexicals ?forms))
    (<- (%emit-expression (:x-list ?span ?type ?items) ?lexicals (make-sml-list (list . ?values)))
        ! (%emit-expressions ?items ?lexicals ?values))
    (<- (%emit-expression (:x-application ?span ?type ?function ?argument) ?lexicals
                          (sml-application ?function-code ?argument-code))
        ! (%emit-expression ?function ?lexicals ?function-code)
        (%emit-expression ?argument ?lexicals ?argument-code))
    (<- (%emit-expression (:x-andalso ?span ?type ?left ?right) ?lexicals
                          (if (sml-truth-p ?left-code) ?right-code +false+))
        ! (%emit-expression ?left ?lexicals ?left-code)
        (%emit-expression ?right ?lexicals ?right-code))
    (<- (%emit-expression (:x-orelse ?span ?type ?left ?right) ?lexicals
                          (if (sml-truth-p ?left-code) +true+ ?right-code))
        ! (%emit-expression ?left ?lexicals ?left-code)
        (%emit-expression ?right ?lexicals ?right-code))
    (<- (%emit-expression (:x-if ?span ?type ?condition ?then ?else) ?lexicals
                          (if (sml-truth-p ?condition-code) ?then-code ?else-code))
        ! (%emit-expression ?condition ?lexicals ?condition-code)
        (%emit-expression ?then ?lexicals ?then-code)
        (%emit-expression ?else ?lexicals ?else-code))
    (<- (%emit-expression (:x-raise ?span ?type ?child) ?lexicals (raise-sml ?code))
        ! (%emit-expression ?child ?lexicals ?code))
    (<- (%emit-expression (:x-while ?span ?type ?condition ?body) ?lexicals
                          (progn (loop while (sml-truth-p ?condition-code) do ?body-code) +unit+))
        ! (%emit-expression ?condition ?lexicals ?condition-code)
        (%emit-expression ?body ?lexicals ?body-code))
    (<- (%emit-expression (:x-function ?span ?type ?argument ?rules) ?lexicals ?code)
        ! (%emit-one-argument-function ?rules ?lexicals ?code))
    (<- (%emit-expression (:x-case ?span ?type ?scrutinee ?rules) ?lexicals ?code)
        ! (%emit-expression ?scrutinee ?lexicals ?scrutinee-code)
        (lisp ?value (%fresh-code-symbol "CASE"))
        (%emit-rules ?rules (?value) ?lexicals (raise-sml +match-exception+) ?match-code)
        (= ?code (let ((?value ?scrutinee-code)) ?match-code)))
    (<- (%emit-expression (:x-handle ?span ?type ?child ?rules) ?lexicals ?code)
        ! (%emit-expression ?child ?lexicals ?child-code)
        (lisp ?condition (%fresh-code-symbol "EXCEPTION"))
        (%emit-rules ?rules ((sml-raise-value ?condition)) ?lexicals
                     (raise-sml (sml-raise-value ?condition)) ?handler-code)
        (= ?code (handler-case ?child-code
                   (sml-raise (?condition) ?handler-code))))
    (<- (%emit-expression (:x-let ?span ?type ?declarations ?expressions) ?lexicals ?code)
        ! (%items-interface ?declarations ?lexicals ?inner-lexicals ?updates)
        (%emit-expressions ?expressions ?inner-lexicals ?forms)
        (= ?body (progn . ?forms))
        (%emit-local-items ?declarations ?lexicals ?body ?code))

    (<-- (%emit-expressions nil ?lexicals nil) !)
    (<- (%emit-expressions (?item . ?items) ?lexicals (?code . ?codes))
        (%emit-expression ?item ?lexicals ?code)
        (%emit-expressions ?items ?lexicals ?codes))
    (<-- (%emit-expression-rows nil ?lexicals nil) !)
    (<- (%emit-expression-rows ((:x-row ?label ?item) . ?rows) ?lexicals
                               ((cons ?label ?code) . ?fields))
        (%emit-expression ?item ?lexicals ?code)
        (%emit-expression-rows ?rows ?lexicals ?fields))

    (<-- (%emit-literal ?literal (quote ?value))
        (lisp ?kind (literal-kind ?literal))
        (or (-> (= ?kind :real) (lisp ?value (%real-number ?literal)))
            (and (or (= ?kind :integer)
                     (or (= ?kind :character) (= ?kind :string)))
                 (lisp ?value (literal-value ?literal)))) !)
    (<- (%emit-literal ?literal (make-sml-word (quote ?value)))
        (lisp ?kind (literal-kind ?literal))
        (= ?kind :word)
        (lisp ?value (literal-value ?literal)))

    ;;; Matchers are ordinary generated functions.  Patterns themselves never
    ;;; survive into executable code as a tree for a runtime interpreter.
    (<-- (%emit-pattern ?pattern ?matcher)
        (lisp ?value (%fresh-code-symbol "MATCH"))
        (%emit-matcher ?pattern ?value ?body)
        (= ?matcher (lambda (?value) (declare (ignorable ?value)) ?body)))
    (<-- (%emit-matcher (:p-wildcard ?span ?type ?bindings) ?value nil) !)
    (<- (%emit-matcher (:p-unit ?span ?type ?bindings) ?value
                        (if (sml-equal ?value +unit+) nil +no-match+)) !)
    (<- (%emit-matcher (:p-literal ?span ?type ?bindings ?literal) ?value
                        (if (sml-equal ?value ?literal-code) nil +no-match+))
        ! (%emit-literal ?literal ?literal-code))
    (<- (%emit-matcher (:p-variable ?span ?type ?bindings ?name ?host) ?value
                        (list (cons (quote ?host) ?value))) !)
    (<- (%emit-matcher (:p-typed ?span ?type ?bindings ?inner) ?value ?code)
        ! (%emit-matcher ?inner ?value ?code))
    (<- (%emit-matcher (:p-constructor ?span ?type ?bindings ?identity ?symbol 0 ?argument) ?value ?code)
        ! (%emit-nullary-constructor-matcher ?identity ?value ?code))
    (<- (%emit-matcher (:p-constructor ?span ?type ?bindings ?identity ?symbol 1 ?argument) ?value ?code)
        ! (%emit-unary-constructor-matcher ?identity ?argument ?value ?code))
    (<- (%emit-matcher (:p-list-nil ?span ?type ?bindings ?identity) ?value ?code)
        ! (%emit-nullary-constructor-matcher ?identity ?value ?code))
    (<- (%emit-matcher (:p-list-cons ?span ?type ?bindings ?identity ?head ?tail) ?value ?code)
        ! (= ?payload (:p-record ?span ?payload-type ?payload-bindings
                                 ((:p-row "1" ?head) (:p-row "2" ?tail))))
        (%emit-unary-constructor-matcher ?identity ?payload ?value ?code))
    (<- (%emit-matcher (:p-record ?span ?type ?bindings ?rows) ?value
                        (if (or (eq ?value +unit+) (sml-record-p ?value)) ?rows-code +no-match+))
        ! (%emit-record-matchers ?rows ?value ?rows-code))
    (<- (%emit-matcher (:p-layered ?span ?type ?bindings ?name ?host ?inner) ?value ?code)
        ! (%emit-pattern ?inner ?matcher)
        (lisp ?frame (%fresh-code-symbol "LAYER"))
        (= ?code (let ((?frame (funcall ?matcher ?value)))
                   (if (eq ?frame +no-match+) +no-match+
                       (append (list (cons (quote ?host) ?value)) ?frame)))))
    (<-- (%emit-nullary-constructor-matcher ?identity ?value ?code)
        (lisp ?payload (%fresh-code-symbol "PAYLOAD"))
        (lisp ?present (%fresh-code-symbol "PRESENT"))
        (= ?code (multiple-value-bind (?payload ?present) (constructor-payload-if ?value)
                   (declare (ignore ?payload))
                   (if (and ?present (eq (constructor-identity ?value) (quote ?identity)))
                       nil +no-match+))))
    (<-- (%emit-unary-constructor-matcher ?identity ?argument ?value ?code)
        (%emit-pattern ?argument ?matcher)
        (lisp ?payload (%fresh-code-symbol "PAYLOAD"))
        (lisp ?present (%fresh-code-symbol "PRESENT"))
        (lisp ?frame (%fresh-code-symbol "FRAME"))
        (= ?code (multiple-value-bind (?payload ?present) (constructor-payload-if ?value)
                   (if (and ?present (eq (constructor-identity ?value) (quote ?identity)))
                       (let ((?frame (funcall ?matcher ?payload)))
                         (if (eq ?frame +no-match+) +no-match+ ?frame))
                       +no-match+))))
    (<-- (%emit-record-matchers nil ?value nil) !)
    (<- (%emit-record-matchers ((:p-row ?label ?pattern) . ?rows) ?value ?code)
        (%emit-pattern ?pattern ?matcher)
        (lisp ?frame (%fresh-code-symbol "FIELD"))
        (lisp ?rest (%fresh-code-symbol "FIELDS"))
        (%emit-record-matchers ?rows ?value ?rest-code)
        (= ?code (let ((?frame (funcall ?matcher (sml-record-field ?value ?label))))
                   (if (eq ?frame +no-match+) +no-match+
                       (let ((?rest ?rest-code))
                         (if (eq ?rest +no-match+) +no-match+
                             (append ?frame ?rest)))))))
    (<- (%emit-record-matchers (?pattern . ?patterns) ?value ?code)
        ;; Compatibility with tuple-shaped semantic rows.
        (%emit-record-matchers ((:p-row "1" ?pattern) . ?patterns) ?value ?code))

    ;;; Ordered match rules.  Only an explicit pattern non-match selects the
    ;;; successor.  Once matched, the body commits with the original outer
    ;;; continuation; no body result or host condition can reopen dispatch.
    (<-- (%emit-rules (:rules nil) ?values ?lexicals ?failure ?code)
        (%emit-rule-list nil ?values ?lexicals ?failure ?code))
    (<- (%emit-rules (:rules (?first . ?rest)) ?values ?lexicals ?failure ?code)
        (= ?rules (?first . ?rest))
        (lisp ?code (%emit-rules-partitioned ?rules ?values ?lexicals ?failure)))

    ;;; Every head completes, including nested rule groups in its body, before
    ;;; the next source head.  Descriptors carry immutable source/body data to
    ;;; the reverse finish phase; they do not represent an evaluator.
    (<-- (%emit-rule-head (:rule ?pattern ?expression) (?value) ?lexicals
                          (:ordinary-head ?pattern ?bindings ?body ?value))
        ! (%pattern-bindings ?pattern ?bindings)
        (%binder-hosts ?bindings ?hosts)
        (%append ?hosts ?lexicals ?inner-lexicals)
        (%emit-expression ?expression ?inner-lexicals ?body))
    (<- (%emit-rule-head (:fc ?patterns ?expression) ?values ?lexicals
                         (:function-head ?patterns ?bindings ?body ?values))
        (%function-rule-bindings ?patterns ?bindings)
        (%binder-hosts ?bindings ?hosts)
        (%append ?hosts ?lexicals ?inner-lexicals)
        (%emit-expression ?expression ?inner-lexicals ?body))
    ;; The caller selects this only for the proper final singleton FC.  Its
    ;; leading cut belongs before FUNCTION-RULE-BINDINGS, as in the reference;
    ;; generic nonfinal FC heads deliberately remain uncut.
    (<-- (%emit-final-function-head
          (:fc ?patterns ?expression) ?values ?lexicals
          (:function-head ?patterns ?bindings ?body ?values))
        ! (%function-rule-bindings ?patterns ?bindings)
        (%binder-hosts ?bindings ?hosts)
        (%append ?hosts ?lexicals ?inner-lexicals)
        (%emit-expression ?expression ?inner-lexicals ?body))

    (<-- (%emit-ordinary-finish
          (:ordinary-head ?pattern ?bindings ?body ?value)
          (?value) ?lexicals ?rest ?code)
        (%emit-pattern ?pattern ?pattern-matcher)
        (lisp ?frame (%fresh-code-symbol "RULE"))
        (%emit-frame-bindings ?bindings ?frame ?body ?body-with-bindings)
        (= ?matcher (funcall ?pattern-matcher ?value))
        (= ?code (sml-or (sml-native-rule (?value . ?lexicals)
                                          ?matcher ?frame ?body-with-bindings)
                         ?rest)))
    (<-- (%emit-final-ordinary-finish
          (:ordinary-head ?pattern ?bindings ?body ?value)
          (?value) ?lexicals ?failure ?rest ?code)
        ;; This is the original terminal recursion, not an invented empty
        ;; successor.  The independent suffix is spliced at ?REST afterward.
        (%emit-rule-list nil (?value) ?lexicals ?failure ?failure)
        (%emit-pattern ?pattern ?pattern-matcher)
        (lisp ?frame (%fresh-code-symbol "RULE"))
        (%emit-frame-bindings ?bindings ?frame ?body ?body-with-bindings)
        (= ?matcher (funcall ?pattern-matcher ?value))
        (= ?code (sml-or (sml-native-rule (?value . ?lexicals)
                                          ?matcher ?frame ?body-with-bindings)
                         ?rest)))
    (<-- (%emit-function-finish
          (:function-head ?patterns ?bindings ?body ?values)
          ?values ?lexicals ?rest ?code)
        (%append ?values ?lexicals ?native-captures)
        (%emit-multi-matcher ?patterns ?values ?matcher)
        (lisp ?frame (%fresh-code-symbol "RULE"))
        (%emit-frame-bindings ?bindings ?frame ?body ?body-with-bindings)
        (= ?code (sml-or (sml-native-rule ?native-captures
                                          ?matcher ?frame ?body-with-bindings)
                         ?rest)))
    (<-- (%emit-final-function-finish
          (:function-head ?patterns ?bindings ?body ?values)
          ?values ?lexicals ?rest ?code)
        (%emit-multi-matcher ?patterns ?values ?matcher)
        (lisp ?frame (%fresh-code-symbol "RULE"))
        (%emit-frame-bindings ?bindings ?frame ?body ?body-with-bindings)
        (lisp ?direct (%irrefutable-pattern-list-p ?patterns))
        (%append ?values ?lexicals ?native-captures)
        (or (-> (= ?direct t)
                (= ?code (let ((?frame ?matcher)) ?body-with-bindings)))
            (= ?code (sml-or (sml-native-rule ?native-captures
                                              ?matcher ?frame ?body-with-bindings)
                             ?rest))))

    ;;; Complete public reference retained with its original parent dispatch,
    ;;; cuts, field order and recursive operation ordering for comparison.
    (<-- (%emit-rule-list nil ?values ?lexicals ?failure ?failure) !)
    (<- (%emit-rule-list ((:rule ?pattern ?expression) . ?rules) (?value) ?lexicals ?failure ?code)
        ! (%pattern-bindings ?pattern ?bindings)
        (%binder-hosts ?bindings ?hosts)
        (%append ?hosts ?lexicals ?inner-lexicals)
        (%emit-expression ?expression ?inner-lexicals ?body)
        (%emit-rule-list ?rules (?value) ?lexicals ?failure ?rest)
        (%emit-pattern ?pattern ?pattern-matcher)
        (lisp ?frame (%fresh-code-symbol "RULE"))
        (%emit-frame-bindings ?bindings ?frame ?body ?body-with-bindings)
        (= ?matcher (funcall ?pattern-matcher ?value))
        (= ?code (sml-or (sml-native-rule (?value . ?lexicals)
                                          ?matcher ?frame ?body-with-bindings)
                         ?rest)))
    (<- (%emit-rule-list ((:fc ?patterns ?expression)) ?values ?lexicals ?failure ?code)
        ! (%function-rule-bindings ?patterns ?bindings)
        (%binder-hosts ?bindings ?hosts)
        (%append ?hosts ?lexicals ?inner-lexicals)
        (%emit-expression ?expression ?inner-lexicals ?body)
        (%emit-multi-matcher ?patterns ?values ?matcher)
        (lisp ?frame (%fresh-code-symbol "RULE"))
        (%emit-frame-bindings ?bindings ?frame ?body ?body-with-bindings)
        (lisp ?direct (%irrefutable-pattern-list-p ?patterns))
        (%append ?values ?lexicals ?native-captures)
        (or (-> (= ?direct t)
                (= ?code (let ((?frame ?matcher)) ?body-with-bindings)))
            (= ?code (sml-or (sml-native-rule ?native-captures
                                              ?matcher ?frame ?body-with-bindings)
                             ?failure))))
    (<- (%emit-rule-list ((:fc ?patterns ?expression) . ?rules) ?values ?lexicals ?failure ?code)
        (%function-rule-bindings ?patterns ?bindings)
        (%binder-hosts ?bindings ?hosts)
        (%append ?hosts ?lexicals ?inner-lexicals)
        (%emit-expression ?expression ?inner-lexicals ?body)
        (%emit-rule-list ?rules ?values ?lexicals ?failure ?rest)
        (%append ?values ?lexicals ?native-captures)
        (%emit-multi-matcher ?patterns ?values ?matcher)
        (lisp ?frame (%fresh-code-symbol "RULE"))
        (%emit-frame-bindings ?bindings ?frame ?body ?body-with-bindings)
        (= ?code (sml-or (sml-native-rule ?native-captures
                                          ?matcher ?frame ?body-with-bindings)
                         ?rest)))
    (<-- (%emit-multi-matcher nil nil nil) !)
    (<- (%emit-multi-matcher (?pattern . ?patterns) (?value . ?values) ?code)
        (%emit-pattern ?pattern ?pattern-matcher)
        (%emit-multi-matcher ?patterns ?values ?rest-matcher)
        (lisp ?frame (%fresh-code-symbol "ARGUMENT"))
        (lisp ?rest (%fresh-code-symbol "ARGUMENTS"))
        (= ?code (let ((?frame (funcall ?pattern-matcher ?value)))
                   (if (eq ?frame +no-match+) +no-match+
                       (let ((?rest ?rest-matcher))
                         (if (eq ?rest +no-match+) +no-match+
                             (append ?frame ?rest)))))))
    (<-- (%emit-frame-bindings nil ?frame ?body ?body) !)
    (<- (%emit-frame-bindings ((:bind ?name ?type ?host) . ?bindings) ?frame ?body ?form)
        (%emit-frame-bindings ?bindings ?frame ?body ?rest)
        (= ?form (let ((?host (binding-value (quote ?host) ?frame))) ?rest)))
    (<-- (%binder-hosts nil nil) !)
    (<- (%binder-hosts ((:bind ?name ?type ?host) . ?bindings) (?host . ?hosts))
        (%binder-hosts ?bindings ?hosts))
    (<-- (%function-rule-bindings nil nil) !)
    (<- (%function-rule-bindings (?pattern . ?patterns) ?bindings)
        (%pattern-bindings ?pattern ?first)
        (%function-rule-bindings ?patterns ?rest)
        (%append ?first ?rest ?bindings))
    (<-- (%pattern-bindings (:p-wildcard ?span ?type ?bindings) ?bindings) !)
    (<- (%pattern-bindings (:p-unit ?span ?type ?bindings) ?bindings) !)
    (<- (%pattern-bindings (:p-literal ?span ?type ?bindings ?literal) ?bindings) !)
    (<- (%pattern-bindings (:p-variable ?span ?type ?bindings ?name ?host) ?bindings) !)
    (<- (%pattern-bindings (:p-constructor ?span ?type ?bindings ?identity ?symbol ?arity ?argument) ?bindings) !)
    (<- (%pattern-bindings (:p-record ?span ?type ?bindings ?rows) ?bindings) !)
    (<- (%pattern-bindings (:p-typed ?span ?type ?bindings ?inner) ?bindings) !)
    (<- (%pattern-bindings (:p-layered ?span ?type ?bindings ?name ?host ?inner) ?bindings) !)
    (<- (%pattern-bindings (:p-list-nil ?span ?type ?bindings ?identity) ?bindings) !)
    (<- (%pattern-bindings (:p-list-cons ?span ?type ?bindings ?identity ?head ?tail) ?bindings) !)

    ;;; Only the innermost Curry closure executes a rule body; outer closures
    ;;; still return raw curried functions as ordinary SML values.  Recursive
    ;;; definitions below use fresh lexical value cells for recursion;
    ;;; nested SML-FUNCTION closures retain Curry partial application.  Their
    ;;; registration occurs once when each recursive factory is initialized.
    (<-- (%emit-one-argument-function ?rules ?lexicals ?lambda)
        (lisp ?argument (%fresh-code-symbol "ARG"))
        (%emit-rules ?rules (?argument) ?lexicals (raise-sml +match-exception+) ?body)
        (= ?lambda (sml-function (?argument) (sml-enter (sml-code ?body)))))
    (<-- (%emit-function (:fb ?name ?host ?type ?rules) ?lexicals ?lambda)
        (%function-rule-arity ?rules ?arity)
        (%fresh-variables ?arity ?arguments)
        (%emit-rules (:rules ?rules) ?arguments ?lexicals (raise-sml +match-exception+) ?body)
        (%curry-lambdas ?arguments ?body ?lambda))
    (<-- (%function-rule-arity ((:fc ?patterns ?expression) . ?rules) ?arity)
        (%list-length ?patterns ?arity))
    (<-- (%list-length nil 0) !)
    (<- (%list-length (?head . ?tail) ?length)
        (%list-length ?tail ?rest) (is ?length (+ ?rest 1)))
    (<-- (%fresh-variables 0 nil) !)
    (<- (%fresh-variables ?count (?symbol . ?symbols))
        (is ?next (- ?count 1))
        (lisp ?symbol (%fresh-code-symbol "ARG"))
        (%fresh-variables ?next ?symbols))
    (<-- (%curry-lambdas nil ?body (sml-enter (sml-code ?body))) !)
    (<- (%curry-lambdas (?argument . ?arguments) ?body (sml-function (?argument) ?nested))
        (%curry-lambdas ?arguments ?body ?nested))

    ;;; Declaration interfaces describe only lexical visibility and dynamic
    ;;; updates.  Evaluation order is established by the nested wrappers below.
    (<-- (%items-interface nil ?lexicals ?lexicals nil) !)
    (<- (%items-interface (?item . ?items) ?lexicals ?final ?updates)
        (%declaration-interface ?item ?lexicals ?next ?first)
        (%items-interface ?items ?next ?final ?rest)
        (%append ?first ?rest ?updates))
    (<- (%declaration-interface (:d-value ?span ?recursive ?bindings) ?lexicals ?next ?hosts)
        (%value-binding-hosts ?bindings ?hosts)
        (%append ?hosts ?lexicals ?next))
    (<- (%declaration-interface (:d-mixed-value ?span ?ordinary ?recursive) ?lexicals ?next ?hosts)
        (%value-binding-hosts ?ordinary ?ordinary-hosts)
        (%value-binding-hosts ?recursive ?recursive-hosts)
        (%append ?ordinary-hosts ?recursive-hosts ?hosts)
        (%append ?hosts ?lexicals ?next))
    (<- (%declaration-interface (:d-functions ?span ?bindings) ?lexicals ?next ?hosts)
        (%function-binding-hosts ?bindings ?hosts)
        (%append ?hosts ?lexicals ?next))
    (<- (%declaration-interface (:d-datatype ?span ?constructors) ?lexicals ?next ?hosts)
        (%constructor-hosts ?constructors ?hosts)
        (%append ?hosts ?lexicals ?next))
    (<- (%declaration-interface (:d-replication ?span ?copies) ?lexicals ?next ?hosts)
        (%replication-hosts ?copies ?hosts)
        (%append ?hosts ?lexicals ?next))
    (<- (%declaration-interface (:d-exceptions ?span ?constructors ?aliases) ?lexicals ?next ?hosts)
        (%constructor-hosts ?constructors ?first)
        (%exception-alias-hosts ?aliases ?second)
        (%append ?first ?second ?hosts)
        (%append ?hosts ?lexicals ?next))
    (<- (%declaration-interface (:d-expression ?name ?host ?expression) ?lexicals (?host . ?lexicals) (?host)))
    (<- (%declaration-interface (:d-local ?span ?local ?body) ?lexicals ?next ?updates)
        (%items-interface ?body ?lexicals ?next ?updates))
    (<- (%declaration-interface (:d-abstype ?span ?datatype ?hidden ?body) ?lexicals ?next ?visible)
        (%items-interface ?body ?lexicals ?with-datatype ?updates)
        (%remove-symbols ?updates ?hidden ?visible)
        (%append ?visible ?lexicals ?next))
    (<- (%declaration-interface (:d-sequence ?items) ?lexicals ?next ?updates)
        (%items-interface ?items ?lexicals ?next ?updates))
    (<- (%declaration-interface (:d-type) ?lexicals ?lexicals nil) !)
    (<- (%declaration-interface (:d-fixity) ?lexicals ?lexicals nil) !)
    (<- (%declaration-interface (:d-open) ?lexicals ?lexicals nil) !)
    (<-- (%value-binding-hosts nil nil) !)
    (<- (%value-binding-hosts ((:vb ?pattern ?expression) . ?bindings) ?hosts)
        (%pattern-bindings ?pattern ?binders)
        (%binder-hosts ?binders ?first)
        (%value-binding-hosts ?bindings ?rest)
        (%append ?first ?rest ?hosts))
    (<-- (%function-binding-hosts nil nil) !)
    (<- (%function-binding-hosts ((:fb ?name ?host ?type ?rules) . ?bindings) (?host . ?hosts))
        (%function-binding-hosts ?bindings ?hosts))
    (<-- (%constructor-hosts nil nil) !)
    (<- (%constructor-hosts ((:dc ?name ?host ?identity ?arity ?exception) . ?constructors) (?host . ?hosts))
        (%constructor-hosts ?constructors ?hosts))
    (<-- (%replication-hosts nil nil) !)
    (<- (%replication-hosts ((:rc ?name ?host ?source ?scheme ?status) . ?copies) (?host . ?hosts))
        (%replication-hosts ?copies ?hosts))
    (<-- (%exception-alias-hosts nil nil) !)
    (<- (%exception-alias-hosts ((:ea ?name ?host ?source) . ?aliases) (?host . ?hosts))
        (%exception-alias-hosts ?aliases ?hosts))

    ;;; Top-level wrappers end in two values: the last interactive expression
    ;;; (or unit), and exactly the bindings exported by this compilation.
    (<-- (%emit-items nil ?lexicals nil ?updates ?updates
                      (values +unit+ (list . ?update-forms)))
        (%emit-updates ?updates ?update-forms))
    (<- (%emit-items nil ?lexicals ?result ?updates ?updates
                     (values ?result (list . ?update-forms)))
        (%emit-updates ?updates ?update-forms))
    (<- (%emit-items (?item . ?items) ?lexicals ?result ?collected ?updates ?form)
        (%declaration-interface ?item ?lexicals ?next ?first)
        (%append ?collected ?first ?next-collected)
        (%emit-items ?items ?next ?result ?next-collected ?updates ?rest)
        (%emit-declaration ?item ?lexicals ?rest ?form))
    (<-- (%emit-updates nil nil) !)
    (<- (%emit-updates (?host . ?hosts) ((cons (quote ?host) ?host) . ?updates))
        (%emit-updates ?hosts ?updates))

    (<-- (%emit-local-items nil ?lexicals ?body ?body) !)
    (<- (%emit-local-items (?item . ?items) ?lexicals ?body ?form)
        (%declaration-interface ?item ?lexicals ?next ?updates)
        (%emit-local-items ?items ?next ?body ?rest)
        (%emit-declaration ?item ?lexicals ?rest ?form))
    (<-- (%emit-declaration (:d-value ?span nil ?bindings) ?lexicals ?body ?form)
        ! (%emit-value-bindings ?bindings ?lexicals ?body ?form))
    (<- (%emit-declaration (:d-value ?span t ?bindings) ?lexicals ?body ?form)
        ! (%recursive-hosts ?bindings ?hosts)
        (%function-markers ?hosts ?markers)
        (%append ?markers ?lexicals ?recursive-lexicals)
        (%emit-recursive-definitions ?bindings ?recursive-lexicals ?definitions)
        (%uninitialized-bindings ?hosts ?host-bindings)
        (lisp ?factory (%factory-initializer ?hosts ?definitions ?lexicals))
        (= ?form (let ?host-bindings ?factory ?body)))
    (<- (%emit-declaration (:d-mixed-value ?span ?ordinary ?recursive) ?lexicals ?body ?form)
        ! (%recursive-hosts ?recursive ?hosts)
        (%function-markers ?hosts ?markers)
        ;; Recursive RHS closures precede the ordinary mixed AND bindings;
        ;; ordinary declarations therefore must not enter their capture scope.
        (%append ?markers ?lexicals ?recursive-lexicals)
        (%emit-recursive-definitions ?recursive ?recursive-lexicals ?definitions)
        (%uninitialized-bindings ?hosts ?host-bindings)
        (lisp ?factory (%factory-initializer ?hosts ?definitions ?lexicals))
        (%emit-value-bindings ?ordinary ?lexicals ?body ?ordinary-form)
        (= ?form (let ?host-bindings ?factory ?ordinary-form)))
    (<- (%emit-declaration (:d-functions ?span ?bindings) ?lexicals ?body ?form)
        ! (%function-binding-hosts ?bindings ?hosts)
        (%function-markers ?hosts ?markers)
        (%append ?markers ?lexicals ?recursive-lexicals)
        (%emit-function-definitions ?bindings ?recursive-lexicals ?definitions)
        (%uninitialized-bindings ?hosts ?host-bindings)
        (lisp ?factory (%factory-initializer ?hosts ?definitions ?lexicals))
        (= ?form (let ?host-bindings ?factory ?body)))
    (<-- (%uninitialized-bindings nil nil) !)
    (<- (%uninitialized-bindings (?host . ?hosts) ((?host nil) . ?bindings))
        (%uninitialized-bindings ?hosts ?bindings))
    (<- (%emit-declaration (:d-datatype ?span ?constructors) ?lexicals ?body ?form)
        ! (%constructor-hosts ?constructors ?hosts)
        (%emit-constructor-bindings ?constructors ?bindings)
        (= ?form (let ?bindings ?body)))
    (<- (%emit-declaration (:d-replication ?span ?copies) ?lexicals ?body ?form)
        ! (%replication-hosts ?copies ?hosts)
        (%emit-replication-bindings ?copies ?lexicals ?bindings)
        (= ?form (let ?bindings ?body)))
    (<- (%emit-declaration (:d-exceptions ?span ?constructors ?aliases) ?lexicals ?body ?form)
        ! (%constructor-hosts ?constructors ?first-hosts)
        (%exception-alias-hosts ?aliases ?second-hosts)
        (%append ?first-hosts ?second-hosts ?hosts)
        (%emit-constructor-bindings ?constructors ?first)
        (%emit-exception-alias-bindings ?aliases ?lexicals ?second)
        (%append ?first ?second ?bindings)
        (= ?form (let ?bindings ?body)))
    (<- (%emit-declaration (:d-expression ?name ?host ?expression) ?lexicals ?body
                           (let ((?host ?code)) ?body))
        ! (%emit-expression ?expression ?lexicals ?code))
    (<- (%emit-declaration (:d-type) ?lexicals ?body ?body) !)
    (<- (%emit-declaration (:d-fixity) ?lexicals ?body ?body) !)
    (<- (%emit-declaration (:d-open) ?lexicals ?body ?body) !)
    (<- (%emit-declaration (:d-sequence ?items) ?lexicals ?body ?form)
        ! (%emit-local-items ?items ?lexicals ?body ?form))
    (<- (%emit-declaration (:d-local ?span ?local ?body-items) ?lexicals ?body ?form)
        ! (%items-interface ?local ?lexicals ?local-lexicals ?ignored)
        (%items-interface ?body-items ?local-lexicals ?inner-lexicals ?updates)
        (%emit-local-items ?body-items ?local-lexicals ?body ?body-form)
        (%emit-local-items ?local ?lexicals ?body-form ?form))
    (<- (%emit-declaration (:d-abstype ?span ?datatype ?hidden ?body-items) ?lexicals ?body ?form)
        ! (%declaration-interface ?datatype ?lexicals ?datatype-lexicals ?ignored)
        (%items-interface ?body-items ?datatype-lexicals ?inner-lexicals ?updates)
        (%emit-local-items ?body-items ?datatype-lexicals ?body ?body-form)
        (%emit-declaration ?datatype ?lexicals ?body-form ?form))

    (<-- (%emit-value-bindings nil ?lexicals ?body ?body) !)
    (<- (%emit-value-bindings ((:vb ?pattern ?expression) . ?bindings) ?lexicals ?body ?form)
        (%pattern-bindings ?pattern ?binders)
        (%binder-hosts ?binders ?hosts)
        (%append ?hosts ?lexicals ?inner)
        (%emit-value-bindings ?bindings ?inner ?body ?rest)
        (%emit-expression ?expression ?lexicals ?value)
        (%emit-pattern ?pattern ?matcher)
        (%emit-frame-bindings ?binders ?frame ?rest ?continuation-body)
        (lisp ?frame (%fresh-code-symbol "VALUE"))
        (= ?form (let ((?frame (funcall ?matcher ?value)))
                   (if (eq ?frame +no-match+) (raise-sml +bind-exception+)
                       ?continuation-body))))
    (<-- (%recursive-hosts nil nil) !)
    (<- (%recursive-hosts ((:vb (:p-variable ?span ?type ?binders ?name ?host) ?expression) . ?bindings) (?host . ?hosts))
        (%recursive-hosts ?bindings ?hosts))
    (<-- (%emit-recursive-definitions nil ?lexicals nil) !)
    (<- (%emit-recursive-definitions ((:vb (:p-variable ?span ?type ?binders ?name ?host) ?expression) . ?bindings)
                                     ?lexicals ((?host (?argument) ?body) . ?definitions))
        (%emit-expression ?expression ?lexicals (sml-function (?argument) ?body))
        (%emit-recursive-definitions ?bindings ?lexicals ?definitions))
    (<-- (%emit-function-definitions nil ?lexicals nil) !)
    (<- (%emit-function-definitions ((:fb ?name ?host ?type ?rules) . ?bindings) ?lexicals
                                    ((?host (?argument) ?body) . ?definitions))
        (%emit-function (:fb ?name ?host ?type ?rules) ?lexicals (sml-function (?argument) ?body))
        (%emit-function-definitions ?bindings ?lexicals ?definitions))
    (<-- (%emit-constructor-bindings nil nil) !)
    (<- (%emit-constructor-bindings ((:dc ?name ?host ?identity 0 nil) . ?constructors)
                                    ((?host (make-sml-nullary-constructor ?name (quote ?identity))) . ?bindings))
        (%emit-constructor-bindings ?constructors ?bindings))
    (<- (%emit-constructor-bindings ((:dc ?name ?host ?identity 1 nil) . ?constructors)
                                    ((?host (make-sml-constructor ?name (quote ?identity))) . ?bindings))
        (%emit-constructor-bindings ?constructors ?bindings))
    (<- (%emit-constructor-bindings ((:dc ?name ?host ?identity 0 t) . ?constructors)
                                    ((?host (make-sml-nullary-constructor ?name (quote ?identity))) . ?bindings))
        (%emit-constructor-bindings ?constructors ?bindings))
    (<- (%emit-constructor-bindings ((:dc ?name ?host ?identity 1 t) . ?constructors)
                                    ((?host (make-sml-constructor ?name (quote ?identity))) . ?bindings))
        (%emit-constructor-bindings ?constructors ?bindings))
    (<-- (%emit-replication-bindings nil ?lexicals nil) !)
    (<- (%emit-replication-bindings ((:rc ?name ?host ?source ?scheme ?status) . ?copies) ?lexicals
                                    ((?host ?source-code) . ?bindings))
        (%emit-variable ?source ?lexicals ?source-code)
        (%emit-replication-bindings ?copies ?lexicals ?bindings))
    (<-- (%emit-exception-alias-bindings nil ?lexicals nil) !)
    (<- (%emit-exception-alias-bindings ((:ea ?name ?host ?source) . ?aliases) ?lexicals
                                        ((?host ?source-code) . ?bindings))
        (%emit-variable ?source ?lexicals ?source-code)
        (%emit-exception-alias-bindings ?aliases ?lexicals ?bindings))

    ;;; Exporting the DCG entry is intentional: callers can inspect or compile
    ;;; the native term, but cannot execute an unelaborated parser AST here.
    (--> (emit-program (:program-items ?items ?program-result) ?code)
         (do (%trailing-result ?items ?host)
             (%emit-items ?items nil ?host nil ?updates ?body)
             (= ?code (lambda/c (%environment)
                        (declare (ignorable %environment)) ?body))))
    (<-- (%trailing-result nil nil) !)
    (<- (%trailing-result ((:d-expression ?name ?host ?expression)) ?host) !)
    (<- (%trailing-result (?item) nil) !)
    (<- (%trailing-result (?item . ?items) ?host) (%trailing-result ?items ?host))
    database))
