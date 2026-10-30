# Automatic native predicate specialization

- Compile eligible pure predicate groups into Common Lisp functions with fixed
  arguments, direct matching/arithmetic, direct calls and indexed ground relations.
- Add `:execution-mode :auto|:wam` to `make-database`, `OOPARTS_PROLOG_DISABLE_NATIVE`
  as a process-level interpreted oracle, and `:native-calls`/`:native-deoptimizations`
  in `query-statistics`.
- Continue depth-limited semidet recursion on an explicit-stack tier: the verified
  definition group is lowered into one `tagbody` over a private adjustable arena,
  with static call entries and integer resume tokens, so activations leave the host
  stack without changing the generated algorithms, answer order or cut scope. The
  promotion reuses the same constants, inputs, fuel and answer budget and is not a
  deoptimization; enumerated definitions and `findall` generators stay synchronous.
- Bound every attempt (fuel, logical depth, collected answers, arithmetic, arity,
  arena slots) and keep the complete WAM implementation for declined calls,
  transactional replay, cut scope, `findall` bags, tabling, SLG and instrumentation.
- Add native/interpreted differential regressions and a counterbalanced
  `benchmarks/prolog/jit-compare.py` comparison on the shared workload.
- Raise `evaluation_error(undefined)` for non-finite transcendental results, so
  hosts whose `log` returns an infinity instead of signaling keep the disputed
  `log(0)` ISO expectations.

# OOPArts refactor — 2026-10-29

- Use only the `ooparts` and `ooparts-tests` primary package-inferred systems.
- Align all source/test package names with the shared directory layout and remove nicknames.
- Move the textual interface into `src/prolog/text/`; keep the public API in `ooparts/prolog`.
- Centralize the Nix flake, provenance ledger, license notices and pinned vendor inventories.
- Preserve the portable WAM backend and native/strict term models. The earlier
  native compiler described below remains removed and is superseded by the
  independent specialization described above.

# Historical native-compiler experiment (removed)

- Add guarded SBCL compilation for pure ground modes and pure finite collectors,
  with native integer arithmetic and indexed ground relations. Preserve the WAM
  fallback for open/cyclic/effectful/tabled calls and exhausted native budgets.
- Keep upstream VM clause selection, unification and graph copying unchanged after
  ablation: native compilation with its ground-fact index suffices for all six workloads.
- Add native/interpreter differential regressions and six reproducible shared-source
  benchmarks against optimized SWI-Prolog, including raw timing/allocation samples.

# 0.10.0 — 2026-10-13

- Separate implementation packages by responsibility and aggregate only the public
  interface with UIOP use-reexport. Move derived predicates into protected library clauses.
- Fix portable decimal number output across Lisp implementations.
- Add an independent `src/prolog/text/` textual reader/loader with string, file and
  stream APIs, operator parsing, common load-time directives and DCG expansion.

- Align FUNCTOR, ARG and UNIV with predicate-call name and finite argument count;
  canonicalize zero-arity construction to atoms and retain arbitrary argument graphs.

- Add 27 ISO-named predicate indicators with Lisp-native cons semantics:
  cons inspection/construction, term order, sorting/SETOF, S-expression term I/O,
  and database-local operator/character configuration.
- Keep derived comparisons, SETOF, and current-stream I/O as ordinary clauses.
- Preserve rational-tree terms; cyclic ordering reports an explicit representation error.

# 0.9.1

- Add source `(let name initializer [declaration])` for nonspecial Lisp bindings in subsequent callbacks.
- Preserve lexical mutation and escaping closures, with independent cells per invocation.
- Support conjunctions, branch-local controls and DCG DO; retain environments across cursor yields, GC and caller-side tabling.
- Keep dynamic special binding / `let*` outside this implementation.

# 0.9.0

- Make `?-` interactive: print one answer, compute another only after `;`, stop on Enter or EOF.
- Display binding values, ground success/failure and conditional SLG answers with delayed negations.
- Use `*query-io*`, print cycles safely and close cursors on every exit path.
- Keep `query` for collecting results; migrate batch examples and regression helpers.

# 0.8.1

- Use quoted token lists in DCGs, with `and`, `or` and `do` for grammar controls.
- Preserve `-->` / `--->` append/replace semantics and accept the old keyword forms for compatibility.
- Migrate examples and regressions; validate malformed quoted token lists.

# 0.8.0

- Adopt a single Lisp cons term model; restore direct list/dotted-pair syntax and remove special list/cons constructors.
- Remove functor/arg/univ, standard term ordering, sort/keysort/setof (11 predicates).
- Remove the Prolog parser/printer, text predicates, operator declarations and character conversion (16 indicators).
- Keep bagof groups in first-appearance order, without term sorting.
- Rename implementation/test/example files to builtins and expose builtin-predicate-inventory (101 core indicators plus 7 aliases).
- Preserve WAM, GC, DCG, SLG, control, arithmetic, dynamic definitions and character/byte streams.

# 0.7.0

- Use ordinary `(f a b)` syntax for compound terms; remove public `:compound` syntax.
- Add variadic `list` and binary `cons` term constructors; reject raw dotted source terms.
- Decode term graphs iteratively at query/clause entry, preserving sharing and cycles.
- Keep parsed Prolog encodings intact and expose compound answers without private markers.
- Migrate DCG, ISO, SLG and GC regressions, examples and documentation to the new syntax.

# 0.6.2

- Rename DCG definition macros to `-->` (append) and `--->` (replace); remove the `->` definition macro.
- Reserve goal `->/2` for ISO if-then; validate first-solution commitment, else behavior, meta-calls and DCG semantic goals.

# 0.6.1

- Keep `=/2` for unification and add `/=/2` as the S-expression alias for ISO nonunifiability.
- Add `/==`, `===`, `=/=`, `/+`, `and/2` and `or/2` aliases for ISO goals, preserving cut scopes and meta-call behavior.
- Add `rule` for dynamic rule terms and `logand`, `logior`, `lognot` for arithmetic expressions.
- Protect predicate aliases from builtin redefinition.
- Fix cut isolation inside negated goals for both `/+` and ISO negation.
- Add forced-GC, binding rollback and rational-tree regressions for the spellings.

# 0.6.0

- Add `src/iso.lisp`: 128 ISO core predicate indicators plus arithmetic evaluables.
- Add explicit ISO compounds, term tests/order/introspection, occurs check, copying and atom/number conversions.
- Implement VM meta-calls, conditionals, negation, once/repeat, catch/throw and catchable Prolog error balls.
- Extend VM GC and SLG snapshot copying with exception-handler roots and rollback marks.
- Add immutable dynamic updates, logical update snapshots, nondeterministic retraction and solution collectors.
- Add database-local streams, flags, operators, character conversion and Prolog text I/O.
- Preserve the S-expression frontend; document atom/term interoperability and conformance limits in ISO.md.
- Add ISO regressions, including forced GC, deep arithmetic/meta-calls, lexical roundtrips and file I/O.

# 0.5.0

- Rename project, ASDF systems and Lisp packages to ooparts/prolog.

- Replace forest-wide completion with dynamic SCC-local completion and local waiters. Recursive intra-SCC calls still use copied consumer continuations.
- Support CUT in tabled generators, untabled helpers and tabled DCGs when it does not cross an incomplete tabled subgoal.
- Add typed SLG-INCOMPLETE-CUT errors; check frozen alternatives using logical scope identities and rebase all copied physical cut boundaries.
- Preserve opaque PHRASE cut scopes across suspension and resumption.
- Abort cursors and release query-local tables on execution errors.
- Add completed-component, maximum-component-size and local-wait statistics.
- Add local-scheduling/cut regression cases with disabled and forced GC; retain independent WFS oracle coverage.

# 0.4.0

- Add suspension-based SLG variant tabling with query-local table space, answer deduplication, copied WAM consumer continuations, and a nonrecursive work queue.
- Add ground TNOT, delayed negative literals, conditional answers, simplification and well-founded three-valued results.
- Add TABLE/UNTABLE, QUERY :TRUTH-VALUES, extra NEXT-SOLUTION truth/delay values and SLG statistics.
- Support left-recursive tabled DCGs and mutual recursion; retain the sole granular WAM backend.
- Reject cyclic table terms, floundering, impure generator operations and changes during active tabled queries.
- Validate against an independent alternating fixed point for finite propositional programs, plus GC and dependency-depth tests.

# 0.3.1

- Rename DCG rule macros: `->` adds a rule and `-->` replaces rules of the same name and arity. Remove `-->>`.
- Update examples, documentation, and regression tests to use the new names.

# 0.3.0

- Adopt the granular WAM exclusively; remove reference backend and duplicate code storage.
- Remove :BACKEND arguments from QUERY and MAKE-QUERY.
- Add --> / -->> DCG definition macros and PHRASE/2,3 goal expansion.
- Add runtime Lisp PHRASE function and public DCG-EXPAND inspection API.
- Add terminals, epsilon, sequences, alternatives and semantic goals with lexical callbacks.
- Compile inline alternatives to branch choice points, retaining prefix side-effect semantics.
- Root saved branch environments during GC and restore them on backtracking.
- Keep grammar-rule cuts local and PHRASE expression cuts opaque to the caller.
- Hide fresh difference-list variables from query results and reject cyclic grammar controls.
- Add parsing, generation, semantic attributes, GC and deep-grammar regression tests.
- Add source-level execution coverage for all eighteen term instructions.

# 0.2.0

- Compile clause heads and body terms to granular WAM instruction families.
- Implement X/A aliasing, Y slots, read/write scans and environment deallocation.
- Add managed variable/cons heap mark/compact, including cyclic term graphs.
- Remap every surviving choice point's heap and trail restoration marks after GC.
- Trail only bindings requiring rollback; prune unreachable/dead undo records.
- Collect automatically at safe boundaries; support GC thresholds and manual GC.
- Release VM roots on exhausted queries as well as explicit cursor close.
- Keep a reference backend for differential validation.
- Expand verification to 820 checks, including bounded heap stress tests.

QUERY and MAKE-QUERY gain :BACKEND and :GC-THRESHOLD keywords.
COLLECT-QUERY-GARBAGE is exported. QUERY-STATISTICS now reports managed cells
(variables and cons cells), allocation totals, Trail and GC counters.

# 0.1.0

Initial S-expression API, explicit-control VM, template-based term processing,
lexical callbacks, clause replacement and 27 semantic/stack-safety checks.
