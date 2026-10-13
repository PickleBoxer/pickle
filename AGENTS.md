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

A Claude Code plugin with language-agnostic engineering playbooks and principles. One router skill, `/pickle:work [low|medium|high] <task>`, sizes the task, reads one playbook and loads only the principles, tools and language packs that playbook needs. A project profile at `.claude/pickle.md` tells pickle how that project tests, lints and runs. pickle ships as a plugin with a mod, and its skills also install on their own with `npx skills add`.

Origin: a rework of pstack's `poteto-mode`. See `CREDITS.md`.

## Status and build order

Bootstrap. No skills yet, on purpose. Evals come before content:

1. Pilot eval case and fixture (`evals/pilot-low-laravel/`).
2. Run the pilot once, with the user's go-ahead, to measure real token use.
3. Build the router, `setup`, three playbooks (feature, bug-fix, refactor), six principles and `pack-php`. Rerun evals.
4. Grow only where evals show gaps.

The working plan lives in `.scratch/plan.md`. `.scratch/` is excluded through `.git/info/exclude` and never committed. If it is missing, ask the user for it.

## Layout

Current:

```
.claude-plugin/plugin.json    manifest
.github/workflows/            CI: validate, dash check
evals/                        eval cases (results/ is ignored)
.claude/CLAUDE.md            imports AGENTS.md
AGENTS.md  README.md  CREDITS.md  LICENSE
```

Planned:

```
skills/
  work/                       router, user-invoked only
    SKILL.md                  profile injection, effort rules, playbook index
    playbooks/*.md            plain files, read on demand
    glossary.md
  setup/                      /pickle:setup, detects stack, writes .claude/pickle.md
    scripts/detect-stack.sh
    profiles/*.md
  principle-*/                background skills (user-invocable: false)
  explore/ design-options/ review/          context: fork
  bakeoff/ adversarial-review/               opt-in only
  pack-php/ pack-typescript/ pack-swift/ pack-template/   background, scoped with paths
agents/                       pickle-explorer (haiku), pickle-implementer (sonnet), pickle-reviewer (opus)
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
- Before writing mod code, load the `plugin-authoring` skill. It writes this build's mod types. Write the mod in this repo, not in the dev-mods folder that skill names.

## Checks

```bash
claude plugin validate . --strict
claude plugin test .
claude --plugin-dir ~/dev/code/pickle
```

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
| `argument-hint` | autocomplete hint, for example `[low\|medium\|high] <task>` |
| `arguments` | named positional arguments for `$name` |
| `disable-model-invocation: true` | user-only. Description is not in context. Blocks the Skill tool and preloading into subagents |
| `user-invocable: false` | Claude-only background skill, hidden from the `/` menu. Description stays in context |
| `allowed-tools` | tools usable without asking during the invoking turn |
| `disallowed-tools` | tools removed while the skill is active |
| `model`, `effort` | per-turn override |
| `context: fork` + `agent` | run the skill in a subagent (`Explore`, `Plan` or a custom agent) |
| `background` | with `context: fork`, `false` waits for the result |
| `paths` | globs. Loads automatically only when working with matching files |
| `hooks` | hooks registered when the skill is invoked |

Outside Claude Code (claude.ai uploads, the Skills API) only `name`, `description`, `license`, `compatibility`, `metadata` and `allowed-tools` are accepted. Other keys fail the upload. pickle targets Claude Code, so it uses the full set.

### Substitutions and injection

- `$ARGUMENTS`, `$0`, `$name`. If no placeholder takes the arguments, Claude Code appends `ARGUMENTS: <value>`.
- `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${CLAUDE_SESSION_ID}`, `${CLAUDE_EFFORT}`.
- `` !`command` `` runs before Claude sees the skill and inlines its output. A failing command aborts the whole invocation, so guard it: `` !`cat .claude/pickle.md 2>/dev/null || echo NO_PROFILE` ``. The command needs a permission rule or an `allowed-tools` entry.

### Locations and names

- Enterprise, personal (`~/.claude/skills/`), project (`.claude/skills/`), nested, plugin (`<plugin>/skills/`). Enterprise beats personal beats project.
- Plugin skills are namespaced `plugin:skill`, so projects can add skills beside pickle but never override it.
- A skill named like its plugin becomes `/pickle:pickle`. That is why the router is `work`.

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
- One term per concept, defined in `glossary.md`.
- No time-sensitive statements. No hardcoded model names in prose; models live in agent frontmatter.
- Forward slashes in paths. Fully qualified MCP tool names (`Server:tool`).
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
- Narrow with `--case` and `--tag`. Override with `--model`. LLM graders default to Haiku (`--judge-model`).
- Prefer free graders (tool used, files changed, tests pass) over LLM graders.
- Fixtures are tiny purpose-built repos created by a `scaffold_script`, which needs `--scaffold`.
- Stage cost: pilot, then low cases, then medium and high, then the three-model pass before releases.

## Design decisions

| Topic | Decision |
|---|---|
| Router | `work`, user-invoked only, `/pickle:work [low\|medium\|high] <task>` |
| Effort | `low`, `medium`, `high`. Picked automatically and reported, asked when borderline, manual argument wins. Independent of Claude Code's `/effort` |
| Playbooks | plain files under the router, all lazy. Steps copied into todos so they survive compaction |
| Principles | about 14 background skills, merged from pstack's 24, rewritten language-agnostic |
| Packs | background skills scoped with `paths`, holding each principle's language half and default verify commands |
| Profile | `.claude/pickle.md` in the user's project, injected by the router, written by `/pickle:setup` |
| Heavy tools | `bakeoff` and `adversarial-review` only when the user names them |
| Reply style | not pickle's job. Lives in the user's CLAUDE.md |
| Observability | Skill calls in the transcript, a `Loaded:` line at the end of each reply, optional mod pane |

| Effort | Signals | Runs |
|---|---|---|
| low | 1 or 2 files, no new data shape | main thread, verify |
| medium | a few files or a new data shape, clear design | `explore`, implement in main, verify, self-review |
| high | crosses modules, unclear design, or touches a profile gate | `explore`, `design-options`, implementer subagent, `review` |

## References

- Skills: https://code.claude.com/docs/en/skills
- Authoring best practices: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- Plugin manifest: https://code.claude.com/docs/en/plugins-reference
- Mods: https://code.claude.com/docs/en/plugins/mods/overview
- pstack upstream: https://github.com/cursor/plugins/tree/main/pstack
- pstack port, mod example: https://github.com/PickleBoxer/pstack
- Marketplace: https://github.com/PickleBoxer/claude-plugins
