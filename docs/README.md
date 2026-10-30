# Documentation

Start with the [root README](../README.md) for the system names and a quick
start. This page indexes the detailed documentation.

## Libraries

| Library | Documentation | Scope |
|---|---|---|
| Continuation | [docs/continuation/README.md](continuation/README.md) | Single-prompt `shift`/`reset`, capture and reinstatement semantics |
| Prolog | [docs/prolog/README.md](prolog/README.md) | Stack-safe S-expression Prolog, DCGs, tabling, WAM-derived execution |
| SAT | [docs/sat/README.md](sat/README.md) | Translated SATCH solver with resource-managed storage |
| regexp | [docs/regexp/README.md](regexp/README.md) | POSIX.1-2024 extended regular expressions in portable Common Lisp |

Additional per-library material sits beside those files, for example
[continuation semantics](continuation/semantics.md),
[Prolog manual](prolog/MANUAL.md) and [built-ins](prolog/BUILTINS.md), and
[SAT testing notes](sat/testing.md).

## Cross-cutting guides

- [Testing and recorded validation](testing.md) — test commands, per-component
  suites, compiler audits and recorded results.
- [Portability](portability.md) — backend selection, host adapters and
  per-implementation launchers.
- [Nix flake](nix.md) — packages, apps, checks, dev shells and how CI consumes
  them.
- [Repository layout](layout.md) — directory conventions and the correspondence
  between paths, packages and inferred systems.

## Validation and provenance

- [THIRD_PARTY.md](../THIRD_PARTY.md) records imports, ports, references and
  benchmark dependencies; `third-party.json` is its machine-readable form.
- [LICENSE](../LICENSE) covers original OOPArts code; [licenses/](../licenses)
  preserves upstream notices.
- Per-library validation detail: [Prolog validation](prolog/VALIDATION.md),
  [SAT testing notes](sat/testing.md), and the regression sections of the
  continuation and regexp READMEs. Aggregate commands and counts are in
  [testing](testing.md).
