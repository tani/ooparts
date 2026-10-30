# ooparts/regexp

`ooparts/regexp` is a portable Common Lisp implementation of POSIX.1-2024
extended regular-expression matching. The primary interface is a fixed
S-expression language; `compile-regexp-string` adds a POSIX ERE text front end
that parses pattern notation into that language. Matches return numbered
subexpression spans with POSIX leftmost-longest selection and support the 2024
minimal-repetition modifier. The system is a Lisp interface to ERE operations,
not an implementation of the C `regex.h` ABI.

The library is portable Common Lisp. Compilation normalizes the expression and
lowers it directly to an immutable edge graph in Lisp; matching uses either of
two independent engines implemented in Lisp. Neither compilation nor matching
uses C FFI, calls `setlocale`, or consults the host locale. The character domain
and all classification tables are fixed to the C/POSIX locale, so results do not
depend on the environment. See [portability](../portability.md) for the
repository-wide portability policy.

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
group 2 `[5,12)` = `"knights"`.

## Public API

All public names are exported from package `ooparts/regexp`. The package has no
nickname. Compiled regexps and matches are immutable; no public constructor or
`setf` accessor is exported for them.

```lisp
(compile-regexp expression &key (backend :vm) case-insensitive newline minimal)
(compile-regexp-string pattern &key (backend :vm) case-insensitive newline minimal)
(match-regexp regexp string &key not-bol not-eol)
(search-regexp regexp string &key not-bol not-eol)
(regexp-p object)
(regexp-backend regexp)
(regexp-group-count regexp)
(regexp-match-p object)
(match-start match &optional (group 0))
(match-end match &optional (group 0))
(match-string match &optional (group 0))
```

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

`regexp-backend` reports the backend selected at compilation. `regexp-group-count`
reports the number of explicit capturing groups (group $0$ is not counted).
`regexp-p` and `regexp-match-p` are type predicates.

## Group numbering and offsets

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

## S-expression language

Operators are keywords. A character or string is literal data: regular-expression
metacharacters such as `.`, `*`, `[`, `(`, `\` and `|` have no textual meaning
inside it. The S-expression language itself has no escaping layer; textual
notation is handled by `compile-regexp-string`.

| Form | Meaning |
| --- | --- |
| A character | One literal character |
| A string | Concatenation of its literal characters; `""` is empty |
| `:epsilon`, `""`, `(:seq)` | Empty expression |
| `:any` | ERE period: any one admissible character |
| `:bol`, `:eol` | Beginning-of-line and end-of-line assertions |
| `(:seq expression...)` | Concatenation; zero operands are empty and one operand is valid |
| `(:or first second more...)` | Alternation; at least two operands |
| `(:capture expression)` | Numbered capturing subexpression |
| `(:* expression)` | Zero or more repetitions |
| `(:+ expression)` | One or more repetitions |
| `(:? expression)` | Zero or one repetition |
| `(:*? expression)`, `(:+? expression)`, `(:?? expression)` | The same duplications with the POSIX repetition modifier |
| `(:repeat minimum maximum expression)` | Bounded interval; `maximum` is an integer or `nil` for unbounded |
| `(:repeat? minimum maximum expression)` | Bounded interval with the POSIX repetition modifier |
| `(:class item...)` | Matching bracket expression; at least one item |
| `(:not-class item...)` | Nonmatching bracket expression; at least one item |

A repetition bound must satisfy $0 \le \mathit{minimum} \le \mathit{maximum} \le 255$
when `maximum` is finite, or $0 \le \mathit{minimum}$ when it is `nil`
(unbounded). Violations signal `regexp-error` with code `:badbr`. `:repeat`
and `:repeat?` bounds must be integers or `nil`; `minimum` is never `nil`.

A bracket item is one of the following forms; a character is a bare item.

| Item | Meaning |
| --- | --- |
| A character | One member |
| `(:range first-character last-character)` | Inclusive ascending range |
| `(:posix class-name)` | One of the twelve C-locale classes |
| `(:collating character)` | Collating element; a singleton in the C locale |
| `(:equivalence character)` | Equivalence class; a singleton in the C locale |

Ranges are ordered by unsigned character code. A reversed range or a
non-character endpoint signals `:erange`. In the C locale a collating element
or equivalence class is exactly one character; a non-character or
multi-character item signals `:ecollate`. An unknown class name signals
`:ectype`. Nested bracket forms or unknown operators are malformed patterns and
signal `:badpat`.

Validated expressions are normalized before matching. Nested uncaptured `:seq`
and `:or` forms are flattened, then n-ary concatenations and alternatives are
lowered left-associatively to binary nodes:

$$((e_1\,e_2)\,e_3), \qquad ((e_1 \mid e_2) \mid e_3).$$

Capture, repetition and assertion boundaries are preserved. Structural nodes
receive identifiers in preorder after this normalization; group numbers remain
those of the source capture openings. Because repetition nodes are visited
before their children and earlier siblings before later ones, ascending
structural identifiers are the outer-before-inner, left-to-right order used by
the minimal-mode filter below.

## Text constructor

`compile-regexp-string` parses POSIX extended regular-expression notation and
compiles the result through the same pipeline as `compile-regexp`. It accepts the
same keyword arguments and produces the same immutable `regexp` object; pattern
characters are validated against the fixed domain ($1$ through $255$).

| Notation | Meaning |
| --- | --- |
| ordinary character | literal; metacharacters are `. \ [ ] ( ) { } * + ? \| ^ $` |
| `\c` | literal character `c`; there are no C-style escapes, so `\n` is the letter `n` |
| `.` | any character except NUL, and except newline under `newline` |
| `^`, `$` | beginning/end assertions wherever they occur outside a bracket expression |
| `e1 e2`, `(e)` | concatenation and a numbered capture; `()` is empty |
| `e1\|e2` | alternation; an empty branch matches the empty string |
| `e*`, `e+`, `e?` | zero-or-more, one-or-more, zero-or-one |
| `e{m}`, `e{m,}`, `e{m,n}` | interval repetition; bounds are validated as `:badbr` |
| `e*?`, `e+?`, `e??`, `e{...}?` | the 2024 minimal modifier for that repetition |
| `[...]`, `[^...]` | matching and nonmatching bracket lists |
| `[a-z]` | inclusive range |
| `[[:alpha:]]` | C-locale character class |
| `[[.x.]]`, `[[=x=]]` | collating symbol and equivalence class (single characters) |
| `[]]`, `[-a]`, `[a-]` | `]` first and `-` first or last are literal |

An interval whose text is not syntactically a valid interval (for example `a{x}`
or a trailing `{`) leaves the `{` as an ordinary literal. A quantifier with no
preceding operand, a second quantifier on the same atom, an unclosed group or
bracket, and a trailing backslash signal `:badpat`. Semantic validation remains
in normalization: reversed ranges signal `:erange`, unknown classes `:ectype`,
multi-character collating elements `:ecollate`, and out-of-range bounds
`:badbr`. The front end does not implement Perl extensions such as `(?:...)`,
inline flags, `\d`, named groups, lookaround, or backreferences.

## Character domain and C-locale classes

The supported domain is character codes $1$ through $255$, represented by Lisp
characters. NUL (code $0$) and codes above $255$ are invalid: in an expression
they signal `regexp-error` with code `:badpat`, and in a subject string they
signal `type-error`. Strings are not truncated or silently reinterpreted.
Codes $128$ through $255$ are matchable by literals, explicit positive bracket
items and ranges, `:any`, and applicable complemented bracket expressions, but
have no membership in the twelve named classes. String positions therefore
correspond one-to-one with C-locale byte positions.

The twelve named classes are fixed to these code sets, with NUL excluded:

| Class | Character codes |
| --- | --- |
| `:upper` | $65$--$90$ |
| `:lower` | $97$--$122$ |
| `:alpha` | `:upper` $\cup$ `:lower` |
| `:digit` | $48$--$57$ |
| `:alnum` | `:alpha` $\cup$ `:digit` |
| `:xdigit` | $48$--$57$ $\cup$ $65$--$70$ $\cup$ $97$--$102$ |
| `:blank` | $\{9, 32\}$ |
| `:space` | $9$--$13$ $\cup$ $\{32\}$ |
| `:cntrl` | $1$--$31$ $\cup$ $\{127\}$ |
| `:print` | $32$--$126$ |
| `:graph` | $33$--$126$ |
| `:punct` | $33$--$47$ $\cup$ $58$--$64$ $\cup$ $91$--$96$ $\cup$ $123$--$126$ |

Case folding pairs exactly the ASCII pairs A--Z and a--z. No other characters
have case counterparts. Membership is precomputed as a 256-bit table per
compiled predicate, with code $0$ never a member.

## Flags

`compile-regexp` accepts three compile-time flags and matching accepts two
execution flags.

### `case-insensitive`

Literal characters and positive bracket membership gain the ASCII case
counterpart. For a bracket expression the case counterparts are added before a
`:not-class` complement is taken. Consequently `:lower` and `:upper` both match
ASCII letters of either case under `case-insensitive`, and a complemented class
excludes both cases of every listed character. No Unicode case mapping is
performed.

### `newline`

`newline` has the `REG_NEWLINE` effects:

- `:any` cannot consume code $10$.
- A `:not-class` expression cannot consume code $10$.
- `:bol` succeeds at offset $0$ and, with `newline`, also immediately after a
  newline.
- `:eol` succeeds at the input length and, with `newline`, also immediately
  before a newline.

Positive classes and a literal newline can still consume newline. Without
`newline`, newline is ordinary data. Interior line assertions do not change the
whole-match requirement of `match-regexp`.

### `minimal`

`minimal` is the `REG_MINIMAL` default for every duplication. A suffixed
operator (`:*?`, `:+?`, `:??`, `:repeat?`) inverts the default for that
duplication only; it does not change nested duplications. The effective mode of
each repetition node is

$$
\mathit{mode} = \mathit{modifier} \oplus \mathit{minimal},
$$

where $\mathit{modifier}=1$ for a suffixed form and $0$ otherwise, and
$\mathit{minimal}=1$ when the compile flag is true. The XOR is applied once,
during normalization. Selection reads the effective mode and never re-applies
the flag. Effective mode $1$ is minimal; $0$ is greedy.

### `not-bol` and `not-eol`

`not-bol` suppresses only the absolute beginning-of-input assertion; `not-eol`
suppresses only the absolute end-of-input assertion. Neither suppresses an
interior assertion enabled by `newline`. These flags affect matching, not
compilation.

## POSIX leftmost-longest matching

For a search, the earliest start offset with any admissible complete parse is
selected; a later start is never compared with an earlier successful one. At the
fixed start, the engine enumerates all admissible successful parses and
maximizes the whole-match end offset:

$$L = \min\{\, s \mid \text{there is a match starting at } s \,\}, \qquad
E = \max\{\, e \mid \text{an admissible parse spans } [L,e) \,\}.$$

For a full match the start is fixed at $0$ and only parses with $e=n$ are
admissible. There is no first-alternative or Perl-style priority: alternatives
are not ordered by source position, and acceptance by one branch does not stop
the search for a longer or otherwise preferred parse.

## P-order disambiguation

When several parses share the same selected whole span, the parse tree is
ordered using the P-order definitions of Borsotti and Trofimovich. The complete
parse tree is compared, not only the public captures.

Each structural node in a parse tree is a position. A present subtree has norm

$$\operatorname{norm}(\text{present subtree}) = \mathit{end} - \mathit{start}.$$

An absent alternative branch or an absent repetition-child placeholder has norm
$-1$. A position that does not exist because the other parse has an extra child
or iteration has norm $+\infty$. Positions are visited in preorder:
ancestors before descendants, siblings left to right, repetition occurrences in
chronological order. This includes the selected child slot of every `:or` and
the absent placeholder of the other slot, and one absent placeholder child for a
zero-iteration `:repeat`. At the first position whose norms differ, the parse
with the greater norm wins. If the norms agree everywhere, and the parses report
identical public captures, either parse may be retained; that choice is not
observable through the API.

Examples of the ordering:

| S-expression / input | Result |
| --- | --- |
| `(:or "a" "aa")` / `"aa"` | Whole `[0,2)`; the longer alternative wins |
| `(:seq (:capture (:or "a" "aa")) (:capture (:? "a")))` / `"aa"` | Group 1 `[0,2)`, group 2 `[2,2)` |
| `(:seq (:* (:capture (:or "a" "aa"))))` / `"aa"` | Group 1 `[0,2)`, not two shorter iterations |
| `(:seq (:* (:capture (:or "a" "aa"))))` / `"aaa"` | Group 1 `[2,3)`, from preferred iterations `aa`, `a` |
| `(:seq (:* (:capture (:seq "a" (:capture (:? "b"))))))` / `"aba"` | Group 1 `[2,3)`, group 2 absent rather than stale `[1,2)` |
| `(:seq (:* (:capture (:* "a"))))` / `"a"` | Whole and group 1 `[0,1)`; no trailing optional empty iteration |
| `(:seq (:repeat 2 2 (:capture (:* "a"))))` / `"a"` | Whole `[0,1)`, group 1 `[1,1)`; the mandatory empty iteration is retained |
| `(:seq (:* (:capture (:* "a"))))` / `"b"` | Whole and group 1 `[0,0)`; an empty capture beats nonparticipation |

## Minimal-mode contextual filtering

POSIX.1-2024 defines the repetition modifier and its inversion under a minimal
default, but it does not give a complete all-greedy P-order analogue for mixed
minimal and greedy parses. The following rule is the **library specification**:
a deterministic elaboration of the standard's mixed-mode wording. It is marked
as **INFERENCE**, not as a theorem supplied by POSIX, and implementations must
not silently replace it with first-success, global shortest-match, or
host-engine behaviour.

1. Enumerate every admissible successful parse at the fixed earliest start. For
   a full match, retain only parses ending at the input length.
2. Process effective-minimal repetition nodes ($\mathit{mode}=1$) by ascending
   structural identifier, which is outer-before-inner and left-to-right. Within
   each node, process its occurrences in chronological order. Repetition nodes
   with effective mode $0$ are never filtered. The XOR with the compile-time
   default has already been applied; do not apply it again.
3. For one minimal repetition node, take the candidate set present at the start
   of that pass and group candidates by the key
   $$\bigl(\mathit{address}, \mathit{branch}, \mathit{start}\bigr),$$
   where $\mathit{address}$ is the occurrence's enclosing-repeat chain from outer
   to inner (node identifier and iteration ordinal) followed by the node
   identifier itself, $\mathit{branch}$ records the chosen child index of every
   enclosing `:or`, and $\mathit{start}$ is the occurrence's input start.
   Choice of descendants below the occurrence is not part of the key.
4. Within each group that contains this occurrence, keep only candidates whose
   occurrence span $\mathit{end}-\mathit{start}$ equals the group's minimum.
   Compute all group minima against the pass-entry candidate set, then remove
   the losing candidates simultaneously. Candidates in which the occurrence is
   absent, including candidates in other branches of an enclosing alternative,
   are untouched.
5. After all minimal passes, select among the survivors with the ordinary
   whole-span maximization and P-order comparison above. Minimality is local: it
   does not impose minimal defaults on descendant repetitions, and it does not
   make a greedy repetition minimal.

The alternative-independence property follows from including every enclosing
`:or` branch choice in the key: a minimal repetition inside one alternative
cannot delete a longer admissible match that takes a different alternative in
which that repetition is absent. Likewise, a minimal repetition expands as far
as its suffix requires, because candidates whose minimal occurrence is
impossible or cannot satisfy the rest of the pattern are not candidates at all.

| S-expression / input | Result |
| --- | --- |
| `(:seq (:*? :any) #\c)` / `"abc abc"` | Whole `[0,3)`; the minimal prefix stops at the first feasible `c` |
| `(:seq (:capture (:*? :any)) (:* :any))` / `"abcdef"` | Whole `[0,6)`, group 1 `[0,0)`; the empty minimal capture is preferred while the match stays maximal |
| `(:seq (:capture (:*? "a")) "b")` / `"aaab"` | Whole `[0,4)`, group 1 `[0,3)`; minimality expands to satisfy the suffix |
| `(:or (:seq (:*? :any) #\c) (:seq (:* :any) #\d))` / `"abc abcd"` | Whole `[0,8)` through the independent second alternative |
| `(:seq (:* :any) #\c)` / `"abc abc"` with `minimal t` | Whole `[0,3)`; the unsuffixed repetition is effectively minimal |
| `(:seq (:*? :any) #\c)` / `"abc abc"` with `minimal t` | Whole `[0,7)`; the suffix inverts the minimal default |
| `(:seq (:repeat? 1 nil (:capture (:seq (:capture (:* "a")) (:* "a") "b"))) (:* :any))` / `"aabaaab"` | Whole `[0,7)`, group 1 `[0,3)`, group 2 `[0,2)`; outer minimality is not inherited by the inner repetition |

## Repetition termination and the nullable rule

The engine admits repetition histories by exact counts and never discards an
epsilon cycle merely because a state and input position were seen before, nor
because the previous iteration was empty. Exact histories are required for
POSIX capture reporting.

Before opening another iteration, the total completed iterations must be less
than an admission bound computed once when the repetition is entered:

$$\min\left(\mathit{max}_{\text{finite}},\;
\max\left(\ell - p_{\text{entry}},\; m,\; 1\right)\right),$$

where $\ell$ is the input length, $p_{\text{entry}}$ is the position at which
the repetition node was opened, $m$ is the repetition minimum, and the finite
maximum term is omitted for an unbounded repetition. The bound is a property of
the repetition occurrence, not recomputed at each iteration boundary. Each
nonempty iteration consumes at least one character, so this is a finite
admission bound, not a timeout or a heuristic epsilon-cycle cut.

When a repetition closes, let $r$ be the number of nonempty iterations, $z$ the
number of empty iterations, $m$ the minimum, and $\mathit{total}=r+z$. The
completed occurrence is admissible exactly when:

- if $r>0$, then $z=\max(0,m-r)$;
- if $r=0$ and $m>0$, then $z=m$;
- if $r=0$ and $m=0$, then $z\in\{0,1\}$, provided the upper bound permits it;
- in every case $\mathit{total}\le\mathit{max}_{\text{finite}}$ when the maximum
  is finite, and $\mathit{total}\ge m$.

Thus `(:repeat 0 0 e)` permits only zero iterations, while a zero-iteration
occurrence remains distinct from one empty iteration. A completed zero-iteration
repetition must carry the recorded absent-placeholder event for its child, and a
repetition with at least one iteration must not; this rejects the bare epsilon
exit from the repetition loop and guarantees the canonical absent child in the
parse tree. This is why a mandatory
empty iteration survives, as in `(a*){2}` on `"a"` reporting group 1 `[1,1)`,
and why `(a*)*` on `"b"` reports an empty capture instead of absence.

## Capture reporting

Reporting follows the POSIX `regexec` subexpression rules, applied after the
complete parse has been selected:

- The root parse tree supplies group $0$.
- Groups are reported in increasing number. For a group, find its nearest
  enclosing capture group $p$ by the metadata parent chain. Then restrict
  attention to the reported occurrence of $p$ (the whole selected tree for a
  top-level group).
- Within that occurrence, take the last occurrence of the capture node in
  depth-first order, with repetition iterations in chronological order. If that
  occurrence is present, report its span. If it is an absent placeholder, or the
  capture does not occur, report the group as absent.
- If the reported occurrence of an enclosing capture is absent, every
  descendant capture is absent as well.

Absent groups are stored internally as offsets $(-1,-1)$ and are exposed as
`nil` by the public readers. A present empty group has
$\mathit{start}=\mathit{end}$ and `match-string` returns `""`. This rule clears
stale captures from earlier parent iterations without discarding the history
needed for disambiguation. For example, `(a(b)?)*` on `"aba"` reports group 1
`[2,3)` and group 2 absent.

## Backends

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
`regexp`; a compiled object is reusable, and each run owns its arena. The
exact-history search can be exponential in the worst case; Thompson's linear
bound does not apply to this capture-complete construction.

## Conditions

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
non-string subject, invalid subject-string characters, and an invalid group
index in a match reader. Malformed pattern terminals signal `regexp-error` with
code `:badpat`. No match is represented by `nil`.

## Scope

This library implements POSIX ERE matching operations. The S-expression API is
primary; `compile-regexp-string` adds the textual ERE front end described above.
Neither interface implements backreferences, lookaround, named captures, Unicode
matching, locale-dependent collation, multi-character collating elements, or the
C `regex.h` binary interface. `:collating` and `:equivalence` are singleton characters because the
fixed locale is the C locale.
