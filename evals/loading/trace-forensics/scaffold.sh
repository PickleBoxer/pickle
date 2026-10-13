#!/usr/bin/env bash
# Fixture for loading-trace-forensics: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
mkdir -p storage/profiles
cat > storage/profiles/checkout.cpuprofile <<'EOF'
{"nodes":[{"id":1,"callFrame":{"functionName":"(root)","url":""},"children":[2]},{"id":2,"callFrame":{"functionName":"CheckoutController::pay","url":"app/Http/Controllers/CheckoutController.php","lineNumber":12},"children":[3,4]},{"id":3,"callFrame":{"functionName":"StripeClient::paymentIntents","url":"vendor/stripe/stripe-php/lib/StripeClient.php"}},{"id":4,"callFrame":{"functionName":"Order::total","url":"app/Models/Order.php","lineNumber":20},"children":[5]},{"id":5,"callFrame":{"functionName":"Collection::sum","url":"vendor/laravel/framework/src/Illuminate/Collections/Collection.php"}}],"startTime":0,"endTime":2400000,"samples":[3,3,5,5,5,5,5,5,5,3],"timeDeltas":[240000,240000,240000,240000,240000,240000,240000,240000,240000,240000]}
EOF
base_commit
