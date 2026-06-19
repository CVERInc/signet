// @cvernet/signet — View Transitions trigger for SvelteKit.
//
// Wires the browser View Transitions API into SvelteKit's client-side
// navigation so every route change morphs via the ::view-transition
// pseudo-elements styled by `@cvernet/signet/transitions.css` — the same
// seamless feel as Astro's <ClientRouter />, so a CVER SvelteKit app and a
// CVER Astro app transition identically.
//
// Usage (in your root +layout.svelte <script>):
//   import { onNavigate } from '$app/navigation';
//   import { viewTransition } from '@cvernet/signet/view-transitions';
//   import '@cvernet/signet/transitions.css';
//   onNavigate(viewTransition);
//
// Progressive enhancement: browsers without document.startViewTransition (e.g.
// older Firefox) simply navigate instantly — no breakage, no error.

/**
 * SvelteKit `onNavigate` handler that wraps the navigation in a View Transition.
 * @param {{ complete: Promise<unknown> }} navigation - the argument SvelteKit
 *   passes to the onNavigate callback.
 * @returns {Promise<void> | undefined} a promise SvelteKit awaits while the
 *   transition snapshot is taken, or undefined when the API is unavailable.
 */
export function viewTransition(navigation) {
	if (typeof document === 'undefined' || !document.startViewTransition) return;
	return new Promise((resolve) => {
		document.startViewTransition(async () => {
			resolve();
			await navigation.complete;
		});
	});
}
