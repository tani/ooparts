(uiop:define-package #:ooparts-tests/sml/types
  (:use #:cl)
  (:import-from #:ooparts/prolog
    #:*database* #:<-- #:make-database #:make-query #:query
    #:next-solution #:close-query)
  (:import-from #:ooparts/sml/types
    #:make-type-name #:make-types-database #:install-type-predicates
    #:type-name #:type-var #:=> #:@ #:record #:field #:scheme
    #:type-function #:realization #:name-map #:variable-map #:type-env #:binding
    #:type-variable #:equality-type-variable #:row-variable #:arrow-type
    #:type-application #:record-type #:record-field #:well-formed-type
    #:type-unify #:ensure-equality #:type-equality
    #:free-type-variables #:free-type-names #:generalize-type
    #:instantiate-type-scheme #:substitute-type-variables
    #:apply-type-function #:realize-type #:substitute-type-names
    #:empty-type-environment #:extend-type-environment
    #:lookup-type-environment #:require-type-environment #:render-type
    #:sml-type-error #:malformed-type-error #:cyclic-type-error
    #:occurs-check-error #:occurs-check-error-variable #:kind-mismatch-error
    #:arity-mismatch-error #:arity-mismatch-error-name
    #:arity-mismatch-error-expected #:arity-mismatch-error-actual
    #:unification-error #:type-name-unification-error #:equality-type-error
    #:record-conflict-error #:record-conflict-error-label
    #:duplicate-record-label-error #:row-tail-conflict-error
    #:unbound-identifier-error #:unbound-identifier-error-identifier
    #:type-error-left #:type-error-right)
  (:import-from #:ooparts/sml/elaborate
    #:install-elaboration-predicates #:freeze-type #:thaw-type)
  (:import-from #:ooparts/sml/runtime #:+reference-identity+)
  (:import-from #:ooparts/test #:with-suite #:is #:signals)
  (:export #:run-type-tests))
(in-package #:ooparts-tests/sml/types)

(defun %name (spelling arity &key (equality :equality) (flexibility :flexible)
                                  identity)
  (make-type-name spelling arity :equality equality :flexibility flexibility
                  :identity identity))

(defun %tv (cell equality)
  (list 'type-var cell :type equality))

(defun %rv (cell equality)
  (list 'type-var cell :row equality))

(defun %app (name &rest arguments)
  (list '@ name arguments))

(defun %arrow (domain result)
  (list '=> domain result))

(defun %field (label type)
  (list 'field label type))

(defun %record (fields &optional (tail :closed))
  (list 'record fields tail))

(defun %query (database goals)
  (query goals :database database))

(defun %one (database &rest goals)
  (let ((answers (%query database goals)))
    (is (= 1 (length answers)) () "Expected one answer for ~S, got ~S"
        goals answers)
    (first answers)))

(defun %ground-success (database &rest goals)
  (let ((answers (%query database goals)))
    (is (equal '(nil) answers) () "Expected ground success for ~S, got ~S"
        goals answers)
    answers))

(defun %failure (database &rest goals)
  (is (null (%query database goals)) () "Expected query failure for ~S" goals))

(defun %binding (variable solution)
  (let ((entry (assoc variable solution)))
    (is entry () "No binding for ~S in ~S" variable solution)
    (cdr entry)))

(defun %capture-type-error (thunk)
  (handler-case
      (progn
        (funcall thunk)
        (is nil () "Expected an SML type condition")
        nil)
    (sml-type-error (condition) condition)))

(defun %record-fields (record)
  (second record))

(defun %record-tail (record)
  (third record))

(defun %named-field (record label)
  (find label (%record-fields record) :test #'equal :key #'second))

(defun %construction-tests ()
  (let* ((database (make-types-database))
         (int-name (%name "int" 0))
         (same-spelling (%name "int" 0))
         (list-name (%name "list" 1))
         (int (%app int-name))
         (list-int (%app list-name int)))
    (let ((answer
            (%one database
              `(= ?int-name ,int-name)
              `(= ?same-name ,same-spelling)
              `(= ?list-name ,list-name))))
      (let ((observed-int (%binding '?int-name answer))
            (observed-same (%binding '?same-name answer))
            (observed-list (%binding '?list-name answer)))
        (is (eq 'type-name (first observed-int)))
        (is (= 6 (length observed-int)))
        (is (string= "int" (second observed-int)))
        (is (third observed-int))
        (is (zerop (fourth observed-int)))
        (is (eq :equality (fifth observed-int)))
        (is (eq :flexible (sixth observed-int)))
        (is (= 1 (fourth observed-list)))
        (is (not (equal (third observed-int) (third observed-same))))))

    (let* ((answer
             (%one database
               '(type-variable :type ?ordinary)
               '(= ?ordinary (type-var ?cell :type ?attribute))
               '(var ?cell)
               '(var ?attribute)))
           (ordinary (%binding '?ordinary answer)))
      (is (eq 'type-var (first ordinary)))
      (is (= 4 (length ordinary)))
      (is (eq :type (third ordinary))))
    (let ((answer
            (%one database
              '(row-variable ?row)
              '(= ?row (type-var ?cell :row ?attribute))
              '(var ?cell)
              '(var ?attribute))))
      (is (eq :row (third (%binding '?row answer)))))

    (let* ((higher (%arrow list-int (%arrow int list-int)))
           (fields (list (%field "a" int) (%field "items" list-int)))
           (answer
             (%one database
               `(arrow-type ,list-int ,higher ?arrow)
               `(type-application ,list-name (,int) ?application)
               `(record-type ,fields :closed ?record))))
      (is (equal (%arrow list-int higher) (%binding '?arrow answer)))
      (is (equal list-int (%binding '?application answer)))
      (let ((record (%binding '?record answer)))
        (is (eq 'record (first record)))
        (is (= 2 (length (%record-fields record))))
        (is (eq :closed (%record-tail record)))
        (is (equal int (third (%named-field record "a"))))
        (is (equal list-int (third (%named-field record "items")))))

    (%ground-success database `(well-formed-type ,higher)))
    (let ((alias (make-type-name "integer" 0 :equality :equality
                                 :identity (third int-name))))
      (%ground-success database
        `(type-unify ,int ,(%app alias))))

    (signals arity-mismatch-error
      (%query database `((type-application ,list-name nil ?out))))
    (signals arity-mismatch-error
      (%query database `((type-application ,list-name (,int ,int) ?out))))
    (let ((condition
            (%capture-type-error
             (lambda ()
               (%query database
                       `((type-application ,list-name nil ?out)))))))
      (is (typep condition 'arity-mismatch-error))
      (when (typep condition 'arity-mismatch-error)
        (is (equal "list" (arity-mismatch-error-name condition)))
        (is (= 1 (arity-mismatch-error-expected condition)))
        (is (= 0 (arity-mismatch-error-actual condition)))))
    (signals malformed-type-error
      (%query database `((well-formed-type (=> ,int)))))))

(defun %unification-tests ()
  (let* ((database (make-types-database))
         (int (%app (%name "int" 0)))
         (bool (%app (%name "bool" 0)))
         (list-name (%name "list" 1))
         (list-int (%app list-name int)))
    (%ground-success database `(type-unify ,list-int ,list-int))

    (let* ((argument (%tv '?argument '?argument-equality))
           (answer (%one database `(type-unify ,argument ,int))))
      (is (equal int (%binding '?argument answer))))
    (let* ((a (%tv '?a '?ae))
           (b (%tv '?b '?be))
           (c (%tv '?c '?ce))
           (left (%arrow (%app list-name a) (%arrow int b)))
           (right (%arrow list-int (%arrow c bool)))
           (answer (%one database `(type-unify ,left ,right))))
      (is (equal int (%binding '?a answer)))
      (is (equal int (%binding '?c answer)))
      (is (equal bool (%binding '?b answer))))

    (signals unification-error
      (%query database `((type-unify ,(%arrow int int) ,int))))
    (signals type-name-unification-error
      (%query database `((type-unify ,int ,bool))))
    (let* ((left-name (%name "same" 0))
           (right-name (%name "same" 0))
           (left (%app left-name))
           (right (%app right-name))
           (condition
             (%capture-type-error
              (lambda ()
                (%query database `((type-unify ,left ,right)))))))
      (is (typep condition 'type-name-unification-error))
      (is (typep condition 'unification-error))
      (is (typep condition 'sml-type-error))
      (when (typep condition 'type-name-unification-error)
        (is (equal left-name (type-error-left condition)))
        (is (equal right-name (type-error-right condition)))))))

(defun %occurs-and-kind-tests ()
  (let* ((database (make-types-database))
         (int (%app (%name "int" 0)))
         (bool (%app (%name "bool" 0))))
    (let* ((variable (%tv '?a '?ae))
           (cyclic (%arrow variable int)))
      (signals occurs-check-error
        (%query database `((type-unify ,variable ,cyclic))))
      (let ((condition
              (%capture-type-error
               (lambda ()
                 (%query database `((type-unify ,variable ,cyclic)))))))
        (is (typep condition 'occurs-check-error))
        (when (typep condition 'occurs-check-error)
          (is (occurs-check-error-variable condition)))))

    (%failure database `(= ,int ,bool))
    (let* ((answer (%one database `(= ?cycle (=> ,int ?cycle))))
           (cycle (%binding '?cycle answer)))
      (is (eq '=> (first cycle)))
      (is (eq cycle (third cycle))))
    (%failure database `(= ?cycle (=> ,int ?cycle)) '(acyclic_term ?cycle))
    (signals cyclic-type-error
      (%query database `((= ?cycle (=> ,int ?cycle))
                         (well-formed-type ?cycle))))

    (let ((ordinary (%tv '?ordinary '?oe))
          (row (%rv '?row '?re)))
      (signals kind-mismatch-error
        (%query database `((type-unify ,ordinary ,row)))))
    (signals kind-mismatch-error
      (%query database
              `((record-type nil ,(%tv '?tail '?te) ?record))))
    (signals kind-mismatch-error
      (%query database
              `((type-application ,(%name "bad-row" 1)
                                  (,(%rv '?row '?row-equality)) ?out))))
    (let* ((tail (%rv '?cyclic-row '?cyclic-row-equality))
           (open (%record nil tail))
           (cyclic-extension
             (%record (list (%field "self" (%record nil tail))))))
      (signals occurs-check-error
        (%query database `((type-unify ,open ,cyclic-extension)))))))

(defun %equality-tests ()
  (let* ((database (make-types-database))
         (int (%app (%name "int" 0 :equality :equality)))
         (real (%app (%name "real" 0 :equality :non-equality)))
         (list-name (%name "list" 1 :equality :equality))
         (list-int (%app list-name int))
         (list-real (%app list-name real))
         (reference-name (%name "ref" 1 :identity +reference-identity+))
         (same-spelling-reference (%name "ref" 1))
         (real-reference (%app reference-name real))
         (function-reference (%app reference-name (%arrow int int)))
         (list-real-reference (%app list-name real-reference))
         (non-reference-real (%app same-spelling-reference real)))
    (let ((answer
            (%one database
              '(equality-type-variable ?equality)
              '(= ?equality (type-var ?cell :type :equality))
              '(var ?cell)
              '(type-equality ?equality :equality))))
      (is (eq :equality (fourth (%binding '?equality answer)))))
    (dolist (entry (list (cons int :equality) (cons real :non-equality)
                         (cons list-int :equality)
                         (cons list-real :non-equality)
                         (cons real-reference :equality)
                         (cons function-reference :equality)
                         (cons list-real-reference :equality)
                         (cons non-reference-real :non-equality)
                         (cons (%arrow int int) :non-equality)))
      (%one database `(type-equality ,(car entry) ,(cdr entry))))
    (%one database `(type-equality ,(%tv '?ordinary '?ordinary-equality)
                                   :undetermined))

    (let* ((ordinary (%tv '?a '?ae))
           (equality (%tv '?e :equality)))
      (%one database
        `(type-unify ,ordinary ,equality)
        `(equality-type-variable ,ordinary)))
    (let* ((equality (%tv '?equality :equality))
           (argument (%tv '?argument '?argument-equality)))
      (%one database
        `(type-unify ,equality ,(%app list-name argument))
        `(equality-type-variable ,argument)))
    (let* ((argument (%tv '?argument '?argument-equality))
           (answer (%one database `(ensure-equality ,(%app list-name argument)))))
      (is (eq :equality (%binding '?argument-equality answer))))

    (let* ((a (%tv '?a '?ae))
           (b (%tv '?b '?be))
           (record (%record (list (%field "a" a) (%field "b" b)))))
      (%one database
        `(ensure-equality ,record)
        `(equality-type-variable ,a)
        `(equality-type-variable ,b)
        `(type-equality ,record :equality)))

    ;; Ordinary variables may become functions, and an equality-constrained
    ;; flexible row checks fields supplied by a later extension.
    (let ((ordinary (%tv '?function-variable '?function-equality)))
      (%one database
        `(type-unify ,ordinary ,(%arrow int int))
        '(type-equality ?function-variable :non-equality)))
    (let* ((tail (%rv '?equality-row '?row-equality))
           (open (%record (list (%field "a" int)) tail))
           (closed (%record (list (%field "a" int)
                                  (%field "f" (%arrow int int))))))
      (signals equality-type-error
        (%query database `((ensure-equality ,open)
                           (type-unify ,open ,closed)))))

    (%ground-success database `(ensure-equality ,int))
    (%ground-success database `(ensure-equality ,real-reference))
    (%ground-success database `(ensure-equality ,function-reference))
    (%ground-success database `(ensure-equality ,list-real-reference))
    (signals equality-type-error (%query database `((ensure-equality ,real))))
    (signals equality-type-error
      (%query database `((ensure-equality ,non-reference-real))))
    (signals equality-type-error
      (%query database `((ensure-equality ,(%arrow int int)))))
    (signals equality-type-error
      (%query database `((ensure-equality ,list-real))))
    (signals equality-type-error
      (%query database
              `((ensure-equality ,(%record (list (%field "bad" real)))))))))

(defun %record-unification-tests ()
  (let* ((database (make-types-database))
         (int (%app (%name "int" 0)))
         (bool (%app (%name "bool" 0)))
         (string-type (%app (%name "string" 0))))
    (let* ((left (%record (list (%field "a" int) (%field "b" bool)
                                (%field "c" string-type))))
           (right (%record (list (%field "c" string-type) (%field "a" int)
                                 (%field "b" bool)))))
      (%one database
        `(type-unify ,left ,right)
        `(record-field ,left "a" ?a)
        `(record-field ,right "b" ?b)
        `(record-field ,left "c" ?c)
        `(= ?a ,int)
        `(= ?b ,bool)
        `(= ?c ,string-type)))
    (%failure database `(record-field ,(%record (list (%field "a" int)))
                                     "missing" ?type))

    (let* ((tail (%rv '?tail '?te))
           (open (%record (list (%field "a" int)) tail))
           (closed (%record (list (%field "a" int) (%field "b" bool))))
           (answer (%one database `(type-unify ,open ,closed)))
           (residual (%binding '?tail answer)))
      (is (eq 'record (first residual)))
      (is (= 1 (length (%record-fields residual))))
      (is (equal bool (third (%named-field residual "b"))))
      (is (null (%named-field residual "a")))
      (is (eq :closed (%record-tail residual))))
    (let* ((tail (%rv '?tail '?te))
           (open (%record (list (%field "a" int)) tail))
           (closed (%record (list (%field "c" string-type) (%field "b" bool)
                                  (%field "a" int))))
           (answer (%one database `(type-unify ,closed ,open)))
           (residual (%binding '?tail answer)))
      (is (= 2 (length (%record-fields residual))))
      (is (equal bool (third (%named-field residual "b"))))
      (is (equal string-type (third (%named-field residual "c"))))
      (is (eq :closed (%record-tail residual))))

    ;; Distinct open rows retain only their common fields explicitly.  Their
    ;; unique fields become residuals over one shared, fresh row variable.
    (let* ((left-tail (%rv '?left-tail '?left-te))
           (right-tail (%rv '?right-tail '?right-te))
           (common (%tv '?common '?common-equality))
           (left (%record (list (%field "a" int) (%field "common" common))
                          left-tail))
           (right (%record (list (%field "common" bool) (%field "b" string-type))
                           right-tail))
           (answer
             (%one database
               `(type-unify ,left ,right)
               `(= ?left-tail (record ?left-fields ?left-residual))
               `(= ?right-tail (record ?right-fields ?right-residual))
               '(row-variable ?left-residual)
               '(row-variable ?right-residual)
               '(== ?left-residual ?right-residual)))
           (left-residual (%binding '?left-tail answer))
           (right-residual (%binding '?right-tail answer)))
      (is (equal bool (%binding '?common answer)))
      (is (= 1 (length (%record-fields left-residual))))
      (is (= 1 (length (%record-fields right-residual))))
      (is (equal string-type (third (%named-field left-residual "b"))))
      (is (equal int (third (%named-field right-residual "a"))))
      (is (null (%named-field left-residual "a")))
      (is (null (%named-field right-residual "b")))
      (is (equal (%binding '?left-residual answer)
                 (%binding '?right-residual answer))))

    (let ((tail (%rv '?same-tail '?same-te)))
      (%one database
        `(type-unify ,(%record (list (%field "a" int)) tail)
                     ,(%record (list (%field "a" int)) tail))
        '(var ?same-tail)))))

(defun %record-error-tests ()
  (let* ((database (make-types-database))
         (int (%app (%name "int" 0)))
         (bool (%app (%name "bool" 0))))
    (signals duplicate-record-label-error
      (%query database
              `((record-type ,(list (%field "a" int) (%field "a" int))
                             :closed ?record))))
    (let ((condition
            (%capture-type-error
             (lambda ()
               (%query database
                       `((record-type ,(list (%field "a" int) (%field "a" bool))
                                      :closed ?record)))))))
      (is (typep condition 'duplicate-record-label-error))
      (is (typep condition 'record-conflict-error))
      (when (typep condition 'record-conflict-error)
        (is (equal "a" (record-conflict-error-label condition)))))

    (let ((condition
            (%capture-type-error
             (lambda ()
               (%query database
                       `((type-unify ,(%record (list (%field "a" int))
                                               (%rv '?row '?re))
                                     ,(%record (list (%field "b" bool))))))))))
      (is (typep condition 'record-conflict-error))
      (when (typep condition 'record-conflict-error)
        (is (equal "a" (record-conflict-error-label condition)))))
    (signals record-conflict-error
      (%query database
              `((type-unify ,(%record (list (%field "a" int)))
                            ,(%record (list (%field "a" int)
                                            (%field "b" bool)))))))
    (signals type-name-unification-error
      (%query database
              `((type-unify ,(%record (list (%field "a" int))
                                      (%rv '?row '?re))
                            ,(%record (list (%field "a" bool)))))))

    (let ((tail (%rv '?same '?same-equality)))
      (signals row-tail-conflict-error
        (%query database
                `((type-unify ,(%record (list (%field "a" int)) tail)
                              ,(%record nil tail))))))

    ;; Empty open rows first acquire a shared residual.  Extending that residual
    ;; later with disjoint required labels must not silently make them agree.
    (let ((left-tail (%rv '?left '?left-equality))
          (right-tail (%rv '?right '?right-equality)))
      (signals record-conflict-error
        (%query database
                `((type-unify ,(%record nil left-tail) ,(%record nil right-tail))
                  (type-unify ,(%record (list (%field "a" int)) left-tail)
                              ,(%record (list (%field "b" bool)) right-tail))))))))

(defun %environment-tests ()
  (let* ((database (make-types-database))
         (int (%app (%name "int" 0)))
         (bool (%app (%name "bool" 0)))
         (string-type (%app (%name "string" 0)))
         (answer
           (%one database
             '(empty-type-environment ?empty)
             `(extend-type-environment ?empty "x" ,int ?first)
             `(extend-type-environment ?first "other" ,bool ?second)
             `(extend-type-environment ?second "x" ,string-type ?shadowed)
             `(lookup-type-environment ?first "x" ?first-x)
             `(lookup-type-environment ?second "x" ?second-x)
             `(lookup-type-environment ?shadowed "x" ?shadowed-x)
             `(lookup-type-environment ?second "other" ?other)
             `(require-type-environment ?shadowed "x" ?required)
             `(= ?first-x ,int)
             `(= ?second-x ,int)
             `(= ?shadowed-x ,string-type)
             `(= ?other ,bool)
             `(= ?required ,string-type))))
    (is (equal '(type-env nil) (%binding '?empty answer)))
    (let ((first-entries (second (%binding '?first answer)))
          (second-entries (second (%binding '?second answer)))
          (shadowed-entries (second (%binding '?shadowed answer))))
      (is (= 1 (length first-entries)))
      (is (= 2 (length second-entries)))
      (is (= 3 (length shadowed-entries)))
      (is (equal (list 'binding "x" int) (first first-entries)))
      (is (equal "other" (second (first second-entries))))
      (is (equal "x" (second (first shadowed-entries))))
      (is (equal string-type (third (first shadowed-entries)))))
    (%failure database '(lookup-type-environment (type-env nil) "absent" ?value))
    (let ((condition
            (%capture-type-error
             (lambda ()
               (%query database
                       '((require-type-environment (type-env nil) "absent" ?value)))))))
      (is (typep condition 'unbound-identifier-error))
      (when (typep condition 'unbound-identifier-error)
        (is (equal "absent" (unbound-identifier-error-identifier condition)))))))

(defun %logical-variable-member-p (variable solution variables)
  "Match the shared logical identity preserved by answer reification.
VARIABLE is the original TYPE-VAR term, while VARIABLES contains reified terms;
EQUAL would incorrectly compare the original ?A symbols with their ?G aliases."
  (let ((expected-cell (%binding (second variable) solution))
        (expected-equality (%binding (fourth variable) solution)))
    (find-if (lambda (candidate)
               (and (consp candidate)
                    (eq 'type-var (first candidate))
                    (eq expected-cell (second candidate))
                    (eq expected-equality (fourth candidate))))
             variables)))

(defun %free-variable-tests ()
  (let ((database (make-types-database)))
    (let* ((a (%tv '?a '?ae))
           (b (%tv '?b '?be))
           (name-a (%name "same" 0))
           (name-b (%name "same" 0))
           (body (%arrow (%app name-a) (%app name-b)))
           (scheme (list 'scheme (list a) (%arrow a b)))
           (answer
             (%one database
               `(free-type-variables ,(%arrow a b) ?body-variables)
               `(free-type-variables ,scheme ?scheme-variables)
               `(free-type-names ,body ?names))))
      (let ((body-variables (%binding '?body-variables answer))
            (scheme-variables (%binding '?scheme-variables answer))
            (names (%binding '?names answer)))
        (is (= 2 (length body-variables)))
        (is (%logical-variable-member-p a answer body-variables))
        (is (%logical-variable-member-p b answer body-variables))
        (is (= 1 (length scheme-variables)))
        (is (%logical-variable-member-p b answer scheme-variables))
        (is (not (%logical-variable-member-p a answer scheme-variables)))
        (is (= 2 (length names)))
        (is (member name-a names :test #'equal))
        (is (member name-b names :test #'equal))))
    (let* ((a (%tv '?a '?ae))
           (b (%tv '?b '?be))
           (c (%tv '?c '?ce))
           (scheme (list 'scheme (list a) (%arrow a b)))
           (environment (list 'type-env
                              (list (list 'binding "closed" scheme)
                                    (list 'binding "open" c))))
           (answer (%one database `(free-type-variables ,environment ?variables)))
           (variables (%binding '?variables answer)))
      (is (= 2 (length variables)))
      (is (%logical-variable-member-p b answer variables))
      (is (%logical-variable-member-p c answer variables))
      (is (not (%logical-variable-member-p a answer variables))))
    (let ((a (%tv '?linked '?linked-equality))
          (int (%app (%name "int" 0))))
      (%one database
        `(type-unify ,a ,int)
        `(free-type-variables ,a ?variables)
        '(= ?variables nil)))))

(defun %generalization-tests ()
  (let ((database (make-types-database))
        (int (%app (%name "int" 0))))
    ;; Quantified variables are copied into the scheme body.  Specializing that
    ;; copy must leave the original identity variable unbound.
    (let* ((a (%tv '?a '?ae))
           (identity-type (%arrow a a)))
      (%one database
        `(generalize-type ,identity-type (type-env nil) nil :nonexpansive ?scheme)
        '(= ?scheme (scheme (?quantified) (=> ?domain ?result)))
        '(== ?quantified ?domain)
        '(== ?quantified ?result)
        `(type-unify ?quantified ,int)
        '(var ?a)
        '(var ?ae)))

    (let* ((a (%tv '?a '?ae))
           (environment-variable (%tv '?environment '?environment-equality))
           (excluded (%tv '?excluded '?excluded-equality))
           (environment (list 'type-env
                              (list (list 'binding "x" environment-variable))))
           (type (%arrow a (%arrow environment-variable excluded)))
           (answer
             (%one database
               `(generalize-type ,type ,environment (,excluded) ?scheme)
               '(= ?scheme
                   (scheme (?quantified)
                           (=> ?domain (=> ?from-environment ?excluded-body))))
               '(== ?quantified ?domain)
               `(== ?from-environment ,environment-variable)
               `(== ?excluded-body ,excluded)
               '(var ?a)
               '(var ?environment)
               '(var ?excluded)
               '(free-type-variables ?scheme ?free))))
      (let ((free (%binding '?free answer))
            (quantified (%binding '?quantified answer))
            (from-environment (%binding '?from-environment answer))
            (excluded-body (%binding '?excluded-body answer)))
        (is (= 2 (length free)))
        (is (member from-environment free :test #'equal))
        (is (member excluded-body free :test #'equal))
        (is (not (member quantified free :test #'equal)))))

    (dolist (eligibility '(:expansive :value-restriction))
      (let* ((a (%tv '?a '?ae))
             (type (%arrow a a)))
        (%one database
          `(generalize-type ,type (type-env nil) nil ,eligibility ?scheme)
          '(= ?scheme (scheme nil (=> ?domain ?result)))
          '(== ?domain ?result)
          `(== ?domain ,a)
          '(var ?a))))))

(defun %instantiation-tests ()
  (let* ((database (make-types-database))
         (int (%app (%name "int" 0)))
         (bool (%app (%name "bool" 0)))
         (a (%tv '?a '?ae))
         (shared (%tv '?shared '?shared-equality))
         (type (%arrow a shared)))
    ;; Each instance freshens only the quantified variable; the excluded free
    ;; variable stays shared, and later specialization cannot alter the scheme.
    (%one database
      `(generalize-type ,type (type-env nil) (,shared) ?scheme)
      '(instantiate-type-scheme ?scheme ?first)
      '(instantiate-type-scheme ?scheme ?second)
      '(= ?first (=> ?first-variable ?first-shared))
      '(= ?second (=> ?second-variable ?second-shared))
      `(== ?first-shared ,shared)
      `(== ?second-shared ,shared)
      '(= ?first-variable (type-var ?first-cell :type ?first-equality))
      '(= ?second-variable (type-var ?second-cell :type ?second-equality))
      '(var ?first-cell)
      '(var ?second-cell)
      `(type-unify ?first-variable ,int)
      '(var ?second-cell)
      '(instantiate-type-scheme ?scheme ?third)
      '(= ?third (=> ?third-variable ?third-shared))
      `(== ?third-shared ,shared)
      '(= ?third-variable (type-var ?third-cell :type ?third-equality))
      '(var ?third-cell)
      `(type-unify ?second-variable ,bool)
      '(var ?third-cell))
    (let* ((residual (%record (list (%field "1" int))))
           (row (list 'type-var residual :row '?row-equality))
           (body (%record (list (%field "2" bool)) row)))
      (%one database
        `(instantiate-type-scheme (scheme nil ,body) ?instance)
        '(well-formed-type ?instance)
        '(= ?instance (record ?fields (type-var ?copied :row ?equality)))
        `(= ?copied ,residual)))))

(defun %substitution-and-type-function-tests ()
  (let* ((database (make-types-database))
         (int (%app (%name "int" 0)))
         (pair-name (%name "pair" 2)))
    (let* ((a (%tv '?a '?ae))
           (b (%tv '?b '?be))
           (body (%arrow a (%arrow a b)))
           (maps (list (list 'variable-map a b) (list 'variable-map b int))))
      (%one database
        `(substitute-type-variables ,body ,maps ?result)
        '(= ?result (=> ?first (=> ?second ?last)))
        `(== ?first ,b)
        `(== ?second ,b)
        `(== ?last ,int)
        '(var ?a)
        '(var ?b)))
    (let* ((a (%tv '?a '?ae))
           (b (%tv '?b '?be))
           (free (%tv '?free '?free-equality))
           (function (list 'type-function (list a b)
                           (%arrow (%app pair-name a b) free))))
      (%one database
        `(apply-type-function ,function (,b ,a) ?result)
        '(= ?result (=> (@ ?name (?first ?second)) ?result-free))
        `(== ?name ,pair-name)
        `(== ?first ,b)
        `(== ?second ,a)
        `(== ?result-free ,free)))
    (let* ((a (%tv '?a '?ae))
           (function (list 'type-function (list a) (%arrow a a))))
      (signals arity-mismatch-error
        (%query database `((apply-type-function ,function nil ?result))))
      (signals arity-mismatch-error
        (%query database `((apply-type-function ,function (,int ,int) ?result)))))))

(defun %realization-tests ()
  (let* ((database (make-types-database))
         (int (%app (%name "int" 0)))
         (source (%name "source" 1))
         (same-spelling (%name "source" 1))
         (target (%name "target" 1))
         (outer (%name "outer" 1))
         (new-outer (%name "new-outer" 1)))
    (let* ((a (%tv '?a '?ae))
           (type (%arrow (%app outer (%app source a))
                         (%app same-spelling int)))
           (realization
             (list 'realization
                   (list (list 'name-map source target)
                         (list 'name-map outer new-outer)))))
      (%one database
        `(realize-type ,type ,realization ?result)
        '(= ?result (=> (@ ?outer-name (?nested)) (@ ?other-name (?argument))))
        `(== ?outer-name ,new-outer)
        `(= ?nested (@ ?target-name (?nested-argument)))
        `(== ?target-name ,target)
        `(== ?nested-argument ,a)
        `(== ?other-name ,same-spelling)
        `(== ?argument ,int)))
    (%one database
      `(substitute-type-names ,(%app source int) (,(list 'name-map source target))
                              ?result)
      `(= ?result ,(%app target int)))

    (let* ((parameter (%tv '?parameter '?parameter-equality))
           (function (list 'type-function (list parameter)
                           (%arrow parameter parameter)))
           (realization
             (list 'realization (list (list 'name-map source function)))))
      (%one database
        `(realize-type ,(%app source int) ,realization ?result)
        `(= ?result ,(%arrow int int))))

    (let* ((non-equality-target (%name "target" 1 :equality :non-equality))
           (realization
             (list 'realization
                   (list (list 'name-map source non-equality-target))))
           (answer
             (%one database
               `(realize-type ,(%app source int) ,realization ?result)
               '(type-equality ?result :non-equality)))
           (result (%binding '?result answer)))
      (is (equal non-equality-target (second result)))
      (signals equality-type-error
        (%query database `((ensure-equality ,(%app non-equality-target int))))))
    (let* ((wrong-arity (%name "target" 2))
           (realization
             (list 'realization (list (list 'name-map source wrong-arity)))))
      (signals arity-mismatch-error
        (%query database
                `((realize-type ,(%app source int) ,realization ?result)))))
    (let* ((function (list 'type-function nil int))
           (realization
             (list 'realization (list (list 'name-map source function)))))
      (signals arity-mismatch-error
        (%query database
                `((realize-type ,(%app source int) ,realization ?result)))))))

(defun %persistent-row-tests ()
  (let* ((database (install-elaboration-predicates (make-types-database)))
         (int (%app (%name "int" 0)))
         (residual (%record (list (%field "b" int))))
         (type (%record (list (%field "a" int)) (%rv residual :equality)))
         (answer
           (%one database
             `(freeze-type ,type ?frozen)
             '(thaw-type ?frozen ?thawed)
             '(well-formed-type ?thawed)))
         (thawed (%binding '?thawed answer)))
    (is (eq :row (third (%record-tail thawed))) ()
        "Freezing replaced a bound row with a bare residual record."))
  (let* ((database (make-types-database))
         (source (%name "source" 0))
         (target (%name "target" 0))
         (residual (%record (list (%field "b" (%app source)))))
         (type (%record (list (%field "a" (%app source)))
                        (%rv residual :equality)))
         (realization
           (list 'realization (list (list 'name-map source target))))
         (answer
           (%one database
             `(realize-type ,type ,realization ?result)
             '(well-formed-type ?result)))
         (result (%binding '?result answer)))
    (is (eq :row (third (%record-tail result))) ()
        "Type-name realization discarded a residual row wrapper.")))

(defun %rendering-tests ()
  (let* ((database (make-types-database))
         (int (%app (%name "int" 0)))
         (list-name (%name "list" 1))
         (list-int (%app list-name int)))
    (let ((first (%one database `(render-type ,int ?text)))
          (second (%one database `(render-type ,int ?text))))
      (is (search "int" (%binding '?text first)))
      (is (string= (%binding '?text first) (%binding '?text second))))
    (let ((answer
            (%one database
              `(render-type ,list-int ?first)
              `(render-type ,list-int ?second))))
      (is (string= (%binding '?first answer) (%binding '?second answer)))
      (is (search "int" (%binding '?first answer)))
      (is (search "list" (%binding '?first answer))))

    (let ((answer
            (%one database
              `(render-type ,(%tv '?equality :equality) ?first)
              `(render-type ,(%tv '?equality :equality) ?second))))
      (is (string= (%binding '?first answer) (%binding '?second answer)))
      (is (search "''" (%binding '?first answer))))

    (let* ((left-cell (make-symbol "?same"))
           (right-cell (make-symbol "?same"))
           (left (%tv left-cell (make-symbol "?left-equality")))
           (right (%tv right-cell (make-symbol "?right-equality")))
           (answer
             (%one database
               `(render-type ,(%arrow left right) ?combined)
               `(render-type ,left ?left)
               `(render-type ,right ?right))))
      (is (string= "'a -> 'b" (%binding '?combined answer)))
      (is (string= (%binding '?left answer) (%binding '?right answer))))))

(defun %database-and-cursor-tests ()
  (let* ((database (make-types-database))
         (int-name (%name "int" 0))
         (int (%app int-name))
         (cursor (make-query `((type-application ,int-name nil ?out))
                             :database database)))
    (unwind-protect
         (progn
           (multiple-value-bind (solution foundp) (next-solution cursor)
             (is foundp)
             (when foundp (is (equal int (%binding '?out solution)))))
           (multiple-value-bind (solution foundp) (next-solution cursor)
             (declare (ignore solution))
             (is (not foundp))))
      (close-query cursor)))

  (let ((left (make-database :term-model :native :execution-mode :wam))
        (right (make-database :term-model :native :execution-mode :wam))
        (int (%app (%name "int" 0))))
    (let ((*database* left))
      (<-- (local-type-sentinel left)))
    (let ((*database* right))
      (<-- (local-type-sentinel right)))
    (is (eq left (install-type-predicates left)))
    (is (eq right (install-type-predicates right)))
    (let ((answer (%one left '(local-type-sentinel ?value))))
      (is (eq 'left (%binding '?value answer))))
    (let ((answer (%one right '(local-type-sentinel ?value))))
      (is (eq 'right (%binding '?value answer))))
    (%ground-success left `(type-unify ,int ,int))
    (%ground-success right `(type-unify ,int ,int))))

(defun run-type-tests ()
  (with-suite ("ooparts-tests/sml/types")
    (%construction-tests)
    (%unification-tests)
    (%occurs-and-kind-tests)
    (%equality-tests)
    (%record-unification-tests)
    (%record-error-tests)
    (%environment-tests)
    (%free-variable-tests)
    (%generalization-tests)
    (%instantiation-tests)
    (%substitution-and-type-function-tests)
    (%realization-tests)
    (%persistent-row-tests)
    (%rendering-tests)
    (%database-and-cursor-tests))
  t)
