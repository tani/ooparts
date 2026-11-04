# ooparts/test

A minimal, dependency-free testing framework adapted from
[1am](https://github.com/lmj/1am) at revision
`8b1da94eca4613fd8a20bdf63f0e609e379b0ba5`. The implementation retains
upstream behavior and the MIT copyright/permission header. The full notice is
also available in [licenses/1am-MIT.txt](../../licenses/1am-MIT.txt).
Only the package definition and namespace have changed; installing 1am is
not necessary. ASDF/UIOP is used for package-inferred system loading.

## Quick start

```lisp
(asdf:load-system "ooparts/test")

(uiop:define-package #:example/tests
  (:use #:cl)
  (:import-from #:ooparts/test #:test #:is #:signals #:run #:*tests*))
(in-package #:example/tests)

(test arithmetic
  (is (= 4 (+ 2 2)))
  (signals division-by-zero (/ 1 0)))

(run)                   ; Run the default registry in randomized order.
(arithmetic)            ; Run one test as an ordinary function.
(run '(arithmetic))     ; Run an explicit selection.
```

## API

| Export | Contract |
|---|---|
| `*tests*` | Dynamically bindable list used by `run` by default. Initially `nil`. |
| `(test name &body body)` | Define a zero-argument function, register its symbol once, return its name. Registration occurs when evaluated or loaded, including FASL load. |
| `(is form)` | Use Common Lisp `assert` to require a non-nil result; print a dot and count a successful check. The `continue` restart is retained. |
| `(signals condition &body body)` | Require a signaled condition matching the literal type specifier, including subtypes. A missing or differently typed condition is an error. |
| `(run &optional (tests *tests*))` | Run a shuffled copy of a sequence of function designators. Return no values on success; propagate failures. |

Tests are compiled normally when their source is compiled. Calling a test
function directly prints its name and success summary and preserves its body's
return values. A successful `run` prints the test and check counts. Empty runs
succeed. Assertions outside a run print dots without adding to a run's count.

## Failure and reproducibility

Failures enter the normal Lisp debugger, or propagate to an enclosing handler.
There is no catch-and-continue runner: a failed run stops immediately and does
not print a success summary. `signals` intercepts the first signaled condition;
for example, a warning before an expected error is a mismatch.

The runner uses a private random state shared by the shuffle and tests. After
an unsuccessful run, the next invocation starts from the retained state until
a run succeeds. Reproduction requires the same test sequence and unchanged
random-consuming control flow. External state and side effects are not reset.

The registry is flat and shared unless dynamically bound. Bind `*tests*` around
loading or defining a suite to isolate it, retain that resulting list, and pass
it to `run`. Tests must not run concurrently if they share the registry or
failure seed. Thread synchronization and cross-thread check counting are not
provided. No suites, fixtures, TAP/JUnit output, or new CLI are added.

## Portability and verification

The framework uses ANSI Common Lisp, with ASDF/UIOP for its package definition.
It contains no FFI, implementation-specific reader conditionals, runtime
process calls or external Lisp libraries. It is included in the repository's
eight-implementation Nix matrix; actual local validation is recorded in the
change report rather than inferred from portability.

```sh
python3 tools/check-layout.py
python3 tools/lisp.py tools/test.lisp test
nix run .#test-test-sbcl
```

The regression facade `ooparts-tests/test:run-tests` checks registration and
redefinition, assertions and their restart, condition subtypes and mismatches,
direct calls and return values, list/vector selection, nonmutating shuffling,
failure propagation, and replay of failed random runs. Existing component
suites keep their current runners.

Local validation on 2026-11-04 used SBCL 2.2.9: the regression facade passed,
and separate compiler/loader processes verified FASL registration and repeated
load deduplication. The aggregate `ooparts-tests` suite, layout checks and
license inventory validation also passed.
Other implementations are configured in Nix but were not executed locally.
