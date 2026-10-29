#!/usr/bin/env python3
"""Check continuation FASLs in fresh processes, plus saved images on SBCL."""
import argparse
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from lisp import add_lisp_arguments, lisp_command, options


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    add_lisp_arguments(parser)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix='ooparts-continuation-') as directory:
        environment = dict(os.environ, OOPARTS_CONT_FIXTURE_FASL=str(Path(directory) / 'fixture.fasl'),
                           OOPARTS_CONT_TEST_CORE=str(Path(directory) / 'test.core'))
        scripts = ['compile-fixture.lisp', 'load-fixture.lisp']
        if args.implementation == 'sbcl':
            scripts.append('save-core.lisp')
        for script in scripts:
            with lisp_command(ROOT / 'tools/continuation' / script, **options(args)) as command:
                subprocess.run(command, cwd=ROOT, env=environment, check=True, timeout=300)
        if args.implementation == 'sbcl':
            executable = args.lisp or args.sbcl or os.environ.get('SBCL', 'sbcl')
            subprocess.run([executable, '--core', environment['OOPARTS_CONT_TEST_CORE'],
                            '--noinform', '--disable-debugger'], check=True, timeout=60)
        print('Continuation FASL reload passed in a fresh process.' +
              (' Saved-core reload passed.' if args.implementation == 'sbcl' else ''))


if __name__ == '__main__':
    main()
