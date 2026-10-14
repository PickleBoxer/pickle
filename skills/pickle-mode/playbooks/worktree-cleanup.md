# Worktree cleanup

Experimental, ported from pstack.

Tools: `scripts/worktree-audit.sh` in the `pickle-mode` folder, next to `playbooks/`.

This playbook deletes local state with no review to catch a slip. The checks below are the review.

Claude Code cleans up the worktrees it creates: a clean `--worktree` session's worktree at exit, and subagent and background-session worktrees older than `cleanupPeriodDays` that hold no work. It keeps every worktree made with `git worktree add`, by the user or another tool. This playbook is mostly for those.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Record free disk space. Run `bash <pickle-mode>/scripts/worktree-audit.sh [-b <base>] [repo]`: one row per worktree with size, age, merged, uncommitted work, remote, PR, last Claude Code session, whether Claude Code made it (`CLAUDE`, by its `.claude/worktrees/` path) and a suggested bucket. Pass `-b` when PRs merge into a branch other than the remote's default. Never type a worktree path by hand: take it from the audit.
3. Sort them, starting from the audit's bucket:
   - Safe: merged or with a closed PR, clean, no recent session.
   - Ask: uncommitted changes (`hold-wip`), unmerged commits, an open PR (`hold-open-pr`), or a recent session (`verify-recent-chat`). Show what would be lost and wait for the user's answer.
   - Keep: the current worktree and any the user names.
   A `CLAUDE` worktree that is not safe is one native cleanup would also keep. Say so.
4. Check the evidence for each safe one directly before removing it (**principle-prove-it-works**). A squash merge shows as `MERGED no`, so the PR state is the signal there. A guess about whether a worktree is in use is not evidence.
5. Remove each confirmed worktree with `git worktree remove <path>`, then `git worktree prune`. If git refuses because the worktree is locked, ask before `git worktree unlock`: Claude Code locks the worktree of a running agent. Branches stay, so committed work is not lost. Delete branches only if the user asked.
6. Record free disk space again and list the worktrees that remain.
7. Report the space reclaimed, the worktrees removed, and each one kept with its reason. End with the Loaded line.
