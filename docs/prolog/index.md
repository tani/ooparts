# Documentation

[Project README](README.md)

- [User guide](MANUAL.md): term syntax, queries, lexical `let`, Lisp callbacks, DCGs, SLG, WAM and GC.
- [Prolog textual loader](PROLOG-LOADER.md): string/file/stream APIs, operators, directives and limits.
- [Builtin reference](BUILTINS.md): supported predicates, arithmetic and Lisp-friendly names.
- [Validation](VALIDATION.md): test coverage, stress tests and current limitations.
- [ISO compatibility](ISO-COMPATIBILITY.md): pinned upstream tests, deliberate differences and unresolved cases.
- [Historical native compiler ablation](NATIVE-ABLATION.md): measurements of the removed optimizer.
- [Historical SWI comparison](COMPETITIVE-BENCHMARKS.md): archived native-compiler results and reproduction.
- [Benchmarks](BENCHMARKS.md): measured performance, allocation profiles, bottlenecks and reproduction commands.
- [Type declaration experiment](TYPE-DECLARATIONS.md): SBCL measurements without algorithm changes.
- [Roadmap](ROADMAP.md): implementation status and planned improvements.
- [Changelog](CHANGELOG.md): release history.

Commands in these documents are run from the repository root. See the
[test layout](../../tests/prolog/README.md), [ISO layout](iso-runner.md) and
[benchmark layout](../../benchmarks/prolog/README.md). Runnable examples are in
[`examples/`](../../examples/prolog).

- [Development](DEVELOPMENT.md): package-inferred ASDF systems, Nix outputs and portability

- [Predicate implementation layers](PRIMITIVES.md): primitive, syntax, and derived library boundaries.
