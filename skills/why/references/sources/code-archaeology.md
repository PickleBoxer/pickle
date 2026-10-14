# Source control (git and gh)

The source closest to the code, and always available: commits, PR descriptions and reviews, code comments, tests, ADRs, changelogs, ticket IDs in messages.

## Search

```bash
git log --follow --oneline -- <file>          # history through renames
git log -S '<exact string>' -- <file>          # commits that added or removed the text
git log -G '<regex>' -- <file>
git blame -L <start>,<end> <file>
git show <sha>
gh pr view <n> --json title,body,author,mergedAt,comments,reviews,closingIssuesReferences
```

Then look outside the history:

- ADRs and design notes: Grep `*.md` for "decision", "ADR", "rationale".
- `TODO`, `FIXME`, `HACK`, `NOTE` near the target.
- Tests that name the symbol: their names and inputs often encode the edge case behind a change.
- Files changed in the same commits as the target.
- CHANGELOG entries and release notes.

## Pitfalls

- A squash merge hides the branch's commits. Read the PR instead.
- A revert followed by a re-apply is a story: read both commits and the PR between them.
- A mass reformat or rename resets `git blame`. Use `git log -S` or `blame` with `-w -C` to see past it.
