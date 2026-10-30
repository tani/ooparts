# Native compiler ablation — 2026-10-23

> Historical record. The optimizer measured here was removed and has since been
> replaced by the independent implementation described in [NATIVE-JIT.md](NATIVE-JIT.md).
> These results apply only to the revisions cited below; run reproduction commands
> in those revisions and do not reuse these figures for the current code.

## Decision

Keep the guarded native compiler and its ground-fact relation index. Remove the VM first-argument index, scalar-unification shortcuts and graph-copy rewrite from this PR. They are unnecessary to reach SWI parity on the six current workloads. This does not establish that they would be useless on interpreter-only or SLG workloads.

| Variant | VM clause/term handling | Native ground-fact handling | Cases faster than SWI |
| --- | --- | --- | ---: |
| `full` | Previous VM indexing and allocation changes | Indexed | 6 / 6 |
| `native_only` (selected) | Unmodified upstream algorithms | Indexed | 6 / 6 |
| `native_linear` | Unmodified upstream algorithms | Linear clause matching | 5 / 6 |

## Controlled measurements

Median CPU milliseconds per query. Each engine uses the same Prolog source and batch size 20; three samples in each of two fresh-process rounds (six samples per case). Round two reverses engine order. Every result is checked. SBCL 2.2.9, 2 GiB dynamic space, 1 MiB control stack; SWI-Prolog 9.2.9 with `-O`; AMD EPYC 9V74, Linux x86-64. Loading and first-query warmup are excluded.

| Workload | Full ms | Native only ms | No native fact index ms | SWI ms | SWI / native only |
| --- | ---: | ---: | ---: | ---: | ---: |
| 8 queens, all solutions | 0.999 | 0.991 | 0.958 | 2.269 | 2.29x |
| Takeuchi (16,10,4) | 1.083 | 0.996 | 0.949 | 3.276 | 3.29x |
| Naive reverse, 1200 elements | 9.978 | 9.604 | 9.330 | 18.385 | 1.91x |
| Quicksort, 2000 elements | 1.001 | 0.985 | 1.026 | 3.373 | 3.42x |
| Graph, 2046 edges / 1024 paths | 0.175 | 0.155 | 0.778 | 0.263 | 1.70x |
| Symbolic differentiation | 0.359 | 0.344 | 0.348 | 0.778 | 2.26x |

The selected variant wins all six cases by 1.70–3.42x. The full VM changes show no necessary benefit for this target. Do not infer a statistically significant improvement from the small full/native-only timing differences.

Removing the native fact index loses the graph case: approximately 0.778 ms versus SWI 0.263 ms, about 2.95x slower. The native index is therefore retained based on measured necessity. The earlier exploratory figure of approximately 50 ms also included different native matching code and was not an isolated measurement of indexing. This controlled comparison supersedes it.

## What was removed

- Restore upstream `unify` and `map-term` verbatim.
- Restore upstream `compile-predicate` and VM instruction vocabulary; remove `index-first`/`jump-clause`.
- Retain only the native-call hook and native statistics in the engine, and native-cache teardown in the compiler.
- Move the native relation-key helper into the native compiler; the VM does not depend on it.

The selected source hashes exactly match the measured `native_only` variant in [results.json](../../benchmarks/prolog/ablations/results.json). Source fingerprints, all CPU/allocation samples, cold timings, execution order and runtime versions are retained there. The former full result is archived in [competitive-results.json](../../benchmarks/prolog/results/competitive-results.json).

## Reproduction

The experimental baseline is the previous PR head `6da5c8e4ff692fb1da887835452fd625b33f2731`. The patches apply to that revision, independently of each other. Run from the current repository root:

```sh
git worktree add --detach /tmp/ooparts-prolog-full 6da5c8e4ff692fb1da887835452fd625b33f2731
git worktree add --detach /tmp/ooparts-prolog-native-only 6da5c8e4ff692fb1da887835452fd625b33f2731
git worktree add --detach /tmp/ooparts-prolog-native-linear 6da5c8e4ff692fb1da887835452fd625b33f2731
git -C /tmp/ooparts-prolog-native-only apply "$PWD/benchmarks/ablations/native-only.patch"
git -C /tmp/ooparts-prolog-native-linear apply "$PWD/benchmarks/ablations/native-linear.patch"
python3 benchmarks/prolog/ablate.py \
  --variant full=/tmp/ooparts-prolog-full \
  --variant native_only=/tmp/ooparts-prolog-native-only \
  --variant native_linear=/tmp/ooparts-prolog-native-linear \
  --output benchmarks/prolog/ablations/reproduced.json
```

The default settings are two rounds, three samples per round and batch size 20. `--sbcl`, `--swipl`, `--rounds`, `--repeats` and `--batch` are configurable. Benchmark processes execute serially.

## Independent confirmation using the original benchmark protocol

After selecting `native_only`, rerun `compare.py --require-parity` with its original
per-case batch sizes and five samples. All six cases pass again, by 1.49–3.32x.
Those independent measurements are in [native-only-results.json](../../benchmarks/prolog/results/native-only-results.json)
and summarized in [the current benchmark report](COMPETITIVE-BENCHMARKS.md).
The different batch sizes and separate run explain why these medians differ from
the controlled ablation table; do not mix their samples into one comparison.

## Validation after removing the VM optimizations

4,625 checks pass on SBCL with a 1 MiB control stack. With native execution disabled, 4,618 checks pass (seven native-path assertions are skipped). All 54 derived observations still match upstream. The original full PR passed all 17 GitHub Actions jobs before this reduction; those results do not substitute for the new head’s CI.
