# Nix flake

The single root `flake.nix` (flake-parts) declares implementation and component
catalogs, then uses a local `mkRecipe` factory to produce records containing
`library`, `runtime`, `test`, `repl`, and `check`. Thin projections expose those
records as packages, apps, checks, development shells, and overlay aliases.

This declarative settings → recipe record → output projection organization uses
[`tani/nix-common-lisp` at `c27b1d6`](https://github.com/tani/nix-common-lisp/tree/c27b1d60e50543b370ddf0aa7433c65dd72b06fb)
as an organizational reference only, not as a dependency. All implementations
come from the locked `nixos-unstable` nixpkgs input; a variant exists only when
the selected platform provides an available, unbroken implementation.

The flake targets x86-64 Linux, ARM64 Linux and Apple Silicon macOS.
The selected unstable Nixpkgs has dropped Intel macOS (`x86_64-darwin`), so
that platform is not advertised by this flake.

```sh
nix develop
nix develop .#sbcl
nix build .#lib-all-sbcl
nix run .#test-all-sbcl
nix run .#repl-prolog-sbcl
nix run .#prolog -- --help
nix run .#sat vendor/satch/test/true.cnf
```

`nix develop` selects the default shell, which contains every available
implementation plus Python, a C toolchain and SWI-Prolog. `nix develop
.#<implementation>` selects one implementation. Both set
`CL_SOURCE_REGISTRY` to the checkout.

The locked ABCL derivation already selects OpenJDK 17; it does not accept a
`jdk` override argument. MKCL's Nix Lisp wrapper loads the existing GNU11
bootstrap before compiling ASDF and retains it in packaged runtimes. This is
compiler configuration, without patching the host or external libraries.

## Components and implementations

Components and the systems they cover:

| Component | Library system | Test system |
|---|---|---|
| `advice` | `ooparts/advice` | `ooparts-tests/advice` |
| `prolog` | `ooparts/prolog` | `ooparts-tests/prolog` |
| `continuation` | `ooparts/continuation` | `ooparts-tests/continuation` |
| `sat` | `ooparts/sat` | `ooparts-tests/sat` |
| `regexp` | `ooparts/regexp` | `ooparts-tests/regexp` |
| `sml` | `ooparts/sml` | `ooparts-tests/sml` |
| `all` | `ooparts` | `ooparts-tests` |

Implementations are whatever nixpkgs provides and supports on the selected
platform: SBCL, ECL, ABCL, CCL, CLISP, Clasp, CMUCL and MKCL. Every component is
offered for every available implementation, so MKCL gets `continuation` and
`all` recipes as well; its continuation support depends on the internal adapters
in `src/continuation/environment.lisp` and `src/continuation/runtime.lisp`.

## Outputs

Packages, apps and checks follow a `<prefix>-<component>-<implementation>`
scheme:

- `packages.lib-<component>-<implementation>` — compiled library and test
  systems (plus the Prolog or SAT CLI module where applicable).
- `packages.test-<component>-<implementation>` — binary that loads the test
  system and runs its suite.
- `packages.repl-<component>-<implementation>` — binary that loads the library
  and starts a REPL.
- `packages.default` — the default recipe's library. The default recipe is
  `all-sbcl` when available, then `prolog-sbcl`, then any defined recipe.
- `apps.test-<component>-<implementation>` and
  `apps.repl-<component>-<implementation>` — installed commands
  `ooparts-test` and `ooparts-repl`.
- `apps.prolog` and `apps.sat` — SBCL command-line launchers installed as
  `ooparts-prolog` and `ooparts-sat`.
- `apps.default` — the default recipe's REPL.
- `checks.test-<recipe>` — regression check for that recipe, including the
  continuation FASL and saved-core reload scripts where applicable. The flake
  currently exposes `test-all-<implementation>`,
  `test-curses-<implementation>`, and `test-readline-<implementation>` for each
  available implementation, plus `checks.layout`.
- `checks.layout` — runs `python3 tools/check-layout.py`.

The overlay adds each supported library and test system to the corresponding
Lisp package set and exports an `ooparts-<recipe>` wrapper around the recipe's
REPL.

## CI

[`.github/workflows/test.yml`](../.github/workflows/test.yml) is the consumer.
Its `sbcl` job runs the layout audit, the SAT zero-warning compile, the
aggregate test suite, continuation reload tests, SAT differential and proof
comparisons, the portable SAT path and both ISO profiles through `nix develop
.#sbcl`. Its `matrix` job evaluates `nix eval .#checks.<system>` for
`x86_64-linux`, `aarch64-linux` and `aarch64-darwin`, then the `test` job builds
each advertised check with `nix build`.

The presence of a Nix attribute is not evidence that its derivation built or
that the implementation passed. Report source-level checks separately from
actual `nix build` results.
