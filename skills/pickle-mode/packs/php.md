<!-- TODO: written from memory, not checked against docs. Verify every command, API and version claim against the official docs, then delete this comment. Least certain: `expectsDatabaseQueryCount`, `Benchmark::measure()`, PHPStan reporting a missing `match` case, `casts()` from Laravel 11, `withExceptions`, the laravel-lsp and php-lsp install commands. -->

# PHP pack

The PHP half of the principles, plus default verify commands and the language server. Each section gives only the PHP form of one principle: read the principle file first, then apply it with the lines below. Lines marked Laravel apply when `composer.json` requires `laravel/framework`.

## Verify commands

The profile's verify commands win. Without a profile, use the first that exists in the project:

| Purpose | Command |
|---|---|
| test | a `composer.json` script such as `composer test`, then `php artisan test` (Laravel), `vendor/bin/pest`, `vendor/bin/phpunit` |
| types | `vendor/bin/phpstan analyse` (Larastan on Laravel), `vendor/bin/psalm` |
| lint | `vendor/bin/pint --test`, `vendor/bin/php-cs-fixer fix --dry-run --diff`, `vendor/bin/phpcs` |
| refactor check | `vendor/bin/rector process --dry-run`, when `rector.php` exists |

Run a single test file or filter (`--filter`) while iterating, the full suite before saying done.

## Language server

With a PHP language server, the LSP tool finds definitions and references and reports diagnostics after edits, more reliably than grep. If the LSP tool is not available for `.php` files, suggest one plugin once in the reply. Do not install it.

- Laravel app: `laravel-lsp@laravel` from the `laravel/agent-skills` marketplace. Server: `composer global require laravel/lsp`.
- Other PHP: `php-lsp@claude-plugins-official` (Intelephense). Server: `npm install -g intelephense`.

## principle-types

- A closed set is a backed enum (`enum OrderStatus: string`), never class constants or string literals compared across files. Laravel: cast the column to the enum in `casts()` (`$casts` before Laravel 11).
- Branch over an enum with `match` and no `default` arm. PHPStan reports a missing case, and PHP throws `UnhandledMatchError` at runtime.
- Distinct meanings get a `final readonly class` value object (`OrderId`, `Money`) that validates in its constructor. Laravel: store it through a custom cast (`CastsAttributes`).
- Native types on every parameter, return and property. Generics and shapes go in PHPDoc (`list<OrderLine>`, `array<string, int>`). An `array{...}` shape at a boundary becomes a class inside.
- `@phpstan-ignore`, `@var` overrides and a growing PHPStan baseline are lies to the checker. Fix the type or trace the hazard to a boundary.

## principle-boundaries

- Laravel HTTP input goes through a Form Request. Use `$request->validated()` or a DTO built from it, never `$request->all()`.
- Controllers parse, call one action or service, and return a response. The action takes domain types, not `Request`.
- A third-party API sits behind an interface the app owns, bound in a service provider (`$this->app->bind(PaymentGateway::class, StripeGateway::class)`). The adapter catches vendor exceptions and throws domain ones.
- Laravel: `env()` only inside `config/*.php`. Code reads `config()`, or it breaks under `config:cache`.
- Let exceptions reach the handler (`withExceptions` in `bootstrap/app.php` on Laravel 11+). No `catch` that returns `null` or `false`.

## principle-model-the-domain

- Lifecycle rules live on the enum (`canTransitionTo()`, or a transitions map) and in one model or action method (`$order->cancel()`), not in `update(['status' => ...])` calls spread across controllers and jobs.
- A query rule used in several places becomes a local scope or a custom query builder.

## principle-idempotent-operations

- Converge with a conditional update and act on the result: `Order::whereKey($id)->where('status', OrderStatus::Paid)->update([...])` returns the affected row count. A read, a check in PHP, then a write is a race.
- `firstOrCreate`, `updateOrCreate` and `upsert` are only safe with a unique index behind them.
- Laravel jobs: `ShouldBeUnique`, or the `WithoutOverlapping` job middleware. Dispatch after commit (`afterCommit()`) when the job reads rows the transaction writes.
- Laravel scheduled commands: `->withoutOverlapping()->onOneServer()`.
- Webhooks: store the provider's event ID under a unique constraint and skip duplicates. Outgoing payments: pass the provider's idempotency key.
- Backfills: `chunkById` with a `where` that skips rows already converted, so a rerun resumes.

## principle-no-shared-writes

- A unique index or a conditional update is structural serialization. Prefer them to locks.
- Locks when the invariant is real: `lockForUpdate()` inside `DB::transaction`, or `Cache::lock()` with a timeout and `block()`.

## principle-test-behavior

- Pest: call the route or action, then assert the response and the stored state: `expect($order->fresh()->status)->toBe(OrderStatus::Shipped)` or `assertDatabaseHas`.
- Fakes (`Queue::fake()`, `Mail::fake()`, `Http::fake()`, `Event::fake()`) assert the payload with a closure, `Mail::assertSent(OrderShipped::class, fn ($mail) => $mail->order->is($order))`, not only that something was sent.
- `Http::preventStrayRequests()` so an unfaked call fails the test.
- Build data with factory states (`Order::factory()->paid()`), many inputs with datasets.
- Pest `arch()` tests are fine for layering rules, such as controllers never using `DB`.

## principle-fix-root-causes

- Reproduce with a failing Pest test before the fix.
- Read the real error: `storage/logs/laravel.log` or `php artisan pail`.
- "Works locally", "fails after deploy" or "fails after restart": suspect cached config, routes, views and events (`php artisan optimize:clear`) and long-running workers that still run old code (`php artisan queue:restart`, Octane, Horizon).
- `Model::preventLazyLoading()` outside production turns hidden N+1 queries into errors.
- Remove `dd()`, `dump()` and `ray()` before saying done.

## principle-finish-migrations

- Find every caller with LSP references and grep for the string forms too: config keys, route names, `$model->status === '...'`.
- Mechanical sweeps: a Rector rule beats hand edits.
- Database: expand, migrate, contract. Drop a column only after the deployed code no longer reads it, in a later deploy.

## principle-prove-it-works

- Query counts: `$this->expectsDatabaseQueryCount(n)` in a test, or `DB::listen` while reproducing.
- Timing: `Illuminate\Support\Benchmark::measure()` with several iterations, never a single run.
- Run the profile's `verify.ui` check for anything a user sees in Blade, Livewire or Inertia.
