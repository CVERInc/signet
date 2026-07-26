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
| **List item** | `·` ×112, **`•` ×36** | `•` ×54 | `·` ×103, `•` ×21 |
| **Next step** | `→` ×98 | **none (0)** — advice is prose under "Recommendation" | `→` ×150 |
| **Rebuild hint** | `↺ cd … && npm install` | — | — |
| **Status** | emoji: `✅ 🔴 ⚠️ ❌ 🔒 ✨` | `[PASS] [WARN] [CRIT]`, **translated** in ja/zh/ko | ANSI colour + `● ○` + `yes/no/-` in tables |
| **Level indicator** | — | — | `●` (green/yellow/red) / `○` = *no reading* |
| **Selection** | numbered picker (`64) com.spotify…`) | — (non-interactive) | `[x]` / `[ ]` checkboxes ×3 |
| **Horizontal rules** | **0** (33 retired 2026-07-26) | 3 | **0** (28 are source comments) |
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

### 4. Two tools were internally inconsistent, not one

clikae prints `·` ×103 and `•` ×21; **sheersweep prints `·` ×112 and `•` ×36.**
So the `·` vs `•` question was never only between tools — it was inside two of
them, including the one being used as the reference.

sheersweep's 36 all live in the localised `--help` heredocs, which is why the
first pass called it "all `·`": the counts were taken over the report-building
code, and help text is output too. **A tool's language includes the part you
only read once.**

On the other two rows, note the direction: clikae's dominant separator (`·`) and
pointer (`→`) already match sheersweep. The outlier there is sheerstatus.

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

### 7. Three of this table's own numbers were wrong, in both directions

Corrected 2026-07-27, when the decided rules got a lint and the lint was pointed
at the real files:

| row | first pass | actual | why |
|---|---|---|---|
| clikae horizontal rules | 21 | **0** | all 28 are `# ── section ──` source dividers |
| sheersweep list item | all `·` | **`•` ×36** | its localised `--help` was never counted |
| clikae list item | `·` 119 / `•` 61 | `·` 103 / `•` 21 printed | the rest are comments |

Every one of them came from grepping the *file* to answer a question about the
*output*. A comment is source; a reader never sees it. And the retire-the-rules
decision was taken with "clikae: 21" sitting on the table — the honest number
was one line, in one tool.

The fix is not to count more carefully next time. **The lint already knows the
difference** — `_skip_line` exempts comments, because a rule about printed text
can't be broken by text that is never printed. So the counting moved into the
lint, and this table is now a snapshot of something a machine re-derives:

```sh
signet-cli-lint sheersweep bin/clikae $(find lib -name '*.sh')
```

*An audit that reads is a first draft; an audit that runs is the audit.*

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

## Open

Everything structural was decided on 2026-07-26/27 and is in `SPEC.md`: colour
amplifies but never carries, `·` is the one bullet, `▸` is the group header,
rules retire, `[x]` is the selection mark, `● / ○` stays (clikae turned out to
be the reference implementation, not the exception), and `CRIT` joined the set.

Closed on 2026-07-27, each one worth the sentence it took:

- **clikae's log prefixes.** `[OK]` was carrying the PASS/DONE overload the badge
  set exists to force apart. Sorting 63 call sites by *did this change the
  state?* split them 54 / 9. `[INFO]` lost its badge — it isn't a state, it's
  the guidance that follows one. **Narration takes the same badges as a report**;
  the stream it goes to is what makes it narration, not a second vocabulary.
- **clikae's section headers were a colour.** Found while doing the above:
  `  Tanks` was bright cyan and nothing else, so a pipe lost the header entirely.
  Marked in both render paths.
- **The snapshot count in a size column** → an em dash, with the count moved into
  the label. A snapshot's size genuinely cannot be measured, and saying so is
  the same move as "unreadable even to root".
- **sheerstatus was 4-locale below the nouns** — and so was its verdict section,
  and `zh-Hans` was reading Traditional throughout. Fixed, and the gate that
  should have caught it was rebuilt (see below).
- **Both harnesses** now speak the family's language and are linted.

Still open:

- **A repeatable method for the system-dictionary check** (finding 5)
- **`https://oss.cver.net/sheersweep` and `/sheerstatus` still 404** — a live
  tool printing a dead link in its first four lines. sheerstatus is at least a
  real repo now (`CVERInc/sheerstatus`, public 2026-07-27); the pages are not
  built. Copy and distribution are the maintainer's craft, so this waits for him.
- **clikae's inline bold.** 62 of its 63 bold sites are emphasis inside a row,
  not headers. Whether emphasis needs a family rule at all is undecided.

### The gate that could not see what it was for

worth recording on its own, because it is the shape of the whole exercise:

sheersweep's i18n check asked *does `t <key>` return something in every locale?*
A key missing a locale falls through to `*)` and returns English — which is very
much something. It could only ever catch a typo'd key name, while its comment
claimed it caught silent fallbacks. **It passed for months because the codebase
happened to be clean, not because the check worked.**

Found by writing the same weak check for sheerstatus and watching it bless a
four-locale section as nine. The replacement reads the shape rather than the
value: a key whose body opens `case "$SS_LANG"` is claiming per-language text,
so every locale must appear as a branch label. That forced `en-US|*)` across both
tools — one label meaning both "English" and "any language we haven't heard of"
is exactly what made the gap invisible.

*A check you have never seen fail is a check you have never seen.*

---

*Audited 2026-07-26. Re-run the counts before trusting them — they are a
snapshot, and the point of the lint is that nobody should have to.*
