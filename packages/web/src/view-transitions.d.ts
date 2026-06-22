/**
 * SvelteKit `onNavigate` handler that wraps the navigation in a View Transition
 * (styled by `@cvernet/signet/transitions.css`). Progressive enhancement:
 * returns `undefined` (instant navigation) when the View Transitions API is
 * unavailable.
 *
 * @example
 *   import { onNavigate } from '$app/navigation';
 *   import { viewTransition } from '@cvernet/signet/view-transitions';
 *   onNavigate(viewTransition);
 */
export function viewTransition(
	navigation: { complete: Promise<unknown> }
): Promise<void> | undefined;
