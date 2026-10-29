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
- Logical update view for immutable clause/code snapshots.
- Source LET bindings shared by lexical callbacks, with mutation, shadowing and
  cursor-safe lifetime. Dynamic special bindings remain future work.

See [the user guide](MANUAL.md), [builtin specification](BUILTINS.md) and
[validation results](VALIDATION.md) for behavior and current restrictions.

## Execution policy

Predicates execute through the portable WAM backend. Ground-mode specialization
and native JIT compilation were removed to keep a single execution path.
Earlier native-compiler [comparisons](COMPETITIVE-BENCHMARKS.md) and
[ablation results](NATIVE-ABLATION.md) remain historical records.

## Scope

Lisp-native terms and embedding take priority over ISO Prolog compatibility.
There is no separate compound-term encoding or ISO conformance target.
A textual `.pl` loader maps into native conses; term ordering is Lisp-native.
Prolog-style output remains unimplemented.
PAIP / Allegro API inspiration does not imply complete API compatibility.

## Future API work

Variable inspection APIs and cleanup scopes are not implemented.
Prolog resource cleanup across backtracking needs a separate design; host Lisp
UNWIND-PROTECT alone does not provide those semantics.
DCG dynamic nonterminal calls, semicontext/push-back and grammar-level
negation/conditionals remain unsupported.

## Future performance work

The [historical profiles](BENCHMARKS.md) identify interpreter bottlenecks.
Make small, measured changes when interpreter/SLG workloads justify them. Earlier
optimizer results do not establish the performance of the current interpreter.

- VM indexing, scalar/graph allocation changes, X-register reuse and variable lifetime analysis.
- Direct acyclic term construction, compact instruction encodings and native dispatch.
- Shared frozen stacks, answer tries and explicit table-space accounting.
- Incremental SCC maintenance, immediate completion of ground successes,
  call/answer subsumption and answer aggregation.

These are candidates, not a release schedule. Preserve the explicit VM control
model and check semantics against the independent regression oracles.
The VM retains Lisp cons graphs; physical reclamation is performed by SBCL GC.
