#!/usr/bin/env bash
# Fixture for loading-refactor: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
mkdir -p app/Http/Controllers
cat > app/Http/Controllers/CheckoutController.php <<'EOF'
<?php

namespace App\Http\Controllers;

use App\Models\Order;
use Stripe\StripeClient;

class CheckoutController extends Controller
{
    public function pay(Order $order)
    {
        $stripe = new StripeClient(config('services.stripe.secret'));

        $intent = $stripe->paymentIntents->create([
            'amount' => $order->total,
            'currency' => 'eur',
            'metadata' => ['order_id' => $order->id],
        ]);

        if ($intent->status === 'succeeded') {
            $order->update(['status' => 'paid']);
        }

        return $intent;
    }

    public function refund(Order $order)
    {
        $stripe = new StripeClient(config('services.stripe.secret'));

        return $stripe->refunds->create(['payment_intent' => $order->payment_intent_id]);
    }
}
EOF
base_commit
