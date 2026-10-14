#!/usr/bin/env bash
# Fixture for loading-skill-no-comments: the bug-fix fixture on main, then a branch
# whose fix to Order::total() comes wrapped in narrating and defensive comments.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../bug-fix/scaffold.sh"

git checkout -qb skip-refunds
cat > app/Models/Order.php <<'PHP'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable = ['customer_id', 'status', 'total'];

    // Relationship to the order lines
    public function lines()
    {
        return $this->hasMany(OrderLine::class);
    }

    // ===== Totals =====
    // IMPORTANT: do not remove the null check, it is too risky
    public function total(): int
    {
        // Filter out refunded lines so they are not counted
        $lines = $this->lines->filter(fn ($line) => $line !== null && ! $line->refunded);

        // $old = $this->lines->sum('amount');

        // Sum the amounts
        return $lines->sum('amount');
    }
}
PHP
git add -A
git_eval commit -qm "fix(orders): skip refunded lines in total"
