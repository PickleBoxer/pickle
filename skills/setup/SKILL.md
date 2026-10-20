---
name: setup
description: Configure this repo for pickle's skills: where issues are tracked, where the glossary and ADRs live, and which docs source to check first. Offers to set the quality bar. Run once per repo.
disable-model-invocation: true
metadata:
  upstream: mattpocock-skills/skills/engineering/setup-matt-pocock-skills
  upstream-version: 1.3.1
---

# Setup

Write the per-repo configuration pickle's skills read:

- **Issue tracker**: where issues live (GitHub, GitLab, local markdown, or a workflow the user describes)
- **Domain docs**: where `GLOSSARY.md` and ADRs live, and how skills read them
- **Docs sources**: which docs tool or site to check first for each part of the stack, at the installed version

Explore, present what you found, confirm with the user, then write. Nothing is written before the user confirms.

## 1. Explore

Read whatever exists; don't assume:

- `git remote -v`: GitHub, GitLab (`gitlab.com` or a self-hosted host), another host, or no remote?
- `CLAUDE.md` (root or `.claude/`) and `AGENTS.md` at the root: which exist, does one only import the other (`@AGENTS.md`), and is there already an `## Agent skills` section? Note any generated block: Laravel Boost rewrites everything inside `<laravel-boost-guidelines>`.
- `docs/agents/`: does this skill's earlier output exist?
- `GLOSSARY.md` and `GLOSSARY-MAP.md` at the root
- ADR folders: `docs/adr/`, `docs/decisions/`, an `.adr-dir` file, any `src/*/docs/adr/`
- `.scratch/`: feature folders from earlier work; an `issues/` folder in one means local-markdown issues are already in use
- Lockfiles (`composer.lock`, `package-lock.json` and so on): the main frameworks and their installed versions
- MCP servers: those connected in this session (your own tool list) and those in `.mcp.json`. Servers added at user scope or by a plugin never appear in `.mcp.json`. Note docs tools (`laravel-boost`, Context7) and trackers (Linear, Atlassian for Jira); `laravel/boost` in `composer.lock` also counts
- `CONSTRAINTS.md` at the root
- Monorepo signals: `pnpm-workspace.yaml`, a `workspaces` field in `package.json`, or a populated `packages/*` with its own `src/`. Their absence means single-context, which is almost every repo.

## 2. Present findings and ask

Summarise what's present and what's missing. Then take the sections in order: one section, one answer, then the next.

Lead each section with the recommended answer so the user can accept it in a word. Skip a question when exploration already settled it.

**Section A: Issue tracker.** Skills that create or read issues follow `docs/agents/issue-tracker.md`, so they never guess between `gh issue create`, a markdown file under `.scratch/`, or another workflow.

Propose the tracker that matches `git remote`: GitHub for github.com, GitLab for a GitLab host, local markdown when there is no remote. When a Linear or Atlassian MCP server is connected, name it as the alternative: code on GitHub with issues in Linear or Jira is common. Otherwise, or if the user prefers, offer:

- **GitHub**: the repo's GitHub Issues, through the `gh` CLI
- **GitLab**: the repo's GitLab Issues, through the [`glab`](https://gitlab.com/gitlab-org/cli) CLI
- **Local markdown**: files under `.scratch/<feature>/` in this repo (solo projects, repos without a remote)
- **Linear**: Linear issues through Linear's MCP server. Check it with `list_teams` and ask which team (and project, if any) this repo's issues go to
- **Jira**: Jira issues through Atlassian's MCP server. Check it with `getAccessibleAtlassianResources` (it returns the `cloudId` every Jira tool needs), then `listJiraProjects`, and ask which project key this repo's issues go to

When the Linear or Atlassian server is not connected, give the user its `claude mcp add` command and offer local markdown until it is: `claude mcp add --transport http linear-server https://mcp.linear.app/mcp` or `claude mcp add --transport http atlassian https://mcp.atlassian.com/v2/mcp`, then `/mcp` to sign in.

- **Other** (YouTrack, Shortcut and so on): ask for one paragraph describing the workflow, and which tool Claude reaches the tracker through (an MCP server or a CLI). Make one read-only call with that tool to check it works. If it fails, say so and offer to continue with local markdown until the tool is connected. Record the paragraph as written, plus the exact tool names

**Section B: Domain docs.** Default to **single-context**: one `GLOSSARY.md` and `docs/adr/` at the root. This fits almost every repo; take it without asking. If an ADR folder other than `docs/adr/` already holds ADRs, record that folder instead.

Offer **multi-context** (a root `GLOSSARY-MAP.md` pointing to one `GLOSSARY.md` per context) only when exploration found monorepo signals, then confirm which layout they want.

If no `GLOSSARY.md` exists, offer to seed one (recommended: **yes** when the code has a clear domain). On yes, spawn one Explore subagent (Agent tool, `subagent_type: Explore`) to list the domain nouns the code, tests and docs use, with the synonyms used for the same concept. From its findings, propose 5 to 15 terms, each with a one-sentence definition and an _Avoid_ line. Write only the terms the user confirms, with the **domain-modeling** skill (Skill tool, `pickle:domain-modeling`).

**Section C: Docs sources.** The source-driven-development skill reads `docs/agents/sources.md` to pick where to look before it fetches a page. Propose one row per main framework from the lockfiles: the installed version, the docs tool found in exploration as the first source (Boost's `search-docs` for the Laravel ecosystem, Context7 for other libraries), and the official docs URL for that version as the fallback. With no docs tool, the first source column stays empty and the row still records the versioned URL.

**Section D: Quality bar.** Skip it when `CONSTRAINTS.md` exists. Otherwise offer, recommended **yes**, to run the **constraint-driven-development** skill (Skill tool, `pickle:constraint-driven-development`) once step 5 is done. It asks its own questions; record nothing for it here.

## 3. Confirm and edit

Show the user a draft of:

- the `## Agent skills` block, and the file it goes in (step 4)
- `docs/agents/issue-tracker.md`, `docs/agents/domain.md` and `docs/agents/sources.md`

Let them edit before writing.

## 4. Write

**Pick the instruction file to edit:**

- If `CLAUDE.md` exists, edit it. If it only imports `AGENTS.md`, edit `AGENTS.md` instead.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask the user which one to create; don't pick for them.

Never create `AGENTS.md` when `CLAUDE.md` already exists, or the other way round.

If an `## Agent skills` block already exists, update it in place rather than appending a duplicate. Don't touch the sections around it. Never put the block inside a generated block such as `<laravel-boost-guidelines>`: the tool's next update deletes it.

The block:

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked]. See `docs/agents/issue-tracker.md`.

### Domain docs

[one-line summary of the layout: "single-context" or "multi-context"]. See `docs/agents/domain.md`.

### Docs sources

[one-line summary, such as "Boost search-docs first for Laravel 12"]. See `docs/agents/sources.md`.
```

Then write the docs files from the templates:

- [references/issue-tracker-github.md](references/issue-tracker-github.md): GitHub
- [references/issue-tracker-gitlab.md](references/issue-tracker-gitlab.md): GitLab
- [references/issue-tracker-local.md](references/issue-tracker-local.md): local markdown
- [references/issue-tracker-linear.md](references/issue-tracker-linear.md): Linear, with each `{{tool}}` replaced by the exact name the server lists
- [references/issue-tracker-jira.md](references/issue-tracker-jira.md): Jira, with the site, project key and `cloudId` filled in
- [references/domain.md](references/domain.md): domain docs, with its Layout section filled in and any non-default ADR folder replacing `docs/adr/`
- [references/sources.md](references/sources.md): docs sources, with the confirmed rows

For "other" trackers, write `docs/agents/issue-tracker.md` from the user's description, with a Conventions section naming the exact tool calls to create and read an item, and the same two closing sections the templates have: what "publish to the issue tracker" and "fetch the relevant ticket" mean.

## 5. Done

Tell the user setup is complete and what was written. They can edit `docs/agents/*.md` directly later; re-running this skill is only needed to switch issue trackers or start over.

If the user said yes in Section D, run the constraint-driven-development skill now.
