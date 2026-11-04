# OOPArts

A collection of Common Lisp libraries. All modules use ASDF package-inferred
systems; the only explicit systems are `ooparts` and `ooparts-tests`. A module's
package name matches its path, and public packages have no nicknames.

## Libraries

Each library's README contains its interface, examples, implementation support,
behavior, limitations and validation results.

| Library | System and public package | README |
|---|---|---|
| Advice | `ooparts/advice` | [README](docs/advice/README.md) |
| Continuation | `ooparts/continuation` | [README](docs/continuation/README.md) |
| Curses | `ooparts/curses` | [README](docs/curses/README.md) |
| Readline | `ooparts/readline` | [README](docs/readline/README.md) |
| Prolog | `ooparts/prolog` | [README](docs/prolog/README.md) |
| SAT | `ooparts/sat` | [README](docs/sat/README.md) |
| regexp | `ooparts/regexp` | [README](docs/regexp/README.md) |

## Load

Register the checkout with ASDF, then load the aggregate system or an individual
system from the table above:

```lisp
(require :asdf)
(pushnew (truename "/path/to/ooparts/") asdf:*central-registry* :test #'equal)
(asdf:load-system "ooparts")
```

## Documentation

- [Documentation index](docs/README.md)
- [Testing](docs/testing.md), [portability](docs/portability.md),
  [Nix](docs/nix.md), [repository layout](docs/layout.md)
- [Third-party provenance](THIRD_PARTY.md) and [MIT license](LICENSE)

Original OOPArts code is MIT licensed; vendored sources keep their own licenses.
See [THIRD_PARTY.md](THIRD_PARTY.md).
