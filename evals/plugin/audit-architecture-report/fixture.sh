#!/usr/bin/env bash
# A small TypeScript shop with three subsystems worth a finding and one that is fine as it is.
# src/orders: an Order's status as scattered booleans and optional fields that allow invalid
# combinations. src/notify: the same switch on channel in three files. src/reports: a linear
# customer lookup inside every loop. src/format: clear local code, which should be skipped.
set -euo pipefail
git init -q
c() { git add -A && git -c user.name=eval -c user.email=eval@example.com commit -qm "$1"; }
mkdir -p src/orders src/notify src/reports src/format tests

cat > package.json <<'JSON'
{ "name": "shop", "private": true, "scripts": { "test": "vitest run" } }
JSON

cat > src/orders/order.ts <<'TS'
export type Order = {
  id: string;
  customerId: string;
  totalCents: number;
  isPaid: boolean;
  isShipped: boolean;
  isCancelled: boolean;
  paidAt?: Date;
  shippedAt?: Date;
  trackingNumber?: string;
  cancelReason?: string;
};
TS
cat > src/orders/orderService.ts <<'TS'
import { Order } from "./order";

export function markPaid(o: Order): Order {
  if (o.isCancelled) throw new Error("cancelled");
  return { ...o, isPaid: true, paidAt: new Date() };
}

export function ship(o: Order, trackingNumber: string): Order {
  if (!o.isPaid) throw new Error("not paid");
  if (o.isCancelled) throw new Error("cancelled");
  return { ...o, isShipped: true, shippedAt: new Date(), trackingNumber };
}

export function cancel(o: Order, reason: string): Order {
  if (o.isShipped) throw new Error("already shipped");
  return { ...o, isCancelled: true, cancelReason: reason };
}
TS
cat > src/orders/orderView.ts <<'TS'
import { Order } from "./order";

export function statusLabel(o: Order): string {
  if (o.isCancelled && o.isShipped) return "Unknown";
  if (o.isCancelled) return `Cancelled: ${o.cancelReason ?? "no reason"}`;
  if (o.isShipped) return `Shipped (${o.trackingNumber ?? "no tracking"})`;
  if (o.isPaid) return "Paid";
  return "Awaiting payment";
}
TS

cat > src/notify/channel.ts <<'TS'
export type Channel = "email" | "sms" | "push";
TS
cat > src/notify/send.ts <<'TS'
import { Channel } from "./channel";

export async function send(channel: Channel, to: string, body: string): Promise<void> {
  switch (channel) {
    case "email": console.log(`smtp ${to}: ${body}`); return;
    case "sms": console.log(`twilio ${to}: ${body.slice(0, 160)}`); return;
    case "push": console.log(`fcm ${to}: ${body.slice(0, 100)}`); return;
  }
}
TS
cat > src/notify/preview.ts <<'TS'
import { Channel } from "./channel";

export function preview(channel: Channel, body: string): string {
  switch (channel) {
    case "email": return body;
    case "sms": return body.slice(0, 160);
    case "push": return body.slice(0, 100);
  }
}
TS
cat > src/notify/cost.ts <<'TS'
import { Channel } from "./channel";

export function costCents(channel: Channel): number {
  switch (channel) {
    case "email": return 0;
    case "sms": return 4;
    case "push": return 0;
  }
}
TS

cat > src/reports/types.ts <<'TS'
export type Customer = { id: string; name: string; region: string };
export type OrderRow = { id: string; customerId: string; totalCents: number };
TS
cat > src/reports/revenue.ts <<'TS'
import { Customer, OrderRow } from "./types";

export function revenueByRegion(orders: OrderRow[], customers: Customer[]): Map<string, number> {
  const out = new Map<string, number>();
  for (const o of orders) {
    const c = customers.find((x) => x.id === o.customerId);
    if (!c) continue;
    out.set(c.region, (out.get(c.region) ?? 0) + o.totalCents);
  }
  return out;
}

export function topCustomers(orders: OrderRow[], customers: Customer[], n: number): string[] {
  const totals = new Map<string, number>();
  for (const o of orders) totals.set(o.customerId, (totals.get(o.customerId) ?? 0) + o.totalCents);
  return [...totals.entries()]
    .sort((a, b) => b[1] - a[1])
    .slice(0, n)
    .map(([id]) => customers.find((x) => x.id === id)?.name ?? id);
}
TS
cat > src/reports/missing.ts <<'TS'
import { Customer, OrderRow } from "./types";

export function ordersWithoutCustomer(orders: OrderRow[], customers: Customer[]): OrderRow[] {
  return orders.filter((o) => !customers.find((x) => x.id === o.customerId));
}
TS

cat > src/format/money.ts <<'TS'
export function formatCents(cents: number, currency = "EUR"): string {
  return new Intl.NumberFormat("en", { style: "currency", currency }).format(cents / 100);
}
TS
c "initial shop"

cat > tests/orders.test.ts <<'TS'
import { describe, it, expect } from "vitest";
import { cancel, markPaid, ship } from "../src/orders/orderService";

const fresh = { id: "o1", customerId: "c1", totalCents: 100, isPaid: false, isShipped: false, isCancelled: false };

describe("orders", () => {
  it("ships a paid order", () => expect(ship(markPaid(fresh), "T1").isShipped).toBe(true));
  it("refuses to cancel a shipped order", () =>
    expect(() => cancel(ship(markPaid(fresh), "T1"), "late")).toThrow());
});
TS
c "orders: add service tests"
