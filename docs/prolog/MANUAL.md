# ooparts/prolog user guide

[README](README.md) · [Builtins](BUILTINS.md) · [Validation](VALIDATION.md)

## Definitions and queries

```lisp
(<-- (append () ?ys ?ys))
(<- (append (?x . ?xs) ?ys (?x . ?zs))
    (append ?xs ?ys ?zs))
(query '((append ?xs ?ys (a b c))))
```

`<--` replaces all clauses of the same name and arity; `<-` appends one.
Ordinary predicates select goals left to right and clauses in definition order,
using depth-first search. Tabled predicates use SLG.

Symbols beginning with `?` are logic variables. Each occurrence of `?` is a
fresh anonymous variable. Common Lisp package identity matters for symbols.
`query` collects solutions as binding alists: failure is NIL, while a successful
goal without named bindings returns `(NIL)`. Use limits or cursors for large or
infinite answer sets. `?-` is the interactive interface described below.

```lisp
(query '((append ?xs ?ys (a b c))) :limit 2)
(let ((cursor (make-query '((append ?xs ?ys (a b c))))))
  (unwind-protect
      (loop
        (multiple-value-bind (solution foundp) (next-solution cursor)
          (unless foundp (return))
          (print solution)))
    (close-query cursor)))
```

### Interactive queries

```lisp
(?- (append ?xs ?ys (a b c)))
```

```text
?XS = NIL
?YS = (A B C)
More? [; = next, Enter = stop] ;
?XS = (A)
?YS = (B C)
More? [; = next, Enter = stop]
```

The first answer is computed immediately. Only `;` followed by Enter requests
another; Enter alone, EOF, `q` or `.` stops. Invalid commands repeat the prompt
without advancing. There is no lookahead to determine whether more answers exist.
Requesting an answer after exhaustion prints `false.`; a ground success prints
`true.`. `?-` returns no values and does not accumulate solutions.

Input and output use dynamically bound `*query-io*`. Answers preserve Lisp
notation and print cycles with reader labels. Conditional SLG answers print
`undefined` and their delayed negations instead of being silently skipped.
The cursor is released on stop, EOF, exhaustion, errors and nonlocal exits.
Lexical callbacks work as in `prolog`. An individual request may still diverge;
tabled evaluation may need to complete an SCC before producing an answer.

Use `query` for programmatic collection and `make-query` / `next-solution` for
programmatic streaming. The collecting examples in this guide use `query`.

The second value of `next-solution` distinguishes an answer from exhaustion.
Answer cons graphs are copied and remain valid after backtracking. Unbound
variables become fresh `?G...` symbols, preserving sharing within each answer.

Bind `*database*` to a `make-database` result to isolate definitions.
`clear-database` removes clauses and table declarations. Databases are intended
for single-threaded use; synchronization is not implemented.

## Terms

Terms are native Lisp cons graphs. Lists and compound terms are not distinct.

```lisp
(query '((= ?x (f a b))))
(query '((= ?x (a b c))))
(query '((= (a . ?tail) (a b)))) ; ?tail = (b)
```

`list`, `cons` and `:compound` have no special constructor meaning.
`(f)` is a one-element list in data position and an `f/0` call in goal position.
Input terms, answers and callback values use the same representation.

Unification uses rational trees by default, without an occurs check; shared and
cyclic cons graphs are supported in ordinary execution. Atomic comparisons use
EQL, so distinct strings are not unified by their contents. Set `*print-circle*`
to T when printing cyclic answers. See [Builtins](BUILTINS.md) for explicit
occurs-check unification and term inspection.

Unknown predicates raise an existence error by default; the `unknown` flag can
select failure instead. Builtins cannot be overwritten.

## Lisp callbacks

```lisp
(let ((items '(a b c)) (results nil))
  (prolog
    (lisp ?items items)
    (append ?xs ?ys ?items)
    (lisp (push (list ?xs ?ys) results)))
  (nreverse results))
```

- `(lisp ?output expression)` unifies the expression's result with the output.
- `(lisp expression)` evaluates the expression and succeeds regardless of its value.
- `(lispp expression)` succeeds when the expression returns a true Lisp value.
- `prolog` enumerates answers and normally returns NIL.

Callbacks capture their lexical environment, including in clause definitions.
Their logic-variable inputs are copied Lisp data; use ground inputs. There is no
host API for manipulating unbound logic variables. Symbols beginning with `?`
are detected as callback variables even inside quoted expressions.
Lisp side effects are not undone by backtracking.

`return-from prolog` and Lisp exceptions release the VM through host
`unwind-protect`. A Prolog cleanup construct spanning backtracking is not
implemented. Allegro variable APIs and full interactive API compatibility are not implemented.

### Lexical LET

`(let name initializer)` introduces a Lisp variable for subsequent bridge
expressions in the same source goal sequence. It is a source control construct,
not a logic-variable unification or a runtime callable predicate.

```lisp
(<-- (adjusted ?n ?out)
  (let offset 10)
  (lisp ?out (+ ?n offset)))
(query '((adjusted 3 ?out))) ; => (((?out . 13)))

(prolog
  (let counter 0)
  (or (= ?n 3) (= ?n 4))
  (lisp ?out (incf counter ?n))
  (lisp (format t "~D -> ~D~%" ?n ?out)))
;; Prints 3 -> 3, then 4 -> 7.
```

Initializers can reference bound logic variables, surrounding Lisp lexical
variables and earlier LET bindings. Successive LET forms bind sequentially;
a repeated name shadows its previous binding after evaluating the initializer.
The name must be a nonspecial Lisp variable, not a `?` logic variable, keyword
or constant. An optional third argument may be a Lisp DECLARE form, for example
`(let offset 10 (declare (type integer offset)))`.

Bindings are visible to `lisp` / `lispp`, later initializers and source
conjunction, disjunction, if-then, once and negation forms. Branch-local bindings stay within their source branch; callee
bindings do not replace caller bindings. DCG `do` also supports LET.
`setq`, `setf` and escaping closures work through a shared lexical cell.
Lisp assignments and other side effects are not undone by backtracking.

Backtracking within the continuation retains the cell; returning to a choice
before LET and reexecuting it creates a new cell and reruns the initializer.
Separate calls and cursors have independent cells. Cells survive cursor yields,
GC and ordinary callers' tabled suspensions, without adding Lisp stack frames.
Escaping Lisp closures can retain them after the cursor closes.

Use LET through `<-`, `<--`, `?-`, `prolog` or DCG definition macros, which compile
the Lisp expressions. Raw runtime `query` data does not compile embedded Lisp
forms; it can call predicates already defined with LET.
Existing restrictions on host callbacks in SLG generators and conditional
answers also apply to LET initialization and access. Dynamic special bindings,
SPECIAL declarations and Allegro-style `let*` are not implemented.

## DCGs

`-->` appends a grammar clause; `--->` replaces clauses of the same grammar name
and arity. Expansion adds input and remainder arguments to each nonterminal,
then compiles the result with the ordinary WAM backend.

```lisp
(---> (article) '(the))
(---> (noun cat) '(cat))
(--> (noun dog) '(dog))
(---> (sentence ?noun) (article) (noun ?noun))

(query '((phrase (sentence ?noun) (the cat))))
;; => (((?noun . cat)))
(query '((phrase (sentence ?noun) ?tokens)))
;; => (((?noun . cat) (?tokens the cat))
;;     ((?noun . dog) (?tokens the dog)))
(query '((phrase (sentence ?noun) (the dog extra) ?rest)))
;; => (((?noun . dog) (?rest extra)))
```

| Grammar form | Meaning |
|---|---|
| `(noun ?x)` or `noun` | Nonterminal call |
| `'(a b ?x)` | Token sequence; variables and compound tokens unify |
| `'()`, `(and)`, or an empty rule body | Empty sequence |
| Consecutive body forms or `(and A B ...)` | Sequence |
| `(or A B ...)` | Ordered alternatives; wrap multi-form branches in `and` |
| `(do G1 G2 ...)` | Ordinary goals without consuming input |
| `!` or `(!)` | Cut within the current grammar predicate |

`quote`, `and`, `or` and `do` are reserved DCG body syntax. Quote marks a token
sequence rather than making its variables constant. The sequence must be a
finite proper list; individual tokens may be arbitrary Lisp terms.

```lisp
(let ((offset 10))
  (---> (adjusted ?out)
    '(?n)
    (do (lispp (integerp ?n))
        (lisp ?out (+ ?n offset)))))
(query '((phrase (adjusted ?out) (3)))) ; => (((?out . 13)))
```

`phrase/2` requires complete input consumption; `phrase/3` exposes the remainder.
Its grammar argument may be a nonterminal or an inline grammar expression.
Generated variables are hygienic and omitted from answer alists. Inline phrase
expressions have their own cut boundary and preserve caller alternatives.

The Lisp function `phrase` accepts runtime grammar data:

```lisp
(phrase '(sentence ?noun) '(the cat))
(phrase '(sentence ?noun) '?tokens nil :limit 1 :gc-threshold 64)
(phrase ''(the cat) '(the cat)) ; Pass (quote (the cat)) as grammar data.
```

Supply the optional remainder before keyword arguments. For lexical callbacks,
use definition macros, `?-` or `prolog`. Streaming queries use `make-query` with
`((phrase ...))` goals. `dcg-expand` returns the expanded head and body as two values.

Legacy `:terminals`, `:seq`, `:or`, `:goal` and `:goals` forms remain accepted.
Alternatives execute within a shared environment, so prefix side effects run
once rather than once per branch. Saved branch environments are GC roots.

Dynamic nonterminal calls, semicontext/push-back and grammar-level negation or
conditionals are unsupported. Strings are not automatically converted to
character/code sequences. Untabled left recursion may diverge; table the expanded
arity to evaluate left-recursive grammars with SLG.

## SLG resolution

`(table 'name arity)` enables variant tabling; `(untable 'name arity)` disables it.
Both accept an optional database argument. Declarations may precede or follow
clause definitions.

```lisp
(table 'path 2)
(<-- (path ?x ?y) (path ?x ?z) (edge ?z ?y))
(<- (path ?x ?y) (edge ?x ?y))
(<-- (edge a b)) (<- (edge b c)) (<- (edge c a))
(query '((path a ?y)))
;; => (((?y . b)) ((?y . c)) ((?y . a)))
```

Calls differing only in variable names share a table; variable-sharing patterns
are part of the key. Generators produce answers, while consumers suspend copied
WAM continuations and resume for new answers. Variant duplicate answers are
removed. Answer subsumption is not implemented. Answer order can differ from
ordinary depth-first execution.

A queue scheduler records positive and negative dependencies between call
variants. Iterative graph traversal computes dynamic strongly connected
components (SCCs). A component completes when its work and outgoing unfinished
dependencies are resolved. Calls to child components wait for completion;
recursive calls within the same component suspend as consumers.
Continuation copying can use substantial memory when many consumers suspend.

### Negation and truth values

`(tnot (p ...))` requires a declared tabled predicate and ground arguments when
selected. Nonground negation raises a floundering error. Negation can be delayed
and simplified as tables complete; unresolved negative cycles are undefined.

```lisp
(table 'p 0) (table 'q 0)
(<-- (p) (tnot (q)))
(<-- (q) (tnot (p)))
(query '((p)) :truth-values t)
;; => ((:truth :undefined :bindings nil :delays ((q))))
```

`query` normally collects only true answers; `?-` displays conditional answers
as undefined. With `:truth-values t`,
`query` returns `(:truth :true-or-undefined :bindings alist :delays goals)`.
Each delayed goal represents a negation whose truth remains unresolved.
Different conditional derivations may yield different delay lists for the same
bindings. A true derivation removes matching conditional variants. False goals
produce no answers.

`next-solution` additionally returns truth as its third value and delays as its
fourth. Its second value is T for conditional answers as well.

### Tabled grammars

```lisp
(table 'letters 2) ; A zero-argument grammar expands to arity two.
(---> (letters) (letters) '(a))
(--> (letters))
(query '((phrase (letters) (a a a)))) ; => (NIL)
```

### Cuts and limitations

Ordinary choice points and completed-table answer alternatives can be pruned.
A cut crossing an unfinished tabled call raises `slg-incomplete-cut`. The check
depends on reached calls and their current SCC/completion state.

```lisp
(table 'first-path 1)
(<-- (first-path ?x) (path a ?x) !)
(query '((first-path ?x))) ; Select one answer after PATH completes.

(table 'bad 1)
(<-- (bad ?x) (bad ?x) !)
(<- (bad base))
(query '((bad ?x))) ; SLG-INCOMPLETE-CUT: crosses an unfinished recursive call.
```

A caller's cut leaves other answers in a completed child table intact.
Generator-entry and helper-local cuts are supported, as are DCG cuts and opaque
phrase boundaries. Logical cut scope identities survive continuation copying.
Illegal cuts and other execution errors abort the cursor and release partial
tables; create a new query instead of resuming that cursor.

- Tables are query-local and released on exhaustion or `close-query`.
- Lisp callbacks are unsupported inside generators and after conditional answers;
  ordinary callers receiving completed true answers may use them.
- Cyclic table keys and answers are unsupported; ordinary SLD rational trees remain supported.
- Changing clauses or declarations after tabling starts invalidates the active cursor.
- Termination requires finitely many call variants and answers, plus terminating
  untabled work; unbounded term growth is not covered.
- Nonground negation, incremental tabling, call/answer subsumption, answer
  aggregation and immediate completion from ground success are unsupported.

Design reference: [XSB Programmer's Manual](https://xsb.sourceforge.net/manual1/manual1.pdf).
The implementation does not use XSB code or claim full XSB/SWI-Prolog compatibility.

## WAM execution

The WAM interpreter generates granular term instructions and remains the
reference backend used by `:execution-mode :wam`. The default `:auto` policy may
execute eligible predicate groups as compiled Lisp; see
[Native specialization](#native-specialization).

| Family | Instructions |
|---|---|
| Head matching | get-variable/value/constant/list/structure |
| Body construction | put-variable/value/constant/list/structure |
| Read/write scanning | unify-variable/value/constant/void |
| Write-mode construction | set-variable/value/constant/void |
| Control | allocate, deallocate, call, execute, proceed |

A registers alias X registers. Clause variables occupy Y slots; temporary term
references use X registers. Variable cells live on the heap, so classic WAM
unsafe/local instructions for stack-variable relocation are unnecessary.
`disassemble-predicate` displays compiled instructions.

Short proper lists beginning with a symbol can use structure instructions;
long and open lists use list instructions. Both preserve native cons semantics.
The structure-recognition bound is an optimization, not a limit on term size.
This is not a contiguous classic WAM tagged-cell heap.

Interpreted WAM calls do not use Lisp recursion. Unification, compilation, term
export, graph copying and GC traversal also use explicit work lists. User callback
recursion is outside this guarantee. The compiled direct tier uses host recursion
only up to its configured depth bound and then continues on the heap arena, as
described under [Native specialization](#native-specialization). First-argument
indexing is not implemented.

### Native specialization

`make-database` also accepts `:execution-mode`: `:auto` (default) compiles
eligible deterministic/semideterministic ground-input predicate groups to Common
Lisp and `:wam` keeps the interpreted backend only. Either policy answers
identically; `query-statistics` adds `:native-calls` and
`:native-deoptimizations`. Deep semidet recursion that would exhaust the host
stack continues on a heap-arena tier with the same budget and still counts as one
native call. Unsupported, open, cyclic, effectful, tabled, instrumented or
over-budget calls keep the WAM automatically. See
[Native predicate specialization](NATIVE-JIT.md) for eligibility and limits.

```lisp
(query '((fac 10 ?r)) :database (make-database :execution-mode :wam))
```

## Garbage collection and updates

VM GC tracks variable cells and VM-created cons cells. Nonmoving mark/compact
compresses ownership vectors while preserving object identity; SBCL GC performs
physical reclamation. External Lisp cons graphs are traversed but not included
in managed allocation counts.

Roots include current registers/environments, saved continuations, choice-point
arguments and environments, query variables, term scan positions and generator
answer arguments. Only necessary undo records for reachable variables survive.
Choice-point heap/trail marks are remapped after compaction. Monotonic allocation
ages preserve conditional-trailing decisions across GC.

Automatic GC runs at safe instruction boundaries. The default starting threshold
is 4,096 cells and adapts to the live set. Ownership-vector capacity also shrinks.

```lisp
(let ((cursor (make-query '((append ?xs ?ys (a b c))) :gc-threshold 64)))
  (unwind-protect
      (progn
        (next-solution cursor)
        (collect-query-garbage cursor)
        (query-statistics cursor))
    (close-query cursor)))
(query '((append ?xs ?ys (a b c))) :gc-threshold nil) ; Disable automatic VM GC.
```

GC reduces retention of dead terms; live choices, non-tail continuations and
outputs still consume memory. Collected query results and compiled code are not
part of the managed heap statistics. Exhaustion and `close-query` release VM roots.

`query-statistics` reports instruction, continuation, choice, managed-cell, trail
and GC counts. Its `:slg` field reports tables, answers, suspensions/resumptions,
copied continuations, worker instructions and component statistics. Outer-VM
heap counts are not total SLG or process memory. Active workers use VM GC;
saved continuations are retained through Lisp GC roots.

Clause updates publish immutable code snapshots. Existing calls keep their entry
alternatives; later calls see the new definitions. Builtin assert/retract uses
the same logical update view. Full static/dynamic directive classification is
not implemented.

See [Builtins](BUILTINS.md) for predicate semantics and [Validation](VALIDATION.md)
for tested behavior and limits.
