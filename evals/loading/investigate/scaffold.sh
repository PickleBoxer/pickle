#!/usr/bin/env bash
# Fixture for loading-investigate: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
mkdir -p app/Console/Commands
cat > app/Console/Commands/ShipPaidOrders.php <<'EOF'
<?php

namespace App\Console\Commands;

use App\Jobs\ShipOrder;
use App\Models\Order;
use Illuminate\Console\Command;

// Scheduled every minute in routes/console.php.
class ShipPaidOrders extends Command
{
    protected $signature = 'orders:ship-paid';

    public function handle(): void
    {
        Order::where('status', 'paid')->each(fn (Order $order) => dispatch(new ShipOrder($order)));
    }
}
EOF
mkdir -p routes
cat > routes/console.php <<'EOF'
<?php

use Illuminate\Support\Facades\Schedule;

Schedule::command('orders:ship-paid')->everyMinute();
EOF
mkdir -p app/Listeners
cat > app/Listeners/ShipOnPayment.php <<'EOF'
<?php

namespace App\Listeners;

use App\Events\OrderPaid;
use App\Jobs\ShipOrder;

class ShipOnPayment
{
    public function handle(OrderPaid $event): void
    {
        dispatch(new ShipOrder($event->order));
    }
}
EOF
base_commit
