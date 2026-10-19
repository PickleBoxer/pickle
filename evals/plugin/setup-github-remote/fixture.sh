#!/usr/bin/env bash
# A GitHub repo with a CLAUDE.md and no domain docs.
set -euo pipefail
git init -q
git remote add origin git@github.com:acme/shop.git
printf '# Shop\n\nRun `npm test` before committing.\n' > CLAUDE.md
