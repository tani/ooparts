# Advice

`ooparts/advice` provides global function advice with an API modeled on modern
Emacs advice. It has no external Lisp dependencies. The SBCL backend requires
**SBCL 2.6.6 or later** and uses native encapsulation, without patching SBCL.
Other implementations use a portable function-definition wrapper with the
limitations below.

```lisp
(asdf:load-system "ooparts/advice")

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
```

All names are exported from `ooparts/advice`. The target must already be a
globally defined function, named by a symbol or `(setf symbol)`. Macros, special
operators, lexical functions and pending advice for undefined targets are not
supported. Advice functions can be function objects or function-name symbols;
symbols are resolved when called.

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
chain and base function and can be retained after AROUND returns.

## Implementation guarantees

On SBCL 2.6.6+, native `sb-int:encapsulate` makes ordinary compiled global calls
and newly fetched `fdefinition` values pass through advice without a NOTINLINE
declaration. Advice remains installed across DEFUN and `(setf fdefinition)`
redefinition. Removing the last advice exposes the latest base definition.
One native encapsulation holds the composed OOPArts chain, separate from other
encapsulations such as TRACE. SB-INT is an internal, version-dependent API.

An ordinary function object actually retained before installation remains the
original object. A compiler can rewrite `(let ((f #'target)) ... (funcall f x))`
into a named call; that expression is not a reliable test that an object was
retained. The audit distinguishes an opaque retained object from that compiled
local binding. Already expanded inline calls, block-local calls and optimized
self-recursion can bypass global encapsulation. Native generic functions retain
identity and affect saved objects; see the complete tables below.

The portable backend changes FDEFINITION. Fetching a definition dynamically
observes the wrapper, but the host compiler may cache a function or emit direct
calls. ECL and MKCL same-file compiled calls are examples. Automatic reapplication
after target redefinition is not provided by this backend. Removing advice
preserves an externally replaced function instead of restoring a stale base.
Those limitations also apply to CCL while using the portable backend. The
compiled CMUCL adapter has an additional removal failure: the identity guard
can reject its own installed definition, leaving advice active after registry
removal. TRACE can similarly defeat the portable identity guard. The detailed
audit records these current defects rather than presenting the fallback as
behaviorally equivalent to native SBCL.

The registry serializes additions and removals using `ooparts/host`. Running
calls hold no registry lock and use the chain they obtained on entry. Concurrent
user redefinition of a function is governed by the host implementation.

## Validation

```sh
sbcl --script tools/test.lisp advice
nix run .#test-advice-sbcl
python3 tools/check-layout.py
```

The regression suite covers the ten combinators, multiple and zero values,
short-circuit branches, ordering, replacement and removal, snapshot mutation,
SETF names, named definitions and escaping NEXT functions. SBCL-specific checks
cover compiled calls, compiled FDEFINITION lookup and redefinition while advised.
The separate behavior audit deliberately records differences and errors instead
of treating every difference as a test failure.

## References

- [Emacs: advising named functions](https://www.gnu.org/software/emacs/manual/html_node/elisp/Advising-Named-Functions.html)
- [Emacs: advice combinators](https://www.gnu.org/software/emacs/manual/html_node/elisp/Advice-Combinators.html)
- [SBCL 2.6.6 release notes](https://www.sbcl.org/all-news.html)
- [SBCL compiler and block compilation manual](https://www.sbcl.org/manual/index.html#Block-Compilation-Semantics)
- [CLHS compilation semantic constraints](https://www.lispworks.com/documentation/HyperSpec/Body/03_bbc.htm)
- [Emacs advice reference source](https://github.com/emacs-mirror/emacs/blob/master/lisp/emacs-lisp/nadvice.el)
- Implementation: [core](../../src/advice/core.lisp), [backend](../../src/advice/backend.lisp),
  [executable observations](../../tests/advice/behavior.lisp).

This is an independent Common Lisp implementation of the described interface;
no Emacs source code is included.

## Scope and evidence

The comparison below concerns **this implementation**, whose non-SBCL backend
is currently a SETF FDEFINITION wrapper. It does not measure CCL's native ADVISE,
Budden tools, cl-advice, or the previously explored ECL/MKCL compiler patches.
Those mechanisms are not installed by `ooparts/advice`.

| Evidence | What it establishes | What it does not establish |
|---|---|---|
| Common core source review | Combinator construction, registry rules, validation and snapshot iteration | Correct host compilation of every possible program |
| Backend source review | SBCL native encapsulation versus a portable wrapper and EQ-based removal guard | Uniform redefinition or metadata behavior on every host |
| Recorded executable probes | Exact results for the listed runtime versions, policies and sequences | Behavior on other architectures, operating systems, builds or arbitrary optimization settings |
| SBCL manual and CLHS | Inline, same-file, recursive and block compilation constraints | A portable guarantee that NOTINLINE-free advice intercepts every call |
| Emacs manual/source review | Which modern API conventions were adopted or intentionally differ | Bit-for-bit compatibility with Emacs Lisp |

All ordinary compiler tests use compatible argument/return shapes. Observing
advice by changing a declared FTYPE contract would be a different, potentially
non-conforming experiment. An INLINE request that is actually honored is also
outside a portable promise of later changing that function definition.

## Differences from modern Emacs advice

The Emacs column is based on the upstream Lisp manual and `nadvice.el`, not on
running an Emacs implementation in the eight-host audit.

| Item | `ooparts/advice` | Modern Emacs named-function advice |
|---|---|---|
| Named API | `advice-add`, `advice-remove`, `advice-member-p`, `advice-mapc`, `define-advice` | Same API names and principal argument order |
| Ordinary combinators | Ten call combinators listed above | Same ten combinations of advice and inner function |
| Properties | Common Lisp plist with `:name`, `:depth` | Alist with `name`, `depth` |
| Nesting | Lower depth outside; newest outside at equal depth | Same convention |
| Named replacement | Replace matching name; unnamed replacement by the supplied designator | Same principal convention |
| Names | Non-NIL symbol or string; symbol identity and string contents matter | Symbol or string; the same distinction matters |
| Return values | Common Lisp multiple values, including zero values | Emacs Lisp has one ordinary return value |
| FILTER-RETURN | Receives only the primary inner value; its own multiple values become the result | Receives the single inner result |
| NEXT | Callable function value; can be invoked repeatedly or retained | Callable inner function |
| Existing global targets | Symbol or `(setf symbol)` | Named symbol, including alias/macro/autoload handling |
| Undefined targets | Rejected; no pending registration | Deferred advice can be registered before definition while preserving FBOUNDP behavior |
| Macro targets | Rejected | Supported for future macro expansions |
| Special operators/forms | Rejected | Rejected |
| Generalized-place `add-function` / `remove-function` | Not provided | Provided separately from named-function advice |
| Interactive command metadata and `:interactive-only` | Not provided | Provided by Emacs |
| Documentation | Host-dependent; original function documentation can disappear while wrapped | Named advice integrates with documentation and advice descriptions |
| Redefinition tracking | Native SBCL only; unbinding still breaks registry/backend correspondence | Named advice integrates with definition changes and autoloads |
| `define-advice` naming | `TARGET@NAME` in the macro caller's package; SETF names are supported | `SYMBOL@NAME` |
| `define-advice` reload | Named advice replaces; anonymous reload adds another closure | Same practical named/anonymous distinction |
| Registry return | Boolean membership; MAPC snapshots entries and copies the outer plist | Non-NIL membership; properties are Emacs alists |

## Current limitations exposed by the audit

These are observations about the present code, including defects. No backend
or host semantics were changed to make the comparison look uniform.

| Situation | Current behavior | Scope / consequence |
|---|---|---|
| DEFUN, COMPILE, setter or FASL redefinition | Native SBCL keeps advice; portable fallback loses it | Portable registry entries remain, so membership can say true when calls are unadvised |
| Adding again after external redefinition | The existing registry state prevents reattachment | Portable calls remain unadvised even though the new advice appears in MAPC |
| FMAKUNBOUND | Removes the function binding without clearing the registry | Affects native SBCL too; defining the name again does not automatically repair the stale state |
| Removing ordinary advice on CMUCL under QEMU | The compiled adapter's installed definition was not EQ to its stored wrapper in the diagnostic probe | Detach's guard fails: registry removal can leave interception active; the deeper compiler/host cause and behavior on native i386 are not established |
| TRACE outside a portable wrapper | Current definition is no longer EQ to the stored wrapper | Removing advice can leave it active. ABCL also showed this for TRACE installed first |
| Saved ordinary wrapper after the last removal | The saved dispatcher still closes over the old state and chain | It continues to apply the old advice; current name lookup normally returns the base, except for the CMUCL removal failure |
| Saved wrapper after base redefinition | SBCL sees the replaced native underlying definition; portable wrapper keeps its old captured base | Current name and retained wrapper can produce different results |
| Copying an advised definition to another name | SBCL setter strips native encapsulation from the supplied function; portable hosts retain the closure | Copying a definition is not equivalent to copying its advice registry |
| Saved generic function | Native SBCL mutates the generic dispatch while retaining identity | A preexisting generic-function object sees advice, unlike an ordinary saved function |
| Adding methods while generically advised | Native SBCL works; portable global binding is an ordinary closure | DEFMETHOD fails on the portable binding until the generic function is restored |
| Compiler rewrites a local `#'target` binding | SBCL and CMUCL can perform a named call after the installer runs | A lexical variable in source does not establish that an independent old function object survives compilation |
| Self recursion | Fast SBCL code and several other hosts enter the wrapper only once | Global-entry interception does not imply interception of each recursive step |
| Definition documentation | Host-dependent preservation or loss | The API does not copy or synthesize documentation metadata |
| MAPC properties | Only the outer plist is copied | Mutating a shared nested property object remains visible |
| Running calls during registry mutation | In-flight call uses its captured chain; later calls use the updated chain | Cross-thread callback mutation was tested; arbitrary simultaneous redefinition races were not |
| Package-locked functions, arbitrary C/FFI entries, saved images, debugger frame layout and overhead | Not established by this audit | No claim of uniform behavior or performance is made for these unmeasured cases |

## Reproduce the full behavior audit

The observer is `tests/advice/behavior.lisp`; the runner launches a fresh process
per host, checks the completion marker and rejects duplicate/missing records.
The report generator lists every probe exactly once and refuses a report whose
recorded backend/core/host hashes no longer match the implementation.

```sh
# One available host.
nix develop .#sbcl --command python3 tools/advice/audit.py \
  --implementation sbcl --output-dir build/advice/audit-sbcl

# All available Linux hosts. The GNU11 setup affects MKCL only.
nix develop --command python3 tools/advice/audit.py \
  --implementation sbcl ccl ecl mkcl abcl clisp clasp cmucl \
  --bootstrap tools/advice/mkcl-gnu11.lisp \
  --output-dir build/advice/audit

# Generate all tables; update both READMEs when all eight reports are complete.
python3 tools/advice/report.py build/advice/audit/results.json --update-readme
```

The current execution host required a QEMU i386 wrapper for CMUCL. Use
`--runtime-map map.json` to select exact executable paths, including a wrapper,
and `--emulated cmucl` to record that fact. The wrapper simply executes
`qemu-i386 /absolute/path/to/cmucl/bin/lisp "$@"`. It is a development tool,
not a Lisp library dependency. ASDF caches and all generated FASLs, sources,
logs, JSON and standalone Markdown reports stay under ignored `build/`.

The recorded Nix runtime versions below supersede earlier experiments using
locally extracted Ubuntu/release binaries. The earlier seven-host regression
pass counts did not test this entire behavior space.

<!-- BEGIN ADVICE BEHAVIOR AUDIT -->
## Recorded behavior comparison

Audited on 2026-11-03, with Nixpkgs commit `0bb2eedc20e4739f29e8045034f2828ad7054f8f` on Linux. These are measurements of the current OOPArts backends, not of each host's native advice facility.

**218 comparison rows, 1684 observations across eight runtimes:** 153 rows have identical outcomes; 65 rows differ or include an unavailable control. N/A cells are not counted as measurements.

| Runtime | Version | Default same-file call | DEFUN retains advice | Last removal restores base | Generic identity retained |
|---|---|---|---|---|---|
| SBCL | 2.6.8 | Advice | Yes | Yes | Yes |
| CCL | Version 1.13 LinuxX8664 | Advice | No | Yes | No |
| ECL | 26.5.5 | Bypass | No | Yes | No |
| MKCL | 1.1.11* | Bypass | No | Yes | No |
| ABCL | 1.9.3 | Advice | No | Yes | No |
| CLISP | 2.49.95+ (2024-11-03) (built on localhost [127.0.0.1]) | Advice | No | Yes | No |
| Clasp | clasp-boehmprecise-3.0.1-non-cst | Advice | No | Yes | No |
| CMUCL | 21d (21D Unicode) / emulated* | Advice | No | **No** | No |

* Bootstrap: `mkcl-gnu11.lisp`.
* Emulated runtimes: CMUCL.
* In the 2026-11-03 snapshot, MKCL used GNU11 mode because the locked package's default C compiler mode rejected its generated calls. This does not patch Lisp lookup or optimization policy. CMUCL used QEMU i386 because this execution host cannot run the package's 32-bit ELF directly; CMUCL emitted a personality-setting warning. Native i386 was not measured.
* CLISP reports an older source date in `lisp-implementation-version`; the Nix package is `2.49.95-unstable-2024-12-28`. Full runtime-reported versions are in the JSON report.

### How to read the complete tables

- Each cell is the printed `multiple-value-list` of a probe. `NIL` means **zero values**; `(NIL)` means one NIL value. Errors are normalized to `UNDEFINED-FUNCTION`, `TYPE-ERROR`, `PROGRAM-ERROR`, or other `ERROR`, not exact implementation-specific subclasses or messages.
- Ordinary base: argument 10 returns `(11 :SECONDARY)`; one doubling advice returns `(22 :SECONDARY)`; two return `(44 :SECONDARY)`. Replacement base returns `(12 :SECONDARY)`, or `(24 :SECONDARY)` when still advised.
- `combinator.*` probes return two values: the result-value list and the event sequence. Mutation and TRACE probes likewise return before/after values. IDs map directly to `tests/advice/behavior.lisp`.
- Shared rows are listed once under **Same on all eight**. Every other row includes all eight columns. Both types are observations, not proofs that every optimization or platform behaves the same.
- `default` uses fresh host defaults. Other policies first set speed/space/safety/debug/compilation-speed to 1, then apply their named changes: `fast` = speed 3, safety 1, debug 0; `debug3` = debug 3; `speed0` = speed 0; `inline` = fast + INLINE target; `notinline` = NOTINLINE target/self/mutual entry; `block` = host `:block-compile t` on SBCL/CMUCL.
- Same-file and separate-file callers are compiled before advice. `compiled-after-add` is a new separate caller compiled while advice is present. `reloaded-caller-fasl` reloads the separate caller's FASL after advice is present. Recursion probes call n=3: full interception gives 4 self calls or 2 calls to the observed mutual-recursion entry.
- `local-saved-function` evaluates `(let ((saved #'target)) (funcall installer) (funcall saved x))`; the installer adds advice. `local-saved-fdefinition` uses FDEFINITION instead. These deliberately distinguish compiler rewriting from an actual object captured through an opaque boundary.
- INLINE requests can be ignored. An advised result in an INLINE row does not establish that actual inline expansion was intercepted. Same-file redefinition and inline controls explore implementation behavior beyond portable ANSI assumptions.

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
| `object.saved-wrapper-after-last-removal` | `(22 :SECONDARY)` |
| `object.saved-wrapper-after-readd` | `(22 :SECONDARY)` |
| `object.current-after-readd` | `(99)` |
| `object.alias-bound-before-add` | `(11 :SECONDARY)` |
| `object.wrapper-after-gc` | `(22 :SECONDARY)` |
| `object.escaped-next-after-base-redefinition` | `(11 :SECONDARY)` |
| `object.assign-definition-to-itself` | `(22 :SECONDARY)` |
| `object.function-assignment-identity` | `(T)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `object.current-after-last-removal` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` |
| `object.alias-bound-after-add` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `object.saved-wrapper-after-base-redefinition` | `(24 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |

### Redefinition and unbinding

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `redefinition.defun.member` | `(T)` |
| `redefinition.defun.after-remove` | `(12 :SECONDARY)` |
| `redefinition.compile.member` | `(T)` |
| `redefinition.compile.after-remove` | `(12 :SECONDARY)` |
| `redefinition.fdefinition.member` | `(T)` |
| `redefinition.fdefinition.after-remove` | `(12 :SECONDARY)` |
| `redefinition.symbol-function.member` | `(T)` |
| `redefinition.symbol-function.after-remove` | `(12 :SECONDARY)` |
| `redefinition.fasl.member` | `(T)` |
| `redefinition.fasl.after-remove` | `(12 :SECONDARY)` |
| `redefinition.fmakunbound-boundp` | `(NIL)` |
| `redefinition.fmakunbound-member` | `(T)` |
| `redefinition.fmakunbound-add` | `error: UNDEFINED-FUNCTION` |
| `redefinition.fmakunbound-then-define` | `(12 :SECONDARY)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `redefinition.defun.current` | `(24 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` |
| `redefinition.defun.add-again` | `(24 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` |
| `redefinition.compile.current` | `(24 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` |
| `redefinition.compile.add-again` | `(24 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` |
| `redefinition.fdefinition.current` | `(24 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` |
| `redefinition.fdefinition.add-again` | `(24 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` |
| `redefinition.symbol-function.current` | `(24 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` |
| `redefinition.symbol-function.add-again` | `(24 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` |
| `redefinition.fasl.current` | `(24 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` |
| `redefinition.fasl.add-again` | `(24 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` | `(12 :SECONDARY)` |

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
| `generic.saved-before-after-remove` | `(11 :SECONDARY)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `generic.saved-before-add` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` |
| `generic.identity-preserved` | `(T)` | `(NIL)` | `(NIL)` | `(NIL)` | `(NIL)` | `(NIL)` | `(NIL)` | `(NIL)` |
| `generic.still-generic-function` | `(T)` | `(NIL)` | `(NIL)` | `(NIL)` | `(NIL)` | `(NIL)` | `(NIL)` | `(NIL)` |
| `generic.add-method-while-advised` | `(6)` | `error: PROGRAM-ERROR` | `error: PROGRAM-ERROR` | `error: PROGRAM-ERROR` | `error: ERROR` | `error: ERROR` | `error: PROGRAM-ERROR` | `error: PROGRAM-ERROR` |
| `generic.current-after-remove` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` |

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
| `validation.undefined-target` | `error: UNDEFINED-FUNCTION` |
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

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `trace.trace-first` | `((22 :SECONDARY) (11 :SECONDARY))` | `((22 :SECONDARY) (11 :SECONDARY))` | `((22 :SECONDARY) (11 :SECONDARY))` | `((22 :SECONDARY) (11 :SECONDARY))` | `((22 :SECONDARY) (22 :SECONDARY))` | `((22 :SECONDARY) (11 :SECONDARY))` | `((22 :SECONDARY) (11 :SECONDARY))` | `((22 :SECONDARY) (22 :SECONDARY))` |
| `trace.advice-first` | `((22 :SECONDARY) (11 :SECONDARY))` | `((22 :SECONDARY) (22 :SECONDARY))` | `((22 :SECONDARY) (22 :SECONDARY))` | `((22 :SECONDARY) (22 :SECONDARY))` | `((22 :SECONDARY) (22 :SECONDARY))` | `((22 :SECONDARY) (22 :SECONDARY))` | `((22 :SECONDARY) (22 :SECONDARY))` | `((22 :SECONDARY) (22 :SECONDARY))` |

### Compilation: default

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `compile.default.fdefinition` | `(22 :SECONDARY)` |
| `compile.default.symbol-function` | `(22 :SECONDARY)` |
| `compile.default.compiled-after-add` | `(22 :SECONDARY)` |
| `compile.default.reloaded-caller-fasl` | `(22 :SECONDARY)` |
| `compile.default.local-saved-fdefinition` | `(11 :SECONDARY)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `compile.default.direct` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.default.sharp` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.default.separate-file` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.default.local-saved-function` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.default.recursion-count` | `(4)` | `(1)` | `(1)` | `(1)` | `(1)` | `(1)` | `(4)` | `(4)` |
| `compile.default.mutual-count` | `(2)` | `(2)` | `(1)` | `(1)` | `(2)` | `(2)` | `(2)` | `(2)` |

### Compilation: fast

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `compile.fast.fdefinition` | `(22 :SECONDARY)` |
| `compile.fast.symbol-function` | `(22 :SECONDARY)` |
| `compile.fast.compiled-after-add` | `(22 :SECONDARY)` |
| `compile.fast.reloaded-caller-fasl` | `(22 :SECONDARY)` |
| `compile.fast.local-saved-fdefinition` | `(11 :SECONDARY)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `compile.fast.direct` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.fast.sharp` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.fast.separate-file` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.fast.local-saved-function` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.fast.recursion-count` | `(1)` | `(1)` | `(1)` | `(1)` | `(1)` | `(1)` | `(4)` | `(4)` |
| `compile.fast.mutual-count` | `(2)` | `(2)` | `(1)` | `(1)` | `(2)` | `(2)` | `(2)` | `(2)` |

### Compilation: debug3

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `compile.debug3.fdefinition` | `(22 :SECONDARY)` |
| `compile.debug3.symbol-function` | `(22 :SECONDARY)` |
| `compile.debug3.compiled-after-add` | `(22 :SECONDARY)` |
| `compile.debug3.reloaded-caller-fasl` | `(22 :SECONDARY)` |
| `compile.debug3.local-saved-fdefinition` | `(11 :SECONDARY)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `compile.debug3.direct` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.debug3.sharp` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.debug3.separate-file` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.debug3.local-saved-function` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.debug3.recursion-count` | `(4)` | `(4)` | `(1)` | `(1)` | `(1)` | `(1)` | `(4)` | `(4)` |
| `compile.debug3.mutual-count` | `(2)` | `(2)` | `(2)` | `(1)` | `(2)` | `(2)` | `(2)` | `(2)` |

### Compilation: speed0

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `compile.speed0.fdefinition` | `(22 :SECONDARY)` |
| `compile.speed0.symbol-function` | `(22 :SECONDARY)` |
| `compile.speed0.compiled-after-add` | `(22 :SECONDARY)` |
| `compile.speed0.reloaded-caller-fasl` | `(22 :SECONDARY)` |
| `compile.speed0.local-saved-fdefinition` | `(11 :SECONDARY)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `compile.speed0.direct` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.speed0.sharp` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.speed0.separate-file` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.speed0.local-saved-function` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` |
| `compile.speed0.recursion-count` | `(4)` | `(1)` | `(1)` | `(1)` | `(1)` | `(1)` | `(4)` | `(4)` |
| `compile.speed0.mutual-count` | `(2)` | `(2)` | `(1)` | `(1)` | `(2)` | `(2)` | `(2)` | `(2)` |

### Compilation: inline

Same on all eight:

| Probe ID | Observed values on all eight |
|---|---|
| `compile.inline.fdefinition` | `(22 :SECONDARY)` |
| `compile.inline.symbol-function` | `(22 :SECONDARY)` |
| `compile.inline.local-saved-function` | `(11 :SECONDARY)` |
| `compile.inline.local-saved-fdefinition` | `(11 :SECONDARY)` |

Different outcomes or unavailable controls:

| Probe ID | SBCL | CCL | ECL | MKCL | ABCL | CLISP | Clasp | CMUCL |
|---|---|---|---|---|---|---|---|---|
| `compile.inline.direct` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` |
| `compile.inline.sharp` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` |
| `compile.inline.separate-file` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` |
| `compile.inline.compiled-after-add` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` |
| `compile.inline.reloaded-caller-fasl` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` | `(11 :SECONDARY)` | `(22 :SECONDARY)` | `(11 :SECONDARY)` |
| `compile.inline.recursion-count` | `(1)` | `(1)` | `(1)` | `(1)` | `(1)` | `(1)` | `(4)` | `(4)` |
| `compile.inline.mutual-count` | `(2)` | `(2)` | `(1)` | `(1)` | `(2)` | `(2)` | `(2)` | `(2)` |

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
| `compile.block.direct` | `(11 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(11 :SECONDARY)` |
| `compile.block.fdefinition` | `(22 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(22 :SECONDARY)` |
| `compile.block.sharp` | `(11 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(11 :SECONDARY)` |
| `compile.block.symbol-function` | `(22 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(22 :SECONDARY)` |
| `compile.block.separate-file` | `(22 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(22 :SECONDARY)` |
| `compile.block.compiled-after-add` | `(22 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(22 :SECONDARY)` |
| `compile.block.reloaded-caller-fasl` | `(22 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(22 :SECONDARY)` |
| `compile.block.local-saved-function` | `(11 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(11 :SECONDARY)` |
| `compile.block.local-saved-fdefinition` | `(11 :SECONDARY)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(11 :SECONDARY)` |
| `compile.block.recursion-count` | `(1)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(1)` |
| `compile.block.mutual-count` | `(1)` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `N/A` | `(1)` |

<!-- END ADVICE BEHAVIOR AUDIT -->
