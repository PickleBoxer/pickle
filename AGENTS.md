# AGENTS.md

Guide for agents working in this repo. `.claude/CLAUDE.md` imports this file (a root `CLAUDE.md` trips `plugin validate --strict`).

## Contents

- What pickle is
- Status and build order
- Layout
- Working rules
- Checks
- Skills in Claude Code
- Skill authoring best practices
- Plugin facts
- Mods
- Evals
- Design decisions
- References

## What pickle is

A Claude Code plugin with language-agnostic engineering playbooks and principles. The user starts one skill, `/pickle:pickle-mode <task>`. From the task, the agent decides which playbooks to read and which principles to load. Playbooks and principles are plain files inside `pickle-mode`, read only when the task needs them. pickle's language rules are defaults only: each project lists its own conventions in the profile, and `/pickle:setup` adds the language skills for the stack after them (pickle's own, or third-party ones the user has installed). Invoking pickle means the full process: there are no effort levels, and small tasks simply don't use pickle. A project profile at `.claude/pickle.md` tells pickle how that project tests, lints and runs. pickle ships as a plugin with a mod, and its skills also install on their own with `npx skills add`.

Origin: a rework of pstack's `poteto-mode`. See `CREDITS.md`.

## Status and build order

In progress. `pickle-mode`, all playbooks and principles, the tools, the agents and `setup` exist. Plan 2 renamed the tools to `how`, `architect`, `interrogate` and `swarm`. Loading evals pass on the renamed set on Haiku, Sonnet and Opus. Evals came before content:

1. Loading eval cases for all 19 playbooks plus ambiguous cases (`evals/loading/`), each with a small fixture.
2. Build `pickle-mode`, all 19 playbooks, all 14 principles, the tools and the agents.
3. Run the loading evals, with the user's go-ahead, until the agent reads the right playbooks and loads the right principles for each task.
4. Build `setup`, which writes the profile with the project's verify commands and conventions.
5. Then outcome evals and token evals. Grow only where evals show gaps.

The working plans live in `.scratch/plan.md` (plan 1) and `.scratch/plan-2.md` (tools, upstream, next skills). `.scratch/` is excluded through `.git/info/exclude` and never committed. If it is missing, ask the user for it.

## Layout

Current:

```
.claude-plugin/plugin.json    manifest
.github/workflows/            CI: validate, dash check
skills/pickle-mode/           entry skill: SKILL.md, playbooks/ (19), principles/ (14)
skills/how/ why/ architect/ interrogate/ swarm/   tools, context: fork, lead plus references/
skills/setup/                 /pickle:setup: scripts/detect-stack.sh, profiles/ (5)
skills/sharpen/ in-your-own-words/   user-only prompts, ported from pstack
skills/tdd/ unslop/ technical-writing/ no-comments/ deslop/ benchmark-checklist/ show-me-your-work/ blast-radius/ figure-it-out/   inline skills ported from pstack (deslop from cursor-team-kit)
skills/typescript-best-practices/   language skill, a default convention for TypeScript stacks
agents/                       pickle-lead, pickle-explorer, pickle-implementer, pickle-reviewer, pickle-historian, comment-sicko
evals/                        eval cases (results/ is ignored)
docs/                         claude-code.md (native features), pstack.md (pstack map)
scripts/                      check-refs.sh (CI), upstream-diff.sh (maintainer)
UPSTREAM.md                   pstack source and version per pickle file
.claude/CLAUDE.md            imports AGENTS.md
AGENTS.md  GLOSSARY.md  README.md  CREDITS.md  LICENSE
```

Planned:

```
skills/
  pickle-mode/                entry skill, user-invoked only
    SKILL.md                  process, non-negotiables, playbook and principle indexes
    playbooks/*.md            plain files, read on demand
    principles/*.md           plain files, read on demand
  setup/                      /pickle:setup, detects stack, writes .claude/pickle.md
    scripts/detect-stack.sh
    profiles/*.md
  how/ why/ architect/ interrogate/ swarm/  context: fork, run as pickle-lead (why as pickle-historian)
agents/                       pickle-lead, pickle-explorer, pickle-implementer, pickle-reviewer
hooks/                        mod: hooks.json plus register.tsx
tests/                        *.test.ts for the mod
types/index.d.ts              mod state contract, if the mod keeps $.state values
```

## Working rules

- Never run `git commit`, `git push`, `gh repo create` or any other publishing command. Prepare the change, then hand the user the command and a commit message.
- Commit messages: Conventional Commits, `type(scope): title`. Scope mandatory, imperative, lowercase, no period, about 50 chars. Body as `-` bullets when it makes more than one point. No AI attribution, no emojis.
- Never use em dashes or en dashes in any file or message. Rephrase with periods, commas or parentheses. Hyphens in compound words are fine. CI fails on them.
- GitHub: run `gh auth switch -u PickleBoxer` before any `gh` call for this repo. The SSH remote uses the host alias `github-PickleBoxer.com`.
- Never run an eval without asking first. See Evals.
- Ask before assuming intent or architecture. Flag uncertainty and say whether a claim is measured, inferred or a guess.
- Claude Code facts come from the `claude-code-docs` MCP server, never from memory or WebFetch: search with `mcp__claude-code-docs__search_claude_code_docs`, then read the page with `mcp__claude-code-docs__query_docs_filesystem_claude_code_docs` (`/en/<page>.mdx`). Pass the same instruction to subagents that research docs. If the server is missing, ask the user to run `claude mcp add --transport http claude-code-docs https://code.claude.com/docs/mcp`, never at project scope (a root `.mcp.json` ships with the plugin). The claude.ai "Claude Docs" connector is a different product: it edits shareable documents.
- Before writing mod code, load the `plugin-authoring` skill. It writes this build's mod types. Write the mod in this repo, not in the dev-mods folder that skill names.

## Checks

```bash
claude plugin validate . --strict
bash scripts/check-refs.sh
claude plugin test .
claude --plugin-dir ~/dev/code/pickle
```

`check-refs.sh` fails when a skill, principle or agent mention does not resolve, a called skill is user-only, or `UPSTREAM.md` disagrees with the files. `validate --strict` does not check skill frontmatter, so this script does. `scripts/upstream-diff.sh` (maintainer only) lists upstream changes since each baseline in `UPSTREAM.md`: pstack, and cursor-team-kit for `kit:` rows.

`plugin test` runs every `*.test.ts` under the folder against the engine. It needs at least one test, so it joins CI with the first mod code.

## Skills in Claude Code

Verified against the docs on 2026-10-13, Claude Code 2.1.296.

### What sits in context

- Only `description` plus `when_to_use` of each skill is always in context, cut at 1,536 characters per skill. Put the key use case first.
- The body loads when the skill is invoked and stays as one message. It is not re-read on later turns.
- Re-invoking a skill with identical content adds only a note that it is loaded.
- After compaction, the most recent invocation of each skill is re-attached: the first 5,000 tokens per skill, 25,000 tokens combined. Older skills can drop out.
- Files opened with Read are not re-attached after compaction. Anything that must survive compaction is a skill, or is copied into the todo list.

### Frontmatter

| Field | Use |
|---|---|
| `name` | lowercase letters, numbers, hyphens, max 64 chars. Defaults to the folder name. In a plugin it sets the last segment only |
| `description` | what it does and when to use it, third person |
| `when_to_use` | extra trigger phrases, appended to the description |
| `argument-hint` | autocomplete hint, for example `<task>` |
| `arguments` | named positional arguments for `$name` |
| `disable-model-invocation: true` | user-only. Description is not in context. Blocks the Skill tool and preloading into subagents |
| `user-invocable: false` | Claude-only background skill, hidden from the `/` menu. Description stays in context |
| `allowed-tools` | tools usable without asking during the invoking turn |
| `disallowed-tools` | tools removed while the skill is active |
| `model`, `effort` | per-turn override |
| `context: fork` + `agent` | run the skill in a subagent (`Explore`, `Plan` or a custom agent) |
| `background` | with `context: fork`, `false` waits for the result |
| `paths` | globs. Lists a project skill only after a matching file is read. Ignored for plugin skills (measured, `docs/claude-code.md`) |
| `hooks` | hooks registered when the skill is invoked |

Outside Claude Code (claude.ai uploads, the Skills API) only `name`, `description`, `license`, `compatibility`, `metadata` and `allowed-tools` are accepted. Other keys fail the upload. pickle targets Claude Code, so it uses the full set.

### Substitutions and injection

- `$ARGUMENTS`, `$0`, `$name`. If no placeholder takes the arguments, Claude Code appends `ARGUMENTS: <value>`.
- `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${CLAUDE_SESSION_ID}`, `${CLAUDE_EFFORT}`.
- `` !`command` `` runs before Claude sees the skill and inlines its output. A failing command aborts the whole invocation, so guard it: `` !`cat .claude/pickle.md 2>/dev/null || echo NO_PROFILE` ``. The command needs a permission rule or an `allowed-tools` entry. If Bash is denied, the permission check fails and the skill aborts with zero turns, guard or not (measured in an eval run). pickle reads its profile with Read instead.

### Locations and names

- Enterprise, personal (`~/.claude/skills/`), project (`.claude/skills/`), nested, plugin (`<plugin>/skills/`). Enterprise beats personal beats project.
- Plugin skills are namespaced `plugin:skill`, so projects can add skills beside pickle but never override it.
- A skill named like its plugin becomes `/pickle:pickle`. That is why the entry skill is `pickle-mode`.

## Skill authoring best practices

From Anthropic's skill authoring guide. Apply to every skill, playbook and principle.

- Concise. Claude is already smart. Every line must justify its token cost.
- `SKILL.md` body under 500 lines. Split into reference files before that.
- References one level deep from `SKILL.md`. Nested references get skimmed with partial reads.
- Reference files over 100 lines start with a table of contents.
- Descriptions in third person, what it does plus when to use it, with the key terms a user would say.
- Match freedom to fragility. Exact commands and scripts for fragile steps, prose for judgment.
- Scripts for deterministic work. Say whether Claude runs a script or reads it.
- Workflows as checklists Claude copies into its todo list. Feedback loops: run, fix, rerun.
- One term per concept, defined in `GLOSSARY.md` at the repo root. Use its terms in every skill, playbook and principle, and never use a word it lists under _Avoid_ to name that concept.
- No time-sensitive statements. No hardcoded model names in prose; models live in agent frontmatter.
- Forward slashes in paths. Fully qualified MCP tool names: `mcp__<server>__<tool>` in Claude Code (`Server:tool` is the Skills API form).
- Evals before content. Test on Haiku, Sonnet and Opus.
- Watch how Claude navigates the skill in real runs. Files never read are badly signposted or unneeded.

## Plugin facts

Learned while porting pstack (PickleBoxer/pstack). Recheck after Claude Code updates.

- `.claude-plugin/plugin.json` alone makes a folder a valid plugin. Skills load from `skills/<folder>/SKILL.md`, agents from `agents/*.md` as `pickle:<name>`.
- `disable-model-invocation: true` hides the description and blocks the Skill tool. A skill that must load another such skill has to Read its `SKILL.md`.
- `skillOverrides` in settings does not apply to plugin skills.
- `npx skills add PickleBoxer/pickle --skill '*'` installs skill files only. No agents, no mod, no `userConfig`. Skills must work without the mod.
- `userConfig` fields with `options` render as pickers in the config menu (Claude Code 2.1.271+).
- Version is semver in `plugin.json`. Claude Code updates users when it changes. Tag each release `v<version>`.

## Mods

A mod is a plugin with function hooks. Claude Code 2.1.287+ (verified on 2.1.296). The API is early access and moves between releases. The generated types are the authority.

- Three files: `.claude-plugin/plugin.json`, `hooks/hooks.json` (`{ "modules": ["./register.tsx"] }`), `hooks/register.tsx` exporting `register: Register` from `'claude-code'`.
- State kept in `$.state` is declared in `types/index.d.ts` under `interface PluginState`, named in `plugin.json` as `"types"`. `claude plugin validate` checks every key against it.
- Every hook is `($, e, next)`. `next(e)` continues the chain, returning without it answers alone, `next({ ...e, x })` rewrites.
- The module has no DOM and no Node. Everything goes through `$`. Only static `import` of the plugin's own files and `'claude-code'`. `import()` does not load.
- UI: `const { Box, Text, Button } = $.ui.resolve(e)`. Surfaces: `terminal`, `desktop`, `vscode`, `mobile`. Panes via `$.ui.open` plus a `ui.render` hook on `Pane`. Bands via `AbovePrompt`. Mods draw only in the terminal and the desktop Code tab. Hooks still run under `claude -p`.
- Slash commands: `$.command.register` in `session.start`, answered by `command.run`.
- Guards (`tool.call`, `prompt.submit`, `command.run`, ...) are skipped if they throw, unless their `.catch` answers. Write `on(...).catch(($, e, next) => next.called ? next(e) : { deny: 'why' })`.
- Types: the engine writes `.claude-plugin/types/` when it loads the mod from a watched folder. That folder is gitignored. `tsc -p .` type-checks.
- Develop with `claude --plugin-dir ~/dev/code/pickle` (or `CLAUDE_CODE_PLUGIN_DIRS`). Saves hot-reload. Use `claude --debug` to see skipped hooks.
- Tests: `*.test.ts` importing `test`, `expect`, `mock` from `claude-code/testing`, run by `claude plugin test .`. Loop UI tests over `['terminal', 'desktop'] as const`.
- Events used in pstack's mod: `skill.prompt`, `tool.call` (result `context` reaches only Claude), `agent.spawn`, `prompt.submit`, `prompt.compose`, `session.compact`, `command.run`, `command.describe`, `ui.render`.

## Evals

Tool: `claude plugin eval` (built in). Cases are `evals/**/case.yaml` or `prompt.md` plus `graders/*.md`. Scaffold one with `claude plugin eval init --bare <name>`.

- Always ask the user before running any eval. Each run is a full agent session on their account.
- Always pass `--no-publish` (reports publish to claude.ai by default) and `--max-cost-usd`.
- Default is 3 runs per case, with and without the plugin. Use `--runs 1` while iterating, 3 for decisions.
- Loading evals run with `--ablation none`: a no-plugin arm has nothing to load, and in a two-arm run `Skill` graders are reported but not scored.
- Read-only tools are granted when listed in `allowed_tools`. Edit, Write and Bash need `--allow-tools`. Loading cases don't need them.
- Loading cases are dry runs: `append_system_prompt` stops the agent after it reads principles, `allowed_tools: [Read, Glob, Grep]`, `max_turns: 12`. Use `--tag smoke` (three cases) and `--model haiku` while iterating, about $0.01 per pass.
- Narrow with `--case` and `--tag`. Override with `--model`. LLM graders default to Haiku (`--judge-model`).
- Prefer free graders (`tool_used`, `tool_order`, `regex`, `file_exists`) over `llm`. There is no tests-pass grader: have Claude write the result to a file and grade that file.
- Fixtures are tiny purpose-built repos created by a `scaffold_script` in the case directory, which needs `--scaffold`. No `.claude/` config loads inside a run, but files there can still be read.
- Docs: https://code.claude.com/docs/en/plugin-evals.md
- Stages: loading evals, then outcome evals, then token evals, then the three-model pass before releases.

## Design decisions

| Topic | Decision |
|---|---|
| Entry skill | `pickle-mode`, user-invoked only, `/pickle:pickle-mode <task>`. Like pstack's `poteto-mode`: the user starts the skill, the agent decides from the task which playbooks to read and which principles to load |
| Effort | No levels. Invoking pickle means the full process. Claude Code's own `/effort` is separate and untouched |
| Playbooks | 19 plain files under `pickle-mode`, read only when the task needs them. Steps copied into todos so they survive compaction |
| Principles | 14 plain files under `pickle-mode`, merged from pstack's 24, rewritten language-agnostic. Named throughout, as in pstack: a trigger index in `pickle-mode` and inline mentions in playbook steps (`**principle-fix-root-causes**` is `principles/fix-root-causes.md`). The agent reads one when a mention applies. Not skills, so they cost nothing outside pickle and never load in ordinary sessions. Todos name the principle file, so it can be reread after compaction |
| Conventions | Principles stay language-agnostic, and each project lists its conventions in the profile as skill names or file paths. `pickle-mode` loads every one in step 1, also for tasks that write no code, and they win over pickle's defaults. Language skills are defaults only: `/pickle:setup` appends the ones for each detected stack after the project's own conventions, so the project wins. pickle ships `typescript-best-practices`. Laravel and React use third-party skills the user installs (`laravel-best-practices` from Laravel Boost, `vercel-react-best-practices` from Vercel): pickle never copies them, `detect-stack.sh` reports whether they are installed, and setup gives the install command when they are not. No `paths`: plugin skills ignore it |
| Profile | `.claude/pickle.md` in the user's project, read with Read by `pickle-mode`, written by `/pickle:setup` |
| Tools | `how`, `why`, `architect`, `interrogate`, `swarm`, each a forked `pickle-lead` that fans out to its own subagents and returns one answer. `why` forks as `pickle-historian` instead, which has no tools list so it can reach MCP sources. `arena` (bakeoff) dropped: one model family. `interrogate panel` and `swarm` only when a playbook calls for them or the user names them |
| Reply style | not pickle's job. Lives in the user's CLAUDE.md |
| Observability | playbook and principle Reads in the transcript, a `Loaded:` line at the end of each reply, optional mod pane |

`pickle-mode` flow: read the profile and load its conventions, read the playbooks the task needs (ask once if unclear), copy the steps into todos, read principle files where the playbook steps or the `pickle-mode` Principles index name them, pass principle and convention paths to subagents, run `how`, `architect`, implementer subagent, `interrogate` and `swarm` as the playbook lists them, verify against the profile, end with the `Loaded:` line.

## References

- Claude Code native features and the pstack map: `docs/claude-code.md`, `docs/pstack.md`
- Skills: https://code.claude.com/docs/en/skills
- Authoring best practices: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- Plugin manifest: https://code.claude.com/docs/en/plugins-reference
- Mods: https://code.claude.com/docs/en/plugins/mods/overview
- pstack upstream: https://github.com/cursor/plugins/tree/main/pstack
- pstack port, mod example: https://github.com/PickleBoxer/pstack
- Marketplace: https://github.com/PickleBoxer/claude-plugins
