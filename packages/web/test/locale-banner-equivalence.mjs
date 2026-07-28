// ONE-SHOT MIGRATION PROOF for 0.6.0 — kept as evidence, not wired into
// scripts/test.sh (it needs a browser and a checkout of the sibling tile repo,
// neither of which belongs in this package's mandatory deps).
//
// WHAT IT PROVED. The banner had drifted into two files: this one, and an edited
// copy inside sitetile (tile/packages/sitetile/astro/src/packages/lingo/) that
// had gained host-theme (--gd-*) colours, a contrast fix and a banner-height
// var, and never came home. 0.6.0 merges that copy back. This harness is how the
// merge was shown to be behaviour-preserving for BOTH hosts rather than asserted:
//
//   standalone / light   ✅   standalone / dark   ✅   (== signet before the merge)
//   themed(mbpa) / light ✅   themed(mbpa) / dark ✅   (== the sitetile copy)
//   control: the two pre-merge files vs each other → 2 diffs (the ruler moves)
//
// Run it against a later HEAD by changing OLD_SIGNET's ref. Compares computed
// styles, never screenshots.
//
//   node packages/web/test/locale-banner-equivalence.mjs
import pw from '/Users/chodaict/Developer/ejecta/tools/fidelity/node_modules/playwright/index.js';
const { chromium } = pw;
import { readFileSync } from 'node:fs';
import { execSync } from 'node:child_process';

const NEW = readFileSync('/Users/chodaict/Developer/signet/packages/web/src/locale-banner.css', 'utf8');
const OLD_SIGNET = execSync('git -C /Users/chodaict/Developer/signet show HEAD:packages/web/src/locale-banner.css', { encoding: 'utf8' });
const OLD_TILE = readFileSync('/Users/chodaict/Developer/tile/packages/sitetile/astro/src/packages/lingo/locale-banner.css', 'utf8');

// mbpa's real token values (pajicomic), light scheme.
const THEMED = `--gd-bg:#fdfcff;--gd-surface:#ffffff;--gd-text:#34303c;--gd-muted:#70697d;
  --gd-accent:#b98fe0;--gd-accent-ink:#ffffff;--gd-border:#ece6f4;--gd-soft:#f6f1fc;
  --gd-accent-deep:#875fb6;--gd-accent-hover:#9656d0;--gd-pill:0px;`;
// feelreef pins these onto the banner itself.
const STANDALONE = `--color-primary:#aceace;--color-primary-deeper:#084a4c;`;

const page_html = (css, vars) => `<style>${css}</style>
<div class="locale-banner" style="${vars}">
  <div class="locale-banner__inner">
    <p class="locale-banner__msg">msg</p>
    <div class="locale-banner__actions">
      <button class="locale-banner__decline">no thanks</button>
      <a class="locale-banner__continue" href="#">continue</a>
    </div>
  </div>
</div>`;

const PROPS = {
  '.locale-banner': ['background-color', 'color', 'border-bottom-color', 'font-size'],
  '.locale-banner__decline': ['color'],
  '.locale-banner__continue': ['background-color', 'color', 'border-radius'],
};

async function measure(browser, css, vars, scheme) {
  const ctx = await browser.newContext({ colorScheme: scheme });
  const page = await ctx.newPage();
  await page.setContent(page_html(css, vars));
  const out = {};
  for (const [sel, props] of Object.entries(PROPS)) {
    out[sel] = await page.$eval(sel, (el, props) => {
      const cs = getComputedStyle(el);
      return Object.fromEntries(props.map((p) => [p, cs.getPropertyValue(p)]));
    }, props);
  }
  await ctx.close();
  return out;
}

// color-mix() serializes as `color(srgb r g b / a)` with 0..1 floats, plain
// colours as `rgb(r, g, b)` with 0..255 — the SAME colour in two notations.
// Compare the rendered colour numerically (±1/255), not the string, or every
// color-mix reads as a regression.
const asRgba = (v) => {
  let m = v.match(/^color\(srgb\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)(?:\s*\/\s*([\d.]+))?\s*\)$/);
  if (m) return [+m[1] * 255, +m[2] * 255, +m[3] * 255, m[4] === undefined ? 1 : +m[4]];
  m = v.match(/^rgba?\(([\d.]+),\s*([\d.]+),\s*([\d.]+)(?:,\s*([\d.]+))?\)$/);
  if (m) return [+m[1], +m[2], +m[3], m[4] === undefined ? 1 : +m[4]];
  return null;
};
const same = (x, y) => {
  if (x === y) return true;
  const a = asRgba(x), b = asRgba(y);
  if (!a || !b) return false;
  return a.every((n, i) => Math.abs(n - b[i]) <= (i === 3 ? 0.004 : 1));
};
const cmp = (a, b) => {
  const diffs = [];
  for (const sel of Object.keys(PROPS))
    for (const p of PROPS[sel])
      if (!same(a[sel][p], b[sel][p])) diffs.push(`${sel} { ${p}: ${a[sel][p]}  →  ${b[sel][p]} }`);
  return diffs;
};

const browser = await chromium.launch();
let fail = 0;
for (const scheme of ['light', 'dark']) {
  const oldS = await measure(browser, OLD_SIGNET, STANDALONE, scheme);
  const newS = await measure(browser, NEW, STANDALONE, scheme);
  const d = cmp(oldS, newS);
  console.log(`standalone / ${scheme}: ${d.length === 0 ? '✅ 完全相同' : '⚠️ ' + d.length + ' 處不同'}`);
  d.forEach((x) => console.log('    ' + x));
  fail += d.length;
}
for (const scheme of ['light', 'dark']) {
  const oldT = await measure(browser, OLD_TILE, THEMED, scheme);
  const newT = await measure(browser, NEW, THEMED, scheme);
  const d = cmp(oldT, newT);
  console.log(`themed(mbpa) / ${scheme}: ${d.length === 0 ? '✅ 完全相同' : '⚠️ ' + d.length + ' 處不同'}`);
  d.forEach((x) => console.log('    ' + x));
  fail += d.length;
}
// CONTROL: the harness must be able to SEE a difference — compare the two old
// files against each other. If this prints 0 the comparison proves nothing.
const ctl = cmp(await measure(browser, OLD_SIGNET, STANDALONE, 'light'), await measure(browser, OLD_TILE, STANDALONE, 'light'));
console.log(`\n對照組（舊 signet vs 舊 tile，同一宿主）: ${ctl.length} 處不同 ${ctl.length ? '✅ 尺會動' : '🔴 尺是死的，上面全部不算數'}`);
await browser.close();
process.exit(fail === 0 && ctl.length > 0 ? 0 : 1);
