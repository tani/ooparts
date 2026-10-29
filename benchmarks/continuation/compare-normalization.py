#!/usr/bin/env python3
"""Compare two checkouts using identical, sequential, CPU-pinned workloads."""
import argparse
import csv
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import statistics
import subprocess

ROOT = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--before', type=Path, required=True)
    parser.add_argument('--after', type=Path, default=ROOT.parents[1])
    parser.add_argument('--vendor', type=Path, required=True)
    parser.add_argument('--sbcl', default=os.environ.get('SBCL', 'sbcl'))
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--processes', type=int, default=5)
    parser.add_argument('--rounds', type=int, default=9)
    parser.add_argument('--target', type=float, default=0.03)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    cpu = min(os.sched_getaffinity(0))
    snapshots = {'before': args.before.resolve(), 'after': args.after.resolve()}
    metadata = {
        'lisp': subprocess.check_output([args.sbcl, '--version'], text=True).strip(),
        'platform': platform.platform(), 'cpu_affinity': cpu,
        'processes_per_revision': args.processes, 'rounds': args.rounds,
        'target_seconds': args.target, 'policy': {'speed': 3, 'safety': 1, 'debug': 0},
        'order': 'before/after and after/before alternate between process pairs',
        'sources': {label: {str(p.relative_to(checkout)): hashlib.sha256(p.read_bytes()).hexdigest()
                           for p in sorted((checkout / 'src/continuation').glob('*.lisp'))}
                    for label, checkout in snapshots.items()},
        'harness': {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
                    for p in [ROOT / 'benchmarks.lisp', ROOT / 'bootstrap.lisp',
                              ROOT / 'normalization.lisp', Path(__file__)]},
    }
    (output / 'environment.json').write_text(json.dumps(metadata, indent=2) + '\n')
    samples = []
    for process in range(1, args.processes + 1):
        order = ['before', 'after'] if process % 2 else ['after', 'before']
        for label in order:
            sample = output / f'{label}-{process}.csv'
            env = dict(os.environ, OOPARTS_CONT_BENCH_DEFINITIONS_ONLY='1',
                       OOPARTS_CONT_CL_CONT='head',
                       OOPARTS_CONT_BENCH_VENDOR=str(args.vendor.resolve()),
                       OOPARTS_CONT_BENCH_IMPLEMENTATION=str(snapshots[label]),
                       OOPARTS_CONT_BENCH_CACHE=str(output / 'cache' / label),
                       OOPARTS_CONT_BENCH_PROCESS=str(process),
                       OOPARTS_CONT_BENCH_ROUNDS=str(args.rounds),
                       OOPARTS_CONT_BENCH_TARGET=f'{args.target}d0',
                       OOPARTS_CONT_BENCH_CSV=str(sample))
            command = ['taskset', '-c', str(cpu), args.sbcl, '--dynamic-space-size', '2048',
                       '--noinform', '--non-interactive', '--load', str(ROOT / 'bootstrap.lisp'),
                       '--load', str(ROOT / 'normalization.lisp')]
            print(f'Starting {label}, process {process}.', flush=True)
            with (output / f'{label}-{process}.log').open('w') as log:
                subprocess.run(command, env=env, stdout=log, stderr=subprocess.STDOUT,
                               check=True, timeout=600)
            with sample.open() as stream:
                samples.extend(dict(row, revision=label) for row in csv.DictReader(stream))
    with (output / 'raw.csv').open('w') as stream:
        writer = csv.DictWriter(stream, fieldnames=list(samples[0]))
        writer.writeheader()
        writer.writerows(samples)
    summary = []
    for case in sorted({row['case'] for row in samples}):
        for variant in ['selective', 'native', 'transform']:
            result = {'case': case, 'variant': variant}
            for label in snapshots:
                rows = [row for row in samples if row['case'] == case
                        and row['variant'] == variant and row['revision'] == label]
                for field, unit, scale in [('cpu_seconds', 'cpu_us', 1e6), ('bytes', 'bytes', 1)]:
                    medians = [statistics.median(float(row[field]) / int(row['iterations']) * scale
                                                for row in rows if int(row['process']) == process)
                               for process in range(1, args.processes + 1)]
                    result[f'{label}_{unit}'] = statistics.median(medians)
                result[f'{label}_process_us'] = [statistics.median(
                    float(row['cpu_seconds']) / int(row['iterations']) * 1e6
                    for row in rows if int(row['process']) == process)
                    for process in range(1, args.processes + 1)]
            result['after_over_before'] = result['after_cpu_us'] / result['before_cpu_us']
            summary.append(result)
    (output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    with (output / 'summary.csv').open('w') as stream:
        fields = [key for key in summary[0] if not key.endswith('_process_us')]
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        writer.writerows({key: row[key] for key in fields} for row in summary)
    for variant in ['selective', 'native', 'transform']:
        ratios = [row['after_over_before'] for row in summary if row['variant'] == variant]
        print(f'{variant}: geometric mean after/before = {math.exp(statistics.mean(map(math.log, ratios))):.4f}')
    print(f'Measured {len(samples)} samples; results: {output}', flush=True)


if __name__ == '__main__':
    main()
