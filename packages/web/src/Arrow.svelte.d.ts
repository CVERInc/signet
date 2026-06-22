import type { Component } from 'svelte';

/**
 * Directional arrow (Svelte). A full arrow at rest; on hover of the nearest
 * `.group` ancestor the tail retracts into the chevron. Import `arrow.css` once.
 */
declare const Arrow: Component<{
	/** Arrow direction. @default 'right' */
	direction?: 'right' | 'left' | 'up-right';
	/** Pixel size of the square arrow box. @default 16 */
	size?: number;
	/** Extra class(es) merged onto the arrow span. */
	class?: string;
}>;

export default Arrow;
