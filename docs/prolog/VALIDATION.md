# Validation

Predicate specialization is enabled by default. `:execution-mode :auto` compiles
eligible pure predicate groups into Common Lisp; `:wam` is the per-database
interpreted oracle, and `OOPARTS_PROLOG_DISABLE_NATIVE=1` disables compilation
process-wide. `query-statistics` reports `:native-calls` and
`:native-deoptimizations`. Compiled groups use a direct tier bounded by logical
depth 256 and continue deep semidet recursion on an explicit-stack tier over a
heap arena bounded at 1,048,576 slots; a depth promotion reuses the same attempt
and counts as one native call, not a deoptimization. The contract is in
[NATIVE-JIT.md](NATIVE-JIT.md).

Recorded with SBCL 2.5.4 on aarch64-linux and a 1 MiB control stack.
`python3 tools/lisp.py tools/test.lisp all` prints:

| Component | Checks |
| --- | ---: |
| Prolog | 6027, including 389 native-specializer and 110 explicit-stack |
| regexp | 5650 |
| SAT API | 40 |
| Numeric/representation boundaries | 51 |
| Lisp interface | 475, including 96 exhaustive-oracle cases |
| Arena storage | 69 |

The ISO adapter selects the pinned 782-definition inventory. The native-model
profile reports 718 PASS / 56 SKIP / 8 XFAIL, and the strict term-model profile
reports 726 PASS / 56 SKIP, with no FAIL or BLOCKED in either.
`python3 tools/check-layout.py` prints
`Layout, inferred packages and licenses verified; 293 pinned vendor files.`

```sh
python3 tools/lisp.py tools/test.lisp all
python3 tools/check-layout.py
```

Benchmark measurements, allocation and cold-compile figures, and their reproduce
commands are in [BENCHMARKS.md](BENCHMARKS.md).

# Historical records (superseded)

Every section below preserves the counts, scope and wording recorded at its
revision. Those numbers are not current; use the table above for the present
tree. Optimizer comparisons and removal claims in the 2026-10-23 record describe
an implementation that no longer exists.

# Portable WAM execution — 2026-10-23 (superseded)

At this revision, predicate specialization and native JIT compilation were absent.
Every Lisp implementation used the same WAM execution path, without mode caches
or native call/deoptimization counters. WAM compilation and lexical Lisp callbacks
remained.

SBCL 2.2.9 with a 1 MiB control stack passed **5,632 checks**. General collection
regressions cover both term models, empty/nested collections, compound elements,
answer order and duplicates, variable sharing, cuts and forced GC. Optimizer-only
comparisons and fallback-counter assertions were absent at this revision.
The 54 normalized derived observations match the preceding revision byte for byte.
The bundled corpus completes with 726 PASS / 56 SKIP in ISO mode and
718 PASS / 8 XFAIL / 56 SKIP in the default model, with no FAIL or BLOCKED in
either mode. All 13 driver tests pass. The six shared-source workloads return
their expected results in both models through WAM execution.

Earlier validation records below describe the revisions tested at the time;
their optimizer-specific checks and measurements do not describe the current tree.

# ISO failure and applicability corrections

SBCL 2.2.9, 1 MiB stack: **5,350 native checks pass**. The bundled corpus completes
with **718 PASS, 8 XFAIL, 0 FAIL, 56 SKIP, 0 BLOCKED** against the preceding
baseline, including `--strict`. All five former failures are resolved; six
previously disabled bitwise checks execute against documented implementation
choices. The original vendored files and native term representation are unchanged.

OP rejects infix/postfix conflicts and the native empty-list atom atomically;
redefinition/removal replaces a fixity group. PUT_BYTE validates byte type/range,
retaining instantiation errors and writing boundary bytes. The READ error example
now requires the syntax error without prescribing undefined input consumption.
**Twelve driver tests pass**, including rejection of missing/wrong syntax errors.
All **54 derived observations** match the preceding processor revision byte for
byte. See [ISO compatibility](ISO-COMPATIBILITY.md) for scope, exact exceptions,
remaining skips and implementation-defined values.

# Bundled Apache-2.0 ISO port

All **782 ISO-labelled definitions from 93 Logtalk source files** are bundled
with their originals, source pins, LICENSE/NOTICE and an executable plain Prolog
port. SBCL 2.2.9, 1 MiB stack: **707 PASS, 8 XFAIL, 5 FAIL, 62 SKIP, 0 BLOCKED**.
The driver passes **11 tests**, including real text/binary I/O, variable sharing,
subsumption/variants, setup/cleanup, applicability, isolated databases/files,
timeout continuation, malformed protocols and complete source inventories.

Normal execution requires Python and SBCL only, with no source downloads,
Logtalk import or SWI runtime. SWI is an optional development-only converter.
The prior importer limitations are resolved; five remaining observations are
visible failures. The eight native-model exceptions and 62 inapplicable or
undefined definitions are explicit, not passes. Strict exception patterns and
the SETOF variable-order correction are recorded alongside original expectations.
See [ISO compatibility](ISO-COMPATIBILITY.md) for limitations and reproduction.
No processor source was changed in this port. The earlier 5,290 native-check
result below belongs to the preceding implementation revision.

The remaining sections are historical measurements of previous corpora.

# ISO specification precedence

SBCL 2.2.9, 1 MiB control stack: **5,290 native checks pass**. The 987-check
Hodgson corpus records **960 PASS, 6 XFAIL, 11 FAIL, 10 SKIP, 0 BLOCKED**.
Four previous failures now pass under ISO 7.2, 7.4.3, 7.5.2 and 7.5.3:
compound-term ordering, empty declared procedures, static update protection and
private source-procedure access. Source metadata distinguishes quoted predicate
case and is cleared with user definitions. Native Lisp definitions retain their
extension behavior. Tests cover float/integer and compound order, mixed-extension
transitivity, all update operations, dynamic reflection and empty declarations.

The adapter's ten tests pass. All 54 derived observations match the immediately
preceding correction commit. No upstream goal or expected answer changed. The
remaining failures are historical-suite expectation/harness issues, detailed in
[ISO compatibility](ISO-COMPATIBILITY.md).

# ISO validation and number conversion corrections

SBCL 2.2.9, 1 MiB control stack: **5,217 native checks pass**. All **987**
Hodgson check points complete: **956 PASS, 6 XFAIL, 15 FAIL, 10 SKIP, 0 BLOCKED**.
Thirty-one previous FAILs now pass. One previous PASS exposes a contradictory
upstream CALL expectation, and one existing FAIL now observes the corrected
character error class. These two changed observations are explicitly retained in
the baseline; the upstream goals and expectations are unchanged.

Tests cover concrete and partial numeric representations, malformed predicate
indicators, body validation independent of clause lookup, exact character and
stream errors, whole-body callable culprits, explicit meta-call boundaries and
rejection before side effects. The driver still passes ten tests. The 54 existing
derived observations differ only for the corrected CLOSE stream-domain error.
See [ISO compatibility](ISO-COMPATIBILITY.md) for remaining failure categories.

# Hodgson ISO suite port (historical baseline)

At this historical revision, the ISO CI corpus was Hodgson's plain-Prolog INRIA and standard-example
suites: **987 check points, 926 PASS, 6 XFAIL, 45 FAIL, 10 SKIP, 0 BLOCKED** on
SBCL 2.2.9 with a 1 MiB control stack. The 977 applicable checks execute; ten
explicit arity/integer/character-set premises are false. Logtalk/SWI import,
fixtures and baseline are replaced. Different corpus sizes are not a coverage
comparison. The historical measurements below refer to the former Logtalk corpus.

**5,089 native checks** and **ten adapter tests** pass. The adapter tests include
28 synthetic check points, failure/exception classification, flag/setup replay,
process/database/file isolation, timeout continuation, real HALT exit and source
pinning. New parser checks load a 2,000-goal conjunction, retain mixed-operator
associativity and reject invalid equal-priority operands with the same stack
limit. The 54 serialized derived observations match the preceding revision byte
for byte. See [ISO compatibility](ISO-COMPATIBILITY.md) for source pins, adaptation
boundaries, historical-suite limitations and reproduction.

# Independent Lisp/Prolog stream syntax

SBCL 2.2.9, Linux x86-64: **5,086 checks pass** with a 1 MiB control stack.
The driver passes nine tests; all 782 ISO observations still match the existing
baseline (656 PASS, 9 XFAIL, 2 FAIL, 115 BLOCKED) with both stream syntax flags
set to Prolog. The 54 serialized derived observations match the previous
ISO-fixes revision byte for byte with default Lisp I/O.

`read_syntax` and `write_syntax` independently accept `lisp` (default) or
`prolog`. Tests cover database isolation, persistence after backtracking/clause
clearing, syntax switching, atom quoting/escapes, variable aliases and name
collisions, numbered variables, canonical output, all seven operator fixities
and precedence/associativity, list/application mapping, explicit cycle/opaque
object errors and public wrapper contexts. Round trips run with GC disabled and
thresholds 1, 8 and 4096. Iterative output handles a 10,000-level compound term
and a 20,000-element list under the same stack limit.

# ISO compatibility failure fixes

SBCL 2.2.9, Linux x86-64: **4,764 native checks pass** with a 1 MiB control stack.
The ISO driver passes **nine tests**. The pinned Logtalk inventory completes with
**656 PASS, 9 XFAIL, 2 FAIL and 115 BLOCKED** out of 782 definitions, with no
baseline regressions. The remaining FAIL entries concern native term ordering;
the XFAIL entries record exact cons/NIL/pair-model differences. BLOCKED entries
are reported framework limitations, not successful executions.
See [ISO-COMPATIBILITY.md](ISO-COMPATIBILITY.md) for scope and reproduction.

New regression checks cover runtime conjunction/disjunction/if and cut opacity,
implicit variable calls in dynamic clauses, atom-headed zero-arity clauses,
cyclic argument sharing, protected-procedure errors, arithmetic powers, ARG and
operator validation, flags, and opt-in Prolog stream reading. Variable sharing,
option terms, quoted atom case, EOF and syntax switching are checked with GC
disabled and thresholds 1, 8 and 4096. Existing callback, SLG, logical-update and
stress tests remain in the full suite. The 54 serialized derived observations
match the initial ISO-baseline revision byte for byte.

# Native specializer validation — 2026-10-30 (superseded)

At this revision, portable automatic specialization was implemented in
[`src/prolog/syntax/native.lisp`](../../src/prolog/syntax/native.lisp) and tested
by `tests/prolog/syntax/native.lisp` (278 differential checks at that time). Every
semantic observation ran on fresh `:auto` and `:wam` databases and compared
ordered answers, duplicates, truth values, delays, normalized ISO exception
terms, graph/atom identity and cursor statistics.

| Host | `:auto` | `OOPARTS_PROLOG_DISABLE_NATIVE=1` |
| --- | ---: | ---: |
| SBCL 2.5.4 (local, script and `nix run .#test-prolog-sbcl`) | 5,916 | 5,892 |
| CLISP 2.49.95 | 5,916 | 5,892 |
| ABCL 1.9.3 | 5,916 | 5,892 |
| ECL 24.5.10 | 5,913 | 5,889 |

The five checks added with the non-finite arithmetic fix run on every host and
are the only difference from the counts measured for the preceding commit
(5,911/5,887 SBCL, CLISP and ABCL; 5,908/5,884 ECL). SBCL and the ECL auto cell
were re-measured at 5,916/5,892 and 5,913; the remaining cells follow from the
same host-independent checks.

The delta is limited to assertions that require actual compiled execution. ECL
additionally skips three exception-shape assertions because its interpreted
`(mod 1 0)` returns the dividend instead of signaling; the native path still
must reproduce that interpreted outcome, and it does. CCL, CMUCL, Clasp and MKCL
are unavailable for this host/platform; no result is claimed for them.

Coverage includes the public smoke (`fac(10,R)` = 3628800, compiled mode cached,
second query reuses it, `:wam` builds no cache), semidet cut/failure placement,
no answer lookahead and delayed errors, `findall` bag validation and graph
isolation, ground-input aliasing with a single published root, atom-name
matching across Lisp packages, depth/fuel/answer bailouts with transactional
replay, clause-replacement cache invalidation, dispatcher and provider
instrumentation, forced managed GC, high-arity rejection, and tabled/arithmetic
boundaries. Deep pure recursion inside the host-depth budget runs on the direct
tier; beyond it the same attempt is promoted once to the explicit-stack tier,
which answers from a heap arena without host stack exhaustion and without a
replay. `run-native-stack-tests` in the same file covers that tier portably.

ISO adapters: `tools/prolog/iso/run.py --term-model iso --strict --jobs 2`
selects 782 upstream cases and reports **726 PASS, 0 FAIL, 56 SKIP** both with
and without the native path, matching the record above.

The two disputed `log(0)` and `log(0.0)` cases initially failed on this host:
`iso-eval` accepted `(log 0d0)` because SBCL 2.5.4 returns negative infinity.
The baseline records these cases as PASS, so the recording host's `log` did not
return a finite real value. The transcendental branch now rejects any non-finite
or complex result as `evaluation_error(undefined)`, which satisfies both disputed
zero-argument cases and the undisputed negative-argument one. A probe of the
unmodified checkout (a detached worktree at `HEAD`) reproduced the infinity, so
the gap was host behavior rather than a checkout regression.

Specialization measurements: `benchmarks/prolog/jit-compare.py --repeats 7
--batch 20` on SBCL 2.5.4, Linux aarch64, two counterbalanced fresh-process
rounds, same sources, validated results.

| Workload | `:wam` median | `:auto` median | Speedup | Native calls/deopts |
| --- | ---: | ---: | ---: | --- |
| 8 queens | 106.7 ms | 0.98 ms | 108.9x | 1 / 0 |
| Takeuchi (16,10,4) | 203.1 ms | 0.82 ms | 248.0x | 1 / 0 |
| Naive reverse, 1200 | 2344 ms | 2790 ms | 0.84x | 3 / 2 |
| Quicksort, 2000 | 247.1 ms | 244.3 ms | 1.01x | 4002 / 2 |
| Graph, 1024 paths | 541.6 ms | 541.9 ms | 1.00x | 0 / 3 |
| Symbolic differentiation | 42.7 ms | 0.374 ms | 114.2x | 1 / 0 |

This table records the direct tier alone at the 2026-10-30 revision: reverse
exceeded the logical depth budget and was replayed by the interpreter, which cost
the reported 16%. It is retained as the pre-promotion baseline, is reproducible
from its recorded JSON, and was not modified. Current numbers, where every case
completes on exactly one native attempt with no replay, are in
[BENCHMARKS.md](BENCHMARKS.md). No SWI-Prolog parity is claimed.

The previous native-compiler record follows and describes a superseded revision.

# Prolog validation — 0.10.0, 2026-10-13

SBCL 2.2.9.debian and CLISP 2.49.93+, Linux x86-64. No external Lisp libraries.

```sh
sbcl --dynamic-space-size 2048 --control-stack-size 1 --script tools/test.lisp prolog
```

4,540 checks pass on SBCL with a 1 MiB Lisp control-stack limit and on CLISP.
The Prolog-loader PR passed all 17 CI jobs before merging.
The portable execution backend is granular WAM. The earlier reference backend and
its selectable API are removed. The suite includes WAM-only GC comparisons and
the builtin, term-model and DCG syntax regressions.

| Stress case | Result | Max VM continuation depth | Max managed heap cells |
|---|---|---:|---:|
| 1,000,000 deterministic tail calls | Pass | 1 | 4,096 |
| 100,000 non-tail calls | Pass | 100,001 | 100,000 |
| 100,000 tail iterations constructing/discarding compound terms | Pass | 2 | 65 |
| Compile/unify/export a 100,000-element list | Pass | Iterative traversal | Input-sized live terms |
| Parse 10,000 tokens with a right-recursive DCG | Pass | 1 | 13,079 |
| Expand a 10,000-level nested DCG AND expression | Pass | Iterative expansion | Source-sized work list |

The million-call run allocates 1,000,000 managed cells and reclaims 998,936 before
its first answer. The garbage-producing run allocates 800,000 cells, reclaims
799,967 and has a maximum post-GC live set of 8 cells. These are VM ownership-cell
statistics, not process RSS or total Lisp allocation measurements.

The DCG recursion stress case retains 10,001 choice points because its epsilon
alternative exists at every recursive level. GC correctly preserves those
alternatives. Bounded tail continuation depth does not imply bounded search memory.

## Semantic and GC coverage

- Original core unification, clause order, recursion, cut, rollback and lexical host tests.
- 96 independently varied queries compared with GC disabled vs thresholds 1, 8, 64.
- All eighteen term instructions executed through actual S-expression source programs.
- Cyclic terms/source graphs, forced GC between answers, scan roots and cursor release.
- DCG parsing and generation, semantic trees, empty rules, repeated/compound tokens,
  PHRASE/2 full consumption and PHRASE/3 residual input.
- Nested sequences, nested/multiple alternatives and relocated branch addresses in
  non-first clauses; prefix side effects execute once across branch alternatives.
- Predicate-local cuts, pruning grammar clause alternatives, and opaque PHRASE
  expression cut scope preserving caller choices, including forced GC.
- Embedded semantic goals, lexical Lisp callbacks, runtime Lisp PHRASE, hidden
  generated variables, rule replacement and malformed/cyclic grammar rejection.
- DCG answers compared with independent hand-written difference-list rules with
  automatic GC disabled and enabled.

These are regression tests and observed execution results, not a formal proof or
an Allegro/ISO conformance suite. The append, DCG and SLG standalone examples also pass.

## SLG and well-founded semantics coverage

- Cyclic transitive closure with the left-recursive clause first, mutual recursion,
  positive loops without a base, nonground answers, variable aliasing, duplicate
  suppression, ground success, tabled tail calls and caller cuts.
- Automatic GC disabled vs thresholds 1, 8, 64; forced collection between answers,
  independent consumer bindings, EQL identity for string/vector atoms and teardown.
- Left-recursive tabled DCG full parses and all prefix answers.
- Ground TNOT true/false/undefined, odd and even negative loops, removal of
  conditional answers with failed suffixes, late-answer invalidation, domination
  by unconditional variants, branch delay rollback and nonground generators
  with ground negative children.
- Independent alternating-fixed-point oracle: all 1,024 subsets of two-atom
  empty/single-literal rules (2,048 truth comparisons), plus 300 deterministically
  sampled three-atom programs (900 truth comparisons). These verify finite
  propositional cases, not unrestricted first-order completeness.
- 500-level dependency chain (501 tabled subgoals) completes under the same
  1 MiB Lisp control-stack limit.
- Rejection of floundering, untabled negation targets, cyclic table terms,
  host operations inside generators, host callbacks after conditional answers
  and database changes during active tabled queries.

This is a copying SLG implementation. Suspended consumers retain independent
WAM graphs; dynamic SCCs complete individually at local quiescence. SCC graph
traversals use explicit work lists. Shared frozen WAM stacks, subsumption,
immediate ground-success completion and incremental tables are outside this release. Existing heap statistics exclude table space
and suspended-worker allocation; no process memory or speed comparison with
XSB is claimed.

## Local scheduling and cut coverage

The same semantic suite and independent WFS oracle run after the scheduling change.
New cut cases run with automatic GC disabled and thresholds 1, 8, 64:

- Generator-entry cuts, pruning ordinary alternatives and retaining alternatives
  introduced after a cut.
- Completed child-table and recursive child-SCC cuts; other child answers remain
  available to subsequent goals in the same query.
- Helper-local cuts after an earlier caller suspension.
- Typed rejection of cuts over direct/mutual recursion, returned suspended helpers,
  frozen consumers in an earlier clause and delayed negative recursive calls.
- Completed undefined child SCC before a parent's cut.
- Tabled DCG predicate cuts and opaque PHRASE cuts, including after suspension.
- Two mutually recursive SCCs finish independently, with observed component
  count 2 and maximum completed-component size 2.
- Illegal cuts abort the cursor immediately, release partial tables and prevent
  continuing past the failed CALL/CUT.

This validates the implemented restriction; it is not a full SWI-Prolog/XSB
compatibility claim.

## Lisp-native builtins and cons terms

SBCL 2.2.9, Linux x86-64, 2 GiB dynamic-space ceiling, 1 MiB control stack:
**4,190 combined checks pass**. The core builtin registry contains **101 predicate
indicators**, plus seven aliases. ISO conformance and Prolog text conversion are
outside the specification.

`tests/adapters/builtins.lisp` covers arithmetic, cons graph operations, control/cut scopes,
meta-calls, exception rollback, dynamic updates, findall/bagof, atom/number
conversions and character/byte streams. Forced-GC checks use thresholds 1, 8 and
4096, as well as disabled collection. Stress cases retain 100,000 arithmetic tail
calls, 10,000 meta-calls and a 10,000-level arithmetic expression.

`tests/syntax/term-syntax.lisp` verifies native cons terms and dotted tails, cyclic inputs,
ordinary LIST/CONS data symbols, meta-calls, exceptions, dynamic definitions,
first-appearance BAGOF grouping, and all 27 removed predicate indicators.
Existing 100,000-element list, WAM instruction-family, DCG, SLG and independent
well-founded-model oracle tests remain in the combined suite.

Standalone append, DCG, SLG and builtin examples are checked locally.

## Quoted DCG syntax (0.8.1)

DCG regressions use quoted token lists and and/or/do controls, including variable
and compound tokens, empty productions, lexical callbacks, nested alternatives,
cut boundaries, tabled grammars and forced GC. Runtime grammar data is tested
separately from definition/query macros. Malformed and cyclic quoted token
sequences are rejected; legacy keyword syntax remains covered for compatibility.

## Interactive queries (0.9.0)

`tests/api/interactive.lisp` checks demand-driven alternatives (including infinite
REPEAT), EOF and explicit stop commands, invalid-command retries, ground success,
failure, cyclic answer printing, lexical callbacks, undefined SLG answers and
cursor teardown after stop, errors and nonlocal exits. Batch regressions use a
private collecting macro; the public `?-` interface is exercised separately.

## Lexical LET (0.9.1)

`tests/syntax/let.lisp` covers logic-variable and lexical initializers, shadowing, optional
declarations, mutation, escaping closures, branch scope, initialization counts,
DCG DO, independent cursors, compiled hidden variables, ordinary callers of
tabled predicates and forced GC. A 10,000-call tail-recursive predicate using
LET retains continuation depth one with a 1 MiB host control stack.

## Performance investigation

[Benchmarks](BENCHMARKS.md) records five-run timing/allocation medians for 13
workloads, CPU and allocation profiles, and process-local diagnostic experiments
on revision be479795 (0.9.1). Timing, cumulative allocated bytes and peak managed
cells are distinct metrics. No runtime optimizer was installed by the investigation.

## Cons operations and S-expression term I/O

The cons-model extension adds 27 indicators, bringing the public inventory to
128 (74 primitive/adapters, 8 syntax, 46 derived). SBCL with a 1 MiB control stack
and CLISP both pass **4,475 checks**. The existing derived-observation output is
byte-for-byte identical to the namespace-refactor reference output.
New checks cover finite application decomposition/construction, zero-arity canonicalization,
callable reconstructed goals, cyclic argument graphs and shared
variables, stable pair sorting, SETOF grouping/existentials, forced GC, deep term
comparison, deep finite arities, SLG term operations and ordering, protected definitions, reader options and disabled
read-time evaluation, cyclic I/O round trips, EOF, variable-name collisions,
public wrapper exception contexts, and database-local configuration retained
through failure and clause clearing.

## Prolog textual loader

The textual interface adds five Lisp APIs without changing the 128 predicate
indicator inventory. The complete SBCL suite (1 MiB control stack) and CLISP each pass
**4,540 checks**. New checks cover native list/compound mapping, per-term variable
scope, operator precedence and fixities, numeric/quoted text, character conversion,
reader flags, stream lookahead/EOF, load replacement, multifile and empty dynamic
declarations, initialization, relative includes, ensure-loaded cache invalidation,
recursive includes, DCG expansion, long flat terms and controlled nesting errors.
The preexisting derived-observation output remains byte-for-byte unchanged.

## Optional strict ISO terms

SBCL with a 1 MiB control stack passes **5,476 checks**. The 126 additional
strict-mode checks exercise list/compound and atom distinctions, internal-name
collisions, FUNCTOR/ARG/UNIV agreement, character/code relations, copying and
variable sharing, collectors, sorting, dynamic clauses, rational trees, textual
and Lisp DCGs with lexical callbacks, SLG cursor resumption and forced GC. Four
GC thresholds include collection at every safe point. Native-mode behavior and
all 54 derived observations remain unchanged.

The same bundled 782-definition corpus completes in both modes: native reports
718 PASS / 8 XFAIL / 56 SKIP, while ISO reports **726 PASS / 0 XFAIL / 56 SKIP**.
Neither has FAIL or BLOCKED. Strict mode has no expected-difference entries;
undefined STO and applicability skips are unchanged. Thirteen driver tests cover
isolation, error/result checking, timeouts, source integrity and strict-mode
selection. See [ISO compatibility](ISO-COMPATIBILITY.md) for reproduction and
license/provenance details.
