#!/usr/bin/env bash
# Fixture for loading-prototype: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
mkdir -p resources/views/checkout
cat > resources/views/checkout/summary.blade.php <<'EOF'
<div class="summary">
    <h2>Order #{{ $order->id }}</h2>
    <ul>
        @foreach ($order->lines as $line)
            <li>{{ $line->name }}: {{ $line->amount / 100 }} EUR</li>
        @endforeach
    </ul>
    <p>Total: {{ $order->total / 100 }} EUR</p>
</div>
EOF
base_commit
