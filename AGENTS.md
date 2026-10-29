# Working on OOPArts

- Define only the two primary package-inferred systems, `ooparts` and
  `ooparts-tests`. Library files belong in `src/`; regression modules belong in
  `tests/`. Each file owns its matching `ooparts/...` or `ooparts-tests/...`
  package, defined with `uiop:define-package`. Do not add package nicknames.
- Public entry files are `src/<library>.lisp`; matching test facades are
  `tests/<library>.lisp`. Declare imports rather than loading implementation
  files or relying on implicit load order.
- Write documentation in Markdown, using TeX notation for mathematics.
  Keep documentation, comments and docstrings in English. Update examples,
  tooling paths and the root Nix flake when moving files.
- Keep tools, examples and benchmarks under their library's common directory
  conventions. Generated/transient output belongs in ignored `build/`.
- Preserve upstream copyright/license notices. Register imports and ports in
  `third-party.json`, separately from references and optional external tools.
  Keep pinned vendor inventories intact or explicitly update their provenance.
- Run `python3 tools/check-layout.py` and the relevant inferred regression
  suites. SAT changes also require the compiler audit, differential cases and
  proof comparison. Continuation changes require FASL/core reload checks.
- Keep all libraries portable. Use reader conditionals for native fast paths
  and retain the portable SAT backend as an independently tested implementation.
  Declare portability dependencies in packages and the unified Nix flake.
