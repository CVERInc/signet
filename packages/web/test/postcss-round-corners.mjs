// The build-time half of the corner rule: full radii get `corner-shape: round`, nothing else is touched.
//   node test/postcss-round-corners.mjs
import assert from 'node:assert/strict';
import postcss from 'postcss';
import roundCorners, { isFullRadius } from '../src/postcss-round-corners.js';

const run = async (css, opts) => (await postcss([roundCorners(opts)]).process(css, { from: undefined })).css;
const has = (css) => /corner-shape:\s*round/.test(css);
let n = 0;
const check = async (name, css, want, opts) => { assert.equal(has(await run(css, opts)), want, name + ' :: ' + css); n++; };

// full radii: a circle or a pill, however it is written
for (const v of ['50%', '100%', '999px', '9999px', '1e3px', '100vmax', '99rem', 'calc(infinity * 1px)', '50% / 50%', '999px 999px', '50%!important', '50% !important'])
  await check('full', `.a{border-radius:${v}}`, true);
// finite radii: these ARE the squircles; leave them alone
for (const v of ['0', '6px', '12px', '1rem', '16px 16px 0 0', '49%', '998px', '50% 8px', 'inherit', 'var(--radius)', 'calc(1rem + 2px)'])
  await check('finite', `.a{border-radius:${v}}`, false);
// other properties are not radii
await check('width', '.a{width:50%}', false);
await check('longhand', '.a{border-top-left-radius:50%}', false);
// a named full-radius token, only when the build says so
await check('var unknown', '.a{border-radius:var(--radius-pill)}', false);
await check('var known', '.a{border-radius:var(--radius-pill)}', true, { vars: ['--radius-pill'] });
await check('var with fallback', '.a{border-radius:var(--radius-pill, 999px)}', true, { vars: ['--radius-pill'] });

// the author's own corner-shape wins, in either order, and nothing is added twice
assert.equal(await run('.a{border-radius:50%;corner-shape:squircle}'), '.a{border-radius:50%;corner-shape:squircle}'); n++;
assert.equal(await run('.a{corner-shape:bevel;border-radius:50%}'), '.a{corner-shape:bevel;border-radius:50%}'); n++;
const once = await run('.a{border-radius:50%}');
assert.equal(await run(once), once, 'running twice adds nothing'); n++;
assert.equal(once, '.a{border-radius:50%;corner-shape:round}'); n++;
// only the rule that has the full radius is touched, inside at-rules too
assert.equal(await run('.a{border-radius:8px}@media (min-width:1px){.b{border-radius:999px}}'), '.a{border-radius:8px}@media (min-width:1px){.b{border-radius:999px;corner-shape:round}}'); n++;
// an !important radius does not make the shape !important (corners.css's own rule has zero specificity)
assert.equal(await run('.a{border-radius:50% !important}'), '.a{border-radius:50% !important;corner-shape:round}'); n++;

assert.equal(isFullRadius('50%'), true); assert.equal(isFullRadius('8px'), false); n += 2;
console.log(`postcss-round-corners: ${n} checks passed`);
