# ooparts/prolog documentation

Every document under `docs/prolog/`, in reading order. Commands shown in these
documents run from the repository root.

## Reference

- [Library entry point](README.md): load, query, module map, command line and the
  recorded validation summary.
- [User guide](MANUAL.md): terms, queries, lexical `let`, Lisp callbacks, DCGs,
  SLG, WAM execution and GC.
- [Builtin reference](BUILTINS.md): public indicators, arithmetic, ordering,
  term I/O and reader configuration.
- [Prolog textual loader](PROLOG-LOADER.md): string/file/stream APIs, operators,
  directives and parser limits.
- [ISO compatibility](ISO-COMPATIBILITY.md): pinned upstream corpus, strict term
  mode, deliberate differences and observations.
- [ISO runner](iso-runner.md): offline worker layout, expectations and run commands.
- [Type declaration experiment](TYPE-DECLARATIONS.md): recorded SBCL experiment
  at a pinned revision; measurements are historical, not current performance.
- [Native predicate specialization](NATIVE-JIT.md): `:auto` policy, eligibility,
  budgets, the explicit-stack tier and controls.
- [Benchmarks](BENCHMARKS.md): canonical measurement tables, allocation profiles
  and reproduction commands.
- [Validation](VALIDATION.md): test coverage, stress tests and current limitations.
- [Predicate implementation layers](PRIMITIVES.md): primitive, syntax and derived
  library boundaries.
- [Development](DEVELOPMENT.md): package-inferred ASDF systems, Nix outputs and
  portability.
- [Roadmap](ROADMAP.md): implementation status and planned improvements.
- [Changelog](CHANGELOG.md): release history.

## Historical records

- [Native compiler ablation](NATIVE-ABLATION.md): measurements of a superseded
  optimizer revision.
- [SWI comparison](COMPETITIVE-BENCHMARKS.md): archived native-compiler results
  and reproduction.

## Around the library

- [Project documentation index](../README.md): cross-library overview of the
  monorepo.
- [Test layout](../../tests/prolog/README.md): suite modules and Lisp runner.
- [Benchmark layout](../../benchmarks/prolog/README.md): drivers, artifacts and
  reproduction entry points.
- [Testing policy](../testing.md): aggregate command matrix.
- [Runnable examples](../../examples/prolog): Lisp sources for the CLI and embedding.
