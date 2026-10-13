#!/usr/bin/env bash
# Fixture for loading-bug-fix: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
mkdir -p app/Models
cat > app/Models/OrderLine.php <<'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OrderLine extends Model
{
    protected $casts = ['refunded' => 'boolean'];
}
EOF
mkdir -p app/Models
cat > app/Models/Order.php <<'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable = ['customer_id', 'status', 'total'];

    public function lines()
    {
        return $this->hasMany(OrderLine::class);
    }

    public function total(): int
    {
        return $this->lines->sum('amount');
    }
}
EOF
base_commit
