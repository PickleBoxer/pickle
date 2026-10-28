# pickle

A Claude Code plugin that runs a coding task through agent-skills' workflow skills, starting from one entry skill.

## Process

**pickle-mode**:
The skill a user starts to run a task through pickle. It is agent-skills' `using-agent-skills`, renamed and user-only: it maps the task to workflow skills and sets the operating rules they share.
_Avoid_: work, entry point

**Workflow skill**:
A skill from agent-skills that holds the steps for one phase of work, such as spec, implementation, debugging or review. pickle-mode picks the ones that fit the task.
_Avoid_: playbook, mode, recipe

**Language skill**:
A skill with default idioms for one language or framework: pickle's own (typescript-best-practices) or a third-party one the user installs. The project's own rules win over it.
_Avoid_: language pack, rules pack

**Investigation skill**:
A skill that explains code before a change: how (what it does and how it runs), why (the reasons it is shaped that way) or blast-radius (what a change breaks outside its diff). From pstack.
_Avoid_: research skill, archaeology

**Source guide**:
A file in why's `references/sources/` with search steps for one evidence category, such as the issue tracker or team chat.
_Avoid_: playbook

**Extension**:
A skill that workflow skills call to go deeper on one concern: codebase-design (module shape) or domain-modeling (the domain glossary). Hidden from the `/` menu, and calls no skill itself. From Matt Pocock's skills.
_Avoid_: base skill, add-on, helper skill

**Domain glossary**:
A project's own `GLOSSARY.md` (or one per context, listed in `GLOSSARY-MAP.md`), kept by domain-modeling. Not pickle's GLOSSARY.md.
_Avoid_: context file, dictionary

**Writing skill**:
A skill with rules for prose: technical-writing (document structure and sentences) or unslop (AI writing patterns). From pstack.
_Avoid_: style guide, prose pack

**Scheduled report**:
A user-only skill run on a schedule in its no-questions form, such as improve-codebase-architecture with `report only`, or audit-architecture. It writes a report and changes no code. Set up as a local routine in Claude Code Desktop.
_Avoid_: cron skill, background job

**Review lane**:
One extra check a project adds to code review, listed in its `docs/agents/review.md`: a skill or agent run as a subagent on the changed files of one type. Written by setup, run by code-review-and-quality.
_Avoid_: review pass, reviewer plugin

**Feature folder**:
The folder `.scratch/<feature-slug>/` that holds one piece of work's intent, idea, spec, plan, task list and local issues, committed as its history. Layout in `references/feature-folder.md`.
_Avoid_: task folder, work dir, scratch pad

## Evals

**Loading eval**:
An eval that checks only which workflow skills pickle-mode invoked for a task. No code changes.
_Avoid_: routing eval

**Firing eval**:
An eval that checks whether a workflow skill fires on its own description, without pickle-mode, and what it adds to the reply. Scored with and without pickle.
_Avoid_: trigger eval

**Case**:
One task in the eval suite, with its prompt, fixture and graders.
_Avoid_: test, scenario

**Fixture**:
The small purpose-built project a case runs in.
_Avoid_: sandbox, test repo

**Dry run**:
A loading eval run where the agent stops right after invoking the workflow skills.
_Avoid_: plan-only run

**Outcome eval**:
An eval that checks whether the change itself is correct. Planned.
_Avoid_: correctness test

**Token eval**:
An eval that compares cost and token use with and without pickle. Planned.
_Avoid_: cost test
