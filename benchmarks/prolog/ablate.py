#!/usr/bin/env python3
"""Compare source variants and SWI serially, reversing engine order each round."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import statistics
import subprocess

EXPECTED = dict(queens=92, tak=5, reverse=1200, qsort=2000, graph=1024, differentiate=12799)


def main():
    parser = argparse.ArgumentParser(__doc__)
    parser.add_argument('--variant', action='append', required=True, help='NAME=CHECKOUT')
    parser.add_argument('--sbcl', default='sbcl')
    parser.add_argument('--swipl', default='swipl')
    parser.add_argument('--rounds', type=int, default=2)
    parser.add_argument('--repeats', type=int, default=3)
    parser.add_argument('--batch', type=int, default=20)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    variants = dict(item.split('=', 1) for item in args.variant)
    roots = {name: Path(root).resolve() for name, root in variants.items()}
    roots['swi'] = next(iter(roots.values()))
    env = dict(os.environ, BENCH_REPEATS=str(args.repeats), BENCH_BATCH=str(args.batch))
    env.pop('BENCH_CASE', None)
    env.pop('OOPARTS_PROLOG_DISABLE_NATIVE', None)
    report = dict(platform=platform.platform(), rounds=args.rounds, repeats=args.repeats,
                  batch=args.batch, execution_order=[], engines={})
    for name, root in roots.items():
        benchmark_dir = 'benchmarks/prolog' if (root / 'benchmarks/prolog').is_dir() else 'benchmarks'
        command = [args.swipl, '-O', '-q', '-s', benchmark_dir + '/competitive-swi.pl'] if name == 'swi' else [
            args.sbcl, '--dynamic-space-size', '2048', '--control-stack-size', '1',
            '--script', benchmark_dir + '/competitive.lisp']
        version_command = [args.swipl, '--version'] if name == 'swi' else [args.sbcl, '--version']
        entry = dict(command=command, version=subprocess.check_output(version_command, env=env, text=True).strip(),
                     cases={}, cold_seconds=[])
        if name != 'swi':
            entry['files_sha256'] = {str(path.relative_to(root)): hashlib.sha256(path.read_bytes()).hexdigest()
                                    for path in sorted((root / 'src').rglob('*.lisp'))}
        report['engines'][name] = entry
    for round_number in range(args.rounds):
        order = list(roots) if round_number % 2 == 0 else list(reversed(roots))
        report['execution_order'].append(order)
        for name in order:
            root, entry = roots[name], report['engines'][name]
            print(f'Round {round_number + 1}: {name}', flush=True)
            run = subprocess.run(entry['command'], cwd=root, env=env, text=True, capture_output=True)
            if run.returncode:
                raise RuntimeError(f'{name}: {run.stdout}\n{run.stderr}')
            counts = {}
            cold = {}
            for line in run.stdout.splitlines():
                fields = line.split()
                if fields[:1] == ['COLD']:
                    cold[fields[1].lower()] = float(fields[2])
                if fields[:1] != ['RESULT']:
                    continue
                _, case, result, seconds, allocated, batch, total = fields
                case = case.lower()
                assert int(result) == EXPECTED[case], (name, case, result)
                counts[case] = counts.get(case, 0) + 1
                entry['cases'].setdefault(case, []).append(dict(
                    round=round_number, seconds=float(seconds), allocated_bytes=int(allocated),
                    batch=int(batch), batch_seconds=float(total)))
            assert set(counts) == set(EXPECTED) and all(n == args.repeats for n in counts.values())
            entry['cold_seconds'].append(cold)
    report['summary'] = {}
    for case in EXPECTED:
        medians = {name: statistics.median(row['seconds'] for row in entry['cases'][case])
                   for name, entry in report['engines'].items()}
        report['summary'][case] = {
            name: dict(seconds=median, swi_over_variant=medians['swi'] / median,
                       min_seconds=min(row['seconds'] for row in report['engines'][name]['cases'][case]),
                       max_seconds=max(row['seconds'] for row in report['engines'][name]['cases'][case]))
            for name, median in medians.items()}
        print(case + ': ' + ', '.join(f'{name} {value * 1000:.3f} ms' for name, value in medians.items()), flush=True)
    target = Path(args.output)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
