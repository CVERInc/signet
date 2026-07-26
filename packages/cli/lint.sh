#!/usr/bin/env bash
# signet-cli-lint — the seal-keeper you can read.
# Static only · zero dependencies · never ships inside a tool · self-testing.
# https://oss.cver.net/signet  ·  MIT © CVER Inc.
#
# It reads files, runs nothing, changes nothing. Meant for CI in every CVER CLI
# repo; nothing here is a runtime dependency of sheersweep/sheerstatus/clikae —
# it only inspects them. It carries the seal it enforces, and checks itself.
#
#   signet-cli-lint FILE...        check files, non-zero on any violation
#   signet-cli-lint --self-test    prove the checks can still fire, then exit
#
# Only DECIDED rules are enforced. Anything marked TBD in SPEC.md is deliberately
# not checked — a lint that guesses is worse than one that waits.
set -u

# The closed badge set (SPEC.md → State badges).
BADGES="PASS DONE WARN FAIL HELD"

VIOLATIONS=0
report() {   # $1 = file:line  $2 = rule  $3 = what
  printf '%s: [%s] %s\n' "$1" "$2" "$3" >&2
  VIOLATIONS=$((VIOLATIONS + 1))
}

is_known_badge() {
  case " $BADGES " in *" $1 "*) return 0 ;; esac
  return 1
}

# Should this line be exempt from the output rules?
#
# A comment is never printed, so it cannot violate a rule about printed output —
# and any file that documents these rules has to quote the wrong forms somewhere.
# The explicit marker covers the other case: test fixtures, which are code that
# writes deliberately non-conforming text.
_skip_line() {   # $1 = raw line
  local t="${1#"${1%%[![:space:]]*}"}"       # strip leading whitespace
  case "$t" in \#*) return 0 ;; esac
  case "$1" in *'# signet-lint: fixture'*) return 0 ;; esac
  return 1
}

# ---- C1 · an unknown badge -------------------------------------------------
# Anything shaped like a badge — four uppercase letters in brackets, padded or
# not — whose word isn't in the closed set. Padded and unpadded are checked
# together on purpose: split across two checks, "[CRIT]" (wrong word AND wrong
# shape) fell through both.
check_unknown_badge() {   # $1 = file
  local line no word
  while IFS=: read -r no line; do
    [ -n "$no" ] || continue
    _skip_line "$line" && continue
    word="$(printf '%s' "$line" | /usr/bin/sed -n 's/.*\[ *\([A-Z][A-Z][A-Z][A-Z]\) *\].*/\1/p' | head -1)"
    [ -n "$word" ] || continue
    is_known_badge "$word" && continue
    report "$1:$no" "badge-vocab" "[$word] is not in the closed set ($BADGES)"
  done < <(/usr/bin/grep -nE '\[ ?[A-Z]{4} ?\]' "$1" 2>/dev/null)
}

# ---- C2 · a badge without its padding --------------------------------------
# The right word in the wrong shape: "[PASS]" instead of "[ PASS ]". The padding
# is what keeps a status badge from reading as a checkbox.
check_badge_padding() {   # $1 = file
  local no line b
  for b in $BADGES; do
    while IFS=: read -r no line; do
      [ -n "$no" ] || continue
      _skip_line "$line" && continue
      report "$1:$no" "badge-shape" "[$b] is missing its padding — write [ $b ]"
    done < <(/usr/bin/grep -nF "[$b]" "$1" 2>/dev/null)
  done
}

# ---- C3 · a translated badge -----------------------------------------------
# Badges are never localised (SPEC.md). A bracket holding non-ASCII glyphs is a
# translated badge, e.g. [混雑] / [정상].
#
# Portability: [:ascii:] is NOT a valid character class on BSD grep — it exits
# "invalid character class", which a silenced stderr turns into "no matches" and
# therefore into a false all-clear. Under LC_ALL=C every UTF-8 byte is
# non-printable, so the negated [:print:] class finds them everywhere.
check_badge_translated() {   # $1 = file
  local no line tok
  while IFS=: read -r no line; do
    [ -n "$no" ] || continue
    _skip_line "$line" && continue
    tok="$(printf '%s' "$line" | LC_ALL=C /usr/bin/sed -n 's/.*\(\[[^][:print:]]\{1,12\}\]\).*/\1/p' | head -1)"
    report "$1:$no" "badge-i18n" "${tok:-a bracketed non-ASCII token} — badges stay English in every locale"
  done < <(LC_ALL=C /usr/bin/grep -nE '\[[^][:print:]]{1,12}\]' "$1" 2>/dev/null)
}

# ---- C4 · the header seal --------------------------------------------------
# The three-line mould every CVER CLI already shares. Checked on the first 8
# lines so a shebang and a blank line don't matter.
check_header_seal() {   # $1 = file
  local head8
  head8="$(head -8 "$1" 2>/dev/null)"
  printf '%s' "$head8" | /usr/bin/grep -qE '^# [a-z0-9-]+ — .* you can read\.' \
    || report "$1:1" "seal-line1" "missing '# <name> — the <thing> you can read.'"
  printf '%s' "$head8" | /usr/bin/grep -qE 'oss\.cver\.net/[a-z0-9-]+.*MIT © CVER Inc\.' \
    || report "$1:1" "seal-line3" "missing 'https://oss.cver.net/<name>  ·  MIT © CVER Inc.'"
}

run_checks() {   # $1 = file
  check_unknown_badge "$1"
  check_badge_padding "$1"
  check_badge_translated "$1"
  check_header_seal "$1"
}

# ---- self-test -------------------------------------------------------------
# A lint whose patterns silently stop matching reads exactly like a clean repo.
# So every check gets a fixture it MUST fire on. If a check goes quiet here, the
# lint reports itself broken rather than blessing the codebase.
self_test() {
  local dir bad good rc=0 before
  dir="$(mktemp -d)" || { echo "self-test: mktemp failed" >&2; return 1; }
  bad="$dir/bad.sh"; good="$dir/good.sh"

  # bad.sh breaks every decided rule at once, INCLUDING the seal (no identity
  # lines) — an earlier version kept the seal here and the seal check "passed"
  # by never being given anything to catch.
  {
    printf '#!/usr/bin/env bash\n'
    printf '# just some script\n'
    printf 'echo "[ CRIT ] not in the set"\n'   # signet-lint: fixture
    printf 'echo "[PASS] unpadded"\n'   # signet-lint: fixture
    printf 'echo "[CRIT] unpadded AND unknown — fell through both checks once"\n'   # signet-lint: fixture
    printf 'echo "[混雑] translated"\n'   # signet-lint: fixture
  } > "$bad"
  {
    printf '#!/usr/bin/env bash\n'
    printf '# widget — the thing you can read.\n'
    printf '# Open source · one file · zero deps.\n'
    printf '# https://oss.cver.net/widget  ·  MIT © CVER Inc.\n'
    printf 'echo "[ PASS ] fine"\n'
    printf 'echo "[ WARN ] also fine"\n'
    printf 'echo "[x] a checkbox is not a badge"\n'
  } > "$good"

  fires() {   # $1 = label  $2 = function  $3 = file
    before="$VIOLATIONS"; VIOLATIONS=0
    "$2" "$3" 2>/dev/null
    if [ "$VIOLATIONS" -gt 0 ]; then printf '  ok    %s fires\n' "$1"
    else printf '  BROKEN %s did not fire on a known-bad fixture\n' "$1"; rc=1; fi
    VIOLATIONS="$before"
  }
  silent() {   # $1 = label  $2 = function  $3 = file
    before="$VIOLATIONS"; VIOLATIONS=0
    "$2" "$3" 2>/dev/null
    if [ "$VIOLATIONS" -eq 0 ]; then printf '  ok    %s stays quiet on clean input\n' "$1"
    else printf '  BROKEN %s cried wolf on a clean fixture\n' "$1"; rc=1; fi
    VIOLATIONS="$before"
  }

  echo "signet-cli-lint self-test"
  fires  "badge-vocab " check_unknown_badge     "$bad"
  fires  "badge-shape " check_badge_padding     "$bad"
  fires  "badge-i18n  " check_badge_translated  "$bad"
  fires  "seal        " check_header_seal       "$bad"
  silent "badge-vocab " check_unknown_badge     "$good"
  silent "badge-shape " check_badge_padding     "$good"
  silent "badge-i18n  " check_badge_translated  "$good"
  silent "seal        " check_header_seal       "$good"

  rm -rf "$dir"
  [ "$rc" -eq 0 ] && echo "self-test ok" || echo "self-test BROKEN — fix the lint before trusting a clean run" >&2
  return "$rc"
}

# ---- main ------------------------------------------------------------------
if [ "${1:-}" = "--self-test" ]; then
  self_test; exit $?
fi
if [ "$#" -eq 0 ]; then
  echo "usage: signet-cli-lint FILE...   |   signet-cli-lint --self-test" >&2
  exit 2
fi

# Always self-check first: a clean report is only worth anything if the checks
# can still fire.
if ! self_test >/dev/null 2>&1; then
  echo "signet-cli-lint: self-test failed — refusing to report a clean run" >&2
  self_test
  exit 3
fi

for f in "$@"; do
  [ -f "$f" ] || { echo "signet-cli-lint: no such file: $f" >&2; VIOLATIONS=$((VIOLATIONS + 1)); continue; }
  run_checks "$f"
done

if [ "$VIOLATIONS" -eq 0 ]; then
  echo "signet-cli-lint: clean ($# file(s))"
  exit 0
fi
echo "signet-cli-lint: $VIOLATIONS violation(s)" >&2
exit 1
