# Repository layout

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

## Package-inferred systems

Library and test modules are inferred from their package declarations; the only
explicit systems are `ooparts` and `ooparts-tests`. Package names correspond to
paths, and a facade file names the system's public package:

- `src/<library>.lisp` and `src/<library>/` belong to system
  `ooparts/<library>`; for example package `ooparts/sat/runtime` lives in
  `src/sat/runtime.lisp`.
- `tests/<library>.lisp` and `tests/<library>/` belong to system
  `ooparts-tests/<library>`; for example package `ooparts-tests/prolog/kernel/slg`
  lives in `tests/prolog/kernel/slg.lisp`.

Dependencies come from `uiop:define-package`; there are no serial component
lists in an `.asd` file, and implementation files never load one another. Tool
scripts and tests load the systems and call their exported entry points. A
library's public package has no nickname.
