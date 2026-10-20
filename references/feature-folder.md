# Feature folder

Working files for one piece of work live together in `.scratch/<feature-slug>/` at the repo root. File names keep the case upstream gave them: `SPEC.md` and `PERF.md` uppercase, the rest lowercase. Commit them with the work: the folder is the handoff between sessions, and finished folders stay as history.

```
.scratch/<feature-slug>/
  intent.md       interview-me: confirmed statement of intent
  idea.md         idea-refine: the one-pager
  SPEC.md         spec-driven-development (module specs: SPEC-<module>.md)
  plan.md         planning-and-task-breakdown: plan document
  todo.md         planning-and-task-breakdown: task list, when no external tracker
  PERF.md         performance-optimization: experiment log
  issues/NN-*.md  local markdown issue tracker (docs/agents/issue-tracker.md)
.scratch/reports/ improve-codebase-architecture reports, not a feature
```

## Slug

- Work from a tracker issue (Linear, Jira, GitHub, GitLab): the issue key plus its title, kebab-case: `ENG-123-csv-export`, `gh-42-fix-login-redirect`.
- Otherwise: a short kebab-case name for the work, `csv-export`.
- One slug per piece of work. Every skill in the chain reuses the folder the first one created; don't start a second folder for the same work.
- Confirm the slug with the user when you create the folder.
- When a tracker issue is opened later for work that already has a folder, rename it to the issue's slug with `git mv` and tell the user.

## Finding the current folder

1. The user named a slug or a path: use it.
2. Otherwise, the folders whose `todo.md` has unchecked items (`grep -l '^- \[ \]' .scratch/*/todo.md`), or whose `plan.md` names an external tracker with open items. One match: use it. Several: list them and ask.
3. None: ask for a slug, or create a new folder when the skill starts new work.

## Never overwrite

Before writing a file that exists in the folder, read it. Revising the same work updates it in place. Anything else: stop and ask.
