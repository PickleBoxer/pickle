---
description: A bug fix request in a Laravel app, with the PHP class pasted inline and no mention of tests. The skill should fire, and the reply should reproduce the bug with a failing Pest or PHPUnit test, using Laravel's test commands, since the bug is on the PHP side.
expected_outcome: A Pest or PHPUnit test that reproduces the lost cent, shown or described as failing first, then the fix; test-driven-development is invoked; no JS test runner (npm test, Jest, Vitest) for this PHP-side bug.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

Fix this bug in our Laravel app: InvoiceSplitter::split(10000, 3) returns [3333, 3333, 3333] and a cent goes missing. Here is the class.

```php
<?php

namespace App\Billing;

final class InvoiceSplitter
{
    /** @return list<int> */
    public static function split(int $totalCents, int $parts): array
    {
        $share = intdiv($totalCents, $parts);

        return array_fill(0, $parts, $share);
    }
}
```
