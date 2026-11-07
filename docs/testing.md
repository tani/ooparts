# Testing and recorded validation

Run commands from the repository root. Library and test modules are inferred
from their package declarations. Only `ooparts` and `ooparts-tests` have explicit
ASDF definitions.

## Command matrix

`tools/lisp.py` selects implementation flags, forwards script arguments and
separates ASDF caches per implementation and per native/portable SAT path.

```sh
python3 tools/lisp.py tools/test.lisp all
python3 tools/lisp.py tools/test.lisp curry
python3 tools/lisp.py tools/test.lisp test
python3 tools/lisp.py tools/test.lisp prolog
python3 tools/lisp.py tools/test.lisp continuation
python3 tools/lisp.py tools/test.lisp sat
python3 tools/lisp.py tools/test.lisp regexp
python3 tools/lisp.py tools/test.lisp sml
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

An earlier aggregate run printed `110 explicit-stack checks` and `405 native
specializer checks` among its sections, then the suite totals: 3190 continuation
checks, 6066 Prolog checks, 5704 regexp checks and 635 SAT checks. The SAT total
splits into 40 public-API, 51 numeric/representation-boundary, 475 Lisp-interface
(including 96 exhaustive-oracle cases) and 69 arena-storage checks. Exact counts
can depend on test configuration, source checkpoint and loaded implementation
packages; a printed failure is never accepted as a pass.

The observed implementation-specific totals at those earlier checkpoints were:

| Implementation | Native-specializer checks | Prolog checks |
|---|---:|---:|
| CCL | 405 | 6,066 |
| ECL | 402 | 6,063 |
| CLISP | 405 | 6,050 |

On the coherent source/loaded-FASL epoch used by the supported corpus gates,
direct SBCL 2.6.8/Linux arm64 component runs passed **4,081 SML checks** and
**6,097 Prolog checks**. Their logs are
`build/sml/splice-coherence/final-sbcl-sml.stdout` and
`build/sml/splice-coherence/final-sbcl-prolog.stdout`. The SML total splits into
163 lexer, 2,835 parser, 267 native type, 482 Core, 105 structured Basis, and
229 native Module checks. These include nested-match, weak-lifetime,
datatype-replication, ordered overloads, and observable deep
continuation/mutation regressions. These two component runs do not constitute a
new whole-project suite result.

The following complete-project/component timings are earlier independently
measured observations, not a fresh serial validation of the coherent epoch:

| Recorded host | SML checks | Wall time | Peak RSS |
|---|---:|---:|---:|
| SBCL, complete project | 4,081 | 60.61 s | 379,440 KiB |
| CCL, complete SML component | 4,081 | 146.10 s | 86,372 KiB |
| CLISP, complete SML component | 4,081 | 14:38.96 | 107,148 KiB |
| ECL, complete SML component | 4,081 | 18:23.77 | 211,696 KiB |
| ABCL, complete SML component | 4,081 | 19:14.68 | 2,997,812 KiB |

An independent packaged-application run of `nix run .#test-sml-sbcl` rebuilt
with its isolated SBCL and passed all 4,081 checks in 61.98 seconds on the
current application source. This is packaged SBCL evidence, not a system-SBCL,
CCL, or whole-flake result. The independent, ordinary ABCL SML component also
completed all 4,081 checks with natural process exit 0 in 1,647.13 seconds and
2,485,276 KiB peak RSS on its own new private cache of 67 fingerprinted FASLs.
The six groups were 163 lexer, 2,835 parser, 267 types, 482 core, 105 Basis,
and 229 native Modules. This is a component result connected to a successful
process termination, not an earlier mixed-generation or post-deadline counter.
It does not make the separate ABCL whole-project warning-restart failure or
ECL whole-project reference-reduction timeout a passing whole-project result.
See `build/sml/abcl-serial-validation/report.md` and its aligned log/metadata.
A current `nix run .#test-sml-ccl` application run
also rebuilt its CCL, SML, and test derivations and completed all 4,081 SML
checks in 188.30 seconds. These are isolated application results, not all
whole-project or every Nix check execution. Earlier `nix run .#test-sml-sbcl` and
`nix run .#test-sml-ccl` component runs took 47.20 and 143.45 seconds
respectively and belong to their recorded source checkpoints, not the coherent
epoch above. ABCL and ECL have both completed the
entire SML component on the earlier instantiate-repair engine. ABCL completed
all native-module groups as well, with no Java initialization/runtime error.
Their longer measured runs required explicitly recorded duration budgets;
they do not claim that the earlier 900-second invocations completed. Keep
these host results associated with their recorded fingerprints rather than
combining them with a different semantic-writing epoch. CLISP also passed
all 4,081 checks on one live run, but `src/prolog/kernel/gc.lisp` changed
during that run. It therefore is not a final uniform-fingerprint attestation
for the pending GC optimization and must be rerun with matching source and
compiled artifacts. Host compilation may emit style-only diagnostics for
unused generated lexical bindings; these are separate from semantic failure
and captured SML output bytes. CLISP also retains pre-existing ASDF/grammar,
docstring-placement and unused-variable warnings; they are not suppressed. The
historical CLISP 245-check/`Program stack overflow` diagnostics remain of
unknown current status; the native metadata repair is not claimed to settle
them or to provide a fresh serial CLISP gate.

The full unchanged 250,000-call curried control executed on CCL in 0.587
seconds with exact `250000\n` output. Its native function-metadata registry
uses CCL's weak-key EQ table. SBCL, ABCL, and ECL also retain their weak
metadata registries; other hosts use the portable ordinary EQ table. Only replaceable native
call-protocol metadata is weak. SML values, reference cells, nominal/module
identities, and inference state are not weak registry contents. A saved partial
application and its distinct captured arguments survived forced full CCL GCs.

The Module regressions cover independent named signature occurrences, opaque
versus rigid type realization, datatype replication, signature equality,
outer-basis refinement, sharing, aliases, generative functors, and
namespace-safe `open`. Sharing resolves each noninitial participant once per
operation and reuses those exact views for suffix pairs without persistent view
caches. These checks do not imply completion of the full ABCL suite or every
MLton program. See [the MLton runner documentation](sml/conformance.md) for
exact oracle sizes, negative-case controls, and separate ordinary-case limits.

The public compiler also passed three separately selected MLton output cases
(`hello-world.sml`, `fact.sml`, and `functor.sml`). They are individual probes,
not the aggregate corpus result below.

The coherent supported-corpus gate is consolidated in
`build/sml/splice-coherence/final-result.json`. Its ordinary report discovered
288 sources, selected 98, and recorded **77 `PASS` outcomes**: 69 normal
executions with exact oracles, two intentional-nonzero executions with exact
oracles, and six required compile-only successes. The other 21 selected cases
actually executed but are `NO-ORACLE`, not passes; the remaining 190 sources were
`NOT-SELECTED`, not demonstrated successes or richer-Basis support. The
supported negative report selected 111 of 117 sources and passed all 111
(104 source rejections plus seven explicitly reviewed intentional unbound
identifiers), leaving six sources `NOT-SELECTED`. Full 239,194-byte COBOL
completed genuine execution in two isolated runs and again inside the ordinary
batch under the 1 GiB heap and 360-second case timeout; all three are
`NO-ORACLE`, with no inferred empty-output oracle. The manifest records 59 stable
loaded FASLs across these gates. Exact oracle paths, heavy-input byte counts,
compile-only semantics, and artifact hashes are in [the MLton runner
documentation](sml/conformance.md).

The consolidated record does not establish fresh serial ABCL/ECL/CLISP/CCL
gates, a current whole-project SBCL run beyond the two components above, or
completion of the 16 named Nix checks and 293 layout checks.
`nonterminate/8.sml` awaits an actual
current host-compilation result; its mandated disposition remains compile-only,
never execution for an output comparison. Older component successes and resource
failures remain associated with their own checkpoints rather than filling these
gaps.

A prior aggregate-check environment was SBCL 2.5.4, GCC 13.3 and Linux x86-64;
its aggregate suite ran with a 1 MiB control stack. This is separate from the
SBCL 2.6.8/Linux arm64 semantic checkpoint above.

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
