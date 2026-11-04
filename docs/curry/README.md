# ooparts/curry

An automatically curried Common Lisp user environment, plus explicit `/c`
functions and definition macros. Runtime code uses ANSI Common Lisp and
ASDF/UIOP; no implementation introspection or external Lisp libraries are used.

## Start a curried REPL

```lisp
(asdf:load-system "ooparts/curry/user")
(ooparts/curry/user:enter)

(defun add (x y &optional (z 0)) (+ x y z))
(funcall (add 1) 2 3)                  ; => 6
(funcall (cons 1) 2)                   ; => (1 . 2)
(funcall (mapcar #'1+) '(1 2))          ; => (2 3)
(funcall (funcall #'(lambda (x y) (+ x y)) 1) 2) ; => 3
```

`enter` selects the `ooparts/curry/user` package and its private readtable in
its current dynamic scope. It does not modify `CL`, the existing `CL-USER`, or
the standard readtable. `nix run .#repl-curry-sbcl` loads this environment too.

The user package exports the standard CL names. Global functions use curried
wrappers, and the defining forms below use their `/c` counterparts. Other
standard syntax, constants and dynamic variables are inherited from CL.
Lexically provided `call-next-method` and `next-method-p` remain standard CL
names, rather than being replaced with global functions.

The custom readtable makes `#'(lambda ...)` create a curried function. Merely
selecting the package with `in-package` is insufficient for this reader syntax;
use `enter`, or dynamically bind `*readtable*` to `*curried-readtable*` while
reading. Plain `(lambda ...)` and `(function (lambda ...))` also work.

For source files, arrange to load and enter the environment before reading
curried source, for example from a launcher. A package using this environment
should use `ooparts/curry/user` instead of also using `cl`, since the replaced
symbols intentionally conflict. Code needing literal standard symbols can use
`cl:` explicitly. This is an opt-in language environment, not a claim that every
program observing package/symbol identity is unchanged.

## Explicit API

```lisp
(asdf:load-system "ooparts/curry")
(ooparts/curry:defun/c add (x y) (+ x y))
(funcall (add 2) 3)                    ; => 5
(funcall (ooparts/curry:cons/c 1) 2)    ; => (1 . 2)
```

| Public macro | Standard counterpart |
|---|---|
| `defun/c` | `defun` |
| `flet/c` | `flet` |
| `labels/c` | `labels` |
| `lambda/c` | `lambda` |
| `defgeneric/c` | `defgeneric` |
| `defmethod/c` | `defmethod` |
| `defclass/c` | `defclass` |
| `defstruct/c` | `defstruct` |
| `define-condition/c` | `define-condition` |

Use `lambda/c` as a function-producing expression; `#'(lambda/c ...)` is not
standard lambda syntax. The user readtable handles `#'(lambda ...)` instead.

## Ordinary lambda lists and evaluation

All ordinary lambda-list sections are supported: required parameters,
`&optional` including supplied-p variables, `&rest`, `&key` including explicit
keyword names and supplied-p variables, `&allow-other-keys`, and `&aux`.
The corresponding standard generic-function, specialized method and BOA
constructor lambda-list restrictions still apply. Macro lambda lists with
`&whole`, `&environment`, `&body` or destructuring are not ordinary lambda lists;
macros retain their native CL protocols.

A call collects argument groups in order until the number of required arguments
is reached. It then passes **all** collected arguments to the native binding
code immediately. Optional and keyword arguments do not postpone execution.

```lisp
(ooparts/curry:defun/c weighted (x y &optional (scale 1))
  (* scale (+ x y)))
(funcall (weighted 2) 3 10)            ; => 50
(weighted 2 3)                        ; => 5, already executed

(ooparts/curry:defun/c gather (x y &rest tail)
  (list x y tail))
(funcall (gather 1) 2 3 4)             ; => (1 2 (3 4))
```

Defaults, auxiliary initializers and the body run only on completed calls, in
standard binding order. Supplied arguments are evaluated normally by the caller.
Partial applications are reusable. Argument-list spines are copied, including
those supplied through `apply`, but argument object identities are preserved.
Multiple values, lexical closures, local-function scope, declarations and named
body blocks follow the standard counterparts. Parameter initializers remain
outside the implicit body block. A zero-argument definition still defines a
function, executed on a call rather than at definition time.

There is no automatic application of excess arguments to a returned function.
Extra arguments and invalid keywords are handled by the underlying native
lambda list. Compiler safety settings retain their usual effects.

### Variadic standard functions

The catalog provides `/c` wrappers for 636 standard global function names.
Wrappers are generated automatically from the reviewed required-arity table in
[cl-functions.json](../../tools/curry/cl-functions.json). The initial table was
obtained from SBCL 2.6.8's `SB-INTROSPECT:FUNCTION-LAMBDA-LIST`; no SBCL code or
introspection is needed to compile or run the library on other hosts.

The threshold is the native required count. Thus `+/c` and `list/c`, whose
required count is zero, execute immediately. To request a larger collection
threshold, use `curry` with an explicit nonnegative count:

```lisp
(funcall (funcall (ooparts/curry:curry #'+ 2) 10) 20) ; => 30
```

`curry` accepts a function object or global function name and always returns a
function. It does not change the target's argument-binding semantics.

Generalized places such as `(setf (car/c object) value)` delegate to the native
setf expansion. Standard names that also designate types, such as `cons`,
`string`, `eql` and `mod`, retain type aliases in the user package. Method
specializers and `find-class` calls canonicalize these standard class aliases.
This does not make the new symbols `eq` to their CL counterparts.

A host missing a standard native entry point cannot execute that native
operation. The wrapper is still exported and can collect incomplete arguments;
lookup of the native function is delayed until a completed call. Tests record
native availability rather than inventing missing host implementations.

## Generic functions and generated functions

```lisp
(ooparts/curry:defgeneric/c combine (left right))
(ooparts/curry:defmethod/c combine ((left integer) (right integer))
  (+ left right))
(funcall (combine 2) 3)               ; => 5

(ooparts/curry:defclass/c box ()
  ((value :initarg :value :accessor box-value)))
(let ((object (make-instance 'box :value 1)))
  (funcall (funcall #'(setf box-value) 7) object)
  (box-value object))                 ; => 7

(ooparts/curry:defstruct/c (point (:constructor make-point (x y))) x y)
(point-x (funcall (make-point 1) 2))   ; => 1
```

`defmethod/c` implicitly creates a native generic if necessary. Explicit
`defgeneric/c` is available for generic options and inline methods. Argument
collection happens before method selection. Specializers, method combination,
`:before`, `:after`, `:around`, `call-next-method` and method body blocks are
handled by the native generic function.

**Public generated names designate ordinary wrapper functions, not generic
function objects.** The native target is available as
`(uncurried-function 'combine)`, also accepting `(setf name)` function names.
Use it with `find-method`, `add-method`, `remove-method` or generic introspection.
Keep definitions of a given public generic/accessor in the curried interfaces;
an unrelated existing ordinary definition is not silently adopted. The explicit
`defun/c`, local and anonymous macros do not register native targets with this
accessor. Standard `/c` wrappers and their user aliases are registered.

`defclass/c` wraps requested `:reader`, `:writer` and `:accessor` methods. It
preserves the class name, superclass graph, slots and native instance layout;
it does not generate a new class-specific constructor. `make-instance` remains
the native constructor protocol through its standard wrapper.
`define-condition/c` similarly wraps condition readers.

`defstruct/c` wraps constructors, predicates, copiers, readers and writable
setf functions, preserving the structure name and native layout. Keyword
constructors have zero required parameters and run immediately. BOA constructors
use their required parameter count. Disabled generated functions and read-only
slots remain disabled/read-only. `:include` is supported for parents previously
defined with `defstruct/c`, whose slot metadata is available portably; the
library does not use host internals to enumerate an unrelated native structure.

## Declarations and diagnostics

An `ftype` must describe the curried calling convention. A fixed binary function
returning an integer contradicts unary partial calls returning functions. Avoid
that declaration or use a sufficiently broad function type. This includes
`declare`, `declaim` and `proclaim`; declarations on original argument variables
remain useful. The library does not silently remove inconsistent declarations.

No blanket warning-free guarantee is made for arbitrary source. For example,
SBCL can issue a style warning for combining `&optional` with `&key` even for
native functions. Documentation strings follow standard positions, but their
retention depends on the host; CLISP can discard compiled metadata for functions
with uninterned parameter names. Tests compare against equivalent native forms.

## Generation and validation

```sh
python3 tools/curry/generate-cl.py --check
python3 tools/check-layout.py
python3 tools/lisp.py tools/test.lisp curry
python3 tools/lisp.py tools/test.lisp test
python3 tools/lisp.py tools/curry/compile-clean.lisp
```

`generate-cl.py` regenerates namespace declarations and catalog data; wrapper
bodies are emitted by a macro from that catalog. Review arity-table changes
before regeneration. All curry regressions use `ooparts/test`. The compiler
check compiles the core macro definitions and clients together in a fresh
process. Set `OOPARTS_CURRY_BUILD_DIRECTORY` for a separate writable output path.
See [VALIDATION.md](VALIDATION.md) for the recorded host matrix.

[SRFI 232](https://srfi.schemers.org/srfi-232/srfi-232.html) provides a related
Scheme mechanism. This is an independent Common Lisp implementation; it does not
adopt surplus-result application or immediate nullary-definition evaluation.
