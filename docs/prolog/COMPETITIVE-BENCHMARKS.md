# Shared-source comparison with SWI-Prolog

> Historical record. The optimizer measured here was replaced by the independent
> implementation described in [NATIVE-JIT.md](NATIVE-JIT.md). These results apply
> only to the revisions cited below; run reproduction commands in those revisions
> and do not reuse these figures for the current code.

Measured 2026-10-23 JST, starting from upstream `9e14c1e` (0.10.0).
All six workloads beat SWI-Prolog 9.2.9 with `-O` on this host after warmup.
After [controlled ablation](NATIVE-ABLATION.md), the VM-side indexing, scalar
unification and graph-copy changes were removed. This table measures the selected
native compiler with its own ground-fact relation index and unmodified VM algorithms.
This is a throughput result for this suite, not a claim about every Prolog program.

| Workload | Native only ms | SWI `-O` ms | SWI / native only |
| --- | ---: | ---: | ---: |
| 8 queens, all 92 solutions | 1.119 | 2.431 | 2.17x |
| Takeuchi (16, 10, 4) | 1.067 | 3.472 | 3.25x |
| Naive reverse, 1200 elements | 12.595 | 18.740 | 1.49x |
| Quicksort, 2000 elements | 1.075 | 3.571 | 3.32x |
| Binary graph: 2046 edges, 1024 length-10 paths | 0.165 | 0.278 | 1.68x |
| Symbolic differentiation, depth 8; 12799 result nodes | 0.389 | 0.812 | 2.09x |

## Method

- Linux x86-64, AMD EPYC 9V74, nine visible logical CPUs, eight-CPU quota and 8 GiB memory limit. Queries are single-threaded.
- SBCL 2.2.9.debian, 2 GiB dynamic space, 1 MiB control stack. SWI-Prolog 9.2.9, optimized compilation enabled with `-O`.
- Both engines load the exact same `competitive.pl` and `competitive-edges.pl`. Algorithms, inputs, clause order, arithmetic and answer enumeration are shared; there are no Lisp callbacks, CLP libraries or solver-specific benchmark definitions.
- One untimed query warms the compiler and indexes. Each of five timed samples executes a fixed batch, identical for both engines: queens/tak/qsort 100; reverse 10; graph 500; differentiation 250. Times above are median CPU seconds divided by the batch size.
- Query creation, execution, scalar result export and cursor teardown are inside the ooparts/prolog timed loop. Both engines check the result of every query. Expected results are independently fixed in `compare.py`: 92, 5, 1200, 2000, 1024 and 12799.
- Full host GC is requested before each sample, outside timing. GC during the workload remains included. Engines run serially. No terminal I/O occurs inside the timed loop.
- Process launch, source loading, database construction and initial native compilation are excluded. The raw `cold_seconds` field records first-query time; the first benchmark compiles a closed group containing all six `bench/2` clauses, so later first-query values are not independent cold-compiler measurements.
- Raw CPU samples, allocation counts, batches, versions and executed commands are in [native-only-results.json](../../benchmarks/prolog/results/native-only-results.json). The former full-optimization measurements and upstream context are archived in [competitive-results.json](../../benchmarks/prolog/results/competitive-results.json). Allocation bytes are cumulative SBCL allocations per query, not live bytes or RSS. SWI allocation fields are placeholders (zero), not allocation measurements.

## Reproduction

From the repository root, with SBCL, SWI-Prolog and Python 3 available:

```sh
sbcl --dynamic-space-size 2048 --control-stack-size 1 --script tools/test.lisp prolog
python3 benchmarks/prolog/compare.py --require-parity
```

`--sbcl`, `--swipl`, `--repeats` and `--output` select executables and output. The parity flag fails if any measured median is slower than SWI. Other hardware/runtime versions may produce different ratios.

To compare the interpreter path or individual cases:

```sh
OOPARTS_PROLOG_DISABLE_NATIVE=1 sbcl --dynamic-space-size 2048 --control-stack-size 1 --script tools/test.lisp prolog
BENCH_CASE=QUEENS BENCH_BATCH=1 sbcl --dynamic-space-size 2048 --control-stack-size 1 --script benchmarks/prolog/competitive.lisp
BENCH_CASE=QUEENS BENCH_BATCH=1 swipl -O -q -s benchmarks/prolog/competitive-swi.pl
```

## Implementation and limits

The VM's clause selection, unification and graph-copying algorithms are unchanged
from upstream. The [ablation report](NATIVE-ABLATION.md) explains why their proposed
optimizations were removed; they were unnecessary for this throughput target.

On SBCL, `src/prolog/syntax/native.lisp` specializes pure user predicates by their ground input positions. Disjoint input heads or source cuts justify deterministic/semideterministic execution. Native Common Lisp labels perform integer arithmetic, matching and calls directly. A pure statically known `findall/3` goal uses continuation-based enumeration; ground fact relations use indexes on available scalar inputs. These optimizations depend on program structure and call modes, not benchmark names.

Native calls require ground acyclic inputs and independent free output variables. Constrained/aliased outputs, unsupported arithmetic types, host callbacks, effects, tabling and instrumentation retain the VM path. Compiled and rejected modes are cached per database generation; clearing a database releases its cache. Recursive native collector compilation is detected and falls back.

Native evaluation is speculative: it makes no VM bindings or external effects before completion. Depth (2,048), call fuel (1,000,000), compiler mode count (128), template depth (64) and collector answer count (65,536) bounds trigger VM fallback. A cursor remembers a failed specialization to avoid retrying the same expensive bailout at every recursive call. The portable WAM remains the implementation for other Lisp runtimes; SLG is not a speed claim of this benchmark.

`query-statistics` adds `:native-calls` and `:native-deoptimizations`. Existing instruction, continuation-depth and managed-cell counters describe WAM work; native temporary allocation is visible in the host byte counters.

## Correctness evidence

4,625 checks pass on SBCL with a 1 MiB stack, including native/interpreter comparisons, 49 cut/guard combinations, errors, output constraints/aliasing, rational/open terms, recursive collectors, cache invalidation and deep tail/non-tail fallback. With native execution disabled, 4,618 checks pass (seven native-path assertions are skipped). All 54 serialized derived observations match the upstream revision. Existing SLG, callback, forced-GC and logical-update regressions remain enabled.
