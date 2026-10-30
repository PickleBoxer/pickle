---
name: audit-architecture
description: Audit a whole codebase read-only for material simplifications in how it represents state and data (invalid-state booleans, repeated branching, missing indexes, unclear ownership). Reviews every subsystem with Explore subagents, verifies every finding against the code and writes a P0 to P3 Markdown report to docs/agents/reports/. Not a line-level cleanup (/pickle:code-simplify) or a diff review (/pickle:review).
argument-hint: "[path to limit the audit]"
disable-model-invocation: true
---

# Audit Architecture

Find materially useful simplifications in this codebase's data structures, state representation, control flow, algorithms and ownership.

Direction from the user: $ARGUMENTS

## Rules

- **Read-only.** The run writes one file, `docs/agents/reports/audit-architecture-<timestamp>.md`. No edits, no tests, no git command that changes the repo (commit, add, checkout, stash, reset).
- **No questions.** The run is often a scheduled report with nobody watching. Decide, note the decision in the audit log and go on.
- **Every run is a full audit.** Don't read earlier reports in `docs/agents/reports/`; review the code as it is now.
- **At most 2 findings per subsystem.** Every subsystem gets reviewed, however many there are.
- **Direction.** A path limits the audit to subsystems under it.

## 1. Inventory the subsystems

```bash
git status --porcelain
git ls-files | awk -F/ '{print (NF>2 ? $1"/"$2 : $1)}' | sort | uniq -c | sort -rn
git log --since="6 months ago" --name-only --format= | grep -v '^$' | sort | uniq -c | sort -rn | head -30
```

Give each subsystem an ID (`S1`, `S2`, ...), a name, an exact boundary (paths) and its key files and tests. Cover frontend, backend, shared infrastructure, platform bridges, generated contracts and test tooling where they hold logic. No catch-all rows such as "misc": a boundary must be small enough for one reviewer. Order rows by the hot-spot count, busiest first. Keep the `git status` output: the final check compares against it.

## 2. Review each subsystem

Spawn one Explore subagent per subsystem (Agent tool, `subagent_type: Explore`), up to 12 in one message so they run at the same time. With more subsystems, start the next batch once a batch returns, until every row is reviewed. Without the Agent tool, review them yourself in turn.

A subagent sees none of this conversation. Each brief carries the subsystem's boundary, key files and tests, and this text:

> Review this subsystem for at most two materially useful simplifications in its data structures, state representation or organizing model. Read its implementation, public interfaces, major call sites and tests. Stay inside the boundary; name cross-subsystem concerns but don't solve them.
>
> Look for:
> - booleans or optional fields that allow invalid combinations and should be one state machine or discriminated union
> - repeated assumptions about an object's shape that need one shared typed model
> - branching repeated across files that a map, registry, reducer or command model would remove
> - state or behavior with no clear owner that a small module boundary would settle
> - repeated scans or lookups that the right collection or index would remove
> - lifecycle, async or concurrent state that can go stale or contradict itself
>
> Prefer boring local code when it is already clear. Don't recommend a change for consistency alone, hypothetical extensibility, a few saved lines, or moving branching behind a new type. If nothing clearly qualifies, return `skip` with one line why.
>
> Per finding return: evidence (file:line), the current complexity or invalid states, the proposed representation and why it is simpler, the smallest credible scope (files and interfaces), regression risks, existing and missing validation, and confidence (high, medium, low).

## 3. Verify and merge

Read the cited lines of every finding yourself. Reject a finding that is vague, duplicates another, misreads intended behavior or only moves complexity; narrow or demote one that overreaches. Each accepted finding gets one ID (`F1`, `F2`, ...) and one owning subsystem. A skip counts as reviewed.

Then check the whole audit. With 3 or more findings, give this to one fresh Explore subagent with the draft report; otherwise check it yourself:

- **Coverage:** every tracked source path from `git ls-files` sits in a boundary. A gap gets a new row, reviewed in this run. Never widen a finished boundary to hide it.
- **Overlap:** no two findings fix the same thing; no two boundaries share a path.
- **Materiality:** no finding is an abstraction for its own sake.
- **Completeness:** every finding has every field from the brief.
- **Order:** rank by concrete impact, confidence, implementation effort, blast radius and prerequisites; a finding that depends on another ranks after it.

## 4. Write the report

Get `<timestamp>` from `date +%Y-%m-%d-%H%M`, create `docs/agents/reports/` if missing and write the report in this shape:

```markdown
# Architecture audit

- Date: <YYYY-MM-DD>
- Commit: <full HEAD sha>
- Scope: <whole repo, or the path>

## Subsystems

| ID | Subsystem | Boundary | Status | Findings |

## Findings

### F<n> (P<tier>, S<n>): <title>

- Evidence, Current, Proposed, Scope, Risks, Validation, Confidence

## Skips

## Priority synthesis

## Audit log
```

Status is `recommend` or `skip`. Tiers:

- **P0:** correctness, security or data-loss risk: wrong record, lost update, authorization, durable state, an operation that can stay incomplete.
- **P1:** concrete boundary failures and high-leverage ownership fixes with less immediate damage or a larger migration.
- **P2:** invariant improvements with narrower impact or a sensitive migration.
- **P3:** diagnostics and maintainability. Expect few.

The priority synthesis gives the number of unique findings, lists each ID exactly once by tier and names the best first slice. The audit log notes each decision taken without asking, such as a rejected or demoted finding and why.

The audit is done only when:

- every subsystem has a recommendation or an explicit skip
- every finding has every field from the brief
- duplicates and weak abstractions are gone
- priorities and dependencies agree
- `git status --porcelain` matches the start of the run, apart from the new report

Reply with the report path, how many subsystems were reviewed and skipped, and one line per P0 and P1 finding. Ask nothing.
