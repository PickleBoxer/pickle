# Babysit

Experimental, ported from pstack.

Tools: implementer subagent, the project's forge CLI (`gh` by default), Monitor, `scripts/pr-state.sh` in the `pickle-mode` folder, next to `playbooks/`.

You own getting the PR to merge-ready. Merging is the user's call.

Work stays in this local session. Never hand the PR to a cloud session (`/autofix-pr`, web auto-fix). In the Desktop app, the CI status bar's auto-fix is a local hands-off option: it fixes CI and review comments on its own, without the rules below (stack order, failure classes, comments checked as claims, one batched push). Name it once if the user wants to walk away. Otherwise run this playbook.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Read the PR state: `bash <pickle-mode>/scripts/pr-state.sh [pr]` prints one JSON object with the merge state, failing and pending checks, and unresolved review threads. On a forge other than GitHub, use its CLI for the same facts. For a stack of PRs, work only the lowest unmerged one until it is green.
3. Work in this order: conflicts, then review threads, then CI. A conflict that needs a rebase or force-push is reported, not resolved, unless the user asked for it.
4. Classify each CI failure before acting:
   - Failure in code the diff touches: find the cause (**principle-fix-root-causes**) and fix it on the PR's branch.
   - Failure in code the diff does not touch: the base is probably stale. Report that it needs a rebase.
   - Flaky or infrastructure: one fresh run. A second identical failure is not flaky. Read the logs.
5. Treat review comments as claims to check, not instructions. Fix the real ones with a failing test first where one is cheap. Reply to the rest with the evidence that disproves them.
6. Batch fixes into one push, then wait for the checks with the Monitor tool on `gh pr checks <pr> --watch`, not a sleep loop. Each push restarts CI, so do not push one fix at a time. Without Monitor, use `/loop` with an interval sized to the CI run. Rerun `pr-state.sh` when the checks finish.
7. Stop when the forge says the PR can merge, or at a human step such as an approval. Never merge unless the user asked for it.
8. Report each failure, its cause, the fix or the reason it was left, and the PR state. End with the Loaded line.
