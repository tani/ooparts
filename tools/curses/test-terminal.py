#!/usr/bin/env python3
"""Check native modes, UTF-8/key input, resizing, and exception cleanup on a PTY."""
import argparse
import fcntl
import os
from pathlib import Path
import pty
import selectors
import struct
import subprocess
import sys
import termios
import time

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from lisp import add_lisp_arguments, lisp_command, options


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    add_lisp_arguments(parser)
    args = parser.parse_args()
    master, slave = pty.openpty()
    original = None
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 24, 80, 0, 0))
    output = bytearray()
    stages = set()
    with lisp_command(ROOT / 'tools/curses/native.lisp', **options(args)) as command:
        env = dict(os.environ, LANG='C.UTF-8', LC_ALL='C.UTF-8')
        proc = subprocess.Popen(command, cwd=ROOT, stdin=slave,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env)
        selector = selectors.DefaultSelector()
        selector.register(proc.stdout, selectors.EVENT_READ)
        deadline = time.monotonic() + 120
        try:
            while proc.poll() is None or selector.get_map():
                if time.monotonic() > deadline:
                    raise AssertionError('Native Curses probe timed out')
                for key, _ in selector.select(0.1):
                    chunk = os.read(key.fileobj.fileno(), 65536)
                    if not chunk:
                        selector.unregister(key.fileobj)
                        continue
                    output.extend(chunk)
                if b'CURSES-BASELINE' in output and 'baseline' not in stages:
                    original = termios.tcgetattr(slave)
                    stages.add('baseline')
                    os.write(master, b'\n')
                if b'CURSES-OPTIONS' in output and 'options' not in stages:
                    mode = termios.tcgetattr(slave)
                    assert mode[0] & termios.ISTRIP, mode
                    assert mode[3] & termios.NOFLSH, mode
                    stages.add('options')
                    os.write(master, b'q')
                if b'CURSES-READY' in output and 'raw' not in stages:
                    mode = termios.tcgetattr(slave)
                    assert not mode[3] & (termios.ICANON | termios.ECHO | termios.ISIG), mode
                    assert not mode[0] & termios.ISTRIP, mode
                    assert chr(0x1f469).encode() in output, 'Non-BMP terminal output missing'
                    stages.add('raw')
                    os.write(master, b'\x1b[A' + chr(0x754c).encode())
                if b'CURSES-RESIZE' in output and 'resize' not in stages:
                    stages.add('resize')
                    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 30, 90, 0, 0))
                if b'CURSES-CBREAK' in output and 'cbreak' not in stages:
                    mode = termios.tcgetattr(slave)
                    assert not mode[3] & (termios.ICANON | termios.ECHO), mode
                    assert mode[3] & termios.ISIG, mode
                    stages.add('cbreak')
                    os.write(master, b'q')
                if b'CURSES-RESTORED' in output and 'restored' not in stages:
                    restored = termios.tcgetattr(slave)
                    assert restored == original, ('TTY settings not restored', original, restored)
                    stages.add('restored')
                    os.write(master, b'\n')
            status = proc.wait()
            if status == 77 and b'CURSES-NATIVE-UNAVAILABLE' in output:
                print(f'{args.implementation}: native PTY checks unavailable: host built without FFI; stream coverage is separate')
                return
            assert status == 0, output.decode(errors='replace')[-8000:]
            assert b'CURSES-RESTORED' in output, output.decode(errors='replace')[-8000:]
            assert stages == {'baseline', 'options', 'raw', 'resize', 'cbreak', 'restored'}, stages
            print(f'{args.implementation}: native PTY mode/input/resize/unwind checks passed')
        except BaseException:
            proc.kill()
            proc.wait()
            print(output.decode(errors='replace')[-8000:], file=sys.stderr)
            raise
        finally:
            selector.close()
            os.close(master)
            os.close(slave)


if __name__ == '__main__':
    main()
