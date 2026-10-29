#!/usr/bin/env python3
"""Fetch the exact public upstream sources used in the recorded benchmark."""
from pathlib import Path
import hashlib
import subprocess
import tarfile
import urllib.request

root = Path(__file__).resolve().parent
vendor = root.parents[1] / "build/continuation/vendor"
vendor.mkdir(parents=True, exist_ok=True)
releases = [
    ("alexandria", "https://beta.quicklisp.org/archive/alexandria/2024-10-12/alexandria-20241012-git.tgz",
     "dcdfc5bac229a952358dfe661f0860e8a02480e406d0d95dee4300cdc3d45b31"),
    ("closer-mop", "https://beta.quicklisp.org/archive/closer-mop/2026-01-01/closer-mop-20260101-git.tgz",
     "bea987c69b906d9a94b5e19e6d3f1665a1646d511f080076637195ed4bc7089f"),
    ("cl-cont-quicklisp", "https://beta.quicklisp.org/archive/cl-cont/2011-02-19/cl-cont-20110219-darcs.tgz",
     "a00f159c1df572af501d564abc37d5f907e2ff1d541fed6124c5cd2e34961813"),
]
for name, url, digest in releases:
    archive = vendor / (name + ".tgz")
    if not archive.exists():
        print("Fetching", name, flush=True)
        with urllib.request.urlopen(url, timeout=60) as response:
            archive.write_bytes(response.read())
    if hashlib.sha256(archive.read_bytes()).hexdigest() != digest:
        raise SystemExit("Archive hash mismatch: " + str(archive))
    with tarfile.open(archive) as tar:
        for member in tar.getmembers():
            if Path(member.name).is_absolute() or ".." in Path(member.name).parts:
                raise SystemExit("Unsafe archive path")
        tar.extractall(vendor, filter="data")
commit = "2cbe618d833b97ac4eb8dbb68c059c0913ff9c4b"
repo = vendor / "cl-cont"
if not repo.exists():
    subprocess.run(["git", "clone", "https://gitlab.common-lisp.net/cl-cont/cl-cont.git", str(repo)],
                   check=True)
subprocess.run(["git", "-C", str(repo), "fetch", "origin", commit], check=True)
subprocess.run(["git", "-C", str(repo), "checkout", "--detach", commit], check=True)
actual = subprocess.check_output(["git", "-C", str(repo), "rev-parse", "HEAD"], text=True).strip()
assert actual == commit
print("Pinned dependencies are ready.")
