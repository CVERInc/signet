#!/bin/bash
# Auto-guard: build + run the framework-free smoke checks. Run before commit.
#
#   ./scripts/test.sh
#
# Signet is mostly visual, so the suite (a plain executable, since Command Line
# Tools ship no XCTest/Testing) only guards the invariants that break silently:
# token ordering, hex parsing, and that both shipped themes wire every role.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "▸ swift build -c release"
swift build -c release

echo "▸ smoke checks"
swift run -c release SignetTests

# --self-test first, deliberately: a clean scan proves nothing until you have watched the gate
# go red on a planted specimen. This one shipped its first run reporting four real findings and
# exiting 0, so the green is not trusted here without the proof that red is still reachable.
echo "▸ surface leaklint"
bash packages/surface/leaklint.sh --self-test
bash packages/surface/leaklint.sh

# Same reasoning as leaklint above, and the gap it closes: nothing in CI ran this
# before — scripts/test.sh is the whole gate (AGENTS.md), so a self-test this
# file never calls is a self-test nobody has watched fail in CI.
echo "▸ cli lint self-test"
bash packages/cli/lint.sh --self-test

echo "✓ all checks passed"
