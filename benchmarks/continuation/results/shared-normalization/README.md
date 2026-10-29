# Shared normalization: before/after measurements

Measured on 2026-10-29 with SBCL 2.2.9.debian on Linux x86-64. The baseline
is commit `b26f900eb66ef5c148ec75b0f84b57d24b9fcf58`; the after sources are
identified by SHA-256 in [environment.json](environment.json).

The compiler shares assignment, iteration and handler normalization across
implementations. Its six `#-sbcl` guards are removed (nine reader conditionals
in total become three). Handler frames and their restoration are shared too.
Known literal FUNCALL targets retain their direct-call effect, including the
setters returned by GET-SETF-EXPANSION. Other implementation-specific environment,
MOP and special-binding operations retain their compatibility paths.

## Findings

- Selective execution: equal-weight geometric mean after/before **0.8025** across 30 cases.
- Transformation time: geometric mean **0.8894**.
- Equivalent native controls: geometric mean **0.9974**.
- Handler cases improve substantially and allocate less. The generalized-place
  INCF case becomes direct code instead of going through the CPS dispatcher.
- There is a cost for handler-free continuation dispatch: the simple capture,
  resume and nested-reset cases are about 2–9% slower. The driver checks the
  shared handler cache even when no handler is installed.
- The typed integer loop is 4.9% slower in the selective measurement; its
  unchanged native control is 3.0% slower. Small differences must be interpreted
  with the native controls and shared-host/frequency noise in mind.
- These are microbenchmarks. The geometric mean is not an application-level
  speedup prediction, and timings have not been generalized to other Lisps.

## Execution

CPU time is in microseconds per call. Allocation is bytes per call. Each entry
is the median of five process medians, with nine rounds in each process.
Ratios below one mean faster; allocation counters have sampling granularity.

| Case | Before µs | After µs | After/before | Before B | After B |
|---|---:|---:|---:|---:|---:|
| abort-no-resume | 1.1082 | 1.1702 | 1.056 | 1509 | 1525 |
| capture-resume-once | 1.4783 | 1.5479 | 1.047 | 2050 | 2068 |
| capture-resume-twice | 2.2257 | 2.3782 | 1.069 | 3141 | 3149 |
| capture-return | 1.0999 | 1.1466 | 1.042 | 1504 | 1522 |
| chunked-4096-shifts-0 | 32.2212 | 29.0338 | 0.901 | 48431 | 38177 |
| chunked-4096-shifts-1 | 39.5439 | 35.8013 | 0.905 | 60014 | 50136 |
| chunked-4096-shifts-16 | 63.2287 | 61.1962 | 0.968 | 90253 | 77967 |
| deep-capture-resume | 17.4323 | 18.2232 | 1.045 | 29458 | 29458 |
| dolist-shift | 20.1783 | 19.2254 | 0.953 | 29746 | 28366 |
| dotimes-shift | 43.2557 | 39.8486 | 0.921 | 60904 | 53245 |
| handler-bind-normal | 1.1476 | 0.4301 | 0.375 | 1727 | 751 |
| handler-bind-signal | 4.5401 | 2.5802 | 0.568 | 5515 | 2992 |
| handler-case-error | 8.1399 | 4.3580 | 0.535 | 10761 | 5856 |
| handler-case-normal | 3.3047 | 2.4492 | 0.741 | 4443 | 3501 |
| higher-order-capture | 3.4383 | 3.4695 | 1.009 | 4467 | 4495 |
| incf-place | 0.4821 | 0.0160 | 0.033 | 751 | 32 |
| inline-4096-shifts-0 | 6.2741 | 6.1175 | 0.975 | 0 | 0 |
| inline-4096-shifts-1 | 2895.8125 | 2385.7500 | 0.824 | 5506811 | 4195537 |
| inline-4096-shifts-16 | 3143.6875 | 2562.1875 | 0.815 | 5533104 | 4221101 |
| inline-4096-shifts-256 | 8414.7500 | 7318.5625 | 0.870 | 6011509 | 4658270 |
| multiple-values | 1.5484 | 1.6453 | 1.063 | 2101 | 2116 |
| nested-reset | 1.4889 | 1.6215 | 1.089 | 2053 | 2065 |
| pure-arithmetic | 0.0053 | 0.0054 | 1.021 | 0 | 0 |
| pure-dolist | 0.0179 | 0.0165 | 0.922 | 0 | 0 |
| pure-dotimes | 0.2297 | 0.1983 | 0.864 | 0 | 0 |
| pure-local-recursion | 2.1639 | 2.0229 | 0.935 | 0 | 0 |
| resume-stored | 0.4367 | 0.4453 | 1.020 | 688 | 703 |
| sparse-control | 3.6597 | 3.7117 | 1.014 | 2120 | 2135 |
| typed-integer-loop | 6.0649 | 6.3630 | 1.049 | 0 | 0 |
| typed-local-recursion | 1.0599 | 1.0542 | 0.995 | 0 | 0 |

## Transformation time

Microseconds per call to `transform`, measured independently of compilation
and execution. This includes allocation and GC during transformation.

| Case | Before µs | After µs | After/before |
|---|---:|---:|---:|
| abort-no-resume | 5.539 | 5.588 | 1.009 |
| capture-resume-once | 7.276 | 7.122 | 0.979 |
| capture-resume-twice | 12.835 | 13.091 | 1.020 |
| capture-return | 5.756 | 5.669 | 0.985 |
| chunked-4096-shifts-0 | 28.473 | 23.870 | 0.838 |
| chunked-4096-shifts-1 | 39.282 | 34.510 | 0.879 |
| chunked-4096-shifts-16 | 38.482 | 33.279 | 0.865 |
| deep-capture-resume | 17.148 | 17.038 | 0.994 |
| dolist-shift | 38.015 | 33.395 | 0.878 |
| dotimes-shift | 34.364 | 32.177 | 0.936 |
| handler-bind-normal | 16.735 | 5.684 | 0.340 |
| handler-bind-signal | 26.624 | 16.112 | 0.605 |
| handler-case-error | 36.977 | 26.295 | 0.711 |
| handler-case-normal | 21.927 | 17.620 | 0.804 |
| higher-order-capture | 21.573 | 22.135 | 1.026 |
| incf-place | 15.308 | 12.562 | 0.821 |
| inline-4096-shifts-0 | 15.146 | 14.088 | 0.930 |
| inline-4096-shifts-1 | 40.122 | 34.899 | 0.870 |
| inline-4096-shifts-16 | 41.770 | 34.248 | 0.820 |
| inline-4096-shifts-256 | 42.944 | 33.364 | 0.777 |
| multiple-values | 13.878 | 14.374 | 1.036 |
| nested-reset | 8.575 | 8.929 | 1.041 |
| pure-arithmetic | 3.554 | 3.456 | 0.973 |
| pure-dolist | 16.747 | 18.302 | 1.093 |
| pure-dotimes | 14.448 | 14.889 | 1.031 |
| pure-local-recursion | 10.199 | 10.158 | 0.996 |
| resume-stored | 5.725 | 5.764 | 1.007 |
| sparse-control | 17.361 | 16.799 | 0.968 |
| typed-integer-loop | 15.051 | 14.356 | 0.954 |
| typed-local-recursion | 10.218 | 10.562 | 1.034 |

## Method and reproduction

See [the benchmark driver](../../compare-normalization.py) and
[benchmark instructions](../../README.md#shared-normalization-comparison).
The 8,100 samples cover two revisions × five fresh processes × 30 cases ×
three measured variants × nine rounds. Process order alternates before/after
and after/before; variant order is shuffled within each round. All processes
run sequentially pinned to one permitted CPU, with speed 3, safety 1, debug 0.
CPU frequency is not fixed. No other OOPArts tests run during measurement.
Ten inputs per compiled function are checked against expected results before
timing. Warmup, calibration, compilation and pre-sample full GC are excluded.
The native variant is equivalent-result code, not native continuation capture.

Raw samples are in [raw.csv](raw.csv); per-process medians and allocation
statistics are in [summary.json](summary.json), with the flat table in
[summary.csv](summary.csv). [hardware.json](hardware.json) records the host CPU.

## Correctness

The SBCL continuation suite passes 3,126 checks, including 1,328 independently
reduced core terms in both transformation modes. Fresh-process FASL and
saved-core reload tests pass, including a handler continuation invoked after
its original installation has ended.
