# Portability

All three libraries use package-inferred systems. The public continuation
system remains `ooparts/continuation` (singular). No compatibility nicknames or
additional explicit systems are introduced.

## Reader-selected implementations

| Component | Native path | Portable path |
|---|---|---|
| SAT storage | `#+(and sbcl x86-64 (not ooparts-portable-sat))`: checked system-area pointers | Growable octet vectors, integer virtual addresses and explicit little-endian words |
| SAT locking | `#+(and sbcl sb-thread)`: recursive SB-THREAD mutex | Bordeaux Threads recursive lock; its single-thread fallback is permitted |
| Continuation environments | `#+sbcl`: SB-CLTL2 | CL-ENVIRONMENTS.CLTL2 augmented environments |
| Callable continuations | `#+sbcl`: SB-MOP; `#+mkcl`: native CLOS MOP | Closer to MOP funcallable objects |
| GC/thread regression checks | SBCL APIs | Trivial Garbage and Bordeaux Threads |

The SAT engine and public API are shared by both storage paths. The portable
backend retains the translated LP64 layout even on a 32-bit or big-endian host;
it does not reinterpret the host's pointers or object representation. Both
paths enforce the existing 256 MiB heap and 16 MiB automatic-storage limits.
Portable vectors grow on demand and retain virtual addresses when resized.
Binary single/double floats with 24/53 significant bits are required. Supported
finite values follow the host's float range; non-finite encoded values signal
an error. Subnormal and signed-zero regression checks run when the host
represents those values.

SBCL/Linux retains native resource accounting. Other platforms use
`get-internal-run-time` for process time and report zero for unavailable OS
memory counters. A missing native process ID is reported as zero; it is only
used for optional process information, not solving.

The continuation compiler recognizes portable handler and iteration syntax
before non-SBCL macro expanders introduce private operators. Dynamic handler
frames are reinstated on continuation invocation. Handler-case transfers leave
protected extents before running a clause. Missing PROGV values create unbound
bindings directly. On ABCL and ECL, an adapter updates the virtual binding when MAKUNBOUND would
otherwise clear only the global value. It preserves that global value and
installs the unbound dynamic binding at the next trampoline step.

On CMUCL, augmenting an empty macro environment first creates a native empty
environment object. Callable continuation closures use `kernel:instance-lambda`
to follow CMUCL's funcallable-instance calling convention.

## Dependencies

SBCL needs only its bundled ASDF/UIOP, SB-CLTL2, MOP and thread facilities.
Other implementations need the following systems in ASDF's source registry:

- SAT: `bordeaux-threads`.
- Continuations: `cl-environments` and `closer-mop`.
- Continuation tests: also `bordeaux-threads` and `trivial-garbage`.

For CLISP, CMUCL and MKCL, the flake pins Bordeaux Threads 0.8.8;
0.9.4 rejects some of these implementations or requires unsupported atomics.
It also patches the external environment library's list-valued DEFCONSTANTs
to DEFPARAMETERs so compiling and loading it works on Clasp. These dependency
patches are applied during the Nix build, outside the OOPArts source tree.
A package manager such as Quicklisp or the root Nix flake resolves their
transitive dependencies. See [the license ledger](../THIRD_PARTY.md) for license
and distribution boundaries. No external C solver or FFI is used by SAT.

The Nix flake exposes the aggregate on available SBCL, ECL, ABCL, CCL, CLISP,
CMUCL and Clasp implementations. Actual availability depends on the selected
platform and the dependency packages. MKCL exposes Prolog and SAT variants; the
current third-party environment/MOP stack does not advertise MKCL support.
Availability of a Nix attribute is not itself evidence of a successful run.

## Reproduce validation

`tools/lisp.py` selects implementation flags, forwards script arguments and
separates native/portable ASDF caches. Use `--lisp /path/to/executable` for a
custom binary. `--bootstrap setup.lisp` can initialize an existing dependency
installation before loading OOPArts.

```sh
python3 tools/lisp.py --implementation sbcl tools/test.lisp
python3 tools/lisp.py --implementation ecl tools/test.lisp sat
python3 tools/lisp.py --implementation clisp tools/test.lisp continuation
python3 tools/lisp.py --implementation abcl tools/test.lisp continuation
python3 tools/continuation/reload.py --implementation clisp

python3 tools/lisp.py --portable-sat tools/test.lisp sat
python3 tools/sat/differential.py --portable-sat --random 1000 \
  --build-dir build/sat-portable --report build/sat-portable/results.json
python3 tools/sat/proofs.py --portable-sat \
  --build-dir build/sat-portable --report build/sat-portable/proofs.json
```

Add `:ooparts-portable-sat` to `*features*` **before** loading SAT to force the
portable storage path on SBCL x86-64. Reader features change compiled code: use
separate ASDF output caches (as the launcher does), or force a complete rebuild
when toggling this feature. Existing FASLs do not change when `*features*` changes.

Fresh-process FASL reload tests apply to every implementation. Saved-core
reload tests are additionally run on SBCL; dumping images is not an ANSI
Common Lisp operation. The continuation suite reports one fewer check when
its implementation has no threads. SAT storage checks similarly reflect host
subnormal/signed-zero support. Semantic failures are never skipped.
