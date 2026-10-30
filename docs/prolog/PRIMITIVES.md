# Predicate implementation layers

The public inventory contains **128 predicate indicators**, plus seven aliases:
**74 public runtime primitives/adapters**, **8 compiler forms**, and **46 derived
predicates**. Five private adapter operations and three private library helpers
are excluded. This is a separation of responsibilities, not an ISO conformance
claim or a claim of mathematical minimality.

## P1: protected shared library

`src/prolog/library/standard-library.lisp` contains ordinary clauses compiled by the same compiler
as user programs. `resolve-code` falls back to this shared base after looking in
the user database. Library predicates are not copied into each database and do
not appear in `current_predicate/1`, which continues to enumerate user definitions.
`clear-database` leaves the base library intact. Modification and clause-access
checks protect the entire public namespace, including aliases and private helpers.

`current_predicate/1` remains a database adapter. After argument validation, a
bound name and arity use the existing predicate hash table directly. Partial
indicators still enumerate in database order. Generated atoms that bridge Lisp
symbols by spelling retain enumeration to preserve all matches and their order.
The lookup reads current database state without a cache, including declaration-only
procedures and later assertion or abolition.

The P1 definitions are `nonvar/1`, `number/1`, `callable/1`, `ground/1`,
`once/1`, `repeat/0`, `\+/1`, `\=/2`, and `\==/2`. There is no special repeat VM
instruction. Calls to derived aliases go through normal predicate resolution.

**Conditional retention:** `atomic/1` accepts all Common Lisp numbers, including
ratios and complex numbers, while `number/1` accepts integers and floats. Defining
it as atom-or-number would change the API. Using a host callback instead would
also lose support inside SLG generators, where callbacks are disallowed. It
therefore remains a small adapter until a broader numeric type primitive is justified.

`once` and negation containing lexical Lisp callbacks keep a source expansion:
callback objects are executable compiler input, not first-class Prolog terms.
Their ordinary term forms use library clauses. Source-time callable validation
is retained, including the original exception context. Cuts inside a called goal
remain opaque; cuts in conjunction/disjunction remain transparent to their clause.

## P2: thin adapters and ordinary wrappers

The following predicates now use library clauses:

| Family | Derived indicators |
| --- | --- |
| Default options | `open/3`, `close/1` |
| Current-stream I/O | `get_char/1`, `get_code/1`, `peek_char/1`, `peek_code/1`, `put_char/1`, `put_code/1`, `get_byte/1`, `peek_byte/1`, `put_byte/1` |
| Other defaults | `flush_output/0`, `at_end_of_stream/0`, `halt/0` |
| Newline | `nl/0`, `nl/1` |
| Atom relations | `atom_length/2`, `atom_chars/2`, `sub_atom/5` |
| Number relations | `number_chars/2` |

Character conversion uses `char_code/2` and a shared Prolog list relation. The
input/output direction is selected before traversing the list, preserving output
variables and open output tails. For `number_chars/2`, a ground character list
selects parsing even when the number is already instantiated; partial lists
retain generation behavior. `number_codes/2` uses the existing list-validation
boundary to make the same distinction. `sub_atom/5` uses two `atom_concat/3` calls and
length relations, preserving before-then-length enumeration order.

Private checks `%output_nonnegative/1`, `%chars_arguments/3`, and
`%sub_atom_arguments/5` retain validation order and errors for improper/cyclic
lists, partial inputs, negative offsets, and invalid characters. They perform no
relation enumeration. Removing these checks would silently turn some exceptions
into failure or permit modes the previous implementation rejected.

Explicit-stream I/O, EOF state, nonseekable lookahead, atom interning, numeric
parsing/printing, and arithmetic evaluation remain host adapters. Code/byte I/O
is retained separately to preserve EOF and stream-type validation. PUT_BYTE
requires an integer in 0..255 and reports `type_error(byte, Culprit)` for all
other nonvariable values, retaining instantiation errors and public context.

An adapter wrapper marks its public error context. This context is saved/restored
with continuations, choice points, and exception snapshots, so private checks do
not expose helper names and later unrelated goals get their own contexts.
Invalid current-stream arguments and invalid stream/alias values produce domain
errors; `stream_property/2` requires a stream rather than accepting aliases.
OPEN reports invalid option names in the `stream_option` domain. Predicate
indicator and CLAUSE body checks run before enumeration, including empty lookup
results. Runtime goal conversion reports the whole converted goal as the culprit
of a callable type error, before any goal side effects can run.

## P3: copies, updates, and collection

`copy_term/2` is the singleton result of `findall/3`; internal `iso-copy` remains
the iterative graph-copy operation for collected solutions, exceptions, and
other runtime work. Tests cover cycles, fresh variables, and repeated aliases.
This derived definition may allocate more than the previous direct adapter.

`retractall/1` ensures the dynamic predicate exists, then exhausts head deletions
with a failure-driven library loop. The private `%ensure_dynamic/1` preserves
observable empty predicate registration; `%retract_head/1` reuses the existing
snapshot deletion enumerator without exposing or inspecting clause bodies.
Head-only access is required because Lisp callback bodies cannot be represented
as ordinary Prolog terms. Bindings are rolled back while deletions persist.
Existing calls retain immutable clause/code snapshots.

`findall/3` and `bagof/3` retain the child-query collection boundary. For `bagof`,
free-variable handling, variant grouping (`iso-group-answers`), and result
construction (`iso-bagof-results`) are separate functions. Group keys are compared
with a variable bijection and their aliases aligned before collecting templates.
The grouping has not been replaced by ordinary equality or a superficial Prolog
list grouping operation.

## P4: source organization and kernel boundary

| Directory / module | Responsibility |
| --- | --- |
| `kernel/engine`, `kernel/wam`, `kernel/gc`, `kernel/slg` | Bindings, trail, choice points, execution, GC, tabling |
| `kernel/model`, `kernel/instructions`, `kernel/protocol` | Record types, instruction identities, late execution interfaces |
| `kernel/runtime` | Meta-call entry, continuation handling, exceptions |
| `syntax/compiler`, `syntax/wam-compiler` | Clause compilation and lowering |
| `syntax/control-syntax` | Conjunction/disjunction/if, lexical meta-form fallback |
| `syntax/let-syntax` | Lisp lexical cells and `let` expansion |
| `syntax/host-syntax`, `syntax/dcg` | Host callback construction and DCGs |
| `api/package`, `api/public`, `api/api`, `api/registry`, `api/state` | Public package/macros and predicate namespaces/inventory |
| `adapters/term-ops` | Graph inspection, copying, identity, checked unification |
| `adapters/arithmetic`, `adapters/adapter` | Numeric evaluation, type/atom/flag boundaries |
| `adapters/dynamic`, `adapters/collection`, `adapters/streams` | Database updates, answer collection, stream state |
| `adapters/builtins` | Runtime dispatch and primitive/syntax registration |
| `library/standard-library` | Protected ordinary Prolog clauses |

The irreducible execution boundary consists of binding/trail operations,
choice-point control and cut, runtime goal entry, exception snapshots, and table
scheduling. Graph inspection, host types, symbols, streams, flags, and database
updates are host/state boundaries. The implementation does not equate all of these
with special WAM instructions. `let` has no WAM primitive: it expands into the
existing Lisp bridge and lexical getter/setter closures.

`builtin-predicate-inventory` accepts `:kind :all` (default), `:primitive`,
`:syntax`, or `:derived`. The eight syntax indicators are `!/0`, `,/2`, `->/2`,
`;/2`, `=/2`, `true/0`, `fail/0`, and `false/0`; they remain available to meta-call
through runtime entry. Punctuation aliases keep their previous meanings.

## Validation (historical records)

- At that historical revision, SBCL 2.2.9 and CLISP 2.49.93+ passed the complete
  suite's **4,324 checks**, including the existing
  100,000-step tail-call and 10,000-token DCG checks, with a **1 MiB control stack** on SBCL.
- New tests cover registry separation/protection, clearing databases, repeat,
  caller cut scope, failed partial unification, cyclic copies, character conversion
  modes, substring ordering, dynamic rules/callbacks, SLG, and context restoration.
- `tests/support/derived-observations.lisp` produces identical normalized observations
  against `3504d947` and this branch, including solutions, variable aliases,
  cyclic graph shape, error terms, answer order, EOF, and output effects.
- Other Lisp implementations have not been run locally. The multi-implementation
  Nix/CI configuration remains the verification mechanism for the full platform matrix.
- These finite checks are regression evidence, not a universal equivalence proof.

To reproduce the comparison, run the observation script once per checkout and
compare its stdout. Loading/compilation messages are suppressed by the script:

```sh
OOPARTS_ROOT=/path/to/reference sbcl --script tools/prolog/observations.lisp > before.txt
OOPARTS_ROOT=/path/to/current sbcl --script tools/prolog/observations.lisp > after.txt
diff -u before.txt after.txt
```

## Implementation packages

The current SBCL suite passes 6027 Prolog checks, including 389
native-specializer checks, 110 explicit-stack checks, and package ownership and
facade isolation checks. The aggregate `all` run additionally reports 5650 regexp
checks, SAT API 40, numeric/representation boundaries 51, Lisp interface 475
(including 96 exhaustive-oracle cases) and arena storage 69. Earlier experiment
counts below describe their revisions.

The package refactoring uses `uiop:define-package` and matching `in-package`
forms in source and test modules. Public `ooparts/prolog:` names are selective reexports
from their providers through `src/prolog/api/public.lisp`. The final
`src/prolog.lisp` uses `:use-reexport` to aggregate that selected interface
without package nicknames. Internal functions are owned by their modules;
old `ooparts/prolog::` internal references have been updated in tests, examples, and
benchmarks. See [Development](DEVELOPMENT.md) for cycle boundaries and dispatch costs.

## Cons-model operations and term I/O

`term-relations.lisp` owns FUNCTOR, ARG, UNIV, COMPARE, SORT and KEYSORT.
**Retention:** finite application decomposition/construction and dereferencing variable
identity require the host boundary. Sorting accesses variable and opaque Lisp
identity through the same comparator; it copies only the input list spine.
The four order comparisons and SETOF remain ordinary clauses over COMPARE,
BAGOF and SORT. SETOF deliberately preserves BAGOF group encounter order.
ISO floats precede integers; finite native applications compare by arity, functor
name, then argument terms. Non-ISO Lisp values occupy disjoint extension classes
so mixed comparisons remain transitive. Comparison and traversal remain iterative.

`term-io.lisp` owns explicit-stream READ_TERM/WRITE_TERM and database-local
operator/conversion tables. **Retention:** these operations access host streams,
reader/printer state and persistent database configuration. All read/write
convenience forms use ordinary clauses, with public exception contexts preserved.
READ_TERM and WRITE_TERM dispatch independently on the database-local
`read_syntax` and `write_syntax` flags (each `lisp` by default, or `prolog`).
The Prolog paths use `src/prolog/text/reader.lisp` and `src/prolog/text/writer.lisp`.
The adapter owns conversion to fresh managed VM variables, atom-name bridging,
stream/EOF state and option validation/unification. The iterative writer owns
Prolog quoting, operator precedence and variable spelling. These stream and
configuration boundaries require an adapter; no new execution engine is added.
The accepted format and its limits are specified in [BUILTINS.md](BUILTINS.md).
No new VM instruction, term tag, or public Lisp export is introduced.

## Textual loader boundary

The five Lisp text APIs are owned by `src/prolog/text/reader.lisp` and
`src/prolog/text/loader.lisp`, with lexing in `src/prolog/text/lexer.lisp`. They translate
source syntax into existing cons terms and compiler input. Load-time declarations
remain at this boundary; the VM has no new instruction or compound-term tag.
The OP and character-conversion adapters supply database-local reader state.
OP validates the entire name list before changing state: native NIL (the textual
empty-list atom), `[]`, `{}`, and comma restrictions apply at this boundary.
Positive-priority infix and postfix definitions cannot coexist. Redefinition and
priority-zero removal operate on the prefix/infix/postfix group, preserving the
independent prefix definition when an infix definition changes. These checks
remain in the stateful adapter; no VM instruction or term-model change is needed.
READ/READ_TERM and WRITE predicates can select Prolog syntax through the term-I/O
adapter; both default to Lisp syntax. The writer preserves the native cons mapping
and reports cycles or unrepresentable Lisp objects explicitly.

## Predicate execution

All Prolog predicates execute through the portable WAM, which remains the
authoritative interpreter. On top of it, `ooparts/prolog` specializes eligible
pure predicate groups into compiled Common Lisp: `:execution-mode :auto` (the
default) compiles and uses them, `:wam` selects the interpreted oracle per
database, and `OOPARTS_PROLOG_DISABLE_NATIVE=1` disables compilation
process-wide. Compiled groups run on a direct tier bounded by logical depth 256
and continue deep semidet recursion on an explicit-stack tier over a heap arena
bounded at 1,048,576 slots; a depth promotion reuses the same attempt and counts
once, and only a real bound failure is replayed on the WAM. `findall/3` and
`bagof/3` use the child-query collection adapter; returned lists follow the
database's immutable term model.

`query-statistics` reports WAM execution, ownership GC and SLG counters, plus
`:native-calls` (a native attempt that succeeded or failed logically) and
`:native-deoptimizations` (attempts privately aborted and replayed on the WAM).
See [NATIVE-JIT.md](NATIVE-JIT.md) for eligibility, budgets and the atomic-commit
contract.

## Prolog source procedure properties

The textual loader records ISO static/private defaults separately from Lisp-native
clause definitions. The dynamic adapter enforces source protection for assertion,
retraction, abolition and reflection. DYNAMIC declarations permit updates and
inspection. DYNAMIC, MULTIFILE and DISCONTIGUOUS declarations create empty
procedures immediately; source compilation and the isolated ISO runner use the
same property marker. These are database metadata operations, not VM instructions.

## Term model boundary

Databases fix `:term-model :native` (default) or `:iso` at construction. Both
share the cons graph VM, unification and GC. Strict lists use explicit
`($cons Head Tail)` applications and `$nil`; their public Prolog names remain
`'.'/2` and `[]`. Dedicated symbols prevent collision with user atoms of the
same Lisp spelling. List adapters are semantically necessary to distinguish
list spines from application argument spines; their construction/validation
functions select the database's model. They are not additional VM opcodes.

The protected standard library has one clause source with explicit list literals
and two shared compilations. Query construction and cursor resumption bind the
correct database/model, including callbacks, collectors and SLG children. Native
mode retains its original list/pair behavior and observations. Strict KEYSORT
validates `Key-Value` compounds and sorts by the key. DCG and host syntax select
model-specific list lowering while preserving lexical callback objects in
executable syntax only.
