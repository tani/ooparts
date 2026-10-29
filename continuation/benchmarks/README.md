# Continuation benchmarks

Recorded on SBCL 2.2.9.debian: 22 cases, 3 fresh processes × 9 rounds,
1782 samples. CPU time per call in microseconds; lower is faster.

| Case | native | selective CPS 1.2 | cl-cont |
|---|---:|---:|---:|
| pure-dotimes | 0.2287 | 0.2303 | 17.2878 |
| inline-4096-shifts-0 | 6.1141 | 6.1062 | 676.6410 |
| typed-integer-loop | 5.7476 | 5.7736 | 588.9881 |
| pure-local-recursion | 1.1641 | 1.8754 | 191.6744 |
| typed-local-recursion | 0.2995 | 0.9272 | 183.4981 |

See results/raw.csv and results/summary.csv for all samples and cases.
These are the original pre-import measurements; environment.json fingerprints
refer to the original selective-cps source, before package/system renaming.
The import changes package and integration names, not control algorithms.

Reproduce from this directory:

```sh
python3 fetch-vendor.py
python3 run.py --sbcl /path/to/sbcl
```

Requires Python 3, git and SBCL; set SBCL_HOME if necessary. Dependencies are
pinned by commit or archive hash. The implementation path defaults to the
parent continuation/ directory. Use --vendor to reuse a dependency directory.

Compilation policy: speed 3, safety 1, debug 0. One permitted CPU is pinned.
Fresh processes run sequentially; variant order shuffled each round.
Warmup, calibration, compilation and pre-sample full GC are excluded; in-sample
GC is included. Ten inputs are checked before timing; outputs retained.
Representative cost is median of process medians. Shared VM/frequency noise
and harness overhead remain. Native means an equivalent-result computation,
not native shift/reset: identity capture/resume is removed, and some tiny
control cases use specialized result-equivalent forms. The cl-cont lowering
is valid for these cases only. The pure kernel in chunked cases is included
in timing and must not itself capture native frames.
