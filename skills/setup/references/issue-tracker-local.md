# Issue tracker: Local Markdown

Issues for this repo live as markdown files in `.scratch/`, in the same feature folders as the intent, spec and plan for that work.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- Specs are not issues: `/pickle:spec` writes them to `.scratch/<feature-slug>/SPEC.md`
- Implementation issues are one file per ticket at `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`, never a single combined tickets file
- State is recorded as a `Status:` line near the top of each issue file (`open`, `in-progress`, `done`)
- Comments and conversation history append to the bottom of the file under a `## Comments` heading

Plans and task lists from `pickle:planning-and-task-breakdown` stay in `plan.md` and `todo.md` in the feature folder, where `/pickle:build` reads them. `issues/` holds issues only when a skill or the user publishes one.

## When a skill says "publish to the issue tracker"

Create a new file under `.scratch/<feature-slug>/` (creating the directory if needed).

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.
