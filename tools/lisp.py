#!/usr/bin/env python3
"""Run a Lisp script with consistent arguments and isolated ASDF caches."""
import argparse
from contextlib import contextmanager
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
IMPLEMENTATIONS = {
    'sbcl': ['--noinform', '--disable-debugger', '--script'],
    'ecl': ['-norc', '-shell'],
    'abcl': ['--noinform', '--noinit', '--batch', '--load'],
    'ccl': ['--quiet', '--no-init', '--batch', '--load'],
    'clisp': ['-q', '-norc'],
    'mkcl': ['-norc', '-shell'],
    'cmucl': ['-quiet', '-noinit', '-batch', '-load'],
    'clasp': ['--noinform', '--norc', '--script'],
}


def lisp_string(value):
    return '"' + str(value).replace('\\', '\\\\').replace('"', '\\"') + '"'


def add_lisp_arguments(parser):
    parser.add_argument('--implementation', choices=IMPLEMENTATIONS, default='sbcl')
    parser.add_argument('--lisp', help='Lisp executable (defaults to implementation name)')
    parser.add_argument('--sbcl', help='Compatibility alias for --lisp with SBCL')
    parser.add_argument('--portable-sat', action='store_true', help='Force the octet-vector SAT backend')
    parser.add_argument('--bootstrap', default=os.environ.get('OOPARTS_LISP_INIT'),
                        help='Optional Lisp initialization file for external dependencies')


@contextmanager
def lisp_command(script, arguments=(), *, implementation='sbcl', lisp=None,
                 sbcl=None, portable_sat=False, bootstrap=None):
    if sbcl and implementation != 'sbcl':
        raise ValueError('--sbcl requires --implementation sbcl')
    executable = lisp or sbcl or os.environ.get(implementation.upper()) or {
        'cmucl': 'lisp', 'clasp': 'clasp'}.get(implementation, implementation)
    mode = 'portable' if portable_sat else 'native'
    cache = ROOT / 'build' / 'lisp-cache' / mode
    cache.mkdir(parents=True, exist_ok=True)
    source = '(pushnew :ooparts-portable-sat *features*)\n' if portable_sat else ''
    source += '(require "asdf")\n'
    if bootstrap:
        source += f'(load {lisp_string(Path(bootstrap).resolve())})\n'
    source += f'''(asdf:initialize-output-translations
 '(:output-translations (t ({lisp_string(str(cache) + '/')} :implementation))
   :ignore-inherited-configuration))
(handler-case
    (progn (load {lisp_string(Path(script).resolve())}) (uiop:quit 0))
  (error (condition)
    (format *error-output* "~&Lisp script failed: ~A~%" condition)
    (uiop:quit 1)))
'''
    with tempfile.TemporaryDirectory(prefix='ooparts-lisp-') as directory:
        entry = Path(directory) / 'entry.lisp'
        entry.write_text(source)
        yield [executable, *IMPLEMENTATIONS[implementation], str(entry),
               *([] if implementation == 'sbcl' else ['--']), *map(str, arguments)]


def options(arguments):
    return {key: getattr(arguments, key) for key in
            ('implementation', 'lisp', 'sbcl', 'portable_sat', 'bootstrap')}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    add_lisp_arguments(parser)
    parser.add_argument('script', type=Path)
    parser.add_argument('arguments', nargs=argparse.REMAINDER)
    arguments = parser.parse_args()
    with lisp_command(arguments.script, arguments.arguments, **options(arguments)) as command:
        return subprocess.call(command, cwd=ROOT)


if __name__ == '__main__':
    raise SystemExit(main())
