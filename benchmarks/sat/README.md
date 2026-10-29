# SAT benchmarks

## Lisp-style refactor (2026-10-29)

[refactor-results.json](refactor-results.json) compares the optimized pre-refactor
OOPArts port with the current source on eleven identical formulas. Five
alternating warm-process groups are pinned to one CPU. Median solve CPU time
excludes startup, compilation, input insertion, model queries and statistics;
GC during solving is included. Every Lisp iteration is checked against its
own matched-allocator C server, including model and trace digests. C is built
with GCC `-O3 -DNDEBUG`, separate translation units and no LTO.

The solve-time geometric mean improves **1.0446x** (about 4.5% higher throughput);
time relative to C changes from **9.3181x to 8.9199x**. Individual speedup ratios
range from 0.9737x to 1.1302x, so this is not an improvement on every formula.
Solve allocation, raw groups, ranges and source/harness hashes are retained.
This is one SBCL 2.2.9 / GCC 13.3 / Linux x86-64 run, not a general speed guarantee.
The separate total-API metric covers low-level create/add/solve/release; it does
not measure the public convenience API's validation and detached model creation.

Reproduce from the repository root, with a checkout of the published pre-refactor
revision `aa5bcced22c1eccc62cc254faa21e43ac2cc8baa`:

```sh
SBCL=sbcl python3 benchmarks/sat/compare.py --baseline /path/to/pre-refactor-checkout
```

The baseline's indexed tree must be `b2a2735cef02aba1f4a2cc6dcf389563c4ed6351`
for the recorded comparison. The report records the indexed tree and exact file
hashes; working files must correspond to that snapshot. New outputs default
to ignored `build/sat/benchmark/`, including C binaries and subprocess logs.
The baseline is loaded in a separate Lisp process. No baseline source is bundled.

## Earlier type-declaration optimization

`optimization-results.json` preserves the complete paired C / before / after
measurement of the standalone Common Lisp port before its OOPArts integration.
The source hashes identify the original `cl-satch` files, before package names
were first integrated into OOPArts. They predate the current inferred modules,
Lisp names, lexical bindings and structured control flow. These numbers must
not be presented as measurements of the refactored source.

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
