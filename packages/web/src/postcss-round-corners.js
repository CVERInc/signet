// @cvernet/signet — keep circles and pills round, at build time.
//
// corners.css gives every element `corner-shape: squircle`. On a full radius (a 50% avatar, a
// 999px pill) that draws a rounded square, and CSS has no selector for "this radius is at least
// half the box", so corners.css can only guess from class names. The stylesheet's SOURCE does say
// it, though: the author wrote `border-radius: 50%`. This PostCSS plugin reads that and adds
// `corner-shape: round` to the same rule, so every circle and pill in the build is covered,
// including the one somebody adds next month, with no list to maintain.
//
//   // vite.config.js
//   import roundCorners from '@cvernet/signet/postcss-round-corners';
//   export default { css: { postcss: { plugins: [roundCorners()] } } };
//
//   // postcss.config.js
//   export default { plugins: { '@cvernet/signet/postcss-round-corners': {} } };
//
// What it does not see: a pill written as a finite length (`border-radius: 22px` on a 44px
// button) and radii set in inline `style=""` or from script. corners.css's opt-out and a
// hand-written `corner-shape: round` still cover those.
//
// Options:
//   vars  custom properties that hold a full radius, e.g. ['--radius-pill', '--radius-circle'];
//         `border-radius: var(--radius-pill)` is then treated as full.

const FULL_LENGTH = { px: 999, rem: 99, em: 99, vmax: 100, vmin: 100, vw: 100, vh: 100 };

function isFullToken(token, vars) {
  const t = token.trim().toLowerCase();
  if (!t) return false;
  if (/^calc\(\s*infinity\s*\*\s*1px\s*\)$/.test(t) || /^calc\(\s*1px\s*\*\s*infinity\s*\)$/.test(t)) return true;
  const v = /^var\(\s*(--[\w-]+)\s*(?:,[^)]*)?\)$/.exec(t);
  if (v) return vars.has(v[1]);
  const n = /^(-?\d*\.?\d+(?:e[+-]?\d+)?)(%|[a-z]+)$/.exec(t);
  if (!n) return false;
  const value = Number(n[1]);
  if (n[2] === '%') return value >= 50;
  return n[2] in FULL_LENGTH && value >= FULL_LENGTH[n[2]];
}

// Split on spaces and the `/` between horizontal and vertical radii, but not inside parentheses.
function tokens(value) {
  const out = [];
  let depth = 0;
  let cur = '';
  for (const ch of value) {
    if (ch === '(') depth++;
    if (ch === ')') depth--;
    if (depth === 0 && (ch === ' ' || ch === '/' || ch === '\t' || ch === '\n')) {
      if (cur) out.push(cur);
      cur = '';
    } else cur += ch;
  }
  if (cur) out.push(cur);
  return out;
}

/** True when every radius in a `border-radius` value is a full one (circle or pill). */
export function isFullRadius(value, vars = new Set()) {
  const list = tokens(String(value).replace(/!important\s*$/i, '').trim());
  return list.length > 0 && list.every((t) => isFullToken(t, vars));
}

function roundCorners(options = {}) {
  const vars = new Set(options.vars || []);
  return {
    postcssPlugin: 'signet-round-corners',
    Declaration: {
      'border-radius'(decl) {
        if (!isFullRadius(decl.value, vars)) return;
        // The author already chose a corner shape for this rule: leave it alone.
        if (decl.parent.some((n) => n.type === 'decl' && n.prop === 'corner-shape')) return;
        decl.cloneAfter({ prop: 'corner-shape', value: 'round', important: false });
      },
    },
  };
}
roundCorners.postcss = true;

export default roundCorners;
