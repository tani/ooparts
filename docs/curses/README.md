# Curses

`ooparts/curses` implements a Curses-style character-cell terminal interface in
Common Lisp. It does not load ncurses, terminfo, CFFI, or any external Lisp library,
and does not run `stty` or another terminal helper. ASDF/UIOP and the host Lisp's
native FFI are used. The only foreign calls are to the operating system's libc.
Windows is outside the current scope.

## Hosts and terminals

| Lisp | Native interface |
|---|---|
| SBCL | SB-ALIEN and SB-SYS |
| CCL | EXTERNAL-CALL and native pointers |
| ECL | Native dynamic FFI |
| MKCL | Native dynamic FFI |
| CLISP | Built-in FFI |
| CMUCL | ALIEN and SYSTEM |
| Clasp | CLASP-FFI |
| ABCL | JDK 17 `jdk.incubator.foreign` |

Linux and macOS use distinct termios layouts. Native mode is for little-endian
x86/x86-64 and ARM hosts. The OS is detected with `uname`, rather than assuming
that every Lisp has a `:linux` feature. macOS arm64 needs a variadic-aware `ioctl`
call; the host adapter handles this separately. Clasp on macOS requires its
native variadic FFI interface. A host/platform combination must also be supported
by the Lisp itself; this library cannot make CMUCL run on unsupported CPUs.

ABCL requires a JVM launched with:

```sh
JAVA_TOOL_OPTIONS="--add-modules=jdk.incubator.foreign --enable-native-access=ALL-UNNAMED" abcl
```

The ABCL adapter targets the JDK 17 incubator API (`CLinker`, `ResourceScope`,
`MemorySegment`, and `MemoryAccess`), not `java.lang.foreign`. It releases every
confined resource scope after use. JDK 18 changed the incubator API, so other JDK
versions are not implicitly treated as compatible.

No JNA, JNI helper library, C compiler, or Java compiler is needed by this library.
ECL/MKCL still need their normal compiler toolchains for ASDF compilation.

Two explicit profiles are provided:

- `:vt100`: basic cursor movement, erasure, scrolling and text attributes, without
  color, mouse, bracketed paste or alternate-screen extension sequences.
- `:xterm` (default): additionally supports indexed colors, alternate screen,
  SGR mouse reports and bracketed paste. A terminal must support the requested
  extensions; the profile is an explicit capability contract, not auto-detection.

Native CLISP terminals require a host built with the `:ffi` feature. The locked
Nixpkgs macOS CLISP is built without FFI: the library and stream renderer still
load and run, but native terminal operations report that limitation. The native
PTY probe reports this configuration as unavailable separately from API and
stream-feature coverage; it does not count it as a native-terminal pass.

UTF-8 must be configured for the Lisp's character streams. CMUCL defaults to
Latin-1 independently of the locale, so the native test fixture sets its standard
FD streams to UTF-8 explicitly. An original hardware
VT100 does not support Unicode; use its supported character repertoire there.

## Usage

```lisp
(require "asdf")
(asdf:load-system "ooparts/curses")

(ooparts/curses:with-screen ()
  (ooparts/curses:cbreak)
  (ooparts/curses:noecho)
  (ooparts/curses:keypad ooparts/curses:*stdscr* t)
  (ooparts/curses:box ooparts/curses:*stdscr*)
  (ooparts/curses:mvaddstr 1 2 "Hello from Common Lisp")
  (ooparts/curses:refresh)
  (ooparts/curses:getch))
```

See [the interactive demo](../../examples/curses/demo.lisp). Use `with-screen`
to restore the saved termios state during normal return and non-local exits,
including Lisp errors. `SIGKILL` cannot be cleaned up. Job-control suspend/resume
is not intercepted; call `endwin` before suspending and `refresh` after resuming.

Native input defaults to `*terminal-io*` with descriptor 0. When using a different
TTY, pass matching `:input`, `:output` and `:fd` to `initscr`, `newterm`, or
`with-screen`. Streams and descriptor must refer to the same terminal. The
library does not open a separate controlling terminal behind redirected stdin.

## Lisp conventions

C underscores become hyphens: `set_term` becomes `set-term`, `get_wch` becomes
`get-wch`. Other names are preserved: `waddstr`, `mvwaddstr`, `wnoutrefresh`.
Constants and global state use Lisp spelling, such as `+a-bold+`, `+key-up+`,
`*screen*`, `*stdscr*`, `*lines*`, `*cols*`, `*colors*`, `*color-pairs*`.
Coordinates are zero-based, in row/column (`y`, `x`) order.

Functions normally return `+ok+` (0) or `+err+` (-1); constructors return an
object or NIL. Functions that would write C output parameters return multiple
values instead:

| API | Values |
|---|---|
| `getyx`, `getmaxyx`, `getbegyx`, `getparyx` | Row, column (or height, width) |
| `getch` | Character code, special-key integer, or `+err+` |
| `get-wch` | Character or special-key integer; status 0, 256, or -1 |
| `getnstr`, `getstr` | String, status |
| `attr-get` | Attribute bits, color-pair number |
| `getcchar` | Text, attribute bits, color-pair number |
| `pair-content` | Foreground, background, status |
| `color-content` | Red, green, blue (0..1000), status |
| `mousemask` | Available new mask, previous mask |
| `wmouse-trafo` | Row, column, success flag |

`printw` uses Common Lisp `format` directives, not C printf directives.
`newterm` takes keyword arguments instead of C FILE pointers. `inch` and
`in-wch` return independent cell objects. Use `getcchar` to inspect one and
`setcchar` to construct an attributed cell, including combining marks.
`addch` accepts a character, a cell, or a legacy low-byte character/attribute
integer. Use Lisp characters or wide APIs for Unicode, not integer code points.

## Drawing and refresh

Windows hold cells; derived windows share backing cells with their parent.
Pads can exceed terminal dimensions and display selected viewports. Modifications
remain in memory until refreshed. Use `wnoutrefresh` on several windows followed
by one `doupdate` to batch a frame. Output is compared with a retained physical
screen, so unchanged glyphs are not re-emitted. The cursor and wrap mode can
still produce control sequences on an otherwise unchanged frame.

Ordinary windows are not a stacking compositor: update overlapping windows in
order and mark exposed regions with `touchwin`. Panel stacking, menus, and forms are provided by the `panel`, `menu`, and `form`
modules and re-exported by the public facade. They use Lisp objects, callbacks
and multiple values instead of C pointers and output parameters. `idlok` and `idcok` are accepted
optimization hints; rendering does not require terminal insert/delete commands.

Whole wide glyphs are repaired when a write or clipping boundary touches one
of their cells. Width policy covers common combining blocks, variation selectors,
East Asian wide ranges and common emoji ranges. It is a deterministic policy,
not a complete Unicode grapheme implementation: ambiguous width is one column,
and terminal-specific emoji presentation can still differ. Common ZWJ emoji,
regional-indicator flags, skin tones and variation selectors are covered.
CMUCL uses surrogate-pair strings for non-BMP scalars and emits UTF-8 directly
on native descriptors. `ooparts/curses/model:codepoint-string` constructs these
portably.

`wresize` preserves content and shared views, and rejects a resize that would
leave a child outside its parent. Native size changes are polled while waiting
for input; `getch` returns `+key-resize+` after updating the standard screen.
A nonblocking input loop should keep calling `getch` to observe resize events.

## Input and extensions

Escape-prefixed keys are parsed with a bounded wait (`set-escdelay`, milliseconds).
Unknown/incomplete sequences are replayed without dropping characters. `keypad`
enables special-key parsing; otherwise escape sequences remain ordinary input.
Custom sequences can be added with `define-key`. There is no keyboard-protocol
negotiation; modifier-specific sequences can be registered explicitly.

`enable-paste` enables bracketed paste on xterm. `getch` then reports
`+key-paste-begin+`, literal paste content, and `+key-paste-end+`.

`mousemask` enables xterm SGR mouse reporting. `getch` returns `+key-mouse+` and
`getmouse` returns a `mouse-event` with zero-based screen coordinates, a button,
`:press`/`:release`/`:motion`, modifier keywords, and `bstate`. Bits use five-bit
button groups (release bit 0, press bit 1) and `+report-mouse-position+`.
`+all-mouse-events+` selects button events. Click, double-click and triple-click reports are synthesized from matching
press/release positions within `mouseinterval`. A zero interval disables
synthesis. The selected event mask controls which reports enter the queue.

Colors use foreground/background pairs with indices 0..255 and -1 for terminal
defaults. Extended pair numbers range up to 65535. `init-color` and
`init-extended-color` emit xterm OSC palette definitions and remember the RGB
values; teardown resets modified palette entries. `init-rgb-pair` selects
truecolor foreground/background triples without changing the palette.
`color-content` reports the conventional xterm palette unless a color was
redefined through this library; it does not query user-customized terminal colors.
`curs-set(2)` selects a blinking block on xterm. Alternate charset and protected
attributes emit DEC charset/DECSCA controls. The terminal must support the
requested operations; the VT100 profile correctly reports color as unsupported.

The terminfo/termcap API uses built-in VT100/xterm profiles. Capability names and
types come from a pinned ncurses Caps inventory. Unknown names and unsupported
capabilities are distinguished (`tigetnum`: -2/-1, `tigetstr`: -1/NIL).
Parameter expansion supports the stack language, variables, nested conditionals,
arithmetic and printf-style field flags/precision. External terminfo databases
are not searched. `setupterm` returns status and diagnostic as multiple values.

Pre-initialization `filter`, `use-env`, `use-tioctl`, `ripoffline` and soft-label
APIs are available. Soft labels reserve screen rows. `scanw` and its variants
parse scanf conversions; they return the assigned Lisp values as a list and the
assignment count. `printw` deliberately retains Lisp `format` syntax. Native
meta/flush control, control characters and baud-rate queries use termios.
The form regexp validator uses the in-repository `ooparts/regexp` component;
this adds no external dependency.

`putwin`/`getwin` and `scr-*` use a versioned Lisp representation, not ncurses'
binary format. Reading disables reader evaluation and validates cells/dimensions.

## API coverage

The [generated API inventory](API.md) lists the public interface. The
[frozen coverage manifest](../../tests/curses/coverage-manifest.json) contains
379 unique non-extension routines from the referenced ncurses index (SVr4 and
X/Open names, including deprecated aliases). Nothing is removed from this
inventory to reach the numerical target.

[Coverage results](COVERAGE.md) distinguish:

1. **API definitions:** reference names present in the public package.
2. **API execution:** reference functions whose entry was observed during tests.
   An optional entry observer works with statically linked ECL/MKCL calls as
   well as dynamically dispatched calls. It is NIL in normal operation.
3. **Feature scenarios:** passed cases from a frozen list of 53 behavioral
   scenarios, with assertions about state, output, error handling and round trips.

All three metrics must be at least 99%; the command returns a nonzero exit code
otherwise. Missing tests, failed processes and unexpected scenario names fail
the gate. These are **inventory and acceptance-test metrics**, not line/branch
coverage and not a proof of complete behavioral equivalence with ncurses.
The widget modules are exercised in the feature scenarios; they are not silently
added to the 379-routine denominator. Native PTY checks are additional gates.

Known boundaries remain explicit: automatic POSIX job-control signal handlers,
complete Unicode grapheme conformance, external terminfo databases, terminal
capability negotiation, ncurses binary serialization and C ABI compatibility
are not claimed. The widget interfaces use a Lisp data model; they do not claim
all undocumented ncurses edge cases or identical error-number conventions.
Windows remains outside scope; macOS requires separate execution validation.

## Tests

```sh
python3 tools/check-layout.py
python3 tools/lisp.py --implementation sbcl tools/test.lisp curses
python3 tools/curses/coverage.py --implementation sbcl
python3 tools/curses/test-terminal.py --implementation sbcl
python3 -m unittest discover -s tests/curses -p 'test_*.py' -v
```

Replace `sbcl` with `ccl`, `ecl`, `mkcl`, `clisp`, `cmucl`, `clasp` or `abcl`.
`--lisp` selects an executable; `--bootstrap` supplies local toolchain setup.
The stream suite runs without a terminal. The PTY test checks raw/cbreak flags,
UTF-8 and escape input, kernel size changes and exact restoration after an error.
The root flake adds `curses` recipes/checks for every available implementation.

See [recorded validation results](VALIDATION.md) for host versions and limitations.
