# Syntax and features

`ooparts/regexp` accepts two concrete notations: the fixed S-expression
language and POSIX ERE text through `compile-regexp-string`. Both reach the same
validator, normalization and compiler. The public entry points, return values
and group numbering are in [README.md](README.md).

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

## Repetition bounds

A repetition bound must satisfy $0 \le \mathit{minimum} \le 255$ and, when
`maximum` is a finite integer, $\mathit{minimum} \le \mathit{maximum} \le 255$.
With `maximum` `nil` the repetition is unbounded, but `minimum` is still at most
$255$. Violations signal `regexp-error` with code `:badbr`. `:repeat` and
`:repeat?` bounds must be integers or `nil`; `minimum` is never `nil`.

## Bracket expressions

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
signal `:badpat`. The complete code table is in
[README.md](README.md#conditions).

## Normalization

Validated expressions are normalized before matching. Nested uncaptured `:seq`
and `:or` forms are flattened, then n-ary concatenations and alternatives are
lowered left-associatively to binary nodes:

$$((e_1\,e_2)\,e_3), \qquad ((e_1 \mid e_2) \mid e_3).$$

Capture, repetition and assertion boundaries are preserved. Structural nodes
receive identifiers in preorder after this normalization. Capture numbering is
defined in
[the API section](README.md#group-numbering-and-offsets). Because repetition
nodes are visited before their children and earlier siblings before later ones,
ascending structural identifiers are the outer-before-inner, left-to-right order
used by the [minimal-mode filter](SEMANTICS.md#minimal-mode-contextual-filtering).

## POSIX ERE text constructor

`compile-regexp-string` parses POSIX extended regular-expression notation and
compiles the result through the same pipeline as `compile-regexp`. It accepts the
same keyword arguments and produces the same immutable `regexp` object; pattern
characters are validated against the fixed domain ($1$ through $255$).

| Notation | Meaning |
| --- | --- |
| ordinary character | literal, including `]` and `}` outside a bracket or interval |
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

The parser treats `.`, `\`, `[`, `(`, `)`, `|`, `^`, `$`, `*`, `+` and `?` as
special outside a bracket expression. `{` is special only when the text after an
atom forms a valid interval; otherwise it is an ordinary literal.

An interval whose text is not syntactically a valid interval (for example `a{x}`
or a trailing `{`) leaves the `{` as an ordinary literal. A quantifier (`*`,
`+`, `?`) with no preceding operand, a second quantifier on the same atom, an
unclosed group or bracket, and a trailing backslash signal `:badpat`. Semantic
validation remains in normalization: reversed ranges signal `:erange`, unknown
classes `:ectype`, multi-character collating elements `:ecollate`, and
out-of-range bounds `:badbr`. The front end does not implement Perl extensions
such as `(?:...)`, inline flags, or `\d`; the library-wide scope is in
[README.md](README.md#scope).

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
the flag. Effective mode $1$ is minimal; $0$ is greedy. The filtering rule that
consumes the effective mode is in
[SEMANTICS.md](SEMANTICS.md#minimal-mode-contextual-filtering).

### `not-bol` and `not-eol`

`not-bol` suppresses only the absolute beginning-of-input assertion; `not-eol`
suppresses only the absolute end-of-input assertion. Neither suppresses an
interior assertion enabled by `newline`. These flags affect matching, not
compilation.
