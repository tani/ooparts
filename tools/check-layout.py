#!/usr/bin/env python3
"""Check inferred namespaces, repository layout and pinned vendor provenance."""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VENDOR = ROOT / 'vendor'


def inventory(directory):
    files = {}
    for path in sorted(directory.rglob('*')):
        if path.is_symlink():
            raise ValueError(f'Symlink in pinned vendor tree: {path}')
        if path.is_file() and path != VENDOR / 'manifest.json':
            files[path.relative_to(directory).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    return files


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--update-vendor-manifest', action='store_true',
                        help='explicitly replace the reviewed vendor inventory')
    args = parser.parse_args()
    if args.update_vendor_manifest:
        (VENDOR / 'manifest.json').write_text(json.dumps(
            {'algorithm': 'sha256', 'files': inventory(VENDOR)}, indent=2) + '\n')

    errors = []
    def check(condition, message):
        if not condition:
            errors.append(message)

    owned = [p for prefix in ('src', 'tests', 'docs', 'examples', 'benchmarks', 'tools', '.github')
             for p in (ROOT / prefix).rglob('*') if p.is_file()
             and '__pycache__' not in p.parts and 'generated' not in p.parts]
    check(sorted(p.name for p in ROOT.glob('*.asd')) == ['ooparts-tests.asd', 'ooparts.asd'],
          'Only ooparts.asd and ooparts-tests.asd may define primary systems')
    definitions = []
    for path in [*ROOT.glob('*.asd'), *owned]:
        if path.suffix not in ('.asd', '.lisp'):
            continue
        source = path.read_text()
        definitions += re.findall(r'\((?:asdf:)?defsystem\s+"([^"]+)"', source, re.I)
        check(not re.search(r'\(:nicknames\b', source, re.I), f'Package nickname: {path}')
    check(sorted(definitions) == ['ooparts', 'ooparts-tests'], f'Explicit systems: {definitions}')
    for name in ('ooparts', 'ooparts-tests'):
        check(':package-inferred-system' in (ROOT/f'{name}.asd').read_text(), f'{name} must be inferred')
    check([p.relative_to(ROOT).as_posix() for p in ROOT.glob('**/flake.nix')
           if 'build' not in p.parts] == ['flake.nix'], 'Use one root flake')
    for prefix, namespace in (('src', 'ooparts'), ('tests', 'ooparts-tests')):
        for path in (ROOT/prefix).rglob('*.lisp'):
            expected = namespace + '/' + path.relative_to(ROOT/prefix).with_suffix('').as_posix()
            source = path.read_text()
            package = re.search(r'\(uiop(?:/package)?:define-package\s+#:([^\s()]+)', source, re.I)
            active = re.search(r'\(in-package\s+#:([^\s()]+)', source, re.I)
            check(package is not None and package[1].lower() == expected, f'Package/path mismatch: {path}')
            check(active is not None and active[1].lower() == expected, f'In-package mismatch: {path}')
    for path in [*ROOT.glob('*.md'), *owned]:
        if path.suffix not in ('.md', '.lisp', '.py', '.html', '.sh', '.nix'):
            continue
        source = path.read_text()
        check(not re.search(r'[\u3040-\u30ff\u3400-\u9fff]', source), f'Non-English owned text: {path}')
        if path.suffix == '.md':
            for target in re.findall(r'\]\(([^)]+)\)', source):
                if re.match(r'[a-z]+:|#', target) or ' ' in target:
                    continue
                target = target.split('#')[0]
                check((path.parent/target).exists(), f'Broken link: {path.relative_to(ROOT)} -> {target}')
        if path.suffix == '.html':
            for target in re.findall(r'(?:src|href)="([^"]+)"', source):
                if not re.match(r'[a-z]+:|#', target):
                    check((path.parent/target.split('#')[0]).exists(), f'Broken HTML resource: {target}')

    manifest = json.loads((VENDOR/'manifest.json').read_text())
    actual = inventory(VENDOR)
    check(manifest['algorithm'] == 'sha256' and manifest['files'] == actual, 'Vendor inventory differs')
    corpus = json.loads((VENDOR/'logtalk/upstream.json').read_text())
    for category in ('original', 'ported'):
        check(corpus['files'][category] == inventory(VENDOR/'logtalk'/category), f'Logtalk {category} inventory differs')
    ledger = json.loads((ROOT/'third-party.json').read_text())
    for component in ledger['distributed']:
        check(bool(component['license']) and bool(component['source']), f'Incomplete provenance: {component["name"]}')
        for license_file in component['license_files']:
            check((ROOT/license_file).is_file(), f'Missing license: {license_file}')
        for pattern in component['paths']:
            check(bool(list(ROOT.glob(pattern))), f'Empty provenance path: {pattern}')
    if errors:
        raise SystemExit('\n'.join(errors))
    print(f'Layout, inferred packages and licenses verified; {len(actual)} pinned vendor files.')


if __name__ == '__main__':
    main()
