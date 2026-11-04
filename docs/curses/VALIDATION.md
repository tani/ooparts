# Validation

Linux validation, 2026-11-04. Every host passed the same 379-routine inventory
and execution gate and all 53 frozen behavior scenarios. See [the coverage
summary](COVERAGE.md) and the per-host JSON files in [reports](reports/).

| Host | Version | API defined/exercised | Feature scenarios | Native PTY |
|---|---|---|---|---|
| SBCL | 2.2.9 | 379/379 | 53/53 | Pass |
| CCL | 1.14 | 379/379 | 53/53 | Pass |
| ECL | 21.2.1 | 379/379 | 53/53 | Pass |
| MKCL | 1.1.11 | 379/379 | 53/53 | Pass |
| CLISP | 2.49.93+ | 379/379 | 53/53 | Pass |
| CMUCL | 21f, x86 under qemu-i386 | 379/379 | 53/53 | Pass |
| Clasp | 2.6.0 development build | 379/379 | 53/53 | Pass |
| ABCL | 1.9.0, OpenJDK 17.0.20 | 379/379 | 53/53 | Pass |

ABCL was launched with:

```text
--add-modules=jdk.incubator.foreign
--enable-native-access=ALL-UNNAMED
```

The native PTY probe independently inspects raw/cbreak flags, ISTRIP and
NOFLSH settings, feeds escape and UTF-8 input, checks non-BMP UTF-8 output,
changes kernel terminal dimensions, and compares the full termios snapshot
before and after a deliberate Lisp error. This is separate from the stream
acceptance scenarios and the API-entry observer.

The Python gate's negative tests verify that an API-definition deficit, an
API-execution deficit, a behavior-test deficit, an unexpected scenario, or a
nonzero process exit cannot pass the gate. Layout and whitespace checks passed.

A truncated ABCL FASL cache artifact was observed during validation;
recompiling that development cache restored the definitions, and
the subsequent complete coverage and native checks passed. No host software
was patched. Generated cache files are not distributed.

macOS execution and Nix builds were unavailable locally; the adapters and Nix
checks are provided without claiming runtime verification on macOS. Windows
is explicitly outside scope. These results are not line/branch coverage or
universal ncurses conformance: [README](README.md) documents the metric scope
and remaining compatibility boundaries.
