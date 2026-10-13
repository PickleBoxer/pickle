# Worktree cleanup

Experimental, ported from pstack.

Tools: none.

This playbook deletes local state with no review to catch a slip. The checks below are the review.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Record free disk space. List worktrees with `git worktree list --porcelain`. Never type a worktree path by hand.
3. For each worktree, collect: branch, last commit date, merged into the base branch or not, uncommitted changes, untracked files, open PR.
4. Sort them:
   - Safe: merged, clean, no open PR.
   - Ask: uncommitted changes, unmerged commits, an open PR, or recent activity. Show what would be lost and wait for the user's answer.
   - Keep: the current worktree and any the user names.
5. Check the evidence for each safe one directly before removing it (**principle-prove-it-works**). A guess about whether a worktree is in use is not evidence.
6. Remove each confirmed worktree with `git worktree remove <path>`, then `git worktree prune`. Branches stay, so committed work is not lost. Delete branches only if the user asked.
7. Record free disk space again and list the worktrees that remain.
8. Report the space reclaimed, the worktrees removed, and each one kept with its reason. End with the Loaded line.
