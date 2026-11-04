# Validation

Local Linux validation, 2026-11-04. Each implementation passed the same 505
checks (including public-export integrity checks), and the native PTY probe.

| Implementation | Version | Stream suite | Native PTY |
|---|---|---|---|
| SBCL | 2.2.9 | Pass | Pass |
| CCL | 1.14 | Pass | Pass |
| ECL | 21.2.1 | Pass | Pass |
| MKCL | 1.1.11 | Pass | Pass |
| CLISP | 2.49.93+ | Pass | Pass |
| CMUCL | 21f, x86 under qemu-i386 | Pass | Pass |
| Clasp | 2.6.0 development build | Pass | Pass |
| ABCL | 1.9.0, OpenJDK 17.0.20 | Pass | Pass |

ABCL was launched with exactly these native-access options:

```text
--add-modules=jdk.incubator.foreign
--enable-native-access=ALL-UNNAMED
```

The PTY probe independently inspects kernel termios flags in raw and cbreak
modes, feeds an arrow escape sequence and a non-ASCII character, changes the
kernel terminal dimensions, and compares the full termios snapshot before and
after a deliberate Lisp error. The host backends call libc directly; they do
not launch a terminal helper or load a Lisp portability library.

The stream suite covers window sharing and ownership, cursor positions,
insertion/deletion, scrolling regions, wide-cell repair, combining characters,
attribute/color propagation, dirty redraws, serialization, resizing with shared
children, pad viewports, overlapping copies, input pushback, escape decoding,
literal paste content, mouse reports, mode snapshots, and endwin/resume.

`python3 tools/check-layout.py` and `git diff --check` passed. macOS adapters
and Nix checks are present, but neither macOS execution nor Nix builds were
available in this local validation. No claim of macOS runtime verification is
made here. Windows is excluded from this implementation.
