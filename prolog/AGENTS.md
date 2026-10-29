# Working on ooparts/prolog

- Preserve the Lisp-native cons/rational-tree data model and the existing public API.
- Put predicates definable from existing goals in `src/library/standard-library.lisp` as
  ordinary clauses. Do not add a VM instruction just to accelerate a library wrapper.
- Keep executable source forms (`let`, host callbacks, transparent control) in
  the syntax modules. Runtime Prolog terms do not capture Lisp lexical environments.
- Add genuinely stateful operations to the appropriate adapter module; use small
  private `%` boundary operations when validation or database access is unavoidable.
- Register public primitives, syntax, and derived predicates separately. Protect
  all three layers, including aliases, against modification. `clear-database`
  clears user state and must preserve the shared base library.
- Preserve error class, argument validation order, public error context, answer
  order, variable sharing, rational trees, cut scope, and logical update view.
- Use `uiop:define-package`; enter that exact package with `in-package`. Each
  module owns its definitions and explicitly imports/exports its interfaces.
  Select public symbols in `src/api/public.lisp`. Aggregate that interface with
  `:use-reexport` in `src/api/package.lisp`, which alone has the `ooparts/prolog` and `prolog` nicknames.
  Break execution cycles through the model, instruction vocabulary, and explicit
  late hooks rather than defining implementation functions in another package.
- For predicate/compiler changes, run `tests/run.lisp` with a 1 MiB control stack.
  Compare `tests/support/derived-observations.lisp` with the reference revision when changing
  derived definitions. Include cyclic terms, callbacks, SLG, and forced GC where relevant.
- Document conditional retention of adapters in `docs/PRIMITIVES.md`; distinguish
  semantic necessities from optimized or compatibility-preserving implementations.

- Keep source responsibilities in `src/api/`, `src/kernel/`, `src/syntax/`,
  `src/adapters/`, `src/library/`, and `src/prolog/`. Dependency package names must match
  `ooparts/prolog/src/<layer>/<file>`. Implementation namespaces are distinct. Match package dependencies to the
  actual interfaces and initialization requirements; internal names are not facade API.

- FUNCTOR, ARG and UNIV interpret nonempty proper lists as symbol-name plus finite
  arguments, matching call name/arity. Reject open/improper/cyclic outer spines;
  retain arbitrary graphs inside arguments. Zero-arity construction yields atoms.

- Keep the Prolog textual interface in `src/prolog/`; parse without Lisp EVAL.
  Reader syntax marks are transient and must not change the native cons term model.
