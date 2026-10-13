#!/usr/bin/env bash
# Fixture for loading-eval: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
mkdir -p prompts
cat > prompts/summary-a.md <<'EOF'
Write a short, friendly email summarising the order below. List each item and the total.
EOF
mkdir -p prompts
cat > prompts/summary-b.md <<'EOF'
You are a helpful shop assistant. Summarise the order for the customer in under 80 words. Mention the delivery date first, then the items, then the total.
EOF
base_commit
