# Testing and recorded validation

Run commands from the repository root. Library and test modules are inferred
from their package declarations. Only `ooparts` and `ooparts-tests` have explicit
ASDF definitions.

```sh
sbcl --dynamic-space-size 2048 --control-stack-size 1 --script tools/test.lisp
python3 tools/check-layout.py
```

In an installed/source-registered checkout, `(asdf:test-system "ooparts")` and
`(asdf:test-system "ooparts-tests")` run the complete suite. Individual modules
use `tools/test.lisp continuation`, `prolog` or `sat`, or load the matching
`ooparts-tests/<component>` and call its exported `run-tests`.

## Recorded environment

The 2026-10-29 local run used SBCL 2.2.9.debian, GCC 13.3 and Linux x86-64.
The aggregate suite ran with a 1 MiB control stack. It passed 3073 continuation,
5632 Prolog and 560 SAT API/numeric checks. Exact counts can depend on test
configuration and loaded implementation packages; a printed failure is never
accepted as a pass.

## Continuations

```sh
SBCL=sbcl bash tools/continuation/test.sh
```

This runs the 3073 checks and fresh-process FASL/saved-core reload tests. The
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

The runner validates every pinned original/ported file before execution. Native
mode records 718 PASS, 56 SKIP and eight exact XFAIL observations; ISO term mode
records 726 PASS and 56 SKIP. The corpus has 782 cases, including upstream-disabled
or inapplicable cases. Thirteen runner tests verify isolation, timeout handling,
protocol validation and expected-difference classification.

`tools/prolog/observations.lisp` emits normalized observations for comparison
with a reference checkout. `OOPARTS_ROOT` selects another checkout with the new
layout. This checks public error context, answer order, sharing and cyclic terms;
ordinary regression tests additionally exercise forced GC and SLG. All 54
normalized observations match the pre-refactor checkout exactly.

## SAT

```sh
sbcl --non-interactive --load tools/sat/compile-clean.lisp
python3 tools/sat/differential.py --random 1000
python3 tools/sat/proofs.py
```

The compiler audit forces a fresh compile with ordinary compiler conditions
visible and fails on any NOTE, WARNING or STYLE-WARNING. It does not muffle
conditions. All six implementation/CLI modules compiled with zero notes and warnings.
The recorded reports are in `tests/sat/reports/`.

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

The root flake exposes only supported component/implementation combinations.
`nix flake check` builds their regression checks and the layout/license audit.
CI runs the direct SBCL checks and the Nix checks. A local environment without
Nix cannot establish that the Nix derivations have built successfully; distinguish
source/syntax checks from actual Nix builds when reporting validation.
