#!/usr/bin/env bash
# Fixture for loading-tool-why: the shared Laravel base plus a batch limit whose reason lives in git history.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
cat > app/Jobs/SyncOrders.php <<'PHP'
<?php

namespace App\Jobs;

use App\Models\Order;
use Illuminate\Support\Facades\Http;

class SyncOrders
{
    public function handle(): void
    {
        Order::query()->chunk(500, function ($orders) {
            Http::post('https://erp.example.com/orders', $orders->toArray());
        });
    }
}
PHP
base_commit

sed -i.bak 's/chunk(500/chunk(100/' app/Jobs/SyncOrders.php && rm app/Jobs/SyncOrders.php.bak
git add -A
git_eval commit -qm "cap order sync batches at 100 (#42)" -m "The ERP rejects payloads over 1 MB with a 413. 500 orders hit that on busy days, see ticket OPS-311."
