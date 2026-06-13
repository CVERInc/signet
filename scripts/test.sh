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

echo "✓ all checks passed"
