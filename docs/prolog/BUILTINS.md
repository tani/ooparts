# Lisp-native terms and builtins (0.10.0)

[README](README.md) · [User guide](MANUAL.md)

ooparts/prolog uses Lisp cons graphs as its term model. There is no separate Prolog
compound type and no ISO conformance claim. `(f a b)` is exactly the same cons
structure whether used as data or as a predicate application. Goal position gives
it a callable interpretation. Data terms can have variable heads, improper tails,
sharing and cycles. `(f)` is a one-element list in data position and an `f/0` call
in goal position. `()` is NIL. `?x` is a logic variable; each `?` is fresh.

```lisp
(<-- (append () ?ys ?ys))
(<- (append (?x . ?xs) ?ys (?x . ?zs)) (append ?xs ?ys ?zs))
(query '((append ?xs ?ys (a b c))))
(query '((= ?term (f a (g b)))))
(query '((= ?tail (a . ?tail)) (ground ?tail)))
```

`list`, `cons`, and `:compound` have no special term-constructor meaning.
`(list a b)` is data containing the symbol LIST, followed by A and B; `(cons a b)`
is data containing CONS, A and B. Native lists/dotted pairs are used directly.
Answers and Lisp callbacks use the same cons representation as input terms,
with unbound variables exported as fresh symbols. Lisp bridge expressions keep
normal Common Lisp evaluation rules; source goals and their data are quoted by
the query/definition macros.

## Supported builtins

The registry exposes 128 public predicate indicators, plus seven aliases.
`src/prolog/adapters/builtins.lisp` registers primitive adapters and syntax;
`src/prolog/library/standard-library.lisp` installs the derived predicates.
`(ooparts/prolog:builtin-predicate-inventory)` lists the core indicators by name/arity;
aliases are listed below. This inventory excludes user predicates and separate
DCG/SLG APIs such as PHRASE and TNOT.

| Family | Operations |
|---|---|
| Control | true/fail, cut, call/1..8, and/or, if-then, negation, once/repeat, catch/throw |
| Unification | `=`, `/=`, occurs check, subsumption |
| Cons term inspection | var/nonvar, atom/atomic, number/integer/float, compound/callable, ground/acyclic_term, term_variables, copy_term, `==`/`/==` |
| Arithmetic | is, arithmetic comparisons, integer/floating functions, logand/logior/lognot |
| Dynamic definitions | asserta/assertz, retract/retractall, abolish, clause, current_predicate |
| Collection | findall, bagof |
| Streams | open/close, current/set input/output, flush, stream properties/positions, end-of-stream |
| Characters and bytes | get/peek/put char/code/byte, nl |
| Atoms and numbers | atom_length/concat, sub_atom, atom_chars/codes, char_code, number_chars/codes |
| Environment | current/set flags, halt |

`compound/1` means a nonempty cons term. `callable/1` retains the broad symbol/cons
classification; actual calls additionally require a finite application with a
symbol in predicate position. `atom/1` tests symbol atoms, rather than Common
Lisp's broader ATOM predicate. Ordinary Lisp symbols retain package identity.
NIL has the atom name `nil`, not a translated Prolog empty-list spelling.
Atom/number conversion helpers use a private generated-atom namespace and bridge
those generated atoms by printed name; this is independent of any source parser.

| Preferred spelling | Retained punctuation alias |
|---|---|
| `/=` | `\=` |
| `/==` | `\==` |
| `===` | `=:=` |
| `=/=` | `=\=` |
| `/+` | `\+` |
| `and/2` | `,/2` |
| `or/2` | `;/2` |

`=/2` unifies cons graphs. `/=/2` tests immediate nonunifiability without binding
variables. `==/2` and `/==/2` test structural identity while preserving variable
identity, not host EQ identity of cons cells. `===/2` and `=/=/2` evaluate arithmetic
expressions. Bitwise expressions use `logand`, `logior`, `lognot`; their punctuation
spellings remain supported. Integers are unbounded; computed floating results use
SBCL double precision. ROUND retains ties away from zero.
`**/2` always returns a float; a zero exponent gives 1.0, including 0**0.
For `^/2`, integer arguments with a nonnegative exponent give an integer.
Negative integer exponents give an integer for bases 1 and -1; base 0 raises
`evaluation_error(undefined)` and other integer bases raise `type_error(float, Base)`.
Other supported powers use floating arithmetic.

`->/2` commits to the first condition solution. `(or (-> condition then) else)`
selects ELSE only if CONDITION fails, not if THEN fails. AND/OR are cut-transparent;
CALL and negation have opaque cut boundaries. DCG definitions use `-->` for append
and `--->` for replacement.

Assertions publish immutable clause/code snapshots; active calls retain their
entry definitions. Builtins cannot be overwritten. `(rule head body)` is accepted
by assertion/retraction operations; elsewhere RULE is an ordinary data symbol.
Variable goals in asserted or reflected clause bodies are represented as
`call(Variable)`, including inside transparent control forms. Zero-arity heads
accept both atom and singleton-list call spellings. Accessing a protected clause
raises `permission_error(access, private_procedure, Name/Arity)`; retracting one
raises `permission_error(modify, static_procedure, Name/Arity)`.
BAGOF groups variant free-variable bindings in first-appearance order and retains
answer order inside each group; no standard term ordering is imposed. FINDALL
keeps every answer in execution order.

## Cons inspection, order, and collections

For a nonempty proper list `(name arg1 ... argN)`, `functor/3` returns the
symbol NAME and arity N. `arg/3` selects ARG1 at index 1, and so on; zero or
out-of-range indices fail. Non-cons Lisp values have arity 0;
ARG raises `type_error(compound, Value)` for them, including at index 0.
`=../2` decomposes a list application to `(name arg1 ... argN)` and a non-cons
value to `(value)`. There is no special CONS marker or constructor.

```lisp
(query '((functor (f a b) f 2) (arg 2 (f a b) ?arg))) ; ?arg = b
(query '((=.. ?term (f a b))))                      ; ?term = (f a b)
(query '((functor ?term f 2)))                      ; ?term = (f ?fresh1 ?fresh2)
(query '((=.. ?term (f))))                          ; ?term = f
(query '((sort (3 1 2 1) ?sorted)))
(query '((keysort ((2 . b) (1 . a) (2 . c)) ?pairs)))
```

The following description applies to the default `:native` term model. In
`:term-model :iso` databases, list cells use `($cons Head Tail)` and `$nil`;
FUNCTOR/ARG/UNIV expose `'.'/2` and `[]`, KEYSORT uses `Key-Value` compounds, and
canonical output expands lists into `'.'/2`. Input/output syntax selection is
independent of this choice. See [strict term mode](ISO-COMPATIBILITY.md#strict-term-mode).

These operations match predicate-call name, arity and argument positions.
Lists and compounds remain indistinguishable: `(a b c)` has name A and arity 2.
A list application's head must be an instantiated symbol. A variable head or
open argument tail raises `instantiation_error`; a non-symbol head or improper
tail raises `type_error`; a cyclic outer spine raises
`representation_error(finite_arity)`. The checks traverse only the outer spine:
arguments may be unbound, shared, improper or cyclic graphs. Bound tail variables
are dereferenced. Validation and construction use iterative traversal.

Construction at arity 0 produces the non-cons name. In particular, F and `(f)`
both decompose to `(f)`; reconstruction canonicalizes `(f)` to the atom F.
Unification continues to distinguish F from `(f)`. Positive-arity construction
requires a symbol name and retains argument sharing. An empty UNIV input list
raises `domain_error(non_empty_list)`. No tag or source-origin metadata is added.

`compare/3` and `@</2`, `@=</2`, `@>/2`, `@>=/2` use the order
variable < number < symbol < other Lisp non-cons object < cons. Cons comparison
is lexicographic CAR then CDR, using iterative traversal. Variables use creation
IDs; equal IDs from different machines are distinguished by database-local IDs.
Numbers compare real part, imaginary part, then numeric representation (integer,
ratio, float format, complex). Symbols compare exact symbol name, package name,
then identity for uninterned symbols. Other Lisp objects use database-local
identity IDs assigned on first comparison. This is a Lisp-native total order;
it deliberately distinguishes package symbols even where builtin-generated atom
names can bridge them during unification. Opaque identity ordering is stable
within a database, not across program runs. Cyclic terms raise
`representation_error(acyclic_term)` in ordering operations. Terms may contain
unbound variables, and later bindings can change their order.

`sort/2` sorts a copied list spine and removes duplicates under this order;
`keysort/2` stably sorts native `(key . value)` pairs without removing duplicates.
Neither mutates the input spine nor copies its elements. `setof/3` is the ordinary
clause BAGOF followed by SORT. It preserves BAGOF's first-appearance group order,
sorts/deduplicates each group, supports existential `^`, and fails with no answers.

## Term I/O and reader configuration

`read/1,2`, `read_term/2,3`, `write/1,2`, `writeq/1,2`,
`write_canonical/1,2`, and `write_term/2,3` operate on text streams in S-expression
format by default. Current-stream and default-option forms are ordinary library clauses.
The independent database-local extension flags `read_syntax` and `write_syntax`
accept `lisp` (default) or `prolog`; `sexp` is not a flag value.
READ/READ_TERM follow `read_syntax` and all WRITE predicates follow `write_syntax`.
The Prolog paths use the [textual reader and writer](PROLOG-LOADER.md), including
the database's operator configuration. Flags can change between complete reads
or writes, survive backtracking and clause clearing, and are isolated by database.

```prolog
set_prolog_flag(read_syntax, prolog).
set_prolog_flag(write_syntax, prolog).
set_prolog_flag(read_syntax, lisp).
set_prolog_flag(write_syntax, lisp).
```

Reading uses a fresh standard Lisp readtable with case preservation, the generated
atom package, and `*read-eval*` disabled. `?Name` becomes a fresh logic variable
per read, repeated names share it, and each `?` is anonymous. Lisp `#n=` / `#n#`
sharing and cycles are supported. EOF returns `end_of_file`; malformed input
raises `syntax_error(s_expression)`. Stream direction, text type, and EOF action
are checked. `read_term` options are `variables`, `variable_names`, and `singletons`.
The first returns all variables in encounter order (including anonymous ones);
the other two return native `(name . variable)` pairs and omit anonymous variables.

In Prolog mode, terms require a terminating full stop. Source variables become
fresh VM variables per read, preserving repeated names and anonymous occurrences.
Atoms use the generated-atom namespace and its existing name bridge; quoted atom
case is preserved. The same options are accepted, but `variable_names` and
`singletons` return `=(Name, Variable)` terms. EOF and stream validation remain
the same. The native cons mapping and textual reader's limits still apply.

In Lisp mode, writing dereferences terms, preserves sharing/cycles with Lisp circle notation,
and names unbound variables `?G0`, `?G1`, etc. `writeq` and `write_canonical`
enable quoted Lisp output; both have the same S-expression representation.
`write_term` supports `quoted` and `variable_names` (native pairs with names
beginning with `?`). In quoted query source those names must be atoms from
`ooparts/prolog/atoms` (for example `(intern "?Name" :ooparts/prolog/atoms)`), since ordinary
Lisp symbols beginning with `?` are compiled as variables. Duplicate names for
different variables and the anonymous name `?` are rejected. `ignore_ops` and `numbervars` validate booleans but have no
effect in this format: operators do not affect Lisp syntax and there is no
special numbered-variable term. Decimal output and unlimited print depth/length
do not depend on ambient printer settings. Non-readable host objects retain
Common Lisp's printed representation; the Lisp reader/printer's own depth limits
apply to I/O, unlike iterative VM term operations.

With `write_syntax=prolog`, the writer emits integers, floats, atoms, variables
and native cons terms without a final full stop. A finite symbol-headed proper
list is written as `f(a,b)`, including `f()` for a singleton list.
Other cons spines use `[...|Tail]` and NIL uses `[]`. There is no origin tag
to distinguish an atom list from an application: `[a,b]` and `a(b)` are the
same native term and normally print as `a(b)`. The distinct atom named `[]`
is quoted by WRITEQ. Package identity is not encoded by Prolog syntax; symbols
use the existing atom-name bridge.

WRITE permits unquoted atom text; WRITEQ quotes atoms and escapes control
characters as needed. WRITE_TERM supports `quoted`, `ignore_ops`,
`numbervars` and `variable_names`. Operator notation respects all seven fixities,
precedence and associativity. WRITE_CANONICAL enables quoting and ignores
operators, using functional notation for native applications. It does not
translate native lists into ISO `'.'/2` cells.
Prolog variable names default to `_G0`, `_G1`, etc., preserving aliases.
The `variable_names` option uses `=(Name, Variable)` terms with valid named
Prolog variables (not anonymous `_`). Conflicting names for distinct variables
are rejected; generated names avoid explicit names. Bound values are ignored.
With `numbervars(true)`, `'$VAR'(0)` through `'$VAR'(25)` print as A through Z,
then A1, B1, etc.; WRITEQ enables this convention and WRITE_CANONICAL disables it.

The Prolog writer traverses iteratively. Cycles raise
`representation_error(acyclic_term)`; opaque Lisp values such as host strings,
vectors, ratios and complex numbers raise `type_error(prolog_term, Value)`.
These graphs and objects remain available through Lisp output. Repeated acyclic
cons structure is expanded, while variable sharing is preserved. Validation
errors do not leave partial term text in the output stream.

`op/3` stores priority 1..1200 and `fx/fy/xf/yf/xfx/xfy/yfx` by atom name and
specifier; priority 0 removes the entry. Atom lists are accepted for names.
Priorities outside 0..1200 raise `domain_error(operator_priority, Priority)`.
Comma cannot be modified; atom names `[]` and `{}` cannot be declared as operators.
The bar `|` requires infix fixity and priority greater than 1000, or priority 0
for removal. Every name is checked before changes are published. Native NIL
retains the distinct atom name `nil` and can be an operator name.
`current_op/3` enumerates this initially empty table. The first textual-reader call initializes
default operators. `char_conversion/2` stores
one-character atom mappings. With bound input, `current_char_conversion/2`
returns its mapping or identity; with variable input, it enumerates explicitly
configured entries only, including configured identities. Enumeration order of
both configuration tables is unspecified. These tables are database-local,
persist across backtracking, and do not alter the Lisp reader. The textual reader uses them as described in [PROLOG-LOADER.md](PROLOG-LOADER.md). Like stream and flag configuration, clearing clauses does not reset these tables.
The former Lisp APIs `iso-read-term`, `iso-write-term`, and
`iso-predicate-inventory` are not restored.

## Runtime and embedding

WAM, managed VM GC, DCG, SLG and its well-founded negative resolution remain.
Cons graphs are shared by ordinary and tabled execution. Rational-tree unification
is the default; occurs-check unification is available explicitly.

Open streams persist until explicitly closed. Stream options include type,
reposition, alias and eof_action; close supports force. Bindings and exception
handlers survive VM GC and rollback. The existing Lisp exception API
`iso-exception`/`iso-exception-term` and embedding hook `*iso-halt-function*` retain
their historical names; exception payloads are plain S-expressions. HALT exits SBCL
by default. Unknown predicates raise an existence error by default; the unknown
flag can select failure instead. These conventions are ooparts/prolog's own specification.
The read-only `max_arity` flag is `unbounded`, matching finite native application
arities without a fixed implementation limit.

## Source LET control

`(let name expression)` binds a nonspecial Lisp variable for later host bridge
expressions. It is compiled by source macros and is not a core predicate
indicator. See [the user guide](MANUAL.md#lexical-let) for scope, declarations,
backtracking and embedding restrictions. Allegro-style dynamic `let*` is not
implemented.

## Implementation layers

46 indicators run as ordinary protected
Prolog clauses; see [implementation layers](PRIMITIVES.md) for the classification,
private adapter boundary, source organization, and validation results.
