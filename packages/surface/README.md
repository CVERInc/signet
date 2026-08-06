# Signet · Surface

The publication ruler. Not a fourth renderer — [`cli`](../cli), [`native`](../native) and
[`web`](../web) each turn roles into a surface, and [`voice`](../voice) reads the words that land
on them. This one reads what a repository **says about the machine that built it**.

| file | what it is |
|---|---|
| [`leaklint.sh`](leaklint.sh) | the mechanical half — home-directory paths that reached a public tree |

## What it can and cannot see

It cannot tell you a repository is safe to publish. It catches one specific residue, the one that
actually keeps happening: an absolute path under someone's real home directory, committed into a
tracked file and then forgotten. Usually it is in a test harness, a comment, or a tool nobody runs
any more — the places nobody re-reads before going public.

```bash
bash packages/surface/leaklint.sh              # scan this repo's tracked files
bash packages/surface/leaklint.sh --self-test  # prove the rules still fire
bash packages/surface/leaklint.sh --deny list  # also match a local, private name list
```

**A home path is not the defect; a real person's home path is.** `/Users/you`, `/Users/someone`
and `/Users/x` are how you write an example, and a gate that flagged them would fire forever with
nothing to fix — which is how a gate gets ignored, taking the real findings down with it. So the
rule is "a user segment that is not a recognised placeholder", and the placeholder list is meant
to grow. An unrecognised name is reported: it fails toward noticing.

## What it deliberately does not do

- **It does not know your private repository names.** That list cannot live in a public file
  without being the leak it prevents. Pass one with `--deny`; CI will not have it, so treat that
  half as advice rather than enforcement. `cvertex`'s `tools/leakguard.sh` is the same idea with
  the list kept private and the scan pointed at a submodule about to graduate.
- **It reads tracked files only.** Untracked scratch is not published, and a gate that shouts
  about your local mess is one you learn to ignore.
- **It reads files and runs nothing.** It is never a runtime dependency of anything it inspects.

## In CI, for any public repo in the family

```yaml
- name: Surface — nothing about the machine that built it
  run: |
    curl -fsSL https://raw.githubusercontent.com/CVERInc/signet/main/packages/surface/leaklint.sh -o /tmp/leaklint
    bash /tmp/leaklint --self-test
    bash /tmp/leaklint
```

Run `--self-test` first, always. A green scan means nothing until you have seen the gate go red on
a planted specimen; the first version of this file reported four real findings and still exited
`0`, because the counter lived in a pipeline's subshell. `--self-test` now runs the whole gate
against planted repositories and asserts its exit code, not its regex.

CI is also the only place this cannot be shadowed: a repo-local `core.hooksPath` silently replaces
the global one, so a machine-wide git hook would miss exactly the repos that set it.
