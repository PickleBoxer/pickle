#!/usr/bin/env bash
# Fixture for loading-skill-blast-radius: the tool-why fixture on main, then a branch that raises the sync batch to 250.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../tool-why/scaffold.sh"

git checkout -qb sync-batch-250
sed -i.bak 's/chunk(100/chunk(250/' app/Jobs/SyncOrders.php && rm app/Jobs/SyncOrders.php.bak
git add -A
git_eval commit -qm "raise order sync batch to 250"
