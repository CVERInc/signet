#!/usr/bin/env bash
# signet-surface-lint — what a public repo must not publish about the machine that built it.
# Static only · zero dependencies · reads files, runs nothing, changes nothing · self-testing.
# https://oss.cver.net/signet  ·  MIT © CVER Inc.
#
# The seal covers what a repo looks like. This covers what it leaks. A public repo can be
# perfectly correct and still ship a developer's home directory, or the internal layout of a
# repo nobody outside can clone — usually inside a path in a test harness, a comment, or a
# tool nobody runs any more. That is not a security hole; it is a stranger learning the shape
# of a machine they have no business seeing.
#
#   leaklint.sh                 scan this repo's TRACKED files, non-zero on any hit
#   leaklint.sh --self-test     prove the checks can still fire, then exit
#
# TRACKED files only, on purpose: untracked scratch is not published, and a gate that shouts
# about your local mess is a gate you learn to ignore.
#
# In CI, alongside the CLI seal:
#   curl -fsSL https://raw.githubusercontent.com/CVERInc/signet/main/packages/surface/leaklint.sh -o /tmp/leaklint
#   bash /tmp/leaklint
#
# SCOPE, honestly. It catches home-directory paths, which is the failure that actually keeps
# happening and needs no secret to detect. It does NOT catch private repository *names* — that
# list cannot live in a public file without being the leak it prevents. Keep such a list
# locally and pass it with --deny <file>; CI will not have it, so treat that half as advice,
# not enforcement. cvertex's tools/leakguard.sh is the same idea with the list kept private.
set -u

VIOLATIONS=0
DENY=""
SELFTEST=0

report() {  # $1 = file:line  $2 = rule  $3 = what
  printf '%s: [%s] %s\n' "$1" "$2" "$3" >&2
  VIOLATIONS=$((VIOLATIONS + 1))
}

while [ $# -gt 0 ]; do
  case "$1" in
    --self-test) SELFTEST=1 ;;
    --deny) shift; DENY="${1:-}" ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *) printf 'leaklint: unknown argument: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

# The home-directory pattern is assembled at run time from two halves. Written out whole it
# would appear in this file, and this file is itself tracked in a public repo — the gate would
# then report itself on every run and teach you to ignore it. Assembling it keeps the literal
# string out of the source, so no path needs an exemption and the scan stays honest.
U="/Us""ers/"
H="/ho""me/"
HOME_RE="(${U}|${H})[A-Za-z0-9._-]+/"

# Never pipe INTO the reporting loop. A `... | while read` runs the loop in a subshell, so
# every VIOLATIONS increment is discarded when the pipeline ends: the gate prints each hit and
# then exits 0. That is exactly how this file behaved on its first run against a real leak —
# four findings reported, "clean" printed, exit 0. Capture first, loop in this shell.
report_hits() {  # $1 = rule  $2 = message  $3 = captured "file:line:text" block
  [ -n "$3" ] || return 0
  while IFS= read -r hit; do
    [ -n "$hit" ] || continue
    loc="${hit%%:*}"; rest="${hit#*:}"; lineno="${rest%%:*}"
    report "$loc:$lineno" "$1" "$2"
  done <<EOF
$3
EOF
}

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

if [ "$SELFTEST" -eq 1 ]; then
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  # Each case runs the WHOLE gate against a planted repo and asserts its EXIT CODE. The first
  # version of this self-test asserted the regex instead, and passed while the gate reported
  # four real findings and still exited 0 — a double thinner than the thing it stood for.
  # A rule that stops firing here has been unguarding everything it covers for however long
  # it took someone to notice.
  plant() {  # $1 = dir  $2 = file content
    mkdir -p "$tmp/$1" && ( cd "$tmp/$1" && git init -q . && printf '%s\n' "$2" > f.js && git add -A )
  }
  fired=0
  expect() {  # $1 = dir  $2 = "block"|"pass"  $3 = label
    if ( cd "$tmp/$1" && bash "$SELF" >/dev/null 2>&1 ); then got=pass; else got=block; fi
    if [ "$got" = "$2" ]; then
      printf '  ok    %s\n' "$3"; fired=$((fired + 1))
    else
      printf '  FAIL  %s (gate said %s, expected %s)\n' "$3" "$got" "$2" >&2
    fi
  }
  plant pos-users "const P = \"${U}rjmarsden/Developer/thing/x.css\";"
  plant pos-home  "const P = \"${H}rjmarsden/src/x.css\";"
  plant neg-rel   'const P = "./relative/x.css";'
  plant neg-ph    "const P = \"${U}you/.local/bin/agent\";"
  expect pos-users block 'surface/home-path  blocks a real name'
  expect pos-home  block 'surface/home-path  blocks the /home variant'
  expect neg-rel   pass  'surface/home-path  passes a relative path'
  expect neg-ph    pass  'surface/home-path  passes a documented placeholder'
  [ "$fired" -eq 4 ] || { printf 'self-test FAILED\n' >&2; exit 1; }
  printf 'self-test ok\n'
  exit 0
fi

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  printf 'leaklint: not inside a git work tree\n' >&2; exit 2; }

FILES="$(git ls-files)"
[ -n "$FILES" ] || { printf 'leaklint: no tracked files\n' >&2; exit 2; }

# A home path is not the defect — a REAL person's home path is. Docs and tests are supposed to
# say /Users/you and /Users/someone; that is how you write an example. Flagging those would fire
# forever with nothing to fix, and a gate nobody can act on gets ignored, taking the real hits
# down with it. So: match any home path, then keep only the ones whose user segment is not a
# recognised placeholder. Unknown names are reported — it fails toward noticing.
# Grow this list rather than deleting a rule. A name that is obviously synthetic belongs here;
# when in doubt leave it out, because an unrecognised name is reported and a reported name costs
# you ten seconds, while an unreported one costs you a stranger's map of your machine.
PLACEHOLDERS="|you|me|my|user|username|someone|somebody|example|name|yourname|youruser|someuser|test|tester|USER|HOME|<user>|<you>|alice|bob|jdoe|johndoe|runner|root|x|y|z|foo|bar|baz|qux|prev|next|demo|sample|dev|admin|ubuntu|ci|build|"

# -I skips binaries; xargs -0 survives spaces and non-ASCII filenames.
RAW="$(printf '%s\n' "$FILES" | tr '\n' '\0' \
  | xargs -0 /usr/bin/grep -IEn "$HOME_RE" 2>/dev/null || true)"

# The user segment is taken by splitting the match on "/", never by writing the prefix out
# again — this file is tracked in a public repo and must not match its own rule.
HITS="$(printf '%s' "$RAW" | awk -v ure="$HOME_RE" -v ph="$PLACEHOLDERS" '
  {
    p = index($0, ":");        f = substr($0, 1, p - 1);  rest = substr($0, p + 1)
    q = index(rest, ":");      ln = substr(rest, 1, q - 1); s = substr(rest, q + 1)
    while (match(s, ure)) {
      seg = substr(s, RSTART, RLENGTH)
      n = split(seg, parts, "/")
      user = parts[3]
      if (index(ph, "|" user "|") == 0) { print f ":" ln ": " user; break }
      s = substr(s, RSTART + RLENGTH)
    }
  }')"
report_hits "surface/home-path" "a real user's home directory, not a placeholder" "$HITS"

if [ -n "$DENY" ]; then
  [ -f "$DENY" ] || { printf 'leaklint: denylist not found: %s\n' "$DENY" >&2; exit 2; }
  while IFS= read -r term; do
    case "$term" in ''|'#'*) continue ;; esac
    out="$(printf '%s\n' "$FILES" | tr '\n' '\0' \
      | xargs -0 /usr/bin/grep -IFn -- "$term" 2>/dev/null || true)"
    [ -n "$out" ] || continue
    while IFS= read -r hit; do
      [ -n "$hit" ] || continue
      loc="${hit%%:*}"; rest="${hit#*:}"; lineno="${rest%%:*}"
      # The term itself is NOT printed: this runs in logs, and the list is the secret.
      report "$loc:$lineno" "surface/private-name" "a name from the local denylist"
    done <<EOF
$out
EOF
  done < "$DENY"
fi

if [ "$VIOLATIONS" -gt 0 ]; then
  printf 'leaklint: %d violation(s)\n' "$VIOLATIONS" >&2
  exit 1
fi
printf 'leaklint: clean (%d tracked file(s))\n' "$(printf '%s\n' "$FILES" | wc -l | tr -d ' ')"
