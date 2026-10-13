#!/usr/bin/env bash
# Fixture for loading-multi-phase-plan: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
mkdir -p database/migrations
cat > database/migrations/2025_06_01_000000_create_shop_orders_table.php <<'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('shop_orders', function (Blueprint $table) {
            $table->ulid('id')->primary();
            $table->foreignId('customer_id');
            $table->string('state');
            $table->unsignedBigInteger('total_cents');
            $table->timestamps();
        });
    }
};
EOF
mkdir -p docs
cat > docs/admin-app.md <<'EOF'
# Legacy admin app

A separate PHP app used by the warehouse. It reads and writes the `orders` table directly
(status updates, manual totals). It will not be changed during the migration.
EOF
base_commit
