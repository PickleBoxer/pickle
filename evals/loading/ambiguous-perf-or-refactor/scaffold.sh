#!/usr/bin/env bash
# Fixture for loading-ambiguous-perf-or-refactor: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
mkdir -p resources/views/orders
cat > resources/views/orders/index.blade.php <<'EOF'
@foreach ($orders as $order)
    <tr>
        <td>{{ $order->id }}</td>
        <td>{{ $order->customer->name }}</td>
        <td>{{ $order->lines->count() }} items</td>
    </tr>
@endforeach
EOF
mkdir -p app/Models
cat > app/Models/Customer.php <<'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Customer extends Model {}
EOF
base_commit
