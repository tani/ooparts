# Curses coverage

API reference: 379 unique non-extension routines from the ncurses routine index (SVr4/X/Open).
Definitions, observed function entry, and frozen behavior scenarios are separate metrics.

| Host | API defined | API exercised | Feature scenarios |
|---|---:|---:|---:|
| sbcl | 379/379 (100.00%) | 100.00% | 53/53 (100.00%) |
| ccl | 379/379 (100.00%) | 100.00% | 53/53 (100.00%) |
| clisp | 379/379 (100.00%) | 100.00% | 53/53 (100.00%) |
| ecl | 379/379 (100.00%) | 100.00% | 53/53 (100.00%) |
| mkcl | 379/379 (100.00%) | 100.00% | 53/53 (100.00%) |
| cmucl | 379/379 (100.00%) | 100.00% | 53/53 (100.00%) |
| clasp | 379/379 (100.00%) | 100.00% | 53/53 (100.00%) |
| abcl | 379/379 (100.00%) | 100.00% | 53/53 (100.00%) |

These percentages do not assert equivalence for all ncurses inputs, terminal capabilities,
Unicode versions, widgets, or OS signal behavior. Native PTY verification is recorded separately.
