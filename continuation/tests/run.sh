#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd "$(dirname "$0")/.." && pwd)"
scps_temp_dir="$(mktemp -d)"
trap 'rm -rf "$scps_temp_dir"' EXIT
scps_sbcl="${SBCL:-sbcl}"
export SCPS_FIXTURE_FASL="$scps_temp_dir/fixture.fasl"
export SCPS_TEST_CORE="$scps_temp_dir/test.core"
"$scps_sbcl" --noinform --non-interactive --load "$project_dir/test.lisp"
"$scps_sbcl" --noinform --non-interactive --load "$project_dir/tests/compile-fixture.lisp"
"$scps_sbcl" --noinform --non-interactive --load "$project_dir/tests/load-fixture.lisp"
"$scps_sbcl" --noinform --non-interactive --load "$project_dir/tests/save-core.lisp"
"$scps_sbcl" --core "$SCPS_TEST_CORE" --noinform --disable-debugger
