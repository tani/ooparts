# Prolog benchmarks and measurements

This is the canonical home for current Prolog performance measurements and their
reproduction commands. The execution contract behind the numbers is in
[NATIVE-JIT.md](NATIVE-JIT.md); historical investigations and superseded
optimizers are archived below under [Historical records](#historical-records-superseded).

## Current native execution measurements

Recorded 2026-10-30 with SBCL 2.5.4 on aarch64-linux, 30 samples per case per
round, `BENCH_BATCH=3`, in two counterbalanced fresh-process rounds on the
identical sources with a 1 MiB control stack. Times are warmed CPU milliseconds
per query; allocation is cumulative SBCL bytes per query. Both policies produced
every expected result (`92, 5, 1200, 2000, 1024, 12799`).

Every case executes completely natively: exactly one native call and zero
deoptimizations, both cold and warm. Deep semidet recursion is promoted once from
the direct tier to the explicit-stack tier within that same attempt; no case is
replayed by the interpreter. Allocation falls sharply relative to the WAM - from
143.17 MB to 1.558 MB on queens and from 1280.12 MB to 11.937 MB on reverse -
because intermediate answer graphs stay in the private arena.

Interquartile spread of the samples was 0.2–3.9% of each median, and the two
counterbalanced rounds agreed within 1.6%, so the medians are stable rather than
one lucky ordering.

| Workload | `:wam` ms | `:auto` ms | Speedup | Allocated `:auto` MB | Allocated `:wam` MB | `:auto` cold compile ms |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 8 queens, all solutions | 117.58 | 1.048 | 112.17x | 1.558 | 143.17 | 28.3 |
| Takeuchi (16,10,4) | 212.38 | 0.865 | 245.58x | 0.031 | 242.94 | 0.9 |
| Naive reverse, 1200 | 2281.14 | 71.547 | 31.88x | 11.937 | 1280.12 | 374.7 |
| Quicksort, 2000 | 216.47 | 6.156 | 35.16x | 1.370 | 166.71 | 6.1 |
| Graph, 1024 paths | 539.48 | 1.013 | 532.61x | 2.349 | 788.06 | 1.3 |
| Symbolic differentiation | 55.61 | 0.416 | 133.72x | 0.099 | 59.84 | 0.4 |

`reverse` remains slower than the other specializations in absolute terms because
its helper chain is quadratic, not because part of it still runs on the WAM.
Cold compile is reported separately from warmed queries; it is not included in
the `:auto` milliseconds column.

### Pre-tier baseline

The same tool, host and flags were run against the parent revision in a separate
worktree before the explicit-stack tier was introduced, in the same
counterbalanced order. At that revision deep list recursion exceeded the direct
tier's depth bound and was replayed by the interpreter, which is visible in the
call/deoptimization counts.

| Workload | `:auto` before ms | `:auto` after ms | Allocated before / after MB | Native before / after |
| --- | ---: | ---: | ---: | --- |
| Naive reverse, 1200 | 2653.7 | 71.547 | 1709.6 / 11.937 | 3 calls, 2 deopts / 1 call, 0 |
| Quicksort, 2000 | 222.1 | 6.156 | 187.6 / 1.370 | 4002 calls, 2 deopts / 1 call, 0 |
| Graph, 1024 paths | 539.6 | 1.013 | 790.0 / 2.349 | 0 calls, 3 deopts / 1 call, 0 |

The `:wam` medians of the two runs agree within noise, so the comparison is
between the two engine policies rather than between two host states.
`benchmarks/prolog/competitive.lisp` requires exactly one native call and zero
deoptimizations for `reverse` and `quicksort` on the cold run and on every warm
query whenever compilation is enabled. `benchmarks/prolog/jit-compare.py`
requires at least one native call in both counterbalanced rounds for queens, tak,
reverse and qsort, and additionally exactly one call with no replay for reverse
and qsort, while still recording all six cases so shallow-path regressions stay
visible.

### SWI-Prolog reference

`benchmarks/prolog/compare.py` on the same host, 30 samples, `BENCH_BATCH=3`,
SWI-Prolog 9.2.9 with `-O`. This is used only as a reference; no SWI parity gate
applies.

| Workload | `:auto` ms | SWI `-O` ms | `:auto` vs SWI |
| --- | ---: | ---: | ---: |
| 8 queens | 1.072 | 2.408 | 2.25x faster |
| Takeuchi (16,10,4) | 0.872 | 4.157 | 4.77x faster |
| Naive reverse, 1200 | 71.576 | 18.742 | 3.82x slower |
| Quicksort, 2000 | 6.181 | 3.754 | 1.65x slower |
| Graph, 1024 paths | 1.002 | 0.333 | 3.01x slower |
| Symbolic differentiation | 0.415 | 0.820 | 1.98x faster |

Queens, Takeuchi and differentiation are ahead of optimized SWI. The remaining
deficits are structural rather than interpretive: `reverse` builds two quadratic
lists in portable Lisp, `quicksort` sorts a pseudo-random permutation without a
specialized comparison or destructive update, and `route(X, D, Y)` re-scans the
`edge/2` fact relation per call because the ground-fact index is keyed on the
available scalars instead of being a first-argument index. No part of those three
workloads is executed by the WAM any more, so closing the gaps needs better data
structures and fact indexing, not more native code.

### Reproduction

Run from the repository root:

```sh
python3 benchmarks/prolog/jit-compare.py --repeats 30 --batch 3 --output build/prolog/jit-comparison.json
BENCH_BATCH=3 python3 benchmarks/prolog/compare.py --repeats 30 --output build/prolog/swi-comparison.json
python3 tools/lisp.py tools/test.lisp all
```

The first command runs `:wam` and `:auto` in two counterbalanced fresh-process
rounds on identical sources, validates all six results, and retains per-round
samples, native-use counts and medians. The second compares the same shared
sources against SWI-Prolog. The third is the aggregate correctness suite.

Host and flags belong to the recorded run above; re-running on other hardware or
runtime versions may produce different ratios. Do not convert the historical
x86-64 figures into current multipliers.

## Historical records (superseded)

The following investigation describes the interpreter-only revision
`be479795e11bcbd6f84ca2020e53c8dd17a9e992` (0.9.1) on 2026-10-12 JST. It
predates predicate specialization and the explicit-stack tier. Its tables are a
separate diagnostic record of interpreter bottlenecks, not current measurements,
and are kept for provenance. Runtime code was unchanged by that investigation.

The main opportunities identified then were avoiding generic graph machinery for
scalar values, adding first-argument indexing, reducing large-term
compilation/allocation and reducing repeated answer copying. VM GC was effective
at limiting retained cells; disabling it did not provide a clear throughput
benefit on the garbage workload.

### Method

- SBCL 2.2.9.debian, Linux x86-64, AMD EPYC 9V74 virtual machine.
- The container exposes nine logical CPUs, an eight-CPU quota and an 8 GiB memory limit.
  Each benchmark is single-threaded and runs without other benchmark processes.
- 2 GiB dynamic-space ceiling and 1 MiB Lisp control stack; normal project compiler settings.
- One warmup followed by five measurements per workload. Full host GC runs before,
  outside each timed measurement. Workload order alternates between passes.
- Reported numbers are medians; [CSV](../../benchmarks/prolog/results/baseline.csv) also records run min/max.
- Build means MAKE-QUERY compilation. First-answer workloads time RUN-MACHINE,
  then the same binding-export graph copy used by NEXT-SOLUTION separately.
- SLG and append-all workloads enumerate and discard every answer with NEXT-SOLUTION;
  their Run column includes export. No terminal I/O is timed. All-answer counts are checked.
- Database construction, clause compilation and construction of host input lists
  precede measurement. These results therefore do not measure database-update throughput.
- Bytes are cumulative SBCL allocations, not peak live memory or RSS. The allocation
  counter is region-granular; tiny allocations can register as zero. Wall-clock ticks
  were coarse on this host (approximately 4 ms); zero or 4 ms results need that context.
- Host-GC milliseconds and VM managed-cell/collection counters are in the raw results.
  Outer-VM heap counters do not include suspended SLG workers or all host allocations.

### Baseline results

| Workload | Build ms | Run ms | Export ms | Build MiB | Run MiB | Export MiB |
|---|---:|---:|---:|---:|---:|---:|
| host-tail-100k | 0.0 | 192.0 | 0.0 | 0.0 | 259.4 | 0.0 |
| arith-tail-100k | 0.0 | 416.0 | 0.0 | 0.0 | 402.9 | 0.0 |
| let-tail-100k | 0.0 | 248.0 | 0.0 | 0.0 | 396.6 | 0.0 |
| walk-10k | 4.0 | 16.0 | 0.0 | 11.4 | 13.3 | 0.0 |
| append-10k | 8.0 | 24.0 | 0.0 | 11.4 | 18.6 | 2.3 |
| unify-100k | 108.0 | 48.0 | 8.0 | 114.5 | 66.4 | 23.2 |
| dcg-10k | 8.0 | 28.0 | 0.0 | 11.4 | 27.5 | 0.0 |
| waste-50k-gc64 | 0.0 | 188.0 | 0.0 | 0.0 | 198.3 | 0.0 |
| waste-50k-gc4096 | 0.0 | 184.0 | 0.0 | 0.0 | 188.6 | 0.0 |
| waste-50k-no-gc | 0.0 | 196.0 | 0.0 | 0.0 | 184.2 | 0.0 |
| fact-last-1000x1000 | 0.0 | 288.0 | 0.0 | 0.0 | 337.6 | 0.0 |
| slg-path-1000 | 0.0 | 356.0 | 0.0 | 0.0 | 345.2 | 0.0 |
| append-all-1000 | 0.0 | 116.0 | 0.0 | 1.1 | 243.9 | 0.0 |

The last-clause workload performs 1,000 lookups in a 1,000-clause predicate.
The SLG workload enumerates paths along 1,000 edges using a left-recursive rule;
it uses the same unindexed fact database. DCG consumes 10,000 tokens. Append-all
exports 1,001 splits of a 1,000-element list.

### Historical bottleneck analysis

#### 1. Generic graph processing for scalar values

`unify` constructs a work list and cycle-detection hash table before it knows
whether it is comparing two scalar values. `map-term` similarly allocates graph
copying machinery for atoms; the host bridge calls it during both instantiation
and reification, including for numeric and opaque lexical-binding inputs.

The host-tail CPU profile attributes 26.1% inclusive samples to hash-table
creation and 22.3% to MAP-TERM; LET increases these to 30.9% and 30.8% respectively.
These overlap and must not be summed. The waste allocation profile attributes
42.2% inclusive allocation samples to hash-table allocation, with MAP-TERM and
UNIFY both prominent. See the [raw profiles](../../benchmarks/prolog/results/profiles/profile-host-tail-100k-cpu.txt).

Benchmark-only scalar shortcuts, retaining the generic path for cons graphs,
produce the following diagnostic medians:

| Workload | Diagnostic baseline ms / MiB | Both shortcuts ms / MiB |
|---|---:|---:|
| Host tail calls, 100k | 188 / 259.4 | 152 / 108.3 |
| LET tail calls, 100k | 236 / 396.6 | 172 / 158.7 |
| Discarded terms, 50k | 180 / 188.6 | 140 / 94.8 |

This isolates a roughly 19–27% time reduction and 50–60% allocation reduction
in these cases. Separate shortcuts and raw measurements are in
[diagnostics.csv](../../benchmarks/prolog/results/diagnostics.csv). Small differences between shortcut
variants can be noise; allocation counts are more stable than their timing order.

The proposed first optimization was scalar fast paths and lazy creation of
cycle-detection state, preserving cyclic-term handling, variable age/trailing and
generated-atom equality.

#### 2. Missing first-argument indexing

Every unsuccessful fact head invokes unification and creates/backs out choices.
The SLG path workload executes 3,011,016 worker instructions even though it has
only 1,000 edges and answers. It copies 1,001 continuations, but the measured
large speedup comes from skipping irrelevant fact clauses, rather than from
changing those copies.

A benchmark-only index for unique ground numeric heads gave:

| Workload | Production baseline ms / MiB | Numeric index ms / MiB |
|---|---:|---:|
| Last fact, 1,000 lookups | 288 / 337.6 | about 4 / 2.4 |
| SLG paths, 1,000 answers | 356 / 345.2 | 72 / 8.5 |

SLG worker instructions fall to 14,016 with the same 1,000 answers and 1,001
continuation copies. The index is restricted to these numeric facts; a general
implementation must preserve clause order, variable-headed fallback clauses and
logical update snapshots. Its approximately 4 ms result is timer-resolution limited.

#### 3. Large literal terms expand into expensive compiled construction

For a 100,000-element list, query construction takes 108 ms and allocates 114.5 MiB,
compared with 48 ms / 66.4 MiB to execute and 8 ms / 23.2 MiB to export it.
The compiler emits 499,971 instructions and execution reaches 199,993 managed
cells. The logical list itself has 100,000 cons cells.

LOWER-WAM-CODE assigns placeholder variables to graph nodes before emitting their
construction, preserving sharing and cycles but adding work for acyclic input.
Its BUILD-TERM helper accounts for 26.1% inclusive CPU samples in the large-term
profile; graph hash lookup/growth and STRUCTURE-FIELDS also appear prominently.

Candidate optimizations were a direct acyclic construction path, compact instruction
operands, fewer temporary graph/list objects, and compiled-query reuse when input
shape is stable. None were installed or timed in that investigation.

#### 4. Exporting each answer copies the complete cons graph

Enumerating all append splits takes 116 ms and allocates 243.9 MiB even though
answers are immediately discarded. MAP-TERM accounts for 90.8% inclusive CPU
samples in this workload, while RUN-MACHINE itself has 3.1% inclusive samples.

Each of 1,001 answers exports prefixes and suffixes whose total length is 1,000.
Streaming avoids retaining every answer, but still performs these copies. A
read-only/transient answer API or sharing-aware multi-binding export may help;
saved ordinary answers must remain valid after backtracking.

#### 5. Arithmetic builtin dispatch and LET overhead

The interpreted arithmetic countdown takes 416 ms versus 192 ms for equivalent
Lisp arithmetic callbacks. Its profile attributes 53.3% inclusive samples to
ISO-INVOKE and 27.6% to ISO-EVAL; STRING=* contributes 11.4% self samples. This
indicates builtin dispatch and expression interpretation/name comparisons, not
numeric subtraction itself, are substantial costs.

LET adds about 29% time and 53% allocated bytes over the host countdown in the
baseline. Much of this is generic host-value graph handling: the scalar diagnostic
reduces LET to 172 ms / 158.7 MiB. Closure/cell construction remains another cost.
Specialized arithmetic instructions and cached builtin dispatch were candidates
after scalar paths and indexing.

### Historical GC tradeoff

| Discarded terms, 50k | Run ms | Run MiB | Peak managed cells | VM collections | Host GC ms |
|---|---:|---:|---:|---:|---:|
| Threshold 64 | 188 | 198.3 | 65 | 7,142 | 0.9 |
| Threshold 4,096 | 184 | 188.6 | 4,097 | 97 | 1.1 |
| Disabled | 196 | 184.2 | 400,000 | 0 | 22.5 |

Timing ranges overlap, so these small speed differences are not decisive.
The default threshold reduces peak managed cells by about 98 times versus
disabled VM GC. A threshold of 64 keeps fewer cells but causes many more scans
and additional host allocation. The default is a reasonable balance for this case.
Live large terms can still make GC significant: the large-term CPU profile has
15.7% inclusive VM-GC samples, and its baseline host-GC time is about 39 ms across
build/run/export. GC effectiveness and throughput depend on the workload.

### Historical reproduction

These commands reproduce the interpreter-only investigation, not the current
native measurements. Run from the repository directory:

```sh
sbcl --dynamic-space-size 2048 --control-stack-size 1 --script benchmarks/prolog/run.lisp
BENCH_LOAD_ONLY=1 sbcl --dynamic-space-size 2048 --control-stack-size 1 --script benchmarks/prolog/diagnose.lisp
sbcl --script benchmarks/prolog/summarize.lisp
BENCH_LOAD_ONLY=1 BENCH_PROFILE=host-tail-100k sbcl --dynamic-space-size 2048 --control-stack-size 1 --script benchmarks/prolog/profile.lisp
BENCH_LOAD_ONLY=1 BENCH_PROFILE=waste-50k-gc4096 BENCH_PROFILE_MODE=alloc sbcl --dynamic-space-size 2048 --control-stack-size 1 --script benchmarks/prolog/profile.lisp
```

`BENCH_RESULTS` selects the baseline output path. The summarizer reads the default
results paths. `BENCH_PROFILE` selects any case by name; its default is the waste
workload. Save profiler stdout to retain a report.

CPU profiles collect 1,200 samples at 3 ms intervals. Allocation profiles collect
20,000 region-based samples. Profiling includes query creation, execution and
export, but excludes setup and the explicit full-GC warmup. Sampling stops at the
sample limit, which can bias phase coverage; allocation percentages are not exact
byte attribution. Inclusive percentages overlap and recursive stacks can exceed
100%. Profiler signal/trampoline overhead is visible in raw reports. Timing results
come from separate, unprofiled runs.

Diagnostic substitutions were process-local and restored with UNWIND-PROTECT.
They confirmed mechanisms on these workloads, not correctness or performance of a
finished general optimizer. Production source files remained unchanged. No comparison
with SWI-Prolog, XSB or Allegro Prolog was performed in that investigation.

The recommended order at that time was scalar graph fast paths; first-argument
indexing; large-term construction; answer export; arithmetic dispatch. Shared SLG
stacks were a later candidate, rather than the first fix for the path workload
measured there.

### Historical type-declaration experiment

A [follow-up experiment](TYPE-DECLARATIONS.md) compares VM parameter declarations
and broader vector/local type declarations against that implementation. It retains
reproducible patches and measurements; neither candidate is applied to production.
