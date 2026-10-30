(uiop:define-package #:ooparts/prolog/kernel/model (:use #:cl)
  (:export #:%make-machine #:%make-var #:choice #:choice-age #:choice-args
    #:database-term-model #:*term-model* #:$cons #:$nil
    #:choice-builtin-context #:choice-code #:choice-continuation #:choice-cut #:choice-delays
    #:choice-handlers #:choice-heap #:choice-lineage #:choice-p #:choice-pc #:choice-scopes
    #:choice-slots #:choice-trail #:continuation #:continuation-builtin-context
    #:continuation-code #:continuation-cut #:continuation-depth #:continuation-handlers
    #:continuation-lineage #:continuation-p #:continuation-parent #:continuation-pc
    #:continuation-scopes #:continuation-slots #:copy-choice #:copy-continuation #:copy-database
    #:copy-disjunction-goal #:copy-host-goal #:copy-iso-handler #:copy-iso-state
    #:copy-iso-stream #:copy-lexical-binding #:copy-logic-var #:copy-machine #:copy-predicate
    #:copy-scoped-goals #:copy-sequence-goals #:copy-slg-answer #:copy-slg-consumer
    #:copy-slg-context #:copy-slg-table #:copy-slg-waiter #:copy-slot-ref #:database
    #:database-execution-mode #:database-generation #:database-iso-state #:database-native-cache #:database-p #:database-predicates
    #:database-tabled #:disjunction-goal #:disjunction-goal-branches #:disjunction-goal-p
    #:host-goal #:host-goal-arguments #:host-goal-function #:host-goal-output #:host-goal-p
    #:host-goal-testp #:iso-exception #:iso-exception-term #:iso-handler #:iso-handler-catcher
    #:iso-handler-p #:iso-handler-parent #:iso-handler-recovery #:iso-handler-snapshot
    #:iso-handler-tailp #:iso-state #:iso-state-aliases #:iso-state-dynamic #:iso-state-flags
    #:iso-state-reader-initialized #:iso-state-loaded-files #:iso-state-declarations #:iso-state-order-ids #:iso-state-operators #:iso-state-conversions
    #:iso-state-input #:iso-state-output #:iso-state-p #:iso-state-streams #:iso-stream
    #:iso-stream-alias #:iso-stream-byte-look #:iso-stream-eof-action #:iso-stream-file
    #:iso-stream-mode #:iso-stream-p #:iso-stream-past-end #:iso-stream-reposition
    #:iso-stream-stream #:iso-stream-type #:lexical-binding #:lexical-binding-getter
    #:lexical-binding-p #:lexical-binding-setter #:logic-var #:logic-var-binding #:logic-var-id
    #:logic-var-p #:machine #:machine-allocations #:machine-args #:machine-builtin-context
    #:machine-choices #:machine-closed #:machine-code #:machine-continuation #:machine-cut
    #:machine-database #:machine-delays #:machine-gc-count #:machine-gc-floor #:machine-gc-limit
    #:machine-gc-reclaimed #:machine-heap #:machine-iso-handlers #:machine-max-choices
    #:machine-max-depth #:machine-max-heap #:machine-max-live #:machine-max-trail #:machine-mode
    #:machine-native-calls #:machine-native-deopts #:machine-native-disabled
    #:machine-p #:machine-pc #:machine-ready #:machine-scan #:machine-scopes #:machine-serial
    #:machine-slg #:machine-slg-bypass #:machine-slg-lineage #:machine-slg-owner
    #:machine-slg-paused #:machine-slg-root #:machine-slg-worker #:machine-slots #:machine-steps
    #:machine-trail #:machine-variables #:make-choice #:make-continuation #:make-database
    #:make-disjunction-goal #:make-host-goal #:make-iso-handler #:make-iso-state
    #:make-iso-stream #:make-lexical-binding #:make-predicate #:make-scoped-goals
    #:make-sequence-goals #:make-slg-answer #:make-slg-consumer #:make-slg-context
    #:make-slg-table #:make-slg-waiter #:predicate #:predicate-adapter-context
    #:predicate-clauses #:predicate-code #:predicate-p #:scoped-goals #:scoped-goals-goals
    #:scoped-goals-p #:sequence-goals #:sequence-goals-goals #:sequence-goals-p #:slg-answer
    #:slg-answer-delays #:slg-answer-p #:slg-answer-tokens #:slg-consumer #:slg-consumer-p
    #:slg-consumer-tailp #:slg-consumer-vm #:slg-context #:slg-context-answers
    #:slg-context-atoms #:slg-context-closed #:slg-context-components-completed
    #:slg-context-constants #:slg-context-copies #:slg-context-database #:slg-context-generation
    #:slg-context-guards #:slg-context-local-waits #:slg-context-max-component-size
    #:slg-context-p #:slg-context-queue #:slg-context-resumptions #:slg-context-running
    #:slg-context-scope-serial #:slg-context-steps #:slg-context-suspensions
    #:slg-context-tables #:slg-context-tail #:slg-incomplete-cut #:slg-incomplete-cut-table
    #:slg-table #:slg-table-answers #:slg-table-arity #:slg-table-complete #:slg-table-consumers
    #:slg-table-dependencies #:slg-table-falsep #:slg-table-id #:slg-table-index
    #:slg-table-name #:slg-table-p #:slg-table-tokens #:slg-table-waiters #:slg-waiter
    #:slg-waiter-negativep #:slg-waiter-p #:slg-waiter-tailp #:slg-waiter-vm #:slot-ref
    #:slot-ref-anonymous #:slot-ref-index #:slot-ref-p))
(in-package #:ooparts/prolog/kernel/model)

;;; Streams and options.
(defstruct iso-stream stream file mode (type "text") alias (reposition nil) (eof-action "eof_code") (past-end nil) (byte-look :empty))

;;; Database-local flags, streams, native term identities and future reader tables.
(defstruct iso-state (flags (make-hash-table :test 'equal))
  (streams (make-hash-table :test 'eq)) (aliases (make-hash-table :test 'equal))
  (input *standard-input*) (output *standard-output*)
  (order-ids (make-hash-table :test 'eq))
  (reader-initialized nil)
  (loaded-files (make-hash-table :test 'equal))
  (declarations (make-hash-table :test 'equal))
  (operators (make-hash-table :test 'equal))
  (conversions (make-hash-table :test 'eql))
  (dynamic (make-hash-table :test 'equal)))
(defstruct iso-handler snapshot catcher recovery parent tailp)

(defstruct lexical-binding getter setter)

;; Copying SLG: each consumer owns an isolated WAM continuation. The work queue
;; propagates each new (possibly conditional) answer exactly once to each consumer.
;; Dynamic SCCs complete independently, before external waiters consume answers.
(defstruct slg-context
  database generation (tables (make-hash-table :test 'equal))
  (atoms (make-hash-table :test 'eql))
  (constants (make-array 16 :adjustable t :fill-pointer 0))
  queue tail (running nil) (closed nil) (suspensions 0) (resumptions 0)
  (steps 0) (answers 0) (copies 0) (scope-serial 0)
  (guards (make-hash-table)) (components-completed 0) (max-component-size 0)
  (local-waits 0))
(defstruct slg-table id name arity tokens
  (answers nil) (index (make-hash-table :test 'equal)) consumers complete falsep dependencies waiters)
(defstruct slg-answer tokens delays)
(defstruct slg-consumer vm tailp)
(defstruct slg-waiter vm tailp negativep)

(define-condition slg-incomplete-cut (error)
  ((table :initarg :table :reader slg-incomplete-cut-table))
  (:report (lambda (condition stream)
             (let ((table (slg-incomplete-cut-table condition)))
               (format stream "Illegal CUT over incomplete tabled subgoal ~S/~D"
                       (slg-table-name table) (slg-table-arity table))))))

(defstruct predicate (clauses nil) (code #()) adapter-context)
(defstruct host-goal function arguments output testp)
(defstruct sequence-goals goals)

(defstruct disjunction-goal branches)
(defstruct scoped-goals goals)


(defstruct (logic-var (:constructor %make-var (id)))
  (id 0 :type fixnum) binding)
(defstruct (slot-ref (:constructor slot-ref (index &optional anonymous))) index anonymous)
(define-condition iso-exception (error)
  ((term :initarg :term :reader iso-exception-term))
  (:report (lambda (c s) (let ((*print-circle* t) (*print-level* 8) (*print-length* 12))
                                   (format s "Prolog exception: ~S" (iso-exception-term c))))))
(defstruct continuation code pc slots cut parent depth scopes lineage handlers builtin-context)
(defstruct choice code pc args continuation cut trail heap age slots scopes delays lineage handlers builtin-context)
(defvar *term-model* :native)
(defstruct (database (:constructor %make-database))
  (term-model :native :type (member :native :iso) :read-only t)
  (execution-mode :auto :type (member :auto :wam) :read-only t)
  (predicates (make-hash-table :test 'equal))
  (tabled (make-hash-table :test 'equal)) (generation 0) iso-state
  ;; Compiled native modes are generation qualified; never query state.
  native-cache)
(defun make-database (&rest options &key (term-model :native) (execution-mode :auto)
                      &allow-other-keys)
  "Create a database with an immutable term model and execution policy.
EXECUTION-MODE is :AUTO (specialize eligible predicates) or :WAM (interpreted only)."
  (unless (member term-model '(:native :iso))
    (error "Unknown term model: ~S" term-model))
  (unless (member execution-mode '(:auto :wam))
    (error "Unknown execution mode: ~S" execution-mode))
  (apply #'%make-database options))
(defstruct (machine (:constructor %make-machine))
  database code iso-handlers builtin-context (pc 0) args slots continuation (cut 0) scopes
  slg slg-worker slg-owner slg-root slg-bypass slg-paused slg-lineage delays
  scan (mode :read) (serial 0)
  (gc-floor 4096) (gc-limit 4096) (gc-count 0) (gc-reclaimed 0)
  (allocations 0) (max-trail 0) (max-live 0)
  (heap (make-array 64 :adjustable t :fill-pointer 0))
  (trail (make-array 64 :adjustable t :fill-pointer 0))
  (choices (make-array 16 :adjustable t :fill-pointer 0))
  variables (ready nil) (closed nil) (steps 0) (max-depth 0)
  (native-disabled nil) (native-calls 0) (native-deopts 0)
  (max-choices 0) (max-heap 0))
