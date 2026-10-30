# Testing and recorded validation

Run commands from the repository root. Library and test modules are inferred
from their package declarations. Only `ooparts` and `ooparts-tests` have explicit
ASDF definitions.

## Command matrix

`tools/lisp.py` selects implementation flags, forwards script arguments and
separates ASDF caches per implementation and per native/portable SAT path.

```sh
python3 tools/lisp.py tools/test.lisp all
python3 tools/lisp.py tools/test.lisp prolog
python3 tools/lisp.py tools/test.lisp continuation
python3 tools/lisp.py tools/test.lisp sat
python3 tools/lisp.py tools/test.lisp regexp
python3 tools/lisp.py --implementation ecl tools/test.lisp sat
python3 tools/lisp.py --lisp /path/to/lisp tools/test.lisp
python3 tools/lisp.py --bootstrap setup.lisp tools/test.lisp
python3 tools/lisp.py --portable-sat tools/test.lisp sat
python3 tools/check-layout.py
```

`--implementation` names the host Lisp, `--lisp` points at a custom binary, and
`--bootstrap` loads a setup file before OOPArts. Reader features change compiled
code, so the portable SAT path uses its own cache, as the launcher arranges.

The same suites run directly under SBCL:

```sh
sbcl --dynamic-space-size 2048 --control-stack-size 1 --script tools/test.lisp
sbcl --script tools/test.lisp prolog
```

In an installed or source-registered checkout, `(asdf:test-system "ooparts")`
and `(asdf:test-system "ooparts-tests")` run the complete suite. An individual
facade can be loaded and called directly:

```lisp
(asdf:load-system "ooparts-tests/regexp")
(ooparts-tests/regexp:run-tests)
```

The same pattern applies to `ooparts-tests/continuation`, `ooparts-tests/prolog`
and `ooparts-tests/sat`.

## Recorded totals

The aggregate run prints `110 explicit-stack checks` and `389 native
specializer checks` among its sections, then the suite totals: 3190 continuation
checks, 6027 Prolog checks, 5650 regexp checks and 635 SAT checks. The SAT total
splits into 40 public-API, 51 numeric/representation-boundary, 475 Lisp-interface
(including 96 exhaustive-oracle cases) and 69 arena-storage checks. Exact counts
can depend on test configuration and loaded implementation packages; a printed
failure is never accepted as a pass.

The recorded environment for these runs is SBCL 2.5.4, GCC 13.3 and Linux
x86-64; the aggregate suite runs with a 1 MiB control stack.

See [portability](portability.md) for implementation-neutral launchers,
portable-backend checks and native host adapters. Library and regression systems
require no external Lisp libraries or dependency patches.

## Continuations

```sh
SBCL=sbcl bash tools/continuation/test.sh
```

This runs the 3190 checks and fresh-process FASL/saved-core reload tests. The
independent substitution reducer checks 1328 terms in selective and full modes.
The suite also exercises mutation, multiple values, dynamic control, native
boundaries, deep captures, GC and another thread. It does not mechanically prove
the compiler or capture arbitrary native stacks.

## Prolog

```sh
ISO_SBCL=sbcl python3 -m unittest discover -s tests/prolog/iso -p 'test_*.py' -v
python3 tools/prolog/iso/run.py --baseline tests/prolog/iso/expectations/baseline.json --strict --jobs 2
python3 tools/prolog/iso/run.py --term-model iso --strict --jobs 2 --output build/prolog/iso-strict
```

The runner validates every pinned original/ported file before execution. The
native-model baseline profile records 718 PASS, 56 SKIP and eight exact XFAIL
observations; the strict term-model profile records 726 PASS and 56 SKIP. The
corpus has 782 cases, including upstream-disabled or inapplicable cases.
Thirteen runner tests verify isolation, timeout handling, protocol validation and
expected-difference classification.

`tools/prolog/observations.lisp` emits normalized observations for comparison
with a reference checkout. `OOPARTS_ROOT` selects another checkout with the new
layout. This checks public error context, answer order, sharing and cyclic terms;
ordinary regression tests additionally exercise forced GC and SLG. All 54
normalized observations match the pre-refactor checkout exactly.

## Regexp

The regexp suite runs with the other components through `tools/lisp.py` and
reports 5650 checks. It covers the S-expression language, POSIX ERE text
parsing, both matching engines, leftmost-longest and P-order selection, the
fixed character domain and case folding. See [its documentation](regexp/README.md)
for the behavioural contract.

## SAT

```sh
sbcl --non-interactive --load tools/sat/compile-clean.lisp
python3 tools/sat/differential.py --random 1000
python3 tools/sat/proofs.py
```

The compiler audit forces a fresh compile with ordinary compiler conditions
visible and fails on any NOTE, WARNING or STYLE-WARNING. It does not muffle
conditions. All nine selected storage/implementation/CLI modules compiled with
zero notes and warnings. The recorded reports are in `tests/sat/reports/`.

The differential suite compares 1105 formulas against the pinned C source,
including 1000 small formulas checked by an independent exhaustive solver.
Models are evaluated against the original clauses. Matched allocation order
makes internal counters and models exact despite upstream pointer tie-breaks.
The six public-API proof outputs match C byte-for-byte; all three ASCII UNSAT
proofs are independently RUP-checked.

Elapsed batch time in a correctness report includes startup/loading and is not
a solver speed benchmark. Historical measurements under `benchmarks/` identify
the source snapshots and their timing boundaries.

## Nix and CI

The flake's checks and the CI consumer are described in [Nix flake](nix.md).
`nix flake check` builds the regression checks and the layout/license audit. CI
runs the direct SBCL checks and the Nix checks. A local environment without Nix
cannot establish that the Nix derivations have built successfully; distinguish
source/syntax checks from actual Nix builds when reporting validation.
