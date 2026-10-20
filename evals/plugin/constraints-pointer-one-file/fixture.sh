#!/usr/bin/env bash
# A PHP repo whose CLAUDE.md only imports AGENTS.md.
set -euo pipefail
git init -q
printf '# Shop\n\nRun `vendor/bin/pest` before committing.\n' > AGENTS.md
printf '@AGENTS.md\n' > CLAUDE.md
cat > composer.json <<'JSON'
{
    "require": { "php": "^8.4" },
    "require-dev": { "pestphp/pest": "^4.0", "larastan/larastan": "^3.0" },
    "autoload": { "psr-4": { "App\\": "src/" } }
}
JSON
mkdir -p src tests
printf '<?php\n\ndeclare(strict_types=1);\n\nnamespace App;\n\nfinal class Cart {}\n' > src/Cart.php
printf '<?php\n\nit("builds a cart", fn () => expect(new App\\Cart())->toBeObject());\n' > tests/CartTest.php
