# Drift audit — what the three CLIs actually do today

**Read-only.** This file records what is, not what should be. Every number was
grepped or run on 2026-07-26; nothing here is from memory. Decisions live in
`SPEC.md`; unresolved questions are marked **TBD** and must not be settled by
whoever reads this — they go back to chodaict.

This is the CLI counterpart of the observation that created Signet in June:
*every app had independently grown the same color-role taxonomy and just drifted
on the hex values.* Same disease, third surface — the roles below are identical
across all three tools; only the characters drifted.

The tools point at each other (`sheerstatus → sheersweep → clikae`), so a person
can walk all three in one sitting and meet three languages.

---

## The table

| Role | sheersweep | sheerstatus | clikae |
|---|---|---|---|
| **Group header** | `▸ Title` | bare text after a blank line, under a `----` rule | ANSI **bold** text, 2-space indent, no glyph |
| **List item** | `·` | `•` | **both** — `·` ×119, `•` ×61 |
| **Next step** | `→` ×98 | **none (0)** — advice is prose under "Recommendation" | `→` ×150 |
| **Rebuild hint** | `↺ cd … && npm install` | — | — |
| **Status** | emoji: `✅ 🔴 ⚠️ ❌ 🔒 ✨` | `[PASS] [WARN] [CRIT]`, **translated** in ja/zh/ko | ANSI colour + `● ○` + `yes/no/-` in tables |
| **Level indicator** | — | — | `●` (green/yellow/red) / `○` = *no reading* |
| **Selection** | numbered picker (`64) com.spotify…`) | — (non-interactive) | `[x]` / `[ ]` checkboxes ×3 |
| **Horizontal rules** | **0** (33 retired 2026-07-26) | 3 | 21 (`─`) |
| **ANSI colour** | **0** | **0** | **67** escape sites, ~196 colour-var uses |
| **Machine output** | — | `--json` | — |
| **stdout / stderr split** | data → stdout, notice+heartbeat → stderr | not separated | not audited |

### Header signature — two of three, and it stops at line 4

```
sheersweep  — the Mac cleaner you can read.
              Open source · dry-run first · hard never-touch list · sweeps every account.
              https://oss.cver.net/sheersweep  ·  MIT © CVER Inc.

sheerstatus — the zero-daemon hardware & pre-upgrade auditor you can read.
              Open source · macOS & Linux · hard-data verdict · single-file Bash.
              https://oss.cver.net/sheerstatus  ·  MIT © CVER Inc.
```

Same three-line mould, same `·`, same *"you can read"*, same URL and licence
line. It just never propagated past the header into the output.

**clikae — the oldest of the three — never got the mould:**

```
clikae      - CLI profile switcher  (kirikae, "switch")
              https://github.com/CVERInc/clikae
              MIT License
```

Plain hyphen instead of the em dash, no *"you can read"* claim, `github.com`
instead of `oss.cver.net`, `MIT License` instead of `MIT © CVER Inc.`

> A first draft of `SPEC.md` claimed **all three** tools shared the mould. Two
> had been checked. The third was asserted. That is the same failure this whole
> audit exists to prevent, committed inside the audit — and it was the lint that
> caught it, on its first real run.

**And the URL in the seal is currently a promise two of the three break.**
Checked 2026-07-26:

```
https://oss.cver.net/clikae       200  → redirects to clikae.cver.net (a real page)
https://oss.cver.net/sheersweep   404
https://oss.cver.net/sheerstatus  404
```

`oss.cver.net` lists bleedblend, demodeck, liquidframe, motifmint and seikyusho
— neither sheer tool has a page there. So the one tool **without** the seal is
the only one whose URL resolves, and the two that carry it print a dead link in
their first four lines.

The two 404s are not the same kind of problem:

| | published? | the claim |
|---|---|---|
| sheersweep | yes, on GitHub | a **live tool printing a dead link** |
| sheerstatus | **no git remote at all** — local only | aspirational; the page can't exist yet |
| clikae | yes | true |

The lint checks the URL's *shape*, not that it answers; a network call has no
place in a static check. **TBD — create the pages, or change the line?** Not
decided here, and it isn't a wording problem: it is a live claim that isn't true.

Note the irony in row 2 of the table: **sheerstatus's header uses `·` while its
own output uses `•`.** The sealed part is consistent; the improvised part drifted.

---

## Findings that changed the plan

### 1. Colour is the deepest drift, and it was missing from the plan

`sheersweep 0 · sheerstatus 0 · clikae 67`.

> **If you re-run this, mind the pattern.** A first pass that included a bare
> `tput` reported 11 and 5 for the two colourless tools — every hit was the word
> **out·put**, which contains `tput`. The wider net was *worse* than the narrow
> one. Use `\\033[` / `\\x1b[` / `\\e[` / `tput` with a word boundary, and always
> keep a control that **must** be non-zero (clikae) so a silently-broken pattern
> can't read as "all clean".

Two tools are entirely colourless; one is heavily coloured. This is a bigger
split than any glyph, and it bears directly on the status decision: the original
argument for emoji was *"colour conveys severity faster than text"* — but
sheersweep has no colour at all, so its emoji were **standing in for** colour.
clikae has the real thing.

Three different answers to "how do you show severity":

| | mechanism |
|---|---|
| sheersweep | colour-by-glyph (emoji) |
| sheerstatus | text badge, no colour |
| clikae | real ANSI colour |

**TBD — does the CLI signet use colour at all?** Not decided. Arguments exist on
both sides (speed of recognition vs. piping to files, CI logs, `NO_COLOR`,
terminal themes, colour-blindness). This is the single largest open question and
it outranks `·` vs `•`.

### 2. A sixth role the five badges don't cover

clikae's `●` / `○` is not PASS/WARN/FAIL. It is a **level indicator with an
honest unknown**:

- `●` — a reading exists; its *colour* carries the level
- `○` — **no reading** (from the source: *"an honest ○ 'no reading'"*)

That "we don't know, and we say so" state is the same instinct as sheersweep's
*"unreadable even to root — no tool can total it"*. It is a real role, it exists
in the family, and the five-badge set has no slot for it.

**TBD — is "level with an honest unknown" a family role?** If yes it needs a
rendering; if no, clikae needs a different way to say it.

### 3. sheerstatus has no next-step arrows at all

`→ ×0`. Its advice is prose:

```
Recommendation
  • If lag persists, consider upgrading RAM and storage on your next machine.
  • Consider using sheersweep to free up disk space.
```

Both other tools point with `→` (98 and 150 uses). This is not a glyph choice —
it is a missing role. Aligning sheerstatus means *adding* pointers, not
translating them.

### 4. clikae is internally inconsistent — and closer to sheersweep than sheerstatus is

`·` ×119 and `•` ×61 in the same codebase, both in output paths
(`lib/core/tui.sh`, `lib/commands/*`). So the `·` vs `•` question is not only
between tools; it is inside one.

But note the direction: clikae's dominant separator (`·`) and pointer (`→`)
already match sheersweep. The outlier on those two rows is sheerstatus.

### 5. The system-dictionary audit item partly evaporated

The audit was meant to check each status word against the OS's own strings —
prompted by sheerstatus's Japanese `[混雑]` (*congested*), where macOS says
「メモリプレッシャー」 for memory pressure.

The **do-not-translate ruling makes those four words moot** — `[混雑] [吃緊]
[不足] [赤字] [正常] [良好] [정상] [주의] [경고]` are all being removed.

The rule still applies to the *nouns* each tool translates (Storage / Battery /
Memory → ストレージ / バッテリー / メモリ, which do match macOS). **TBD — a
method for checking a term against the OS's own language pack**, so this is an
audit that can be re-run rather than a one-time opinion.

---

### 6. Every tool wrote sizes in a base its owner could not verify

Same volume, four answers:

```
diskutil / Finder / System Settings   202.7 GB   ← what the owner sees
brew (divides by 1000)                 …MB       ← agrees with macOS
sheersweep (du -h)                     189Gi     ← agrees with nothing on screen
sheerstatus (÷1048576, printed "GB")   188 GB    ← a GiB value with a decimal label
```

The odd ones out were ours, and the sibling's was the worst of the four: the
right label on the wrong arithmetic. Both are fixed — see the size rules in
`SPEC.md`, which also record the two traps (`du -H` is not `df -H`; memory is
binary, storage is decimal, and macOS is consistent about both).

Found only because a bullet and a two-letter suffix looked inconsistent in one
column. The notation was the symptom; the numbers were the defect.

## Roles inventory (what a spec has to cover)

Structural — every tool has all of these, whatever it calls them:

1. Banner / identity line
2. Group header
3. List item
4. Next step (pointer out of, or deeper into, the tool)
5. Separation between groups
6. Progress / narration while working
7. Result of an action

State — the closed set is decided (see `SPEC.md`); these are the meanings found
in the wild:

| meaning | seen as |
|---|---|
| checked, nothing to do | `✅ No leftovers` · `[PASS]` · **`✨ nothing eligible`** |
| done, something moved | `✅ Moved 3 items to Trash` |
| needs your judgement | `⚠️ Likely orphans (review)` · `[WARN]` |
| operation failed | `❌ couldn't be moved` · `⚠️ could not restore` |
| can't be touched | `🔒 container hint` |
| level, with honest unknown | `● / ○` **(no slot yet — TBD)** |

Two glyphs for one meaning inside a single tool: sheersweep says "nothing to do"
with **both** `✅` (no leftovers / no orphaned dependencies) and `✨` (nothing
eligible to reclaim). Found only on a second pass — the first inventory missed
`✨` entirely, which is the argument for a lint over an eyeball.

Two overloads found in sheersweep, both invisible until something forced a
choice:

- `⚠️` carries **both** "needs your judgement" and "the operation failed"
- `🔴` carries **three** things: a protective refusal (*"refusing: {app} is on
  the sealed system volume"*, *"installed formulae depend on it"* → that is
  `HELD`, not a failure), a partial failure (*"only 3 of 5 items could be
  moved"* → `FAIL`), and **"this tool doesn't run on this platform"**, which is
  neither.

The badge set forces these apart — the width limit is a semantic forcing
function.

> **This first read blocked the work, and was wrong.** The third `🔴` case —
> *"sheersweep is macOS-only"* — was called homeless, but `[ FAIL ]` means "this
> didn't succeed", and a run on the wrong platform is exactly that. All 25 keys
> mapped onto the five with no new decision needed; sheersweep converted the same
> day. Only sheerstatus's third severity rung is genuinely open.

Interactive — presentation only in v1:

8. A selectable row and its selected/unselected mark

---

## Open, deliberately not decided here

- **Colour: in or out of the CLI signet?** (finding 1 — the biggest)
- **`·` vs `•`** — and clikae uses both, so this needs a *job* for each, or a cull
- **Is `▸` the family group header?** (only sheersweep uses it; clikae has 2 uses)
- **Do horizontal rules retire family-wide?** (sheersweep 0, sheerstatus 3, clikae 21)
- **Is `[x]` the family selection mark?**
- **Is "level with honest unknown" a family role?** (finding 2)
- **Does the badge set need a third severity rung?** sheerstatus runs
  `[PASS] → [WARN] → [CRIT]`; the five-badge set has one rung of concern. Found
  by the lint on its first real run — the set was derived from the tool that
  *acts*, and the tool that *measures* needs a ladder. **This blocks converting
  sheerstatus's badges.**
- **A repeatable method for the system-dictionary check** (finding 5)
- **When sheerstatus's 9-locale tests get rewritten** for the do-not-translate ruling

---

*Audited 2026-07-26. Re-run the counts before trusting them — they are a
snapshot, and the point of the lint is that nobody should have to.*
