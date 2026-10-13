#!/usr/bin/env bash
# Fixture for loading-visual-parity: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
mkdir -p resources/views
cat > resources/views/invoice.blade.php <<'EOF'
<div style="font-family: Arial; padding: 24px;">
    <h1 style="font-size: 20px;">Invoice {{ $order->id }}</h1>
    <table style="width: 100%;">
        @foreach ($order->lines as $line)
            <tr><td>{{ $line->name }}</td><td style="text-align: right;">{{ $line->amount / 100 }}</td></tr>
        @endforeach
    </table>
</div>
EOF
mkdir -p resources/views/components/ds
cat > resources/views/components/ds/heading.blade.php <<'EOF'
<h1 {{ $attributes->merge(['class' => 'ds-heading']) }}>{{ $slot }}</h1>
EOF
mkdir -p resources/views/components/ds
cat > resources/views/components/ds/table.blade.php <<'EOF'
<table {{ $attributes->merge(['class' => 'ds-table']) }}>{{ $slot }}</table>
EOF
base_commit
