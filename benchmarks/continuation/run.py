#!/usr/bin/env python3
"""Run sequential, CPU-pinned, fresh-process benchmarks. No parallel workers."""
import argparse
import csv
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import time

root = Path(__file__).resolve().parent
p = argparse.ArgumentParser()
p.add_argument("--sbcl", default=os.environ.get("SBCL", "sbcl"))
p.add_argument("--implementation", type=Path, default=root.parents[1])
p.add_argument("--vendor", type=Path, default=root.parents[1] / "build/continuation/vendor")
p.add_argument("--processes", type=int, default=3)
p.add_argument("--rounds", type=int, default=9)
p.add_argument("--target", type=float, default=0.05)
p.add_argument("--baseline", choices=("head", "quicklisp", "both"), default="head")
a = p.parse_args()
out = Path(os.environ.get("OOPARTS_CONT_RESULTS", str(root / "results")))
out.mkdir(parents=True,exist_ok=True)
cpu = min(os.sched_getaffinity(0))
env = dict(os.environ)
env.update(OOPARTS_CONT_BENCH_VENDOR=str(a.vendor.resolve()),
           OOPARTS_CONT_BENCH_IMPLEMENTATION=str(a.implementation.resolve()))
source_hashes = {}
for file in sorted((a.implementation / "src/continuation").glob("*.lisp")) + [a.implementation / "src/continuation.lisp"]:
    source_hashes[str(file.relative_to(a.implementation))] = hashlib.sha256(file.read_bytes()).hexdigest()
metadata = dict(platform=platform.platform(), cpu_affinity=cpu,
                logical_cpus=os.cpu_count(), processes=a.processes,
                rounds=a.rounds, target_seconds=a.target,
                source_sha256=source_hashes,
                policy={"speed": 3, "safety": 1, "debug": 0},
                timestamp_utc=time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()))
metadata["baseline_selection"] = a.baseline
metadata["cl_cont_head_commit"] = subprocess.check_output(["git", "-C", str(a.vendor / "cl-cont"), "rev-parse", "HEAD"], text=True).strip()
metadata["benchmark_sha256"] = {name: hashlib.sha256((root / name).read_bytes()).hexdigest() for name in ["benchmarks.lisp", "bootstrap.lisp"]}
metadata["lisp"] = subprocess.check_output([a.sbcl, "--version"], env=env, text=True).strip()
metadata["cpu_info"] = subprocess.check_output(["lscpu"], text=True)
(out / "environment.json").write_text(json.dumps(metadata, ensure_ascii=False, indent=2))
baselines = ("head", "quicklisp") if a.baseline == "both" else (a.baseline,)
rows = []
for baseline in baselines:
    for process in range(1, a.processes + 1):
        tag = f"{baseline}-{process}"
        sample = out / f"{tag}.csv"
        env.update(OOPARTS_CONT_CL_CONT=baseline, OOPARTS_CONT_BENCH_PROCESS=str(process),
                   OOPARTS_CONT_BENCH_ROUNDS=str(a.rounds),
                   OOPARTS_CONT_BENCH_TARGET=f"{a.target}d0",
                   OOPARTS_CONT_BENCH_CSV=str(sample),
                   OOPARTS_CONT_BENCH_CACHE=str(root.parents[1] / "build/continuation/cache" / baseline))
        command = [a.sbcl, "--dynamic-space-size", "2048", "--noinform",
                   "--non-interactive", "--load", str(root / "bootstrap.lisp")]
        if shutil.which("taskset"):
            command = ["taskset", "-c", str(cpu), *command]
        print(f"Starting {tag}", flush=True)
        with (out / f"{tag}.log").open("w") as log:
            r = subprocess.run(command, env=env, stdout=log, stderr=subprocess.STDOUT, timeout=240)
        if r.returncode:
            raise SystemExit(f"{tag} failed, see {out / (tag + '.log')}")
        with sample.open() as f:
            rows.extend(csv.DictReader(f))
        print(f"Finished {tag}: {len(rows)} total samples", flush=True)
with (out / "raw.csv").open("w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(rows[0]))
    writer.writeheader()
    writer.writerows(rows)
print(f"All measurements written to {out / 'raw.csv'}", flush=True)
