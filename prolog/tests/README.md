# Tests

Run commands from the repository root:

```sh
sbcl --dynamic-space-size 2048 --control-stack-size 1 --script tests/run.lisp
```

`run.lisp` loads the `ooparts/prolog/tests` ASDF system. `suite.lisp` remains the single
suite entry point; inferred package names match each test file's path.

| Directory | Coverage |
|---|---|
| `api/` | Interactive query interface |
| `kernel/` | WAM, garbage collection, SLG and cut |
| `syntax/` | DCG, lexical LET and term syntax |
| `adapters/` | Builtins, collectors, cons operations, ISO behavior and strict terms |
| `library/` | Ordinary derived predicates and adapter wrappers |
| `prolog/` | Text reader/writer and source loading |
| `support/` | Assertions, solution helpers and differential observations |
| `iso/` | Bundled upstream corpus and independent conformance driver |

Compare normalized derived observations across checkouts using the same script:

```sh
OOPARTS_PROLOG_ROOT=/path/to/reference sbcl --script tests/support/derived-observations.lisp > before.txt
OOPARTS_PROLOG_ROOT=/path/to/current sbcl --script tests/support/derived-observations.lisp > after.txt
diff -u before.txt after.txt
```

See [the ISO driver](iso/README.md) for the separate Python/SBCL validation
commands and [validation coverage](../docs/VALIDATION.md) for test boundaries.
