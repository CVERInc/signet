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

**7. A step that needs software the reader may not have goes last.**
Within a list, rank by whether this tool can act at all, and only then by size.
Every "run this verb" row belongs together, and the one pointing at another
product sits at the end however large it is — a list that promises "here is what
to run" should keep that promise to its final line rather than break it halfway
down. Note the test: not "is it outside this tool" (System Settings is outside
too, and stays where its size puts it) but **"might the reader not have it"**.
This is the same admission the pointer itself already makes by printing a URL
only when the tool isn't installed.

**8. A report answers only the question it promised to answer.**
Information riding along gives itself away, and usually the tell is a column it
can't fill. *Failure that taught it:* a "Homebrew updates available: 2" row sat
in a group headed "Cleanable, inside the above" — space you can reclaim — with a
bare `2` in the size column, because updates aren't space and upgrading may well
use more. The instinct was to find something to put there (leave it blank? a
dash?). The right move was to ask why it had nothing, and the answer was that it
belonged to a different verb. **When a row can't fill a column, suspect the row,
not the column.**

**9. Never claim what didn't happen.**
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
| `[ CRIT ]` | past the line, not merely near it | — |
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

**`WARN` vs `CRIT` is the same question one step further: has the line already
been crossed?** `WARN` is "look at this"; `CRIT` is "this is already costing you
something". A tool that only *acts* rarely needs the rung — sheersweep's 25
status keys mapped onto the other five with none left over. A tool that
*measures* always does, because "getting full" and "already thrashing" are not
the same reading and flattening them makes the report useless at the exact
moment it matters.

> *The set was derived from the tool that acts, and the tool that measures needed
> a rung it didn't have.* Found by the lint on its first real run, not by
> reading — the vocabulary check fired on sheerstatus's `[CRIT]` and there was no
> honest way to rewrite it as one of the five. **A closed set derived from one
> member is a sample of one.**

### Sizes — decided

**A size is written the way this machine writes it to its owner**, because the
owner can check us. That is not one rule but two, and the base follows the
**domain**, not the tool that happens to report it:

| domain | base | example | what macOS shows |
|---|---|---|---|
| **storage** — disks, files, caches | **decimal** (1000) | `202.7 GB` | diskutil / Finder / System Settings: `202.7 GB` |
| **memory** — RAM, swap | **binary** (1024) | `16 GB` | About This Mac: `16 GB` · `vm.swapusage`: `3072.00M` |

The unit is spelled out — `GB`, `MB`, `KB` — as macOS spells it. That also tells
it apart at a glance from `du -h`'s binary `G`/`M`, which is an existing
convention rather than one invented here.

*Failure that taught it:* every size in sheersweep was `du -h`'s binary output —
`189Gi` where diskutil said `202.7 GB` for the same volume. **No surface the
owner could check us against used our number.** And the map points at System
Settings, so we were sending people to a figure that wouldn't match the one we
had just shown them — a seam we made ourselves.

*Second failure, in the sibling:* sheerstatus divided by 1048576 and printed the
result as `228 GB` — a GiB value wearing a decimal label, which is worse than
either base used honestly.

Two traps worth writing down:

- `df -H` is decimal, but **`du -H` means "follow symlinks"**. The flags do not
  mirror each other; do the arithmetic yourself from `-k` blocks.
- Quoted third-party figures need checking, not converting. Homebrew divides by
  1000 and writes `MB`; `du` divides by 1024 and writes `M`. Those had been
  sitting in one column looking comparable. Once the column is decimal, brew's
  figures need no conversion at all — **the odd one out was us**.

A guard belongs in the test suite, and it should name what the *wrong* answer
looks like: `102400 KB` is exactly 100 MiB, so decimal renders `105 MB` and
binary would render `100M`. A test that only asserts the right string can pass
while the formatter silently changes base.

### The result of an action — decided

**The number is the disk's answer, not ours.** What a tool removed is what it
*meant* to remove; free space before and after is what actually happened. They
differ for ordinary reasons — a file was still open, two paths were one inode,
a sparse file was never occupying what it claimed. Reporting our own sum is
reporting our intent and calling it a measurement.

**The unit follows the number, and a rounded-away result is a false report.**
`0.0 GB freed` after clearing 57 MB is not a rounding artefact, it is the tool
saying it did nothing. Use the same size rules as everywhere else — the unit is
chosen per value, so a small win reads as a small win instead of as a failure.

**When the delta is zero or negative, change the sentence, not the number.**
Something else wrote to the disk while the sweep ran; the honest line names what
the tool did (`Moved 23 items to Trash`) instead of reporting a delta the tool
did not cause. Printing `-1.2 GB freed` blames the tool for the machine, and
printing `0.0 GB` when 23 things moved is ruler 9.

### Structure — decided

| role | rendering |
|---|---|
| group header | `▸ Title`, with its rows directly beneath |
| list item, read-only | `·` |
| list item, selectable | `N)` — the number **is** the mark |
| next step | `→ where to go` |
| rebuild hint | `↺ <full paste-anywhere command>` |
| separation between groups | a blank line — **no horizontal rules** |
| selection mark | `[x]` / `[ ]` |
| level, with an honest unknown | `● / ○` |

**One character, two jobs: `·`.** It marks an item at the head of a line and
separates fields inside one (`build output · 9`, `oss.cver.net/x · MIT`). `•` is
retired family-wide — it was never doing a job `·` wasn't.

**`▸` is the header mark because it is the only one that survives a pipe.** ANSI
bold and a `----` rule both vanish into a file, and the reader is left unable to
tell a title from a row. A rule is worse than nothing: it draws a border around
a region it does not actually contain. `▸` plus a blank line already segments
the page, and it segments it in the copy someone pastes into an issue.

**The blank line goes between groups, not under the header.** A title and its
rows are one block; separating them would make the header float free and imply
a break where there is none.

**A report title is not a group header.** The line that names the whole report
carries no `▸` — the `▸` headers beneath it are its groups, and a mark on both
puts a parent in competition with its own children. `The sheersweep:` and
`Reclaim build output —…` head reports; `▸ Yours to act on` heads a group.

**A group header may carry a badge, but never opens with one.** `▸` says a group
starts here; a badge says what state it is in. Two marks, two jobs — and the
badge is there because of ruler 4: when every row in a group shares a state, the
state belongs to the group.

```
▸ [ WARN ] Unidentified — heavy, gitignored, and I can't prove these are safe
```

**A note is not an item.** A line that summarises the list it follows takes no
bullet, and never borrows the size column to hold something that isn't a size.

**`↳` is the outcome of the row above it.** `·` says *this is one of the things*;
`↳` says *this is what happened to the thing above*. They are different
relationships, and indentation alone cannot carry the second one — an indented
`·` still reads as a nested item rather than a result.

```
   3) 1.2 GB  ~/proj/crawl
        ↳ skipped — kept in place.
```

This mark was very nearly deleted for tidiness: it is the only structural
character outside `·` and `▸`, the lint has never enforced it, and "the family
has two marks" is a cleaner sentence than "the family has three". What stopped
it was asking what `·` would say in its place — and the answer was *something
false*. A mark that survives that question has earned its place (ruler 1); a
mark deleted because the set looked tidier has only made the set tidier.

It never opens a group and never carries a badge. If the outcome needs a state,
the row above it takes the badge.

**The magnitude leads, and the variable-width field goes last.**

This was first written as "the *sort key* leads", to justify one list holding
two shapes — a name-sorted section leading with the name, a size-sorted one with
the size. That clause lasted a day. Asked whether the rule and the interface
were really the same thing, the honest answer was no: the name-sorted section
was the exception, and the rule had been bent around it.

Sorting everything by magnitude removed the exception and the clause with it.
It was also just better: **a picker is the discovery path, not the lookup path.**
Anyone who knows which app they want already has a door — `uninstall <name>` —
so the list is for asking *what is here and what does each cost*, and that
question wants the heaviest row at the top.

The second half of the rule is not taste. A field of unbounded width in the
*middle* of a row shears every column after it the moment something is longer
than the padding you guessed:

```
   20) com.getdropbox.dropbox.alternatenotificationservice    33 KB  (…)
   19) com.getdropbox.dropbox.garcon                   61 KB  (…)
```

Put it last and no input can break the layout, because nothing is lined up
against it:

```
   19)    61 KB  com.getdropbox.dropbox.garcon
   20)    33 KB  com.getdropbox.dropbox.alternatenotificationservice
```

**A hint that repeats the row is not a hint.** The picker used to append a
guessed vendor to every orphan id — `com.dropbox.DropboxMacUpdate
(dropboxmacupdate?)`. Measured against 1073 real bundle ids, **1067 were the
id's own last component, lowercased**, printed two columns from the id itself;
four in a thousand said something new. It cost more than the noise: the same
parentheses carry facts elsewhere, and a mark that is filler 99% of the time
teaches the reader to stop looking inside them.

> *A glyph that dissolved.* `leftovers` used `↳` for "what this row refers to" —
> a real job neither `→` nor `↺` does, so it looked like it had earned a place.
> Re-rendered as a picker row, the fact fit in the parentheses that already
> carry `(what)`, and the third arrow was simply not needed. **Before adding a
> mark, check whether an existing shape can hold the fact** — a mark earns its
> place by doing a job no other mark does, and "no other mark does it *here*" is
> not the same test.

```
▸ system-wide
   ·   108 MB  (/Library/Caches)

▸ Yours to act on
   ·  41.1 GB  (/Users/tin)
     → System Settings › Users
```

**A number is a promise you can act.** `N)` says "type this"; `·` says "this is
for reading". Never decorate a numbered row with a bullet as well — that is two
marks for one meaning, and it makes the reader look for a difference that
isn't there.

#### Colour

**Colour may amplify. It may never carry.** Strip every escape sequence and the
output must lose speed, not meaning. Non-TTY turns it off automatically, and
`NO_COLOR` is honoured.

The family's own reference implementation is clikae's fuel gauge, and it is
worth reading before writing any coloured output:

```
● claude/h   over quota · resets 3pm      ← red,    and it says so
● claude/l   82% this week                ← yellow, and it says so
● codex/main                              ← green,  nothing to say
○ gemini                                  ← dim, and the shape differs
```

Two of the four states are the ones that cost you something, and both spell
themselves out in words on their own row. The third — everything is fine — needs
no words at all. The fourth isn't a level, it's the absence of a reading, so it
gets a **different shape**, not a different colour.

So: **the states that matter are carried by text, the rest by shape, and colour
by neither.** Delete every escape sequence from that block and all four states
are still distinguishable. That is the test, and it is mechanical: pipe it to a
file and read the file.

It also shows what *not* to spend words on. Green says nothing because "fine"
needs no explanation — the same instinct as putting state on the group instead
of on every row.

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
| crit | `[ CRIT ]` | `"crit"` |
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

**Narration takes the same badges as a report.** The stream is what makes a line
narration — not a second vocabulary. clikae had run `[OK] [INFO] [WARN] [ERR]`
for years beside reports saying `[ PASS ] [ WARN ]`, so a person met two spellings
of one meaning in a single session with nothing to explain the difference.

And the badge set does the same work here that it does in a report: `[OK]` was
carrying both *I did something* and *I checked and there was nothing to do*.
Sorting 63 call sites by the usual question — did this change the state? — split
them 54 to 9 with nothing left over.

A log level with no state behind it takes **no badge**. `[INFO]` isn't a state,
it's the guidance that follows one ("No alias added. Run `clikae alias …`"), so
it indents under the badge column and claims nothing. Same instinct as green
needing no words: a mark earns its place by doing a job no other mark does.

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
