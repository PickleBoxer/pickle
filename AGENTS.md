# AGENTS.md

Guide for agents working in this repo. `.claude/CLAUDE.md` imports this file (a root `CLAUDE.md` trips `plugin validate --strict`).

## What pickle is

A Claude Code plugin built on [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills). The user starts `/pickle:pickle-mode <task>`: the vendored `using-agent-skills`, renamed and made user-only, which maps the task to the 24 workflow skills. pickle also ships nine skills from pstack: `typescript-best-practices`, `unslop`, `technical-writing` and the user-only `sharpen` (ported), `how`, `why`, `blast-radius` and the user-only `reflect` and `teach` (rewritten for Claude Code; `reflect` merges in mattpocock's `retro`). From mattpocock/skills it ships two extensions, `codebase-design` and `domain-modeling`, which workflow skills call, and two user-only skills, `/pickle:setup` and `/pickle:improve-codebase-architecture`. Origin and licenses: `CREDITS.md`.

## Next

1. With the user's go-ahead, run the firing evals until the skills fire on their own, and the loading evals at 3 runs on Sonnet and Opus. Then the cases for the Matt Pocock skills: the extension chains, `setup-*`, `improve-architecture-*`, `reflect-*`, `teach-*`, `sharpen-*` and `constraints-*` (scaffolded, `--ablation none` for the user-only ones).
2. Trim vendored skills on `main` where evals show they are too long or overlap.
3. Outcome evals, token evals, then the Sonnet and Opus pass before a release.

## Layout

```
.claude-plugin/plugin.json    manifest
.github/workflows/            CI: validate, check-refs
skills/pickle-mode/           entry skill: vendored using-agent-skills, renamed and user-only on main
skills/<agent-skills name>/   24 vendored workflow skills
skills/typescript-best-practices/   default TypeScript idioms
skills/how/, skills/why/, skills/blast-radius/   investigation skills (pstack): how code works, why it is shaped that way, what a change breaks
skills/unslop/, skills/technical-writing/   writing skills (pstack)
skills/reflect/               user-only session review (pstack reflect + mattpocock retro), scripts/digest.sh
skills/teach/, skills/sharpen/   user-only (pstack): explain via how and why, rewrite a prompt
skills/codebase-design/, skills/domain-modeling/   extensions (mattpocock/skills), called by workflow skills
skills/setup/, skills/improve-codebase-architecture/   user-only (mattpocock/skills)
references/                   vendored checklists and patterns shared by skills, commands and agents
commands/                     9 vendored commands (/pickle:build, /pickle:ship, ...)
agents/                       4 vendored agents (code-reviewer, security-auditor, test-engineer, web-performance-auditor)
LICENSES/                     agent-skills.txt, for every vendored file outside skills/; mattpocock-skills.txt
evals/                        vendored from agent-skills: README.md, skill-impact.md and plugin/ (17 firing and 6 loading cases, plus 11 cases for the user-only skills and `/pickle:constraints`)
docs/                         claude-code.md (native features, plugin and mod notes),
                              agents.md and adoption-guide.md (vendored)
scripts/                      check-refs.sh (CI), upstream-diff.sh and vendor-sync.sh (maintainer)
UPSTREAM.md                   upstream source and version per pickle file
```

## Working rules

- Never run `git commit`, `git push`, `gh repo create` or any other publishing command. Hand the user the command and a commit message.
- Commit messages: Conventional Commits, `type(scope): title`. Scope mandatory, imperative, lowercase, no period, about 50 chars. Body as `-` bullets when it makes more than one point. No AI attribution, no emojis.
- GitHub: run `gh auth switch -u PickleBoxer` before any `gh` call. The SSH remote uses the host alias `github-PickleBoxer.com`.
- Never run an eval without asking first.
- Ask before assuming intent or architecture. Say whether a claim is measured, inferred or a guess.
- Claude Code facts come from the `claude-code-docs` MCP server, never from memory or WebFetch: `mcp__claude-code-docs__search_claude_code_docs`, then `mcp__claude-code-docs__query_docs_filesystem_claude_code_docs` (`/en/<page>.mdx`). Tell research subagents the same. If the server is missing, ask the user to run `claude mcp add --transport http claude-code-docs https://code.claude.com/docs/mcp`, never at project scope (a root `.mcp.json` would ship with the plugin). `.claude/mcp.json` has the same server for `claude --mcp-config .claude/mcp.json`.
- Extensions (`codebase-design`, `domain-modeling`) call no skill. Workflow skills reach them with a one-line pointer, noted in the row's Notes in `UPSTREAM.md`. `check-refs.sh` enforces it.
- Before writing mod code, load the `plugin-authoring` skill. Mod notes: `docs/claude-code.md`, Mods.

## Checks

```bash
claude plugin validate . --strict
bash scripts/check-refs.sh
claude --plugin-dir ~/dev/code/pickle
```

`check-refs.sh` fails when a skill or agent mention does not resolve, a called skill is user-only, a skill has unknown frontmatter (`--strict` does not check it), `pickle-mode` names a skill without the call form, or `UPSTREAM.md` disagrees with the files. `claude plugin test .` joins CI with the first mod test.

## Vendored skills

- `scripts/vendor-sync.sh [ref]` copies every `vendored` row from agent-skills to the `vendor/agent-skills` branch, at the pickle path its row names, and prints the commit and merge commands. It rewrites upstream names to `pickle:<name>` and repo paths to `${CLAUDE_PLUGIN_ROOT}`. Agent names stay bare so projects can override them.
- Edit vendored files on `main`. The merge keeps those edits. After a merge, set the agent-skills Baseline and every `vendored` row to the new version.
- To stop syncing a skill, change its row to `rewritten` and keep your copy in the next merge.
- `scripts/upstream-diff.sh` lists upstream changes since each baseline: the pstack rows, the `as:` (agent-skills) rows and the `mp:` (mattpocock-skills) rows.

## Authoring

From Anthropic's skill authoring guide. Skill basics and measured behaviour: `docs/claude-code.md`, Skills. Full mechanics: the docs server, `/en/skills.mdx`.

- Every line must justify its token cost. `SKILL.md` under 500 lines, references one level deep, a table of contents over 100 lines.
- Descriptions in third person: what it does, then when to use it, key use case first. Description plus `when_to_use` is cut at 1,536 characters and sits in every session unless the skill is user-only.
- Exact commands or scripts for fragile steps, prose for judgment.
- One term per concept, from `GLOSSARY.md`. Never use a word it lists under _Avoid_.
- No time-sensitive statements and no model names in prose.
- Evals before content. Watch real runs: files never read are badly signposted or unneeded.

## Evals

`claude plugin eval`. `experimental.evals` in `plugin.json` points it at `evals/plugin/`. A case is `prompt.md` plus one grader per file in `graders/`, and a `case.yaml` only for `context` (a scaffold). Reports go to `evals/plugin/results/`, which is ignored. `evals/README.md` is upstream's guide: its Tier 1 to 3 and `run-evals.js` are not in pickle. Docs: https://code.claude.com/docs/en/plugin-evals.md

- Always pass `--no-publish` (reports publish to claude.ai by default) and `--max-cost-usd`.
- Firing cases need both arms: run them with the default ablation, `--runs 1` while iterating and 3 for decisions, and read the Δ, since a skill fires in some runs and not others. A `tool_used: Skill` grader is left out of the score in two-arm runs, so each case pairs it with a grader on the reply.
- Loading cases (`pickle-mode-routes-*`) run one arm with `--ablation none`: without pickle, `/pickle:pickle-mode` does not exist. The dry-run rule sits in `append_system_prompt`, so the task stays what a user would type.
- Skills target Sonnet and Opus, not Haiku. `--model haiku` is fine for checking that graders work; decide on firing and outcomes with `--model sonnet` and `--model opus`.
- Prefer free graders (`tool_used`, `tool_order`, `regex`, `file_exists`) over `llm`. For test results, have Claude write them to a file and grade the file.
- Tools listed in a case's `allowed_tools` are granted if read-only. Edit, Write and Bash need `--allow-tools`.
- A case with a `case.yaml` scaffold needs `--scaffold`. Each case's description names the flags it needs.
- No `.claude/` config loads inside a run.

## References

- Native features, plugin and mod notes: `docs/claude-code.md`.
- Skills: https://code.claude.com/docs/en/skills
- Authoring: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- Plugins: https://code.claude.com/docs/en/plugins-reference
- Mods: https://code.claude.com/docs/en/plugins/mods/overview
- pstack (source of `typescript-best-practices`): https://github.com/cursor/plugins/tree/main/pstack
- Marketplace: https://github.com/PickleBoxer/claude-plugins
