# Curry validation

The complete curried user environment was checked on Linux x86-64. Each row
runs the inferred curry suite, the shared framework's own suite, and a separate
fresh-process compilation of core macros and clients in one source file.

| Implementation | Curry checks | Framework checks | Same-unit compilation |
|---|---:|---:|---|
| SBCL 2.6.8 | 4,313 | 38 | Passed, zero warning conditions/flags |
| CCL 1.13 | 4,313 | 38 | Passed, zero warning conditions/flags |
| ECL 26.5.5 | 4,313 | 38 | Passed, zero warning conditions/flags |
| ABCL 1.9.3 | 4,313 | 38 | Passed, zero warning conditions/flags |
| CLISP 2.49.95+ | 4,313 | 38 | Passed, zero warning conditions/flags |
| MKCL 1.1.11 | 4,313 | 38 | Passed, zero warning conditions/flags |
| Clasp 3.0.1 | 4,313 | 38 | Passed, zero warning conditions/flags |
| CMUCL 21d, 32-bit under QEMU user-mode | 4,313 | 38 | Passed, zero warning conditions/flags |

[Machine-readable results](reports/matrix.json) record all 24 combinations.
The MKCL launcher uses the repository's existing GNU11 compiler bootstrap;
no external Lisp implementation or library is patched.

## What the counts mean

The suite checks every one of the 636 catalog entries for public export and a
callable wrapper, compares available native targets, and tests incomplete calls
without executing effectful zero-required-arity operations. It verifies the
alternative namespace's CL exports and function aliases. These interface checks
make up much of the total; the number is not a percentage of ANSI conformance or
an exhaustive functional test of every standard operation.

Behavioral regressions cover grouped and empty partial calls, all ordinary
lambda-list sections, native default binding and initialization order, rest-list
ownership, multiple values, declarations, local recursion, implicit blocks,
malformed definitions, CLOS dispatch and method combination, class accessors,
structure constructors/copiers/predicates/setters, read-only and disabled
functions, inherited accessors, condition readers, generalized places, standard
type aliases and the curried readtable's function-quote syntax.

Some native reader entry points can be absent or lazily installed by a host.
Tests distinguish this from wrapper availability; incomplete calls do not force
native lookup. Completed calls retain the host's native behavior and limitations.
Native compiler notes and style warnings in regression fixtures are distinct
from the explicitly checked warning-free same-unit compiler test.

## Aggregate and Nix checks

The complete existing library suite also passed on SBCL 2.6.8 with a 1 MiB
control stack, including curry, the shared framework, advice, Curses,
continuations, Prolog, readline, regexp and SAT. Existing SAT negative tests
intentionally print fatal API-usage diagnostics; the runner checks these cases
and exits successfully. The two aggregate compilation warnings originate from
existing continuation division-by-zero negative tests, not the curry compiler check.

The following were also checked:

- Layout, package ownership, documentation links and third-party inventories.
- Exact regeneration of the standard-function catalog and namespace files.
- Nix flake syntax and evaluation of all eight curry implementation recipes.
- Building and running `test-curry-sbcl` through Nix.
- Running `repl-curry-sbcl` through Nix, verifying its package selection,
  optional-argument definitions and `#'(lambda ...)` currying.

The existing OS/implementation CI matrix is retained. Curry is included in the
aggregate tests; generator and same-unit compiler checks run with aggregate Nix
checks. macOS and ARM were not executed locally in this validation.
