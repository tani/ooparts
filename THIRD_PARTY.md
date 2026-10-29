# Third-party sources and references

OOPArts' original code is MIT licensed; see [LICENSE](LICENSE). Imported source,
ports, documentation assets and their notices retain their own licenses. The
machine-readable [ledger](third-party.json) distinguishes distributed material
from design references and optional external tools. A reference does not imply
that its implementation was copied or that its license applies to OOPArts.

| Distributed material | Source/version | License and retained notices |
|---|---|---|
| SAT engine/layout, original C, upstream CNFs | [SATCH](https://github.com/arminbiere/satch), `b4d4081f8971931399b36c8fdd92bdf4aabac005`, 0.5.6rc | [MIT](licenses/satch-MIT.txt), [port notice](licenses/satch-NOTICE.txt) |
| Prolog library imported into OOPArts | [cons-prolog](https://github.com/tani/cons-prolog), imported version 0.10.0 | [MIT](licenses/cons-prolog-MIT.txt), Masaya Taniguchi |
| Original and ported ISO examples | [Logtalk](https://github.com/LogtalkDotOrg/logtalk3), `e0f2576eef32aa5d5732a0d47531d0f62b9a31f1` | [Apache-2.0](vendor/logtalk/original/LICENSE.txt), [original notice](vendor/logtalk/original/NOTICE.txt), [port notice](vendor/logtalk/ported/NOTICE.txt) |
| Offline mathematics renderer | [MathJax](https://github.com/MathJax/MathJax/tree/3.2.2), 3.2.2 `tex-svg.js` | [Apache-2.0](vendor/mathjax/LICENSE), [asset attributions](licenses/mathjax-NOTICE.txt) |
| Speech Rule Engine embedded in that browser bundle | [Speech Rule Engine](https://github.com/Speech-Rule-Engine/speech-rule-engine/tree/v4.0.6), 4.0.6 | [Apache-2.0](licenses/speech-rule-engine-Apache-2.0.txt), [upstream notice](licenses/speech-rule-engine-NOTICE.txt) |
| Context-menu code embedded in that browser bundle | [mj-context-menu](https://www.npmjs.com/package/mj-context-menu), MathJax release dependency `^0.6.1` | [Apache-2.0](vendor/mathjax/LICENSE), [asset attributions](licenses/mathjax-NOTICE.txt) |
| Renamed subset documentation font | Adobe Source/Noto-derived font, metadata version 2.004 | [SIL OFL 1.1](vendor/docs-font/OFL.txt); family renamed to `SCPS Docs Sans` |

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

The MathJax and font bytes are preserved from the pre-refactor OOPArts tree
`aa5bcced22c1eccc62cc254faa21e43ac2cc8baa`. The renderer identifies MathJax
3.2.2 and SRE 4.0.6. MathJax's release metadata declares `mj-context-menu`
`^0.6.1`; that range is not asserted to be a verified exact embedded version.
The font's name table identifies the renamed family, Adobe copyright and a
NotoSansJP-derived unique ID. An exact original font source revision was not
recorded at import; its digest fixes the actual distributed bytes. Do not
substitute an unrelated Source Sans font provenance claim.

The original cons-prolog import did not record a separate upstream commit ID.
Its version and OOPArts import commit are recorded in the ledger; a current
upstream HEAD must not be represented as the revision used for that import.

## References and optional dependencies

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
  optional external comparison/conversion executable. None is a Lisp runtime
  dependency of this repository.

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
