#!/usr/bin/env bash
# Fixture for loading-skill-figure-it-out: the shared Laravel base plus status strings spread across several layers.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
for job in ShipOrder RefundOrder RemindUnpaid; do
cat > "app/Jobs/$job.php" <<PHP
<?php

namespace App\Jobs;

use App\Models\Order;

class $job
{
    public function handle(Order \$order): void
    {
        if (\$order->status === 'paid' || \$order->status === 'pending') {
            \$order->update(['status' => 'shipped']);
        }
    }
}
PHP
done
cat > tests/Feature/OrderStatusTest.php <<'PHP'
<?php

it('marks a paid order as shipped', function () {
    $order = Order::factory()->create(['status' => 'paid']);
    (new App\Jobs\ShipOrder)->handle($order);
    expect($order->fresh()->status)->toBe('shipped');
});
PHP
base_commit
