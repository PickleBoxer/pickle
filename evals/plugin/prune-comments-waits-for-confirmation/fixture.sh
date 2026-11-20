#!/usr/bin/env bash
# A small TypeScript cart with one comment per class. Tautology: "add the item to the cart".
# Excuse: the TODO about hardcoded prices. Stale: the note about fetchLegacy(), which no longer
# exists, and a commented-out legacyClient call. Decision Record, keep: rounding per line for the
# payment provider. Decision Record, ADR: money as integer cents everywhere. Not comments for the
# skill: the Copyright header, the docblock on addItem and the eslint-disable directive.
set -euo pipefail
git init -q
mkdir -p src
cat > package.json <<'JSON'
{ "name": "cart", "private": true, "scripts": { "test": "vitest run" } }
JSON

cat > src/cart.ts <<'TS'
// Copyright 2025 Cart Co.
// Licensed under the MIT license.

export type Line = { sku: string; qty: number; unitCents: number };

// Money is integer cents everywhere, never floats or decimals. Floats lost cents in the
// refund run, and going back would mean migrating every stored amount and the provider API.
export type Cart = { lines: Line[] };

// TODO: hack, prices are hardcoded here for now until the catalog service is ready
const PRICES: Record<string, number> = { apple: 120, pear: 95 };

/**
 * Adds an item to the cart and returns the new cart.
 * @param cart the current cart
 * @param sku the product
 */
export function addItem(cart: Cart, sku: string, qty: number): Cart {
  // add the item to the cart
  return { lines: [...cart.lines, { sku, qty, unitCents: PRICES[sku] ?? 0 }] };
}

export function totalCents(cart: Cart, taxRate: number): number {
  // Round tax per line, not on the total: the payment provider rejects a total that differs
  // from the sum of its lines by a cent.
  return cart.lines.reduce((sum, l) => sum + Math.round(l.qty * l.unitCents * (1 + taxRate)), 0);
}
TS

cat > src/api.ts <<'TS'
import { Cart } from "./cart";

export async function saveCart(url: string, cart: Cart): Promise<void> {
  // uses fetchLegacy() so failed saves are retried three times
  // const res = await legacyClient.post(url, cart);
  // eslint-disable-next-line no-console
  console.log("saving", url);
  await fetch(url, { method: "POST", body: JSON.stringify(cart) });
}
TS
git add -A && git -c user.name=eval -c user.email=eval@example.com commit -qm "initial cart"
