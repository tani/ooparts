# Bundled ISO tests

Run from the repository root:

```sh
python3 -m unittest discover -s tests/iso -p 'test_*.py' -v
python3 tests/iso/run.py --baseline tests/iso/expectations/baseline.json --strict --jobs 2
python3 tests/iso/run.py --term-model iso --strict --jobs 2 --output iso-results-strict
```

| Location | Role |
|---|---|
| `run.py` | Offline entry point, isolation, timeouts and reporting |
| `test_runner.py` | Driver and harness regression checks |
| `runtime/` | SBCL worker and portable Prolog harness |
| `tools/` | Development-only converter and regeneration script |
| `expectations/` | Native baseline, exact differences and adaptation notes |
| `suite/` | Generated plain Prolog port and per-case inventory |
| `vendor/` | Unmodified upstream originals and license notices |
| `upstream.json` | Pinned upstream revision and corpus file hashes |

Normal execution requires only Python and SBCL. Regeneration additionally needs
SWI-Prolog:

```sh
python3 tests/iso/tools/regenerate.py --swipl /path/to/swipl
```

The converter reads the bundled sources; it does not download or execute Logtalk.
Keep original sources, generated cases and their license notices together with
their hash inventory. See [ISO compatibility](../../docs/ISO-COMPATIBILITY.md)
for provenance, licenses, skips and strict-mode boundaries.
