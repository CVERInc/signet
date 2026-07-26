# Signet · CLI

The plain-text surface of CVER's design system — the third renderer, after
`native` (SwiftUI) and `web` (CSS/JS).

In a terminal there is no layout engine, no typeface, no colour swatch to lean
on. **The characters are the interface.** So "the same thing written two ways"
is not untidy — it is a UI bug, the way a button that sometimes looks like a
label is a UI bug.

The seal already existed before this file did — in the header of the two newest
tools, identical down to the `·`:

```
<name> — the <thing> you can read.
Open source · <promise> · <promise> · <promise>
https://oss.cver.net/<name>  ·  MIT © CVER Inc.
```

It stopped at line 4 and left the output to improvise. And the oldest of the
three, clikae, never got it at all — a plain hyphen, a GitHub URL, `MIT License`.
So the convergence was real but partial, and entirely undocumented: two tools
found the same shape by hand, one didn't, and nothing would have caught that.

This package carries the seal the rest of the way, and writes it down.

## What this governs — and what it must not

| | |
|---|---|
| **Governs** | roles, and how each role renders in a terminal (and in `--json`) |
| **Does not govern** | any tool's JSON *schema*, its verbs, its features, its keybindings |

> **Hard constraint: doc + lint only. Never a runtime dependency.**
> sheersweep sells *"one file you can read end to end"* and zero dependencies;
> sheerstatus sells *"single-file / zero deps"*. A shared library would break
> both promises at once. Drift is prevented in CI, never at run time.

The public role names are brand-stable, the renderings are not — the same reason
`native` keeps a `CVER*` prefix while the package is called Signet. **The
aesthetic follows the times; the seal stays.** When `▸` is replaced one day, one
row of the table changes, not three repositories.

---

## The rulers

These generate the decisions below. When a new case appears that the tables
don't cover, reach for these — not for a vote.

**1. A mark earns its place by doing a job no other mark does.**
Everything else is costume. `♻️` as a section banner said nothing `▸` didn't; it
went. `♻️` in a list of three findings, where the glyph is what tells them apart
at a glance, stayed until the words alone proved enough.

**2. Same meaning, same mark. Different component, different layout.**
A progress log and an inventory are different components; they share tokens but
need not share a shape. Consistency is *token-level*, not uniformity.

**3. What structure can avoid computing, don't compute.**
*Failure that taught it:* aligning `→` after a variable-width label meant
measuring CJK display width — unsolvable in portable shell, and `column` gets it
wrong too. Moving the action onto its own indented line deleted the problem
instead of solving it. Prefer the layout that needs no layout engine.

**4. State belongs to the group, not to every row.**
*Failure that taught it:* five stacked `⚠️` stop being read by the third one —
the same reflex a wall-of-text confirmation trains. One warning over the group
keeps it sharp; rows below return to a plain item mark.

**5. A pointer is a promise.**
Only point at something the tool can actually assert. An unrecognised path gets
no pointer at all — the absence is information. *Failure that taught it:*
"`/opt` is probably Homebrew" is true on this machine and false on an Intel Mac;
asking `brew` where it lives is true everywhere.

**6. If it can't be said in four characters, it isn't a badge — it's a message.**
And if it needs a sentence of context, it isn't a badge either.

**7. Never claim what didn't happen.**
*Failure that taught it:* a dry-run that reports a freed-space delta is reporting
a number it invented. It freed nothing; it may say only that.

> These are the best answers so far, not a constitution. **A concrete new case
> beats an old generalisation.** Every rule above exists because something
> specific went wrong; the next specific thing may retire it.

---

## Roles → renderings

### State badges — decided

A closed set. Anything else in `[ ---- ]` shape is a lint violation.

| badge | means | test |
|---|---|---|
| `[ PASS ]` | checked, nothing needed doing | state **unchanged** |
| `[ DONE ]` | it happened, something moved | state **changed** |
| `[ WARN ]` | needs your judgement | — |
| `[ FAIL ]` | the operation did not succeed | — |
| `[ HELD ]` | can't be touched (protected / sealed) | — |

**Shape: `[ PASS ]` — eight columns.** Two brackets, two spaces, four letters.
The padding is not decoration: it separates a *status badge* from a *checkbox*
(`[x]`), which are otherwise the same visual family and get misread as
selectable.

**Never translated.** `[ WARN ]` stays `[ WARN ]` in every locale.

- fixed width stops being a discipline and becomes a property
- greppable across languages — someone can paste a log and you can search it
- deletes dozens of translation strings that could rot
- the terminal's own status vocabulary is untranslated everywhere: `dmesg`,
  `systemctl`, every log level ever shipped

The prose *after* the badge is still localised, so mixed script is expected and
fine — `[ WARN ] メモリ：…`. The badge is a visual anchor; the sentence carries
the meaning.

**PASS vs DONE is decided by one question: did this line change the disk?**
Seven real lines were tested and none was ambiguous, including the hard one
("Kept 23 items untouched" → `PASS`; the tool deliberately did nothing).

This makes `[ DONE ]` a claim that can be caught lying: **a `[ DONE ]` in a
dry-run is a phantom**, the same red line as a dry-run reporting a delta.

*Failure that taught the closed set:* `⚠️` was carrying both "needs your
judgement" and "the operation failed" — one glyph, two meanings, so the reader
can't tell whether to look or to worry. Being forced to choose between
`[ WARN ]` and `[ FAIL ]` makes you decide what it actually is. **The width
limit is a semantic forcing function.**

*Failure that taught the four-character rule:* `[LOCKED]` is eight, which breaks
the column. The answer isn't a shorter synonym — it's that the rule tells you
when something was never a badge.

> **TBD — the set may not be closed yet.** It was derived from sheersweep, which
> *acts*. sheerstatus *measures*, and runs a three-rung severity ladder:
> `[PASS] → [WARN] → [CRIT]`. `CRIT` has no home here — `WARN` would flatten the
> ladder, and `FAIL` means "the operation didn't succeed", not "the reading is
> bad". Either the set grows a rung or the ladder loses one; **do not decide this
> by writing code.** It blocks converting sheerstatus's badges.

### Structure — partly open

| role | rendering | status |
|---|---|---|
| group header | `▸ Title` | **TBD** — only sheersweep uses it today |
| list item | `·` | **TBD** — `·` vs `•`, and clikae uses both |
| next step | `→ where to go` | decided in shape; sheerstatus has none yet |
| rebuild hint | `↺ <full paste-anywhere command>` | sheersweep only; family fit TBD |
| separation between groups | a blank line | **TBD** — do rules retire family-wide? |
| selection mark | `[x]` / `[ ]` | **TBD** — family role or clikae's own? |
| level with an honest unknown | `● / ○` | **TBD** — is this a family role at all? |
| **colour** | — | **TBD, and the biggest one** |

On colour: two tools use none, one uses it heavily (see `AUDIT.md`). sheersweep's
emoji were standing in for colour it never had; clikae has the real thing. Not
decided here. Do not decide it by writing code.

Two shapes that *are* settled, because they came out of specific failures:

- **A row with a next step is two lines** — `· size (what)` then, indented under
  it, `→ where to go`. This is ruler 3: the variable-width part sits
  ragged-right where nothing has to line up with it.
- **A pointer must be runnable as-is.** `↺ cd /absolute/path && npm install`,
  not `npm install` — the line gets copied into a fresh shell that is not in
  your repo. Absolute is uglier and honest.

### Machine output — roles only

`--json` is the fourth renderer of the same roles:

| role | terminal | json |
|---|---|---|
| pass | `[ PASS ]` | `"pass"` |
| done | `[ DONE ]` | `"done"` |
| warn | `[ WARN ]` | `"warn"` |
| fail | `[ FAIL ]` | `"fail"` |
| held | `[ HELD ]` | `"held"` |

Signet names the shared vocabulary. It does **not** define what fields a tool
reports — that is the tool's business, exactly as Signet doesn't define which
screens an app has. Only one tool ships `--json` today, which makes this the
cheapest moment there will ever be to agree the words.

### Streams

**stdout is data. stderr is narration.**

Progress notices, heartbeats and "measuring…" lines go to stderr; the report
goes to stdout. A person sees both; a pipe gets only the data. This is testable,
so the lint can hold it.

---

## Voice

> Follow the language pack inside the system itself. No internet slang — it
> rots, and then it's embarrassing.

That is the whole rule, and it is deliberately not a link to anywhere: a
reference rots, and a copy would create the second source of truth this package
exists to prevent. It points the dictionary at the machine.

*It works:* the best label written on 2026-07-26 was `→ System Settings › Users`
— Apple's own words, including Apple's own `›`.

## Stance

The part no lint can check, and the part that is actually recognisable as ours.

- **Show everything; decide nothing.** Being able to see is the tool's duty;
  whether to act belongs to whoever holds sudo. Never withhold a fact because
  the tool judges it "not yours to touch".
- **Say what you cannot see.** `50.7G unreadable even to root — no tool can
  total it` is the signature. A competitor has no reason to write that line.
- **Never claim a feature that isn't wired up**, and never a number you didn't
  measure.
- Reversible **xor** regenerable: destructive reach is earned by one or the
  other, never by neither.

---

## Interactive components

v1 governs **how a selectable row looks** — its shape, its header, its
selected/unselected mark. A selectable row is still a row; leaving it out would
move the seam from *between* tools to *inside* one.

v1 does **not** govern the interaction contract — which keys do what, how cancel
works, how much friction a destructive action needs. That is a consent-and-safety
discipline, not a visual one, and it deserves its own round.

> **Change the look, never the keys.** clikae is daily muscle memory for the
> person who maintains it.

Principles already true across the family, recorded here as a starting point for
that round, not as enforced rules:

- destructive actions confirm by typing the name, not by pressing `y`
- a confirmation prompt stays short — a wall of text trains a rubber stamp
- `all` never silently includes the rows that need individual consent
