# Claude Code notes for pickle

The Claude Code basics pickle builds on, the rules we follow, and what we measured that the docs do not say. For anything else, and before you rely on a detail here, read the current docs through the Claude Code Docs MCP server.

Marks: **read** = stated in the docs. **measured** = probed with a throwaway plugin (Claude Code 2.1.299, `claude -p`). **inferred** = our conclusion. Unmarked lines are read. Checked against the docs server on 2026-10-16.

## Contents

- Current docs
- Extension points
- Skills
- Subagents
- MCP
- Plugin
- Mods
- Best practices
- Unverified

## Current docs

The docs change with every Claude Code release, so this file keeps no field lists, tool tables or command lists. Ask the server:

1. `mcp__claude-code-docs__search_claude_code_docs` with a query. It returns page paths.
2. `mcp__claude-code-docs__query_docs_filesystem_claude_code_docs` with `cat`, `grep -n` or `sed -n` on `/en/<page>.mdx`.

Setup is in `AGENTS.md`, Working rules. Never answer Claude Code questions from memory or WebFetch, and tell research subagents the same.

| Topic | Page |
|---|---|
| Skill frontmatter, substitutions, `!` injection, compaction | `/en/skills.mdx` |
| Subagent frontmatter, nesting, forks, resume | `/en/sub-agents.mdx` |
| Built-in tools and which subagents get them | `/en/tools-reference.mdx` |
| Built-in commands and bundled skills | `/en/commands.mdx` |
| Hook events and types | `/en/hooks.mdx` |
| MCP config, scopes, tool names, tool search | `/en/mcp.mdx` |
| Plugin components and what each loads | `/en/plugins/components.mdx` |
| `plugin.json` keys | `/en/plugins/manifest-reference.mdx` |
| `claude plugin` commands | `/en/plugins/cli-reference.mdx` |
| Evals | `/en/plugin-evals.mdx` |
| Mods | `/en/plugins/mods/overview.mdx`, `reference.mdx`, `events.mdx`, `test.mdx` |
| CLAUDE.md, rules, auto memory | `/en/memory.mdx` |

## Extension points

What pickle uses, and the points that matter when choosing one.

| Point | Where | Cost until used | pickle uses |
|---|---|---|---|
| Skill | `skills/<name>/SKILL.md` | description, unless `disable-model-invocation` | `pickle-mode`, the vendored skills |
| Command | `commands/*.md` | description. Older format, the docs prefer skills | the 9 vendored commands |
| Agent | `agents/*.md` | description | the 4 vendored agents |
| Hook | `hooks/hooks.json` | 0 | no |
| Mod | `hooks/hooks.json` `modules` | 0 | no |
| MCP server | plugin root `.mcp.json` or `plugin.json` `mcpServers` | tool names, schemas deferred | no |
| Evals | `evals/` or `experimental.evals` | 0 | yes |
| Plugin `settings.json` | plugin root | 0. Only `agent` and `subagentStatusLine` take effect | no |
| Plugin `CLAUDE.md` | plugin root | **not loaded**, validate warns | no. `AGENTS.md` via `.claude/CLAUDE.md` is repo-only |

## Skills

Basics:

- Description plus `when_to_use` is cut at 1,536 characters in the skill listing (configurable with `skillListingMaxDescChars`). Put the key use case first.
- `disable-model-invocation: true`: user only. The description leaves context, and the skill cannot be called with the Skill tool, preloaded into a subagent or run by a scheduled task.
- `user-invocable: false`: Claude only, hidden from `/`. The description stays in context.
- `context: fork` runs the skill as a new subagent of the `agent` type, with the skill body as its prompt and no conversation history. `background: false` makes the caller wait.
- `metadata` is a free-form map Claude Code does not act on. pickle uses it for upstream source and version.
- Compaction re-attaches the latest invocation of each skill, first 5,000 tokens each, 25,000 total, most recent first. Files opened with Read are not re-attached. Put the important instructions near the top.
- Outside Claude Code (claude.ai, Skills API) only the six spec fields are valid. Other keys are a hard error.

Measured:

| Frontmatter | Claude (Skill tool) | Preload into subagent |
|---|---|---|
| `disable-model-invocation: true` | tool error, which also says "do not replicate this skill's workflow by other means" | skipped silently, no error |
| `user-invocable: false` | yes | yes |

- `disallowed-tools` is **not applied inside a `context: fork` subagent**: the fork still had Edit and Write. Restrict a fork through its `agent`'s `tools`.
- `paths` gates the description listing for project skills. **Plugin skills ignore it** and are listed from the start.
- `claude plugin validate --strict` does not check skill frontmatter: any unknown key passes. `scripts/check-refs.sh` checks it.
- `skillOverrides` in settings does not apply to plugin skills.
- A skill calls a sibling as `pickle:<name>`, or by bare name when unique. All three phrasings we tried led to a Skill tool call (9 of 9). pickle writes `the **name** skill (Skill tool, \`pickle:name\`)`: it names the tool and the exact name, and does not read as a command for the user.
- A skill that must load a `disable-model-invocation` skill has to Read its `SKILL.md`.

## Subagents

Basics:

- Plugin agents ignore `hooks`, `mcpServers` and `permissionMode` (and `initialPrompt`). Use the plugin's `hooks.json` and `.mcp.json`.
- When agents share a `name`, the higher-priority location wins and replaces the whole definition: managed, `--agents`, project, user, plugin (lowest). A plugin agent also answers to `pickle:<name>`.
- Nesting goes up to three layers below the main conversation. At the limit the Agent tool is withheld (a fork keeps it but gets an error). `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` changes the limit. A fork cannot spawn forks.
- A fork inherits the conversation, tools and model. A named subagent starts with only its prompt. A `context: fork` skill behaves like a named subagent, not a fork (inferred).

Measured:

- A `context: fork` skill invoked from the main thread does not use a nesting layer. One invoked inside it does.
- Inside a fork, an Agent call without `run_in_background` launched async: the fork returned before its child replied. With `run_in_background: false` it waited. **Fan-out skills must set it explicitly.**
- LSP is silently absent without a code-intelligence plugin, even when an agent's `tools` lists it.

pickle's rule (inferred): the vendored personas (`code-reviewer`, `security-auditor`, `test-engineer`, `web-performance-auditor`) are called by bare name, as upstream does, so a project or user agent can override them. Pin with `pickle:<name>` when an override must not apply.

## MCP

Basics:

- Scopes: local (default, `~/.claude.json` under the project path), project (root `.mcp.json`, shared), user (`~/.claude.json`).
- Tool names: `mcp__<server>__<tool>`. Plugin servers: `mcp__plugin_<plugin>_<server>__<tool>`.
- Tool search is on by default: only names sit in context, schemas load through ToolSearch.
- An agent `tools` allowlist without MCP names gives no MCP tools. `mcp__<server>__*` adds them.
- Eval runs never start a plugin's real MCP servers unless asked. A tool needs a mock in `evals/mocks/<server>/<tool>.md`.

pickle's rules (inferred):

- pickle ships no MCP server. Never add a root `.mcp.json`: it would ship to every user. Maintainer servers go in local or user scope, or `.claude/mcp.json`.
- Skills cannot know the user's server names. They describe the job ("the issue tracker").

## Plugin

Measured:

- `.claude-plugin/plugin.json` alone makes a folder a valid plugin.
- A skill named like its plugin becomes `/pickle:pickle`, which is why the entry skill is `pickle-mode`.
- Unknown top-level `plugin.json` keys are stripped with a warning, so `validate --strict` fails (read).
- `npx skills add PickleBoxer/pickle --skill '*'` installs skill files only: no agents, mod or `userConfig`. Skills must work without them.
- `version` in `plugin.json` is semver. Claude Code updates users only when it changes, so bump it on every release. Set it in `plugin.json` only, never also in the marketplace entry. Tag each release `pickle--v<version>`, the form plugin dependency ranges resolve against.

## Mods

A mod is a plugin with function hooks, on by default from Claude Code 2.1.287. The API moves between releases, so the generated types and the `plugin-authoring` skill are the authority. Load that skill before writing mod code, and write the code in this repo.

- Files: `hooks/hooks.json` (`{ "modules": ["./register.tsx"] }`) and `hooks/register.tsx`. A mod that keeps `$.state` names a contract in `plugin.json` (`"types": "./types/index.d.ts"`) that declares each key inline under `interface PluginState`.
- Mods draw in the terminal, the desktop Code tab and the VS Code extension, but hooks also run under `claude -p`.
- Tests: `claude plugin test .`, which needs at least one `*.test.ts` or `*.test.tsx`. A hook that passes to `next` in a `ui.render` test needs a test hook that draws for the engine.
- `$.command.register({ name })` declares a bare `/<name>`, not `/<plugin>:<name>`, so prefix the name with the plugin's. A `command.run` matcher must name it as a literal, or `validate` lists the hook as a gate.
- Desktop (measured, 2.1.309): a docked `Pane` opens as its own region on the right, over the session details panel. No render site draws inside that panel.
- pickle's mod: the welcome band (`AbovePrompt`, terminal and desktop only, hidden by Hide or any `/pickle:` command), the task tip (`prompt.submit` toast, once a session), the review suggestion (`turn.complete`, after a turn with edits) and the guide pane (`/pickle-guide`).

## Best practices

- Prefer a skill over a command, hook or mod. Add a hook or mod only for something a skill cannot enforce, such as a gate on a tool call.
- Keep descriptions short, key use case first. Every model-invocable description costs context in every session.
- Make a skill user-only (`disable-model-invocation`) only when Claude must never start it. pickle's skills cannot call a user-only skill with the Skill tool.
- Restrict a forked skill's tools through its `agent`, not `disallowed-tools`.
- Set `run_in_background` explicitly on every Agent call in a fan-out skill.
- Name skills with the Skill tool form above, and agents by bare name unless they must be pinned.
- Ship nothing that depends on the user's settings or agents. A skill must still work when installed with `npx skills add`.
- A skill may use an MCP server the user adds. List it in README, Optional extras, with what the skill loses without it.
- Measure before relying on a behaviour the docs do not state: probe it with a throwaway plugin under `claude --plugin-dir`, then record it here with its mark.

## Unverified

Test each with a throwaway skill under `claude --plugin-dir` before pickle relies on it, then move the answer into the section above.

1. Glob and Grep in interactive sessions (measured present only under `claude -p`).
2. A skill call from a long skill body as reliable as from the short probe bodies.
