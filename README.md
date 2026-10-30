# OOPArts

Common Lisp libraries for delimited continuations, Prolog, SAT and POSIX extended
regular expressions. All modules use ASDF package-inferred systems; the only
explicit systems are `ooparts` and `ooparts-tests`. A module's package name
matches its path, and public packages have no nicknames.

| Library | System and public package | Platform | Documentation |
|---|---|---|---|
| Continuation | `ooparts/continuation` | Portable Common Lisp | [docs](docs/continuation/README.md) |
| Prolog | `ooparts/prolog` | Portable Common Lisp | [docs](docs/prolog/README.md) |
| SAT | `ooparts/sat` | Portable Common Lisp; native SBCL x86-64 fast path | [docs](docs/sat/README.md) |
| regexp | `ooparts/regexp` | Portable Common Lisp | [docs](docs/regexp/README.md) |

Register the checkout with ASDF, then load any library by its system name:

```lisp
(asdf:load-system "ooparts/prolog")
(ooparts/prolog:<-- (parent alice bob))
(ooparts/prolog:query '((parent alice ?who)))
;; => (((?WHO . BOB)))
```

See the [per-library documentation](docs/README.md) for more examples.

## Performance

Warmed CPU milliseconds per query on `benchmarks/prolog/competitive.pl`, with
identical source and search order in both engines: 30 samples, `BENCH_BATCH=3`,
SBCL 2.5.4 vs SWI-Prolog 9.2.9 `-O`, aarch64-linux. `:auto` is the default
execution mode; the ratios are a reference, not a parity gate.

| Workload | `ooparts/prolog` `:auto` | SWI-Prolog `-O` | Ratio |
| --- | ---: | ---: | ---: |
| 8 queens, all solutions | 1.07 ms | 2.41 ms | 2.25x faster |
| Takeuchi (16,10,4) | 0.87 ms | 4.16 ms | 4.77x faster |
| Naive reverse, 1200 | 71.6 ms | 18.7 ms | 3.82x slower |
| Quicksort, 2000 | 6.18 ms | 3.75 ms | 1.65x slower |
| Graph, 1024 paths | 1.00 ms | 0.33 ms | 3.01x slower |
| Symbolic differentiation | 0.42 ms | 0.82 ms | 1.98x faster |

Reproduce commands and allocation figures: [Prolog benchmarks](docs/prolog/BENCHMARKS.md).

## Documentation
- [Documentation index](docs/README.md)
- [Continuation](docs/continuation/README.md), [Prolog](docs/prolog/README.md), [SAT](docs/sat/README.md), [regexp](docs/regexp/README.md)
- [Testing](docs/testing.md), [portability](docs/portability.md), [Nix](docs/nix.md), [layout](docs/layout.md)
- [Third-party provenance](THIRD_PARTY.md) and [MIT license](LICENSE)

Original OOPArts code is MIT licensed; vendored sources keep their own licenses, see [THIRD_PARTY.md](THIRD_PARTY.md).
