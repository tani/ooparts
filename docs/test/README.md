# ooparts/test

A minimal, dependency-free testing framework adapted from
[1am](https://github.com/lmj/1am) at revision
`8b1da94eca4613fd8a20bdf63f0e609e379b0ba5`. The original API and MIT copyright/permission header are retained.
OOPArts adds ordered suites, descriptive checks, output control and optional
external-driver integration. The full notice is
also available in [licenses/1am-MIT.txt](../../licenses/1am-MIT.txt).
Installing 1am is not necessary. ASDF/UIOP is used for package-inferred system loading.

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
| `(is form &optional places datum &rest arguments)` | Require a non-nil result with CL:ASSERT-compatible places and diagnostics. Count a successful check and retain the `continue` restart. |
| `(signals condition &body body)` | Require a signaled condition matching the literal type specifier, including subtypes. A missing or differently typed condition is an error. |
| `(run &optional (tests *tests*))` | Run a shuffled copy of a sequence of function designators. Return no values on success; propagate failures. |

## OOPArts extensions

| Export | Contract |
|---|---|
| `(check value &optional description &rest arguments)` | Check an already evaluated value, format a failure diagnostic, count a success and return the value. A false value signals `simple-error`. |
| `(with-suite (name) &body body)` | Run an ordered group, preserving declarations and multiple values. Nested groups share the root counter and random state. |
| `(call-with-suite name function)` | Function interface to `with-suite`. |
| `*test-output*` | Test report stream; `nil` selects standard output. The root captures the stream before test code can redirect application output. |
| `*print-progress*` | Controls dots for successful checks. The original API defaults to dots; a root suite suppresses them to keep large runs readable. |
| `(check-program command &key directory (expected-status 0))` | Optionally run an argv list through UIOP, inherit process streams and check its exit status. Return that status on success. No shell interpolation is performed. |

```lisp
(ooparts/test:with-suite ("parser")
  (ooparts/test:check (equal '(a b) (parse "a b"))
                      "Parser returned an unexpected value")
  (ooparts/test:with-suite ("invalid input")
    (ooparts/test:signals parse-error (parse "("))))
```

Ordered suites do not populate `*tests*` or shuffle their bodies. This preserves
setup/cleanup ordering in existing regressions. The root reports the number of
named groups and successful checks. A group escaping with an error or another
nonlocal exit prints no success summary; the error reaches ASDF/CI unchanged.
The existing `run` API keeps its randomized sequence and no-values return.
Neither runner collects errors automatically. A test that deliberately catches
errors must check the resulting observation or reject the accumulated failures.

## Repository integration

Curry and the framework regression suite use this runner. Load the inferred
systems `ooparts-tests/curry` or `ooparts-tests/test`, then invoke their exported
`run-tests` functions. Both are included in the aggregate regression runner.
Other libraries retain their existing entry points.
