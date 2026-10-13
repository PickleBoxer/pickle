#!/usr/bin/env bash
# Fixture for loading-session-pickup: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
cat > HANDOFF.md <<'EOF'
# Handoff

Task: add an `OrderStatus` enum and migrate callers.

Done:
- Wrote `app/Enums/OrderStatus.php` (not committed yet, see below).

Next:
- Cast `Order::$status`.
- Replace string comparisons in `OrderController` and `ShipOrder`.
- Run `php artisan test`.

Open question: should `shipped` orders be able to go back to `paid` on refund?
EOF
base_commit
