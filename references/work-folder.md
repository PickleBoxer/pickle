# Work folder

Big work gets a folder: `docs/work/<slug>/`. Small, clear work stays in `tasks/plan.md` and `tasks/todo.md`; a project-wide spec stays in the root `SPEC.md`.

Create one when spec work has any of: several tickets, an outside party, an unknown to probe (an API contract), files from outside, or many sessions. If a plan in `tasks/` grows that way, propose moving it in with `git mv`.

Slug: the tracker key plus title, kebab-case (`ship-3398-inmac-eu-order-api`), or a short name.

Start with `SPEC.md`. Add the rest only when the work needs it:

```
README.md     hub: source issue line, what we have, decisions so far, tickets, files
SPEC.md       spec-driven-development
plan.md       planning-and-task-breakdown, once the spec settles
todo.md       task list, when there is no tracker
issues/       this work's tickets when there is no tracker, NN-<slug>.md with a Status: line; with a tracker, the README links them
research/     findings and spike results, NN-<topic>.md
fixtures/, captures/, scripts/, vendor-docs/   inputs, raw outputs, probes, files from outside
```

Credentials (`.env`, keys) stay local: check they are gitignored before writing them.

Finding active work: the slug the user named; else `tasks/` if it has unchecked tasks; else the one folder whose `todo.md` or `issues/` has open items; several: ask.

Archive: move a finished or paused plan, from `tasks/` or a work folder, to `docs/work/archive/<date>-<slug>/` with `git mv`, `<date>` from `date +%Y-%m-%d`. Never read `docs/work/archive/` as active work.
