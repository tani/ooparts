# Portability

All three libraries use package-inferred systems. The public continuation
system remains `ooparts/continuation` (singular). No compatibility nicknames or
additional explicit systems are introduced.

Libraries and regression suites require no external Lisp libraries or patches
to external software. ASDF/UIOP manages the systems; implementation modules such
as SBCL's SB-CLTL2 come with the selected Lisp. Reader conditionals are preferred
when they avoid an external dependency, even when that increases their count.

## Reader-selected implementations

| Component | Native path | Portable path |
|---|---|---|
| SAT storage | `#+(and sbcl x86-64 (not ooparts-portable-sat))`: checked system-area pointers | Growable octet vectors, integer virtual addresses and explicit little-endian words |
| SAT locking | Host recursive lock through `ooparts/host` | No lock on a single-threaded host |
| Continuation environments | Bundled SB-CLTL2, CCL, CMUCL or Clasp CLTL2 interfaces | Native interpreter environments on ECL, ABCL and CLISP |
| Callable continuations | Host MOP funcallable objects | Same public calling convention on every supported host |
| GC/thread regression checks | Host GC and thread operations | Thread checks depend on actual thread support |

The SAT storage facade selects `ooparts/sat/storage/native` or
`ooparts/sat/storage/portable` once. Shared address state lives in
`ooparts/sat/storage/state`; allocation bookkeeping, C arithmetic and streams
remain in the common runtime. Backend accessors retain their inline native
operations and their existing compiler policies. The engine and public API
are shared by both storage paths. The portable
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

The continuation compiler normalizes `incf`, `decf`, `dotimes`, `dolist`,
`handler-bind` and `handler-case` on every implementation before host macro
expanders introduce private operators. Dynamic handler and restart frames use native installers on every implementation.
Their parameters and condition associations are retained as Lisp data; host
handler/restart clusters and short-lived native objects are never captured.
The installers reconstruct the native dynamic context for each trampoline step.
Restart bindings have separate activation identities; cloning a segment
rebases condition associations to those fresh bindings, including recursive
invocation of the same continuation.
The driver skips native context installation when a frame has no handlers or restarts.
`restart-case` is normalized on every implementation as well. Its virtual
exits survive capture and reinstatement. Signaling forms, including lexical
macro expansions, associate every new restart with the signaled condition;
duplicate names, anonymous restarts and condition-sensitive tests are retained.
Handler-case transfers leave
protected extents before running a clause. Missing PROGV values create unbound
bindings directly. On ABCL and ECL, an adapter updates the virtual binding when MAKUNBOUND would
otherwise clear only the global value. It preserves that global value and
installs the unbound dynamic binding at the next trampoline step.

On CMUCL, augmenting an empty macro environment first creates a native empty
environment object. Callable continuation closures use `kernel:instance-lambda`
to follow CMUCL's funcallable-instance calling convention.

## Host adapters

`ooparts/continuation/environment` contains the compiler's small environment
interface. SBCL, CCL, CMUCL and Clasp use their bundled CLTL2 operations. On ECL,
ABCL and CLISP, synthetic LET/FLET/MACROLET/SYMBOL-MACROLET forms extend a native
interpreter environment. The dummy bindings never evaluate user initializers
or CPS bodies. Macro definitions are enclosed by the host, preserving macro
lambda-list parsing and the outer lexical macro environment. The adapter passes
native environments to macro expanders, SETF expanders and CONSTANTP.

ABCL calls its own Lisp evaluator through its bundled Java interface. CLISP's
evaluator needs five environment slots while its macro interface exposes two;
the adapter supplies empty block, tagbody and declaration slots. CMUCL expands
macro-function bodies with its built-in walker before compiling them.

`ooparts/host` selects native recursive locks, thread joins and full-GC requests.
It uses a no-op lock only when the implementation has no thread support.
Callable continuations directly use the implementation's MOP; no compatibility
library patches host classes or generic functions.

The Nix flake exposes the aggregate on available SBCL, ECL, ABCL, CCL, CLISP,
CMUCL and Clasp implementations. Availability depends on the selected platform.
MKCL exposes Prolog and SAT; its continuation environment adapter has not yet
been implemented and validated. Availability of a Nix attribute is not itself
evidence of a successful run.

The license ledger retains previously consulted libraries as references, not
runtime dependencies. Optional comparison programs and translator tools remain
development-only requirements; see [the license ledger](../THIRD_PARTY.md).

## Reproduce validation

`tools/lisp.py` selects implementation flags, forwards script arguments and
separates native/portable ASDF caches. Use `--lisp /path/to/executable` for a
custom binary. `--bootstrap setup.lisp` can initialize a local
toolchain before loading OOPArts.

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
