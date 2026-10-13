#!/usr/bin/env bash
# Fixture for loading-ambiguous-feature-or-refactor: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
base_commit
