# AGENTS.md — driving signet as an agent

You are likely an AI coding agent (Claude Code, Codex, Antigravity, …) being asked to
change or consume `signet`. This file is your front door. (Human-facing intro is in
[README.md](README.md); each package has its own README, and `packages/cli/SPEC.md`
is the authority for the CLI surface.)

Read the two rules about *copies* and *reaching live* before you change anything —
they are the two ways this repo gets broken by someone who did nothing wrong locally.

## What signet is, in one breath

Signet is **the design seal CVER stamps onto every surface** — one source of truth for
palette, tokens, glass, components, badges and voice, so the Mac apps and the sitetile
sites render as the same family. (Native consumers today: `clioil`, `andross`. The
README also names snapsift and reepub; neither has a `Package.swift`, so read that line
as intent, not as wiring.) It is **four packages in
one repo**, each turning the same roles into a different surface: `native` (SwiftUI),
`web` (CSS + Astro/Svelte, published as `@cvernet/signet`), `cli` (a static linter for
terminal output), `voice` (a localization ruler). The aesthetic will follow the times;
the seal is what stays — which is why the public API keeps a brand-stable `CVER*`
prefix (`CVERTheme`, `CVERRadius`) while the package is named `Signet`.

## Driving it headless (the part you'll actually use)

```bash
./scripts/test.sh                              # build + smoke checks — the ONLY mandatory suite (also CI, also pre-push)
swift build -c release                         # native only
swift run -c release SignetTests               # the framework-free smoke runner

./packages/cli/lint.sh --self-test             # prove the badge/format checks can still fire
./packages/cli/lint.sh FILE...                 # check a CLI's output strings; non-zero on any violation

python3 packages/voice/voicelint.py FILE...              # locale inferred from path (ir/zh-tw/… → zh-TW)
python3 packages/voice/voicelint.py --locale zh-TW FILE  # force a locale
```

All five verified passing in this checkout. `scripts/test.sh` is the whole gate — there
is no separate lint/typecheck step to remember.

**The pre-push gate is per-clone and off by default.** `hooks/pre-push` is tracked, but git
does not look there until you run `git config core.hooksPath hooks` once. Do that in a fresh
clone or you will push red. Note that this setting is repo-local and overrides any global
`core.hooksPath` you have configured, so install it deliberately rather than as a reflex.

## Non-negotiable rules (break one and you ship something you shouldn't)

1. **🔴 Never copy a signet file into a consumer. Import the package.** A seal that
   exists in two places is not a seal. This is not style — it is the one incident this
   repo is built around: in 2026-07 the locale banner was copied into a consuming site
   renderer, then got four weeks of fixes *on the copy only*, while both files still said
   `@cvernet/signet` in their headers, so everyone who checked was reading the stale one.
   That consumer now runs a detector in its own suite, firing on a filename clash with a
   signet export or on a file that begins with `/* @cvernet/signet`. If you feel the urge
   to "copy it and tweak", the answer is a PR here.
2. **Reaching live is three steps, and skipping any one means nothing shipped.**
   `npm publish` → bump the dependency in the consuming repo → redeploy that consumer. A
   merged commit on `main` is not a released web package, and a published package is not a
   live site.
3. **🔴 The native side has no version gate.** Its consumers depend on
   `.package(url: …/signet, branch: "main")` — verified today in `clioil` and `andross` —
   so **a push to `main` ships to them immediately**, with no tag, no semver, and no
   chance to hold it back. The web side is versioned through npm; the native side is not.
   Treat a `main` push as a release.
4. **Publishing is a human action, and it edits files behind your back.** The npm account
   uses passkey 2FA — there is no OTP to pass and no headless path; a human runs
   `npm publish` from a real terminal. And `npm publish` rewrites the `version` field in
   `package-lock.json` *after* your release commit. **So the finish check is `git status`,
   never "what did I change"** — your mental model of your own edits cannot see what the
   publish did.
5. **Read the header before touching `locale-banner.css` colours.** One file serves two
   host kinds — *themed* hosts (sitetile, which publish `--gd-*`) and *standalone* hosts
   (feelreef, only `--color-*`) — through a single fallback chain collapsed into `--lb-*`
   internals. The dark block swaps only the standalone tail of that chain; in a themed
   host it is a deliberate no-op. Editing it as if it had one host silently breaks the other.
6. **Don't repair `packages/web/test/locale-banner-equivalence.mjs`.** It is a frozen
   one-shot proof for 0.6.0, deliberately not wired into `scripts/test.sh`. Run it and it
   exits `0` after telling you why it cannot run: the third specimen it compared against —
   the pre-merge copy inside the consuming site renderer — was deleted upstream when the
   merge landed, which is the *success* condition. Its header records what it proved.
   Leave it as evidence.
7. **Only DECIDED rules get linted.** `packages/cli/lint.sh` deliberately does not check
   anything marked TBD in `SPEC.md` — a lint that guesses is worse than one that waits.
   If you want a new check, decide the rule in `SPEC.md` first.

## Honest scope (don't claim more than is here)

- **The suite is a smoke runner, not a test framework.** Command Line Tools ship no
  XCTest/Testing, so `SignetTests` is a plain executable guarding the invariants that
  break *silently*: ladder ordering, hex parsing, and that both themes wire every role.
  Visual correctness is not covered by anything here.
- **`voicelint.py` cannot tell you a sentence is bad.** It detects the mechanical residue
  of copy that was translated instead of transcreated (mainland vocabulary in zh-TW,
  scattered `あなた`, literal `당신`, …). A `[ PASS ]` means no fingerprints, not good prose.
- **`packages/cli/lint.sh` reads files and runs nothing.** It is never a runtime
  dependency of the CLIs it inspects; it only reads them.
- **Two themes ship** (`ReefTheme`, `AndrossTheme`). There is no theme registry, no
  runtime theme loading, and no web↔native token sync check — the two sides are kept
  aligned by hand.

## Where to look

- [README.md](README.md) — the API table, and how to add signet to a Swift package.
- `packages/cli/SPEC.md` — the authority for badges and terminal output; `AUDIT.md` for
  what was found in the CLIs.
- `packages/voice/README.md` — what the voice ruler can and cannot see, per locale.
- `packages/web/package.json` — the real export surface (`./corners.css`, `./Arrow.astro`, …).
- `.github/workflows/ci.yml` — macos-15, and it runs exactly `./scripts/test.sh`.
