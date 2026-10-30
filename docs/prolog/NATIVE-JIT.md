# Native predicate specialization

`ooparts/prolog` specializes eligible predicate groups into compiled Common
Lisp functions at query time. Specialized calls use fixed Lisp arguments, local
variables, direct matching/arithmetic and direct calls; they never dispatch WAM
instructions. Deep semidet recursion that would exhaust the host stack continues
on a second tier that keeps its activations in a heap arena and transfers control
with static jumps and integer resume tokens. Ineligible or unsupported executions
keep the complete interpreted implementation, so observable Prolog semantics do
not depend on the policy.

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
  (1- multiple-values-limit))`, and at most 1,048,576 explicit-stack slots per
  attempt.

## Two execution tiers

Compiled groups run on two tiers with identical semantics.

| Tier | Activation storage | Bound |
| --- | --- | --- |
| Direct | one host frame per generated call | logical depth 256 |
| Explicit stack | private adjustable heap arena | arena slot limit |

The direct tier is emitted first: fixed Lisp arguments, local variables, direct
matching/arithmetic and direct calls. When its logical-depth check trips, the
same attempt is offered to an explicit-stack function compiled from the identical
verified definition group that the direct compiler already built. Only that
promotion exists; a mode that is not depth-limited never touches the second tier.

The second tier lowers the same generated bodies into one `tagbody`. A call
checks and grows the arena, evaluates its inputs with the caller's base, writes
the callee frame - header slots for the parent base, the success token and the
failure token, then mask-ordered inputs and one fixed register slot per generated
binding - advances the base and jumps to a static entry label. A return publishes
outputs into a per-attempt result vector, clears the dying frame and dispatches on
a dense integer token, so no closure, argument list or per-term dispatch is built.
Enumerated definitions and `findall/3` generators keep their bounded Lisp
recursion and act as synchronous bridges: the collector runs to completion before
the caller resumes, so no frame offset is captured across a suspension.

## Bounded attempts and atomic commit

Each outer attempt owns one budget: 1,000,000 generated entries, logical depth
256, 65,536 collected answers and the arena slot limit. A depth overflow on the
direct tier is not a bailout: the promoted attempt continues with the same
constants, inputs and remaining fuel and answers, and counts once. Crossing any
other bound - or the depth bound again - throws the same private bailout tag, and
only then is the call replayed by the WAM. Suppression is generation qualified, so
a later clause publication re-enables the mode. Attempt-level guards are ordinary
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
python3 benchmarks/prolog/jit-compare.py --sbcl sbcl --repeats 30 --batch 3 \
  --output build/prolog/jit-comparison.json
```

The tool runs `:wam` and `:auto` in two counterbalanced fresh-process rounds on
the identical sources, validates all six results and retains per-round samples,
native-use counts and medians. Correct results, actual compiled execution and
lower warmed medians for the generated-search workloads are the acceptance
evidence; no SWI-Prolog parity gate applies.

Recorded 2026-10-30 with SBCL 2.5.4 on aarch64-linux, 30 samples per case per
round, batch 3, in two counterbalanced fresh processes with a 1 MB control stack.
Interquartile spread of those samples was 0.2-3.9% of each median, and the two
rounds agreed within 1.6%, so the medians below are stable rather than one lucky
ordering.
Times are warmed CPU milliseconds per query and allocation is bytes per query;
both policies produced every expected result (`92, 5, 1200, 2000, 1024, 12799`).

| Workload | `:wam` | `:auto` | Speedup | Native calls/deopts | Cold compile | Allocated `:wam` / `:auto` |
| --- | ---: | ---: | ---: | --- | ---: | --- |
| 8 queens, all solutions | 117.6 ms | 1.05 ms | 112.2x | 1 / 0 | 28 ms | 143 MB / 1.6 MB |
| Takeuchi (16,10,4) | 212.4 ms | 0.87 ms | 245.6x | 1 / 0 | <1 ms | 243 MB / 31 KB |
| Naive reverse, 1200 | 2281 ms | 71.5 ms | 31.9x | 1 / 0 | 375 ms | 1.28 GB / 11.9 MB |
| Quicksort, 2000 | 216.5 ms | 6.16 ms | 35.2x | 1 / 0 | 6 ms | 167 MB / 1.4 MB |
| Graph, 1024 paths | 539.5 ms | 1.01 ms | 532.6x | 1 / 0 | 1 ms | 788 MB / 2.3 MB |
| Symbolic differentiation | 55.6 ms | 0.42 ms | 133.7x | 1 / 0 | <1 ms | 60 MB / 99 KB |

These are comparisons against this checkout's interpreted backend, not the
historical x86-64 figures in [NATIVE-ABLATION.md](NATIVE-ABLATION.md). Every case
now runs completely natively: exactly one native attempt and no replay, cold and
warm, including the deep list recursion that used to fall back.

The same tool, host and flags were run against the parent revision in a separate
worktree before the tier was introduced, in the same counterbalanced order:

| Workload | `:auto` before | `:auto` after | Allocated before / after | Native before / after |
| --- | ---: | ---: | ---: | --- |
| Naive reverse, 1200 | 2654 ms | 71.5 ms | 1710 MB / 11.9 MB | 3 calls, 2 deopts / 1 call, 0 |
| Quicksort, 2000 | 222.1 ms | 6.16 ms | 188 MB / 1.34 MB | 4002 calls, 2 deopts / 1 call, 0 |
| Graph, 1024 paths | 539.6 ms | 1.02 ms | 790 MB / 2.33 MB | 0 calls, 3 deopts / 1 call, 0 |

Allocation drops by two to four orders of magnitude because intermediate answer
graphs stay in the private arena instead of being interpreted, and the
`:wam` medians of the two runs agree within noise, so the comparison is between
the two engine policies rather than between two host states. `reverse` remains
slower than the other specializations in absolute terms because its helper chain
is quadratic, not because part of it still runs on the WAM.
`benchmarks/prolog/competitive.lisp`
enforces exactly one native call and zero deoptimizations for `reverse` and
`quicksort` on the cold run and on every warm query whenever compilation is
enabled. `benchmarks/prolog/jit-compare.py` requires at least one native call in
both counterbalanced rounds for queens, tak, reverse and qsort, and additionally
exactly one call with no replay for reverse and qsort, while still recording all
six cases so shallow-path regressions stay visible.

### SWI-Prolog reference

`benchmarks/prolog/compare.py --sbcl sbcl --swipl swipl` on the same host, 30
samples, `BENCH_BATCH=3`, SWI-Prolog 9.2.9 `-O` (used only as a reference; no
parity gate applies):

| Workload | `:auto` | SWI `-O` | `:auto` vs SWI |
| --- | ---: | ---: | ---: |
| 8 queens | 1.07 ms | 2.41 ms | 2.25x faster |
| Takeuchi (16,10,4) | 0.87 ms | 4.16 ms | 4.77x faster |
| Naive reverse, 1200 | 71.6 ms | 18.7 ms | 3.82x slower |
| Quicksort, 2000 | 6.18 ms | 3.75 ms | 1.65x slower |
| Graph, 1024 paths | 1.00 ms | 0.33 ms | 3.01x slower |
| Symbolic differentiation | 0.42 ms | 0.82 ms | 1.98x faster |

Queens, Takeuchi and differentiation are ahead of optimized SWI. The remaining
deficits are structural rather than interpretive: `reverse` builds two quadratic
lists in portable Lisp, `quicksort` sorts a pseudo-random permutation without
specialized comparison or destructive update, and `route(X, D, Y)` re-scans the
`edge/2` fact relation per call because the ground-fact index is keyed on the
coarse available scalars instead of being a first-argument index. No part of those
three workloads is executed by the WAM any more, so closing the gaps needs better
data structures and fact indexing, not more native code.

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

`run-native-stack-tests` in the same file covers the explicit-stack tier
portably: deep and mutually recursive non-tail bodies, the benchmark helper chain
inside one wrapper body, multi/absent/NIL outputs, cut placement, output sharing
and atom identity after promotion, the synchronous collector bridge, fuel and
answer budget sharing across exactly one promotion, arena slot limits, and a
non-integer arithmetic guard after a deep prefix. Every case compares ordered
answers, truth values and delays against the WAM on a fresh database in both term
models, and asserts native statistics only where a query has a single public
attempt.
