# Multi-phase plan

Experimental, ported from pstack.

Tools: `how`, `architect`. Prototype playbook for open questions.

You own the plan, not the code. The plan is the deliverable: a checklist someone else can run box by box. Do not implement.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. If the change fits in one PR with an obvious approach, say so and stop.
3. Run the **how** skill (Skill tool, `pickle:how`) over the code involved: entry points, data stores, callers, tests, and the verify commands. Keep the findings as file pointers, not dumps.
4. Settle open questions before writing: by prototype when a run can answer them, by one question to the user when only they can.
5. Find every writer of the data that moves. When old and new code both write during the move, remove the shared write before planning a sync or a lock: one writer per row or table at each phase (**principle-no-shared-writes**). Every step that copies or backfills data must be safe to run twice.
6. Cut the work into PRs that each land on their own, leave the system working, and carry their own check (**principle-small-verified-steps**). Order them so each phase can be stopped or rolled back.
7. The last phases move every caller to the new form and delete the old one. A plan that ends with both alive is not finished (**principle-finish-migrations**).
8. Write the plan with the template below to the path the user names, else `.scratch/plans/<slug>.md`. If `.scratch/` is not ignored by git, add it to `.git/info/exclude` so the plan is never committed by accident. Keep every heading. Drop a block only by writing `None.` under it. Write it with the **technical-writing** skill (Skill tool, `pickle:technical-writing`): the plan is a how-to, and each heading states the task or the finding.
9. Reread the plan against the template: every PR has every block, every box names its evidence, and the dependency order has no cycle. Then run the **unslop** skill (Skill tool, `pickle:unslop`) on the plan file.
10. Report the plan path, the PRs with their dependencies, and what is still unproven. Execution starts only when the user says so. End with the Loaded line.

## Template

```markdown
# <Change> plan

<Under ten lines: what changes, for whom, and the PRs in order.>

## How to read this

One box is one unit of work. Check a box only when its evidence exists: a test run, a command output, a screenshot, a commit. Run each PR with the pickle playbook named in it.

## Order

- [ ] <PR id> first. Branches from the base branch.
- [ ] <PR id> after <PR id>.
- [ ] Writers per phase: <which app or job writes which table at each phase>.
- [ ] Live verification runs as the **swarm** skill (Skill tool, `pickle:swarm`): one full swarm at the code-ready head of each PR. Another full swarm only for new behaviour, a redesign or a large new diff. A rebase, conflict fix or minor fix gets one verifier at the new head.

## <Task as a verb phrase> (<PR id>)

**Playbook.** <feature, refactor, ...>

**Depends on.** <PR id, or None.>

**Files.**
- [ ] Edit `<path>`.
- [ ] Create `<path>`.
- [ ] Delete `<path>`.

**Change.**
- [ ] <One change. Name the symbol and the file.>

**You see.**
- [ ] <One observable result: the log line, the screen state, the row.>

**Verify.**
- [ ] Test: <test file and case>. Run `verify.test`.
- [ ] Live: <scenario on the running app>. Pass when <predicate>.
- [ ] Perf, if it can change speed: <metric>, baseline on the base branch first. Fails above <number>.

**Rollback.**
- [ ] <How to undo this PR safely, including data written so far.>

## Close

- [ ] Every caller is on the new form and the old one is deleted.
- [ ] Every box above is checked with its evidence.

## Risks

<Each risk, the PR it lands in, and what to watch.>

## Alternatives rejected

<Each approach weighed and why it lost.>
```
