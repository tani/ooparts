# Bundled ISO validation

Run from the repository root:

```sh
ISO_SBCL=sbcl python3 -m unittest discover -s tests/prolog/iso -p 'test_*.py' -v
python3 tools/prolog/iso/run.py --baseline tests/prolog/iso/expectations/baseline.json --strict --jobs 2
python3 tools/prolog/iso/run.py --term-model iso --strict --jobs 2 --output build/prolog/iso-strict
```

| Location | Role |
|---|---|
| `tools/prolog/iso/run.py` | Offline isolation, timeouts, validation and reporting |
| `tests/prolog/iso/test_runner.py` | Driver and harness regression checks |
| `tests/prolog/iso/worker.lisp` | Package-inferred SBCL worker |
| `tools/prolog/iso/harness.pl` | Portable Prolog harness |
| `tools/prolog/iso/{regenerate.py,port-logtalk.pl}` | Development-only conversion |
| `tests/prolog/iso/expectations/` | Baseline, exact differences and adaptations |
| `vendor/logtalk/ported/` | Plain Prolog port, license, notice and case inventory |
| `vendor/logtalk/original/` | Unmodified upstream originals and notices |
| `vendor/logtalk/upstream.json` | Pinned revision and complete file hashes |

Normal validation requires Python and SBCL, without network access. Regeneration
additionally needs SWI-Prolog to read Logtalk source syntax:

```sh
python3 tools/prolog/iso/regenerate.py --swipl /path/to/swipl
```

The converter reads bundled sources without executing Logtalk. Regeneration
changes reviewed files: update the corpus lock and `vendor/manifest.json`
explicitly after review. See [ISO compatibility](ISO-COMPATIBILITY.md) for the
782-case inventory, skips, native differences and strict term-model boundaries.
