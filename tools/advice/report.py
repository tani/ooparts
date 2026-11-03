#!/usr/bin/env python3
"""Render every recorded advice probe into the library README."""
import argparse
from collections import OrderedDict
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ORDER = ['sbcl', 'ccl', 'ecl', 'mkcl', 'abcl', 'clisp', 'clasp', 'cmucl']
LABELS = {'sbcl': 'SBCL', 'ccl': 'CCL', 'ecl': 'ECL', 'mkcl': 'MKCL',
          'abcl': 'ABCL', 'clisp': 'CLISP', 'clasp': 'Clasp', 'cmucl': 'CMUCL'}
BEGIN = '<!-- BEGIN ADVICE BEHAVIOR AUDIT -->'
END = '<!-- END ADVICE BEHAVIOR AUDIT -->'


def outcome(host, key):
    value = host['observations'].get(key)
    if value is None:
        if key.startswith('compile.block.'):
            return 'N/A'
        raise ValueError(f'Missing probe {key}')
    if value['kind'] == 'ERROR':
        return 'error: ' + value['value']
    if value['value'] == '(:NOT-SUPPORTED)':
        return 'N/A'
    return value['value']


def cell(text):
    return '`' + text.replace('|', '&#124;').replace('`', '\\`') + '`'


def section(key):
    prefix = key.split('.')[0]
    if prefix == 'preexisting':
        return 'Code compiled before library loading'
    if prefix == 'status':
        return 'Active and pending registration'
    if prefix == 'compile':
        return 'Compilation: ' + key.split('.')[1]
    return {'combinator': 'Composition, values, arguments and control flow',
            'short-circuit': 'Composition, values, arguments and control flow',
            'zero-values': 'Composition, values, arguments and control flow',
            'arguments': 'Composition, values, arguments and control flow',
            'filter-args': 'Composition, values, arguments and control flow',
            'around': 'Composition, values, arguments and control flow',
            'nonlocal': 'Composition, values, arguments and control flow',
            'registry': 'Registry, ordering and mutation',
            'designator': 'Registry, ordering and mutation',
            'object': 'Function objects, identity and aliases',
            'target': 'Function names and lexical functions',
            'redefinition': 'Redefinition and unbinding',
            'metadata': 'Documentation metadata',
            'generic': 'Generic functions and methods',
            'validation': 'Validation and absent targets',
            'define-advice': 'Definition macros',
            'threads': 'Threads and cross-thread mutation',
            'trace': 'TRACE coexistence'}[prefix]


def summary_table(hosts, versions):
    lines = ['| Runtime | Version | Instrumented same-file call | DEFUN retains advice | Last removal restores base | Generic identity retained |',
             '|---|---|---|---|---|---|']
    for name in ORDER:
        h = hosts[name]
        direct = 'Advice' if outcome(h, 'compile.default.direct') == '(22 :SECONDARY)' else 'Bypass'
        redefine = 'Yes' if outcome(h, 'redefinition.defun.current') == '(24 :SECONDARY)' else 'No'
        remove = 'Yes' if outcome(h, 'object.current-after-last-removal') == '(11 :SECONDARY)' else '**No**'
        generic = 'Yes' if outcome(h, 'generic.identity-preserved') == '(T)' else 'No'
        lines.append(f'| {LABELS[name]} | {versions[name]} | {direct} | {redefine} | {remove} | {generic} |')
    return lines


def preexisting_table(hosts):
    lines = ['| Runtime | Existing default caller | Existing fast caller | Existing INLINE caller | Existing default FDEFINITION getter |',
             '|---|---|---|---|---|']
    for name in ORDER:
        values = [outcome(hosts[name], key) for key in
                  ['preexisting.default.caller', 'preexisting.fast.caller',
                   'preexisting.inline.caller', 'preexisting.default.getter']]
        lines.append('| ' + LABELS[name] + ' | ' + ' | '.join(
            'Advice' if value == '(22 :SECONDARY)' else
            'Bypass' if value == '(11 :SECONDARY)' else cell(value)
            for value in values) + ' |')
    return lines


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('report', type=Path)
    parser.add_argument('--update-readme', action='store_true')
    args = parser.parse_args()
    report = json.loads(args.report.read_text())
    hosts = report['implementations']
    for name in ORDER:
        if name not in hosts or 'error' in hosts[name]:
            raise ValueError(f'Incomplete audit for {name}')
    for name, digest in report.get('source_sha256', {}).items():
        if hashlib.sha256((ROOT / name).read_bytes()).hexdigest() != digest:
            raise ValueError(f'Implementation changed after audit: {name}')
    keys = list(hosts['sbcl']['observations'])
    for name in ORDER:
        extra = set(hosts[name]['observations']) - set(keys)
        if extra:
            raise ValueError(f'Unexpected probes: {name}: {extra}')
    groups = OrderedDict()
    same = different = 0
    for key in keys:
        values = [outcome(hosts[name], key) for name in ORDER]
        common = len(set(values)) == 1
        same += int(common)
        different += int(not common)
        groups.setdefault(section(key), []).append((key, values, common))
    versions = {name: ' '.join(hosts[name]['version'].split()) for name in ORDER}
    setup = report.get('setup', {})
    emulated = setup.get('emulated', [])
    gnu11 = 'mkcl-gnu11' in (setup.get('bootstrap') or '')
    for name in emulated:
        versions[name] += ' / emulated*'
    if gnu11:
        versions['mkcl'] += '*'
    total = sum(host['count'] for host in hosts.values())
    lines = [BEGIN, '## Recorded behavior comparison', '',
             f'Audited on {report["run_date"]}, with Nixpkgs commit '
             f'`{report["nixpkgs_revision"]}` on Linux. '
             'These are measurements of the current OOPArts backends, not of each host\'s native advice facility.', '',
             f'**{len(keys)} comparison rows, {total} observations across eight runtimes:** '
             f'{same} rows have identical outcomes; {different} rows differ or include an unavailable control. '
             'N/A denotes a missing or explicitly unsupported control.', '']
    lines += summary_table(hosts, versions)
    lines += ['', 'Calls compiled **before** the library was loaded (separate fixtures):', '',
              *preexisting_table(hosts)]
    lines += ['', '* Bootstrap: ' + (cell(Path(setup['bootstrap']).name) if setup.get('bootstrap') else 'none') + '.',
              '* Emulated runtimes: ' + (', '.join(LABELS[name] for name in emulated) or 'none') + '.',
              '* MKCL used GNU11 mode because the locked package\'s default C compiler '
              'mode rejected its generated calls. The GNU11 bootstrap itself does not patch Lisp lookup; '
              'the library separately repairs cached references and instruments future calls. '
              'CMUCL used QEMU i386 because this execution host cannot run the package\'s 32-bit ELF directly; '
              'CMUCL emitted a personality-setting warning. Native i386 was not measured.',
              '* CLISP reports an older source date in `lisp-implementation-version`; the Nix package is '
              '`2.49.95-unstable-2024-12-28`. Full runtime-reported versions are in the JSON report.', '',
              '### How to read the complete tables', '',
              '- Each cell is the printed `multiple-value-list` of a probe. `NIL` means **zero values**; '
              '`(NIL)` means one NIL value. Errors are normalized to `UNDEFINED-FUNCTION`, `TYPE-ERROR`, '
              '`PROGRAM-ERROR`, or other `ERROR`, not exact implementation-specific subclasses or messages.',
              '- Ordinary base: argument 10 returns `(11 :SECONDARY)`; one doubling advice returns '
              '`(22 :SECONDARY)`; two return `(44 :SECONDARY)`. Replacement base returns '
              '`(12 :SECONDARY)`, or `(24 :SECONDARY)` when still advised.',
              '- `combinator.*` probes return two values: the result-value list and the event sequence. '
              'Mutation and TRACE probes likewise return before/after values. IDs map directly to '
              '`tests/advice/behavior.lisp`.',
              '- Shared rows are listed once under **Same on all eight**. Every other row includes all eight columns. '
              'Both types are observations, not proofs that every optimization or platform behaves the same.',
              '- `preexisting.*` fixtures are compiled before library loading with original compiler behavior. '
              'All `compile.*` fixtures are compiled with the library\'s compilation mode enabled, before or after '
              'adding advice as indicated. They measure instrumented calls, not unchanged host compilation.',
              '- `default` uses fresh host defaults. Other policies first set speed/space/safety/debug/compilation-speed '
              'to 1, then apply their named changes: `fast` = speed 3, safety 1, debug 0; '
              '`debug3` = debug 3; `speed0` = speed 0; `inline` = fast + INLINE target; '
              '`notinline` = NOTINLINE target/self/mutual entry; `block` = host `:block-compile t` on SBCL/CMUCL.',
              '- Same-file and separate-file callers are compiled before advice. `compiled-after-add` is a new '
              'separate caller compiled while advice is present. `reloaded-caller-fasl` reloads the separate caller\'s '
              'FASL after advice is present. Recursion probes call n=3: full interception gives 4 self calls '
              'or 2 calls to the observed mutual-recursion entry.',
              '- `local-saved-function` evaluates `(let ((saved #\'target)) (funcall installer) (funcall saved x))`; '
              'the installer adds advice. `local-saved-fdefinition` uses FDEFINITION instead. '
              'These deliberately distinguish compiler rewriting from an actual object captured through an opaque boundary.',
              '- Prepared calls are redirected before INLINE/self-call expansion. Their advised INLINE results '
              'therefore do not mean that old expanded instructions were patched. In preexisting fixtures INLINE '
              'requests may also be ignored. Same-file redefinition controls explore behavior beyond portable ANSI assumptions.', '']
    for title, rows in groups.items():
        lines += ['### ' + title, '']
        common = [row for row in rows if row[2]]
        varied = [row for row in rows if not row[2]]
        if common:
            lines += ['Same on all eight:', '', '| Probe ID | Observed values on all eight |', '|---|---|']
            lines += [f'| {cell(key)} | {cell(values[0])} |' for key, values, _ in common]
            lines.append('')
        if varied:
            lines += ['Different outcomes or unavailable controls:', '',
                      '| Probe ID | ' + ' | '.join(LABELS[name] for name in ORDER) + ' |',
                      '|---|' + '---|' * len(ORDER)]
            lines += ['| ' + cell(key) + ' | ' + ' | '.join(cell(v) for v in values) + ' |'
                      for key, values, _ in varied]
            lines.append('')
    lines += [END]
    text = '\n'.join(lines) + '\n'
    destination = args.report.parent / 'comparison.md'
    destination.write_text(text)
    if args.update_readme:
        path = ROOT / 'docs/advice/README.md'
        current = path.read_text()
        if BEGIN in current:
            a, b = current.index(BEGIN), current.index(END) + len(END)
            current = current[:a] + text.rstrip() + current[b:]
        else:
            current += '\n' + text
        path.write_text(current)
        path = ROOT / 'README.md'
        current = path.read_text()
        root_section = '\n'.join([
            '<!-- BEGIN ADVICE SUMMARY -->', '## Advice behavior across implementations', '',
            f'Measured with the locked unstable Nixpkgs: {len(keys)} behavior rows and {total} observations. '
            f'{same} rows agree across all eight runtimes; {different} differ or include an unavailable control.', '',
            *summary_table(hosts, versions), '',
            'Native SBCL/CCL encapsulation, revocable portable dispatchers and definition reconciliation '
            'support redefinition and TRACE coexistence. Compilation instrumentation is enabled by default '
            'and redirects future application calls through dynamic lookup, including the measured INLINE and recursive cases. '
            'Old ECL/MKCL direct calls still need recompilation, and genuinely retained old ordinary function objects remain unchanged. '
            'The [complete comparison and known limitations](docs/advice/README.md#recorded-behavior-comparison) '
            'document every measured row, including errors. MKCL uses GNU11 compiler flags; CMUCL was measured '
            'under QEMU i386. Dynamic lookup trades optimization for interception; no uniform guarantee covers arbitrary old compiled code.',
            '<!-- END ADVICE SUMMARY -->', ''])
        begin, end = '<!-- BEGIN ADVICE SUMMARY -->', '<!-- END ADVICE SUMMARY -->'
        if begin in current:
            a, b = current.index(begin), current.index(end) + len(end)
            current = current[:a] + root_section.rstrip() + current[b:]
        else:
            current = current.replace('## Performance\n', root_section + '\n## Performance\n')
        path.write_text(current)
    print(f'{len(keys)} rows; {total} observations; {same} identical; {different} different/N/A.')
    print(destination)


if __name__ == '__main__':
    main()
