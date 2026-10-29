# SAT validation

All commands run from the repository root:

```sh
sbcl --script tools/test.lisp sat
sbcl --non-interactive --load tools/sat/compile-clean.lisp
python3 tools/sat/differential.py --random 1000
python3 tools/sat/proofs.py
```

The Lisp suite checks resource/state ownership, atomic input validation, DIMACS,
models and signed literals. Its 475 public-interface checks include 96 formulas
checked by independent exhaustive search. Low-level API and representation tests
add 40 checks; numeric tests cover full-width conversions, rounding, wrapping
generalized-place updates, and invalid pointer/arena-size rejection. Arena
storage adds 63 to 69 checks for cross-width byte access, signed boundaries,
known float encodings, overlap copying, filling, arena growth and stable
load-time string addresses that allocate no storage on repeated evaluation.
See [portability](../portability.md) to repeat these checks on other runtimes
or force the portable backend on SBCL.

The compiler audit forces all five SAT library modules and the CLI to compile with normal
SBCL diagnostics. It fails on any NOTE, WARNING or STYLE-WARNING, without
muffling conditions. `tests/sat/reports/compiler-diagnostics.json` records zero
notes and warnings on SBCL 2.2.9, Linux x86-64.

The differential report contains 1,105 cases: bundled upstream formulas,
structured stress cases and 1,000 independently exhaustively checked random
formulas. Every status and model is checked. With matched allocation ordering,
the model and every recorded internal counter match C, including conflicts,
decisions, propagations, ticks, reductions, restarts, mode switches, rephasings,
eliminations and vivifications. Stock libc ordering can change ticks because
the original solver uses pointer addresses to break ties.

The proof suite compares six public-API ASCII/binary outputs byte-for-byte with
C. All three ASCII UNSAT proofs additionally pass independent RUP verification.
Reports live in `tests/sat/reports/`; transient binaries and output go in `build/sat/`.
Tests use seed 20261029. `SBCL` overrides the Lisp executable. GCC only builds
independent reference programs; the Lisp solver never loads their object code.

Correctness-report elapsed time includes startup/loading and is not a controlled
speed comparison. [Historical benchmarks](../../benchmarks/sat/README.md)
identify the measured source versions and timing boundaries.

The `literals-native-*` and `literals-portable-*` reports repeat the 1,105-case
differential and six-proof checks after replacing the engine's 212 parameter
bindings with two numeric constants and load-time string literals.
