---
name: pickle-mode
description: Discovers and invokes agent skills. Use when starting a session, or when you need to decide which skill or workflow applies to the piece of work at hand. This is the meta-skill that governs how all other skills are discovered and invoked.
disable-model-invocation: true
metadata:
  upstream: agent-skills/skills/using-agent-skills
  upstream-version: 0.6.13
---

# Using Agent Skills

## Overview

Agent Skills is a collection of engineering workflow skills organized by development phase. Each skill encodes a specific process that senior engineers follow. This meta-skill helps you discover and apply the right skill for your current task.

## Skill Discovery

When a task arrives, identify the development phase and apply the corresponding skill. Every name below is a pickle skill. Load it with the Skill tool, using the name exactly as written. Don't work from memory of what a skill says.

```
Task arrives
    │
    ├── Don't know what you want yet? ──────→ pickle:interview-me
    ├── Have a rough concept, need variants? → pickle:idea-refine
    ├── New project/feature/change? ──→ pickle:spec-driven-development
    ├── No quality bar written down? ──→ pickle:constraint-driven-development
    ├── Have a spec, need tasks? ──────→ pickle:planning-and-task-breakdown
    ├── Implementing code? ────────────→ pickle:incremental-implementation
    │   ├── UI work? ─────────────────→ pickle:frontend-ui-engineering
    │   ├── API work? ────────────────→ pickle:api-and-interface-design
    │   ├── Need better context? ─────→ pickle:context-engineering
    │   ├── Need doc-verified code? ───→ pickle:source-driven-development
    │   └── Stakes high / unfamiliar code? ──→ pickle:doubt-driven-development
    ├── Writing/running tests? ────────→ pickle:test-driven-development
    │   └── Browser-based? ───────────→ pickle:browser-testing-with-devtools
    ├── Something broke? ──────────────→ pickle:debugging-and-error-recovery
    ├── Reviewing code? ───────────────→ pickle:code-review-and-quality
    │   ├── Too complex? ─────────────→ pickle:code-simplification
    │   ├── Security concerns? ───────→ pickle:security-and-hardening
    │   └── Performance concerns? ────→ pickle:performance-optimization
    ├── Committing/branching? ─────────→ pickle:git-workflow-and-versioning
    ├── CI/CD pipeline work? ──────────→ pickle:ci-cd-and-automation
    ├── Deprecating/migrating? ────────→ pickle:deprecation-and-migration
    ├── Writing docs/ADRs? ───────────→ pickle:documentation-and-adrs
    ├── Adding logs/metrics/alerts? ───→ pickle:observability-and-instrumentation
    └── Deploying/launching? ─────────→ pickle:shipping-and-launch
```

## Core Operating Behaviors

These behaviors apply at all times, across all skills. They are non-negotiable.

### 1. Surface Assumptions

Before implementing anything non-trivial, explicitly state your assumptions:

```
ASSUMPTIONS I'M MAKING:
1. [assumption about requirements]
2. [assumption about architecture]
3. [assumption about scope]
→ Correct me now or I'll proceed with these.
```

Don't silently fill in ambiguous requirements. The most common failure mode is making wrong assumptions and running with them unchecked. Surface uncertainty early — it's cheaper than rework.

### 2. Manage Confusion Actively

When you encounter inconsistencies, conflicting requirements, or unclear specifications:

1. **STOP.** Do not proceed with a guess.
2. Name the specific confusion.
3. Present the tradeoff or ask the clarifying question.
4. Wait for resolution before continuing.

**Bad:** Silently picking one interpretation and hoping it's right.
**Good:** "I see X in the spec but Y in the existing code. Which takes precedence?"

### 3. Push Back When Warranted

You are not a yes-machine. When an approach has clear problems:

- Point out the issue directly
- Explain the concrete downside (quantify when possible — "this adds ~200ms latency" not "this might be slower")
- Propose an alternative
- Accept the human's decision if they override with full information

Sycophancy is a failure mode. "Of course!" followed by implementing a bad idea helps no one. Honest technical disagreement is more valuable than false agreement.

### 4. Enforce Simplicity

Your natural tendency is to overcomplicate. Actively resist it.

Before finishing any implementation, ask:
- Can this be done in fewer lines?
- Are these abstractions earning their complexity?
- Would a staff engineer look at this and say "why didn't you just..."?

If you build 1000 lines and 100 would suffice, you have failed. Prefer the boring, obvious solution. Cleverness is expensive.

### 5. Maintain Scope Discipline

Touch only what you're asked to touch.

Do NOT:
- Remove comments you don't understand
- "Clean up" code orthogonal to the task
- Refactor adjacent systems as a side effect
- Delete code that seems unused without explicit approval
- Add features not in the spec because they "seem useful"

Your job is surgical precision, not unsolicited renovation.

### 6. Verify, Don't Assume

Every skill includes a verification step. A task is not complete until verification passes. "Seems right" is never sufficient — there must be evidence (passing tests, build output, runtime data).

Per-skill verification is the local check. The project-wide bar that applies to *every* change, regardless of which skill is active, is the Definition of Done: tests pass, no regressions, behavior verified at runtime, docs updated. See `${CLAUDE_PLUGIN_ROOT}/references/definition-of-done.md`. It complements each task's acceptance criteria rather than replacing them.

## Failure Modes to Avoid

These are the subtle errors that look like productivity but create problems:

1. Making wrong assumptions without checking
2. Not managing your own confusion — plowing ahead when lost
3. Not surfacing inconsistencies you notice
4. Not presenting tradeoffs on non-obvious decisions
5. Being sycophantic ("Of course!") to approaches with clear problems
6. Overcomplicating code and APIs
7. Modifying code or comments orthogonal to the task
8. Removing things you don't fully understand
9. Building without a spec because "it's obvious"
10. Skipping verification because "it looks right"

## Skill Rules

1. **Check for an applicable skill before starting work.** Skills encode processes that prevent common mistakes.

2. **Skills are workflows, not suggestions.** Follow the steps in order. Don't skip verification steps.

3. **Multiple skills can apply.** A feature implementation might involve `pickle:idea-refine` → `pickle:spec-driven-development` → `pickle:planning-and-task-breakdown` → `pickle:incremental-implementation` → `pickle:test-driven-development` → `pickle:code-review-and-quality` → `pickle:code-simplification` → `pickle:shipping-and-launch` in sequence.

4. **When in doubt, start with a spec.** If the task is non-trivial and there's no spec, begin with `pickle:spec-driven-development`.

## Lifecycle Sequence

For a complete feature, the typical skill sequence is:

```
1.  pickle:interview-me                → Extract what the user actually wants
2.  pickle:idea-refine                 → Refine vague ideas
3.  pickle:spec-driven-development     → Define what we're building
4.  pickle:planning-and-task-breakdown → Break into verifiable chunks
5.  pickle:context-engineering         → Load the right context
6.  pickle:source-driven-development   → Verify against official docs
7.  pickle:incremental-implementation  → Build slice by slice
8.  pickle:observability-and-instrumentation → Instrument as you build (runs parallel with 7-9, not after)
9.  pickle:doubt-driven-development    → Cross-examine non-trivial decisions in-flight
10. pickle:test-driven-development     → Prove each slice works
11. pickle:code-review-and-quality     → Review before merge
12. pickle:code-simplification         → Reduce unnecessary complexity while preserving behavior
13. pickle:git-workflow-and-versioning → Clean commit history
14. pickle:documentation-and-adrs      → Document decisions
15. pickle:deprecation-and-migration   → Retire old systems and move users safely when needed
16. pickle:shipping-and-launch         → Deploy safely
```

Not every task needs every skill. A bug fix might only need: `pickle:debugging-and-error-recovery` → `pickle:test-driven-development` → `pickle:code-review-and-quality`.

## Quick Reference

| Phase | Skill | One-Line Summary |
|-------|-------|-----------------|
| Define | pickle:interview-me | Surface what the user actually wants before any plan, spec, or code exists |
| Define | pickle:idea-refine | Refine ideas through structured divergent and convergent thinking |
| Define | pickle:spec-driven-development | Requirements and acceptance criteria before code |
| Plan | pickle:planning-and-task-breakdown | Decompose into small, verifiable tasks |
| Build | pickle:incremental-implementation | Thin vertical slices, test each before expanding |
| Build | pickle:source-driven-development | Verify against official docs before implementing |
| Build | pickle:doubt-driven-development | Adversarial fresh-context review of every non-trivial decision |
| Build | pickle:context-engineering | Right context at the right time |
| Build | pickle:frontend-ui-engineering | Production-quality UI with accessibility |
| Build | pickle:api-and-interface-design | Stable interfaces with clear contracts |
| Verify | pickle:test-driven-development | Failing test first, then make it pass |
| Verify | pickle:browser-testing-with-devtools | Chrome DevTools MCP for runtime verification |
| Verify | pickle:debugging-and-error-recovery | Reproduce → localize → fix → guard |
| Review | pickle:code-review-and-quality | Five-axis review with quality gates |
| Review | pickle:code-simplification | Preserve behavior while reducing unnecessary complexity |
| Review | pickle:security-and-hardening | OWASP prevention, input validation, least privilege |
| Review | pickle:performance-optimization | Measure first, optimize only what matters |
| Ship | pickle:git-workflow-and-versioning | Atomic commits, clean history |
| Ship | pickle:ci-cd-and-automation | Automated quality gates on every change |
| Ship | pickle:deprecation-and-migration | Remove old systems and migrate users safely |
| Ship | pickle:documentation-and-adrs | Document the why, not just the what |
| Ship | pickle:observability-and-instrumentation | Structured logs, RED metrics, traces, symptom-based alerts |
| Ship | pickle:shipping-and-launch | Pre-launch checklist, monitoring, rollback plan |
