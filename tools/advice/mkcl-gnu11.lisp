;;; Explicit development-toolchain setup for the behavior audit.
;;; MKCL 1.1.11 emits old-style C function pointer calls. The compiler shipped
;;; by the locked Nixpkgs rejects those calls in its default C language mode.
;;; GNU11 restores that source language without changing Lisp lookup semantics.
#+mkcl
(setf compiler::*cc-flags* (concatenate 'string compiler::*cc-flags* " -std=gnu11 ")
      compiler::*fast-compile-cc-flags*
      (concatenate 'string compiler::*fast-compile-cc-flags* " -std=gnu11 "))
