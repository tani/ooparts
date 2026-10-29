# Prolog tests

Run from the repository root:

```sh
sbcl --dynamic-space-size 2048 --control-stack-size 1 --script tools/test.lisp prolog
```

`tools/test.lisp` loads the inferred `ooparts-tests/prolog` facade and calls its
exported `run-tests`. The `suite` module imports the layer suites; every test
package matches its path under `tests/`.

| Directory | Coverage |
|---|---|
| `api/` | Interactive query interface |
| `kernel/` | WAM, GC, SLG and cut |
| `syntax/` | DCG, lexical LET and term syntax |
| `adapters/` | Builtins, collection, cons operations and strict ISO terms |
| `library/` | Ordinary derived predicates and adapter wrappers |
| `text/` | Text reader/writer and source loading |
| `support/` | Shared assertions and normalized derived observations |
| `iso/` | Offline worker tests and reviewed corpus expectations |

`sbcl --script tools/prolog/observations.lisp` prints normalized observations.
Use `OOPARTS_ROOT` to select another checkout with the same layout. Compare older
layouts with their revision's observation entry point and the same SBCL.

See the [ISO driver](../../docs/prolog/iso-runner.md) and
[validation coverage](../../docs/prolog/VALIDATION.md).
