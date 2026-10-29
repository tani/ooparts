#!/usr/bin/env bash
set -euo pipefail
ooparts_root="$(cd "$(dirname "$0")/../.." && pwd)"
ooparts_cont_temp="$(mktemp -d)"
trap 'rm -rf -- "$ooparts_cont_temp"' EXIT
ooparts_sbcl="${SBCL:-sbcl}"
export OOPARTS_CONT_FIXTURE_FASL="$ooparts_cont_temp/fixture.fasl"
export OOPARTS_CONT_TEST_CORE="$ooparts_cont_temp/test.core"
"$ooparts_sbcl" --noinform --script "$ooparts_root/tools/test.lisp" continuation
"$ooparts_sbcl" --noinform --non-interactive --load "$ooparts_root/tools/continuation/compile-fixture.lisp"
"$ooparts_sbcl" --noinform --non-interactive --load "$ooparts_root/tools/continuation/load-fixture.lisp"
"$ooparts_sbcl" --noinform --non-interactive --load "$ooparts_root/tools/continuation/save-core.lisp"
"$ooparts_sbcl" --core "$OOPARTS_CONT_TEST_CORE" --noinform --disable-debugger
