#!/usr/bin/env bash
# Fixture for loading-opening-a-pr: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
base_commit
git checkout -q -b feature/order-notes
mkdir -p app/Models
cat >> app/Models/Order.php <<'EOF'

// Order notes: free text the shop owner can attach to an order.
EOF
git_eval commit -qam "feat(orders): add order notes"
