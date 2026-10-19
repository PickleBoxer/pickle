#!/usr/bin/env bash
# A local repo: no remote, no CLAUDE.md or AGENTS.md.
set -euo pipefail
git init -q
printf '# Notes app\n' > README.md
