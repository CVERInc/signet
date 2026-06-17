# @cvernet/signet

The **web** side of the [Signet](../../README.md) design seal — CVER's shared
web design elements, so every CVER website renders as the same family the way
the native apps do. Framework-agnostic CSS with thin Astro and Svelte wrappers.

> Same seal, two surfaces: the repo root is the SwiftUI package (`import Signet`)
> for CVER's native macOS apps; this `packages/web` package is the npm side for
> CVER's websites (cver.net, feelreef, …).

## Install

```bash
npm install @cvernet/signet
```

## Arrow

A directional link arrow with a tail-retract hover morph. At **rest** it's a
full arrow; on **hover** of the nearest `.group` ancestor (or the enclosing
`<a>`) the tail retracts into the chevron (`→` collapses to `>`). One animation;
`direction` rotates it, so the same motion reads correctly everywhere:

| `direction` | rotation | use for |
|---|---|---|
| `right` (default) | 0° | link / next |
| `left` | 180° | back / previous |
| `up-right` | -45° | external / outbound |

The geometry is the canonical CVER arrow (chevron `10 6 16 12 10 18`, stroke 2),
and the tail weight tracks the chevron stroke (`size / 12`) so the whole arrow
thickens and thins as one unit at any size. Pure CSS + SVG, `currentColor`
throughout, no JS, SSR-friendly.

Import the stylesheet **once** in your app, then use the component for your
framework:

```ts
import '@cvernet/signet/arrow.css';
```

**Astro** (cver.net):

```astro
---
import Arrow from '@cvernet/signet/Arrow.astro';
---
<a class="group">Read more <Arrow /></a>
<a class="group">Back <Arrow direction="left" /></a>
<a href="https://github.com/CVERInc" class="group" rel="noopener">
  GitHub <Arrow direction="up-right" />
</a>
```

**Svelte** (feelreef):

```svelte
<script>
  import Arrow from '@cvernet/signet/Arrow.svelte';
</script>
<a class="group">Read more <Arrow /></a>
<a class="group">Back <Arrow direction="left" /></a>
<a href="https://github.com/CVERInc" class="group" rel="noopener">
  GitHub <Arrow direction="up-right" />
</a>
```

Props: `direction` (`'right' | 'left' | 'up-right'`, default `'right'`),
`size` (px, default `16`), `class` (extra classes).

The hover morph fires from any ancestor carrying the Tailwind-style `group`
class (cards, tertiary buttons) **or** the enclosing anchor — so plain links and
primary/secondary buttons animate too, no `group` needed. `prefers-reduced-motion`
disables the transition.

## Locale banner

A top strip that offers a visitor their own language when it differs from the
page's — detect on `navigator.languages`, suggest, remember the dismissal. CSS +
a tiny vanilla controller + Astro/Svelte wrappers. The cver.net-specific bits
are parameterised, so any CVER site can use it.

```ts
import '@cvernet/signet/locale-banner.css';
```

```astro
---
import LocaleBanner from '@cvernet/signet/LocaleBanner.astro';
const PREFIXES = { 'en-us': ['en'], 'ja-jp': ['ja'], 'ko-kr': ['ko'], 'zh-tw': ['zh'] };
---
<LocaleBanner
  current={locale}
  defaultLocale="en-us"
  excludePath="/language"
  class="bleedblend-top bleedblend-push"
  options={localesOnThisPage.map((l) => ({
    id: l,
    match: PREFIXES[l],
    prompt: dict(l).LOCALE_BANNER_PROMPT,
    continue: dict(l).LOCALE_BANNER_CONTINUE,
    dismiss: dict(l).LOCALE_BANNER_DISMISS,
  }))}
/>
```

Svelte is the same, from `@cvernet/signet/LocaleBanner.svelte`.

Props: `current` (page locale id), `defaultLocale` (the locale at the bare path,
no prefix), `options` (one per locale that has *this* page — `{ id, match: string[],
prompt, continue, dismiss? }`, each addressed in the language it suggests),
`excludePath?` (regex string, e.g. the language picker page), `storageKey?`,
`ariaLabel?`, `class?` (e.g. bleedblend's `bleedblend-top bleedblend-push` so it
tints the chrome and pushes content), `id?`.

The href to switch is built client-side (strip the current locale prefix off the
URL, add the suggested one) so it stays correct across view transitions. SSR-safe;
add `.bleedblend-push` if you want it to push content instead of overlaying it.
