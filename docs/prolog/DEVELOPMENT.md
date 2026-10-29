# Prolog development

Commands run from the repository root. The only explicit ASDF systems are
`ooparts` and `ooparts-tests`, both package-inferred systems. Library modules
live under `src/`; test modules live under `tests/`. A module's package name
matches its path relative to that root. Every module defines and enters its own
package; imports describe the dependency graph. No package has a nickname.

`src/prolog.lisp` reexports the selected interface in `src/prolog/api/public.lisp`.
Implementation interfaces remain in their provider packages. `api/state` owns
registries and configuration. Initialization dependencies explicitly install
execution providers before their consumers compile derived clauses.

Three boundaries break execution/compiler/adapter cycles without merging namespaces:

- `kernel/model` owns records and conditions.
- `kernel/instructions` owns WAM instruction and source-marker identities.
- `kernel/protocol` owns late execution hooks. Providers register their function
  symbols; dispatch resolves the current function cell to retain instrumentation.

The atom namespace is its own inferred module, `ooparts/prolog/atoms`. The text
CLI's source-evaluation namespace is `ooparts/prolog/script`. Neither requires
manual system/package registration. The primary ASDF file registers only the
external implementation-provided `SB-CLTL2` package used by continuations.

## Validation

```sh
sbcl --dynamic-space-size 2048 --control-stack-size 1 --script tools/test.lisp prolog
sbcl --script tools/prolog/observations.lisp
python3 tools/check-layout.py
```

With the checkout in ASDF's source registry:

```lisp
(require :asdf)
(asdf:load-system "ooparts-tests/prolog")
(uiop:symbol-call :ooparts-tests/prolog :run-tests)
```

See [test layout](../../tests/prolog/README.md), [ISO driver](iso-runner.md),
[benchmark layout](../../benchmarks/prolog/README.md) and the
[recorded validation](../testing.md). The unified root [flake](../../flake.nix)
provides `lib-prolog-<impl>`, `test-prolog-<impl>` and `repl-prolog-<impl>`
packages/apps for available implementations. `nix run .#prolog` starts the SBCL
text CLI; `nix run .#test-prolog-sbcl` runs its Lisp suite. Component and platform
restrictions are documented in the [project README](../../README.md).

Nix builds only the selected inferred component and restores both primary ASD
files after Nixpkgs' installation filter. Keeping the parent definitions permits
runtime inference without compiling unsupported sibling libraries.

## Source responsibilities and portability

| Directory | Responsibility |
|---|---|
| `src/prolog/api/` | Selected public API, predicate registry and state |
| `src/prolog/kernel/` | VM, instructions, trail, GC, SLG and exceptions |
| `src/prolog/syntax/` | Clause lowering, lexical/control source expansion and DCGs |
| `src/prolog/adapters/` | Graphs, host types, arithmetic, database and stream operations |
| `src/prolog/library/` | Protected predicates compiled from ordinary clauses |
| `src/prolog/text/` | Prolog lexer, reader, writer, loader and CLI |

Tests mirror these layers under `tests/prolog/`. Shared assertions and normalized
observations live under `support/`; `suite.lisp` aggregates them through imports.
Source-file moves require matching changes to the inferred package and consumers.

Prolog requires portable Common Lisp and ASDF 3.1 or later, without Quicklisp
dependencies. Prolog-only loading does not import the SBCL-only libraries.
Numeric text output fixes decimal radix and disables Lisp readable/radix syntax,
including CLISP's readable integer notation. Regression tests exercise bignums
and nondefault printer settings. The halt hook uses `uiop:quit`.

The lexical `let` bridge rejects globally special variables; SBCL uses declaration
introspection and other implementations use a compiled ANSI binding probe.
Worklist loops check termination before popping. Guarded VM evaluation binds
its result once. Instrumented dispatch resolves function cells explicitly, and
circular interactive answers use circle-aware printing. Profiling tools under
`benchmarks/prolog/` are SBCL-specific; the library and semantic suite are not.
