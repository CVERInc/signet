# Signet · Voice

The localization ruler. Not a fourth renderer — [`cli`](../cli),
[`native`](../native) and [`web`](../web) each turn roles into a surface;
this one reads the **words** that land on all three.

| file | what it is |
|---|---|
| [`voicelint.py`](voicelint.py) | the mechanical half — the fingerprints of translated-not-transcreated copy |

## What it can and cannot see

It cannot tell you a sentence is bad. It catches the specific residue that
shows up when copy was *translated* instead of *transcreated*, per locale:

| locale | what it looks for |
|---|---|
| zh-TW | mainland tech vocabulary, `——` sprayed where `：` belongs, `您`, simplified characters, `在線` (which a Chinese reader parses as *online* first) |
| ja-JP | scattered `あなた`, halfwidth katakana, Chinese words that leaked into Japanese copy |
| ko-KR | literal `당신`, the periphrastic `~는 것입니다` |

Everything else is judgement, and it stays out. A lint that guesses is worse
than one that waits.

The word lists are a **backstop, not the method**. The method is a positive
anchor — vocabulary from the current macOS UI strings, register of a composed
Taiwanese adult — which works while the sentence is being written. A blacklist
only ever works afterwards, and only on words someone already thought of.

## Using it

```sh
voicelint.py ir/zh-tw/oss/sheersweep.md      # locale inferred from the path
voicelint.py --locale ko-KR some-string.md   # when the path can't say
voicelint.py --self-test                     # prove every rule can still fire
```

Exit `0` clean · `1` violations · `2` usage · `3` the lint itself is broken.

Point it at built output rather than drafts when you can. A page you *wrote*
correctly and a page that *renders* correctly are different claims, and only
the second one is the product.

## It checks itself first

Eight fixtures: five that must trip specific rules, three clean pages that must
stay silent. `--self-test` fails if a rule goes quiet **or** starts firing on
copy that is fine.

Both halves earned their place on the first run:

- The fullwidth-punctuation rule was applied to Korean and returned ~80 hits a
  page. Korean uses halfwidth `,` and `.` natively; the canon says *中日文*.
  A suspiciously round number across two files is the fingerprint of a broken
  ruler, not a broken page.
- The `것입니다` check matched `당신의 것입니다` — where `것` is a real pronoun,
  not the periphrastic construction. A bare substring match invented that one.

Neither was visible from the output alone. Both looked exactly like findings.

## What it found on its first real pass

Eight landing pages and three index pages, already reviewed by hand:

- a Chinese word (`工具`) sitting in the Japanese copy
- `優化` in the one sentence mocking system optimizers
- four entries left in **English** on all three CJK index pages — twelve
  descriptions, on pages whose whole job is to be read in another language

The last one is the point. It was not a subtle register problem; it was English
text on a Chinese page, and it survived a careful human read.
