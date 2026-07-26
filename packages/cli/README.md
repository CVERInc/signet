# Signet · CLI

The plain-text surface of the CVER design system — the third renderer beside
[`native`](../native) (SwiftUI) and [`web`](../web) (CSS/JS).

`native` and `web` render roles as colours and components. This package renders
the same roles as **characters**, because in a terminal the characters *are* the
interface — which is why "the same thing written two ways" is a UI bug here, not
a matter of taste.

| file | what it is |
|---|---|
| [`SPEC.md`](SPEC.md) | the rulers, the role→rendering tables, and what is still open |
| [`AUDIT.md`](AUDIT.md) | what the three CLIs actually did on 2026-07-26, with evidence |
| [`lint.sh`](lint.sh) | the mechanical half — enforces only what's decided |

## Not a dependency

sheersweep sells *"one file you can read end to end"* and zero dependencies;
sheerstatus sells *"single-file / zero deps"*. **Nothing here ships inside a
tool.** The lint reads them from the outside, in CI. That constraint is the
whole design: drift is caught at build time or not at all.

## Using the lint

```sh
signet-cli-lint sheersweep                          # a single-file tool
signet-cli-lint bin/clikae $(find lib -name '*.sh') # or every file of a multi-file one
signet-cli-lint --self-test                         # prove the checks can still fire
```

Point it at everything a tool is made of, harnesses included — help text,
prompts and test output are all screens someone reads.

The **seal** is narrower: it names a product, so it is asked only of a file with
a shebang *and no extension*. A tool you type has none (`sheersweep`,
`bin/clikae`); a sourced library or a script something else runs keeps its `.sh`.
That is a property of the file rather than a list to maintain — the first
attempt was a list (`tests/`, `scripts/`) and it needed its first amendment
within the hour, on a repo whose harness sits in the root as `./test.sh`.

Exit `0` clean, `1` violations, `2` usage, `3` the lint itself is broken.

In CI, alongside `shellcheck`:

```yaml
- name: Signet (CLI)
  run: |
    curl -fsSL https://raw.githubusercontent.com/CVERInc/signet/main/packages/cli/lint.sh -o /tmp/signet-cli-lint
    bash /tmp/signet-cli-lint <your-entry-point>
```

### It checks itself first

A lint whose pattern silently stops matching is indistinguishable from a clean
repository. So before reporting anything, it runs every check against a fixture
that **must** trip it and a fixture that must **not** — and refuses to report a
clean run if any check has gone quiet.

That is not paranoia. On its first run, two of four checks were dead:
`[:ascii:]` is not a valid character class on BSD grep, so the translated-badge
check had been exiting *"invalid character class"* into a silenced stderr and
reading as "no matches found"; and the seal check had been handed a fixture that
already carried the seal, so it never had anything to catch.

### Exemptions

A line is skipped when it is a **comment** (never printed, so it can't violate a
rule about printed output — and any file documenting these rules has to quote
the wrong forms), or when it carries `# signet-lint: fixture` (test data that is
deliberately non-conforming).

## Status

Decided and in `SPEC.md`: the six state badges, sizes, streams, group headers
(`▸`), the one bullet (`·`), retired rules, the selection mark (`[x]`), the
result line, and colour — which **amplifies but never carries**, the test being
that you can pipe the output to a file and lose no meaning.

Six of those are mechanically enforced. The rest are judgement, and the lint
deliberately stays out: one that guesses is worse than one that waits.

Still open (see the end of `AUDIT.md`): clikae's `[OK] [INFO] [WARN] [ERR]` log
prefixes — 585 call sites of a role the spec doesn't cover — and four smaller
things that are recorded rather than guessed at.
