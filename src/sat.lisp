(uiop:define-package #:ooparts/sat
  (:use #:cl)
  (:import-from #:ooparts/sat/runtime)
  (:import-from #:ooparts/sat/low-level #:read-dimacs)
  (:export #:solver #:solver-p #:make-solver #:close-solver #:with-solver #:solver-status #:solver-closed-p #:solver-state-error #:state-error-solver #:state-error-operation #:state-error-expected #:state-error-actual #:literal #:add-clause #:add-clauses #:new-variable #:reserve-variables #:solve #:solve-cnf #:solve-file #:solve-stream #:read-dimacs #:model #:value #:model-value #:statistics))
(in-package #:ooparts/sat)

;; The public boundary validates Lisp objects; the translated search engine has
;; its own typed, speed-oriented policy. Keep ordinary compiler diagnostics on.
(declaim (sb-ext:unmuffle-conditions sb-ext:compiler-note))
(declaim (optimize (speed 1) (safety 3) (debug 2)))

(deftype literal ()
  "A nonzero signed DIMACS literal; ABS is its one-based variable number."
  '(or (integer -2147483647 -1) (integer 1 2147483647)))

(defstruct (solver (:constructor %make-solver (handle)) (:conc-name %solver-))
  (handle 0 :type ooparts/sat/runtime:c-address :read-only t)
  (state :building :type keyword)
  (variables 0 :type (integer 0 2147483647))
  (clauses 0 :type (integer 0 *)))

(defmethod print-object ((solver solver) stream)
  (print-unreadable-object (solver stream :type t :identity t)
    (format stream "~A, ~D variables, ~D clauses"
            (%solver-state solver) (%solver-variables solver) (%solver-clauses solver))))

(define-condition solver-state-error (error)
  ((solver :initarg :solver :reader state-error-solver)
   (operation :initarg :operation :reader state-error-operation)
   (expected :initarg :expected :reader state-error-expected)
   (actual :initarg :actual :reader state-error-actual))
  (:report (lambda (condition stream)
             (format stream "Cannot ~A solver in state ~S; expected one of ~S."
                     (state-error-operation condition) (state-error-actual condition)
                     (state-error-expected condition)))))

(defun %require-state (solver operation states)
  (check-type solver solver)
  (unless (member (%solver-state solver) states)
    (error 'solver-state-error :solver solver :operation operation
           :expected states :actual (%solver-state solver)))
  solver)

(defmacro %guard-mutation ((solver) &body body)
  "An interrupted engine mutation cannot subsequently be resumed."
  (let ((completed (gensym "COMPLETED")))
    `(let ((,completed nil))
       (unwind-protect
            (multiple-value-prog1 (progn ,@body) (setf ,completed t))
         (unless ,completed (setf (%solver-state ,solver) :failed))))))

(defun %literal (literal)
  (check-type literal literal)
  literal)

(defun %count (count)
  (check-type count (integer 0 2147483647))
  count)

(defun %sequence (sequence)
  ;; Reject strings, dotted lists and circular lists before touching the solver.
  (unless (or (and (listp sequence)
                   (or (null sequence) (list-length sequence)))
              (and (vectorp sequence) (not (stringp sequence))))
    (error 'type-error :datum sequence :expected-type '(or list (vector t))))
  sequence)

(defun %clause (literals)
  (map 'vector #'%literal (%sequence literals)))

(defun solver-status (solver)
  "Return :BUILDING, :SOLVING, :SAT, :UNSAT, :UNKNOWN, :FAILED or :CLOSED."
  (check-type solver solver)
  (ooparts/sat/low-level:api-locked (%solver-state solver)))

(defun solver-closed-p (solver)
  "Whether SOLVER has already been released."
  (eq (solver-status solver) :closed))

(defun close-solver (solver)
  "Release SOLVER. Repeated closes are harmless. Return NIL.
Proof streams belong to the caller and are not closed."
  (check-type solver solver)
  (ooparts/sat/low-level:api-locked
    (unless (eq (%solver-state solver) :closed)
      (ooparts/sat/low-level:satch-release (%solver-handle solver))
      (setf (%solver-state solver) :closed)))
  nil)

(defmacro with-solver ((variable &rest options) &body body)
  "Bind a solver made with OPTIONS and release it on every exit.
BODY may start with declarations and returns its ordinary multiple values."
  `(let ((,variable (make-solver ,@options)))
     (unwind-protect (locally ,@body) (close-solver ,variable))))

(defun %append-clause (solver clause)
  ;; CLAUSE is a complete, validated snapshot. Hold the engine lock throughout.
  (let ((handle (%solver-handle solver)) (maximum (%solver-variables solver)))
    (loop for literal across clause do
      (setf maximum (max maximum (abs literal)))
      (ooparts/sat/low-level:satch-add handle literal))
    (ooparts/sat/low-level:satch-add handle 0)
    (setf (%solver-variables solver) maximum)
    (incf (%solver-clauses solver))))

(defun add-clause (solver literals)
  "Add one clause (a list or vector of nonzero integer literals). Return SOLVER.
NIL or #() adds the empty clause. Invalid input leaves SOLVER unchanged.
Clauses can only be added before the first call to SOLVE."
  (ooparts/sat/low-level:api-locked
    (%require-state solver 'add-clause '(:building))
    (let ((clause (%clause literals)))
      (%guard-mutation (solver) (%append-clause solver clause))))
  solver)

(defun add-clauses (solver clauses)
  "Add a list or vector of clauses. Return SOLVER.
Validate and copy the entire batch before adding any of it."
  (ooparts/sat/low-level:api-locked
    (%require-state solver 'add-clauses '(:building))
    (let ((clauses (map 'vector #'%clause (%sequence clauses))))
      (%guard-mutation (solver)
        (loop for clause across clauses do (%append-clause solver clause)))))
  solver)

(defun reserve-variables (solver count)
  "Declare variables 1 through COUNT, retaining any larger existing count.
This also reserves native capacity. Return SOLVER. Only valid while building."
  (ooparts/sat/low-level:api-locked
    (%require-state solver 'reserve-variables '(:building))
    (setf count (%count count))
    (%guard-mutation (solver)
      (ooparts/sat/low-level:satch-reserve (%solver-handle solver) count)
      (setf (%solver-variables solver) (max count (%solver-variables solver)))))
  solver)

(defun new-variable (solver)
  "Declare and return a fresh positive variable number. Only valid while building."
  (ooparts/sat/low-level:api-locked
    (%require-state solver 'new-variable '(:building))
    (let ((variable (%count (1+ (%solver-variables solver)))))
      (reserve-variables solver variable)
      variable)))

(defun %proof-options (stream format)
  (check-type format (member :ascii :binary))
  (when stream
    (check-type stream stream)
    (unless (and (open-stream-p stream) (output-stream-p stream)
                 (subtypep (stream-element-type stream)
                           (if (eq format :ascii) 'character '(unsigned-byte 8))))
      (error "~S proof requires an open output stream of ~S elements."
             format (if (eq format :ascii) 'character '(unsigned-byte 8))))))

(defun make-solver (&key (clauses nil) (variables 0) (verbosity 0)
                         proof-stream (proof-format :ascii))
  "Create a solver; use WITH-SOLVER or call CLOSE-SOLVER to release it.
CLAUSES is a list/vector of list/vector clauses. VARIABLES declares at least
that many one-based variables. PROOF-STREAM remains owned by the caller."
  (setf variables (%count variables) verbosity (%count verbosity))
  (%proof-options proof-stream proof-format)
  (let ((solver (%make-solver (ooparts/sat/low-level:satch-init))) (completed nil))
    (unwind-protect
         (progn
           (ooparts/sat/low-level:satch-set-verbose-level (%solver-handle solver) verbosity)
           (when proof-stream
             (when (eq proof-format :ascii)
               (ooparts/sat/low-level:satch-ascii-proof (%solver-handle solver)))
             (ooparts/sat/low-level:satch-trace-proof (%solver-handle solver) proof-stream))
           (reserve-variables solver variables)
           (add-clauses solver clauses)
           (setf completed t)
           solver)
      (unless completed (close-solver solver)))))

(defun statistics (solver)
  "Return a fresh plist with :STATUS, :VARIABLES, :CLAUSES and :CONFLICTS.
CLAUSES counts submitted input clauses, including duplicates and tautologies."
  (ooparts/sat/low-level:api-locked
    (%require-state solver 'statistics '(:building :sat :unsat :unknown))
    (list :status (%solver-state solver) :variables (%solver-variables solver)
          :clauses (%solver-clauses solver)
          :conflicts (ooparts/sat/low-level:satch-conflicts (%solver-handle solver)))))

(defun model (solver)
  "Return a fresh signed-literal vector for a SAT solver.
Entry V-1 is V when variable V is true and -V when false. Unused variables
default to true, following SATCH. The snapshot survives CLOSE-SOLVER."
  (ooparts/sat/low-level:api-locked
    (%require-state solver 'model '(:sat))
    (let ((model (make-array (%solver-variables solver) :element-type '(signed-byte 32))))
      (dotimes (index (length model) model)
        (setf (aref model index)
              (ooparts/sat/low-level:satch-val (%solver-handle solver) (1+ index)))))))

(defun model-value (model literal)
  "Return T or NIL for LITERAL in a signed model vector, including negative literals.
Signal TYPE-ERROR for invalid literals, malformed entries or out-of-range variables."
  (check-type model vector)
  (setf literal (%literal literal))
  (let ((variable (abs literal)))
    (unless (<= variable (length model))
      (error 'type-error :datum literal
             :expected-type `(or (integer ,(- (length model)) -1)
                                 (integer 1 ,(length model)))))
    (let ((assignment (aref model (1- variable))))
      (unless (or (eql assignment variable) (eql assignment (- variable)))
        (error 'type-error :datum assignment :expected-type `(member ,variable ,(- variable))))
      (= assignment literal))))

(defun value (solver literal)
  "Return the Boolean truth of LITERAL in a SAT solver. Accept negative literals."
  (ooparts/sat/low-level:api-locked
    (%require-state solver 'value '(:sat))
    (setf literal (%literal literal))
    (unless (<= (abs literal) (%solver-variables solver))
      (error 'type-error :datum literal
             :expected-type `(or (integer ,(- (%solver-variables solver)) -1)
                                 (integer 1 ,(%solver-variables solver)))))
    (= literal (ooparts/sat/low-level:satch-val (%solver-handle solver) literal))))

(defun solve (solver &key conflict-limit)
  "Return three values: :SAT/:UNSAT/:UNKNOWN, signed model vector or NIL, stats plist.
NIL CONFLICT-LIMIT means unlimited; otherwise use a nonnegative signed C int.
After :UNKNOWN, SOLVE may be called again to continue the same formula.
After :SAT or :UNSAT the solver is final; create a new one for another formula."
  (ooparts/sat/low-level:api-locked
    (%require-state solver 'solve '(:building :unknown))
    (let ((limit (if (null conflict-limit) -1 (%count conflict-limit))))
      (%guard-mutation (solver)
        (setf (%solver-state solver) :solving)
        (setf (%solver-state solver)
              (ecase (ooparts/sat/low-level:satch-solve (%solver-handle solver) limit)
                (10 :sat) (20 :unsat) (0 :unknown)))))
    (values (%solver-state solver)
            (when (eq (%solver-state solver) :sat) (model solver))
            (statistics solver))))

(defun solve-cnf (clauses &key (variables 0) conflict-limit)
  "Solve a list/vector of CNF clauses; return status, model snapshot and stats.
All native resources are released before returning, including on errors."
  (with-solver (solver :clauses clauses :variables variables)
    (solve solver :conflict-limit conflict-limit)))

(defun solve-stream (stream &key conflict-limit)
  "Read strict DIMACS CNF from STREAM and solve it. Leave STREAM open."
  (multiple-value-bind (clauses variables) (read-dimacs stream)
    (solve-cnf clauses :variables variables :conflict-limit conflict-limit)))

(defun solve-file (path &key conflict-limit)
  "Read strict DIMACS CNF from PATH and return status, model snapshot and stats."
  (with-open-file (stream path)
    (solve-stream stream :conflict-limit conflict-limit)))
