/**
 * (Re)wire every `[data-signet-locale-banner]` element on the page. Called
 * automatically on load and on Astro view transitions; export `init()` so a
 * SvelteKit/SPA app can re-run it after client-side navigation. SSR-safe:
 * a no-op when there is no `document`.
 */
export function init(): void;
