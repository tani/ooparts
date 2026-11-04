# ooparts/prolog

A stack-safe S-expression Prolog with a WAM-derived register machine, explicit
heap/trail management, DCGs, SLG tabling and a textual Prolog interface. Terms
retain Lisp cons/symbol identity, including cyclic rational trees. The public
API follows Lisp-native Prolog conventions; full Allegro compatibility and full
ISO conformance are not claimed.

The package and inferred system are `ooparts/prolog`, without a nickname.
Original code is MIT licensed. The Logtalk-derived ISO corpus is separately
licensed under Apache-2.0; see [the provenance register](../../THIRD_PARTY.md).

## Load and use

```lisp
(require :asdf)
(pushnew (truename "/path/to/ooparts/") asdf:*central-registry* :test #'equal)
(asdf:load-system "ooparts/prolog")

(ooparts/prolog:<-- (parent alice bob))
(ooparts/prolog:<- (ancestor ?x ?y) (parent ?x ?y))
(ooparts/prolog:<- (ancestor ?x ?y) (parent ?x ?z) (ancestor ?z ?y))
(ooparts/prolog:query '((ancestor alice ?who)))
;; => (((?WHO . BOB)))
```

`<--` replaces a predicate's user clauses; `<-` appends a clause. A successful
ground query returns a list containing NIL, while failure returns NIL. Variables
are symbols whose names start with `?`; bare `?` introduces a fresh anonymous
variable. Search preserves clause order, sharing, cuts and logical update view.

```lisp
(let ((offset 10))
  (ooparts/prolog:prolog
    (lisp ?n (+ offset 1))
    (lispp (> ?n 10))
    (lisp (print ?n))))
```

Host forms have lexical scope inside the syntax macros. Runtime terms are data,
not captured Lisp environments. Use the explicit textual loader for Prolog text:

```lisp
(ooparts/prolog:load-prolog-string "parent(alice,bob).")
(ooparts/prolog:query (ooparts/prolog:parse-prolog-string "parent(alice,X)."))
```

## State, execution and interfaces

A database owns user clauses, stream state and term-model configuration. Bind
`*database*` to `(make-database)` for independent state. Use `make-query`,
`next-solution` and `close-query` for explicit cursors; close them on every exit.
`query-statistics` exposes instructions, explicit stack/heap use, GC counters and
the native-execution counters `:native-calls` and `:native-deoptimizations`.
`table`/`untable` control SLG predicates; `tnot` supports well-founded negation.
Databases default to `:execution-mode :auto`, which compiles eligible predicate
groups to Common Lisp; see [native specialization](NATIVE-JIT.md).
See the [manual](MANUAL.md) for complete conventions and resource ownership.

The default native term model retains Lisp cons/symbol terms. The explicit
`:term-model :iso` profile uses the dedicated list/atom distinctions documented in
[ISO compatibility](ISO-COMPATIBILITY.md). Text syntax and semantic profiles
are separate settings. Readers parse without Lisp EVAL.

## Modules

Each implementation file owns an inferred package of the same path:

| Directory | Responsibility |
|---|---|
| `src/prolog/kernel/` | Term/data model, instructions, VM, trail, GC and SLG |
| `src/prolog/syntax/` | Lisp-facing goal expansion, control/host syntax, WAM compilation and DCGs |
| `src/prolog/adapters/` | Stateful primitives and typed/validated boundary operations |
| `src/prolog/library/` | Predicates expressible as ordinary protected clauses |
| `src/prolog/text/` | Text lexer, reader, writer, loader and CLI |
| `src/prolog/api/` | Registry, public state and selected exports |

[src/prolog.lisp](../../src/prolog.lisp) is the real public facade and reexports
provider symbols without renaming them. The atom and CLI script namespaces also
have their own inferred package files. Internal APIs are not public exports.

## Command line and Nix

```sh
sbcl --script tools/prolog/cli.lisp --help
sbcl --script tools/prolog/cli.lisp --lisp examples/prolog/append.lisp
nix run .#prolog -- --help
nix run .#repl-prolog-sbcl
nix run .#test-prolog-sbcl
```

The CLI is the inferred `ooparts/prolog/text/cli` module; it no longer requires
an explicit ASDF program system. All Nix components share the root flake.
Library and test variants are offered for implementations available on each
platform, using `lib-prolog-<implementation>` and `test-prolog-<implementation>`.

## Performance

Recorded 2026-10-30. Warmed CPU milliseconds per query on
`benchmarks/prolog/competitive.pl`, with identical source and search order in both
engines: 30 samples, `BENCH_BATCH=3`,
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

[BENCHMARKS.md](BENCHMARKS.md) is the canonical measurement document, with
allocation profiles, bottlenecks, full precision and reproduction commands.
These figures retain their recorded runtime and hardware; they are not new
measurements of the current source or Nix toolchain.

## Validation

```sh
sbcl --dynamic-space-size 2048 --control-stack-size 1 --script tools/test.lisp prolog
ISO_SBCL=sbcl python3 -m unittest discover -s tests/prolog/iso -p 'test_*.py' -v
python3 tools/prolog/iso/run.py --baseline tests/prolog/iso/expectations/baseline.json --strict --jobs 2
python3 tools/prolog/iso/run.py --term-model iso --strict --jobs 2 --output build/prolog/iso-strict
```

The recorded SBCL regression run has 6027 checks, including 389
native-specializer and 110 explicit-stack checks, plus deep recursion, cyclic
terms, forced GC, callback lifetime and SLG behavior. The pinned ISO
inventory has 782 cases: native mode records 718 PASS, 56 SKIP and eight exact
expected differences; the strict term-model profile records 726 PASS and 56
SKIP. No unexpected failures or baseline regressions are accepted. A skip is
not a passed conformance case. See [testing](../testing.md) and
[the ISO runner guide](iso-runner.md) for scope and applicability.

Historical speed reports retain their original source/measurement metadata.
They are not automatically measurements of the refactored source.

Further documentation: [manual](MANUAL.md), [builtins](BUILTINS.md),
[primitive placement](PRIMITIVES.md), [text loading](PROLOG-LOADER.md),
[development](DEVELOPMENT.md), and [historical benchmarks](../../benchmarks/prolog/README.md).
