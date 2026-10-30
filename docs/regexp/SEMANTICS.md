# Matching semantics

Both engines enumerate distinct accepted capture histories at one fixed start.
The shared selector in `src/regexp/selection.lisp` then applies the rules below.
Public entry points and group numbering are in [README.md](README.md); grammar
and flags are in [SYNTAX.md](SYNTAX.md).

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
ordered by the P-order norm comparison implemented in `selection.lisp`. The
complete parse tree is compared, not only the public captures.

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
   to inner, each entry a node identifier and iteration ordinal,
   $\mathit{branch}$ records the chosen child index of every enclosing `:or`,
   and $\mathit{start}$ is the occurrence's input start. Choice of descendants
   below the occurrence is not part of the key.
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
