import type { Component } from 'svelte';

/**
 * Locale-suggestion banner (Svelte). Renders the markup + JSON config consumed
 * by `locale-banner.js`. Import `locale-banner.css` once and `locale-banner.js`
 * for behaviour (or call its `init()` after SPA navigation).
 */
declare const LocaleBanner: Component<{
	/** The page's locale id, e.g. 'zh-tw'. */
	current: string;
	/** Locale options to offer (banner-specific config shape). */
	options: unknown;
	/** (prefix strategy) the locale at the bare path, e.g. 'en-us'. */
	defaultLocale?: string;
	/** URL strategy. @default 'prefix' */
	hrefStrategy?: 'prefix' | 'query';
	/** (query strategy) the locale query param name. */
	queryParam?: string;
	/** Accessible label for the banner. @default 'Language' */
	ariaLabel?: string;
	/** localStorage key for the dismiss state. */
	storageKey?: string;
	/** Regex string; banner stays hidden on matching paths. */
	excludePath?: string;
	/** Element id. @default 'signet-locale-banner' */
	id?: string;
	/** Extra class(es). */
	class?: string;
}>;

export default LocaleBanner;
