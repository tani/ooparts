#!/usr/bin/env python3
"""Measure a fixed API inventory and executable behavior scenarios; enforce 99%."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from lisp import add_lisp_arguments, lisp_command, options


def meets_threshold(report, threshold):
    return (report['process_exit_code'] == 0
            and not report['unexpected_features']
            and report['api']['percent'] >= threshold
            and report['api']['exercised_percent'] >= threshold
            and report['features']['percent'] >= threshold)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    add_lisp_arguments(parser)
    parser.add_argument('--output', type=Path, default=ROOT / 'build/curses/coverage.json')
    parser.add_argument('--no-gate', action='store_true')
    args = parser.parse_args()
    manifest = json.loads((ROOT / 'tests/curses/coverage-manifest.json').read_text())
    with lisp_command(ROOT / 'tools/curses/coverage.lisp', **options(args)) as command:
        proc = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    api = {}
    features = {}
    for line in proc.stdout.splitlines():
        parts = line.split('\t', 3)
        if parts[0] == 'CURSES-API' and len(parts) >= 3:
            api[parts[1]] = parts[2]
        if parts[0] == 'CURSES-FEATURE' and len(parts) == 4:
            features[parts[1]] = {'status': parts[2], 'detail': parts[3]}
    missing = [a['c'] for a in manifest['api'] if a['lisp'] not in api]
    uncalled = [a['c'] for a in manifest['api'] if api.get(a['lisp']) != 'called']
    feature_results = {n: features.get(n, {'status': 'missing', 'detail': 'No test result emitted'}) for n in manifest['features']}
    failed = [n for n, result in feature_results.items() if result['status'] != 'pass']
    api_percent = 100 * (1 - len(missing) / len(manifest['api']))
    feature_percent = 100 * (1 - len(failed) / len(feature_results))
    report = {
        'implementation': args.implementation, 'reference': manifest['reference'],
        'api': {'defined': len(manifest['api']) - len(missing), 'total': len(manifest['api']),
                'percent': api_percent, 'missing': missing,
                'exercised_percent': 100 * (1 - len(uncalled) / len(manifest['api'])), 'unexercised': uncalled},
        'features': {'passed': len(feature_results) - len(failed), 'total': len(feature_results),
                     'percent': feature_percent, 'results': feature_results},
        'unexpected_features': sorted(set(features) - set(feature_results)),
        'process_exit_code': proc.returncode,
        'limits': ['API defined percentage measures public entry points, not semantic equivalence.',
                   'Feature percentage measures the frozen acceptance scenarios, not all possible ncurses behaviors.',
                   'Exercised API percentage is reported separately and is not inferred from symbol existence.',
                   'Windows is excluded. Native PTY and macOS validation are separate checks.'],
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    args.output.with_suffix('.log').write_text(proc.stdout)
    print(f"{args.implementation}: API {report['api']['defined']}/{report['api']['total']} ({api_percent:.2f}%), "
          f"features {report['features']['passed']}/{report['features']['total']} ({feature_percent:.2f}%), "
          f"exercised {report['api']['exercised_percent']:.2f}%")
    if missing:
        print('Missing API:', ', '.join(missing))
    for name in failed:
        print(name + ': ' + feature_results[name]['detail'])
    if proc.returncode and not features:
        print(proc.stdout[-5000:])
    success = meets_threshold(report, manifest['threshold_percent'])
    return 0 if success or args.no_gate else 1


if __name__ == '__main__':
    raise SystemExit(main())
