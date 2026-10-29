# OOPArts

Common Lisp libraries.

## ooparts/continuation

Selective CPS `shift` / `reset` for SBCL. Supports composable, multi-shot
continuations that can outlive their original `reset`.

```lisp
(require :asdf)
(asdf:load-asd #p"/path/to/ooparts/ooparts.asd")
(asdf:load-system "ooparts/continuation")

(ooparts/continuation:reset
  (+ 1 (ooparts/continuation:shift k
         (+ (funcall k 10) (funcall k 20)))))
;; => 32
```

The package is `ooparts/continuation`; `scps` and `selective-cps` are aliases.
See [the continuation documentation](continuation/README.md) for supported
forms, native boundary restrictions, dynamic environment conventions and tests.

```sh
sbcl --script continuation/example.lisp
bash continuation/tests/run.sh
```

`(asdf:test-system "ooparts/continuation")` runs the regression suite.
The shell script additionally tests FASL and saved-core reloads.

MIT licensed. Requires SBCL and its bundled ASDF / SB-CLTL2 / SB-MOP.

## ooparts/prolog

Lisp-native Prolog with a WAM VM, DCGs, SLG tabling and an ISO textual interface.

```lisp
(asdf:load-system "ooparts/prolog")
(ooparts/prolog:query '((= ?x 42)))
```

See [the Prolog documentation](prolog/README.md).
The public package alias is `ooparts/prolog` (also `prolog`); internal modules
use `ooparts/prolog/src/...`. Build the `ooparts-prolog` command with
`(asdf:make "ooparts/prolog/cli")`.

```sh
sbcl --dynamic-space-size 2048 --control-stack-size 1 --script prolog/tests/run.lisp
```

`ooparts` loads both libraries; `(asdf:test-system "ooparts")` tests both.
Prolog is portable Common Lisp; continuation currently requires SBCL.
Bundled third-party ISO test cases retain their original licenses and notices.
