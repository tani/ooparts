#!/usr/bin/env python3
"""Compare same-checkout :auto (JIT) and :wam execution with counterbalanced rounds.

Both policies run the identical public workload in fresh SBCL processes. Round 1
runs wam then auto; round 2 runs auto then wam, so a warmed host cannot favor one
engine. Every raw sample, native-use count and per-round median is retained.
"""
import argparse
import json
import os
import platform
import statistics
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EXPECTED = dict(queens=92, tak=5, reverse=1200, qsort=2000, graph=1024, differentiate=12799)
ROUND_ORDERS = (('wam', 'auto'), ('auto', 'wam'))
NATIVE_REQUIRED = ('queens', 'tak')
BENCHMARK_COMMAND = ['--dynamic-space-size', '2048', '--control-stack-size', '1',
                     '--script', 'benchmarks/prolog/competitive.lisp']


def child_env(execution, repeats, batch):
    env = dict(os.environ)
    env.pop('OOPARTS_PROLOG_DISABLE_NATIVE', None)
    env.pop('BENCH_CASE', None)
    env.update(BENCH_EXECUTION=execution, BENCH_REPEATS=str(repeats), BENCH_BATCH=str(batch))
    return env


def run_engine(sbcl, execution, repeats, batch):
    command = [sbcl] + BENCHMARK_COMMAND
    run = subprocess.run(command, cwd=ROOT, env=child_env(execution, repeats, batch),
                         text=True, capture_output=True, check=True)
    cases, cold, native = {}, {}, {}
    for line in run.stdout.splitlines():
        fields = line.split()
        if fields[:1] == ['COLD']:
            cold[fields[1].lower()] = float(fields[2])
        elif fields[:1] == ['NATIVE']:
            _, name, calls, deoptimizations = fields
            native[name.lower()] = dict(native_calls=int(calls),
                                        native_deoptimizations=int(deoptimizations))
        elif fields[:1] == ['RESULT']:
            _, name, result, seconds, allocated, sample_batch, total = fields
            name = name.lower()
            if name not in EXPECTED:
                raise SystemExit(f'{execution}: unknown benchmark case {name}')
            if int(result) != EXPECTED[name]:
                raise SystemExit(f'{execution}: incorrect {name} result: {result}')
            cases.setdefault(name, []).append(
                dict(seconds=float(seconds), allocated_bytes=int(allocated),
                     batch=int(sample_batch), batch_seconds=float(total)))
    if set(cases) != set(EXPECTED):
        raise SystemExit(f'{execution}: missing benchmark cases: '
                         + ', '.join(sorted(set(EXPECTED) - set(cases))))
    for name, rows in cases.items():
        if len(rows) != repeats:
            raise SystemExit(f'{execution}: {name} emitted {len(rows)} samples, expected {repeats}')
    for name in EXPECTED:
        if name not in cold:
            raise SystemExit(f'{execution}: missing COLD line for {name}')
        if name not in native:
            raise SystemExit(f'{execution}: missing NATIVE line for {name}')
    merged = {}
    for name in EXPECTED:
        merged[name] = dict(cold_seconds=cold[name], samples=cases[name],
                            native_calls=native[name]['native_calls'],
                            native_deoptimizations=native[name]['native_deoptimizations'])
    return dict(cases=merged)


def main():
    parser = argparse.ArgumentParser(__doc__)
    parser.add_argument('--sbcl', default='sbcl')
    parser.add_argument('--repeats', type=int, default=7)
    parser.add_argument('--batch', type=int, default=20)
    parser.add_argument('--output', default='build/prolog/jit-comparison.json')
    args = parser.parse_args()
    if args.repeats <= 0:
        parser.error('--repeats must be positive')
    if args.batch <= 0:
        parser.error('--batch must be positive')

    version = subprocess.check_output([args.sbcl, '--version'], env=dict(os.environ),
                                      text=True).strip()
    rounds = []
    for index, order in enumerate(ROUND_ORDERS, start=1):
        engines = {}
        for execution in order:
            print(f'round {index}: {execution} ...', flush=True)
            engines[execution] = run_engine(args.sbcl, execution, args.repeats, args.batch)
        rounds.append(dict(round=index, order=list(order), engines=engines))

    for record in rounds:
        auto = record['engines']['auto']
        for name in NATIVE_REQUIRED:
            if auto['cases'][name]['native_calls'] <= 0:
                raise SystemExit(f"round {record['round']}: auto execution made no native "
                                 f"calls for {name}; compiled execution is not active")

    summary = {}
    for name in EXPECTED:
        round_speedups = []
        round_medians = []
        for record in rounds:
            medians = {engine: statistics.median(row['seconds'] for row in
                                                 record['engines'][engine]['cases'][name]['samples'])
                       for engine in ('wam', 'auto')}
            round_medians.append(dict(round=record['round'], **medians))
            round_speedups.append(medians['wam'] / medians['auto'])
        auto_native = [dict(round=record['round'],
                            native_calls=record['engines']['auto']['cases'][name]['native_calls'],
                            native_deoptimizations=record['engines']['auto']['cases'][name]['native_deoptimizations'])
                       for record in rounds]
        summary[name] = dict(round_medians=round_medians,
                             round_speedups=round_speedups,
                             median_speedup=statistics.median(round_speedups),
                             auto_native=auto_native)

    report = dict(platform=platform.platform(), sbcl_version=version,
                  command=[args.sbcl] + BENCHMARK_COMMAND,
                  repeats=args.repeats, batch=args.batch,
                  expected=EXPECTED, rounds=rounds, summary=summary)
    target = ROOT / args.output
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(report, indent=2) + '\n')

    for name, row in summary.items():
        auto = row['auto_native'][-1]
        wam_ms = statistics.median(m['wam'] for m in row['round_medians']) * 1000
        auto_ms = statistics.median(m['auto'] for m in row['round_medians']) * 1000
        print(f"{name:14} auto {auto_ms:9.3f} ms  wam {wam_ms:9.3f} ms  "
              f"speedup {row['median_speedup']:.2f}x  "
              f"native {auto['native_calls']}/{auto['native_deoptimizations']}", flush=True)


if __name__ == '__main__':
    main()
