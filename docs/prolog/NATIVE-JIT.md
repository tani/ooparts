# Native predicate specialization

`ooparts/prolog` specializes eligible predicate groups into compiled Common
Lisp functions at query time. Specialized calls use fixed Lisp arguments, local
variables, direct matching/arithmetic and direct calls; they never dispatch WAM
instructions. Ineligible or unsupported executions keep the complete interpreted
implementation, so observable Prolog semantics do not depend on the policy.

## Execution policy

`make-database` accepts `:execution-mode`, and `database-execution-mode` reports
it. The policy is independent of `:term-model`.

| Mode | Behavior |
| --- | --- |
| `:auto` (default) | Compile and use eligible predicate groups; fall back otherwise |
| `:wam` | Never compile or execute native code; byte-for-byte interpreted oracle |

Setting `OOPARTS_PROLOG_DISABLE_NATIVE=1` in the process environment before the
module loads selects the interpreted path for every database, which the suite
uses as a full semantic oracle.

```lisp
(let ((*database* (make-database :execution-mode :wam)))
  (load-prolog-string "fac(0,1) :- !. fac(N,R) :- N>0, M is N-1, fac(M,S), R is N*S.")
  (query '((fac 10 ?r))))
```

`query-statistics` reports `:native-calls` (handled native success or logical
failure) and `:native-deoptimizations` (privately aborted native attempts that
were replayed on the WAM). Remaining fields keep counting interpreted work; they
are not comparable between policies.

## Eligibility

A mode is a resolved predicate name, arity, ground-input bitmask and enumeration
kind. Compilation is attempted only for a closed group of pure clauses:

- Arguments are classified at the call: unbound output variables must be
  distinct, and every input must be ground, acyclic and dereference-clean.
- Bodies may use `true`, `fail`, conjunction, source cuts, ground equality,
  integer `is`/comparisons, user calls and `findall/3` over a statically known
  generator. Host callbacks, lexical environments, control/disjunction goals,
  meta-calls, IO, table operations, exceptions and conditional derivations keep
  the WAM.
- Ordinary calls must be deterministic or semideterministic: pairwise disjoint
  known-input heads or a source cut must rule out multiple successes. Atoms are
  compared for overlap by canonical atom name, so two Lisp symbols with one Prolog
  spelling are not treated as disjoint.
- Arithmetic is limited to integer `+`, `-`, `*`, `mod`, `rem`, `min`, `max`,
  `abs` and the integer comparisons. Floats, rationals, unbound operands and zero
  divisors abort the attempt, leaving the authoritative WAM exception and context.
- Source templates must be proper, finite, unshared cons trees of depth at most
  64. Graph-shaped or cyclic source terms stay interpreted.
- Size limits protect the host: at most 128 compiled modes per group, arity at
  most `(min 64 (- call-arguments-limit 4) (- lambda-parameters-limit 4)
  (1- multiple-values-limit))`.

## Bounded attempts and atomic commit

Each outer attempt owns one budget: 1,000,000 generated entries, logical depth
256 and 65,536 collected answers. Crossing a bound throws a private bailout tag
and the call is replayed by the WAM; suppression is generation qualified, so a
later clause publication re-enables the mode. Attempt-level guards are ordinary
declines, not logical failures.

A successful native result is adopted atomically: outputs are validated, their
newly produced cons cells are registered once with the VM, and output variables
are bound. Tail success restores the caller's continuation; non-tail success
resumes the caller's current code without an extra frame; a native logical
failure backtracks. Nothing is committed before the result is known, so aborted
attempts leave bindings, trail, heap, choices and effectful state untouched.

Instrumentation remains observable: replacing the protocol term dispatcher or
its registered provider makes attempts decline until the original function cells
are restored. Cursors, tabling, SLG workers, delayed derivations and conditionals
always use the WAM.

## Provenance and measurements

The port starts from the cons-prolog source-level compiler at revision
`6da5c8e4ff692fb1da887835452fd625b33f2731` (recorded in
[`third-party.json`](../../third-party.json)) and was adapted to the current
model, engine, term bridge and budget design. The historical ablation figures in
[NATIVE-ABLATION.md](NATIVE-ABLATION.md) describe a different revision and are
not evidence for this implementation.

Measure and reproduce with the shared public workload:

```sh
python3 benchmarks/prolog/jit-compare.py --sbcl sbcl --repeats 7 --batch 20 \
  --output build/prolog/jit-comparison.json
```

The tool runs `:wam` and `:auto` in two counterbalanced fresh-process rounds on
the identical sources, validates all six results and retains per-round samples,
native-use counts and medians. Correct results, actual compiled execution and
lower warmed medians for the generated-search workloads are the acceptance
evidence; no SWI-Prolog parity gate applies.

Recorded 2026-10-30 with SBCL 2.5.4 on aarch64-linux, 7 samples per case per
round, batch 20. Times are warmed CPU milliseconds per query; allocation is bytes
per query; both policies produced every expected result (`92, 5, 1200, 2000,
1024, 12799`).

| Workload | `:wam` | `:auto` | Speedup | Native calls/deopts | Cold compile | Allocated `:wam` / `:auto` |
| --- | ---: | ---: | ---: | --- | ---: | --- |
| 8 queens, all solutions | 106.7 ms | 0.98 ms | 108.9x | 1 / 0 | 28 ms | 143 MB / 1.5 MB |
| Takeuchi (16,10,4) | 203.1 ms | 0.82 ms | 248.0x | 1 / 0 | 1 ms | 245 MB / 13 KB |
| Naive reverse, 1200 | 2344 ms | 2790 ms | 0.84x | 3 / 2 | 2.49 s | 1.33 GB / 1.86 GB |
| Quicksort, 2000 | 247.1 ms | 244.3 ms | 1.01x | 4002 / 2 | 0.30 s | 169 MB / 189 MB |
| Graph, 1024 paths | 541.6 ms | 541.9 ms | 1.00x | 0 / 3 | 0.63 s | 792 MB / 794 MB |
| Symbolic differentiation | 42.7 ms | 0.374 ms | 114.2x | 1 / 0 | <1 ms | 60 MB / 74 KB |

These are comparisons against this checkout's interpreted backend, not the
historical x86-64 figures in [NATIVE-ABLATION.md](NATIVE-ABLATION.md). Generated
search specializes completely and drops allocation by one to four orders of
magnitude. `reverse` exceeds the logical-depth budget: every new cursor attempts
the mode, reaches depth 257 with private intermediate graphs, and then replays
the whole query on the interpreter, which accounts for the 16% regression. The
quicksort and graph cases are bounded fallbacks dominated by interpretation and
stay within measurement noise. This conservative behaviour is the designed
tradeoff, not an outstanding optimization.

## Host notes

`tests/prolog/syntax/native.lisp` runs identically on the portable hosts the
launcher exposes. Three assertions about exception shapes are gated on the
interpreted result instead of a fixed expectation, because ECL's `(mod 1 0)`
returns the dividend and therefore its WAM raises no `evaluation_error`: one in
the cut/bailout group and one per term model in the arithmetic-boundary group.
The native path still has to reproduce the interpreted outcome, and it does. No
semantic case is skipped on an available host.

## Tests

`tests/prolog/syntax/native.lisp` covers the automatic path, `:wam` and
process-disabled oracles, cut/failure placement, lazy answers, `findall` bags and
graph isolation, atom identity, transactional bailout, cache invalidation,
instrumentation, forced GC, high arity, tabled and ISO boundaries.
