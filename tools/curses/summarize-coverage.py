#!/usr/bin/env python3
"""Combine per-host JSON reports into a reviewable Markdown table."""
import argparse
import json
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('reports', nargs='+', type=Path)
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
rows = ['# Curses coverage', '',
        'API reference: 379 unique non-extension routines from the ncurses routine index (SVr4/X/Open).',
        'Definitions, observed function entry, and frozen behavior scenarios are separate metrics.', '',
        '| Host | API defined | API exercised | Feature scenarios |',
        '|---|---:|---:|---:|']
for path in args.reports:
    d = json.loads(path.read_text())
    a, f = d['api'], d['features']
    rows.append(f"| {d['implementation']} | {a['defined']}/{a['total']} ({a['percent']:.2f}%) | "
                f"{a['exercised_percent']:.2f}% | {f['passed']}/{f['total']} ({f['percent']:.2f}%) |")
rows += ['', 'These percentages do not assert equivalence for all ncurses inputs, terminal capabilities,',
         'Unicode versions, widgets, or OS signal behavior. Native PTY verification is recorded separately.', '']
args.output.parent.mkdir(parents=True, exist_ok=True)
args.output.write_text('\n'.join(rows))
