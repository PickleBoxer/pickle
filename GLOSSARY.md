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

## Evals

**Loading eval**:
An eval that checks only which workflow skills pickle-mode invoked for a task. No code changes. Planned.
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
