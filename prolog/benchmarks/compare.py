#!/usr/bin/env python3
"""Run both engines serially, validate results, and retain every CPU sample."""
import argparse
import json
import os
from pathlib import Path
import statistics
import subprocess
import platform

ROOT = Path(__file__).resolve().parents[1]
EXPECTED = dict(queens=92, tak=5, reverse=1200, qsort=2000, graph=1024, differentiate=12799)


def main():
    parser = argparse.ArgumentParser(__doc__)
    parser.add_argument('--sbcl', default='sbcl')
    parser.add_argument('--swipl', default='swipl')
    parser.add_argument('--repeats', type=int, default=5)
    parser.add_argument('--output', default='benchmarks/results/wam-results.json')
    parser.add_argument('--require-parity', action='store_true', help='exit unsuccessfully if any median is slower than SWI')
    args = parser.parse_args()
    env = dict(os.environ, BENCH_REPEATS=str(args.repeats))
    commands = {
        'ooparts/prolog': [args.sbcl, '--dynamic-space-size', '2048', '--control-stack-size', '1', '--script', 'benchmarks/competitive.lisp'],
        'swi': [args.swipl, '-O', '-q', '-s', 'benchmarks/competitive-swi.pl'],
    }
    report = {'platform': platform.platform(), 'engines': {}}
    for engine, command in commands.items():
        version_command = [args.sbcl, '--version'] if engine == 'ooparts/prolog' else [args.swipl, '--version']
        version = subprocess.check_output(version_command, env=env, text=True).strip()
        run = subprocess.run(command, cwd=ROOT, env=env, text=True, capture_output=True, check=True)
        cases, cold = {}, {}
        for line in run.stdout.splitlines():
            fields = line.split()
            if fields[:1] == ['COLD']:
                cold[fields[1].lower()] = float(fields[2])
            if fields[:1] != ['RESULT']:
                continue
            _, name, result, seconds, allocated, batch, total = fields
            name = name.lower()
            if int(result) != EXPECTED[name]:
                raise AssertionError(f'{engine}: incorrect {name} result: {result}')
            cases.setdefault(name, []).append(dict(seconds=float(seconds), allocated_bytes=int(allocated),
                                                  batch=int(batch), batch_seconds=float(total)))
        if set(cases) != set(EXPECTED) or any(len(rows) != args.repeats for rows in cases.values()):
            raise AssertionError(f'{engine}: missing benchmark samples')
        report['engines'][engine] = dict(version=version, command=command, cold_seconds=cold, cases=cases)
    report['summary'] = {}
    for name in EXPECTED:
        medians = {engine: statistics.median(r['seconds'] for r in data['cases'][name])
                   for engine, data in report['engines'].items()}
        report['summary'][name] = dict(**medians, swi_over_ooparts/prolog=medians['swi'] / medians['ooparts/prolog'])
        print(f"{name:14} ooparts/prolog {medians['ooparts/prolog']*1000:9.3f} ms  SWI {medians['swi']*1000:9.3f} ms  ratio {medians['swi']/medians['ooparts/prolog']:.2f}x", flush=True)
    target = ROOT / args.output
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(report, indent=2) + '\n')
    if args.require_parity:
        slower = [name for name, row in report['summary'].items() if row['swi_over_ooparts/prolog'] < 1]
        if slower:
            raise SystemExit('SWI parity not reached: ' + ', '.join(slower))


if __name__ == '__main__':
    main()
