# PHP stack

Maps workflow skill steps to PHP commands and tools: a core for any PHP project, then the Laravel and Symfony commands that replace parts of it. Commands only; coding idioms come from a language skill. The project's own commands win: `composer.json` scripts, CI workflows, README and `CLAUDE.md`. Check `composer.json` before you run a tool, since not every project installs every tool below.

## Contents

- Detect
- Two sides of one repository
- Core commands
- Laravel
- Symfony
- CI and shipping

## Detect

- `composer.json` may sit in a subfolder (for example `project/`), not the repository root. Find it, and run every command below from that folder.
- Its `scripts` come first: `composer test`, `composer test:unit`, `composer test:types` and the like are the project's own commands and win over the tables below.
- `composer.json` with `laravel/framework`: core plus the Laravel section. With `symfony/framework-bundle` (and a `bin/console`): core plus the Symfony section. Neither: core only. Read exact versions from `composer.lock`.
- Test runner: `pestphp/pest` in `require-dev` (and `tests/Pest.php`) means Pest. Otherwise PHPUnit.
- Tool configs: `pint.json`, `.php-cs-fixer.dist.php`, `phpstan.neon`, `rector.php`, `infection.json5`.
- Docker: Laravel Sail (`vendor/bin/sail`) or a `compose.yaml` means commands may run in a container. Follow the project's README.

## Two sides of one repository

A PHP app with a JS frontend has two toolchains. Pick by where the change is:

- PHP side (`src/` or `app/`, `routes/`, `config/`, `tests/`, Blade, Twig and Livewire templates): the commands below.
- JS side (`resources/js/` in Laravel, `assets/` in Symfony, Inertia pages, Vue or React components): the scripts in `package.json`, and the JS examples in the workflow skills apply as written. Use the JS test runner the project already has (often Vitest); if it has none, ask before adding one.
- A change that crosses both, such as an Inertia page with its controller: run both sides' checks.

## Core commands

| Step | Command | Notes |
|---|---|---|
| Full suite | `vendor/bin/phpunit` or `vendor/bin/pest` | |
| Focused test | `--filter=name` on either | |
| Format check | `vendor/bin/php-cs-fixer fix --dry-run --diff` | Laravel: Pint, below |
| Static analysis | `vendor/bin/phpstan analyse` | framework extension in `phpstan.neon` |
| Automated refactor check | `vendor/bin/rector process --dry-run` | when `rector.php` exists |
| Coverage | `vendor/bin/phpunit --coverage-text` or `vendor/bin/pest --coverage --min=80` | needs Xdebug or PCOV |
| Mutation | `vendor/bin/infection --git-diff-lines --git-diff-base=main` or `vendor/bin/pest --mutate` | changed lines only |
| CI install | `composer install --no-interaction --prefer-dist` | installs exactly what `composer.lock` pins |
| Lockfile check | `composer validate` | errors when `composer.lock` is out of date |
| Dependency audit | `composer audit --locked` | plus the JS side's audit when there is a `package.json` |
| Unfamiliar project | `composer install --no-scripts --no-plugins` | Composer plugins run code; allow each under `config.allow-plugins` |

## Laravel

Idioms: the `laravel-best-practices` skill and the package skills (`pest-testing`, `livewire-development`, `inertia-*` and others) that Laravel Boost installs for the project's packages: `composer require laravel/boost --dev`, then `php artisan boost:install`. Use them when installed; pickle ships no copy.

| Step | Command | Notes |
|---|---|---|
| Full suite | `php artisan test` | `--parallel` uses `brianium/paratest`, which Pest already requires |
| Focused test | `php artisan test --filter=name` | |
| Format check | `vendor/bin/pint --test` | fix changed files with `vendor/bin/pint --dirty` |
| Static analysis | `vendor/bin/phpstan analyse` | with `larastan/larastan` |
| Coverage | `php artisan test --coverage --min=80` | |
| Migration preview | `php artisan migrate --pretend` | the SQL, without running it |
| Find N+1 queries | `Model::preventLazyLoading(! app()->isProduction())` in `AppServiceProvider::boot()` | a lazy load then throws in tests and locally |
| Profile a request | Laravel Telescope or Debugbar | query count and time per request |
| Assets | `npm run build` | Vite |
| Deploy | `php artisan migrate --force`, `php artisan optimize`, `php artisan queue:restart` | |
| Feature flags | Laravel Pennant | |

## Symfony

No Symfony language skill is planned. Follow the project's own conventions.

| Step | Command | Notes |
|---|---|---|
| Full suite | `php bin/phpunit` | from `symfony/test-pack` |
| Container, config and templates | `php bin/console lint:container`, `lint:yaml config`, `lint:twig templates` | |
| Static analysis | `vendor/bin/phpstan analyse` | with `phpstan/phpstan-symfony`, `symfony.containerXmlPath` set |
| Mapping check | `php bin/console doctrine:schema:validate` | entities against the database |
| Migration preview | `php bin/console doctrine:migrations:migrate --dry-run` | |
| Profile a request | Symfony Profiler, Doctrine panel | query count per request, for N+1 |
| Assets | `php bin/console asset-map:compile` (AssetMapper) or `npm run build` (Encore) | |
| Deploy | `composer install --no-dev --optimize-autoloader`, `composer dump-env prod`, `APP_ENV=prod APP_DEBUG=0 php bin/console cache:clear`, `php bin/console doctrine:migrations:migrate --no-interaction`, `php bin/console messenger:stop-workers` | |

## CI and shipping

- CI: `shivammathur/setup-php` with the project's PHP version and coverage driver, Composer cache on `composer.lock`, then format check, static analysis, `composer audit --locked` and the suite. Laravel needs `cp .env.example .env && php artisan key:generate` first.
- Rollback: code rolls back, data does not. Keep each migration compatible with the previous release (add, backfill, then remove in a later release).
- An API used by a mobile app must stay compatible with every app version still installed. See [swift.md](swift.md), Shipping.
