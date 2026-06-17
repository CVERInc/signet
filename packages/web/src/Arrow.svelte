<script>
  /* @cver/signet — directional arrow (Svelte).
   *
   * Same element as the Astro version. Rest is a full arrow; on hover of the
   * nearest `.group` ancestor (or the enclosing anchor) the tail retracts into
   * the chevron. Rotate per direction. Pure CSS + SVG, currentColor, no JS.
   *
   * Import the stylesheet once in your app, then use the component:
   *   import '@cver/signet/arrow.css';
   *   import Arrow from '@cver/signet/Arrow.svelte';
   *   <a class="group">Read more <Arrow /></a>
   *   <a class="group">Back <Arrow direction="left" /></a>
   *   <a href="https://…" class="group">GitHub <Arrow direction="up-right" /></a>
   */
  export let direction = 'right';
  export let size = 16;
  let extraClass = '';
  export { extraClass as class };

  $: dirClass =
    direction === 'left'
      ? 'signet-arrow--left'
      : direction === 'up-right'
        ? 'signet-arrow--up-right'
        : '';
</script>

<span
  class="signet-arrow {dirClass} {extraClass}"
  style="width:{size}px;height:{size}px;--signet-arrow-w:{size}px"
  aria-hidden="true"
>
  <span class="signet-arrow__tail"></span>
  <svg
    class="signet-arrow__head"
    width={size}
    height={size}
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
  >
    <polyline points="10 6 16 12 10 18" />
  </svg>
</span>
