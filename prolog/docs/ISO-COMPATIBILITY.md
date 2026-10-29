# Bundled ISO Prolog validation

The repository contains an Apache-2.0 port of Logtalk's ISO examples: **782 test
definitions from 93 source files**, including disabled tests and alternate
conditional branches. Normal execution is offline and requires only Python 3 and
SBCL. Neither Logtalk nor SWI-Prolog is loaded by the runner.

This is a finite validation corpus, not a complete executable specification or an
ISO conformance certificate. The default native cons model remains available;
`:term-model :iso` adds strict list/compound and empty-list/atom distinctions.

## Strict term mode

```lisp
(make-database :term-model :iso)       ; opt in
(make-database :term-model :native)    ; default
```

`database-term-model` reports the immutable choice. `read_syntax` and
`write_syntax` still independently default to `lisp` in either term model;
loading Prolog text does not silently change them. Compiled databases and caches
cannot be switched between models, and there is no implicit conversion of Lisp
callback inputs or query results between them.

| Prolog term | Strict Lisp term |
|---|---|
| `f(a)` | `(f a)` |
| `[a,b]` | `($cons a ($cons b $nil))` |
| `[a|b]`, `'.'(a,b)` | `($cons a b)` |
| `[]`, `'[]'` | `$nil` |
| `nil` | ordinary atom `nil`, distinct from `$nil` |

`$cons` and `$nil` are exported from the `ooparts/prolog` and `prolog` facade. They are dedicated internal
symbols, not the ordinary Prolog atoms `'$cons'` and `'$nil'`. Term inspection
exposes their ISO names `.` and `[]`; Prolog output uses bracket lists or, with
`ignore_ops(true)`, explicit `'.'/2` applications. Lisp I/O uses the unescaped
spellings `$CONS` and `$NIL` (the same Lisp symbols as `$cons` and `$nil`).
Ordinary atom spelling and host-required escaping are preserved. In quoted Lisp
output, an ordinary colliding user atom is package-qualified, e.g.
`OOPARTS/PROLOG/ATOMS::$cons`, so it reads back distinctly.
Lisp source and callbacks must explicitly construct strict lists; raw Lisp
lists represent applications, and NIL is not an empty Prolog list in this mode.

The VM, graph copying and collector are shared. The standard library remains
ordinary clauses, compiled twice from one definition with explicit list
literals. Mode selection affects list construction/validation, text boundaries,
term inspection, KEYSORT pair validation and the selected shared library.
Undefined cyclic/STO behavior remains the existing rational-tree extension.
This is a strict **term model**, not a declaration that every Lisp extension has
been removed or that the finite test corpus proves full ISO conformance.

## License and provenance

`tests/iso/vendor/logtalk/` contains unmodified test sources, their provenance
notes, and the upstream LICENSE and NOTICE. The pinned upstream revision is
`e0f2576eef32aa5d5732a0d47531d0f62b9a31f1` of
[LogtalkDotOrg/logtalk3](https://github.com/LogtalkDotOrg/logtalk3).
The selected source files carry Apache-2.0 SPDX notices. Upstream's
`tests/prolog/NOTES.md` records contributions and reuse permissions.

`tests/iso/suite/` contains the checked-in plain Prolog port, its Apache-2.0
LICENSE/NOTICE, and `cases.json`. Original notices are retained and modifications
are identified. Ported cases are not relicensed as MIT. The independent
`harness.pl`, Python driver, worker and development converter use the project's
MIT license.

`upstream.json` records SHA-256 digests for every original and ported file.
Missing, changed, extra or symlinked files abort validation. Each case records
its original source, line, name, standard reference, upstream expectation,
strict expectation, options, conditions and any individual adaptation.

The Hodgson INRIA/standard-example archives and their downloader are no longer
used. No license-unclear Hodgson corpus is bundled. Earlier observations remain
historical records in `docs/VALIDATION.md` and git history.

## Running

```sh
python3 -m unittest discover -s tests/iso -p 'test_*.py' -v
python3 tests/iso/run.py --baseline tests/iso/expectations/baseline.json --strict --jobs 2
python3 tests/iso/run.py --filter predicates/read_term_3 --strict
python3 tests/iso/run.py --term-model iso --strict --jobs 2 --output iso-results-strict
```

`--sbcl` accepts an executable path; unit tests use `ISO_SBCL`. Each applicable
case gets a fresh SBCL process with a 1 MiB control stack, database and temporary
working directory. Both stream syntax flags are `prolog`; ordinary library use
still defaults to `lisp`. Five-second per-case timeouts, crashes, loading/setup
errors and missing/malformed protocol results are FAIL. They never count as
successful tests. The runner continues after a timeout.

`iso-results/report.json` retains every result, source hashes, expectations,
timings and diagnostics. The baseline rejects missing IDs and changed nonpassing
observations while allowing improvements to PASS. An exact, individually
explained native-model failure can be XFAIL; stale or unexpectedly passing
XFAILs require review. **A green baseline job does not mean ISO conformance.**
`--strict` returns nonzero while any FAIL remains. `--term-model iso` uses no
expected-difference entries and rejects a supplied nonempty expectations file;
all applicable definitions must actually pass. Its SKIPs use the same inventory
and applicability conditions as native mode.

## Port and applicability

All `iso_` definitions in the selected upstream revision are accounted for.
The other upstream prefixes (`lgt_`, `sics_`, `eddbali_`, `wg17_`, etc.) are not
part of this inventory; copied helper predicates are retained where needed.
The names alone do not establish that an example prescribes defined ISO behavior.

- Logtalk object declarations are removed. Goal-position `{Goal}` wrappers and
  fixture messages are lowered; braces inside data, lists and variable sharing
  are preserved. The checked-in `.pl` files need no import at execution time.
- Input/output fixtures are ordinary Prolog clauses using files and streams.
  Contents, bytes and unread tails are actually checked. Test output is separate
  from the result protocol. `clean_file/1` leaves deletion to the parent process's
  temporary-directory cleanup, since file deletion is not an ISO core predicate.
- `true`, `false`, postconditions, existential success, thrown balls, exact formal
  errors, variants and subsumption have separate checks. False expectations do
  not accept exceptions. Cleanup errors also fail the case.
- The `retract/1` examples that consume earlier clauses explicitly replay their
  recorded predecessors within the isolated worker.
- Logtalk's permissive alternative error patterns are narrowed to their reviewed
  standard first alternative. Both versions remain visible in `cases.json`.
- `iso_setof_3_17` is corrected to test both allowed relative variable orders
  inside the success branch. Upstream placed one order in an unreachable else
  branch after successful SETOF. The original source remains unchanged.
- `iso_read_term_3_05` requires a real `syntax_error` and accepts no success or
  other exception. Its unread-tail assertion is removed because ISO 8.14.1.1
  NOTE 2 leaves the number of input characters undefined on error. Reader
  behavior is unchanged; the original expectation remains recorded.
- Six upstream-disabled bitwise examples now execute against ooparts/prolog's documented
  implementation-defined choices (table below), with their upstream-disabled
  status and chosen values retained in the inventory.
- STO/cyclic-term examples are SKIP, including their nominally enabled branches:
  undefined ISO behavior does not impose new requirements on native extensions.
  False runtime applicability conditions are also SKIP, with the reason
  retained. They are not counted as passes.
- The one `deterministic` expectation checks exactly one answer. A portable ISO
  driver cannot inspect residual choice points; this is explicitly a weaker
  observation. Approximation is confined to explicit upstream `=~=` checks;
  other numerical equalities remain exact.

## Specification policy and observations

Defined ISO requirements take precedence. Implementation-defined,
implementation-dependent and undefined behavior are distinguished; existing
extensions are retained where compatible with defined ISO requirements.

The SBCL observations are:

| Term model | PASS | XFAIL | FAIL | SKIP | BLOCKED |
|---|---:|---:|---:|---:|---:|
| `native` (default) | 718 | 8 | 0 | 56 | 0 |
| `iso` | 726 | 0 | 0 | 56 | 0 |

The 56 skips comprise 45 STO definitions (23 example names, with alternate
branches), one finite-arity and five bounded-integer premises, and five inactive
conditional branches. The selected counterparts of those five branches execute.
Counts include source alternatives and must not be presented as 782 independent
executed obligations. Six PASS results are checks of implementation-defined
choices, not six additional ISO-mandated numerical answers. CI uses `--strict`.

The eight XFAILs retain native NIL spelling (two), list-cell FUNCTOR (one),
native-pair KEYSORT (one), canonical list output (one), and explicit `'.'/2`
versus native-list syntax (three).

The five former FAILs are resolved as follows:

| Cases | Resolution |
|---|---|
| `iso_op_3_10` (active branch) | Enforce the infix/postfix conflict required by ISO 8.14.3.3 l |
| `iso_op_3_11`, `iso_op_3_12` | Reject the native empty-list atom, including inside an operator-name list, as required by Cor.2 |
| `iso_put_byte_2_04` | Validate the byte type directly instead of first raising an integer type error (ISO 8.13.3.3 c) |
| `iso_read_term_3_05` | Require the syntax error without prescribing undefined consumed input (ISO 8.14.1.1 NOTE 2) |

### Implementation-defined bitwise results

Bit operations use Common Lisp's unbounded two's-complement interpretation.
Complement inverts the infinite signed bit sequence; left shift multiplies by a
power of two and right shift is arithmetic (sign-extending). These choices are
retained and documented, not changed to invent a single portable ISO answer.

| Enabled example | Expression | ooparts/prolog result |
|---|---|---:|
| `iso_bitwise_and_2_04` | `-10 /\ 12` | 4 |
| `iso_bitwise_complement_1_03` | `\(10)` | -11 |
| `iso_bitwise_left_shift_2_03` | `-16 << 2` | -64 |
| `iso_bitwise_or_2_04` | `-10 \/ 12` | -2 |
| `iso_bitwise_right_shift_2_03` | `-16 >> 2` | -4 |
| `iso_xor_2_03` | `xor(-10,12)` | -6 |

Normative references checked during analysis:
[ISO 1995 text](https://previewnorm.com/iso/ISO%20IEC%2013211-1-1995%20PDF.pdf),
[Cor.2 working text](https://www.complang.tuwien.ac.at/ulrich/iso-prolog/dtc2)
(the final ISO publication is linked there), and
[Cor.1 working text](https://www.complang.tuwien.ac.at/ulrich/iso-prolog/dtc1)
which also records the undefined stream state after a read error.

## Regeneration

Normal runs use only committed files. Optional development regeneration uses
SWI-Prolog as a reader/serializer for Logtalk syntax, not as a test oracle:

```sh
python3 tests/iso/tools/regenerate.py
# or: python3 tests/iso/tools/regenerate.py --swipl /path/to/swipl
```

This reads the bundled originals without network access, refuses changed source
pins, rebuilds the plain Prolog files and metadata, and refreshes port hashes.
Review converter changes and regenerated diffs together. Updating the upstream
revision or license notices requires an explicit source-pin review; regeneration
does not silently accept edited originals. `adaptations.json` describes the
boundary, and `expected-differences.json` lists the exact native-model exceptions.
