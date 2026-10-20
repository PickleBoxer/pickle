---
description: A firing case. A test request for a Laravel validation rule, pasted inline, with several invalid inputs that share one behavior. test-driven-development should fire, and the reply should cover the invalid inputs with one parameterized test (a Pest dataset) instead of copies that differ only in the value.
expected_outcome: test-driven-development is invoked; the reply's Pest tests use a dataset (`->with()` or `dataset()`) for the rejected SKUs, with each case named, rather than one copied test per value.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

Add tests for this rule. We use Pest. It should reject an empty SKU, lowercase letters, a missing dash, too few digits and too many digits, and accept a valid one like ABC-1234.

```php
<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

final class Sku implements ValidationRule
{
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (! is_string($value) || preg_match('/^[A-Z]{3}-\d{4}$/', $value) !== 1) {
            $fail('The :attribute must look like ABC-1234.');
        }
    }
}
```
