# @cver/signet

The **web** side of the [Signet](../../README.md) design seal — CVER's shared
web design elements, so every CVER website renders as the same family the way
the native apps do. Framework-agnostic CSS with thin Astro and Svelte wrappers.

> Same seal, two surfaces: the repo root is the SwiftUI package (`import Signet`)
> for CVER's native macOS apps; this `packages/web` package is the npm side for
> CVER's websites (cver.net, feelreef, …).

## Install

```bash
npm install @cver/signet
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
import '@cver/signet/arrow.css';
```

**Astro** (cver.net):

```astro
---
import Arrow from '@cver/signet/Arrow.astro';
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
  import Arrow from '@cver/signet/Arrow.svelte';
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
