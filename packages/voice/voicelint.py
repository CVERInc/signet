#!/usr/bin/env python3
"""voicelint — the localization ruler for CVER copy.

The fourth axis of the design system. `cli`, `native` and `web` render roles;
this one reads the *words*, on whichever surface they land — a landing page, a
README, or a CLI's own string table.

It encodes two rulers that already existed as prose:

  · the Apple-Taiwan voice anchor  — vocabulary = current macOS UI strings,
    register = a composed Taiwanese adult. Mainland tech jargon has no home
    once the consumer layer speaks Apple's Chinese and the dev layer speaks
    English outright, so the words below are a backstop, not the method.
  · the CVER localization canon    — Apple's own per-locale sites as the bar,
    transcreation over translation, en-US is the source.

It is deliberately narrow. It cannot see a bad sentence; it sees the specific
fingerprints that show up when someone (me, usually) translated instead of
transcreated. Everything it does not check is still a judgement call.

    voicelint.py <file.md> [...]        lint
    voicelint.py --self-test            prove every rule can still fire
    voicelint.py --locale ko-KR <file>  when the path can't say

Locale is inferred from the path (`ir/zh-tw/…` → zh-TW); `--locale` overrides.

Exit 0 clean · 1 violations · 2 usage · 3 the lint itself is broken.
"""
import re
import sys

# ── the words ────────────────────────────────────────────────────────────────
# Mainland tech vocabulary. The fix column names the macOS string, because
# "don't say X" without "say Y" just makes the next writer guess again.
MAINLAND = {
    "優化": "最佳化（macOS：最佳化儲存空間／最佳化電池充電）",
    "优化": "最佳化",
    "視頻": "影片",
    "質量": "品質（質量是物理學的 mass）",
    "质量": "品質",
    "信息": "資訊／訊息",
    "默認": "預設",
    "用戶": "使用者",
    "屏幕": "螢幕",
    "內存": "記憶體",
    "硬盤": "硬碟",
    "軟件": "軟體",
    "激活": "啟用",
    "緩存": "快取",
}

# A whole generation's consulting-deck vocabulary. One positive anchor kills the
# lot, so this list exists only to catch the ones that slip past it.
BUZZ = ["賦能", "抓手", "顆粒度", "閉環", "拉通", "打法"]

# Simplified forms that are easy to type by accident inside otherwise correct
# Traditional copy. To this maintainer these are not typos.
SIMPLIFIED = "执两达设线过时门问间关无爱国东车马鸟长风飞"

CJK = r"[一-鿿぀-ヿ가-힯]"


def locale_of(path):
    for tag, loc in (("/zh-tw/", "zh-TW"), ("/ja-jp/", "ja-JP"), ("/ko-kr/", "ko-KR")):
        if tag in path:
            return loc
    return "en-US"


def check(text, loc):
    """Return [(rule, count, why, detail)] — never raises on odd input."""
    body = re.sub(r"^---\n.*?\n---\n", "", text, flags=re.S)   # frontmatter isn't copy
    hits = []

    def flag(rule, n, why, detail=""):
        if n:
            hits.append((rule, n, why, detail))

    for word, fix in MAINLAND.items():
        flag("黑話", body.count(word), f"「{word}」→ {fix}")
    for word in BUZZ:
        flag("潮話", body.count(word), f"「{word}」：不自創詞、不堆潮語")

    if loc == "zh-TW":
        flag("破折號", body.count("——"),
             "對外文案破折號少撒：多數改用「：」或重組句子，只在真正的插入語才留")
        flag("敬語", body.count("您"), "一律「你」不用「您」，照 Apple 台灣；法律頁才例外")
        bad = sorted({c for c in body if c in SIMPLIFIED})
        flag("簡體字", len(bad), "正體字＝認同，不是風格", "".join(bad))
        flag("在線", len(re.findall(r"在線的", body)),
             "「在線」在中文先讀成 online；界線的兩邊要寫「界線」")

    if loc == "ja-JP":
        flag("あなた", body.count("あなた"),
             "日本語は主語を落とすのが自然：撒けば撒くほど翻訳調になる")
        half = sorted({c for c in body if "ｦ" <= c <= "ﾟ"})
        flag("半形片假名", len(half), "絕不半形片假名", "".join(half))
        # 「工具」is Chinese; Japanese says ツール／道具. A Chinese word in a Japanese
        # page is the loudest possible sign the copy was translated from zh, not
        # transcreated from en.
        flag("中文詞", len(re.findall(r"(?<![道用])工具(?!箱)", body)),
             "日文頁混進中文詞", "工具→ツール")

    if loc == "ko-KR":
        flag("당신", body.count("당신"),
             "字面「당신」是韓文品質的最大槓桿：自然韓文幾乎不出現，落掉主語即可")
        # Only the periphrastic 「~는 것입니다」. 「당신의 것입니다」's 것 is a real
        # pronoun — a bare substring match invents a false positive there.
        flag("迂迴", len(re.findall(r"[는은ㄹ]\s*것입니다", body)),
             "「~는 것입니다」是翻訳調：直接言い切る")

    # 🔴 Korean is NOT in this list. The canon says 中日文全形、英數半形 — Korean
    # uses halfwidth , and . natively. Applying it there produced 80 hits per
    # page, and a suspiciously round number is the fingerprint of a broken ruler.
    if loc in ("zh-TW", "ja-JP"):
        flag("半形標點", len(re.findall(CJK + r"[,.](?![0-9])", body)),
             "中日文用全形標點，英數半形")

    return hits


# ── self-test ────────────────────────────────────────────────────────────────
# A rule you have never seen fire is a rule you only know is quiet.
FIXTURES = [
    ("zh-TW", "每一個「系統優化工具」都在騙您——說清楚你在線的哪一邊。",
     {"黑話", "破折號", "敬語", "在線"}),
    ("zh-TW", "执行两个设定过时了。", {"簡體字"}),
    ("zh-TW", "賦能團隊,對齊顆粒度。", {"潮話", "半形標點"}),
    ("ja-JP", "あなたのために、あなたの工具が答えます。ｶﾀｶﾅ もあります。",
     {"あなた", "半形片假名", "中文詞"}),
    ("ko-KR", "당신의 기계는 당신이 실행할 때만 동작하는 것입니다.", {"당신", "迂迴"}),
    # must stay silent
    ("zh-TW", "這台還能撐，還是該換了？記憶體、硬碟、電池各給一個裁決。", set()),
    ("ja-JP", "この機械はまだ大丈夫か、それとも買い替え時か。", set()),
    ("ko-KR", "이 기계, 아직 괜찮은가 아니면 바꿀 때인가.", set()),
]


def self_test():
    broken = []
    for i, (loc, text, expect) in enumerate(FIXTURES, 1):
        got = {r for r, _, _, _ in check(text, loc)}
        if got != expect:
            broken.append((i, loc, sorted(expect - got), sorted(got - expect)))
    for i, loc, missed, extra in broken:
        print(f"   [ FAIL ] fixture {i} ({loc})"
              + (f"  silent: {missed}" if missed else "")
              + (f"  spurious: {extra}" if extra else ""))
    if broken:
        print(f"\n[ FAIL ] voicelint self-test — {len(broken)} of {len(FIXTURES)} fixtures")
        return 3
    print(f"[ PASS ] voicelint self-test — {len(FIXTURES)} fixtures, every rule fired")
    return 0


def main(argv):
    if "--self-test" in argv:
        return self_test()
    forced = None
    if "--locale" in argv:
        i = argv.index("--locale")
        try:
            forced = argv[i + 1]
        except IndexError:
            print("--locale needs a value", file=sys.stderr)
            return 2
        del argv[i:i + 2]
    paths = [a for a in argv if not a.startswith("-")]
    if not paths:
        print(__doc__.strip().split("\n\n")[-2], file=sys.stderr)
        return 2

    total = 0
    for p in paths:
        try:
            text = open(p, encoding="utf-8").read()
        except OSError as e:
            print(f"[ FAIL ] {p}: {type(e).__name__}", file=sys.stderr)
            return 2
        loc = forced or locale_of(p)
        hits = check(text, loc)
        name = p.split("/ir/")[-1] if "/ir/" in p else p
        if not hits:
            print(f"[ PASS ] {name}  ({loc})")
            continue
        print(f"[ WARN ] {name}  ({loc})")
        for rule, n, why, detail in hits:
            total += n
            print(f"   · {rule:6s} ×{n:<3d} {why}" + (f"  {detail}" if detail else ""))
    print()
    if total:
        print(f"[ WARN ] {total} to look at")
        return 1
    print("[ PASS ] voicelint")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
