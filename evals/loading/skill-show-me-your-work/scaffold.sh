#!/usr/bin/env bash
# Fixture for loading-skill-show-me-your-work: the shared Laravel base, nothing more.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
base_commit
