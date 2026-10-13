#!/usr/bin/env bash
# Fixture for loading-authoring-a-skill: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
mkdir -p docs
cat > docs/release.md <<'EOF'
# Release checklist

1. `php artisan test` is green.
2. `vendor/bin/phpstan analyse` is clean.
3. Bump the version in `config/app.php`.
4. Tag `v<version>` and push the tag.
5. Post the changelog in #releases.
EOF
base_commit
