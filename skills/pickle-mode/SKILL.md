---
name: pickle-mode
description: Runs a task through pickle's workflow skills, from spec and planning to review and shipping. Maps the task to the skills that fit and sets the operating rules they share.
disable-model-invocation: true
metadata:
  upstream: agent-skills/skills/using-agent-skills
  upstream-version: 0.6.13
---

# pickle-mode

Run the task through pickle's workflow skills. Each skill encodes a process senior engineers follow for one phase of work.

## Procedure

1. Read the task: the `ARGUMENTS` line at the end of this skill.
2. Find its phases in the router below. Tell the user which skills you will use, in order.
3. Load the first skill with the Skill tool, using the name exactly as written. Load each next skill when its phase starts. Don't work from memory of what a skill says.
4. Follow each skill's steps in order. Skills are workflows, not suggestions: don't skip verification steps.

## Router

Start at the first phase the task needs and work down. Skip the phases it doesn't need.

1. **Define**
   - Don't know what you want yet: the **interview-me** skill (Skill tool, `pickle:interview-me`)
   - Rough concept, need variants: the **idea-refine** skill (Skill tool, `pickle:idea-refine`)
   - New project, feature or change: the **spec-driven-development** skill (Skill tool, `pickle:spec-driven-development`)
   - No quality bar written down: the **constraint-driven-development** skill (Skill tool, `pickle:constraint-driven-development`)
2. **Plan**
   - Have a spec, need tasks: the **planning-and-task-breakdown** skill (Skill tool, `pickle:planning-and-task-breakdown`)
3. **Build**
   - Need better context: the **context-engineering** skill (Skill tool, `pickle:context-engineering`)
   - Need doc-verified code: the **source-driven-development** skill (Skill tool, `pickle:source-driven-development`)
   - Implementing code: the **incremental-implementation** skill (Skill tool, `pickle:incremental-implementation`), and alongside it when they apply:
     - UI work: the **frontend-ui-engineering** skill (Skill tool, `pickle:frontend-ui-engineering`)
     - API work: the **api-and-interface-design** skill (Skill tool, `pickle:api-and-interface-design`)
     - Logs, metrics, alerts: the **observability-and-instrumentation** skill (Skill tool, `pickle:observability-and-instrumentation`), during the build, not after
     - Stakes high or code unfamiliar: the **doubt-driven-development** skill (Skill tool, `pickle:doubt-driven-development`), per decision, in flight
4. **Verify**
   - Writing or running tests: the **test-driven-development** skill (Skill tool, `pickle:test-driven-development`)
     - Browser-based: the **browser-testing-with-devtools** skill (Skill tool, `pickle:browser-testing-with-devtools`)
   - Something broke: the **debugging-and-error-recovery** skill (Skill tool, `pickle:debugging-and-error-recovery`)
5. **Review**
   - Reviewing code: the **code-review-and-quality** skill (Skill tool, `pickle:code-review-and-quality`), plus when needed:
     - Too complex: the **code-simplification** skill (Skill tool, `pickle:code-simplification`)
     - Security concerns: the **security-and-hardening** skill (Skill tool, `pickle:security-and-hardening`)
     - Performance concerns: the **performance-optimization** skill (Skill tool, `pickle:performance-optimization`)
6. **Ship**
   - Committing or branching: the **git-workflow-and-versioning** skill (Skill tool, `pickle:git-workflow-and-versioning`)
   - Writing docs or ADRs: the **documentation-and-adrs** skill (Skill tool, `pickle:documentation-and-adrs`)
   - Deprecating or migrating: the **deprecation-and-migration** skill (Skill tool, `pickle:deprecation-and-migration`)
   - CI/CD pipeline work: the **ci-cd-and-automation** skill (Skill tool, `pickle:ci-cd-and-automation`)
   - Deploying or launching: the **shipping-and-launch** skill (Skill tool, `pickle:shipping-and-launch`)

A bug fix skips most phases: the **debugging-and-error-recovery** skill (Skill tool, `pickle:debugging-and-error-recovery`) → the **test-driven-development** skill (Skill tool, `pickle:test-driven-development`) → the **code-review-and-quality** skill (Skill tool, `pickle:code-review-and-quality`).
When the task is non-trivial and there's no spec, start with the **spec-driven-development** skill (Skill tool, `pickle:spec-driven-development`).

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
