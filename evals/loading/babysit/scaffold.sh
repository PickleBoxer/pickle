#!/usr/bin/env bash
# Fixture for loading-babysit: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
mkdir -p .github/workflows
cat > .github/workflows/ci.yml <<'EOF'
name: ci
on: [pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: composer install
      - run: vendor/bin/pint --test
      - run: vendor/bin/phpstan analyse
      - run: php artisan test
EOF
base_commit
git checkout -q -b fix/order-total
cat > ci-log.txt <<'EOF'
Run vendor/bin/pint --test
  FAIL  app/Http/Controllers/OrderController.php  (no_unused_imports)
Run vendor/bin/phpstan analyse
  ------ ------------------------------------------------
   Line   app/Jobs/ShipOrder.php
  ------ ------------------------------------------------
   15     Access to an undefined property App\Models\Order::$status.
  ------ ------------------------------------------------
Error: Process completed with exit code 1.
EOF
git add -A
git_eval commit -qm "fix(orders): handle refunded lines in total"
