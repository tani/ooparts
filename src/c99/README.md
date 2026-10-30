# OOPArts C99 compiler (bootstrap)

This is an **initial compiler slice**, not a conforming C99 compiler.
It uses `ooparts/regexp` for lexical recognition and
`ooparts/prolog` DCG for syntactic analysis.

## Current accepted translation units

```c
int main() { return 42; }
```

Only a single zero-parameter `int` function with a decimal integer constant
return statement is accepted. Comments and whitespace are supported.
No preprocessing, string literals, declarations, operators, `void` parameter
lists, header files, linking, or complete C99 semantics are implemented.
Out-of-subset input fails rather than silently miscompiling.

## Lisp interface

```lisp
(asdf:load-system "ooparts")
(ooparts/c99:compile-c99 "int main(){return 42;}" :target :aarch64-macos)
```

`compile-c99` returns assembly text. The target keywords are
`:x86-64-linux`, `:x86-64-macos`, `:aarch64-linux`,
and `:aarch64-macos`. Compile the resulting assembly with the target
platform's C compiler driver to produce an executable. The driver and C
runtime are *not* bundled. This is native-target assembly generation, not
cross-platform object emission.

## Follow-up implementation stages

1. Translation phases (line splicing, macro expansion, includes, preprocessing tokens).
2. Complete C99 lexical forms and grammar, with typedef-name contextual disambiguation.
3. Typed AST and semantic validation (declarations, scopes, types, conversions).
4. Structured IR, control-flow lowering, storage duration, relocations.
5. System V AMD64, AAPCS64, and Darwin ABI lowering; object/linker integration.
6. Differential execution tests, C99 conformance suites, platform CI.
