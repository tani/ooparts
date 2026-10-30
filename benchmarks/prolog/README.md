# Benchmarks

Run scripts from the repository root. The scripts remain here; recorded
measurements live under `results/` and focused experiments retain their own
directories. Current measured figures and their interpretation live in
[docs/prolog/BENCHMARKS.md](../../docs/prolog/BENCHMARKS.md); this file only
describes the artifacts and entry points.

| Location | Role |
|---|---|
| `run.lisp`, `summarize.lisp` | Baseline workloads and CSV summaries |
| `profile.lisp`, `diagnose.lisp` | SBCL profiling and temporary diagnostic substitutions |
| `competitive*.lisp`, `competitive*.pl`, `compare.py` | Shared Prolog workloads and SWI comparison |
| `jit-compare.py` | Same-checkout `:auto` versus `:wam` specialization comparison |
| `ablate.py`, `ablations/` | Optimizer ablation driver, patches and measurements |
| `type-declarations/` | Type-declaration experiment, patches, measurements and its `summarize.lisp` |
| `results/baseline.*` | Baseline raw observations and summary |
| `results/diagnostics.*` | Diagnostic substitution observations and summary |
| `results/*-results.json` | Archived cross-engine measurements |
| `results/profiles/` | Recorded CPU and allocation profiles |

```sh
sbcl --dynamic-space-size 2048 --control-stack-size 1 --script benchmarks/prolog/run.lisp
sbcl --script benchmarks/prolog/summarize.lisp
python3 benchmarks/prolog/compare.py --sbcl /path/to/sbcl --swipl /path/to/swipl
python3 benchmarks/prolog/jit-compare.py --repeats 5 --batch 3 --output build/prolog/jit-comparison.json
```

Baseline runs default to `results/baseline.sexp`; `BENCH_RESULTS` overrides the
output path. The comparison driver defaults to `results/wam-results.json`
relative to this directory; its `--output` override is relative to the repository
root. Existing measurements retain their original bytes, versions and source
fingerprints; moving them does not constitute a new benchmark run.

`jit-compare.py` runs both policies in counterbalanced fresh processes. It
requires native execution for `queens`, `tak`, `reverse` and `qsort`, and
requires `reverse` and `qsort` to run completely natively in both rounds: exactly
one native call and zero deoptimizations. Every case keeps its solutions, CPU
and allocation samples; a subset of passing cases is not a pass.

See [measurement tables and reproduce commands](../../docs/prolog/BENCHMARKS.md),
[SWI comparison](../../docs/prolog/COMPETITIVE-BENCHMARKS.md),
[native specialization](../../docs/prolog/NATIVE-JIT.md) and the
[historical native compiler ablation](../../docs/prolog/NATIVE-ABLATION.md).
Archived native-compiler results describe a superseded revision and do not
measure the current implementation; use a new output path when measuring it.
`competitive.lisp` selects `:auto` or `:wam` execution through `BENCH_EXECUTION`.
The comparison defaults to one query per timed sample; `BENCH_BATCH` overrides
this in both engines. `ablate.py` and its patches reproduce historical revisions
only.
