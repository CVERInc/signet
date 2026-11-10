// Proof for corners.css's round-shape opt-out. Like locale-banner-equivalence.mjs it needs a browser,
// so it is not in scripts/test.sh: run it by hand after touching corners.css.
//
//   npm i --no-save playwright && npx playwright install chromium   (once)
//   node packages/web/test/corners-shapes.mjs
//   (or: PLAYWRIGHT_MODULE=<path to playwright/index.mjs> node packages/web/test/corners-shapes.mjs)
//
// It renders a set of specimens under corners.css in Chromium (the only engine with corner-shape) and
// reads the computed corner-shape of each. ROUND must come out `round`; SQUIRCLE must stay `squircle`.
// The same specimens are then run against the corners.css at HEAD~ as a control: the ruler has to
// find circles wearing a squircle there, or a green run here proves nothing.
import { readFileSync } from 'node:fs';
import { execSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

// PLAYWRIGHT_MODULE: an absolute path to an existing playwright install, if you would rather not add one here.
const { chromium } = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
const here = fileURLToPath(new URL('../src/corners.css', import.meta.url));
const NOW = readFileSync(here, 'utf8');
const ref = process.env.CORNERS_CONTROL_REF || 'HEAD';
const BEFORE = execSync(`git show ${ref}:packages/web/src/corners.css`, { cwd: fileURLToPath(new URL('../../../', import.meta.url)) }).toString();

// [label, html]. Every specimen carries a radius; what differs is how an author names it.
const ROUND = [
  ['class-set 50% named fab (feelreef ⌘K)', '<button class="cp-fab" style="width:52px;height:52px"></button>'],
  ['pill class', '<span class="pill">x</span>'],
  ['scoped pill class', '<span class="mod-pill svelte-abc">x</span>'],
  ['status dot', '<i class="status-dot"></i>'],
  ['bare dot', '<i class="dot"></i>'],
  ['avatar', '<img class="avatar-sm" alt="">'],
  ['circle button', '<button class="circle-btn"></button>'],
  ['inline 50%', '<div style="border-radius:50%"></div>'],
  ['inline 100%', '<div style="border-radius: 100%"></div>'],
  ['inline 999px', '<div style="border-radius:999px"></div>'],
  ['inline 9999px', '<div style="border-radius: 9999px"></div>'],
  ['Tailwind rounded-full', '<div class="rounded-full"></div>'],
  ['radio', '<input type="radio">'],
];
const SQUIRCLE = [
  ['card', '<div class="card" style="border-radius:12px"></div>'],
  ['Tailwind rounded-lg', '<div class="rounded-lg"></div>'],
  ['class containing "round" (background)', '<div class="background-panel"></div>'],
  ['button with a finite radius', '<button class="btn-primary" style="border-radius:10px"></button>'],
  ['word "dotted" is not a dot', '<div class="dotted"></div>'],
  ['checkbox', '<input type="checkbox">'],
];

const b = await chromium.launch();
const p = await b.newPage();
async function measure(css) {
  const body = [...ROUND, ...SQUIRCLE].map(([, h], i) => h.replace(/^<(\w+)/, `<$1 data-i="${i}"`)).join('\n');
  await p.setContent(`<!doctype html><style>${css}\n.rounded-lg{border-radius:8px}.rounded-full{border-radius:9999px}div,span,i,img,button{display:inline-block;width:40px;height:40px;border-radius:8px}</style>${body}`);
  const supported = await p.evaluate(() => 'cornerShape' in document.body.style || CSS.supports('corner-shape', 'squircle'));
  if (!supported) throw new Error('this Chromium has no corner-shape: the probe would pass for the wrong reason');
  return p.evaluate(() => [...document.querySelectorAll('[data-i]')].map((e) => getComputedStyle(e).getPropertyValue('corner-shape').trim()));
}
const judge = (got) => {
  const bad = [];
  ROUND.forEach(([l], i) => { if (!/round/.test(got[i])) bad.push(`ROUND    ${l}: ${got[i]}`); });
  SQUIRCLE.forEach(([l], i) => { const v = got[ROUND.length + i]; if (!/squircle/.test(v)) bad.push(`SQUIRCLE ${l}: ${v}`); });
  return bad;
};
const now = judge(await measure(NOW));
const before = judge(await measure(BEFORE));
await b.close();
console.log(`control (${ref}): ${before.length} wrong`); before.forEach((x) => console.log('   ', x));
console.log(`now: ${now.length} wrong`); now.forEach((x) => console.log('   ', x));
if (before.length === 0) { console.log('✗ the control found nothing wrong: this ruler cannot see the bug'); process.exit(2); }
if (now.length) { console.log('✗'); process.exit(1); }
console.log(`✓ ${ROUND.length} round, ${SQUIRCLE.length} squircle, and the control was red`);
