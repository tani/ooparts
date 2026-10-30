# Implementation roadmap

## Implemented (0.10.0)

- Native Lisp cons graphs for terms, lists, dotted tails, sharing and rational trees.
- One granular WAM backend: X/Y registers, get/put/unify/set, read/write modes,
  explicit choices and continuations, and tail execution.
- Iterative term processing and nonmoving VM ownership-vector mark/compact GC,
  with conditional trailing, suspended-environment roots and adaptive thresholds.
- Interactive one-answer-at-a-time queries, cursors, copied answers, database isolation
  and lexical Lisp callbacks.
- DCGs with quoted token lists, and/or/do controls, append/replace definition
  macros, hygienic difference-list expansion and scoped cuts.
- SLG variant tabling, copied consumer continuations, queue scheduling,
  dynamic SCC-local completion and ground well-founded negation.
- Runtime rejection of cuts over unfinished tables, query-local table teardown,
  and version checks when definitions change during tabled execution.
- 128 core builtin indicators plus seven aliases: control, arithmetic, cons term
  operations, exceptions, dynamic definitions, collectors and character/byte I/O.
- Automatic predicate specialization enabled by default through
  `:execution-mode :auto`, with `:wam` as a per-database interpreted oracle and
  `OOPARTS_PROLOG_DISABLE_NATIVE=1` as a process-wide switch. Eligible pure
  predicate groups compile to Common Lisp and run on a direct tier bounded by
  logical depth 256, continuing deep semidet recursion on an explicit-stack tier
  over a heap arena bounded at 1,048,576 slots. A depth promotion reuses the same
  attempt, inputs, fuel and answers and counts as one native call rather than a
  deoptimization; real bound failures replay atomically on the WAM.
  `query-statistics` reports `:native-calls` and `:native-deoptimizations`.
  See [NATIVE-JIT.md](NATIVE-JIT.md) for the contract.
- Logical update view for immutable clause/code snapshots.
- Source LET bindings shared by lexical callbacks, with mutation, shadowing and
  cursor-safe lifetime. Dynamic special bindings remain future work.

See [the user guide](MANUAL.md), [builtin specification](BUILTINS.md) and
[validation results](VALIDATION.md) for behavior and current restrictions.

## Execution policy

The default `:execution-mode :auto` compiles and uses eligible predicate groups
and otherwise keeps the complete portable WAM implementation; `:wam` selects the
interpreted oracle per database. Predicate specialization therefore does not
remove the WAM path: it adds two compiled tiers above it. Earlier experimental
native-compiler [comparisons](COMPETITIVE-BENCHMARKS.md) and
[ablation results](NATIVE-ABLATION.md) remain historical records of a different,
removed optimizer; current measurements are in [BENCHMARKS.md](BENCHMARKS.md).

## Scope

Lisp-native cons terms and embedding remain the default. The optional immutable
`:term-model :iso` distinguishes lists, compounds and the empty list while sharing
the VM and graph algorithms. A textual `.pl` loader and Prolog-style stream I/O
are implemented. The 782-case pinned corpus checks defined behavior; it does
not establish full ISO conformance. See [ISO compatibility](ISO-COMPATIBILITY.md).
PAIP / Allegro API inspiration does not imply complete API compatibility.

## Future API work

Variable inspection APIs and cleanup scopes are not implemented.
Prolog resource cleanup across backtracking needs a separate design; host Lisp
UNWIND-PROTECT alone does not provide those semantics.
DCG dynamic nonterminal calls, semicontext/push-back and grammar-level
negation/conditionals remain unsupported.

## Future performance work

The [historical profiles](BENCHMARKS.md) identify interpreter bottlenecks.
Make small, measured changes when interpreter/SLG workloads justify them.
Current specialization measurements are recorded separately in the same document.

- VM indexing, scalar/graph allocation changes, X-register reuse and variable lifetime analysis.
- Direct acyclic term construction, compact instruction encodings and further compiled-tier dispatch.
- Shared frozen stacks, answer tries and explicit table-space accounting.
- Incremental SCC maintenance, immediate completion of ground successes,
  call/answer subsumption and answer aggregation.

These are candidates, not a release schedule. Preserve the explicit VM control
model and check semantics against the independent regression oracles.
The VM retains Lisp cons graphs; physical reclamation is performed by SBCL GC.
