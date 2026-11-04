#!/usr/bin/env python3
"""Check the cross-runtime guarantees in a completed advice behavior audit."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HOSTS = ('sbcl', 'ccl', 'ecl', 'mkcl', 'abcl', 'clisp', 'clasp', 'cmucl')


def verify(report):
    for name, digest in report['source_sha256'].items():
        if hashlib.sha256((ROOT / name).read_bytes()).hexdigest() != digest:
            raise ValueError(f'Source changed after audit: {name}')
    checks = 0
    for name in HOSTS:
        host = report['implementations'][name]
        observations = host['observations']
        if host['count'] != len(observations):
            raise ValueError(f'Incomplete audit for {name}')

        def expect(key, value):
            nonlocal checks
            actual = observations[key]
            if actual != {'kind': 'VALUE', 'value': value}:
                raise ValueError(f'{name}: {key}: expected {value}, got {actual}')
            checks += 1

        for policy in ('default', 'fast', 'debug3', 'speed0', 'inline', 'notinline', 'block'):
            if policy == 'block' and name not in ('sbcl', 'cmucl'):
                continue
            prefix = f'compile.{policy}.'
            for key in ('direct', 'sharp', 'fdefinition', 'symbol-function',
                        'separate-file', 'compiled-after-add', 'reloaded-caller-fasl'):
                expect(prefix + key, '(22 :SECONDARY)')
            expect(prefix + 'flet-sharp', '(10)')
            expect(prefix + 'labels-sharp', '(3)')
            expect(prefix + 'recursion-count', '(4)')
            expect(prefix + 'mutual-count', '(2)')
        for order in ('trace-first', 'advice-first'):
            for mode in ('active', 'removed'):
                after = 22 if mode == 'active' else 11
                expect(f'trace.output.{order}.{mode}',
                       f'((22 :SECONDARY) T ({after} :SECONDARY) T T)')
        expect('registry.compiler-macro-owned', '(T)')
        expect('registry.compiler-macro-released', '(T)')
    return checks


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('report', type=Path)
    args = parser.parse_args()
    count = verify(json.loads(args.report.read_text()))
    print(f'{count} convergence guarantees verified across eight runtimes.')


if __name__ == '__main__':
    main()
