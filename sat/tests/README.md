# Validation

From the repository root, run `sbcl --script sat/tests/run.lisp` or
`(asdf:test-system "ooparts/sat")`. The public-interface tests include
96 independently exhaustively checked formulas, negative-literal model queries,
state transitions, atomic input validation, resource ownership and cleanup.
Paths below are relative to `sat/`.

The suite runs 475 public-interface checks, 40 low-level API, parser and representation
checks, and 25 numeric-boundary checks. The latter cover full-width C integer
conversions, double-float rounding, invalid pointer/size rejection, and base-string
DIMACS input. They can also be run separately with `sbcl --script tests/api.lisp`
and `sbcl --script tests/numeric-boundaries.lisp`.

Run `sbcl --non-interactive --load tests/compile-clean.lisp` to force a fresh
compile of all 20 implementation modules with ordinary SBCL diagnostics enabled.
The audit fails on any compiler NOTE or warning, including STYLE-WARNING;
`compiler-diagnostics.json` records the counts. Conditions are not muffled.
The recorded run uses SBCL 2.2.9 on Linux x86-64.

Run `python tests/differential.py --random 1000` for 1,105 deterministic cases.
The batch output columns are case ID, status, conflicts, decisions, propagations,
ticks, reductions, restarts, focused/stable switches, rephasings, eliminations,
vivifications, and (only for SAT) one signed value per declared variable.

`results.json` records the actual run. Every field matches the C implementation
when allocation ordering is matched. Stock libc allocation differs only in the
tick count on add64.cnf in this run, due to the upstream address tie-break.
The 1,000 small random cases also pass an independent exhaustive solver.
Every SAT model is evaluated against its original clauses.

Run `python tests/proofs.py` for six public-API ASCII/binary proof comparisons and
independent RUP checks of all three ASCII UNSAT proofs.
`proof-results.json` records sizes and verified addition counts.

GCC is used only to build the C reference programs. The Lisp implementation
does not load these programs or their object files. Tests use fixed random seed
20261029. Override the SBCL executable with the `SBCL` environment variable.

Timing in results.json includes process startup and cached ASDF loading. It is
not a controlled standalone solver benchmark. No C-speed claim is made.
