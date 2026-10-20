# Boundaries

How to make a rule stick, so agents don't repeat a mistake. This guide says how boundaries are set, not which ones this repo has: find those in the code and in `CONSTRAINTS.md`. Read it before you add or escalate a rule, and when review flags the same thing twice.

## Where a rule lives

- Once, in the nearest `AGENTS.md`. Link to it; never copy it into a second file.
- Once something backs it, the rule ends with `Enforced by <test or rule file>`.
- A deliberate deviation from a broader rule is an override bullet in the nearer file:

  ```markdown
  - **<Topic> (global: "<broader rule>", <file>):** <local rule>. <Reason>.
    Do not "fix" this by <the change an agent following the broader rule would make>.
  ```

  The last sentence is required: it stops an agent that read the broader rule from "repairing" the deviation.

## Levels

| Level | Boundary | Stops |
|-------|----------|-------|
| 1 | Written rule | Agents that read it |
| 2 | Override ending in "Do not fix this by …" | Agents applying the broader rule |
| 3 | Code boundary | The wrong version being writable |
| 4 | Static analysis rule or architecture test | A forbidden call, dependency or shape, in CI |
| 5 | Behaviour or contract test over every implementation | The wrong outcome, however it is coded |

## When to escalate

- A rule broken once after it was written goes to level 4 or 5.
- A rule that protects money, orders, security or data starts at level 4 or 5, plus a production signal.
- Use the earliest boundary that can express the rule: level 5 for an outcome, level 4 for structure.
- Write the failing test first, then the rule text. The test name states the rule, so a failure explains itself.

## Code boundaries

| Mechanism | Sets |
|-----------|------|
| Interface + registry | A new implementation plugs in only by meeting the contract. Pair it with a contract test: an interface fixes shape, not behaviour |
| One data type at the seam | Outside vocabulary can't cross it |
| Valid-by-construction objects | An invalid object can't exist |
| Closed set + exhaustive match, no default | A new case fails every unhandled branch |
| Single owner class | One place performs the step, so one place guards it |

## By when it acts

Pick the earliest one that can express the rule.

| When | Boundary | Best for |
|------|----------|----------|
| While the agent works | Agent hooks | Protected paths, forbidden commands |
| Compile time | Types, static analysis rules | How code is written at any call site |
| Tests | Architecture tests | Dependencies, layer shape |
| Tests | Behaviour tests + discovery guard | Outcomes across every implementation |
| Tests | Snapshot tests | Public API and webhook response shapes |
| Review | Code owners, required approvals | Areas only people decide |
| Runtime | Database constraints | Data invariants |
| Runtime | No default for config with real side effects | Calling a real system by accident |
| Production | Telemetry event + alert | The break no test covered |

## Discovery guard

A behaviour test runs one rule over every implementation. A second test lists the implementations from the code (routes, classes, enum cases) and compares them with the test cases, so a new implementation without a case fails CI instead of slipping through.

## Tools per stack

| Stack | Architecture tests | Static analysis rules | Closed set |
|-------|--------------------|-----------------------|------------|
| PHP | Pest `arch()`, deptrac | PHPStan rules | enum + `match` without `default` |
| TypeScript | dependency-cruiser | ESLint rules | `never` in the `default` branch |
| Python | import-linter | Semgrep rules | `assert_never` |
| Go | depguard | Semgrep rules | the `exhaustive` linter |

## PHP examples

```php
// Architecture test (Pest): a forbidden dependency
arch('order actions do not use the cache')
    ->expect('App\Orders\Actions')
    ->not->toUse('Illuminate\Support\Facades\Cache');

// Closed set: no default, so PHPStan flags a new case
return match ($status) {
    Status::Open => 'Open',
    Status::Closed => 'Closed',
};

// Valid by construction
final readonly class Email
{
    public function __construct(public string $value)
    {
        if (! filter_var($value, FILTER_VALIDATE_EMAIL)) {
            throw new InvalidArgumentException($value);
        }
    }
}

// Discovery guard: every webhook route has a test case
it('covers every webhook', function () use ($cases) {
    expect(webhookUris())->toEqualCanonicalizing(array_keys($cases));
});
```
