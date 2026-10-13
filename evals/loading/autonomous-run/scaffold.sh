#!/usr/bin/env bash
# Fixture for loading-autonomous-run: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
mkdir -p tests/Feature
cat > tests/Feature/CheckoutTest.php <<'EOF'
<?php

use App\Models\Order;

it('refuses to ship a pending order', function () {
    $order = Order::factory()->create(['status' => 'pending']);

    $this->post("/orders/{$order->id}/ship")->assertStatus(422);
});

it('lists only pending orders', function () {
    Order::factory()->create(['status' => 'paid']);

    $this->get('/orders')->assertJsonCount(0);
});
EOF
cat > TEST_OUTPUT.txt <<'EOF'
FAIL  Tests\Feature\CheckoutTest
x refuses to ship a pending order
  Expected status 422, got 404. Route [orders/{order}/ship] not defined.
x lists only pending orders
  Route [orders] not defined.
FAIL  Tests\Feature\OrderTest
x ships a paid order
  Call to undefined method App\Models\Order::factory()
Tests: 3 failed
EOF
base_commit
