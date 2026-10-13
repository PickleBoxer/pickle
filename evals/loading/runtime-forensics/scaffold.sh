#!/usr/bin/env bash
# Fixture for loading-runtime-forensics: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
mkdir -p app/Jobs
cat > app/Jobs/SyncInventory.php <<'EOF'
<?php

namespace App\Jobs;

use Illuminate\Support\Facades\Http;

class SyncInventory
{
    public function handle(): void
    {
        do {
            $response = Http::get('https://warehouse.example/api/stock');
        } while (! $response->successful());
    }
}
EOF
base_commit
