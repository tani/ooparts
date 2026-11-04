# Readline

`ooparts/readline` provides inline line editing, history, completion, and reverse
history search. Its terminal backend is **`ooparts/curses`**. No separate FFI,
UTF-8 decoder, key-sequence parser, or character-width table is maintained here.
No GNU Readline, libedit, ncurses, CFFI, JNA, JNI helper, or `stty` is used.

```lisp
(asdf:load-system "ooparts/readline")
(ooparts/readline:readline "> ")
```

## API

```lisp
(ooparts/readline:readline
  "> " :initial "" :history ooparts/readline:*history*
  :completion (lambda (prefix)
                (remove-if-not
                 (lambda (s) (and (<= (length prefix) (length s))
                                  (string= prefix s :end2 (length prefix))))
                 '("hello" "help" "quit")))
  :edit :auto :eof-error-p nil :eof-value nil)
```

The result excludes the terminating newline. `:input` and `:output` default to
the standard streams. `:edit :auto` edits only supported interactive standard
streams; files, pipes, string streams, `TERM=dumb`, and hosts without available
native terminal support use ordinary `read-line`. `:edit t` requires native
editing; `:edit nil` always uses stream input. `initial` and `completion` apply
only in native mode. Prompts are plain text; control characters are removed.

Completion takes the whitespace-delimited prefix ending at the cursor and
returns candidate strings. Nonmatching candidates are filtered. A unique match
is inserted; multiple matches extend the common prefix and display alternatives.
A callback error propagates after terminal cleanup.

EOF returns `eof-value`, or signals `end-of-file` if `eof-error-p` is true.
Ctrl-D on an empty buffer is EOF; otherwise it deletes the next character.
Ctrl-C/Ctrl-G signal `readline-interrupted`. Attributes are restored and
bracketed paste is disabled on normal return and nonlocal exit. Calls to
readline are serialized using the host lock; recursive calls are rejected.
History mutations outside readline must be synchronized by the application.

```lisp
(defparameter *commands* (ooparts/readline:make-history :limit 500))
(ooparts/readline:add-history "hello" *commands*)
(ooparts/readline:history-entries *commands*) ; newest first
(ooparts/readline:write-history #P"commands.history" *commands*)
(ooparts/readline:read-history #P"commands.history" *commands*)
(ooparts/readline:clear-history *commands*)
```

Empty entries and adjacent duplicates are not recorded. `:history nil` disables
history. Files store oldest first using the host's default external format;
missing input files are ignored.

## Keys

| Keys | Action |
|---|---|
| Left / Right, Ctrl-B / Ctrl-F | Move one character |
| Home / End, Ctrl-A / Ctrl-E | Beginning / end |
| Alt-B / Alt-F | Move by whitespace-delimited word |
| Backspace / Delete, Ctrl-D | Delete a character |
| Up / Down, Ctrl-P / Ctrl-N | History; preserve the draft |
| Ctrl-K / Ctrl-U / Ctrl-W | Kill suffix / prefix / preceding word |
| Alt-D / Ctrl-Y | Kill next word / yank |
| Ctrl-T | Transpose adjacent characters |
| Tab | Complete |
| Ctrl-R | Incremental reverse history search; repeat for an older match |
| Enter during search | Keep match and leave search; another Enter submits |
| Escape / Ctrl-G during search | Restore the line before search |
| Ctrl-L | Clear and redraw |
| Enter | Submit |

Bracketed paste inserts text without executing embedded control keys. Tabs and
newlines become spaces. Long lines use a horizontal viewport, reserving the
last terminal cell; idle input detects width changes. Complete Unicode grapheme
editing, vi mode, colored prompts, multiline editing, and job-control interception
are outside the current API. Character editing is by Lisp string index; display
width follows Curses' policy. This is not a GNU Readline API compatibility layer.

## Curses integration

- `curses/terminal` owns native mode changes, size queries, exact restoration,
  and terminal text output.
- Curses `get-wch`, `keypad`, `timeout`, and paste events own key decoding.
- Curses `text-width` owns the width policy.
- Curses `tigetstr`, `tparm`, and `tputs` supply inline cursor/erase capabilities.

A private stream-backed Curses screen decodes events. Its full-screen output
goes to a discard stream, so readline never enters the alternate screen or
clears existing terminal contents during initialization. Only inline rendering
and paste-mode sequences reach the actual output. The private screen and
terminfo bindings leave an enclosing Curses session's dynamic state intact.

The native host/platform requirements are those of
[Curses](../curses/README.md). ABCL uses **JDK 17's incubator API** only:

```sh
JAVA_TOOL_OPTIONS='--add-modules=jdk.incubator.foreign --enable-native-access=ALL-UNNAMED' abcl
```

There is no separate `java.lang.foreign` backend in readline. Windows is outside
scope. As with Curses, character streams must be configured for UTF-8. Clasp uses
its POSIX input stream (`:cstream nil`) while editing, so C stdio buffering does
not hide pending UTF-8 bytes from Curses' nonblocking character reader.

## Validation

```sh
python3 tools/check-layout.py
python3 tools/lisp.py --implementation sbcl tools/test.lisp readline
python3 tools/readline/test-terminal.py --implementation sbcl
JAVA_TOOL_OPTIONS='--add-modules=jdk.incubator.foreign --enable-native-access=ALL-UNNAMED' \
  python3 tools/readline/test-terminal.py --implementation abcl
```

The portable suite covers editing, history, search, completion, viewport bounds,
stream fallback, EOF, and the shared Curses decoder. The PTY suite checks ten
input scenarios including Japanese input, paste, resizing, Ctrl-C and a failing
completion callback. After every scenario it checks the entry termios
configuration. On Darwin only the kernel-managed `PENDIN` bit is excluded:
XNU sets it when canonical mode is restored and clears it when input is
processed ([kernel implementation](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/kern/tty.c)).
Checkpoints use a separate pipe so the harness does not read the restored TTY.
The suite also checks that no alternate-screen or initialization clear sequence
was emitted and that Curses' surrounding dynamic state is preserved.

Nix exposes `readline` packages and checks for every available host, with native
PTY checks alongside the portable suite. A CLISP build without native FFI runs
the portable suite and explicitly reports native checks as unavailable.

Validated on Linux with SBCL 2.6.8, CCL 1.13, ECL 26.5.5, ABCL 1.9.3,
CLISP 2.49.95, MKCL 1.1.11, Clasp 3.0.1, and CMUCL 21d. Each host passed
76 regression checks and all ten PTY scenarios; CMUCL ran through QEMU i386.
