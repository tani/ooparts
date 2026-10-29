# ooparts/sat

The default production SATCH 0.5.6rc solver translated to SBCL Common Lisp,
with a resource-managed Lisp API. Runtime dependencies are SBCL and its bundled
ASDF/UIOP. A C solver, CFFI, GCC and Python are not needed to use the library.

The system and public package are `ooparts/sat`; no package nickname is defined.
The supported backend is SBCL on Linux x86-64, LP64, little endian.

## Solve a formula

```lisp
(asdf:load-system "ooparts/sat")
(multiple-value-bind (status model stats)
    (ooparts/sat:solve-cnf '((1 2) (-1 2) (-2 3)))
  (declare (ignore stats))
  (when (eq status :sat)
    (list (ooparts/sat:model-value model 2)
          (ooparts/sat:model-value model -3))))
;; => (T NIL)

(ooparts/sat:solve-cnf '((1) (-1)))
;; => :UNSAT, NIL, a statistics plist
```

CNF is a list/vector of clauses, each a list/vector of nonzero integer literals.
Positive integers denote one-based variables; a negative sign denotes negation.
The public API adds clause terminators itself. An empty formula is SAT; a
formula containing an empty clause is UNSAT.

The solve functions return three values:

1. `:sat`, `:unsat` or `:unknown`.
2. A signed model vector for SAT, otherwise NIL.
3. A fresh plist with `:status`, `:variables`, `:clauses` and `:conflicts`.

Model entry `v-1` is `v` when variable `v` is true and `-v` when false. Unused
declared variables default to true, following SATCH. A model is a detached
snapshot and remains usable after its solver is closed. `model-value` accepts
positive or negative literals and returns a Boolean.

## Construct and query a solver

```lisp
(ooparts/sat:with-solver (s :variables 2)
  (let ((z (ooparts/sat:new-variable s)))
    (ooparts/sat:add-clauses s #((1 2) #(-1 2)))
    (ooparts/sat:add-clause s (list -2 z))
    (when (eq :sat (ooparts/sat:solve s))
      (ooparts/sat:value s z))))
;; => T
```

`with-solver` releases solver allocations on normal return, error and nonlocal
exit, preserving the body's multiple values. For manual ownership use
`make-solver` and `close-solver`. Closing is idempotent. Native arenas remain in
the process and recycle released allocations.

| API | Meaning |
|---|---|
| `make-solver &key clauses variables verbosity proof-stream proof-format` | Construct a solver; counts/verbosity default to 0, proof format to `:ascii` |
| `with-solver (s &rest options) &body body` | Construct and release on every exit |
| `close-solver s` / `solver-closed-p s` | Release / inspect resource lifetime |
| `add-clause s literals` / `add-clauses s clauses` | Validate and add a clause / entire batch; return the solver |
| `new-variable s` / `reserve-variables s count` | Allocate a variable number / declare a minimum variable range |
| `solve s &key conflict-limit` | Return status, model and statistics |
| `model s` / `value s literal` | Copy a SAT model / query literal truth |
| `model-value model literal` | Query a detached model |
| `statistics s` / `solver-status s` | Inspect counters / current state |
| `solve-cnf clauses &key variables conflict-limit` | Construct, solve and release a formula |
| `read-dimacs stream` | Read strict DIMACS; return clauses and declared variable count |
| `solve-stream stream &key conflict-limit` | Read and solve; leave the stream open |
| `solve-file path &key conflict-limit` | Read and solve a file |

The `variables` option is a minimum declaration, extended by variables present
in clauses. `:clauses` counts submitted input clauses, including duplicates and
tautologies, rather than learned clauses.

## State and conditions

Add clauses and declare variables while the solver is `:building`. The default
conflict limit is NIL (unlimited); an explicit limit is an integer from 0 to
2147483647. After `:unknown`, call `solve` again to continue the same formula.
SATCH does not support adding clauses after its first solve, assumptions, or
solving again after SAT/UNSAT. Use a fresh solver for a different formula.

Invalid input signals `type-error`. Invalid lifecycle operations signal
`solver-state-error`, with readers `state-error-solver`, `state-error-operation`,
`state-error-expected` and `state-error-actual`. A whole clause/batch is copied
and validated before input mutates the engine. An interrupted engine mutation
sets `:failed`, allowing release but not continuation. Transient solving state
is `:solving`; released state is `:closed`.

Public operations use a recursive mutex, including complete clause batches and
model snapshots. Independently allocated solvers retain separate search state.
The original C-style functions remain in `ooparts/sat/low-level`; do not mix a
high-level solver object with raw low-level handles.

## Proofs and command line

```lisp
(with-open-file (proof "proof.drup" :direction :output :if-exists :supersede)
  (ooparts/sat:with-solver (s :clauses '((1) (-1)) :proof-stream proof)
    (ooparts/sat:solve s)))
```

For binary proofs use an `(unsigned-byte 8)` output stream and
`:proof-format :binary`. The caller owns and closes the stream. Tracing starts
before any input clauses are added.

```sh
sbcl --script tools/sat/cli.lisp input.cnf
```

The inferred `ooparts/sat/cli` module emits SAT Competition `s`/`v` lines and
returns exit codes 10/20/0 for SAT/UNSAT/UNKNOWN, or 1 for input errors.

## Translation style and implementation

The pinned upstream revision is `b4d4081f8971931399b36c8fdd92bdf4aabac005` from
[arminbiere/satch](https://github.com/arminbiere/satch), built with `-DNDEBUG`
and all default algorithmic features enabled. All 284 functions remain mapped
in [function-map.json](../../tools/sat/function-map.json).

Generated engine names are ordinary case-insensitive, hyphenated Lisp symbols.
Arguments are lexical parameters, scalar declarations use `let*` at their
declaration positions, and 282 functions use structured Lisp conditionals and
loops. The two functions with source-level cross-branch transfers retain a
`tagbody`. Structure fields are named generalized places supporting `setf`;
wrapping word updates evaluate their place and increment once. Integer widths,
full-width sentinels and evaluation order remain explicit where C semantics
require them. Standard Lisp pretty printing is part of regeneration.

The implementation is split into inferred packages:

- [runtime](../../src/sat/runtime.lisp): checked arenas, typed memory operations
  and C/OS adapters.
- [layout](../../src/sat/layout.lisp): generated named structure-field places.
- [engine](../../src/sat/engine.lisp): generated SATCH algorithms in Lisp.
- [low-level](../../src/sat/low-level.lisp): validated C-style API.
- [public facade](../../src/sat.lisp): Lisp ownership, conditions and convenience API.

The backend retains checked packed LP64 storage for tagged watches and direct
comparison with the pinned C implementation. Structure offsets are isolated in
the layout package. The core uses typed speed-oriented code and safety 1;
public argument validation uses safety 3. Compiler diagnostics are enabled.
All five library modules and the CLI compile with zero compiler notes or warnings on the
recorded SBCL 2.2.9 environment, without muffling conditions.

## Test and regenerate

```sh
sbcl --script tools/test.lisp sat
sbcl --non-interactive --load tools/sat/compile-clean.lisp
python3 tools/sat/differential.py --random 1000
python3 tools/sat/proofs.py
SBCL=sbcl python3 tools/sat/translate.py
```

Validation includes API/lifetime tests, numeric boundaries, an independent
exhaustive oracle, 1105 comparisons with C, six identical ASCII/binary proof
outputs and independent RUP checking. Pointer-based upstream tie-breaks require
a matched allocator for exact internal-counter comparisons. Regeneration uses
Python/pycparser, GCC for preprocessing and 491 ABI checks, and SBCL for standard
Lisp formatting. See [testing](testing.md) and the root [validation guide](../testing.md).

The shared heap arena is limited to 256 MiB and automatic storage to 16 MiB;
exhaustion signals an error. Saving/restoring an image containing live arenas
is unsupported. Historical pre-refactoring measurements are labeled in
[benchmarks](../../benchmarks/sat/README.md); they do not measure the new public
API or automatically establish performance for the current source.

The original SATCH [MIT license](../../licenses/satch-MIT.txt) and
[notice](../../licenses/satch-NOTICE.txt) are retained. See
[THIRD_PARTY.md](../../THIRD_PARTY.md) for the scope of imported material.
