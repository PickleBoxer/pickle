#!/usr/bin/env bash
# Fixture for loading-worktree-cleanup: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
base_commit
echo ".worktrees/" >> .git/info/exclude
git_eval worktree add -q -b old/experiment-a .worktrees/experiment-a
git_eval worktree add -q -b old/experiment-b .worktrees/experiment-b
echo "wip" > .worktrees/experiment-b/WIP.md
git_eval worktree add -q -b feature/live .worktrees/live
