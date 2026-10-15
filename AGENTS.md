# AGENTS.md

Guide for agents working in this repo. `.claude/CLAUDE.md` imports this file (a root `CLAUDE.md` trips `plugin validate --strict`).

## What pickle is

A Claude Code plugin built on [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills). The user starts `/pickle:pickle-mode <task>`: the vendored `using-agent-skills`, renamed and made user-only, which maps the task to the 24 workflow skills. pickle also ships `typescript-best-practices`, ported from pstack. Every other pstack piece (playbooks, principles, tools, profile, `setup`) is `pending` in `UPSTREAM.md` and comes back only when an eval or real use shows the gap. Origin and licenses: `CREDITS.md`.

## Next

1. Run the `router-*` loading evals, with the user's go-ahead, until `pickle-mode` picks the right skills.
2. Trim vendored skills on `main` where evals show they are too long or overlap.
3. Re-add `pending` pieces one at a time, for a measured gap.
4. Outcome evals, token evals, then the Haiku, Sonnet and Opus pass before a release.

Old working plans are in `.scratch/` (excluded via `.git/info/exclude`, never committed). They predate the baseline reset.

## Layout

```
.claude-plugin/plugin.json    manifest
.github/workflows/            CI: validate, check-refs
skills/pickle-mode/           entry skill: vendored using-agent-skills, renamed and user-only on main
skills/<agent-skills name>/   24 vendored workflow skills
skills/typescript-best-practices/   default TypeScript idioms
commands/                     9 vendored commands (/pickle:build, /pickle:ship, ...)
agents/                       4 vendored agents (code-reviewer, security-auditor, test-engineer, web-performance-auditor)
LICENSES/                     agent-skills.txt, for vendored commands and agents
evals/loading/                router-* cases plus _fixture (results/ is ignored)
docs/                         claude-code.md (native features, plugin and mod notes), pstack.md (historical pstack map)
scripts/                      check-refs.sh (CI), upstream-diff.sh and vendor-sync.sh (maintainer)
UPSTREAM.md                   upstream source and version per pickle file
```

## Working rules

- Never run `git commit`, `git push`, `gh repo create` or any other publishing command. Hand the user the command and a commit message.
- Commit messages: Conventional Commits, `type(scope): title`. Scope mandatory, imperative, lowercase, no period, about 50 chars. Body as `-` bullets when it makes more than one point. No AI attribution, no emojis.
- GitHub: run `gh auth switch -u PickleBoxer` before any `gh` call. The SSH remote uses the host alias `github-PickleBoxer.com`.
- Never run an eval without asking first.
- Ask before assuming intent or architecture. Say whether a claim is measured, inferred or a guess.
- Claude Code facts come from the `claude-code-docs` MCP server, never from memory or WebFetch: `mcp__claude-code-docs__search_claude_code_docs`, then `mcp__claude-code-docs__query_docs_filesystem_claude_code_docs` (`/en/<page>.mdx`). Tell research subagents the same. If the server is missing, ask the user to run `claude mcp add --transport http claude-code-docs https://code.claude.com/docs/mcp`, never at project scope (a root `.mcp.json` would ship with the plugin).
- Before writing mod code, load the `plugin-authoring` skill. Mod notes: `docs/claude-code.md`, Mods.

## Checks

```bash
claude plugin validate . --strict
bash scripts/check-refs.sh
claude --plugin-dir ~/dev/code/pickle
```

`check-refs.sh` fails when a skill or agent mention does not resolve, a called skill is user-only, a skill has unknown frontmatter (`--strict` does not check it), or `UPSTREAM.md` disagrees with the files. `claude plugin test .` joins CI with the first mod test.

## Vendored skills

- `scripts/vendor-sync.sh [ref]` copies every `vendored` row from agent-skills to the `vendor/agent-skills` branch, at the pickle path its row names, and prints the commit and merge commands. It rewrites upstream names to `pickle:<name>` and repo paths to `${CLAUDE_PLUGIN_ROOT}`. Agent names stay bare so projects can override them.
- Edit vendored files on `main`. The merge keeps those edits. After a merge, set the agent-skills Baseline and every `vendored` row to the new version.
- To stop syncing a skill, change its row to `rewritten` and keep your copy in the next merge.
- `scripts/upstream-diff.sh` lists upstream changes since each baseline: pstack, `kit:` (cursor-team-kit) and `as:` (agent-skills) rows.

## Authoring

From Anthropic's skill authoring guide. Skill mechanics (frontmatter, context, compaction, substitutions): `docs/claude-code.md`, Skills.

- Every line must justify its token cost. `SKILL.md` under 500 lines, references one level deep, a table of contents over 100 lines.
- Descriptions in third person: what it does, then when to use it, key use case first. Description plus `when_to_use` is cut at 1,536 characters and sits in every session unless the skill is user-only.
- Exact commands or scripts for fragile steps, prose for judgment.
- One term per concept, from `GLOSSARY.md`. Never use a word it lists under _Avoid_.
- No time-sensitive statements and no model names in prose.
- Evals before content. Watch real runs: files never read are badly signposted or unneeded.

## Evals

`claude plugin eval`. Cases are `evals/**/prompt.md` plus `case.yaml`. Docs: https://code.claude.com/docs/en/plugin-evals.md

- Always pass `--no-publish` (reports publish to claude.ai by default) and `--max-cost-usd`.
- Loading cases are dry runs: the agent stops after it invokes the skills. Run them with `--ablation none` (a no-plugin arm has nothing to load), `--scaffold`, `--runs 1` while iterating and 3 for decisions.
- Iterate with `--tag smoke --model haiku`, about $0.01 per case.
- Prefer free graders (`tool_used`, `tool_order`, `regex`, `file_exists`) over `llm`. For test results, have Claude write them to a file and grade the file.
- Tools listed in a case's `allowed_tools` are granted if read-only. Edit, Write and Bash need `--allow-tools`.
- No `.claude/` config loads inside a run.

## References

- Native features, plugin and mod notes: `docs/claude-code.md`. pstack map: `docs/pstack.md`.
- Skills: https://code.claude.com/docs/en/skills
- Authoring: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- Plugins: https://code.claude.com/docs/en/plugins-reference
- Mods: https://code.claude.com/docs/en/plugins/mods/overview
- pstack: https://github.com/cursor/plugins/tree/main/pstack, port: https://github.com/PickleBoxer/pstack
- Marketplace: https://github.com/PickleBoxer/claude-plugins
