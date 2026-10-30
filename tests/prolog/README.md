# Prolog tests

Run from the repository root:

```sh
python3 tools/lisp.py tools/test.lisp prolog
```

`tools/lisp.py` selects an implementation and isolates ASDF caches;
`tools/test.lisp` loads the inferred `ooparts-tests/prolog` facade and calls its
exported `run-tests`. The `suite` module imports the layer suites; every test
package matches its path under `tests/`. The same driver accepts the other
components through `python3 tools/lisp.py tools/test.lisp <continuation|sat|regexp>`
and the aggregate suite through `all`. The direct invocation
`sbcl --dynamic-space-size 2048 --control-stack-size 1 --script tools/test.lisp prolog`
runs the same component under SBCL.

| Directory | Coverage |
|---|---|
| `api/` | Interactive query interface |
| `kernel/` | WAM, GC, SLG and cut |
| `syntax/` | DCG, lexical LET, term syntax and native specialization |
| `adapters/` | Builtins, collection, cons operations and strict ISO terms |
| `library/` | Ordinary derived predicates and adapter wrappers |
| `text/` | Text reader/writer and source loading |
| `support/` | Shared assertions and normalized derived observations |
| `iso/` | Offline worker tests and reviewed corpus expectations |

`sbcl --script tools/prolog/observations.lisp` prints normalized observations.
Use `OOPARTS_ROOT` to select another checkout with the same layout. Compare older
layouts with their revision's observation entry point and the same SBCL.

The bundled ISO corpus has its own driver, outside `tools/test.lisp`:

```sh
ISO_SBCL=sbcl python3 -m unittest discover -s tests/prolog/iso -p 'test_*.py' -v
python3 tools/prolog/iso/run.py --baseline tests/prolog/iso/expectations/baseline.json --strict --jobs 2
python3 tools/prolog/iso/run.py --term-model iso --strict --jobs 2 --output build/prolog/iso-strict
```

See the [ISO driver](../../docs/prolog/iso-runner.md) and
[validation coverage](../../docs/prolog/VALIDATION.md).
