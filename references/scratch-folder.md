# Scratch folder

Active work lives where upstream puts it: the spec in the root `SPEC.md` (and `SPEC-<change>.md`), the plan in `tasks/plan.md` and `tasks/todo.md`. `.scratch/<slug>/` holds two things: big work's extra files, and plans parked to make room for other work.

Give big work a folder when it has any of: several tickets, an outside party, an unknown to probe (an API contract), files from outside, or many sessions.

Slug: the tracker key plus title, kebab-case (`ship-3398-inmac-eu-order-api`), or a short name.

Add only what the work needs:

```
README.md     hub: source issue line, status (active, parked, done), decisions so far, tickets, files
SPEC.md       the spec, once parked
plan.md       the plan, once parked
todo.md       the task list, once parked
issues/       this work's tickets when there is no tracker, NN-<slug>.md with a Status: line; with a tracker, the README links them
research/     findings and spike results, NN-<topic>.md
fixtures/, captures/, scripts/, vendor-docs/   inputs, raw outputs, probes, files from outside
```

Credentials (`.env`, keys) stay local: check they are gitignored before writing them. `.scratch/` itself is committed: it is the record of parked and finished work.

Park: `git mv SPEC.md .scratch/<slug>/SPEC.md`, and the same for `tasks/plan.md` and `tasks/todo.md` (and any `SPEC-<change>.md`), then set the README's status to `parked`, or `done` for finished work.

Resume: `/pickle:build <slug>` (or `/pickle:build auto <slug>`) runs the plan in place, reading `SPEC.md`, `plan.md` and `todo.md` from `.scratch/<slug>/`. To make it the active work again, `git mv` the files back to the root and `tasks/`.
