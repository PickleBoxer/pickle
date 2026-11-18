---
name: why
description: Finds why code is shaped the way it is, from git history, PRs, issues, docs and any MCP sources in the session, as a cited answer that marks inferences. Use for "why does X work this way", "why did we pick Y", regressions, postmortems and where a threshold came from.
argument-hint: "[code, decision or question]"
metadata:
  upstream: pstack/skills/why
  upstream-version: 0.15.43
---

# Why

Answer from the record, not the code: read the commits and PR discussions that introduced the target and each later change, and other sources if the trail is thin. Cite what the authors wrote, mark your own inferences as inferences, and say what the record does not answer. For what the code does and how it runs, use the **how** skill (Skill tool, `pickle:how`).

Start from the history:

```bash
git blame -L <start>,<end> <file>          # last-touch commits
git log --follow -p -- <file>              # full history through renames
git log -1 --format=%B <commit>            # PR number from a merge commit
gh pr view <number> --json title,body,comments,reviews,closingIssuesReferences
```

When the trail is thin, look for MCP servers in this session (issue tracker, docs, team chat, error tracking, observability). Their tools start with `mcp__<server>__` and most load through ToolSearch. End with one line per source you checked or skipped, and why. If the question comes before a change to this code, also give the findings as constraints for it: Preserve, Change, Avoid, Risk.

Avoid three traps. The latest commit is not the whole story, so trace back. A guess in the question is one candidate, so check it like any other. What the code does is not why it exists.

If the project has a `GLOSSARY.md` (or a `GLOSSARY-MAP.md`), use its terms for domain concepts.
