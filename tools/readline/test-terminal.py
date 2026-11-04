#!/usr/bin/env python3
"""Verify Curses-backed inline editing, exact TTY restoration, and resize on a PTY."""
import argparse
import fcntl
import os
from pathlib import Path
import select
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
    master, slave = os.openpty()
    checkpoint_read, checkpoint_write = os.pipe()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 24, 40, 0, 0))
    transcript = bytearray()
    position = 0
    with lisp_command(ROOT / 'tools/readline/native.lisp', **options(args)) as command:
        child = subprocess.Popen(command, cwd=ROOT, stdin=slave, stdout=slave, stderr=slave,
                                 pass_fds=(checkpoint_read,),
                                 env=dict(os.environ, TERM='xterm-256color', LANG='C.UTF-8', LC_ALL='C.UTF-8',
                                          OOPARTS_READLINE_CHECKPOINT_FD=str(checkpoint_read)))
        def expect(marker, timeout=180):
            nonlocal position
            deadline = time.monotonic() + timeout
            while marker not in transcript[position:]:
                if select.select([master], [], [], .1)[0]:
                    transcript.extend(os.read(master, 65536))
                elif child.poll() is not None:
                    if child.returncode == 77 and b'READLINE-NATIVE-UNAVAILABLE' in transcript:
                        return False
                    raise AssertionError(f'Child exited {child.returncode}: {bytes(transcript[-5000:])!r}')
                if time.monotonic() > deadline:
                    raise AssertionError(f'Timed out waiting for {marker!r}: {bytes(transcript[-5000:])!r}')
            position = transcript.index(marker, position) + len(marker)
            return True
        cases = [
            (b'ac\x1b[Db\r', b'RESULT-0:"abc"'),
            (b'\x1b[A!\r', b'RESULT-1:"abc!"'),
            (b'he\tlo\r', b'RESULT-2:"hello"'),
            (b'\x1b[200~a\nb\t\x03c\x1b[201~\r', b'RESULT-3:"a b c"'),
            ('\u65e5\u672c\x7f\u8a9e\r'.encode(), 'RESULT-4:"\u65e5\u8a9e"'.encode()),
            (b'\x12abc\r\r', b'RESULT-5:"abc!"'),
            (b'\x04', b'RESULT-6::EOF'),
            (b'\x03', b'INTERRUPTED-7'),
            (b'\t', b'CALLBACK-ERROR'),
            (b'long line after resize\r', b'RESULT-9:"long line after resize"'),
        ]
        try:
            if not expect(b'READLINE-BASELINE'):
                print(f'{args.implementation}: native FFI unavailable; portable checks are separate')
                return
            baseline = termios.tcgetattr(slave)
            os.write(checkpoint_write, b'q')
            for i, (keys, result) in enumerate(cases):
                expect(f'CASE-{i}'.encode())
                deadline = time.monotonic() + 60
                while termios.tcgetattr(slave)[3] & termios.ICANON:
                    if child.poll() is not None or time.monotonic() > deadline:
                        if select.select([master], [], [], 0)[0]:
                            transcript.extend(os.read(master, 65536))
                        raise AssertionError(f'Raw mode not entered: {bytes(transcript[-3000:])!r}')
                    time.sleep(.01)
                if i == 9:
                    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 24, 12, 0, 0))
                    time.sleep(.2)
                os.write(master, keys)
                expect(result)
                expect(f'RESTORED-{i}'.encode())
                restored = termios.tcgetattr(slave)
                assert restored == baseline, ('TTY not restored', i, baseline, restored)
                os.write(checkpoint_write, b'q')
            expect(b'READLINE-PTY-COMPLETE')
            child.wait(timeout=20)
            assert child.returncode == 0, child.returncode
            assert b'\x1b[?1049h' not in transcript, 'Inline input entered the alternate screen'
            assert b'\x1b[2J' not in transcript, 'Inline input erased the existing screen'
            assert b'\x1b[?2004h' in transcript and b'\x1b[?2004l' in transcript
            print(f'{args.implementation}: 10 PTY scenarios, Curses state and TTY restoration passed')
        except BaseException:
            print(transcript.decode(errors='replace')[-8000:], file=sys.stderr)
            raise
        finally:
            if child.poll() is None:
                child.kill()
                child.wait()
            directory = ROOT / 'build/readline'
            directory.mkdir(parents=True, exist_ok=True)
            (directory / f'pty-{args.implementation}.log').write_bytes(transcript)
            os.close(master)
            os.close(slave)
            os.close(checkpoint_read)
            os.close(checkpoint_write)

if __name__ == '__main__':
    main()
