#!/usr/bin/env bash
# Fixture for loading-skill-deslop: the bug-fix fixture on main, then a branch whose fix
# to Order::total() adds needless guards, a try/catch, nesting and an unused fallback.
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

    public function lines()
    {
        return $this->hasMany(OrderLine::class);
    }

    public function total(bool $legacy = false): int
    {
        try {
            if ($this->lines !== null) {
                if (! $legacy) {
                    return (int) $this->lines
                        ->filter(fn ($line) => $line !== null && isset($line->refunded) && ! $line->refunded)
                        ->sum('amount');
                } else {
                    return (int) $this->lines->sum('amount');
                }
            }
            return 0;
        } catch (\Throwable $e) {
            return 0;
        }
    }
}
PHP
git add -A
git_eval commit -qm "fix(orders): skip refunded lines in total"
