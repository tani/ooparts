# Type declaration experiment (SBCL)

[Documentation](index.md) · [Original benchmark report](BENCHMARKS.md)

Adding type declarations alone produced workload-specific, modest changes, but
no consistent general speedup. The production sources are unchanged. Two
experimental patches and all measurements are retained for reproduction.

## Scope

Baseline: commit `fa135fd2c2f0ff9fcf08e9ad8f21e36e1f5337a3`.
No indexing, scalar fast paths, graph traversal changes, new data representations,
inlining declarations, or optimization-policy changes were introduced.

- **Narrow:** declare VM parameters as `machine` in the engine, WAM and GC
  functions. `instantiate` accepts a nullable VM. This includes `unify`,
  `record-cell`, `run-machine`, register access and garbage collection.
- **Broad:** also describe machine code/register/ownership vectors, bounded
  program counters and slot indices; declare selected local cons cells,
  vector accesses, register indices, logic variables and the reification name
  hash table. Statistical counters and GC thresholds remain unbounded.

The broad patch supports adjustable vectors: SLG copies register environments
into vectors with fill pointers, and dynamic builtin alternatives also use
adjustable code vectors. Declaring these slots as `simple-vector` would be
incorrect. Arbitrary Prolog terms remain of type `t`; they can be atoms,
logic variables, shared cons graphs or cyclic cons graphs.

## Measurements

> **Historical record.** Every figure below, including the check count, is a
> measurement of the pinned baseline commit and its two patches. It is not
> current performance or the current test inventory; see [BENCHMARKS.md](BENCHMARKS.md)
> for current measurements.

SBCL 2.2.9.debian, 2 GiB dynamic-space ceiling and 1 MiB control stack, in the
same environment as the original benchmark. Separate source trees and ASDF
cache paths prevent one variant's definitions from contaminating another.
Processes ran sequentially, in this order:

`baseline, broad, narrow, narrow, broad, baseline`

Each process warmed all 13 workloads and recorded five runs, reversing workload
order on alternating iterations. Setup and explicit full host GC are outside
measurements. The table pools the two batches: 10 samples per workload/variant,
390 measured runs in total. Exploratory runs used to select the candidates are
excluded from these results.

Run time medians in milliseconds; all-answer workloads include answer export.

| Workload | Baseline | Narrow | Broad |
| --- | ---: | ---: | ---: |
| Host tail recursion, 100k | 186.0 | 188.0 | 192.0 |
| Arithmetic tail recursion, 100k | 396.0 | 402.0 | 398.0 |
| Lexical `let`, 100k | 246.0 | 244.0 | 248.0 |
| List walk, 10k | 16.0 | 16.0 | 16.0 |
| Append, 10k | 24.0 | 24.0 | 24.0 |
| Unify a 100k-element list | 48.0 | 46.0 | 48.0 |
| DCG, 10k tokens | 32.0 | 30.0 | 28.0 |
| Allocation loop, GC threshold 64 | 186.0 | 182.0 | 196.0 |
| Allocation loop, GC threshold 4096 | 184.0 | 180.0 | 186.0 |
| Allocation loop, VM GC disabled | 196.0 | 190.0 | 192.0 |
| Last of 1000 facts, 1000 queries | 294.0 | 278.0 | 298.0 |
| SLG path, 1000 answers | 364.0 | 364.0 | 384.0 |
| All append splits, 1000 elements | 112.0 | 114.0 | 120.0 |

[CSV](../../benchmarks/prolog/type-declarations/results.csv) includes min/max, build/export
times and cumulative allocation; [raw rows](../../benchmarks/prolog/type-declarations/results.sexp)
also retain answer counts and VM statistics. Each workload has the same answers,
instruction counts, managed allocations and GC counts across the variants.
Run/export allocation medians are unchanged to the displayed precision.

The narrow candidate improves fact scanning by about 5.4% in pooled medians,
while broad declarations slow SLG by about 5.5% and all-answer append by about
7.1%. Ranges overlap. The apparent DCG improvement is only one 4 ms wall-clock
step for broad declarations; short workloads need longer aggregate timing
before interpreting this as a reproducible relative speedup. No statistical
significance claim is made for these shared-host measurements.

## Interpretation and decision

SBCL already infers types for many local objects created by `cons`,
`make-array` and `make-hash-table`. VM parameter declarations can remove
repeated structure checks. More specific declarations can also increase code
size and move vector/bounds checks into hot functions; shorter source does not
imply faster machine code.

The major graph bottleneck is allocating work lists and hash tables even for
scalar terms. Type declarations retain these allocations. Similarly, declarations
cannot avoid scanning irrelevant clauses or copying every exported answer graph.
The arithmetic evaluator accepts several numeric types and interprets heterogeneous
expressions; assuming all values are fixnums or floats would change its contract.

Both candidates passed **4,190 checks at that revision**, including cyclic terms,
VM GC, SLG, cut, dynamic predicates, interactive queries and lexical bindings,
with a 1 MiB host control stack. This validates the exercised behaviors, rather than
proving every internal caller satisfies the declarations.

**Decision:** retain the experiment, but do not apply either patch wholesale.
The narrow patch is a candidate for a later, focused investigation of dispatch
functions. Neither patch resolves the allocation bottleneck, and the broader
patch introduces measurable regressions. Production source files remain byte
identical to the baseline.

## Reproduction

Use a clean checkout of the baseline for each candidate. From that checkout:

```sh
# Baseline: do not apply a patch.
# Narrow: git apply /path/to/ooparts/prolog/benchmarks/type-declarations/narrow.patch
# Broad:  git apply /path/to/ooparts/prolog/benchmarks/type-declarations/broad.patch
BENCH_RESULTS=/tmp/type-results.sexp sbcl --dynamic-space-size 2048 --control-stack-size 1 --script benchmarks/prolog/run.lisp
sbcl --dynamic-space-size 2048 --control-stack-size 1 --script tools/test.lisp prolog
```

Repeat the six-process sequence above with unique result filenames. Stored raw
rows add `:variant` and `:batch` to the standard benchmark property lists. To
regenerate the summary of the stored measurements, run from this repository root:

```sh
sbcl --script benchmarks/prolog/type-declarations/summarize.lisp
```
