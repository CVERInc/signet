import type { PluginCreator } from 'postcss';

export interface RoundCornersOptions {
  /** Custom properties that hold a full radius, e.g. `['--radius-pill']`. */
  vars?: string[];
}

/** True when every radius in a `border-radius` value is a full one (circle or pill). */
export function isFullRadius(value: string, vars?: Set<string>): boolean;

/** Adds `corner-shape: round` to every rule whose `border-radius` is a full radius. */
declare const roundCorners: PluginCreator<RoundCornersOptions>;
export default roundCorners;
