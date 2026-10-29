#!/usr/bin/env python3
"""Run the fully bundled ISO Prolog port offline with SBCL/ooparts/prolog."""
import argparse
import collections
import concurrent.futures
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import time

HERE = Path(__file__).resolve().parent
WORKER = HERE / "runtime/worker.lisp"
LOCK = json.loads((HERE / "upstream.json").read_text())


def validate(root=HERE, lock=None):
    lock = LOCK if lock is None else lock
    for directory, expected in lock["files"].items():
        base = root / directory
        actual = {str(p.relative_to(base)) for p in base.rglob("*") if p.is_file()}
        if actual != set(expected):
            raise ValueError("Bundled file inventory differs: " + directory)
        for name, digest in expected.items():
            path = base / name
            if path.is_symlink() or hashlib.sha256(path.read_bytes()).hexdigest() != digest:
                raise ValueError("Bundled source changed: " + str(path))


def inventory():
    cases = json.loads((HERE / "suite/cases.json").read_text())
    if len(cases) != LOCK["cases"] or len({c["id"] for c in cases}) != len(cases):
        raise ValueError("Missing or duplicate case IDs")
    return cases


def lisp_string(text):
    return '"' + str(text).replace('\\', '\\\\').replace('"', '\\"') + '"'


def run_case(case, sbcl, timeout, term_model="native"):
    if case.get("skip"):
        return dict(case, status="SKIP", observation=case["skip"], seconds=0)
    with tempfile.TemporaryDirectory(prefix="ooparts-prolog-iso-") as temporary:
        root = Path(temporary)
        fields = {"id": case["id"], "harness": HERE / "runtime/harness.pl",
                  "program": HERE / "suite" / case["program"], "term-model": term_model}
        job, result = root / "job.sexp", root / "result.json"
        setup = "(" + " ".join(lisp_string(p) for p in case.get("predecessors", [])) + ")"
        job.write_text("(" + " ".join(":" + k + " " + lisp_string(v) for k,v in fields.items()) +
                       " :predecessors " + setup + ")")
        start = time.monotonic()
        try:
            proc = subprocess.run([sbcl, "--noinform", "--control-stack-size", "1", "--script",
                                   str(WORKER), str(job), str(result)],
                                  cwd=root, capture_output=True, text=True, timeout=timeout)
        except subprocess.TimeoutExpired:
            return dict(case, status="FAIL", observation="TIMEOUT", seconds=timeout)
        if result.exists() and proc.returncode == 0:
            try:
                observation = json.loads(result.read_text())
                if not isinstance(observation, dict) or observation.get("status") not in {"PASS", "FAIL", "SKIP"}:
                    raise ValueError("Invalid status")
                if observation["status"] == "PASS" and observation.get("observation") != "(:OBSERVED PASS)":
                    raise ValueError("Invalid success result")
            except (ValueError, TypeError):
                observation = {"status": "FAIL", "observation": "INVALID_PROTOCOL"}
        else:
            observation = {"status": "FAIL", "observation": "NO_RESULT"}
        return dict(case, **observation, seconds=round(time.monotonic()-start,3),
                    exit_code=proc.returncode, diagnostics=(proc.stdout+proc.stderr)[-4000:] if proc.returncode else "")


def apply_expectations(results, expectations):
    by_id = {r["id"]: r for r in results}
    unknown = set(expectations) - set(by_id)
    if unknown:
        raise ValueError("Stale expected differences: " + ", ".join(sorted(unknown)))
    for case_id, expected in expectations.items():
        if not expected.get("reason") or not expected.get("observation"):
            raise ValueError("Expected differences require a reason and exact observation: " + case_id)
        result = by_id[case_id]
        result["difference_reason"] = expected["reason"]
        if result["status"] == "FAIL" and result["observation"] == expected["observation"]:
            result["status"] = "XFAIL"
        else:
            result["status"] = "FAIL"
            result["expectation_changed"] = True


def check_baseline(results, baseline):
    current = {r["id"]: r for r in results}
    if set(current) != set(baseline):
        raise ValueError("Baseline and selected case IDs differ")
    regressions = []
    for case_id, result in current.items():
        previous = baseline[case_id]
        if result.get("expectation_changed"):
            regressions.append(case_id)
        elif result["status"] == "PASS":
            continue
        elif (result["status"], result["observation"]) != (previous["status"], previous["observation"]):
            regressions.append(case_id)
    return regressions



def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sbcl", default="sbcl")
    parser.add_argument("--output", type=Path, default=Path("iso-results"))
    parser.add_argument("--timeout", type=float, default=5)
    parser.add_argument("--jobs", type=int, default=1)
    parser.add_argument("--filter", default="")
    parser.add_argument("--strict", action="store_true")
    parser.add_argument("--term-model", choices=("native", "iso"), default="native")
    parser.add_argument("--baseline", type=Path)
    parser.add_argument("--expectations", type=Path)
    args = parser.parse_args()
    if args.timeout <= 0 or args.jobs <= 0:
        parser.error("--timeout and --jobs must be positive")
    validate()
    cases = inventory()
    selected = [c for c in cases if args.filter in c["id"]]
    if not selected:
        raise ValueError("Filter selected no cases")
    expectations = json.loads((args.expectations or HERE / "expectations/expected-differences.json").read_text()) if (args.expectations or args.term_model == "native") else {}
    if args.term_model == "iso" and expectations:
        raise ValueError("ISO term mode does not allow expected differences")
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
        results = list(pool.map(lambda c: run_case(c, args.sbcl, args.timeout, args.term_model), selected))
    selected_ids = {r["id"] for r in results}
    if args.filter:
        expectations = {k:v for k,v in expectations.items() if k in selected_ids}
    apply_expectations(results, expectations)
    regressions = []
    if args.baseline:
        baseline = json.loads(args.baseline.read_text())
        if args.filter:
            baseline = {k:v for k,v in baseline.items() if k in selected_ids}
        regressions = check_baseline(results, baseline)
    counts = dict(collections.Counter(r["status"] for r in results))
    report = {"upstream": LOCK, "inventory": len(cases), "selected": len(selected), "counts": counts,
              "profile": {"term_model": args.term_model, "syntax": "prolog", "strict_expectations": True},
              "regressions": regressions, "results": results}
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps({"inventory": len(cases), "selected": len(selected), "counts": counts}))
    if regressions:
        print("Changed observations: " + ", ".join(regressions))
    return int(bool(regressions or (args.strict and (counts.get("FAIL",0) or counts.get("BLOCKED",0)))))


if __name__ == "__main__":
    raise SystemExit(main())
