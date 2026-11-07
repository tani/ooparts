# Optional MLton regression-case runner

`tools/sml/mlton.lisp` is an **explicitly optional development tool**. It is not
part of an ASDF test operation, an existing core regression command, or a claim
of SML compatibility. It does not run unless the user invokes it. Individual
case results and explicitly bounded assessment batches do not imply
whole-corpus conformance.

The parent script implements enumeration, assessment handling, pristine-corpus
checks, oracle selection, byte comparison, process management, and reporting.
`tools/sml/mlton-worker.lisp` is its one-case child. A fresh worker gets a fresh
initial Basis for each executable case, so host state, dynamic bindings,
exceptions, references, and constructed-datatype identities are not shared
between cases. Both scripts use only Common Lisp, ASDF/UIOP, and OOPArts.
Only individually assessed cases with observable results are reported; passing
selected cases is not whole-corpus conformance.

## Corpus provenance and immutable inputs

The optional checkout in `build/mlton/` is the MLton repository at detached
commit `5fe943391e539a502699327a6266b6e8e97939e1`. The required regression
tree is `d3c35781496aa17015cfdf4a6a4afb6c0f8bb380`. The implementation is based
on the checked-in `build/mlton/bin/regression`, not on a generic guess about
MLton conformance.

The corpus is reference-only and is not distributed with OOPArts. Its root
license is HPND, not MIT. Preserve all of the following:

- `build/mlton/LICENSE` (Historical Permission Notice and Disclaimer);
- `build/mlton/doc/license/README` and every retained component notice below
  `build/mlton/doc/license/`, including SML/NJ, NEC, MLKit, and gdtoa material;
- `build/mlton/regression/README` and
  `build/mlton/regression/README.kit`; and
- original source-file copyright comments.

Before and after an invocation, the script uses path-list `git` invocations (no
shell command construction) to verify the commit and regression tree and to
require `git status --porcelain=v1 --untracked-files=all -- regression` to be
empty. It never resets or cleans the checkout. Source files, input files,
`.ok` oracles, and `.nonterm` sidecars are read-only. No oracle is generated
from OOPArts behavior. Generated requests, responses, logs, captures, and
reports are confined to `build/sml/`; the options cannot name an absolute path
or traverse out of it, and resolved output directories must remain below it.

## Selected observed probes

Each probe used `--execute`, one exact `--case`, and a separately reviewed
assessment. The unchanged pinned source was compiled and run by OOPArts, not an
external SML compiler. A normal-case `PASS` requires equality with the upstream
`.ok` combined standard-output/error bytes.

| Case or control | Observed outcome |
|---|---|
| `hello-world.sml` | Passed; exact 14 ASCII bytes, `Hello, world!` followed by LF. |
| `fact.sml` | Passed; exact 8 ASCII bytes, `3628800` followed by LF. |
| `functor.sml` | Passed; both exact LF-terminated output lines, 28 ASCII bytes: `value is A(K)` and `value is A(J)`. |
| `fail/1.sml` with `:elaboration` and `("y")` | Passed: the intentional unbound `y` is rejected, not accepted as a valid program. |
| `fail/1.sml` with a deliberately wrong allowed identifier | Nonpassing `MISSING-PREREQUISITE`; an unrelated name cannot mask an unbound prerequisite. |
| `fail/1.sml` with correct `("y")` and deliberately wrong `:syntax` | Also nonpassing `MISSING-PREREQUISITE`; correct identifier metadata cannot override a wrong rejection kind. |

The reports retain every discovered case, including `NOT-SELECTED` cases. The
three normal runs each selected one of 288 discovered normal sources, while the
rejection runs selected one of 117 discovered rejection sources. These selected
results are not corpus-wide totals and are not evidence that unassessed,
basis-incomplete, or vendor-specific programs pass. Reports and captures are
ignored development results under `build/sml/`.

A further module control, `signature Bad = sig type 'a t end where type t=int;`,
now rejects deliberate arity mismatch (one parameter to zero). It is not
accepted by treating a signature type constructor as an ordinary alias. Valid
primitive `int`/`ref` refinements and datatype-replication controls remain
accepted through `compile-source`, generated-code compilation, and execution.

### Coherent supported ordinary-case gate

The current supported-corpus result is
`build/sml/splice-coherence/ordinary98-coherent/report.sexp`, selected by the
reviewed `build/sml/reviewed/ordinary-supported.sexp`. On SBCL 2.6.8/Linux arm64
it discovered all 288 ordinary sources and selected 98 eligible cases. Each
worker had a 1 GiB dynamic heap and a 360-second timeout. The independent
response/byte audit is
`build/sml/splice-coherence/ordinary98-coherent-validation.stdout`; it reports no
response failures and this outcome summary:

```lisp
((:NO-ORACLE . 21) (:NOT-SELECTED . 190) (:PASS . 77))
```

| Selected-case classification | Count | Required observation |
|---|---:|---|
| Normal exact-oracle execution | 69 | Completed input, frontend, host compilation, and execution; output matched the upstream oracle byte-for-byte. |
| Intentional-nonzero exact-oracle execution | 2 | The SML exception/nonzero protocol completed and its combined output matched exactly. |
| Required compilation-only success | 6 | Source and generated host code compiled, but the generated program was not invoked and oracle comparison was inapplicable. |
| Executed `NO-ORACLE` | 21 | Genuine execution completed, but no upstream `.ok` exists; this is a selected nonpass outcome, not an oracle pass. |

Thus the 77 `PASS` outcomes comprise 69 ordinary executions, two expected
nonzero executions, and six compile-only dispositions. They are not 98 oracle
passes, and `NO-ORACLE` is never converted into an expected empty byte string.
All 98 selected workers completed without a worker failure or timeout. The
selected inputs totaled 320,193 bytes; the batch took 657.20 seconds with
1,050,752 KiB peak RSS.

**Compilation-only** means successful `compile-source` plus host compilation,
with execution explicitly `:NOT-ATTEMPTED` and oracle comparison
`:NOT-APPLICABLE`/`:COMPILE-ONLY`. An empty capture on this route says nothing
about runtime output and is not a zero-byte execution match. The six ordinary
cases have their own required `.nonterm` sidecars; this does not add a current
result for the separate `nonterminate/8.sml` suite, whose current host-compilation
gate remains pending below.

The other 190 discoveries were not selected or run. Unclassified files, cases
needing richer Basis facilities that are not implemented or reviewed, target
conditions, and vendor extensions are not silently promoted to supported SML '97
conformance. This is a gate for the 98 assessed programs and their declared
constructs, not a claim for every MLton source or the complete Basis library.
The earlier 20-second, 64-`PASS` checkpoint is superseded for current reporting;
its failures are neither folded into nor used to discount this coherent batch.

### Coherent supported rejection-case gate

`build/sml/splice-coherence/fail111-coherent/report.sexp` is the matching
negative-case gate, selected by `build/sml/reviewed/failure-supported.sexp` with
a 120-second case timeout. It discovered 117 rejection sources, selected 111,
and recorded 111 `PASS` outcomes, no selected nonpass, and six `NOT-SELECTED`.
The audit `build/sml/splice-coherence/fail111-coherent-validation-v5.stdout`
reports no response failures. Host compilation and execution were
`:NOT-ATTEMPTED` for every selected negative case; a host crash, timeout, or
unclassified compiler error cannot become a deliberate source-rejection pass.

| Authored passing classification | Count |
|---|---:|
| Actual `:SOURCE-REJECTED` with the reviewed expected category | 104 |
| Reviewed intentional-unbound exception to `MISSING-PREREQUISITE` | 7 |

The frontend category totals are 46 syntax and 65 elaboration. Seven of the
65 elaboration observations are the intentional-unbound cases, rather than
ordinary `:SOURCE-REJECTED` outcomes; there were no representation-category
passes. The seven exact case/identifier contracts are
`fail/1.sml`/`y`, `fail/functor-and.sml`/`F`,
`fail/modules.18.sml`/`T.X.t`, `fail/modules.35.sml`/`ZZZ`,
`fail/signature-and.sml`/`SIG`, `fail/structure-and.sml`/`S`, and
`fail/type.sml`/`u`. These reviewed source requirements are deliberate negative
classifications, not excuses for missing implementation prerequisites.

The six unselected, unclassified sources are `fail/constant-too-big.sml`,
`fail/functor.1.sml`, `fail/overloading-context.3.sml`,
`fail/overloading-context.4.sml`, `fail/overloading-context.5.sml`, and
`fail/overloading-context.6.sml`. They have no supported-gate execution or
rejection result and are neither intended-rejection passes nor compiler
regressions. Only the explicit supported selector establishes the 111-case
count; an unfiltered 117-file invocation is a different run whose six
unclassified selections must remain nonpass.

### Coherent full-input workload outcomes

The following workloads are selected cases in the coherent ordinary report,
not shortened diagnostics or additions to its 98-case count. Oracle paths below
are relative to `build/mlton/regression/`; the report's `:ORACLE-COMPARISON`
records the stated byte counts after independent comparison with the captured
output.

| Workload | Actual coherent outcome |
|---|---|
| Full `fast2.sml` (155 source bytes) | Completed all 100,000,000 tail-recursive iterations and matched `fast2.ok`: seven bytes, exactly `All ok\n`. |
| Full `grow-raise.sml` (110 source bytes) | Executed all 1,000,000 recursive calls under the 1 GiB worker heap and matched the existing zero-byte `grow-raise.ok`. This is an actual empty oracle, unlike `NO-ORACLE`. |
| Full `kkb_eq.sml` (21,836 source bytes) | Completed the three-run computation and matched all 18,768 bytes of `kkb_eq.ok`; it was not compilation-only. |
| Full `kitmandelbrot.sml` (2,176 source bytes) | Completed execution and matched all 57 bytes of `kitmandelbrot.ok`. |
| Full `type-check.sml` (1,715 source bytes) | Completed input, frontend, host compilation, and genuine execution; the outcome is `NO-ORACLE` because there is no `type-check.ok`. No empty-output expectation was invented. |
| Full `undetermined.sml` (845 source bytes) | Completed execution and matched the existing zero-byte `undetermined.ok`. |

#### Full COBOL execution and resource bound

The unchanged original `cobol.sml` is **239,194 bytes** with SHA-256
`49c8f782b6ae5a7a8806791ce4fa6a0a69e93571864efa7fc1947c77113d3b47`.
All three final workers completed the entire input, parse/elaboration, host
compilation, and execution with a **1 GiB dynamic heap** and **360-second case
timeout**:

- `build/sml/splice-coherence/cobol-finalized-1/` recorded 3:36.45 wall time and
  1,076,964 KiB peak RSS;
- `build/sml/splice-coherence/cobol-finalized-2/` recorded 3:42.26 wall time and
  1,081,500 KiB peak RSS; and
- the third response, inside the coherent ordinary batch, is
  `build/sml/splice-coherence/ordinary98-coherent/cases/0052-cobol.sml.response.sexp`.

Each response has terminal `:EXECUTED`, execution `:COMPLETED`, and outcome
`:NO-ORACLE`. The capture is zero bytes because that execution emitted no bytes,
but there is **no `cobol.ok`**, so it is not a byte pass and no empty oracle was
created. The isolated parent runner's status 1 records the selected
`NO-ORACLE` nonpass, not a worker error; the workers' own phases completed.

`nonterminate/8.sml` is not part of the ordinary 98 or negative 111. An earlier
160-byte-source probe reached host compilation through the required
compile-only path, but no actual current coherent host-compilation result is
claimed here. Its acceptance route remains source plus host compilation,
execution `:NOT-ATTEMPTED`, and comparison `:NOT-APPLICABLE`/`:COMPILE-ONLY`;
its gate result awaits an actual current host run and must not be obtained by
executing the nonterminating program.

### Coherent artifact provenance and lifecycle

`build/sml/splice-coherence/final-result.json` consolidates the ordinary,
negative, COBOL, regression, and semantic-control evidence. The ordinary batch,
both isolated COBOL runs, and negative batch used the same isolated sequential
ASDF cache on SBCL 2.6.8/Linux arm64. All **59 loaded FASLs** remained stable,
with before/after source and artifact manifests, rather than mixing a newly
edited source with an older compiled object. The full registry is
`build/sml/splice-coherence/finalized-build.stdout`, and the complete hashes are
in `build/sml/splice-coherence/final-source-and-loaded-artifacts.sha256` and the
consolidated JSON. Key abbreviated hashes are:

- `src/prolog/kernel/engine.lisp`: source `5405ee6f…`, loaded FASL `fb29e29f…`;
- `src/sml/compiler.lisp`: source `2b5929f0…`, loaded FASL `a094ba8e…`;
- `src/sml/emit.lisp`: source `c1d335a5…`, loaded FASL `e3a20114…`; and
- `src/sml/modules.lisp`: source `c5b0fb32…`, loaded FASL `9e169859…`.

The older `final-validation/fail111-final` green case count is not reused because
its provenance is not this coherent epoch. These reports and the JSON are ignored
local build evidence, not committed FASLs or a promise that another cache or host
will reproduce them; the consolidated result also records no commit or staging.

The lifecycle repair preserves semantic identity while reducing redundant live
work. One exact-`EQ` map per query response preserves physical aliases and cycles
among named answer fields; each public map/reify call still has a fresh mapping.
Module producer-spine composition is restricted to exact-identity `LET`
bind-success forms with a generic graph-validation fallback. The compiler builds
the complete compiled program before requesting the existing frontend collection
at the final emission lifecycle boundary, allowing unneeded emission products to
be released while semantic images, source basis, static/module/fixity data,
native code, and strong reference identities remain live. It does not introduce
weak semantic references, monomorphic type aliases, or global semantic caches.
FASL-reload and closure-GC controls passed, as did 15 exact completion/splice
patterns and 15 old/new emission comparisons comprising 30 host executions.

### Earlier host and resource observations

The following measurements belong to earlier checkpoints and are not fresh
serial gates on the coherent corpus epoch. The actual 250,000-call curried
control returned exactly `250000\n`, and the nested 1,000-level handler control
returned exactly `1000\n`; these native execution controls are distinct from a
whole-project suite result.

A separate ABCL native-module profile has also completed all 13 real groups
in one uninterrupted sequence: 229/229 checks in 470.56 seconds on its pinned
loader snapshot, with the same per-query work counts as the independently run
groups. Its logs and isolated FASL identifiers under `build/sml/abcl-single-profile/`
distinguish it from contaminated/uninterrupted-root retries. This is a
native-only result on a stated epoch, not a complete single-process SML suite
or a license to merge epochs after subsequent semantic edits. ECL also has a
separate native-only 229/229 profile; its original full-suite timing comparison
is still unresolved.

The original ABCL full-driver investigation has additional phase evidence in
`build/sml/abcl-single-profile/final-measurements.json`. Before its 900-second
limit, it completed the first five suites (3,852 checks) and nine native groups
(174 checks), then stopped during `ordinary-semantic`, not with a completed
native total. That rejection finished normally in a diagnostic ordered prefix:
960,597 elaboration instructions, 49,865 allocated cells, nine query GCs, and
6,861 maximum live cells. The 30 ordinary checks then passed in 84.026 seconds;
the remaining three native groups took 49.853 seconds in their measured
reference run. Query work matched the complete native-only sequence, heap use
fell by 200,708,152 bytes, and 16,529 classes were unloaded. These results
support accumulated finite work and ABCL throughput variability, not retained
semantic state or runaway elaboration. They neither establish the complete
ABCL suite nor justify claiming that a stopped early rejection was the cause.
The uninterrupted native-only run peaked at 1,996,532 KiB RSS, separately from
the much larger configured JVM heap ceiling.

On the earlier instantiate-repair epoch, a complete single-process ABCL SML
suite passed as well: all 4,081 checks, including all 229 native
modules, in 1154.68 seconds with 2,997,812 KiB peak RSS. The report at
`build/sml/final-validation/abcl-atomic.log` includes Core, Basis, and the
native-module summary, and source fingerprints matched before and after the
run. No Java initialization or weak-map runtime failure occurred. This genuine
later completion follows the finite-work and measured-budget evidence above;
it does not retroactively turn the older 900-second stop into a completed
suite, and it does not establish bounded execution of COBOL across every
ordinary batch.

Rule matching now commits only on an explicitly successful pattern. Matching
and bodies remain independently host-compiled functions; selected bodies do
not retain untried candidate continuations, and exceptions in bodies never
choose another rule. The pending non-tail addition retains a 48-byte
three-capture native closure plus a 16-byte first-field cons: 64 bytes per
level in the measured direct receiver graph. An ordinary-return diagnostic
executed exactly 1,024 additions, while the exceptional control executed zero.
This reduces retained implementation overhead; it does not claim that general
non-tail execution requires constant memory. Full-GC liveness and FASL reload
checks require real committed values and reference identity, not only code
publication or host compilation.

Earlier COBOL second-emission heap failures, including
`build/sml/final-validation/ordinary-atomic/` and the retained one-table and
producer-only experiments, remain historical `WORKER-ERROR` diagnostics from
older epochs. They were not counted as executions or `NO-ORACLE`, and they are
not presented as the current unresolved production outcome now that the three
complete coherent responses above exist. Conversely, those new responses do not
rewrite the old logs. Raised-heap, shortened, and other exploratory runs are
not part of the supported ordinary or negative totals.

### Serial whole-project host checks

Separate current logs under `build/sml/host-validation/logs/` support these
whole-project results; they are distinct from the coherent corpus cache above.

| Host and configuration | Observed result | Wall time | Peak RSS |
|---|---|---:|---:|
| SBCL 2.6.8, default limits | Exit 0; Curry 4,313, Prolog 6,097, SML 4,081 checks. The Prolog run includes 110 explicit-stack and 405 native-specializer checks. | 76.31 s | 539,124 KiB |
| SBCL 2.6.8, 2 GiB dynamic space and 1 MiB control stack | The same groups complete with exit 0, including both native Prolog specializers and SML. | 69.63 s | 477,068 KiB |
| CCL 1.14, default limits | Whole-project exit 0 with the same named component counts. | 216.39 s | 314,724 KiB |
| CLISP 2.49.95+, default limits | Whole-project exit 0 with the same named Prolog/SML component counts. | 1163.13 s | 174,696 KiB |

The corresponding logs are `02-sbcl-full.log`, `03-sbcl-full-2g-1m.log`,
`05-ccl-full.log`, and `18-clisp-full.log`. They are native suite completions,
not corpus byte-pass claims. Independently, `root-fasl-reload.log` records
`FASL-RELOAD: exact output and committed reference state: PASS` for the new
compiled-product boundary.

The independently scoped ABCL **SML component subsequently completed all
4,081 checks**, with natural exit 0 in 1,647.13 seconds and 2,485,276 KiB peak
RSS. The six groups were 163 lexer, 2,835 parser, 267 types, 482 Core, 105
Basis, and 229 native Modules. The ordinary (non-instrumented) worker had its
own cache and 67 fingerprinted cached FASL artifacts, with the retained three
frontend GC requests; no other ABCL profile ran alongside it. The ordinary
transcript provides compile/write evidence, not an additional per-FASL LOAD
trace. See
`abcl-serial-validation/{application.log,run.meta,fasl-manifest.sha256}`.
This proves completion of that component, not a fix for ABCL's separate
whole-project issue, and it does not repurpose earlier unowned late output.

ABCL 1.9.3's full-project attempt remains an observed failure, not a timeout or
successful component validation. It exited 1 after 40.02 seconds with
`Restart MUFFLE-WARNING is not active`, after Curry and Curses but before Prolog
or SML result counts (`08-abcl-full.log`). A separate load/probe produced the
different error `OPERATION instances must only be created through MAKE-OPERATION`
(`09-abcl-load.log`); those two errors must not be conflated. These observations
do not establish an SML semantic failure, suppress the warning, or establish
ABCL Prolog/SML compatibility. Independently, the exact scoped ABCL Prolog
suite completed **6,097 checks**, including 110 explicit-stack and 405 native
specializer checks, in 340.68 seconds with a 2,076,716 KiB peak RSS. That is
actual engine validation, separate from the full-project failure.

The initial scoped ABCL SML run instead met its 600-second limit in the core
group. Lexer (163), parser (2,835), and types (267) completed, but neither the
482-check core group nor the later groups completed (`12-abcl-sml.log`). This
is not a completed 4,081-check SML result. Earlier SML runs required 1,154.68
seconds on ABCL; the new timing and per-fixture investigation is measured
against that history. Neither the earlier epoch nor any timeout is
reused as a passing result for this source epoch.

The post-load-instrumented full run has since completed the actual 482 core
checks and 105 Basis checks, with all 98 frontend calls ending (64 returned, 34
intentional rejections). Run-program measurements total 14.747 seconds over 64
calls, including four intentional SML/test exception unwinds. There are no
unclosed core phases. The full deep-continuation input completed 10.05 seconds
in the frontend, 0.28 seconds in host preparation, and 8.147 seconds executing;
the 600-alternative and 600 named-clause programs also completed. Thus the
600-second run reached ongoing cumulative frontend work, not one demonstrated
semantic deadlock in the large clause case. The completed core/basis evidence
still does not establish the pending 229 native modules or all 4,081 checks.
These phase totals are tied to the preserved core-phase stream
`abcl-core-timing/phases-pid2209527.log` (SHA-256
`46178f00fe4b887e6be44a0ed2ed8c9559631998c0062265758645084e8d37dc`),
plus source and artifact manifests and process identity in
`abcl-core-timing/report.md`. Old observer/bootstrap failures and
mixed-generation aggregates from the cancelled duplicate worker are excluded;
unowned late module output is not treated as a completed run.

### Frontend collection tradeoff and rejected experiment

For fourteen full compile/host/run cases, including reference/module identity
checks and both 600-clause executions, the actual matched measurements were:

| Diagnostic policy | Requests | Suppressed requests | Direct request time | Process time |
|---|---:|---:|---:|---:|
| Original three requests | 42 | 0 | 39.379 s | 171.01 s |
| Diagnostic final-only | 14 | 28 | 12.621 s | 132.32 s |

ORIGINAL included cold-cache compilation while FINAL-ONLY reused those
artifacts. The process-time difference is therefore not an isolated GC-cost
measurement; use the direct-request counts and per-phase timings instead. The
comparison is not proof that earlier collection requests are removable.

The FINAL-ONLY candidate therefore had to pass the actual COBOL guard. Its full
239,194-byte input, under the required 1,073,741,824-byte heap, instead failed
after 218.73 seconds during partitioned rule emission, before the retained
post-program collection. The worker recorded 981,401,248 bytes allocated and
heap exhaustion with 0 bytes available for 144 requested bytes. It produced no
response file and had a `WORKER-ERROR` outcome, not a NO-ORACLE execution. No
second COBOL claim or candidate suite pass was made. The candidate was fully
reverted to the retained three-request compiler, SHA-256 `2b5929f…566d7`.
This preserves large-input resource safety over ordinary-input latency and does
not assert which individual earlier request is independently sufficient. See
`build/sml/gc-revalidation/report.md` for the complete policy comparison and
source/loaded-artifact chronology.

An OOPArts-free, ASDF-free control
(`build/sml/abcl-warning-investigation/bare-jvm-signal.lisp`) returns normally
for direct and compound-handler `SIMPLE-WARNING` signals. The same signals
inside `JVM::%WITH-COMPILATION-UNIT` reproduce the missing
`MUFFLE-WARNING` restart error
(`build/sml/abcl-warning-investigation/logs/08-bare-jvm-signal.log`). This narrows
the full-project failure to the host warning wrapper; it neither fixes nor
masks that failure, and it is not SML portability evidence.

A separate ECL full-project run stopped at its 600-second host limit during
reference reduction at 512/1328 terms (`10-ecl-full.log`). It reached neither
Prolog nor SML result counts. That is an unresolved whole-project timeout, not
a typed rejection or a completed validation of those components. Independently,
the exact scoped ECL Prolog suite passed **6,094 checks**, including 110
explicit-stack and 402 native-specializer checks, in 158.97 seconds with a
1,811,580 KiB peak RSS. Its three fewer assertions are the existing guards for
ECL's interpreted `(mod 1 0)` behavior described in `docs/prolog/NATIVE-JIT.md`;
native execution reproduces the interpreted result rather than skipping a
semantic case.

The subsequent full, unmodified ECL SML component also completed all **4,081**
checks, including the 229 native-module checks, in 1,044.28 seconds with a
160,920 KiB peak RSS (`16-ecl-sml-1500.log`). The 1,500-second bound was chosen
from the actually measured older 1,103.77-second component runtime. Its older
600-second timeout was not sufficient, but the new run is conditioned on actual
source/artifact fingerprints and full groups, not a shortened retry or a reuse
of the older passing result.

The historical CLISP status 245 and separate `Program stack overflow` remain
unknown; they are not two passing suite outcomes or a proved signal cause.
These host limitations do not change the completed supported ordinary and
negative observations above.

## Entry points and inventory

Show the complete CLI without loading the SML compiler:

```sh
sbcl --script tools/sml/mlton.lisp --help
```

Inventory all four supported suite selections without executing SML:

```sh
sbcl --script tools/sml/mlton.lisp \
  --list --suite all \
  --output-directory mlton-inventory --report inventory.sexp
```

`--list` is the default when `--execute` is absent. The default suite is
`normal`; repeat `--suite` to select more than one. The collections are:

| Suite | Pinned source count | Exactly discovered source collection |
|---|---:|---|
| `normal` | 288 | top-level `regression/*.sml` only |
| `modules` | absent | direct-child `regression/modules/*.sml` only |
| `fail` | 117 | direct-child `regression/fail/*.sml` only |
| `nonterminate` | 1 | direct-child `regression/nonterminate/*.sml` only |

`--suite all` expands to those four suite names. At the pinned revision its
report has `:discovered 406` (288 ordinary root files, 117 fail files, and
`nonterminate/8.sml`) and independently reports the absent `modules` suite as
`:missing-suites (:modules)`. This is an inventory observation, not a global
conformance count. The `normal` count remains exactly 288: discovery does not
recurse into `nonterminate/`, `fail/`, or `warn/`, merge suite-relative paths,
or silently prune filenames. The separate warning directory is discussed
below and is deliberately not part of `--suite all`.

If a selected collection directory is absent, it is reported as `SUITE-MISSING`
and recorded in the report's `:missing-suites`; an execution cannot then exit 0.
It is not silently treated as an empty, passing suite.

At the pinned revision, `regression/modules/` does not exist. The retained
upstream README still mentions that directory, but its module programs are
actually top-level files such as `modules.sml`, `functor.sml`, `opaque.sml`,
`open.sml`, and `where.sml`. Assess those programs' language/module features in
`normal`; do not fabricate a collection, move files, or call the module behavior
covered merely because an obsolete path was requested. An explicit request for
`--suite modules` reports the actual absent collection as `SUITE-MISSING`.

Root, `fail/`, and `nonterminate/` cases are not merged or assigned a common
language profile. Repeat `--case` with an exact regression-relative path, such
as `hello-world.sml`, `fail/1.sml`, or `nonterminate/8.sml`.
`modules/records.sml` is only a path-syntax example, not an assertion about a
name in this checkout. A selected path must be discovered in a selected suite.
Other discoveries remain in stdout and the report as `NOT-SELECTED`, rather
than disappearing from counters.

The pinned corpus mixes SML '97 Core and modules, Basis behavior,
platform-dependent behavior, FFI/threads, proprietary MLton extensions, and
annotations. The upstream normal-case MLB supplies standard Basis, MLton and
SML/NJ compatibility material, and MLton annotations. This optional runner does
not relabel everything SML '97, copy upstream platform/name exclusions, or
silently discard unsupported filenames. There is no invented `.types` prelude.
The worker passes the selected source itself to OOPArts and uses a fresh
`make-initial-basis`; requisite language and library support must therefore be
recorded honestly in the assessment.

### Retained warning directory is not an executable conformance suite

The pinned checkout also retains exactly four direct-child sources in
`regression/warn/`: `warning.sml`, `undetermined.sml`,
`val-rec-constructor.sml`, and `val-rec-constructor.2.sml`. That directory has
no warning README/metadata, diagnostic golden, `.ok`, or `.nonterm` sidecar.
It is **not a supported executable conformance suite** for this runner, is not
selected by `--suite all`, and is not included in the 406-file inventory count.
This classification does not pretend that the sources are absent or that their
compile-time diagnostics are unimportant.

Their retained contents require different observations from ordinary execution:

- `warning.sml` explicitly says that the initial top-level `val x::l = []`
  should not warn according to page 28 of the Definition, while its local
  counterpart should. Its later nonexhaustive/redundant matches and redundant
  handler patterns are compile-time warning subjects. Several would raise
  `Bind` or `Match` if evaluated, so runtime bytes cannot substitute for the
  required warning/non-warning observations.
- `undetermined.sml` contains comment-numbered uses of polymorphic identity,
  `ref nil`, and later constraints. These concern implementation treatment of
  undetermined/defaulted types, not an output-byte oracle supplied by the
  corpus.
- The two `val-rec-constructor` files use `NONE` or `SOME`, rather than a plain
  variable, on the left of `val rec`. They cannot silently be classified as
  ordinary valid SML '97 `val rec` examples. However, their directory and
  filenames do not specify whether a particular implementation must reject
  them, accept an extension, or issue a particular warning; no such diagnostic
  is invented here.

A compile-time warning, including a source-comment requirement to warn or not
to warn, is distinct from the deliberate SML '97 syntax/elaboration rejection
required for a `fail/` pass. The retained data supplies no safe automatic
warning category, cardinality, or exact-text oracle for these four files.
Consequently the runner neither executes them as warning passes nor adds a
`warn` selector that accepts every outcome. Supporting them would require a
separately reviewed diagnostic policy and, where applicable, an explicit SML
'97 rejection versus implementation-extension classification.

## Assessment contract

Execution requires at least one `--assessments` file. Each file contains one
UTF-8 Common Lisp data form; `*read-eval*` is false while reading it. Multiple
assessment files may be supplied, but a path may be assessed only once. Files
may be supersets of the current suite selection. Unknown or duplicate keys and
missing required fields are errors rather than silently weakening the contract.

Illustrative format (the values are deliberately only syntax examples, **not**
an assessment supplied by this repository):

```lisp
(:assessment-version 1
 :description "Reviewed for one explicitly declared target."
 :cases
 ((:path "hello-world.sml"
   :language ("SML '97 Core")
   :basis ("OOPArts initial Basis print/1")
   :target ("linux" "arm64")
   :extensions ("MLton batch EOF after a complete declaration")
   :allow-omitted-final-semicolon t
   :applicable t
   :supported t
   :notes "Review every required construct before using this entry.")))
```

Every case entry requires:

- `:path`: the exact inventory path;
- `:language`: a nonempty list of strings identifying the language grammar;
- `:basis`: a list of strings naming required Basis/library facilities;
- `:target`: a list of strings recording target prerequisites;
- `:extensions`: a list of strings recording required extensions/annotations;
- `:applicable`: `t` or `nil`, stating whether the behavior is applicable to the
  declared target;
- `:supported`: `t`, `nil`, or `:unknown`, stating whether every prerequisite is
  explicitly supported; and
- optionally `:notes`, a string documenting the review and limitations.

The interactive production in [Definition §8](https://smlfamily.github.io/sml97-defn.pdf)
uses `topdec; ⟨program⟩`; the runner keeps that SML '97 grammar strict by default.
An optional `:allow-omitted-final-semicolon` field accepts only `t` or `nil`;
the default is `nil`. The value `t` explicitly selects MLton's batch EOF input
convention, allows only a complete final top declaration or interactive
expression to end at the existing EOF token without its final semicolon, and
records `:mlton-batch-eof` as the case's grammar mode. This is an explicit
batch-input compatibility option—not permission to accept a truncated or
malformed construct, ignore source/type errors, or rewrite source/oracle
bytes. Ordinary cases use `:sml97-strict`.

Fail-suite entries may additionally contain `:rejection` and
`:expected-unbound-identifiers`; both default to `nil`. `:rejection` accepts
only `:syntax`, `:elaboration`, `:both`, `:representation`, or `nil`:

| Expected value | Actual rejection admitted for a fail-suite `PASS` |
|---|---|
| `nil` | `:syntax` or `:elaboration`, but not `:representation` |
| `:syntax` | `:syntax` only |
| `:elaboration` | `:elaboration` only |
| `:both` | `:syntax` or `:elaboration`, but not `:representation` |
| `:representation` | `:representation` only |

`nil` is not a wildcard. The only exception to this ordinary condition table is
the separately reviewed unbound-identifier rule below. An actual rejection of a
different category is `UNEXPECTED-REJECTION`; an ordinary successful `normal`,
`modules`, or `nonterminate` case never becomes a negative pass because these
fields are present. `:expected-unbound-identifiers` must be a proper list of
strings, each an exact, case-sensitive source identifier spelling. It may contain unqualified
names such as `"y"` or dotted long identifiers such as `"TextIO.openIn"`.
Unknown assessment keys and malformed values are configuration errors before
any worker is launched.

These are domain-review decisions, not values inferred from compiler errors or
filename patterns. The empty list is valid for Basis, target, and extension
fields when it is an explicit statement that no such prerequisite exists.
There is no repository-provided corpus feature inventory merely to make the
tool runnable.

An assessed, selected, applicable, supported case is eligible. Every other
selected case remains visible and nonpass:

| Condition | Outcome |
|---|---|
| No assessment | `UNCLASSIFIED` |
| `:applicable nil` | `NOT-APPLICABLE` |
| `:supported nil` or `:unknown` | `UNSUPPORTED` |
| Eligible in `--list` mode | `NOT-EXECUTED` |
| Discovery omitted by `--case` | `NOT-SELECTED` (not a selected failure) |

Thus an ordinary suite invocation does not silently turn all unassessed cases
into successes. With no `--case`, every discovered case is selected and every
eligible assessed case is processed under its suite's isolated-worker policy;
the remaining unclassified/unsupported cases still appear in the final nonzero
result. Use exact `--case` arguments for a small reviewed lane.

In `--execute` mode the exit status is zero only if every selected case is
`PASS`; selected skipped/nonpass observations yield 1. Configuration and corpus
guard failures yield 2. Inventory returns 0 unless configuration or guard
checks fail, and its `UNCLASSIFIED` records are not conformance results.

## Explicit execution example

The following command shows the complete execution interface. It requires an
actual reviewed assessment at the shown user-created path; this repository does
not supply that assessment and the command is not reported as having passed.

```sh
sbcl --script tools/sml/mlton.lisp \
  --execute \
  --suite normal \
  --case hello-world.sml \
  --assessments build/sml/reviewed/hello-world.sexp \
  --oracle-selector linux \
  --oracle-selector arm64 \
  --oracle-selector arm64-linux \
  --timeout 30 \
  --output-directory mlton \
  --report hello-world-report.sexp
```

The three selectors above are one **deliberate declaration** for an arm64 Linux
target. They are not autodetected and must not be copied to another target.
Supplying no selectors uses only a readable base `.ok`. There is no fallback to
every available variant. Upstream's full ordering, when all target properties
are independently known and deliberately declared, is:

1. the base `<case>.ok`;
2. `<case>.<object-representation>.ok`;
3. `<case>.<object-representation>a<alignment>.ok`;
4. `<case>.<operating-system>.ok`;
5. `<case>.<architecture>.ok`; and
6. `<case>.<architecture>-<operating-system>.ok`.

Repeat `--oracle-selector` in exactly that desired order, including the
representation and representation/alignment selectors when known. The runner
never guesses MLton's object representation or alignment from SBCL. Later
existing readable files override earlier selections. As in upstream MLton, an
override is considered only while a readable base `<case>.ok` exists; a
variant without that base is not a replacement oracle.

## Compiler, execution, and byte protocol

The child loads `ooparts/sml/compiler` through the root `ooparts.asd`, then uses
only exported compiler/Basis APIs. Source input is opened as
`(unsigned-byte 8)` and each byte is converted directly with `code-char`; it is
never decoded with the host's default UTF-8 external format or normalized.

The response separates these observable phases:

1. **Input**: bytes read, including the actual byte count on success.
2. **Parse/elaboration**: `compile-source`, with no SML evaluation and no host
   compilation.
3. **Host compilation**: macroexpand and validate the public `compiled-code`
   Curry `lambda/c`, then host `compile` its lambda expression.
4. **Execution**: invoke the generated host function with the public old dynamic
   Basis data. Normal-return-only commitment uses `compiled-static` and
   `extend-basis`, exactly the public `run-program` data contract; this split
   avoids private cache access and duplicate host compilation. No semantic tree
   interpreter is used and the returned SML value is not printed implicitly.
5. **Oracle comparison**: the parent reads both expected and actual streams as
   raw bytes.

For execution, both Common Lisp standard output and error output designate one
child-owned file stream with an explicit Latin-1 byte-compatible mapping. The
child runs with `regression/` as its working directory and inherits standard
input, like the upstream executable. Compiler/host-loader
logs go to separate worker files. The capture is a real file under
`build/sml/`, never an in-memory string with implicit transcoding. Its bytes are
retained on failure for independent inspection.

A readable base `.ok` supplies output bytes, not compiler diagnostic goldens.
Comparison is byte-for-byte from offset zero through both EOFs. There is no
trimming, whitespace folding, EOL conversion, charset recoding, diff fuzz, or
special interpretation of a missing `.ok`. After successful execution without
an oracle, the result is `NO-ORACLE`; missing never means empty expected output.

A present root sidecar (`foo.nonterm` for `foo.sml`, likewise below `modules/`)
means `compile-source` plus host compilation **without invoking generated code**.
Its oracle is not required. That existing sidecar rule is unchanged: an ordinary
case without a sidecar is always executed even if observation later finds no
oracle.

Independently of sidecars, selecting the `nonterminate` suite forces
`:compile-only t` for every case in that suite. The authority is the retained
`regression/README`, which says that this directory "contains tests that should
compile, but when run, should not terminate"; it is not an assumption inferred
from a test's output. Thus even the option named `--execute` cannot advance a
`nonterminate/` program into source evaluation. The parent forwards the forced
flag as the existing request's `:nonterm` field. After successful
`compile-source` and generated-Curry host compilation, the worker returns
`:compiled` before its only `mlton-worker-execute` call. The response therefore
retains `:execution (:status :not-attempted)`, and the parent records
`:oracle-comparison (:status :not-applicable :reason :compile-only)` rather
than requiring `.ok` bytes. A selected eligible case passes this route only if
both compilation phases succeed; a generic elaboration, host-compilation, or
worker failure remains a nonpass, and a bare `:compiled` response without the
forced/sidecar compile-only flag is not a no-run pass.

For example, this command selects the pinned one-file suite without evaluating
its source, using the ignored reviewed eligibility assessment at the shown path:

```sh
sbcl --script tools/sml/mlton.lisp \
  --execute \
  --suite nonterminate \
  --assessments build/sml/reviewed/nonterminate.sexp \
  --timeout 30 \
  --output-directory mlton-nonterminate \
  --report nonterminate-report.sexp
```

The discovered case path is `nonterminate/8.sml`; an optional `--case
nonterminate/8.sml` selects that exact path explicitly. The assessment declares
support for recursive Core datatypes/functions, constructor/tuple patterns,
`int` equality/arithmetic, and the source's complete final declaration without
a semicolon. It requires no optional library or external SML runtime. Its final
nonexhaustive `case` is not a static rejection or a warning oracle. Assessment
eligibility is not itself an observed `PASS`.

On an identified uncaught `ooparts/sml/runtime:sml-raise`, the worker renders
`unhandled exception: ` and the raised SML value into the captured program
stream, followed by LF. This is program-output behavior, not a host compiler
diagnostic. The capture is then completed and the non-Windows parent appends
the literal bytes `Nonzero exit status.\n`. No separator is inserted, so
unterminated program output joins the marker. For the intentional nonzero
`1.sml` case, the captured text is therefore:

```text
unhandled exception: Overflow
Nonzero exit status.
```

That case and `2.sml` match their exact two-line upstream oracles after this
repair. The resulting execution is still judged through its output oracle
rather than automatically passing or failing on status. Generic
host/compiler errors, a missing response, malformed response, or a bad worker
exit do not get this marker and cannot masquerade as SML nonzero execution.
Windows execution is rejected rather than silently applying non-Windows EOL
behavior.

Each case may have `--timeout SECONDS`. Expiration forcibly ends that child and
records `TIMEOUT`; it is not a source-rejection pass, normal execution, or an
empty expected output. No resource-exhaustion shortcut is an expected failure.

### Fail cases are deliberately different

The `fail` suite stops after parse/elaboration, analogous to upstream
`mlton -stop tc`; it does not host-compile or run an accepted source and has no
golden diagnostic sidecars. A `PASS` requires all of the following:

- an exact assessment declaring the case applicable and all required syntax,
  Basis facilities, target behavior, and extensions supported;
- no timeout, bad worker exit, input error, or generic host/internal error; and
- an actual normalized category matching the optional `:rejection` assessment,
  or the exact intentional-unbound exception described below.

The worker retains the raw terminal outcome, condition type, and condition
message in the existing phases. Its parse/elaboration details also record the
normalized `:rejection-category` and, for `sml-elaboration-error`, its actual
`:elaboration-kind`. The categories are based on the condition hierarchy, not
on diagnostic text:

- `:syntax` means an `sml-source-error`, including its lexical and grammar
  subclasses;
- `:elaboration` means deliberate static rejection by an `sml-type-error`,
  including an ordinary `sml-elaboration-error`; and
- `:representation` means specifically an `sml-elaboration-error` whose kind is
  `:range`, checked before its `sml-type-error` superclass.

There is one crucial elaboration-condition exception: the compiler emits
`sml-elaboration-error` for a zero-answer fallback as well as for deliberate
static rejection. The exact messages `SML elaboration did not produce a
well-typed program.` and the older `Core elaboration did not produce a
well-typed program.` identify an unresolved/internal/unsupported compiler
outcome, not proof that the source violates SML. The worker removes only the
condition's documented source-name report suffix before comparing those exact
messages. It reports `COMPILER-ERROR` with `:failure-kind
:unresolved-elaboration`, never an `:elaboration` pass. This neither accepts a
valid program nor converts missing module support into a valid negative case.

Consequently, generic parser errors, host numeric errors, unsupported features,
internal crashes, and unrelated static errors cannot be relabeled as a literal
range pass. Fixed-width, floating-point, and Unicode prerequisites may make a
literal-representability case inapplicable or unsupported; it must then remain
`NOT-APPLICABLE` or `UNSUPPORTED`. If no deliberate range condition is
implemented, an earlier grammar/generic elaboration error is a nonpass, not a
`:representation` success.

An accepted negative source is `UNEXPECTED-ACCEPTANCE`. A wrong-kind rejection
is `UNEXPECTED-REJECTION`; this includes a `:representation` result when the
expectation is `nil` or `:both`. Source rejection in `normal`, `modules`, or
`nonterminate` is also `UNEXPECTED-REJECTION`, never a pass, and its respective
accepted-program execution or compile-only flow is unchanged.

`unbound-identifier-error` ordinarily remains `MISSING-PREREQUISITE`. The worker
preserves that terminal outcome and normalizes its native path components,
public syntax identifier, or dotted spelling to one exact source spelling with
`.` separators. The same rule applies to the elaborator's actual formatted
`Unbound value identifier`, `Unbound type constructor`, `Unbound structure
identifier`, `Unbound signature identifier`, and `Unbound functor` diagnostics.
Their source-name suffix and final punctuation are removed according to the
actual formatter; no arbitrary occurrence of the word "unbound" is treated
as a name. An unbound diagnostic whose exact name cannot be established is
`UNKNOWN-PREREQUISITE`, with `:failure-kind :unresolved-unbound-diagnostic`,
rather than a guessed name or generic elaboration pass.

Only when **all** of the following hold may the parent change a named
missing-prerequisite observation into a fail-case `PASS`:

1. the case is selected, applicable, and supported in the `fail` suite;
2. its expected rejection is `nil`, `:elaboration`, or `:both` (not `:syntax`
   or `:representation`);
3. the frontend detail is the elaboration category and supplies an actual
   unbound source identifier; and
4. that exact spelling is a `string=` member of the case's explicit
   `:expected-unbound-identifiers` list.

There is no substring, case-folding, final-component-only, or arbitrary prefix
match. An absent or empty list accepts no unbound identifier. For example,
`fail/1.sml` intentionally refers to `y` inside functor `F` before the later
outer `val y = 13`; a domain-reviewed assessment may list `("y")` to document
that deliberate bad source reference. The same list must not admit an unrelated
missing name. Required standard-library or module names such as an unavailable
`TextIO` operation remain `MISSING-PREREQUISITE` and never pass merely because
some other unbound name was reviewed. A static type mismatch remains an
ordinary `:elaboration` condition, distinct from the intentional-unbound rule.

These checks deliberately do not reproduce the upstream wrapper's generic
nonzero-compiler acceptance, whitelist masking, or aggregate exit-status bug.

## Per-case report

The UTF-8 Lisp-data report contains the immutable revision/tree identifiers,
corpus/child-Lisp and selection configuration, the complete discovered-case
list, actual phase/worker data,
oracle and generated-artifact paths where applicable, and separate summary,
outcome, and classification counts (the latter include nonselected discoveries).
`PASS` is only written after successful required compilation,
nonzero-SML/oracle handling, and strict comparison, or after a properly
classified deliberate fail-suite rejection or compile-only host compilation.
There are no placeholder pass fields or invented coverage results.

Other explicit outcomes include `COMPILER-ERROR`, `UNKNOWN-PREREQUISITE`,
`HOST-COMPILATION-ERROR`, `EXECUTION-ERROR`, `UNEXPECTED-REJECTION`, `MISMATCH`, `ORACLE-ERROR`,
`INPUT-ERROR`, `OUTPUT-ERROR`, `NO-ORACLE`, `WORKER-ERROR`, and `TIMEOUT`.
These counters are additive with skipped/unclassified outcomes and never hide
individual entries.

To inventory without exercising backend code, use `--list`. Backend-dependent
execution requires a stable `ooparts/sml/compiler`; this tool's implementation
and --help/inventory path are not evidence that any semantic regression case
has compiled, run, or matched an oracle.
