#!/usr/bin/env bash
# A PHP repo on GitHub with a CLAUDE.md and one architecture test the guide must not name.
set -euo pipefail
git init -q
git remote add origin git@github.com:acme/shop.git
printf '# Shop\n\nRun `vendor/bin/pest` before committing.\n' > CLAUDE.md
cat > composer.json <<'JSON'
{
    "require": { "php": "^8.4" },
    "require-dev": { "pestphp/pest": "^4.0" },
    "autoload": { "psr-4": { "App\\": "src/" } }
}
JSON
mkdir -p src/Orders tests/Architecture
cat > src/Orders/PlaceOrder.php <<'PHP'
<?php

declare(strict_types=1);

namespace App\Orders;

final class PlaceOrder
{
    public function __invoke(int $cartId): int
    {
        return $cartId;
    }
}
PHP
cat > tests/Architecture/ShopOrdersArchTest.php <<'PHP'
<?php

arch('orders do not use globals')
    ->expect('App\Orders')
    ->not->toUse(['die', 'exit']);
PHP
