# OOPArts

Common Lisp libraries for delimited continuations, Prolog and SAT.

All library and test modules use ASDF's package-inferred systems. The only
explicit systems are `ooparts` and `ooparts-tests`. A module's package name
matches its path; public packages have no nicknames.

| Library | Loadable system and public package | Platform |
|---|---|---|
| [Continuation](docs/continuation/README.md) | `ooparts/continuation` | Portable Common Lisp |
| [Prolog](docs/prolog/README.md) | `ooparts/prolog` | Portable Common Lisp |
| [SAT](docs/sat/README.md) | `ooparts/sat` | Portable Common Lisp; native SBCL x86-64 fast path |

## Load and test

Register the checkout with ASDF, or put it in an existing source registry:

```lisp
(require "asdf")
(pushnew (truename "/path/to/ooparts/") asdf:*central-registry* :test #'equal)
(asdf:load-system "ooparts")
(asdf:test-system "ooparts")
;; Equivalent complete regression entry point:
(asdf:test-system "ooparts-tests")
```

Load an individual inferred system to use a library on its supported platform.
For example, `ooparts/prolog` does not load the other libraries or their dependencies.
See [portability](docs/portability.md) for reader-selected backends, host interfaces
and cross-implementation validation commands.

```lisp
(asdf:load-system "ooparts/continuation")
(ooparts/continuation:reset
  (+ 1 (ooparts/continuation:shift k
         (+ (funcall k 10) (funcall k 20)))))
;; => 32

(asdf:load-system "ooparts/prolog")
(ooparts/prolog:query '((= ?x 42)))

(asdf:load-system "ooparts/sat")
(ooparts/sat:solve-cnf '((1) (-2)))
;; => :SAT, #(1 -2), a statistics plist
```

From the repository root:

```sh
sbcl --dynamic-space-size 2048 --control-stack-size 1 --script tools/test.lisp
sbcl --script tools/test.lisp prolog
sbcl --script tools/test.lisp continuation
sbcl --script tools/test.lisp sat
python3 tools/check-layout.py
```

An individual test facade can also be loaded with
`(asdf:load-system "ooparts-tests/prolog")`, followed by
`(ooparts-tests/prolog:run-tests)`. The same pattern applies to the other two
libraries. See [testing](docs/testing.md) for proof checks, compiler diagnostics,
ISO observations, FASL/core reloads and verification limits.

## Performance

Warmed CPU milliseconds per query on the shared Prolog workload
(`benchmarks/prolog/competitive.pl`, identical source and search order in both
engines, every expected answer validated). 30 samples per case, `BENCH_BATCH=3`,
SBCL 2.5.4 vs SWI-Prolog 9.2.9 `-O`, aarch64-linux. `:auto` is the default
execution mode, which compiles eligible predicate groups to Common Lisp and keeps
the interpreted backend as the fallback oracle.

| Workload | `ooparts/prolog` `:auto` | SWI-Prolog `-O` | Ratio |
| --- | ---: | ---: | ---: |
| 8 queens, all solutions | 1.07 ms | 2.41 ms | 2.25x faster |
| Takeuchi (16,10,4) | 0.87 ms | 4.16 ms | 4.77x faster |
| Naive reverse, 1200 | 71.6 ms | 18.7 ms | 3.82x slower |
| Quicksort, 2000 | 6.18 ms | 3.75 ms | 1.65x slower |
| Graph, 1024 paths | 1.00 ms | 0.33 ms | 3.01x slower |
| Symbolic differentiation | 0.42 ms | 0.82 ms | 1.98x faster |

The interquartile spread of those samples stayed within 3.4% of every
`ooparts/prolog` median and within 0.3% of every SWI median, so the ratios are
stable rather than noise-bound. This is a reference, not a parity gate. Against
the same checkout's `:wam` oracle the six cases are 31.9x to 532.6x faster, each
completing on exactly one native attempt with no replay; the three workloads still
behind SWI need better data structures and first-argument fact indexing, not an
interpreter.

```sh
BENCH_BATCH=3 python3 benchmarks/prolog/compare.py --repeats 30 \
  --output build/prolog/swi-comparison.json
python3 benchmarks/prolog/jit-compare.py --repeats 30 --batch 3 \
  --output build/prolog/jit-comparison.json
```

See [native predicate specialization](docs/prolog/NATIVE-JIT.md) for the
two-tier execution contract, the budgets, per-workload allocation and cold
compile cost.

## Repository layout

| Directory | Contents |
|---|---|
| `src/<library>/` and `src/<library>.lisp` | Implementation packages and public facade |
| `tests/<library>/` and `tests/<library>.lisp` | Inferred regression modules and test facade |
| `docs/<library>/` | API, design and historical notes |
| `examples/<library>/` | Executable examples |
| `benchmarks/<library>/` | Reproducible drivers and identified historical results |
| `tools/<library>/` | CLI launchers, generators and external validation drivers |
| `vendor/` | Pinned upstream reference sources and test corpora |
| `licenses/` | Preserved license texts and attribution notices |
| `build/` | Ignored generated files, downloaded benchmark dependencies and fresh reports |

Package `ooparts/sat/runtime` lives in `src/sat/runtime.lisp`; package
`ooparts-tests/prolog/kernel/slg` lives in `tests/prolog/kernel/slg.lisp`.
Dependencies come from `uiop:define-package`, without serial component lists or
implementation files loading one another. Tool scripts invoke these systems.

## Nix

The single root `flake.nix` exposes component/implementation variants:

```sh
nix develop
nix build .#lib-all-sbcl
nix run .#test-all-sbcl
nix run .#repl-prolog-sbcl
nix run .#prolog -- --help
nix run .#sat -- vendor/satch/test/true.cnf
```

`lib-<component>-<implementation>`, `test-...` and `repl-...` follow the same
scheme. Components are `prolog`, `continuation`, `sat` and `all`. Variants
are exposed for implementations available on the
selected platform. MKCL currently exposes Prolog and SAT. The default package
selects the SBCL aggregate where available.

The default overlay adds each supported library and test system to the corresponding
Lisp package set and exports `ooparts-<component>-<implementation>` REPL wrappers.

## Licenses and provenance

Original OOPArts code is [MIT licensed](LICENSE). This does not replace the
licenses of vendored sources.
[THIRD_PARTY.md](THIRD_PARTY.md) and [third-party.json](third-party.json) record
imports, ports, native-interface references, design references and benchmark
dependencies separately, with preserved notices and pinned-source checksums.
