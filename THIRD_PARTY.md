# Third-party sources and references

OOPArts' original code is MIT licensed; see [LICENSE](LICENSE). Imported source,
ports and their notices retain their own licenses. The machine-readable
[ledger](third-party.json) distinguishes distributed material
from native-interface references, design references and optional external tools.
A reference does not imply
that its implementation was copied or that its license applies to OOPArts.

| Distributed material | Source/version | License and retained notices |
|---|---|---|
| SAT engine/layout, original C, upstream CNFs | [SATCH](https://github.com/arminbiere/satch), `b4d4081f8971931399b36c8fdd92bdf4aabac005`, 0.5.6rc | [MIT](licenses/satch-MIT.txt), [port notice](licenses/satch-NOTICE.txt) |
| Prolog library imported into OOPArts | [cons-prolog](https://github.com/tani/cons-prolog), imported version 0.10.0 | [MIT](licenses/cons-prolog-MIT.txt), Masaya Taniguchi |
| Original and ported ISO examples | [Logtalk](https://github.com/LogtalkDotOrg/logtalk3), `e0f2576eef32aa5d5732a0d47531d0f62b9a31f1` | [Apache-2.0](vendor/logtalk/original/LICENSE.txt), [original notice](vendor/logtalk/original/NOTICE.txt), [port notice](vendor/logtalk/ported/NOTICE.txt) |

SATCH is translated with its default features and `NDEBUG`. All 284 preprocessed
library functions are retained. The Lisp control flow, lexical bindings and
names have been adapted; the LP64 packed representation is retained in the
backend. The original C source and CNFs remain unmodified. Regenerate with
`SBCL=sbcl python3 tools/sat/translate.py`; GCC and Python's `pycparser` are
development dependencies, not runtime dependencies.

Logtalk originals are unmodified. Ported cases replace object/fixture wrappers
and record per-case adaptations. The original distribution NOTICE includes
attributions for the full upstream distribution; only the inventoried subset
is bundled here. The corpus has its own [revision and hash lock](vendor/logtalk/upstream.json).
Updating paths in the port NOTICE is recorded in that lock.

The original cons-prolog import did not record a separate upstream commit ID.
Its version and OOPArts import commit are recorded in the ledger; a current
upstream HEAD must not be represented as the revision used for that import.

## Native portability interfaces

The library and regression systems require no external Lisp libraries. They use
only the selected implementation and the ASDF/UIOP system manager. Nix installs no
portability libraries and applies no patches to external source packages.

The ledger retains cl-environments (MIT), closer-mop (MIT), Bordeaux Threads
(MIT) and trivial-garbage (public domain) as native-interface references. These
libraries are not loaded, patched, vendored or distributed by OOPArts. Their
previously selected transitive dependencies are no longer runtime dependencies.
Implementation-specific environment, MOP, thread and GC calls live in small
OOPArts adapters; see [portability](docs/portability.md).

## References and optional dependencies

- [GNU Emacs modern advice](https://www.gnu.org/software/emacs/manual/html_node/elisp/Advising-Named-Functions.html)
  is an API and behavior reference for the independently implemented Common
  Lisp advice library. No Emacs source is distributed here.
- [CCL native encapsulation](https://github.com/Clozure/ccl/blob/v1.13/lib/encapsulate.lisp)
  and [ABCL compiler internals](https://github.com/armedbear/abcl/blob/fc3d78e55a5b338536286b5ef3bc3a041ba174f7/src/org/armedbear/lisp/precompiler.lisp)
  are host-interface references for independently written adapters. The advice
  library invokes CCL native advice and wraps ABCL compiler entry points in
  memory; no upstream source files are copied or modified.
- [QEMU user-mode emulation](https://www.qemu.org/) is an optional development
  tool used to run the Nixpkgs 32-bit CMUCL binary in the recorded advice audit.
  It is not bundled or required by any Lisp library or regression system.
- [PAIP Lisp](https://github.com/norvig/paip-lisp) is an MIT-licensed design/API
  reference for Prolog. No PAIP source files are distributed here.
- [Allegro Prolog](https://franz.com/products/prolog/) is an interface reference.
  No Allegro source or binaries are distributed. This project makes no assertion
  about that product's software license; consult its upstream terms.
- [cl-cont](https://gitlab.common-lisp.net/cl-cont/cl-cont) is a continuation
  reference and optional benchmark baseline. Its 0.3.8 ASDF metadata declares
  LLGPL; none of its source is bundled in OOPArts.
- Continuation benchmark dependencies are downloaded explicitly by
  `benchmarks/continuation/fetch-vendor.py`, pinned by archive hash or commit,
  and kept under ignored `build/continuation/vendor/` with their upstream
  notices. These include cl-cont, Alexandria and closer-mop. SWI-Prolog is an
  optional external comparison/conversion executable. Their use in a benchmark alone does not make them runtime dependencies.

## Inventory verification

`vendor/manifest.json` records SHA-256 hashes for every distributed vendor file.
`python3 tools/check-layout.py` rejects missing, changed, extra or symlinked
vendor files, verifies the Logtalk corpus lock and checks license references.
When intentionally updating a dependency, first review its license, notices,
revision and corpus lock, then explicitly regenerate the vendor inventory:

```sh
python3 tools/check-layout.py --update-vendor-manifest
python3 tools/check-layout.py
```
