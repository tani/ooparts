# Prolog textual interface

The interface lives in `src/prolog/text/`: `lexer.lisp` reads tokens, `reader.lisp`
reads operator expressions, and `loader.lisp` registers clauses and processes
load-time directives. It uses the existing compiler and database. There is no
separate Prolog term representation and no Lisp EVAL of the input.

```lisp
(let ((*database* (make-database)))
  (load-prolog-string
   "parent(alice,bob).
    parent(bob,charlie).
    ancestor(X,Y) :- parent(X,Y).
    ancestor(X,Y) :- parent(X,Z), ancestor(Z,Y).")
  (query '((ancestor alice ?who))))
;; ALICE's descendants: BOB, CHARLIE
```

## Lisp functions

| Function | Input and result |
| --- | --- |
| `load-prolog-string` | String; returns number of clauses loaded, including nested files |
| `load-prolog` | Caller-owned character stream; same result; does not close the stream |
| `load-prolog-file` | Pathname/string; opens and closes a UTF-8 source file |
| `read-prolog-term` | Character stream; returns term and a presence flag (NIL/false means EOF) |
| `parse-prolog-string` | String; returns a list of terms without publishing clauses or running directives |

All accept `:database` (default `*database*`) and `:package` (default
`*package*`). String/stream loaders also accept `:base-directory` for relative
includes; the stream loader and term reader accept a `:source` diagnostic label.
A read of `[].` returns NIL with a true presence flag, distinct from EOF.
Read results contain source variable symbols usable by the existing compiler.
The stream predicates READ and READ_TERM can use this parser through the
`read_syntax=prolog` extension flag; their default remains S-expression input.
Their VM-variable conversion, options and EOF behavior are described in
[BUILTINS.md](BUILTINS.md#term-io-and-reader-configuration).
WRITE predicates independently select Prolog output with `write_syntax=prolog`.
Both flags default to `lisp`. The writer in `src/prolog/text/writer.lisp` uses
the same native cons mapping and operator table, with quoting, variable names
and iterative traversal; its options and representation limits are documented
alongside the reader options.
`read-prolog-term` additionally returns transient syntax marks used internally
for DCG terminal syntax; these are not term tags or database metadata.

Unquoted atoms and lowercase quoted atoms map to uppercase symbols in the target
Lisp package. Case-sensitive quoted atoms, and atoms beginning with `?`, use
`ooparts/prolog/atoms`. Named variables become uninterned `?Name` symbols, shared within
one term only. Each underscore is anonymous. This keeps ordinary Lisp queries
usable for text-loaded predicates while preserving variable scope.

## Syntax and representation

Each top-level term must end with a full stop followed by layout, a comment,
or EOF. Supported syntax includes facts, rules, directives, query directives,
compound applications, parentheses, lists (including `[a|T]`), quoted atoms,
strings, decimal/binary/octal/hexadecimal integers, character-code literals,
decimal floats with decimal exponents, cut, conjunction,
disjunction, if-then-else, negation and the supported arithmetic operators.
Line comments use `%`; block comments use `/* ... */` without nesting.
Quotes support doubled delimiters, escaped quote/backslash, `\n`, `\r`, `\t`,
and escaped physical newline. ISO control escapes (`\a`, `\b`, `\f`, `\v`),
hexadecimal `\x61\` and octal `\141\` escapes are also supported. Numeric escapes
require their terminating backslash and a Unicode scalar value. Other escapes
raise a syntax error. Quoted delimiter names such as `']'` remain atoms.

`f(a,b)` and `[f,a,b]` both become `(f a b)`; `[a|T]` becomes `(a . ?T)`;
`[]` becomes NIL. `f()` is accepted as `(f)`, retaining the agreed distinction
between that list and atom F. FUNCTOR/ARG/UNIV retain the finite-call-arity
semantics in [BUILTINS.md](BUILTINS.md). Double quotes initially produce code lists.

The first textual read initializes the database's default operator table and
reader flags. Existing entries with the same name/specifier are retained.
`op/3` directives change parsing of subsequent terms; all seven fixities are
supported by precedence and associativity checks. Operators declared at priority
0 remain removed after subsequent reads. The S-expression reader is unaffected.
Parsing alone initializes reader configuration but does not execute `op`
directives embedded in its input; use the loader for sequential declarations.
Initialize the reader before removing a default operator through a host-side
query: removal before first initialization does not mask a future default.

The `char_conversion` flag (initially ON) controls application of the existing
character mappings outside quoted text. The `double_quotes` flag accepts CODES,
CHARS or ATOM. These reader flags become available after first initialization and
can then be changed with `set_prolog_flag/2`. Both apply only to the textual reader.

## Loading and directives

Within one load, clauses of the same name/arity accumulate in source order,
including noncontiguous definitions. The first clause replaces an existing
predicate of that name/arity, unless MULTIFILE is declared; multifile definitions
append. Publication uses the existing logical update view. Builtins remain protected.

| Directive | Behavior |
| --- | --- |
| `dynamic/1` | Accept predicate indicators/comma sequences and create declared empty predicates |
| `multifile/1` | Record indicators so subsequent loads append their clauses |
| `discontiguous/1` | Record indicators; source contiguity is already unrestricted |
| `op/3`, `char_conversion/2`, `set_prolog_flag/2` | Execute immediately before reading the next term |
| `initialization/1` | Queue goals until the outermost load completes; run in encounter order |
| `include/1` | Read relative to the containing file, sharing its clause replacement context |
| `ensure_loaded/1` | Load a canonical filename once per database; skip an active recursive ensure |
| Other goals, including `?- Goal` | Execute once; require success |

User predicates remain modifiable without a dynamic declaration, consistent with
the Lisp API. Declaration metadata is database-local. `clear-database` invalidates
the ensure-loaded cache while retaining reader/declaration configuration.
A file included successfully also enters the ensure-loaded cache.

DCG `-->` declarations use the existing expander. List terminals, conjunction,
disjunction, cut and `{Goal}` are supported. Transient reader marks distinguish
terminal syntax during expansion, then disappear; stored terms remain native conses.

## Errors and limits

Syntax errors signal `iso-exception` with a source label and line/column context.
Loaders retain lexer positions across terms; independent `read-prolog-term` calls
report positions relative to their individual reads. Failed directives or
initialization goals raise `load_error(directive_failed, Goal)`; missing files
raise `existence_error`; cyclic INCLUDE raises `permission_error`.
Changes made before an error remain visible. Loading is not transactional, and
queued initialization goals do not execute if parsing/loading fails first.

This is the initial textual loader, not an ISO-conformance implementation.
Expression nesting is bounded to 64 parser frames with a controlled syntax error;
long flat argument/list sequences are iterative. Fixed-width Unicode escapes
(`\u`/`\U`), module syntax,
DCG semicontext/if-then, and an ASDF `:prolog` component are not implemented.
Parentheses after an ordinary atom are accepted even with intervening layout.
For an unquoted prefix operator, intervening layout selects prefix application:
`- (1,2)` is unary minus of a conjunction, while `-(1,2)` has two arguments.
ISO operator redefinition restrictions are documented for the OP adapter.
EOF is indicated by the presence flag, never by a magic atom.
