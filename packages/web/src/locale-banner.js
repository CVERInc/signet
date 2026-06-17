/* @cvernet/signet — locale-suggestion banner behaviour.
 *
 * Import once anywhere in your app:
 *   import '@cvernet/signet/locale-banner.js';
 *
 * It auto-wires every `[data-signet-locale-banner]` on load and on Astro view
 * transitions (`astro:page-load`). It also exports `init()` so SvelteKit (or
 * any SPA) can re-run it after client-side navigation. SSR-safe: a no-op when
 * there's no `document`.
 *
 * Each banner reads its config from its own `data-config` attribute (a JSON
 * string). The framework wrappers (LocaleBanner.astro / .svelte) render that
 * markup + config for you. Config shape:
 *   {
 *     current: 'zh-tw',          // the page's locale id
 *     defaultLocale: 'en-us',    // (prefix strategy) the locale at the bare path
 *     hrefStrategy?: 'prefix',   // 'prefix' (URL /<loc>/path, default) | 'query'
 *     queryParam?: 'lang',       // (query strategy) the locale param name
 *     storageKey?: 'signet-locale-banner-dismiss',
 *     excludePath?: '/language', // regex string; banner stays hidden on matches
 *     options: [{ id, match: ['zh'], prompt, continue, dismiss }, ...]
 *   }
 *
 * The visitor is addressed in the language being SUGGESTED, so each option
 * carries its own copy. The href is built client-side: strip the current locale
 * prefix off window.location to get the bare path, then add the suggested
 * locale's prefix (default locale = no prefix) — correct across view
 * transitions, unlike a server-baked path.
 */

function detect(options) {
  var list =
    navigator.languages && navigator.languages.length
      ? navigator.languages
      : [navigator.language || ''];
  for (var i = 0; i < list.length; i++) {
    var tag = String(list[i]).toLowerCase();
    for (var j = 0; j < options.length; j++) {
      var m = options[j].match || [];
      for (var k = 0; k < m.length; k++) {
        if (tag.indexOf(String(m[k]).toLowerCase()) === 0) return options[j].id;
      }
    }
  }
  return null;
}

// Current full path with the current-locale prefix stripped → the bare path.
function barePath(current, defaultLocale) {
  var p = window.location.pathname || '/';
  if (current && current !== defaultLocale && p.indexOf('/' + current) === 0) {
    p = p.slice(('/' + current).length) || '/';
  }
  return p;
}

function hrefFor(loc, defaultLocale, bare) {
  var clean = bare.charAt(0) === '/' ? bare : '/' + bare;
  if (loc === defaultLocale) return clean;
  return clean === '/' ? '/' + loc + '/' : '/' + loc + clean;
}

// The link that switches to the suggested locale, per the host's i18n model:
//   'prefix' (default) — strip the current locale prefix, add the suggested one
//                        (en-us at the bare path; others at /<loc>/path).
//   'query'            — keep the path, set ?<queryParam>=<loc> (for sites that
//                        switch via a query param + cookie, e.g. paraglide).
function switchHref(suggested, current, defaultLocale, hrefStrategy, queryParam) {
  if (hrefStrategy === 'query') {
    var u = new URL(window.location.href);
    u.searchParams.set(queryParam || 'lang', suggested);
    return u.pathname + u.search + u.hash;
  }
  return hrefFor(suggested, defaultLocale, barePath(current, defaultLocale));
}

function wire(banner) {
  var cfg;
  try {
    cfg = JSON.parse(banner.getAttribute('data-config') || '{}');
  } catch (e) {
    banner.hidden = true;
    return;
  }
  var options = cfg.options || [];
  var current = cfg.current;
  var defaultLocale = cfg.defaultLocale || (options[0] && options[0].id);
  var storageKey = cfg.storageKey || 'signet-locale-banner-dismiss';
  var excludePath = cfg.excludePath;
  var hrefStrategy = cfg.hrefStrategy || 'prefix';
  var queryParam = cfg.queryParam || 'lang';

  if (!banner.__signetWired) {
    banner.__signetWired = true;
    banner.addEventListener('click', function (e) {
      var t = e.target;
      if (t && t.closest && t.closest('[data-banner-dismiss]')) {
        try {
          localStorage.setItem(storageKey, '1');
        } catch (e2) {}
        banner.hidden = true;
      }
    });
  }

  var pathNow = window.location.pathname.replace(/\/$/, '') || '/';
  if (excludePath && new RegExp(excludePath).test(pathNow)) {
    banner.hidden = true;
    return;
  }
  try {
    if (localStorage.getItem(storageKey)) {
      banner.hidden = true;
      return;
    }
  } catch (e) {}

  var suggested = detect(options);
  if (!suggested || suggested === current) {
    banner.hidden = true;
    return;
  }
  var pick = null;
  for (var i = 0; i < options.length; i++) {
    if (options[i].id === suggested) {
      pick = options[i];
      break;
    }
  }
  if (!pick) {
    banner.hidden = true;
    return;
  }

  var msg = banner.querySelector('[data-banner-message]');
  var cont = banner.querySelector('[data-banner-continue]');
  var dismiss = banner.querySelector('[data-banner-dismiss]');
  if (!msg || !cont) return;

  msg.textContent = pick.prompt || '';
  cont.textContent = pick.continue || '';
  cont.setAttribute('href', switchHref(suggested, current, defaultLocale, hrefStrategy, queryParam));
  if (dismiss && pick.dismiss) dismiss.textContent = pick.dismiss;

  banner.hidden = false;
}

export function init() {
  if (typeof document === 'undefined') return;
  var banners = document.querySelectorAll('[data-signet-locale-banner]');
  for (var i = 0; i < banners.length; i++) wire(banners[i]);
}

if (typeof document !== 'undefined') {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
  document.addEventListener('astro:page-load', init);
}
