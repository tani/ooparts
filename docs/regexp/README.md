# ooparts/regexp

`ooparts/regexp` is a portable Common Lisp implementation of POSIX.1-2024
extended regular-expression matching. The primary interface is a fixed
S-expression language; `compile-regexp-string` adds a POSIX ERE text front end
that parses pattern notation into that language. Matches return numbered
subexpression spans with POSIX leftmost-longest selection and support the 2024
minimal-repetition modifier. The system is a Lisp interface to ERE operations,
not an implementation of the C `regex.h` ABI.

The library is portable Common Lisp. `src/regexp/**` contains no reader
conditionals and no implementation-specific fast path, so it is supported on
every implementation the repository builds: SBCL, ECL, ABCL, CCL, CLISP, Clasp,
CMUCL and MKCL. The source uses ANSI Common Lisp and ASDF/UIOP only.

Compilation normalizes the expression and lowers it directly to an immutable
edge graph in Lisp; matching uses either of two independent engines implemented
in Lisp. Neither compilation nor matching uses C FFI, calls `setlocale`, or
consults the host locale. The character domain and all classification tables
are fixed to the C/POSIX locale, so results do not depend on the environment.

The supported surface covers literals, sequences, alternation, numbered
captures, `:any`, `:bol`/`:eol`, the four quantifiers and the 2024 minimal
modifier, bounded intervals, positive and complemented bracket expressions, the
twelve C-locale classes, singleton collating and equivalence items, three
compile-time flags and two execution flags. The complete grammar is in
[SYNTAX.md](SYNTAX.md); the selection and capture rules are in
[SEMANTICS.md](SEMANTICS.md).

## Scope

This library implements POSIX ERE matching operations. The S-expression API is
primary; `compile-regexp-string` adds the textual ERE front end. Neither
interface implements backreferences, lookaround, named captures, Unicode
matching, locale-dependent collation, multi-character collating elements, or the
C `regex.h` binary interface. `:collating` and `:equivalence` are singleton
characters because the fixed locale is the C locale.

## Load and use

```lisp
(asdf:load-system "ooparts/regexp")

(let* ((regexp (ooparts/regexp:compile-regexp
                '(:seq (:capture (:or "wee" "week"))
                       (:capture (:or "knights" "night")))
                :backend :vm))
       (match (ooparts/regexp:search-regexp regexp "xxweeknightsyy")))
  (list (ooparts/regexp:match-start match)
        (ooparts/regexp:match-end match)
        (ooparts/regexp:match-string match 1)
        (ooparts/regexp:match-string match 2)))
```

The selected result has group 0 `[2,12)`, group 1 `[2,5)` = `"wee"`, and
group 2 `[5,12)` = `"knights"`. The `:backend` argument is optional and defaults
to `:vm`.

## Public API

All public names are exported from package `ooparts/regexp`. The package has no
nickname. Compiled regexps and matches are immutable; no public constructor or
`setf` accessor is exported for them.

| Call | Return value |
| --- | --- |
| `(compile-regexp expression &key (backend :vm) case-insensitive newline minimal)` | immutable `regexp` |
| `(compile-regexp-string pattern &key (backend :vm) case-insensitive newline minimal)` | immutable `regexp` |
| `(match-regexp regexp string &key not-bol not-eol)` | `regexp-match`, or `nil` |
| `(search-regexp regexp string &key not-bol not-eol)` | `regexp-match`, or `nil` |
| `(regexp-p object)` | generalized Boolean |
| `(regexp-backend regexp)` | `:vm` or `:automaton` |
| `(regexp-group-count regexp)` | non-negative integer |
| `(regexp-match-p object)` | generalized Boolean |
| `(match-start match &optional (group 0))` | zero-based offset, or `nil` |
| `(match-end match &optional (group 0))` | zero-based offset, or `nil` |
| `(match-string match &optional (group 0))` | substring, or `nil` |

The exported types are `regexp`, `regexp-match` and condition `regexp-error`; the
condition readers are `regexp-error-code` and `regexp-error-form`. The exported
constant `+re-dup-max+` is `255`.

`compile-regexp` validates and normalizes `expression`, builds the complete
matcher, and returns an immutable `regexp`. `compile-regexp-string` parses
`pattern` as POSIX ERE text and compiles the result; it takes the same keyword
arguments and validation rules. It accepts exactly `:vm` or
`:automaton` as `backend`; the default is `:vm`. Compilation is eager: the
returned object is not a closure and matching never defers compilation. It does
not mutate the source form, and later mutation of a source list or literal
string cannot change an already compiled regexp. An unsupported backend signals
`type-error`.

`match-regexp` succeeds only when the whole input matches; it runs one match at
start offset $0$ with an end-of-input acceptance requirement. `search-regexp`
performs POSIX substring selection: it tries start offsets $0, 1, \ldots, n$ in
order, where $n$ is the input length, and returns the result for the first start
that has any match. An empty match at input end is eligible. Both functions
return a `regexp-match` or `nil`; no match is `nil`, not a condition. The input
must be a string whose characters all lie in the supported domain; it is
validated in place without being copied, and a retained input string must not be
mutated while it is referenced by a match.

`regexp-backend` reports the backend selected at compilation.
`regexp-group-count` reports the number of explicit capturing groups (group $0$
is not counted). `regexp-p` and `regexp-match-p` are type predicates.

The three compile-time flags and the two execution flags are listed with the
signatures above; their behaviour is specified in [SYNTAX.md](SYNTAX.md#flags).

### Group numbering and offsets

Capturing groups are numbered from $1$ in the preorder traversal of the
normalized expression, by the opening position of each `(:capture ...)` form.
The traversal visits a form before its children and siblings from left to right;
repetition and alternative normalization therefore does not renumber source
groups. `regexp-group-count` is the largest assigned number, or $0$ when there
are no explicit captures. Group $0$ is the whole match.

Every offset is a zero-based, end-exclusive index into the original string:
group $g$ covers $[\mathit{start}(g), \mathit{end}(g))$. The three readers
accept `match` and an optional group number defaulting to $0$. They return `nil`
for a group that did not participate in the selected parse. A matched empty
group instead has equal integer bounds; `match-string` returns `""` for it.
`match-string` allocates the requested substring on demand. A group index that
is negative, non-integral, or greater than `regexp-group-count` signals
`type-error`.

## Engines and backend selection

`compile-regexp` accepts two independent backends:

- `:vm` (default) builds a compact instruction program and explores exact
  histories with explicit stacks and choice points.
- `:automaton` builds consuming and non-consuming adjacency vectors and performs
  a tagged epsilon closure followed by input-character steps over configuration
  buffers.

Both backends consume the same normalized graph and metadata, implement the same
edge and history contract, and return the same shape of result: a vector of
distinct successful exact histories at one fixed start plus a per-run arena.
Selection and capture extraction are shared, so backend choice cannot change
the public result. Neither backend is a fallback for the other, and each
operates only on the compiled graph. Runs keep no mutable state in the compiled
`regexp`; a compiled object is reusable, and each run owns its arena.

The backend is fixed when `compile-regexp` runs, not chosen per match.
`compile-regexp` validates `backend` and dispatches to `make-vm-program` or
`make-automaton`; the choice is stored in the immutable `regexp` and reported
by `regexp-backend`, and each call dispatches on that stored value. The file
`src/regexp/selection.lisp` is not backend selection: after either engine has
returned its accepted histories, the shared selector applies minimal-mode
filtering, whole-span maximization, P-order comparison and capture extraction.
Both engines call it.

The portable/native split is empty. No file under `src/regexp/` selects a
native implementation with a reader conditional, and neither engine is a native
fast path: both are portable Lisp code operating on the same graph.

## Limits, errors and portability

The character domain is codes $1$ through $255$; the fixed class membership
tables are defined in
[the character domain section](SYNTAX.md#character-domain-and-c-locale-classes).
Repetition bounds are integers from $0$ to $255$ with `minimum` not above
`maximum`; the exact validation rule is in
[the repetition bounds section](SYNTAX.md#repetition-bounds). The library
defines no input-length or history-count constant: both engines grow their
stacks, vectors and configuration buffers on demand, so a run is bounded by the
distinct capture histories it enumerates and by host memory. The engines keep
distinct capture histories rather than one thread per control state, so the
usual Thompson linear-time bound does not apply; the search can be exponential
in the worst case.

### Conditions

`regexp-error` is an `error` subclass with read-only slots `code` and `form`.
`regexp-error-code` returns one of:

| Code | Cause |
| --- | --- |
| `:badpat` | Malformed or unknown form, wrong arity, invalid pattern character (NUL or code above 255), improper or circular input structure |
| `:badbr` | Invalid repetition bounds |
| `:ectype` | Unknown POSIX class name |
| `:ecollate` | Invalid collating or equivalence item |
| `:erange` | Reversed range or invalid range endpoints |

`regexp-error-form` returns the offending form. Printing a condition binds
`*print-circle*` to `t`, so reporting a rejected cyclic form terminates.

The following are `type-error` rather than `regexp-error`: an unknown backend, a
non-string pattern to `compile-regexp-string`, a non-regexp first argument to
either matcher, a non-string subject, invalid subject-string characters, and an
invalid group index in a match reader. Malformed pattern terminals signal
`regexp-error` with code `:badpat`. No match is represented by `nil`.

### Portability

The library is portable Common Lisp with ASDF/UIOP as its only external
requirement. Compilation and matching never call C code, never call
`setlocale`, and never consult the host locale; character classification is the
fixed C-locale table above. All offsets are character positions, not byte
positions in the host encoding, so the same pattern and a subject string in the
supported domain give the same result on every supported implementation. See
[portability](../portability.md) for the repository-wide policy.

## Testing and validation

`python3 tools/lisp.py tools/test.lisp regexp` currently reports
**5650 regexp checks passed**. This section is the canonical home of the
test-module map; `tests/regexp/` has no separate README.

| Module | Coverage |
| --- | --- |
| `tests/regexp/suite.lisp` | Aggregate `run-tests`; calls the four regression modules |
| `tests/regexp/syntax.lisp` | Named classes, bracket items, codes 128--255, domain errors, group-index errors, malformed forms and interval bounds |
| `tests/regexp/posix.lisp` | Hand-written leftmost-longest, P-order, minimal-mode, repetition, capture and flag cases; reuse and source-mutation checks |
| `tests/regexp/text.lisp` | POSIX ERE text grammar, bracket syntax, intervals, anchors, flags, text/S-expression equivalence and error codes |
| `tests/regexp/differential.lisp` | Same expressions compiled on both backends, compared over every string up to length 3 over the two-letter alphabet |
| `tests/regexp/support.lisp` | Check counter, assertion helpers and `run-for-backends` |

`support.lisp` runs a fixture once for each backend, so the modules exercise
`:vm` and `:automaton` with the same expected values. The differential suite
builds expressions from atoms, every quantifier and modifier, binary `:seq` and
`:or`, captures, intervals and fixed nested/repeated-capture shapes; for each it
compares group counts and the public spans of `match-regexp` and `search-regexp`
between the two engines. It is a cross-backend consistency check, not a
comparison against an external engine.

The POSIX expectations are hand-written tables of exact `(start end)` spans in
`posix.lisp` and `text.lisp`, including absent groups as `(nil nil)`. No
external matcher or oracle runs during the suite. The syntax module likewise
uses explicit expected error codes for malformed patterns and invalid bounds.

## Reproduction

```sh
python3 tools/lisp.py tools/test.lisp regexp
python3 tools/lisp.py tools/test.lisp all
python3 tools/check-layout.py
```

## Documentation map

- [SYNTAX.md](SYNTAX.md) — S-expression language, text constructor, character
  domain and classes, repetition bounds, normalization and flags.
- [SEMANTICS.md](SEMANTICS.md) — leftmost-longest selection, P-order, minimal
  filtering, repetition termination and capture reporting.
