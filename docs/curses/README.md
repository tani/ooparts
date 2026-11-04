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

UTF-8 must be configured for the Lisp's character streams. An original hardware
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
order and mark exposed regions with `touchwin`. The separate ncurses panel,
menu and form libraries are not implemented. `idlok` and `idcok` are accepted
optimization hints; rendering does not require terminal insert/delete commands.

Whole wide glyphs are repaired when a write or clipping boundary touches one
of their cells. Width policy covers common combining blocks, variation selectors,
East Asian wide ranges and common emoji ranges. It is a deterministic policy,
not a complete Unicode grapheme implementation: ambiguous width is one column,
and emoji ZWJ sequences/flags may differ from a terminal's rendering.

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
`+all-mouse-events+` selects button events. Click/double-click/triple-click
synthesis is not implemented; `mouseinterval` stores the setting for future
synthesis but does not delay press/release reports.

Colors use foreground/background pairs with indices 0..255 and -1 for terminal
defaults. Generic profiles do not promise palette redefinition:
`can-change-color` returns NIL and `init-color` returns `+err+`. `color-content`
reports the conventional xterm palette, not a queried user-customized palette.
Truecolor and runtime capability negotiation are not exposed yet.

`putwin`/`getwin` and `scr-*` use a versioned Lisp representation, not ncurses'
binary format. Reading disables reader evaluation and validates cells/dimensions.

## API coverage

The [generated API inventory](API.md) lists the actual public functions, macros,
constants and state. It is a Curses-style Lisp interface, not a claim of complete
X/Open or ncurses ABI/behavioral compatibility. In particular, terminfo/termcap,
soft labels (`slk-*`), pre-initialization layout hooks (`filter`, `ripoffline`),
C scanf-style input, and historical serial-terminal queue/baud APIs are not
provided. Unsupported APIs are not exported as success-returning stubs.

## Tests

```sh
python3 tools/check-layout.py
python3 tools/lisp.py --implementation sbcl tools/test.lisp curses
python3 tools/curses/test-terminal.py --implementation sbcl
```

Replace `sbcl` with `ccl`, `ecl`, `mkcl`, `clisp`, `cmucl`, `clasp` or `abcl`.
`--lisp` selects an executable; `--bootstrap` supplies local toolchain setup.
The stream suite runs without a terminal. The PTY test checks raw/cbreak flags,
UTF-8 and escape input, kernel size changes and exact restoration after an error.
The root flake adds `curses` recipes/checks for every available implementation.

See [recorded validation results](VALIDATION.md) for host versions and limitations.
