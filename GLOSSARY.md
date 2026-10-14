# pickle

A Claude Code plugin that runs a coding task through a fixed engineering process, loading only the playbooks and principles the task needs.

## Process

**pickle-mode**:
The skill a user starts to run a task through pickle. Starting it means the full process: there is no lighter level.
_Avoid_: router, work, entry point

**Playbook**:
A step-by-step procedure for one kind of task, such as a feature, a bug fix or a refactor. The agent picks the playbooks that fit the task and reads only those.
_Avoid_: workflow, mode, recipe

**Core playbook**:
A playbook rewritten for pickle and held to its loading eval.
_Avoid_: main playbook

**Extended playbook**:
A playbook ported from pstack and marked experimental.
_Avoid_: optional playbook, extra playbook

**Playbook index**:
The list in pickle-mode of every playbook with one line on when it applies.
_Avoid_: menu, routing table

**Non-negotiable**:
A rule in pickle-mode that applies to every task, whatever the playbook.
_Avoid_: global rule, always-on rule

**Gate**:
An action the project owner has marked as stop-and-ask, such as a deploy or a migration on a shared database.
_Avoid_: checkpoint, approval step

**Loaded line**:
The last line of a pickle reply, naming the playbooks and principles used for the task.
_Avoid_: load report, footer

## Principles

**Principle**:
A language-agnostic engineering rule with a trigger, read only when a task reaches that trigger. Principles exist only inside pickle-mode.
_Avoid_: rule, guideline, best practice

**Trigger**:
The situation that makes a principle apply, such as debugging or writing a test.
_Avoid_: condition, when-clause

**Principle index**:
The list in pickle-mode of every principle with its trigger.
_Avoid_: principle list, catalogue

**Mention**:
A principle named inline in a playbook step or a non-negotiable, at the point where it applies. A mention is what prompts the agent to load the principle.
_Avoid_: reference, link

**Convention**:
A rule for how one project writes code: its language idioms, frameworks, tools and traps. A skill name or a file path in the project, listed in the profile and read before work starts. Conventions win over pickle's defaults.
_Avoid_: pack, style guide, language skill

## Project

**Profile**:
A short description of one project for pickle: its stack, conventions, verify commands and gates.
_Avoid_: config, settings, project file

**Verify command**:
A command from the profile that checks the work, named by its purpose (test, types, lint, UI) rather than by tool.
_Avoid_: check, CI step

**Setup**:
The pickle step that detects a project's stack and writes its profile.
_Avoid_: init, onboarding

## Tools and roles

**Tool**:
A pickle skill that runs one stage of the process in its own subagent: explore, design options or review.
_Avoid_: helper, sub-skill

**Opt-in tool**:
A heavy tool that runs only when the user names it: bakeoff or adversarial review.
_Avoid_: advanced tool

**Explorer**, **Implementer**, **Reviewer**:
The three subagent roles pickle delegates to. The explorer reads, the implementer changes code, the reviewer judges the result.

**Sign-off**:
The user approving an architect sketch before implementation starts. Opt-in: only when the task asks for it.
_Avoid_: checkpoint, approval step

**Panel**:
An interrogate run with two reviewers, each on its own lens (correctness, design) and model tier. Opt-in: only when the arguments name it.
_Avoid_: multi-model review

**Lead**:
The read-only subagent a tool runs as. It picks the angles, starts explorers or reviewers, and writes the one answer the tool returns.
_Avoid_: orchestrator, coordinator
_Avoid_: worker, helper agent

## Evals

**Loading eval**:
An eval that checks only which playbooks the agent read and which principles it loaded for a task. No code changes.
_Avoid_: routing eval

**Case**:
One task in the eval suite, with its prompt, fixture and graders.
_Avoid_: test, scenario

**Fixture**:
The small purpose-built project a case runs in.
_Avoid_: sandbox, test repo

**Dry run**:
A loading eval run where the agent stops right after loading principles.
_Avoid_: plan-only run

**Smoke set**:
The three core cases (feature, bug fix, refactor) used for quick, cheap checks.
_Avoid_: quick suite

**Ambiguous case**:
A case where two playbooks fit, so either is accepted and only clearly wrong ones fail.
_Avoid_: edge case

**Outcome eval**:
An eval that checks whether the change itself is correct. Planned after loading evals.
_Avoid_: correctness test

**Token eval**:
An eval that compares cost and token use with and without pickle. Planned after outcome evals.
_Avoid_: cost test

## Not pickle terms

**Effort level**:
Not a pickle concept: invoking pickle always means the full process. Claude Code's effort setting is separate. pickle sets it only per subagent role, in each agent's frontmatter, and never changes the session's effort.
_Avoid_: low, medium, high as pickle levels
