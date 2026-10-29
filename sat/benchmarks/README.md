# Optimization measurements

`optimization-results.json` preserves the complete paired C / before / after
measurement of the standalone Common Lisp port before its OOPArts integration.
The source hashes identify the original `cl-satch` files, before package names
were changed to `ooparts/sat/impl` and `ooparts/sat/low-level`.

- SBCL 2.2.9.debian, GCC 13.3.0, AMD EPYC 9V74, Linux x86-64.
- All processes pinned to logical CPU 0; five alternating warm-process groups.
- Median process CPU time per solve. Startup, compilation, parsing, model
  queries, statistics collection and IPC excluded; GC during solving included.
- Pinned upstream C built with `-O3 -DNDEBUG`, separate translation units, no LTO.
- Every Lisp iteration audited against a separate matched-allocator C server.
  Status, trace counters and model digests agree for all eleven cases.
- Geometric mean speedup: **3.924x** (range 3.501–4.308x).
- Time relative to C: before **37.789x**, after **9.629x**.
- add64 Lisp allocation per solve: **619.599 MiB → 2.248 MiB**, cumulative managed
  heap allocation rather than peak RSS or native arena usage.

These are historical measurements of the translated core through the low-level
API. They do not measure the new Lisp interface's input validation and model
snapshot construction. Raw groups, repetitions, ranges and source hashes are
included so that the exact scope of the numbers remains explicit. The original
standalone comparison archive contains the before snapshot and timing harness;
it is not required to run or validate OOPArts.
