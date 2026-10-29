# ooparts/continuation

Single-prompt Danvy–Filinski `shift`/`reset` for Common Lisp, implemented by source
transformation and heap continuations. Continuations are composable, support
multiple invocations, and can outlive the `reset` that captured them. Native stacks and C helpers are not used. Reader conditionals select bundled
SBCL facilities or external environment/MOP portability libraries; see
[portability](../portability.md) for dependencies and validation.

The compiler conservatively adapts the direct-versus-CPS idea of Asai and Uehara
(PEPM 2018). It does not implement their polymorphic answer-type inference.
Unknown calls use the CPS path; effect-free regions remain ordinary native
Lisp. `cl-cont` was a design reference for walking code and handling Lisp-2
calls, rather than a runtime dependency or a vendored implementation.

## Use

Register the checkout with ASDF as described in the [root README](../../README.md).
The system and package are both `ooparts/continuation`; there are no aliases.

```lisp
(asdf:load-system "ooparts/continuation")

(ooparts/continuation:reset
  (+ 1 (ooparts/continuation:shift k
         (+ (funcall k 10) (funcall k 20)))))
;; => 32

(let ((k (ooparts/continuation:reset
           (+ 10 (ooparts/continuation:shift k k)))))
  (list (funcall k 2) (funcall k 7)))
;; => (12 17)
```

| Interface | Purpose |
|---|---|
| `reset &body body` | Transform the body and install a delimiter |
| `shift variable &body body` | Capture to the nearest transformed delimiter |
| `with-cps &body body` | Transform without adding an implicit delimiter |
| `lambda/cps lambda-list &body body` | Construct a transformed function |
| `defun/cps name lambda-list &body body` | Define a transformed global function; SETF names are supported |
| `transform form &optional environment mode` | Return ordinary Lisp implementing a form |
| `analyze form &optional environment` | Report conservative direct/CPS effect information |
| `continuation-p object` / `cps-function-p object` | Inspect function objects |
| `dynamic-wind before thunk after` | Install exit/reentry actions inside transformed code |
| `register-cps-adapter name replacement` | Register a transformed implementation for a native function object |

Captured continuations satisfy `functionp`. `funcall` and `apply` accept any
number of values, including zero. Ordinary single-value contexts select the
first value or NIL. Multiple-value contexts preserve every value.

`*transformation-mode*` controls macro expansion and defaults to `:selective`.
`transform` also accepts `:full` for differential testing. Recompile callers
after changing the compiler or transformation mode.

## Source and package ownership

- [conditions.lisp](../../src/continuation/conditions.lisp) owns the error classes.
- [environment.lisp](../../src/continuation/environment.lisp) selects the environment API.
- [runtime.lisp](../../src/continuation/runtime.lisp) owns frames, drivers,
  dynamic environments, continuation objects and native-call adapters.
- [compiler.lisp](../../src/continuation/compiler.lisp) owns normalization,
  effect analysis, native/CPS emission and transformation macros.
- [continuation.lisp](../../src/continuation.lisp) reexports the selected public API.

Each file has its own inferred package, with explicit imports between modules.
There are no `scps` or `selective-cps` package nicknames.

## Transformation boundary

Functions that must propagate capture to their caller should use `defun/cps`
or `lambda/cps`. Local lambdas, FLET and LABELS inside the transformed region
are handled automatically. Previously compiled native functions are not
decompiled or transformed retrospectively.

Standard special forms, macrolet/symbol-macrolet, ordinary lambda lists,
nonlocal control, dynamic binding and multiple values are supported. Optional,
keyword and auxiliary initializers may themselves capture continuations.
Unknown implementation-specific forms signal `unsupported-form`.

Place BLOCK and TAGBODY targets inside the transformed region. References
crossing a function/reset boundary use heap targets and retain expiration
checks. Invoking a captured reference to an expired outside target signals
`inactive-control-target`.

Native callback functions can be called normally. Capture that would cross an
untransformed native frame signals `native-boundary`. A callback's explicitly
nested `reset` can handle capture locally. Built-in adapters cover `funcall`,
`apply`, list/sequence mapping, `maphash`, `reduce`, and the sequence quantifiers.
Adapters are registered by the identity of the current function object; after
redefining that function, register the adapter again.

## Dynamic state and declarations

Lexical locations and captured special-binding cells are shared by multiple
invocations. Invoking a continuation does not roll back the store or reevaluate
previously evaluated arguments. Each trampoline task synchronizes native
special-variable accesses with its heap environment.

Exiting a dynamic extent runs cleanup/after actions from inside out. Reentry
runs before actions from outside in. Pending transfers captured inside cleanup
are represented explicitly and rebound when a continuation spine is copied.
Already closed external resources are not automatically reopened.

Explicit lexical `type`, `optimize`, and resolvable native `ftype`/`inline`/
`notinline` declarations are preserved. `special` has implemented dynamic
semantics. Arbitrary custom declarations and macros that inspect local type
declarations through `&environment` are not fully modeled. `the` is retained;
top-level compile-time definitions should remain in ordinary Lisp files.

## Verification and limits

```sh
sbcl --script tools/test.lisp continuation
SBCL=sbcl bash tools/continuation/test.sh
```

The regression suite has 3178 checks, including 1328 independently reduced core
terms in both transformation modes. The shell driver also checks fresh-process
FASL and saved-core reloads. A captured restart is invoked after loading
a compiled fixture and again after restoring a saved core. Restart tests also
cover condition association through macro forms, duplicate/anonymous names,
named option functions, correctable errors and repeated resumption. Tests include multiple values, mutations, depth-2000
captures, 100000 tail calls, GC and sequential invocation from another thread.
Shared mutable state is not automatically synchronized between concurrent
invocations.

This is a complete multi-shot `shift`/`reset` implementation for its transformed
subset, not transparent capture of every Common Lisp/native/FFI frame. It does
not provide multi-prompt operators, shift0/control, or a mechanically checked
correctness proof for the complete implementation.

See [the mathematical design note](semantics.md),
[historical benchmarks](../../benchmarks/continuation/README.md), and the
[license/provenance register](../../THIRD_PARTY.md).
