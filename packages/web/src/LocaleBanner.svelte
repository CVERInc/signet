<script>
  /* @cvernet/signet — locale-suggestion banner (Svelte).
   *
   * Renders the banner markup + its config; the behaviour is loaded and run on
   * mount (client-only, SSR-safe). Import the stylesheet once in your app:
   *   import '@cvernet/signet/locale-banner.css';
   *
   * Usage (SvelteKit):
   *   <LocaleBanner
   *     current={locale}
   *     defaultLocale="en-us"
   *     class="bleedblend-top bleedblend-push"
   *     excludePath="/language"
   *     options={localesOnThisPage.map((l) => ({
   *       id: l, match: PREFIXES[l],
   *       prompt: t(l, 'LOCALE_BANNER_PROMPT'),
   *       continue: t(l, 'LOCALE_BANNER_CONTINUE'),
   *       dismiss: t(l, 'LOCALE_BANNER_DISMISS'),
   *     }))}
   *   />
   *
   * To re-show after a client-side navigation, call the exported `init()` from
   * `afterNavigate` (it's a no-op when dismissed / not applicable).
   */
  import { onMount } from 'svelte';

  export let current;
  export let defaultLocale = undefined; // required for hrefStrategy 'prefix'
  export let options;
  export let hrefStrategy = undefined; // 'prefix' (default) | 'query'
  export let queryParam = undefined; // for 'query' strategy
  export let ariaLabel = 'Language';
  export let storageKey = undefined;
  export let excludePath = undefined;
  export let id = 'signet-locale-banner';
  let extraClass = '';
  export { extraClass as class };

  $: config = JSON.stringify({ current, defaultLocale, options, hrefStrategy, queryParam, storageKey, excludePath });

  onMount(async () => {
    const mod = await import('@cvernet/signet/locale-banner.js');
    mod.init();
  });
</script>

<div
  {id}
  class="locale-banner {extraClass}"
  hidden
  role="region"
  aria-label={ariaLabel}
  data-signet-locale-banner
  data-config={config}
>
  <div class="locale-banner__inner">
    <span class="locale-banner__msg" data-banner-message></span>
    <span class="locale-banner__actions">
      <button type="button" class="locale-banner__decline" data-banner-dismiss></button>
      <a href="#" class="locale-banner__continue" data-banner-continue></a>
    </span>
  </div>
</div>
