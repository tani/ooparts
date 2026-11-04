#!/usr/bin/env python3
"""Record advice behavior in fresh Lisp processes and export a comparison matrix."""
import argparse
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone, timedelta
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from lisp import IMPLEMENTATIONS, lisp_command


def read_log(path):
    result = {'observations': {}}
    completed = None
    for line in path.read_text(errors='replace').splitlines():
        if line.startswith('AUDIT-HOST|'):
            _, implementation, version, system, machine = line.split('|', 4)
            result.update(implementation=implementation, version=version,
                          system=system, machine=machine)
        elif line.startswith('AUDIT|'):
            _, key, kind, value = line.split('|', 3)
            if key in result['observations']:
                raise ValueError(f'Duplicate observation {key} in {path}')
            result['observations'][key] = {'kind': kind, 'value': value}
        elif line.startswith('AUDIT-COMPLETE|'):
            completed = int(line.split('|')[1])
    if completed is None or completed != len(result['observations']):
        raise ValueError(f'Incomplete audit in {path}: {len(result["observations"])} records')
    result['count'] = completed
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--implementation', nargs='+', choices=IMPLEMENTATIONS, default=['sbcl'])
    parser.add_argument('--lisp', help='Executable when auditing one implementation')
    parser.add_argument('--runtime-map', type=Path,
                        help='JSON object mapping implementation names to executable paths')
    parser.add_argument('--bootstrap', type=Path,
                        help='Host/compiler setup file, loaded before ASDF')
    parser.add_argument('--emulated', nargs='*', choices=IMPLEMENTATIONS, default=[],
                        help='Label runtimes explicitly executed through an emulator wrapper')
    parser.add_argument('--output-dir', type=Path, default=ROOT / 'build/advice/audit')
    parser.add_argument('--jobs', type=int, default=3)
    parser.add_argument('--timeout', type=int, default=300)
    args = parser.parse_args()
    output = args.output_dir.resolve()
    output.mkdir(parents=True, exist_ok=True)
    executables = json.loads(args.runtime_map.read_text()) if args.runtime_map else {}
    if args.lisp:
        if len(args.implementation) != 1:
            parser.error('--lisp requires exactly one --implementation')
        executables[args.implementation[0]] = args.lisp

    def run(name):
        log = output / f'{name}.log'
        env = dict(os.environ, OOPARTS_ADVICE_AUDIT_DIRECTORY=str(output / name) + '/')
        try:
            with lisp_command(ROOT / 'tools/advice/audit.lisp', implementation=name,
                              lisp=executables.get(name), bootstrap=args.bootstrap) as command:
                with log.open('w') as stream:
                    process = subprocess.run(command, cwd=ROOT, env=env, stdout=stream,
                                             stderr=subprocess.STDOUT, timeout=args.timeout)
            if process.returncode:
                raise RuntimeError(f'exit {process.returncode}')
            result = read_log(log)
            print(f'{name}: {result["count"]} observations', flush=True)
            return name, result
        except Exception as error:
            print(f'{name}: FAILED ({error}); see {log}', flush=True)
            return name, {'error': str(error), 'log': str(log)}

    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = dict(pool.map(run, args.implementation))
    lock = json.loads((ROOT / 'flake.lock').read_text())
    report = {'nixpkgs_revision': lock['nodes']['nixpkgs']['locked']['rev'],
              'run_date': datetime.now(timezone(timedelta(hours=9))).date().isoformat(),
              'source_sha256': {
                  name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
                  for name in ['src/advice.lisp', 'src/advice/core.lisp',
                               'src/advice/backend.lisp', 'src/advice/compilation.lisp',
                               'src/host.lisp', 'tests/advice/behavior.lisp',
                               'tests/advice/reconciliation.lisp',
                               'tools/lisp.py', 'tools/advice/audit.py',
                               'tools/advice/preexisting.lisp']},
              'setup': {'bootstrap': str(args.bootstrap.resolve()) if args.bootstrap else None,
                        'emulated': args.emulated},
              'implementations': results}
    (output / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
    return int(any('error' in result for result in results.values()))


if __name__ == '__main__':
    raise SystemExit(main())
