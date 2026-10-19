---
name: setup
description: Configure this repo for pickle's skills: where issues are tracked and where the glossary and ADRs live. Run once per repo.
disable-model-invocation: true
metadata:
  upstream: mattpocock-skills/skills/engineering/setup-matt-pocock-skills
  upstream-version: 1.3.1
---

# Setup

Write the per-repo configuration pickle's skills read:

- **Issue tracker**: where issues live (GitHub, GitLab, local markdown, or a workflow the user describes)
- **Domain docs**: where `GLOSSARY.md` and ADRs live, and how skills read them

Explore, present what you found, confirm with the user, then write. Nothing is written before the user confirms.

## 1. Explore

Read whatever exists; don't assume:

- `git remote -v`: GitHub, GitLab (`gitlab.com` or a self-hosted host), another host, or no remote?
- `CLAUDE.md` (root or `.claude/`) and `AGENTS.md` at the root: which exist, does one only import the other (`@AGENTS.md`), and is there already an `## Agent skills` section?
- `docs/agents/`: does this skill's earlier output exist?
- `GLOSSARY.md` and `GLOSSARY-MAP.md` at the root
- ADR folders: `docs/adr/`, `docs/decisions/`, an `.adr-dir` file, any `src/*/docs/adr/`
- `.scratch/`: a sign that local-markdown issues are already in use
- Monorepo signals: `pnpm-workspace.yaml`, a `workspaces` field in `package.json`, or a populated `packages/*` with its own `src/`. Their absence means single-context, which is almost every repo.

## 2. Present findings and ask

Summarise what's present and what's missing. Then take the sections in order: one section, one answer, then the next.

Lead each section with the recommended answer so the user can accept it in a word. Skip a question when exploration already settled it.

**Section A: Issue tracker.** Skills that create or read issues follow `docs/agents/issue-tracker.md`, so they never guess between `gh issue create`, a markdown file under `.scratch/`, or another workflow.

Propose the tracker that matches `git remote`: GitHub for github.com, GitLab for a GitLab host, local markdown when there is no remote. Otherwise, or if the user prefers, offer:

- **GitHub**: the repo's GitHub Issues, through the `gh` CLI
- **GitLab**: the repo's GitLab Issues, through the [`glab`](https://gitlab.com/gitlab-org/cli) CLI
- **Local markdown**: files under `.scratch/<feature>/` in this repo (solo projects, repos without a remote)
- **Other** (Jira, Linear and so on): ask for one paragraph describing the workflow, and which tool Claude reaches the tracker through (an MCP server or a CLI). Make one read-only call with that tool to check it works. If it fails, say so and offer to continue with local markdown until the tool is connected. Record the paragraph as written, plus the exact tool names

**Section B: Domain docs.** Default to **single-context**: one `GLOSSARY.md` and `docs/adr/` at the root. This fits almost every repo; take it without asking. If an ADR folder other than `docs/adr/` already holds ADRs, record that folder instead.

Offer **multi-context** (a root `GLOSSARY-MAP.md` pointing to one `GLOSSARY.md` per context) only when exploration found monorepo signals, then confirm which layout they want.

If no `GLOSSARY.md` exists, offer to seed one (recommended: **yes** when the code has a clear domain). On yes, spawn one Explore subagent (Agent tool, `subagent_type: Explore`) to list the domain nouns the code, tests and docs use, with the synonyms used for the same concept. From its findings, propose 5 to 15 terms, each with a one-sentence definition and an _Avoid_ line. Write only the terms the user confirms, with the **domain-modeling** skill (Skill tool, `pickle:domain-modeling`).

## 3. Confirm and edit

Show the user a draft of:

- the `## Agent skills` block, and the file it goes in (step 4)
- `docs/agents/issue-tracker.md` and `docs/agents/domain.md`

Let them edit before writing.

## 4. Write

**Pick the instruction file to edit:**

- If `CLAUDE.md` exists, edit it. If it only imports `AGENTS.md`, edit `AGENTS.md` instead.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask the user which one to create; don't pick for them.

Never create `AGENTS.md` when `CLAUDE.md` already exists, or the other way round.

If an `## Agent skills` block already exists, update it in place rather than appending a duplicate. Don't touch the sections around it.

The block:

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked]. See `docs/agents/issue-tracker.md`.

### Domain docs

[one-line summary of the layout: "single-context" or "multi-context"]. See `docs/agents/domain.md`.
```

Then write the docs files from the templates:

- [references/issue-tracker-github.md](references/issue-tracker-github.md): GitHub
- [references/issue-tracker-gitlab.md](references/issue-tracker-gitlab.md): GitLab
- [references/issue-tracker-local.md](references/issue-tracker-local.md): local markdown
- [references/domain.md](references/domain.md): domain docs, with its Layout section filled in and any non-default ADR folder replacing `docs/adr/`

For "other" trackers, write `docs/agents/issue-tracker.md` from the user's description, with a Conventions section naming the exact tool calls to create and read an item, and the same two closing sections the templates have: what "publish to the issue tracker" and "fetch the relevant ticket" mean.

## 5. Done

Tell the user setup is complete and what was written. They can edit `docs/agents/*.md` directly later; re-running this skill is only needed to switch issue trackers or start over.
