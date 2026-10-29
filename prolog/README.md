# ooparts/prolog

S-expression Prolog for Common Lisp, with native Lisp cons terms, an explicit WAM execution model, DCGs, SLG variant tabling and VM garbage collection.

An independent implementation inspired by the PAIP / Allegro Prolog APIs. ISO
compatibility is tracked against [bundled ISO tests](docs/ISO-COMPATIBILITY.md) while
preserving Lisp-native terms. Full ISO conformance and full Allegro compatibility
are outside its scope. [MIT licensed](LICENSE); bundled Logtalk-derived test cases
retain Apache-2.0 and their original notices.

## Load

No external Lisp libraries are required. From the repository directory:

```lisp
(require :asdf)
(asdf:load-asd (truename "../ooparts.asd"))
(asdf:load-system "ooparts/prolog")
(use-package :prolog)
```

## Command line

`(asdf:make "ooparts/prolog/cli")` builds a standalone `ooparts-prolog` executable in
the repository directory.

```lisp
(require :asdf)
(asdf:load-asd (truename "../ooparts.asd"))
(asdf:make "ooparts/prolog/cli")
```

```sh
cons [file]        # run Lisp forms (S-expression Prolog), or a REPL with no file
cons --lisp [file] # same, explicitly (native term model)
cons --iso [file]  # strict ISO term model; files and the REPL use Prolog text
```

In the `--iso` REPL, enter full-stop-terminated terms: `?- Goal.` or a bare
goal queries (bindings print in Prolog syntax; `;` shows the next answer),
and `Head :- Body.` asserts through `assertz/1`. `?-` directives inside
script files execute as loader directives (no answer display). EOF exits.

## Nix

The flake follows [nix-common-lisp](https://github.com/tani/nix-common-lisp),
with a pinned `flake.lock` and no external Lisp dependencies.

```sh
nix develop                    # all available implementations
nix develop .#sbcl -c sbcl      # one implementation
nix run .#main-sbcl             # REPL with ooparts/prolog loaded
nix run .#test-sbcl             # complete test suite
nix build .#lib-sbcl            # ASDF library
nix flake check -L              # test all available implementations
```

Replace `sbcl` with `ecl`, `abcl`, `ccl`, `mkcl`, `clisp`, `cmucl_binary`
or `clasp-common-lisp`. Outputs are provided only where the pinned Nixpkgs
supports the implementation. GitHub Actions tests those outputs on Linux
(x86-64 and ARM64) and macOS (ARM64).

ASDF uses `package-inferred-system`: module dependencies are declared by each
file's `uiop:define-package`. Implementation modules own their definitions;
the final API facade has the `ooparts/prolog` and `prolog` nicknames and reexports the public interface.
Internal `ooparts/prolog::` references should use the owning module instead.
See [development notes](docs/DEVELOPMENT.md) for module layout and portability.

## Define and query

```lisp
(<-- (append () ?ys ?ys))
(<- (append (?x . ?xs) ?ys (?x . ?zs))
    (append ?xs ?ys ?zs))

(?- (append ?xs ?ys (a b c)))
```

`<--` replaces clauses of the same name and arity; `<-` appends a clause. `?x` is a logic variable; each `?` is anonymous. `?-` computes and displays one answer at a time. Type `;` followed by Enter for the next answer, or Enter alone to stop. EOF also stops. Failure prints `false.`; success without bindings prints `true.`. It returns no values.

Use `(query '((append ?xs ?ys (a b c))))` to collect all answers as binding alists, or add `:limit` to bound collection.

Terms and lists share the same Lisp cons representation. Write `(f a b)` or `(a . ?tail)` directly. Definition and query macros treat goals as data, so ordinary terms need no quote.

## DCGs

```lisp
(---> (article) '(the))
(---> (noun cat) '(cat))
(--> (noun dog) '(dog))
(---> (sentence ?noun)
  (article)
  (noun ?noun))

(?- (phrase (sentence ?noun) (the cat)))
;; Prints ?NOUN = CAT; Enter stops.
```

`--->` replaces grammar clauses; `-->` appends one. Within a DCG, `'(a b)` denotes a token sequence; variables inside it still unify. Use `and` for sequences, `or` for alternatives and `do` for ordinary goals that consume no input.

## Tabling

```lisp
(table 'path 2)
(<-- (path ?x ?y) (path ?x ?z) (edge ?z ?y))
(<- (path ?x ?y) (edge ?x ?y))
(<-- (edge a b))
(<- (edge b c))
(<- (edge c a))

(?- (path a ?y))
;; Prints ?Y = B; type ; for another answer.
```

SLG supports left and mutual recursion, plus ground `tnot`. Conditional answers display `undefined` and their delayed negations. Cuts over unfinished tables raise an error. See the [user guide](docs/MANUAL.md#slg-resolution) for details and restrictions.

Use `prolog` / `lisp` / `lispp` for lexical Lisp callbacks and `(let name expression)` for a Lisp binding shared by subsequent callbacks and `make-query` / `next-solution` / `close-query` for streaming answers. Builtins cover unification, arithmetic, dynamic definitions, exceptions, answer collection and character/byte I/O.

## Examples and tests

```sh
sbcl --script examples/interactive.lisp
sbcl --script examples/append.lisp
sbcl --script examples/dcg.lisp
sbcl --script examples/slg.lisp
sbcl --script examples/builtins.lisp
sbcl --script examples/let.lisp
sbcl --dynamic-space-size 2048 --control-stack-size 1 --script tests/run.lisp
```

Validated on SBCL 2.2.9 / Linux x86-64: 5,632 checks pass, including one million tail calls with a 1 MiB Lisp control stack.

All Prolog predicates execute through the portable WAM backend. Predicate
specialization and native JIT compilation have been removed; calls do not trigger
Common Lisp compilation. [Earlier native-compiler measurements](docs/COMPETITIVE-BENCHMARKS.md)
are historical results and do not describe the current interpreter.

## Documentation

See the [documentation index](docs/README.md).

- [User guide](docs/MANUAL.md): terms, queries, Lisp callbacks, DCGs, SLG, WAM, GC and limitations
- [Builtins](docs/BUILTINS.md): supported predicates and Lisp-friendly names
- [Implementation layers](docs/PRIMITIVES.md): primitives, syntax, and derived predicates
- [Validation](docs/VALIDATION.md): semantic coverage and stress tests
- [Benchmarks](docs/BENCHMARKS.md): timings, allocation profiles and bottlenecks
- [Roadmap](docs/ROADMAP.md) and [changelog](CHANGELOG.md)

Prolog text can also be loaded with `load-prolog-string`, `load-prolog-file`, or
`load-prolog` from a stream. See [the textual interface](docs/PROLOG-LOADER.md).
READ and WRITE predicates independently select Lisp or Prolog syntax:

```lisp
(query '((set_prolog_flag read_syntax prolog)
         (set_prolog_flag write_syntax prolog)))
```

Both flags default to `lisp`. See [term I/O](docs/BUILTINS.md#term-io-and-reader-configuration)
for writer options and the native cons mapping.

Strict ISO term distinctions are available alongside the default native model:

```lisp
(let ((*database* (make-database :term-model :iso)))
  (query '((= ?list ($cons a ($cons b $nil))))))
```

In this database, `[a,b]` and `'.'(a,'.'(b,[]))` both use
`($cons a ($cons b $nil))`, while `f(a)` remains `(f a)`. `$nil` denotes
`[]`; ordinary `nil` remains a distinct atom. The term model is immutable and
independent of the two syntax flags. See [strict terms and validation](docs/ISO-COMPATIBILITY.md).
