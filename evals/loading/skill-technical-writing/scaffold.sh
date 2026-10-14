#!/usr/bin/env bash
# Fixture for loading-skill-technical-writing: the shared Laravel base, nothing else.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
base_commit
