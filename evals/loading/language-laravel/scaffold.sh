#!/usr/bin/env bash
# Fixture for loading-language-laravel: the shared Laravel base, with a profile that lists the
# project's own conventions first, then Laravel Boost's laravel-best-practices. The skill sits in
# .claude/skills/ as boost:install writes it, but project skills do not load in an eval run, so
# the case grades that the Loaded line names it after the project's conventions, loaded or
# flagged as missing, not the skill body.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
mkdir -p .claude/skills/laravel-best-practices
cat > .claude/skills/laravel-best-practices/SKILL.md <<'MD'
---
name: laravel-best-practices
description: Apply this skill whenever writing, reviewing, or refactoring Laravel PHP code.
---

# Laravel best practices

- Eager load relations a loop reads.
- Validate in form requests, authorize in policies.
MD
cat > .claude/pickle.md <<'MD'
---
stack: laravel
conventions: [docs/conventions.md, laravel-best-practices]
gates: [migrations on shared DBs, deploy]
---
## Verify
- test: php artisan test
- types: vendor/bin/phpstan analyse
- lint: vendor/bin/pint --test
MD
base_commit
