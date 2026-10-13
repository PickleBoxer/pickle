#!/usr/bin/env bash
# Fixture for loading-pause-safely: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
base_commit
mkdir -p app/Enums
cat > app/Enums/OrderStatus.php <<'EOF'
<?php

namespace App\Enums;

enum OrderStatus: string
{
    case Pending = 'pending';
    case Paid = 'paid';
    // TODO: shipped
}
EOF
cat > app/Models/Order.php <<'EOF'
<?php

namespace App\Models;

use App\Enums\OrderStatus;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $casts = ['status' => OrderStatus::class];

    protected $fillable = ['customer_id', 'status', 'total'];

    public function isPaid(): bool
    {
        return $this->status === 'paid';
    }
}
EOF
