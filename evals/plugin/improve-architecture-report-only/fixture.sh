#!/usr/bin/env bash
# A small TypeScript shop. src/orders is a chain of shallow modules with pricing leaking into two
# of them, and it is where most commits land. src/legacy is old and untouched.
set -euo pipefail
git init -q
c() { git add -A && git -c user.name=eval -c user.email=eval@example.com commit -qm "$1"; }
mkdir -p src/orders src/legacy tests

cat > GLOSSARY.md <<'MD'
# Shop

## Language

**Order**:
A customer's request to buy items, from placement to delivery.
_Avoid_: Purchase, cart

**Discount**:
A reduction of an Order's total, applied when the subtotal passes a threshold.
_Avoid_: Promo, rebate
MD
cat > package.json <<'JSON'
{ "name": "shop", "private": true, "scripts": { "test": "vitest run" } }
JSON
cat > src/legacy/csvExport.ts <<'TS'
export function toCsv(rows: Record<string, unknown>[]): string {
  const keys = Object.keys(rows[0] ?? {});
  return [keys.join(","), ...rows.map((r) => keys.map((k) => String(r[k])).join(","))].join("\n");
}
TS
cat > src/orders/types.ts <<'TS'
export type Item = { sku: string; priceCents: number; qty: number };
export type OrderRequest = { customerId: string; items: Item[] };
export interface Db { insert(table: string, row: object): Promise<{ id: string }> }
TS
cat > src/orders/orderHandler.ts <<'TS'
import { OrderRequest, Db } from "./types";
import { validateOrder } from "./orderValidator";

export async function handleOrder(req: OrderRequest, db: Db) {
  return validateOrder(req, db);
}
TS
cat > src/orders/orderValidator.ts <<'TS'
import { OrderRequest, Db } from "./types";
import { saveOrder } from "./orderRepo";

export async function validateOrder(req: OrderRequest, db: Db) {
  if (req.items.length === 0) throw new Error("empty order");
  return saveOrder(req, db);
}
TS
cat > src/orders/orderRepo.ts <<'TS'
import { OrderRequest, Db } from "./types";

export async function saveOrder(req: OrderRequest, db: Db) {
  return db.insert("orders", req);
}
TS
c "initial shop"

cat > src/orders/pricing.ts <<'TS'
import { Item } from "./types";

export function subtotal(items: Item[]): number {
  return items.reduce((sum, i) => sum + i.priceCents * i.qty, 0);
}
TS
cat > src/orders/orderRepo.ts <<'TS'
import { OrderRequest, Db } from "./types";
import { subtotal } from "./pricing";

export async function saveOrder(req: OrderRequest, db: Db) {
  const sub = subtotal(req.items);
  const totalCents = sub > 10_000 ? Math.round(sub * 0.9) : sub;
  return db.insert("orders", { ...req, totalCents });
}
TS
c "orders: store total"

cat > src/orders/orderValidator.ts <<'TS'
import { OrderRequest, Db } from "./types";
import { saveOrder } from "./orderRepo";
import { subtotal } from "./pricing";

export async function validateOrder(req: OrderRequest, db: Db) {
  if (req.items.length === 0) throw new Error("empty order");
  const sub = subtotal(req.items);
  const totalCents = sub > 10_000 ? Math.round(sub * 0.9) : sub;
  if (totalCents > 500_000) throw new Error("order over limit");
  return saveOrder(req, db);
}
TS
c "orders: reject orders over the limit"

cat > tests/orders.test.ts <<'TS'
import { describe, it, expect, vi } from "vitest";
vi.mock("../src/orders/orderRepo", () => ({ saveOrder: vi.fn(async () => ({ id: "o1" })) }));
vi.mock("../src/orders/orderValidator", async (orig) => orig());
import { handleOrder } from "../src/orders/orderHandler";
import { saveOrder } from "../src/orders/orderRepo";

describe("handleOrder", () => {
  it("passes the request to the repo", async () => {
    const req = { customerId: "c1", items: [{ sku: "a", priceCents: 100, qty: 1 }] };
    await handleOrder(req, {} as never);
    expect(saveOrder).toHaveBeenCalledWith(req, {});
  });
});
TS
c "orders: add handler test"

sed -i.bak 's/10_000 ? Math.round(sub \* 0.9)/20_000 ? Math.round(sub * 0.85)/' src/orders/orderRepo.ts && rm src/orders/orderRepo.ts.bak
c "orders: new discount threshold"
