# Advice

`ooparts/advice` provides global function advice with an API modeled on modern
Emacs advice. It has no external Lisp dependencies. **SBCL 2.6.6 or later** and
CCL use native encapsulation; ECL, MKCL, ABCL, CLISP, Clasp and CMUCL use revocable
function-definition wrappers. Loading the library also enables compilation
instrumentation and runtime repairs described below.

```lisp
(asdf:load-system "ooparts/advice") ; load before compiling application functions

(defun calculate (x) (values (+ x 1) :secondary))

(ooparts/advice:define-advice calculate (:around (next x) double-result)
  (multiple-value-bind (value secondary) (funcall next x)
    (values (* 2 value) secondary)))

(calculate 10) ; => 22, :SECONDARY
(funcall (fdefinition 'calculate) 10) ; => 22, :SECONDARY

(ooparts/advice:advice-remove 'calculate 'double-result)
(calculate 10) ; => 11, :SECONDARY
```

## Interface

```lisp
(advice-add function-name where function &optional properties)
(advice-remove function-name function-or-name)
(advice-member-p function-or-name function-name)
(advice-mapc function function-name)
(define-advice function-name
    (where lambda-list &optional name depth)
  body...)
(advice-status function-name)              ; :ACTIVE, :PENDING, or NIL
(reconcile-definitions &optional function-name)
(prepare-advice-function function-name)
(enable-advice-compilation)
(disable-advice-compilation)
```

All names are exported from `ooparts/advice`. Targets are global function names:
a symbol or `(setf symbol)`. Macros, special operators and lexical functions
cannot be advised. An undefined name can have **pending advice** without becoming
FBOUNDP. Defining it later activates its registered advice. FMAKUNBOUND returns
it to pending; it does not erase the registration. Membership reports registered
advice, while `advice-status` explicitly distinguishes active and pending states.
Advice functions can be function objects or function-name symbols; symbols are
resolved when called.

`properties` is a Common Lisp **plist**, rather than an Emacs alist:

```lisp
(ooparts/advice:advice-add 'calculate :before #'log-arguments
                         '(:name logging :depth -10))
```

`:name` is a non-NIL symbol or string. Adding the same name replaces that advice.
Without a name, adding the same function replaces its previous occurrences.
Depth defaults to zero and can be any real number. Lower depths are outermost;
at equal depth the most recently added advice is outermost. AFTER advice runs
after the inner chain, so its execution order is the reverse of its nesting.

`advice-remove` removes all matching names or functions and returns NIL, as does
`advice-add`. `advice-member-p` returns a boolean. `advice-mapc` calls its function
with two arguments, the advice designator and a copied properties plist, in
outermost-first order. It uses a snapshot and releases the registry lock before
calling user code, so the callback can change advice safely.

Named `define-advice` forms define `TARGET@NAME` in the caller's current package,
install that symbol as the advice designator, and return the generated symbol.
Reloading the form updates the named advice. Anonymous forms install a closure
and return NIL. For SETF targets, the generated symbol is `(SETF TARGET)@NAME`.

## Combinators and multiple values

| Position | Behavior |
|---|---|
| `:before` | Run advice with the arguments, discard its values, then call the inner function. |
| `:after` | Call the inner function, then run advice with the original arguments on normal return; preserve all inner values. |
| `:around` | Call advice with a callable `next` followed by the arguments. Advice controls calling `next` and returning values. |
| `:override` | Call only advice with the arguments. |
| `:filter-args` | Give advice the argument list as one argument; apply the inner function to the returned list. |
| `:filter-return` | Give advice the inner function's primary value as one argument; return all advice values. |
| `:before-while` | Call the inner function only when the advice's primary value is true. |
| `:before-until` | Call the inner function only when the advice's primary value is false. |
| `:after-while` | Call advice only when the inner function's primary value is true. |
| `:after-until` | Call advice only when the inner function's primary value is false. |

Short-circuit positions preserve every value from the selected result. Zero
values count as a false primary value. FILTER-RETURN intentionally transforms
one primary value: secondary inner values are discarded, and secondary advice
values become the result. AFTER does not run during a non-local exit; use
AROUND with `unwind-protect` for cleanup. The callable NEXT captures its inner
chain and base function and can be retained after AROUND returns. This is a
snapshot of that call's continuation, distinct from a revocable dispatcher.

## Definition consistency and dispatcher lifetime

Each installed dispatcher has its own revocation token. Replacing a definition
revokes the old installation before attaching a fresh one. Removing the last
advice clears the chain and revokes its installation even when TRACE or another
wrapper prevents physical removal. A saved dispatcher consequently calls its
base without the deleted advice; adding new advice does not reactivate that
old dispatcher. The portable backend retains the actual installed FDEFINITION
value for its identity guard, including on CMUCL.

The enabled compilation mode notifies the registry after DEFUN, definition
SETF forms, FMAKUNBOUND and TRACE/UNTRACE. Dynamic resolution, `advice-status`,
membership and MAPC also reconcile registrations against actual definitions.
`reconcile-definitions` repairs one name, or all registered names with no
argument. Use it after changes performed by foreign loaders or old compiled
setters that bypass these notifications. Advice cannot observe every arbitrary
host mutation immediately; the registry is repaired at these defined boundaries.

The registry serializes additions, removals and reconciliation using
`ooparts/host`. Running calls hold no registry lock and use the chain they
obtained on entry. Arbitrary simultaneous redefinition races are not covered.

## Native backends and runtime repairs

| Runtime | Installation and runtime support |
|---|---|
| SBCL 2.6.6+ | `sb-int:encapsulate` / `unencapsulate`, with a separate native marker for each installation. Ordinary native global lookup survives redefinition and composes with TRACE. |
| CCL 1.13 | Native `ccl::advise-2` / `%unadvise-1` around advice, using an inner function binding and an OOPArts marker. Native generic-function identity and DEFMETHOD are preserved. Enabled compilation mode sets `*loading-removes-encapsulation*` to NIL globally until disabled, so loading replacement FASLs retains encapsulation. |
| ECL, CLISP, Clasp, CMUCL | Revocable FDEFINITION wrapper; managed FDEFINITION getter reconciles stale installations before returning a function. |
| MKCL | The portable wrapper and getter, plus `si::update-function-references` for discoverable user-named compiled functions after registry changes. This repairs reference caches, not generated direct C calls or undiscoverable anonymous callers. |
| ABCL | The portable wrapper and getter, `sys::*fset-hooks*` definition notifications, and an in-memory wrapper around `pre::precompile-function-call` to redirect global calls before ABCL expands inline/self calls. Lexical FLET/LABELS entries and application compiler macros are preserved. |

These host interfaces are internal and version-dependent. No upstream source
files or machine instructions are modified. On portable hosts the global
CL:FDEFINITION function binding is temporarily replaced; compiler macros cover
future FDEFINITION and FMAKUNBOUND calls, including host primitives that bypass
that function binding. Disabling compilation mode restores the bindings and
hooks still owned by this module, preserving subsequent application replacements.

## Compiling application code

Compilation mode is **enabled by default**. Load `ooparts/advice` before compiling
application definitions. Its macroexpansion hook prepares application DEFUN names
before their bodies are compiled. A per-name compiler macro redirects global
calls to a dynamic resolver. Definition FASLs restore this preparation when
loaded. The same indirection covers ordinary calls, high-speed calls, INLINE
requests and self-recursion at default/fast/INLINE policies in the measured
fixtures, without NOTINLINE. MKCL debug-3 recursion remains an exception.

This changes optimization: prepared calls intentionally retain dynamic lookup
instead of expanding inline or becoming direct self calls. Each such call
performs registry lookup and locking, even if that function currently has no
advice. The library does not automatically inline or specialize this resolver.
No performance or debugger-stack equivalence is claimed. Runtime/system and OOPArts
implementation packages (`OOPARTS/…`), together with unrelated OOPArts test
packages, are excluded, and existing application compiler macros
are not replaced. Local FLET/LABELS bindings retain their lexical behavior.
Configure these process-wide hooks before concurrent application compilation.
Application systems that produce instrumented FASLs must declare their ASDF
dependency on `ooparts/advice`; the hook does not add dependencies to arbitrary
third-party system definitions.

```lisp
(ooparts/advice:disable-advice-compilation) ; restore owned hooks for future code
(ooparts/advice:enable-advice-compilation)  ; enable again
(ooparts/advice:prepare-advice-function 'existing-function)
```

`prepare-advice-function` prepares future calls to an existing name. It cannot
rewrite a caller already compiled to inline code or a direct entry point.
Disabling removes owned compiler macros and runtime patches; already
instrumented functions/FASLs still call the resolver and require this library.
Re-enabling does not retrospectively prepare all definitions compiled while the
mode was disabled; prepare those names explicitly or recompile their DEFUNs.

## Limits that remain

| Situation | Behavior / required action |
|---|---|
| Code compiled before library loading | Native global calls often work; ECL's measured ordinary same-file caller still bypasses advice, as does MKCL's fast direct caller. Recompile these callers with compilation mode enabled. The audit separates these fixtures from instrumented fixtures. |
| Already expanded inline or block-local code | Old instructions are not rewritten. Future instrumentation prevents those expansions for prepared calls; it cannot retroactively intercept their old copies. |
| Immediate `(funcall #'name ...)` | Some MKCL, ABCL and CMUCL policies still compile function literals that bypass advice. Ordinary prepared named calls and dynamic FDEFINITION getters agree in those same fixtures. |
| MKCL debug-3 self-recursion | Still enters advice only once in the measured n=3 fixture; default/fast/INLINE instrumented recursion enters four times. |
| Application compiler macro or excluded package | Its existing expansion can bypass the resolver. The library preserves that expansion; no universal interception guarantee is made. |
| Ordinary function object genuinely captured before advice | Remains the old object on every measured host. A compiler-rewritten local `#'name` binding may behave differently. Redefining a global name does not mutate arbitrary retained function objects. |
| Saved dispatcher after redefinition | Old installations are revoked; portable saved wrappers retain their own captured base. Native wrappers can follow a host-managed underlying binding. Consult the object/redefinition rows for exact differences. |
| Saved generic-function object | Native SBCL and CCL preserve identity and advise the generic dispatcher. Portable hosts replace the global binding with an ordinary closure, so an old generic object bypasses advice. |
| DEFMETHOD while portably advised | Still fails because the binding is an ordinary closure. Remove advice, add methods, then reinstall, or use a native backend. |
| Copying an advised definition to another name | Native setters and portable closures differ. Copying a function definition does not copy its advice registration. |
| Metadata, aliases, exotic FTYPE/ABI changes, locked application packages, arbitrary FFI entries, saved images | No uniform guarantee. The audit records documentation and alias differences, but does not establish these other cases. |
| MAPC nested property objects | Only the outer plist is copied; nested mutable objects remain shared. |
| Foreign definition/TRACE implementations | Reconcile explicitly if they bypass notifications. Wrapper nesting and trace output/stack presentation remain host-dependent. |

The old behavior matrix remains available at
[the initial audit commit](https://github.com/tani/ooparts/blob/bd58e13434bbb95c530e7516cd21ae7148ef71f9/docs/advice/README.md).
The tables below replace it with current measurements. The principal changes
are reattachment after redefinition/unbinding, inactive saved dispatchers after
removal, TRACE coexistence, native CCL generic functions, and dynamically
resolved future compiled calls. These fixes do not imply equality of arbitrary
old machine code or preexisting function-object identity.

## Validation and reproduction

```sh
sbcl --script tools/test.lisp advice
nix run .#test-advice-sbcl
python3 tools/check-layout.py

# One host; compile the preexisting fixtures before loading the library.
nix develop .#sbcl --command python3 tools/advice/audit.py \
  --implementation sbcl --output-dir build/advice/audit-sbcl

# Eight hosts. GNU11 bootstrap affects MKCL only.
nix develop --command python3 tools/advice/audit.py \
  --implementation sbcl ccl ecl mkcl abcl clisp clasp cmucl \
  --bootstrap tools/advice/mkcl-gnu11.lisp \
  --output-dir build/advice/audit
python3 tools/advice/report.py build/advice/audit/results.json --update-readme
```

The regression suite covers combinators, multiple/zero values, ordering,
mutation, SETF names, pending/active transitions, saved dispatcher revocation,
TRACE in both installation orders, lexical shadowing and compiler-hook lifetime.
The behavior audit records differences and normalized errors rather than treating
every difference as a regression. Its runner checks completion and duplicate
records. The report generator checks source hashes and lists every probe once.

The current host required QEMU i386 for CMUCL. Select executables or wrappers
with `--runtime-map map.json` and label emulation with `--emulated cmucl`.
The wrapper runs `qemu-i386 /absolute/path/to/cmucl/bin/lisp "$@"`.
All caches, generated sources/FASLs, logs, JSON and standalone Markdown reports
stay under ignored `build/`. Avoid running two audits/test processes for the same
implementation against the same ASDF cache concurrently.

## References and evidence

- [Emacs named-function advice](https://www.gnu.org/software/emacs/manual/html_node/elisp/Advising-Named-Functions.html)
  and [combinators](https://www.gnu.org/software/emacs/manual/html_node/elisp/Advice-Combinators.html)
  define the API reference; no Emacs source is included.
- [SBCL release notes](https://www.sbcl.org/all-news.html) and
  [block compilation](https://www.sbcl.org/manual/index.html#Block-Compilation-Semantics).
- [CCL native encapsulation implementation](https://github.com/Clozure/ccl/blob/v1.13/lib/encapsulate.lisp).
- [ABCL precompiler](https://github.com/armedbear/abcl/blob/fc3d78e55a5b338536286b5ef3bc3a041ba174f7/src/org/armedbear/lisp/precompiler.lisp)
  and [lexical environment](https://github.com/armedbear/abcl/blob/fc3d78e55a5b338536286b5ef3bc3a041ba174f7/src/org/armedbear/lisp/Environment.java).
- [CLHS compilation constraints](https://www.lispworks.com/documentation/HyperSpec/Body/03_bbc.htm).
- Implementation: [core](../../src/advice/core.lisp), [backend](../../src/advice/backend.lisp),
  [compilation](../../src/advice/compilation.lisp),
  [executable observations](../../tests/advice/behavior.lisp),
  [preexisting-code fixtures](../../tools/advice/preexisting.lisp).

The evidence is source review plus executable probes on the pinned builds below.
It does not establish arbitrary programs, architectures or compiler policies.
All ordinary call tests use compatible argument/return contracts; changing a
declared FTYPE contract would be a different experiment.

## Differences from modern Emacs advice

The Emacs column follows the upstream manual and source, not a ninth runtime
executed by this audit.

| Item | `ooparts/advice` | Modern Emacs named-function advice |
|---|---|---|
| Named API | Five principal names/argument order; additional status and compilation controls | Five principal names |
| Combinators | The ten positions above | Same ten combinations |
| Properties | Common Lisp plist with `:name`, `:depth` | Alist with `name`, `depth` |
| Ordering | Lower depth outside; newest outside at equal depth | Same convention |
| Named replacement | Matching name; unnamed replacement by supplied function designator | Same principal convention |
| Values | Common Lisp multiple values, including zero | One ordinary result value |
| FILTER-RETURN | Primary inner value in; all advice values out | Single inner value in/out |
| NEXT | Callable and retainable snapshot of the inner chain | Callable inner function |
| Targets | Global symbol or `(setf symbol)` | Named symbol, including alias/macro/autoload handling |
| Undefined targets | Pending registration without making FBOUNDP true | Deferred named advice |
| Macro targets | Rejected | Supported for future macro expansions |
| Special operators/forms | Rejected | Rejected |
| `add-function` / `remove-function` | Not provided | Separate generalized-place API |
| Interactive metadata | Not provided | Integrated with commands |
| Documentation | Host-dependent preservation | Integrated advice descriptions |
| Definition changes | Native backends, notifications and reconciliation; foreign changes may need explicit repair | Integrated with definition changes/autoloads |
| `define-advice` name | `TARGET@NAME` in macro caller's package, including SETF names | `SYMBOL@NAME` |
| MAPC | Boolean membership, snapshot, copied outer plist | Non-NIL membership, alist properties |

<!-- BEGIN ADVICE BEHAVIOR AUDIT -->
## Recorded behavior comparison

Audited on 2026-11-04, with Nixpkgs commit `0bb2eedc20e4739f29e8045034f2828ad7054f8f` on Linux. These are measurements of the current OOPArts backends, not of each host's native advice facility.

**231 comparison rows, 1788 observations across eight runtimes:** 199 rows have identical outcomes; 32 rows differ or include an unavailable control. N/A denotes a missing or explicitly unsupported control.

| Runtime | Version | Instrumented same-file call | DEFUN retains advice | Last removal restores base | Generic identity retained |
|---|---|---|---|---|---|
| SBCL | 2.6.8 | Advice | Yes | Yes | Yes |
| CCL | Version 1.13 LinuxX8664 | Advice | Yes | Yes | Yes |
| ECL | 26.5.5 | Advice | Yes | Yes | No |
| MKCL | 1.1.11* | Advice | Yes | Yes | No |
| ABCL | 1.9.3 | Advice | Yes | Yes | No |
| CLISP | 2.49.95+ (2024-11-03) (built on localhost [127.0.0.1]) | Advice | Yes | Yes | No |
| Clasp | clasp-boehmprecise-3.0.1-non-cst | Advice | Yes | Yes | No |
| CMUCL | 21d (21D Unicode) / emulated* | Advice | Yes | Yes | No |

Calls compiled **before** the library was loaded (separate fixtures):

| Runtime | Existing default caller | Existing fast caller | Existing INLINE caller | Existing default FDEFINITION getter |
|---|---|---|---|---|
| SBCL | Advice | Advice | Bypass | Advice |
| CCL | Advice | Advice | Bypass | Advice |
| ECL | Bypass | Bypass | Bypass | Advice |
| MKCL | Advice | Bypass | Bypass | Advice |
| ABCL | Advice | Advice | Bypass | Advice |
| CLISP | Advice | Advice | Advice | Advice |
| Clasp | Advice | Advice | Advice | Advice |
| CMUCL | Advice | Advice | Bypass | Advice |

* Bootstrap: `mkcl-gnu11.lisp`.
* Emulated runtimes: CMUCL.
* MKCL used GNU11 mode because the locked package's default C compiler mode rejected its generated calls. The GNU11 bootstrap itself does not patch Lisp lookup; the library separately repairs cached references and instruments future calls. CMUCL used QEMU i386 because this execution host cannot run the package's 32-bit ELF directly; CMUCL emitted a personality-setting warning. Native i386 was not measured.
* CLISP reports an older source date in `lisp-implementation-version`; the Nix package is `2.49.95-unstable-2024-12-28`. Full runtime-reported versions are in the JSON report.

### How to read the complete tables

- Each cell is the printed `multiple-value-list` of a probe. `NIL` means **zero values**; `(NIL)` means one NIL value. Errors are normalized to `UNDEFINED-FUNCTION`, `TYPE-ERROR`, `PROGRAM-ERROR`, or other `ERROR`, not exact implementation-specific subclasses or messages.
- Ordinary base: argument 10 returns `(11 :SECONDARY)`; one doubling advice returns `(22 :SECONDARY)`; two return `(44 :SECONDARY)`. Replacement base returns `(12 :SECONDARY)`, or `(24 :SECONDARY)` when still advised.
- `combinator.*` probes return two values: the result-value list and the event sequence. Mutation and TRACE probes likewise return before/after values. IDs map directly to `tests/advice/behavior.lisp`.
- Shared rows are listed once under **Same on all eight**. Every other row includes all eight columns. Both types are observations, not proofs that every optimization or platform behaves the same.
- `preexisting.*` fixtures are compiled before library loading with original compiler behavior. All `compile.*` fixtures are compiled with the library's compilation mode enabled, before or after adding advice as indicated. They measure instrumented calls, not unchanged host compilation.
- `default` uses fresh host defaults. Other policies first set speed/space/safety/debug/compilation-speed to 1, then apply their named changes: `fast` = speed 3, safety 1, debug 0; `debug3` = debug 3; `speed0` = speed 0; `inline` = fast + INLINE target; `notinline` = NOTINLINE target/self/mutual entry; `block` = host `:block-compile t` on SBCL/CMUCL.
- Same-file and separate-file callers are compiled before advice. `compiled-after-add` is a new separate caller compiled while advice is present. `reloaded-caller-fasl` reloads the separate caller's FASL after advice is present. Recursion probes call n=3: full interception gives 4 self calls or 2 calls to the observed mutual-recursion entry.
- `local-saved-function` evaluates `(let ((saved #'target)) (funcall installer) (funcall saved x))`; the installer adds advice. `local-saved-fdefinition` uses FDEFINITION instead. These deliberately distinguish compiler rewriting from an actual object captured through an opaque boundary.
- Prepared calls are redirected before INLINE/self-call expansion. Their advised INLINE results therefore do not mean that old expanded instructions were patched. In preexisting fixtures INLINE requests may also be ignored. Same-file redefinition controls explore behavior beyond portable ANSI assumptions.

### Composition, values, arguments and control flow

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `combinator.before` | `((11 :SECONDARY) (:ADVICE :BASE))` |
| `combinator.after` | `((11 :SECONDARY) (:BASE :ADVICE))` |
| `combinator.around` | `((21 :SECONDARY) (:ADVICE :BASE))` |
| `combinator.override` | `((T :ADVICE) (:ADVICE))` |
| `combinator.filter-args` | `((21 :SECONDARY) (:ADVICE :BASE))` |
| `combinator.filter-return` | `((22 :FILTERED) (:BASE :ADVICE))` |
| `combinator.before-while` | `((11 :SECONDARY) (:ADVICE :BASE))` |
| `combinator.before-until` | `((T :ADVICE) (:ADVICE))` |
| `combinator.after-while` | `((T :ADVICE) (:BASE :ADVICE))` |
| `combinator.after-until` | `((11 :SECONDARY) (:BASE))` |
| `short-circuit.before-while.false` | `(NIL :ADVICE)` |
| `short-circuit.before-while.zero` | `NIL` |
| `short-circuit.before-until.false` | `(NIL :BASE)` |
| `short-circuit.before-until.zero` | `NIL` |
| `short-circuit.after-while.false` | `(NIL :BASE)` |
| `short-circuit.after-while.zero` | `NIL` |
| `short-circuit.after-until.false` | `(NIL :ADVICE)` |
| `short-circuit.after-until.zero` | `NIL` |
| `zero-values.before` | `NIL` |
| `zero-values.after` | `NIL` |
| `zero-values.around` | `NIL` |
| `zero-values.override` | `NIL` |
| `zero-values.filter-args` | `NIL` |
| `zero-values.filter-return` | `(NIL :FILTERED)` |
| `arguments.optional-rest-key` | `(1 3 (:KEY 4))` |
| `arguments.keyword-defaults` | `(2)` |
| `arguments.wrong-arity` | `error: PROGRAM-ERROR` |
| `filter-args.improper-list` | `error: TYPE-ERROR` |
| `around.skip-next` | `(99 :SKIP)` |
| `around.next-twice` | `(21 2)` |
| `around.escaped-next-after-return` | `(21 :SECONDARY)` |
| `around.escaped-next-after-remove` | `(21 :SECONDARY)` |
| `nonlocal.after-skipped-on-throw` | `(:THROWN NIL)` |
| `nonlocal.after-skipped-on-error` | `(NIL)` |
| `nonlocal.around-unwind-protect` | `(:THROWN T)` |
| `nonlocal.advice-error-skips-base` | `(NIL)` |

### Registry, ordering and mutation

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `registry.add-remove-return-values` | `((NIL NIL NIL))` |
| `registry.depth-and-ties` | `((:OUTER :NEWEST :MIDDLE :INNER))` |
| `registry.after-reverses-nesting` | `((:BASE :OLD :NEW))` |
| `registry.replace-name-and-depth` | `((:TWO :ONE))` |
| `registry.replace-unnamed-function` | `((NIL))` |
| `registry.function-and-symbol-distinct` | `(2)` |
| `registry.same-function-multiple-names` | `((:B :A) NIL)` |
| `registry.equal-string-names` | `(1 T)` |
| `registry.symbol-name-package-identity` | `(T NIL)` |
| `registry.nil-name-is-anonymous` | `(NIL T)` |
| `registry.mapc-snapshot-and-removal` | `((:B :A) NIL)` |
| `registry.mapc-properties-copy` | `((:ORIGINAL))` |
| `registry.mapc-shallow-copy` | `((:CHANGED))` |
| `registry.update-during-active-call` | `((:BASE) (:NEW :BASE))` |
| `registry.remove-during-active-call` | `((:INNER :BASE) (:BASE))` |
| `designator.symbol-follows-redefinition` | `(22 :SECONDARY)` |
| `designator.object-keeps-old-definition` | `(11 :SECONDARY)` |
| `designator.symbol-fmakunbound` | `error: UNDEFINED-FUNCTION` |

### Function objects, identity and aliases

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `object.saved-fdefinition-before-add` | `(11 :SECONDARY)` |
| `object.saved-function-before-add` | `(11 :SECONDARY)` |
| `object.late-fdefinition` | `(22 :SECONDARY)` |
| `object.late-symbol-function` | `(22 :SECONDARY)` |
| `object.late-function` | `(22 :SECONDARY)` |
| `object.runtime-symbol-designator` | `(22 :SECONDARY)` |
| `object.identity-before-vs-after-add` | `(NIL)` |
| `object.identity-fdefinition-vs-symbol-function` | `(T)` |
| `object.saved-wrapper-sees-addition` | `(44 :SECONDARY)` |
| `object.saved-wrapper-sees-partial-removal` | `(22 :SECONDARY)` |
| `object.current-after-last-removal` | `(11 :SECONDARY)` |
| `object.saved-wrapper-after-last-removal` | `(11 :SECONDARY)` |
| `object.saved-wrapper-after-readd` | `(11 :SECONDARY)` |
| `object.current-after-readd` | `(99)` |
| `object.alias-bound-before-add` | `(11 :SECONDARY)` |
| `object.wrapper-after-gc` | `(22 :SECONDARY)` |
| `object.escaped-next-after-base-redefinition` | `(11 :SECONDARY)` |
| `object.assign-definition-to-itself` | `(22 :SECONDARY)` |
| `object.function-assignment-identity` | `(T)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `object.alias-bound-after-add` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `object.saved-wrapper-after-base-redefinition` | `(24 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` |

### Redefinition and unbinding

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `redefinition.defun.current` | `(24 :SECONDARY)` |
| `redefinition.defun.member` | `(T)` |
| `redefinition.defun.add-again` | `(24 :SECONDARY)` |
| `redefinition.defun.after-remove` | `(12 :SECONDARY)` |
| `redefinition.compile.current` | `(24 :SECONDARY)` |
| `redefinition.compile.member` | `(T)` |
| `redefinition.compile.add-again` | `(24 :SECONDARY)` |
| `redefinition.compile.after-remove` | `(12 :SECONDARY)` |
| `redefinition.fdefinition.current` | `(24 :SECONDARY)` |
| `redefinition.fdefinition.member` | `(T)` |
| `redefinition.fdefinition.add-again` | `(24 :SECONDARY)` |
| `redefinition.fdefinition.after-remove` | `(12 :SECONDARY)` |
| `redefinition.symbol-function.current` | `(24 :SECONDARY)` |
| `redefinition.symbol-function.member` | `(T)` |
| `redefinition.symbol-function.add-again` | `(24 :SECONDARY)` |
| `redefinition.symbol-function.after-remove` | `(12 :SECONDARY)` |
| `redefinition.fasl.current` | `(24 :SECONDARY)` |
| `redefinition.fasl.member` | `(T)` |
| `redefinition.fasl.add-again` | `(24 :SECONDARY)` |
| `redefinition.fasl.after-remove` | `(12 :SECONDARY)` |
| `redefinition.fmakunbound-boundp` | `(NIL)` |
| `redefinition.fmakunbound-member` | `(T)` |
| `redefinition.fmakunbound-add` | `(NIL)` |
| `redefinition.fmakunbound-then-define` | `(24 :SECONDARY)` |

### Documentation metadata

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `metadata.documentation` | `("Base documentation.")` | `(NIL)` | `(NIL)` | `("Base documentation.")` | `("Base documentation.")` | `(NIL)` | `(NIL)` | `("Base documentation.")` |
| `metadata.documentation-after-remove` | `("Base documentation.")` | `("Base documentation.")` | `(NIL)` | `("Base documentation.")` | `("Base documentation.")` | `("Base documentation.")` | `("Base documentation.")` | `("Base documentation.")` |

### Generic functions and methods

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `generic.current` | `(22 :SECONDARY)` |
| `generic.current-after-remove` | `(11 :SECONDARY)` |
| `generic.saved-before-after-remove` | `(11 :SECONDARY)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `generic.saved-before-add` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` |
| `generic.identity-preserved` | `(T)` | `(T)` | `(NIL)` | `(NIL)` | `(NIL)` | `(NIL)` | `(NIL)` | `(NIL)` |
| `generic.still-generic-function` | `(T)` | `(T)` | `(NIL)` | `(NIL)` | `(NIL)` | `(NIL)` | `(NIL)` | `(NIL)` |
| `generic.add-method-while-advised` | `(6)` | `(6)` | `error: PROGRAM-ERROR` | `error: PROGRAM-ERROR` | `error: ERROR` | `error: ERROR` | `error: PROGRAM-ERROR` | `error: PROGRAM-ERROR` |

### Validation and absent targets

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `validation.unknown-position` | `error: ERROR` |
| `validation.invalid-function` | `error: ERROR` |
| `validation.undefined-adviser` | `error: ERROR` |
| `validation.macro-adviser` | `error: ERROR` |
| `validation.special-adviser` | `error: ERROR` |
| `validation.odd-plist` | `error: ERROR` |
| `validation.alist-instead-of-plist` | `error: ERROR` |
| `validation.invalid-depth` | `error: ERROR` |
| `validation.invalid-name` | `error: ERROR` |
| `validation.ratio-depth` | `(NIL)` |
| `validation.unknown-property` | `(NIL)` |
| `validation.string-name` | `(NIL)` |
| `validation.undefined-target` | `(NIL)` |
| `validation.macro-target` | `error: ERROR` |
| `validation.special-target` | `error: ERROR` |
| `validation.function-object-target` | `error: ERROR` |
| `validation.invalid-setf-name` | `error: ERROR` |
| `validation.failed-add-does-not-register` | `(NIL 11)` |
| `validation.remove-undefined-target` | `(NIL)` |
| `validation.member-undefined-target` | `(NIL)` |
| `validation.mapc-undefined-target` | `(NIL)` |

### Function names and lexical functions

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `target.setf-name` | `(20)` |
| `target.equal-setf-name-member` | `(T)` |
| `target.lexical-flet-is-separate` | `(10)` |

### Definition macros

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `define-advice.named-return` | `(T)` |
| `define-advice.named-reload-count` | `(1)` |
| `define-advice.anonymous-return` | `(NIL)` |
| `define-advice.anonymous-reload-count` | `(2)` |

### Threads and cross-thread mutation

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `threads.supported` | `(T)` |
| `threads.call-and-update` | `((22 :SECONDARY))` |
| `threads.mutate-from-around-without-lock` | `(11 T)` |

### TRACE coexistence

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `trace.trace-first` | `((22 :SECONDARY) (11 :SECONDARY))` |
| `trace.advice-first` | `((22 :SECONDARY) (11 :SECONDARY))` |

### Compilation: default

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `compile.default.direct` | `(22 :SECONDARY)` |
| `compile.default.fdefinition` | `(22 :SECONDARY)` |
| `compile.default.sharp` | `(22 :SECONDARY)` |
| `compile.default.symbol-function` | `(22 :SECONDARY)` |
| `compile.default.separate-file` | `(22 :SECONDARY)` |
| `compile.default.compiled-after-add` | `(22 :SECONDARY)` |
| `compile.default.reloaded-caller-fasl` | `(22 :SECONDARY)` |
| `compile.default.local-saved-fdefinition` | `(11 :SECONDARY)` |
| `compile.default.recursion-count` | `(4)` |
| `compile.default.mutual-count` | `(2)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `compile.default.local-saved-function` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` |

### Compilation: fast

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `compile.fast.direct` | `(22 :SECONDARY)` |
| `compile.fast.fdefinition` | `(22 :SECONDARY)` |
| `compile.fast.symbol-function` | `(22 :SECONDARY)` |
| `compile.fast.separate-file` | `(22 :SECONDARY)` |
| `compile.fast.compiled-after-add` | `(22 :SECONDARY)` |
| `compile.fast.reloaded-caller-fasl` | `(22 :SECONDARY)` |
| `compile.fast.local-saved-fdefinition` | `(11 :SECONDARY)` |
| `compile.fast.recursion-count` | `(4)` |
| `compile.fast.mutual-count` | `(2)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `compile.fast.sharp` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.fast.local-saved-function` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` |

### Compilation: debug3

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `compile.debug3.direct` | `(22 :SECONDARY)` |
| `compile.debug3.fdefinition` | `(22 :SECONDARY)` |
| `compile.debug3.symbol-function` | `(22 :SECONDARY)` |
| `compile.debug3.separate-file` | `(22 :SECONDARY)` |
| `compile.debug3.compiled-after-add` | `(22 :SECONDARY)` |
| `compile.debug3.reloaded-caller-fasl` | `(22 :SECONDARY)` |
| `compile.debug3.local-saved-fdefinition` | `(11 :SECONDARY)` |
| `compile.debug3.mutual-count` | `(2)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `compile.debug3.sharp` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.debug3.local-saved-function` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.debug3.recursion-count` | `(4)` | `(4)` | `(4)` | `(1)` | `(4)` | `(4)` | `(4)` | `(4)` |

### Compilation: speed0

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `compile.speed0.direct` | `(22 :SECONDARY)` |
| `compile.speed0.fdefinition` | `(22 :SECONDARY)` |
| `compile.speed0.symbol-function` | `(22 :SECONDARY)` |
| `compile.speed0.separate-file` | `(22 :SECONDARY)` |
| `compile.speed0.compiled-after-add` | `(22 :SECONDARY)` |
| `compile.speed0.reloaded-caller-fasl` | `(22 :SECONDARY)` |
| `compile.speed0.local-saved-fdefinition` | `(11 :SECONDARY)` |
| `compile.speed0.recursion-count` | `(4)` |
| `compile.speed0.mutual-count` | `(2)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `compile.speed0.sharp` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.speed0.local-saved-function` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` |

### Compilation: inline

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `compile.inline.direct` | `(22 :SECONDARY)` |
| `compile.inline.fdefinition` | `(22 :SECONDARY)` |
| `compile.inline.symbol-function` | `(22 :SECONDARY)` |
| `compile.inline.separate-file` | `(22 :SECONDARY)` |
| `compile.inline.compiled-after-add` | `(22 :SECONDARY)` |
| `compile.inline.reloaded-caller-fasl` | `(22 :SECONDARY)` |
| `compile.inline.local-saved-function` | `(11 :SECONDARY)` |
| `compile.inline.local-saved-fdefinition` | `(11 :SECONDARY)` |
| `compile.inline.recursion-count` | `(4)` |
| `compile.inline.mutual-count` | `(2)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `compile.inline.sharp` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` |

### Compilation: notinline

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `compile.notinline.direct` | `(22 :SECONDARY)` |
| `compile.notinline.fdefinition` | `(22 :SECONDARY)` |
| `compile.notinline.sharp` | `(22 :SECONDARY)` |
| `compile.notinline.symbol-function` | `(22 :SECONDARY)` |
| `compile.notinline.separate-file` | `(22 :SECONDARY)` |
| `compile.notinline.compiled-after-add` | `(22 :SECONDARY)` |
| `compile.notinline.reloaded-caller-fasl` | `(22 :SECONDARY)` |
| `compile.notinline.local-saved-fdefinition` | `(11 :SECONDARY)` |
| `compile.notinline.recursion-count` | `(4)` |
| `compile.notinline.mutual-count` | `(2)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `compile.notinline.local-saved-function` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` |

### Compilation: block

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `compile.block.direct` | `(22 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(22 :SECONDARY)` |
| `compile.block.fdefinition` | `(22 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(22 :SECONDARY)` |
| `compile.block.sharp` | `(22 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(11 :SECONDARY)` |
| `compile.block.symbol-function` | `(22 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(22 :SECONDARY)` |
| `compile.block.separate-file` | `(22 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(22 :SECONDARY)` |
| `compile.block.compiled-after-add` | `(22 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(22 :SECONDARY)` |
| `compile.block.reloaded-caller-fasl` | `(22 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(22 :SECONDARY)` |
| `compile.block.local-saved-function` | `(11 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(11 :SECONDARY)` |
| `compile.block.local-saved-fdefinition` | `(11 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(11 :SECONDARY)` |
| `compile.block.recursion-count` | `(4)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(4)` |
| `compile.block.mutual-count` | `(2)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(2)` |

### Code compiled before library loading

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `preexisting.default.getter` | `(22 :SECONDARY)` |
| `preexisting.default.after-remove` | `(11 :SECONDARY)` |
| `preexisting.fast.getter` | `(22 :SECONDARY)` |
| `preexisting.fast.after-remove` | `(11 :SECONDARY)` |
| `preexisting.inline.getter` | `(22 :SECONDARY)` |
| `preexisting.inline.after-remove` | `(11 :SECONDARY)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `preexisting.default.caller` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `preexisting.fast.caller` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `preexisting.inline.caller` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` |

### Active and pending registration

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `status.active` | `(:ACTIVE)` |
| `status.pending` | `(:PENDING)` |
| `status.reconnected` | `(:ACTIVE)` |
| `status.removed` | `(NIL)` |

<!-- END ADVICE BEHAVIOR AUDIT -->
