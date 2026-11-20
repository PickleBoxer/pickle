---
name: prune-comments
description: Classify every code comment in a codebase or path as Tautology, Excuse, Stale or Decision Record, then act on each class. Delete the first three, file an issue for each Excuse, move architecture decisions to ADRs and keep local reasons. Then hold the remaining count with a ratchet in CI and report the lines removed. Asks once, before deleting anything. Not a line-level cleanup (/pickle:code-simplify).
argument-hint: "[path to limit the run]"
disable-model-invocation: true
---

# Prune Comments

Delete the comments that add nothing or hide a shortcut, keep the ones that carry a reason, and stop new ones from piling up.

Direction from the user: $ARGUMENTS

## Rules

- **One question, before any edit.** Classify everything first, show the result and wait for a yes. Ask nothing else unless something fails.
- **Only comments change.** No code edits, no reformatting. After deleting, the tests must pass as before.
- **Nothing outside the repo without a yes.** Excuses go to local issue files. File them in the tracker only after the user approves the list.
- **No git command that changes history or the index** (commit, add, checkout, stash, reset). The user reviews and commits.
- **Direction.** A path limits the run to files under it. Without one, the run covers the whole repo.

## What is not a comment here

Never classify or delete these. They are code in comment syntax, and the ratchet script skips them too:

- Tool directives: `eslint-disable`, `@ts-expect-error`, `@phpstan-ignore`, `# noqa`, `# type: ignore`, `//go:build`, `prettier-ignore` and similar.
- Docblocks and doc comments (`/** */`, `///`, `//!`, Python docstrings). They document a public API or carry types, as in JSDoc or PHPDoc generics.
- License headers, shebangs, encoding lines and markers in generated files.
- Vendored and generated code.

## 1. Inventory

```bash
git status --porcelain
bash "${CLAUDE_SKILL_DIR}/scripts/comment-ratchet.sh" count <path>
```

If the tree has uncommitted changes, say so: deletions mixed into other work are hard to review. Keep the total from `count`. It is the "before" number for the report. The script counts whole-line comments only. Read trailing comments (`x = 1 // ...`) while classifying, but they are not in the total.

Split the counted files into groups of one directory or subsystem each, about 150 comments at most per group.

## 2. Classify

Give each comment exactly one class. Check the classes in this order and take the first that fits:

| Class | It fits when the comment | Action |
|---|---|---|
| **Stale** | names a function, file, flag, ticket or behavior that is gone or changed, or is commented-out code | delete |
| **Excuse** | admits a shortcut: `TODO`, `FIXME`, `HACK`, `XXX`, "for now", "temporary", "workaround", "should be", "not sure why but" | delete and file an issue |
| **Tautology** | says what the next lines already say (`// increment count`, `// constructor`, `// loop over users`) | delete |
| **Decision Record** | gives a reason the code cannot show, and the reason is still true | ADR or keep (below) |

A Decision Record goes one of two ways:

- **ADR:** the decision is hard to reverse, would surprise a future reader and came from a real trade-off. These are the tests from the **documentation-and-adrs** skill (Skill tool, `pickle:documentation-and-adrs`). It writes the ADR, and the comment is deleted.
- **Keep:** a local reason about these lines only, such as "retry twice because the API drops the first request after idle". It stays where it is, and the ratchet counts it.

When unsure between Tautology and Decision Record, keep the comment. A lost reason costs more than a spare line. Before you call a comment Stale, prove it: grep for the symbol, file or flag it names.

With one group, classify it yourself. With more, spawn one Explore subagent per group (Agent tool, `subagent_type: Explore`), up to 12 in one message, and start the next batch when one returns. Each brief carries the group's files, the table and the two Decision Record rules above, the "not a comment" list, and this text:

> Read every comment in these files with the code around it. Return one row per comment: file:line, the comment's first line, class, and a one-line reason. For Stale, add the proof (what is gone, from a grep). For Excuse, add an issue title and the proper fix in one sentence. For Decision Record, add ADR or keep. Change nothing.

Read the cited lines of every Stale, Excuse and ADR row yourself, and a sample of the Tautologies. Fix the rows you disagree with.

## 3. Confirm

Write the run's folder, `.scratch/prune-comments-<YYYY-MM-DD>/README.md` (layout in `${CLAUDE_PLUGIN_ROOT}/references/scratch-folder.md`). It holds the scope, the "before" total, the counts per class and the full table. Then show the user:

- counts per class, and the lines the deletions remove
- every Excuse with its issue title
- every ADR with its proposed title
- the ratchet change: the files it adds and where `check` will run (step 5)

Ask once whether to go ahead. The user may move rows between classes or narrow the scope. The ratchet holds whatever is left, so a later run can take the rest.

## 4. Apply

1. **Excuses.** Write one file per Excuse to `.scratch/prune-comments-<date>/issues/NN-<slug>.md`, with a `Status: open` line, the comment text, the enclosing function or class (line numbers move once comments go), and the proper fix. Then list the titles and ask whether to file them in the project's tracker (`docs/agents/issue-tracker.md` names it, if it exists). File them only on a yes.
2. **ADRs.** Run the **documentation-and-adrs** skill once with every ADR row. It finds the project's ADR folder and numbering.
3. **Delete** the Stale, Excuse, Tautology and ADR comments with Edit. Remove only the comment lines. Where a deletion leaves two blank lines in a row, remove one.
4. **Verify.** Run the project's tests and linters. A failure means a deleted line was not just a comment: restore it and mark it as not a comment in the README.

## 5. Ratchet

The ratchet bans new comments without forcing out the old ones. Every file keeps a count that may go down and never up.

- **First run** (no `.comment-baseline` in the repo):
  1. Copy the script into the project, at `scripts/comment-ratchet.sh`, unless a file of that name exists.
  2. Run `bash scripts/comment-ratchet.sh init <path>`.
  3. Add `bash scripts/comment-ratchet.sh check` to CI, next to the lint step, and to the project's local lint command (`package.json` script, `composer.json` script or `Makefile`).
- **Later runs:** `bash scripts/comment-ratchet.sh tighten`.
- **Paths to skip** (fixtures, generated code the defaults miss): add a regex per line to `.comment-ratchet-ignore`.
- **`CONSTRAINTS.md`:** if it exists, add or update a row under "Enforced with numbers": `| Comments | No file gains comment lines | bash scripts/comment-ratchet.sh check | CI |`.

To keep a new comment on purpose, raise that file's count in `.comment-baseline` in the same change. The diff shows it to the reviewer.

## 6. Report

```bash
bash scripts/comment-ratchet.sh count <path>
git diff --shortstat
```

Update the run's README with the results, then reply with:

- **Removed:** comment lines before and after (from `count`), and lines removed in total (from `--shortstat`). Both are measured.
- **Left:** the comments that remain. Deleting all of them would shed at most that many lines. Mark it an estimate: the count skips trailing comments, and the kept Decision Records are meant to stay.
- counts per class, the ADRs written, the issue files and whether they were filed
- the ratchet files added or changed, and the test and lint results
- the path of the run's README
