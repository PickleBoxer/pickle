#!/usr/bin/env bash
# A TypeScript and PHP repo whose docs/agents/review.md lists two lanes and one check. The
# uncommitted change touches both languages and breaks the check by logging a customer's email.
set -euo pipefail
git init -q
c() { git add -A && git -c user.name=eval -c user.email=eval@example.com commit -qm "$1"; }
mkdir -p docs/agents src/orders app

cat > docs/agents/review.md <<'MD'
# Review

Read by the code-review-and-quality skill. The five-axis review always runs; these add to it. Reviews only report.

## Lanes

| Lane | When | Skill or agent |
|------|------|----------------|
| TypeScript idioms | `*.ts` | skill `typescript-best-practices` |
| Acme PHP conventions | `*.php` | skill `acme-php-guidelines` |

## Checks

- Never write a customer's email address to logs.
MD

cat > src/orders/place-order.ts <<'TS'
export interface Order {
  id: string;
  customerEmail: string;
  total: number;
}

export function placeOrder(order: Order): Order {
  return order;
}
TS

cat > app/Invoice.php <<'PHP'
<?php

declare(strict_types=1);

namespace App;

final class Invoice
{
    public function total(int $cents): int
    {
        return $cents;
    }
}
PHP
c "add orders and invoices"

cat > src/orders/place-order.ts <<'TS'
export interface Order {
  id: string;
  customerEmail: string;
  total: number;
}

export function placeOrder(order: any): Order {
  console.log(`placing order ${order.id} for ${order.customerEmail}`);
  return order as Order;
}
TS

cat > app/Invoice.php <<'PHP'
<?php

declare(strict_types=1);

namespace App;

final class Invoice
{
    public function total(int $cents, int $taxCents = 0): int
    {
        return $cents + $taxCents;
    }
}
PHP
