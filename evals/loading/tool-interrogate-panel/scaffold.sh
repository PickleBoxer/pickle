#!/usr/bin/env bash
# Fixture for loading-tool-interrogate-panel: the shared Laravel base on main, then a
# branch that bolts order cancellation on with scattered status checks.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
base_commit
git checkout -qb cancel-orders
cat > app/Http/Controllers/OrderController.php <<'PHP'
<?php

namespace App\Http\Controllers;

use App\Models\Order;

class OrderController extends Controller
{
    public function index()
    {
        return Order::where('status', 'pending')->get();
    }

    public function ship(Order $order)
    {
        if ($order->status !== 'paid') {
            abort(422, 'Only paid orders can ship.');
        }

        $order->update(['status' => 'shipped']);

        return $order;
    }

    public function cancel(Order $order)
    {
        if ($order->status === 'shipped' || $order->status === 'cancelled') {
            abort(422, 'This order cannot be cancelled.');
        }

        $order->update(['status' => 'cancelled']);

        return $order;
    }
}
PHP
cat > app/Jobs/ShipOrder.php <<'PHP'
<?php

namespace App\Jobs;

use App\Models\Order;

class ShipOrder
{
    public function __construct(public Order $order) {}

    public function handle(): void
    {
        if ($this->order->status === 'shipped') {
            return;
        }

        if ($this->order->status === 'cancelled') {
            return;
        }

        $this->order->update(['status' => 'shipped']);
    }
}
PHP
git add -A
git_eval commit -qm "add order cancellation"
