# Claude Code native features

What Claude Code ships that a workflow plugin like pickle can build on: extension points, skills, subagents, tools, bundled skills, commands, hooks, MCP, background work and the plugin manifest. The last column of some tables says where pickle uses a feature. [pstack.md](pstack.md) maps pstack's skills onto these features.

Sources: the Claude Code docs at <https://code.claude.com/docs/en/> (skills, sub-agents, agent-teams, commands, tools-reference, hooks, plugins/components, plugins/manifest-reference, plugins/cli-reference, plugins/mods/overview, memory, output-styles, permission-modes, worktrees, scheduled-tasks, checkpointing, headless, mcp, mcp-quickstart, permissions, settings-reference, plugin-evals). Checked 2026-10-14 on Claude Code 2.1.296. The MCP section was read through the Claude Code Docs MCP server on 2026-10-14. Recheck after Claude Code updates.

Marks: **read** = stated in the docs. **measured** = probed with a throwaway plugin (2026-10-14, Claude Code 2.1.299, Haiku, `claude -p`, `--setting-sources project,local`). **unverified** = the docs are silent or unclear. **inferred** = our conclusion.

## Contents

- Extension points
- Skills
- Subagents
- Built-in subagent types
- Tools
- Bundled skills
- Built-in commands
- Hooks
- MCP
- Background, scheduling and parallel work
- Plugin manifest and CLI
- Mods
- Project instructions and modes
- Unverified

## Extension points

| Point | Where | Loaded | Cost until used | pickle uses |
|---|---|---|---|---|
| Skill | `skills/<name>/SKILL.md` | description always (unless `disable-model-invocation`), body on invoke | description, max 1,536 chars | yes: `pickle-mode`, the vendored skills |
| Command | `commands/*.md` | flat markdown, docs prefer skills | description | no |
| Agent | `agents/*.md`, subfolders join with `:` | description always, body when spawned | description | yes: explorer, implementer, reviewer |
| Hook | `hooks/hooks.json`, skill or agent frontmatter, settings | on event | 0 | not yet |
| Mod | `hooks/hooks.json` `modules` plus `register.tsx` | JS/TS handlers in process, 2.1.287+ | 0 | planned (observability) |
| MCP server | plugin root `.mcp.json` or `plugin.json` `mcpServers` | starts when the plugin is enabled, tools deferred behind ToolSearch | tool names | no. See MCP |
| LSP server | `.lsp.json`, binary on user PATH | on matching files | 0 | no |
| Output style | `output-styles/*.md`, used as `<plugin>:<name>` | when selected | 0 | no (reply style is the user's) |
| Monitor | `monitors/monitors.json` via `experimental.monitors`, `when: always` or `on-skill-invoke:<skill>` | interactive sessions only | 0 | `babysit` uses the Monitor tool on `gh pr checks --watch`; a plugin monitor is not used |
| Executables | `bin/` on Bash PATH | while enabled. Not installed by claude.ai, Cowork or `npx skills add` | 0 | no (scripts stay in skill folders) |
| Workflow | `workflows/*.js` | dynamic workflows | unverified | no |
| Theme | `themes/*.json` via `experimental.themes` | when selected | 0 | no |
| Plugin settings | `settings.json` at plugin root | only `agent` and `subagentStatusLine` take effect | 0 | no |
| Evals | `evals/` or `experimental.evals` | `claude plugin eval` | 0 | yes |
| Plugin `CLAUDE.md` | plugin root | **not loaded**, validate warns | n/a | no (AGENTS.md via `.claude/CLAUDE.md` is repo-only) |

## Skills

Frontmatter (read; unknown keys ignored):

| Field | Meaning |
|---|---|
| `name` | `/` name, defaults to folder. In a plugin it is the last segment: `/pickle:<name>` |
| `description` | what and when. Truncated with `when_to_use` at 1,536 chars |
| `when_to_use` | extra triggers, same cap |
| `argument-hint` | autocomplete hint |
| `arguments` | named positional args for `$name` |
| `disable-model-invocation` | `true`: user only. Description not in context. Blocks Skill tool, subagent preload and scheduled-task runs |
| `user-invocable` | `false`: Claude only, hidden from `/`. Description stays in context |
| `allowed-tools` | tools usable without asking during the invoking turn |
| `disallowed-tools` | tools removed while active. **Not applied inside a `context: fork` subagent**: the fork still had Edit and Write (measured). Restrict a fork through its `agent`'s `tools` instead |
| `model`, `effort` | override for the current turn |
| `context: fork` | run as a new subagent of type `agent`, skill body as its prompt, no conversation history |
| `agent` | subagent type for the fork, default `general-purpose` |
| `background` | with fork, `false` waits (2.1.218+). Forced to wait under `-p`, SDK, scheduled fires |
| `hooks` | registered on invoke, kept for the session. `once: true` honoured only here |
| `paths` | globs. Gates the description listing, not the body: a project skill is listed only after a matching file is read, then Claude decides whether to invoke it (measured). **Ignored for plugin skills**: listed from the start (measured) |
| `shell` | `bash` or `powershell` for `!` injection |
| `metadata` | free-form map, ignored by Claude Code. Use for upstream source and version. Passes `validate --strict` (measured), but so does any unknown skill key: `--strict` does not check skill frontmatter |
| `license`, `compatibility` | accepted, not acted on |

Invocation matrix (read, measured where marked):

| Frontmatter | User | Claude (Skill tool) | Description in context | Preload into subagent |
|---|---|---|---|---|
| default | yes | yes | yes | yes |
| `disable-model-invocation: true` | yes | no: tool error that also says "do not replicate this skill's workflow by other means" (measured) | no | no: skipped silently, no error (measured) |
| `user-invocable: false` | no | yes | yes | yes (measured) |

Substitutions: `$ARGUMENTS` (appended as `ARGUMENTS: ...` if no placeholder), `$N` and `$ARGUMENTS[N]`, `$name`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_PLUGIN_ROOT}` (changes on update), `${CLAUDE_PLUGIN_DATA}` (persists), `${CLAUDE_SESSION_ID}`, `${CLAUDE_EFFORT}`, `${user_config.KEY}`.

`` !`command` `` injection: runs before Claude sees the skill. Exit 2 or higher aborts the invocation. Needs an allow rule or `allowed-tools`, else aborts outside auto mode. 2 min timeout. Fenced ` ```! ` runs each line.

Skill tool names (measured): a skill body can call a sibling as `pickle:<name>` or by its bare name when it is unique. Both run. Phrasing (measured, Haiku, 3 runs each, three-line skill body): `**callee** (/probe:callee)`, `the **callee** skill` and `the **callee** skill (Skill tool, \`probe:callee\`)` all led to a Skill tool call, 9 of 9. pickle uses the last form: it names the tool and the exact name, so it needs no rule from elsewhere and does not read as a command for the user.

Locations: enterprise beats personal (`~/.claude/skills`) beats project (`.claude/skills`). Nested and `--add-dir` also load. Plugin skills are namespaced, so they never collide.

Compaction: the latest invocation of each skill is re-attached, first 5,000 tokens each, 25,000 total, most recent first. Files opened with Read are not.

Outside Claude Code (claude.ai, Skills API): only `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`. Other keys are a hard error.

## Subagents

Frontmatter (read):

| Field | Plugin agents | Meaning |
|---|---|---|
| `name`, `description` | yes | id (no `:`), when to delegate |
| `tools`, `disallowedTools` | yes | allowlist, denylist |
| `model` | yes | `sonnet`, `opus`, `haiku`, `fable`, full id, `inherit` |
| `effort` | yes | low to max |
| `maxTurns` | yes | partial result at the limit, resumable |
| `skills` | yes | preload full skill content, first 32 names. Does not restrict Skill tool. `disable-model-invocation` skills cannot be preloaded |
| `memory` | unverified | `user`, `project`, `local` |
| `background` | yes | always background |
| `isolation` | yes | `worktree`: temporary git worktree |
| `color` | yes | display |
| `omitClaudeMd` | yes | start without CLAUDE.md (2.1.271+) |
| `experimental.cacheTtl` | yes | `5m` or `1h` |
| `hooks`, `mcpServers`, `permissionMode`, `initialPrompt` | **ignored** | security. Use plugin `hooks.json` and `.mcp.json` |

Model order: Agent call `model` parameter, then frontmatter, then `CLAUDE_CODE_SUBAGENT_MODEL`, then main model. A mod `agent.spawn` hook can override. `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` makes the env var win.

Same name (read): when several agents share a `name`, the higher-priority location wins: managed settings, then `--agents`, then project `.claude/agents/` (closest to the working directory first), then `~/.claude/agents/`, then a plugin's `agents/` (lowest). The winner replaces the whole definition, nothing merges. A plugin agent also answers to its scoped name `plugin:name`, which picks that exact agent. `claude --agent name` finds a plugin agent by bare name (read). That the Agent tool's `subagent_type` resolves a bare name by the same priority is inferred, not measured. So a caller that passes the bare `name` lets a project or user agent override pickle's, and one that passes `pickle:name` pins pickle's. pickle's own tools pin (`pickle:pickle-reviewer`). The vendored agent-skills personas (`code-reviewer`, `security-auditor`, `test-engineer`, `web-performance-auditor`) are called by bare name, as upstream does, so they are overridable.

Nesting (read): "By default, a subagent can spawn subagents of its own, up to three layers below the main conversation." At the limit the Agent tool is withheld from every subagent except a fork. `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1` disables nesting. "A fork can't spawn further forks."

Nesting (measured):

- Named agents only: main, then layers 1, 2, 3. The layer 3 agent has no Agent tool.
- A `context: fork` skill invoked from the main thread does not use a layer. A `context: fork` skill invoked inside it does. Measured chain: fork, nested fork, agent, agent; the last one had no Agent tool.
- With `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1`, a top-level forked skill still fans out to two agents. A forked skill inside it gets no Agent tool and reports that instead of failing. With pickle's former skills: `architect` under depth 1 still started both Plan runners, and the nested `how` followed its fallback, reading the code itself and saying so under Not checked.
- Waiting: inside a fork, an Agent call without `run_in_background` launched async. The nested fork returned before its child replied, and the late completions surfaced on the main thread as extra turns. With `run_in_background: false` the fork waited and got the reports through SubagentHandback. Fan-out skills must set it explicitly.

Fork vs named: a fork inherits the full conversation, tools and model and shares the prompt cache (`/subtask`, or Claude asks for the fork type). A named subagent starts fresh with only the prompt. A `context: fork` skill starts a subagent of the `agent` type with the skill as prompt (read), so it behaves like a named subagent, not a fork (inferred).

Background: fork mode is the interactive default, so subagents run in the background. Permission prompts surface in the main session. `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` forces foreground.

Resume: SendMessage to the agent id or `name` resumes it with full history. Works without agent teams. Explore and Plan cannot be resumed. Transcripts: `~/.claude/projects/<project>/<session>/subagents/agent-<id>.jsonl`.

Tools every subagent loses: AskUserQuestion, EnterPlanMode, ExitPlanMode (unless `plan` mode), ScheduleWakeup, WaitForMcpServers, Workflow, EndConversation, and Agent at the depth limit. Background subagents keep only: Read, Grep, Glob, LSP, Bash, PowerShell, Edit, Write, NotebookEdit, WebFetch, WebSearch, TodoWrite, Skill, ToolSearch, EnterWorktree, ExitWorktree, Monitor, TaskStop, SendMessage, Artifact, SubagentHandback, MCP tools.

Agent teams (read): experimental, off by default, `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. A lead plus teammates with their own context, a shared task list and a mailbox. When on, a named subagent spawns as a teammate. Not in `-p` or the SDK. No nested teams. The `skills` field is not applied to teammates. Hooks: TeammateIdle, TaskCreated, TaskCompleted.

## Built-in subagent types

| Type | Job | Model | Tools |
|---|---|---|---|
| `Explore` | fast read-only search, thoroughness quick to very thorough | main model (opus alias on a Fable main model) | read-only, no CLAUDE.md or git status |
| `Plan` | research for plan mode | main model | read-only, no CLAUDE.md or git status |
| `general-purpose` | multi-step work | `CLAUDE_CODE_SUBAGENT_MODEL` or main | all subagent tools |
| `claude` | catch-all, default for dispatched background sessions | subagent model order | all subagent tools |
| `statusline-setup` | `/statusline` | sonnet | unverified |
| `claude-code-guide` | questions about Claude Code | haiku | unverified |

A project or user agent named `Explore` overrides the built-in.

## Tools

Grouped. "Sub" = available to background subagents.

| Group | Tool | Job | Permission | Sub | Notes |
|---|---|---|---|---|---|
| Files | Read, Write, Edit, NotebookEdit | read and change files | Write, Edit yes | yes | |
| Search | Glob, Grep | find files, search content | no | yes | absent by default on macOS and Linux, Bash `find`/`grep` instead (read). Present under `claude -p` on macOS, also in a plugin agent with `tools: Read, Grep, Glob, LSP` (measured). Interactive sessions: unverified |
| Search | LSP | definitions, references, diagnostics | no | yes | needs a code-intelligence plugin. Without one it is silently absent, even when an agent's `tools` lists it (measured) |
| Shell | Bash, PowerShell | commands, `run_in_background` | yes | yes | 2 min default, 10 min max |
| Shell | Monitor | stream a background command's lines to Claude | yes | yes | 5 min default, 30 max, 10 under `-p`. Not on Bedrock, Vertex, Foundry |
| Shell | TaskStop | stop a background task | no | yes | |
| Delegation | Agent | spawn a subagent: `subagent_type`, `model`, `effort`, `isolation`, `run_in_background`, `name` | no | until depth limit | |
| Delegation | SendMessage | message a teammate, resume a subagent, message a session | no | yes | 2.1.224+ |
| Delegation | ListAgents | list messageable agents and sessions | no | foreground only | |
| Delegation | SubagentHandback | subagent delivers its report | no | auto mode | 2.1.271+ |
| Skills | Skill | run a skill in the current context | yes | yes | blocked by `disable-model-invocation` |
| Planning | TaskCreate, TaskGet, TaskList, TaskUpdate | session todo list | no | teammates only | TodoWrite is the legacy fallback |
| Planning | EnterPlanMode, ExitPlanMode | plan mode | Exit yes | no | |
| User | AskUserQuestion | multiple choice | no | no | removed by `--permission-prompts none` |
| User | PushNotification, SendUserFile | notify, send a file | no | no | |
| Scheduling | ScheduleWakeup | next self-paced `/loop` iteration, 1 min to 1 h | no | no | |
| Scheduling | CronCreate, CronList, CronDelete | session cron, 50 max, 7-day expiry | no | teammates only | |
| Scheduling | RemoteTrigger | cloud routines (`/schedule`) | no | no | |
| Worktrees | EnterWorktree, ExitWorktree | enter or leave `.claude/worktrees/<name>` | Enter yes | yes | Exit not for `isolation` subagents |
| Web | WebFetch, WebSearch | fetch, search | yes | yes | |
| Other | ToolSearch | load deferred tools | no | yes | |
| Other | Artifact | publish HTML or Markdown | yes | yes | paid plans |
| Other | ReportFindings | structured review findings | no | unverified | used by `/code-review` |
| Other | Workflow | run a dynamic workflow | yes | no | |

## Bundled skills

| Skill | Job | Spawns | Claude can invoke |
|---|---|---|---|
| `/batch <instruction>` | split a large change into 5 to 30 units, plan, run | one background subagent per unit, each in its own worktree | **no**, `disable-model-invocation` (measured) |
| `/simplify [target]` | cleanup review: reuse, simplicity, efficiency, abstraction. Not a bug hunt | 4 review agents in parallel | yes (measured) |
| `/code-review [effort] [--fix] [--comment] [--max-findings] [target]` (alias `/review`) | correctness review of a diff or PR. `ultra` runs a cloud review (`/ultrareview`) | forked subagent | yes (measured) |
| `/loop [interval] [prompt]` | repeat a prompt while the session is open. Self-paced without interval. Default prompt from `.claude/loop.md` | ScheduleWakeup | unverified |
| `/debug [description]` | debug logging and log analysis | unverified | unverified |
| `/verify` | build, run and observe the app | unverified | **no**, user only |
| `/run [description]` | launch and drive the app to check a change | unverified | unverified |
| `/run-skill-generator` | write a per-project run skill to `.claude/skills/run-<name>/` | unverified | unverified |
| `/claude-api [subcommand]` | Claude API reference, incl. `build-eval`, `hillclimb`, `prompt-audit` | none | yes, auto on SDK imports |
| `/fewer-permission-prompts` | add a read-only allowlist from transcripts | unverified | unverified |
| `/doctor [prompt-audit [path]]` | setup checkup, prompt audit | unverified | unverified |
| `/update-config [request]` | edit settings.json | unverified | unverified |
| `/plugin-authoring`, `/workflow-authoring` | mod and workflow references | none | unverified |
| `/dataviz`, `/design`, `/design-sync`, `/slides`, `/artifact-capabilities`, `/artifact-diagramming`, `/claude-in-chrome` | design, charts, artifacts, browser | unverified | unverified |
| `/deep-research <question>` (workflow) | cited multi-search report | background subagents | no, user only |

`/security-review` reviews the branch diff against origin's default branch. Claude can call it with the Skill tool (measured). Its `` !`git diff origin/HEAD...` `` injection aborts the call in a repo without `origin/HEAD`.

## Built-in commands

Relevant to a workflow plugin:

| Command | Job |
|---|---|
| `/agents`, `/skills`, `/skill-doctor` | manage subagents, list skills, skill context cost and usage |
| `/plugin`, `/reload-plugins`, `/reload-skills` | manage and reload |
| `/hooks`, `/permissions`, `/config`, `/memory`, `/init` | inspect configuration |
| `/plan`, `/goal <condition>` | plan mode, keep working across turns until a condition holds |
| `/subtask <task>` | forked subagent whose result returns here |
| `/background`, `/fork`, `/tasks`, `/stop` | background sessions and tasks |
| `/branch`, `/rewind`, `/compact`, `/context`, `/btw` | conversation control |
| `/schedule` (`/routines`) | cloud routines |
| `/autofix-pr` | cloud session fixes CI and review comments on the PR |
| `/security-review`, `/ultrareview`, `/diff` | review |
| `/model`, `/effort`, `/fast`, `/output-style`, `/advisor` | model and style |
| `/list-agents` | messageable agents and sessions |
| `/insights`, `/usage`, `/recap` | reports |

Others (UI, account, setup): `/add-dir`, `/cd`, `/artifacts`, `/auto-mode-setup`, `/autocompact`, `/bug`, `/chrome`, `/clear`, `/color`, `/copy`, `/design-login`, `/desktop`, `/doctor`, `/exit`, `/export`, `/feedback`, `/focus`, `/heapdump`, `/help`, `/ide`, `/import`, `/install-github-app`, `/install-slack-app`, `/keybindings`, `/login`, `/logout`, `/mcp`, `/mobile`, `/passes`, `/powerup`, `/privacy-settings`, `/radio`, `/rate-limit-options`, `/release-notes`, `/remote-control`, `/remote-env`, `/rename`, `/resume`, `/sandbox`, `/scroll-speed`, `/setup-bedrock`, `/setup-vertex`, `/stats`, `/status`, `/statusline`, `/stickers`, `/team-onboarding`, `/teleport`, `/terminal-setup`, `/theme`, `/tui`, `/upgrade`, `/usage-credits`, `/voice`, `/web-setup`, `/workflows`.

Removed: `/pr-comments`, `/vim`, `/ultraplan`. `/review` became an alias of `/code-review` in 2.1.223.

## Hooks

Types: `command` (shell or exec form, `async`, `onFailure`), `http`, `mcp_tool`, `prompt` (single-turn yes/no), `agent` (experimental, a subagent with Read, Grep, Glob). Common fields: `if` (permission rule syntax), `timeout`, `statusMessage`, `once` (skill frontmatter only).

Defined in: user, project and local settings, managed policy, plugin `hooks/hooks.json`, skill frontmatter (rest of session), agent frontmatter (while it runs; ignored for plugin agents).

| Event | Blocks | Use for pickle |
|---|---|---|
| SessionStart | no | |
| Setup | no | |
| UserPromptSubmit, UserPromptExpansion | yes | |
| PreToolUse | yes | gate actions (none shipped) |
| PermissionRequest | yes (JSON) | |
| PermissionDenied | no | |
| PostToolUse | no, can feed back | comment lint, load log |
| PostToolUseFailure, PostToolBatch | batch: yes | |
| Notification, MessageDisplay | no | |
| SubagentStart | no | |
| SubagentStop | yes | check a subagent report has the required sections |
| TaskCreated, TaskCompleted | yes | check skipped todos carry `skip: <reason>` |
| Stop | yes | check the `Loaded:` line |
| StopFailure | no | |
| TeammateIdle | yes | |
| InstructionsLoaded | no | |
| ConfigChange | yes | |
| CwdChanged, DirectoryAdded, FileChanged | no | |
| WorktreeCreate, WorktreeRemove | create yes | |
| PreCompact | yes | |
| PostCompact | no | |
| PreModelSwitch, PostModelSwitch | pre yes | |
| Elicitation, ElicitationResult | yes | |
| SessionEnd | no | |

Mods (2.1.287+): JS/TS handlers in process, events like `skill.prompt`, `tool.call`, `agent.spawn`, `prompt.submit`, `session.compact`, `command.run`, `ui.render`. Draw only in the terminal and the desktop Code tab, run everywhere. Not sandboxed. Built-in mods: `cc-plugin-agents-md`, `cc-plugin-diff`, `cc-plugin-plugin-authoring`, `cc-plugin-sec-default`, `cc-plugin-telemetry`, `cc-plugin-you-should-know`.

## MCP

All **read** unless marked. The served `mcp` page stops partway through: it lacks the sections on tool search, resources, prompts, elicitation and output limits. Facts on those come from other pages.

### Config and scopes

- Transports: `http`, `sse`, `stdio` (command after `--`), `ws` (only through `.mcp.json` or `claude mcp add-json`, header auth only).
- Scopes: local (the default, in `~/.claude.json` under the project path, not `.claude/settings.local.json`), project (`.mcp.json` at the repo root, shared), user (`~/.claude.json`, every project).
- Precedence, whole entry wins: managed, then local, project, user, plugin servers, claude.ai connectors. Scopes match duplicates by name, plugins and connectors by URL or command.
- `.mcp.json` takes `{"mcpServers": {...}}`. An entry with a `url` but no `type` is read as stdio and fails. `${VAR}` and `${VAR:-default}` expand. Credential variables such as `ANTHROPIC_API_KEY` read as empty in remote URLs and headers.
- Project `.mcp.json` servers need approval in interactive sessions. Under `claude -p`, the SDK and cloud sessions they load without a prompt. `disabledMcpjsonServers`, `--setting-sources` or `--strict-mcp-config` block them.
- Reserved names, skipped at load: `workspace`, `claude-in-chrome`, `computer-use`, `Claude Preview`, `Claude Browser`.

### Tool names and loading

- Name: `mcp__<server>__<tool>`. claude.ai connectors: `mcp__claude_ai_<server>__<tool>`. Plugin servers: `mcp__plugin_<plugin>_<server>__<tool>`, with characters outside `A-Za-z0-9_-` turned into `_`. A plugin server registers as `plugin:<plugin>:<server>`.
- Tool search is on by default: only names sit in context, schemas load through ToolSearch. `alwaysLoad: true` on a server skips deferral. Off with `ENABLE_TOOL_SEARCH=false` or a third-party `ANTHROPIC_BASE_URL`.
- Failed servers are reported to Claude only through tool search. Without it, Claude does not learn that a server failed.
- Output: a warning above 10,000 tokens, a cap of 25,000 (`MAX_MCP_OUTPUT_TOKENS`). Text over 50,000 characters is saved to a file.
- Timeouts: `MCP_TIMEOUT` for startup, a per-server `timeout` in ms as a hard wall-clock limit, idle timeout 5 minutes for remote servers and 30 for stdio.
- A main-thread MCP call still running after 2 minutes becomes a background task. Subagent calls never do.

### Subagents, skills and permissions

- Subagents inherit the main conversation's MCP tools, and background subagents keep all of them. A `tools` allowlist without MCP names gives no MCP tools. `tools` and `disallowedTools` accept `mcp__<server>`, `mcp__<server>__*`.
- Agent `mcpServers` frontmatter (a name, or an inline server that connects only for the subagent) is ignored for plugin agents.
- Skill `allowed-tools` pre-approves MCP tools for the invoking turn by full name. It does not restrict which tools exist.
- Permission rules: `mcp__<server>`, `mcp__<server>__*`, `mcp__<server>__<tool>`. An allow rule `mcp__*` is skipped with a warning, deny and ask accept it. Rules with arguments in parentheses are skipped.
- Hook matchers need the tool part: `mcp__memory__.*` matches, `mcp__memory` matches nothing. Plugin servers: `mcp__plugin_<plugin>_<server>__.*`.

### Plugins and evals

- A plugin ships servers in `.mcp.json` at its root or in `plugin.json` `mcpServers`. `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}` and `${CLAUDE_PROJECT_DIR}` expand. `claude plugin validate` checks `.mcp.json`. Plugin servers start on enable and leave only on uninstall.
- `claude plugin eval` never loads personal MCP servers or any `.mcp.json`. Under the default `--mocks record`, plugin servers do not start: a tool with a mock in `evals/mocks/<server>/<tool>.md` works, one without is unavailable. `--allow-real-servers` starts real ones, which also need `--allow-tools "mcp__plugin_<plugin>_<server>__*"`.

### What this means for pickle

Inferred from the facts above.

- pickle ships no MCP server. Never add a root `.mcp.json` to this repo: it would ship to every user. Maintainer servers go in local or user scope.
- An agent that lists `tools` without MCP names gets no MCP tools. A skill that needs history, issues or logs from an MCP server either names `mcp__<server>__*` in the agent's `tools` or runs the query on the main thread.
- Skills cannot know the user's server names. They describe the job ("the issue tracker").
- An eval case that needs an MCP tool needs a mock, since personal servers never load in a run.

### Claude Code Docs server

`https://code.claude.com/docs/mcp`, HTTP, no auth. Tools: `search_claude_code_docs` (search, returns page paths) and `query_docs_filesystem_claude_code_docs` (read-only `ls`, `cat`, `grep`, `sed -n` over the pages, as `/en/<page>.mdx`). Added to this repo at local scope with `claude mcp add --transport http claude-code-docs https://code.claude.com/docs/mcp`, so its tools are `mcp__claude-code-docs__*`. Not the claude.ai "Claude Docs" connector, which edits shareable documents.

## Background, scheduling and parallel work

| Need | Native feature | Limits |
|---|---|---|
| Run a long command and keep working | Bash `run_in_background`, `/tasks` | `-p` waits, 10 min default |
| React to each output line (CI, logs, builds) | Monitor | 30 min max, 10 under `-p` |
| Repeat until done in an open session | `/loop`, self-paced with ScheduleWakeup | open sessions only. Skills with `disable-model-invocation` do not run from a scheduled fire |
| Keep going across turns until a condition | `/goal <condition>` | unverified details |
| Timed prompts in this session | CronCreate | 50 per session, 7 days, restored on resume |
| Timed runs without a session | Routines (cloud, 1 h min), Desktop scheduled tasks (local, 1 min min) | |
| Parallel independent units | `/batch` (5 to 30 worktree subagents), or Agent calls with `isolation: "worktree"` and `run_in_background` | |
| Parallel opinions | several Agent calls in one message, different briefs or models | one model family |
| Long-lived collaborators | agent teams, or named subagents plus SendMessage | teams experimental |
| Isolated checkout | `claude -w <name>`, EnterWorktree, agent `isolation: worktree`, `.worktreeinclude` | |
| Undo | checkpoints, `/rewind` | Bash and subagent edits not tracked |

## Plugin manifest and CLI

`plugin.json` keys: `name` (required, namespace), `displayName`, `version` (free string, pins users), `description`, `author`, `homepage`, `repository`, `license`, `keywords`, `metadata` (free-form, 2.1.222+), `icon`, `documentationUrl`, `supportUrl`, `privacyPolicyUrl`, `termsOfServiceUrl`, `defaultEnabled`, `dependencies`, `settings`, `userConfig`, `types`, `channels`, component paths (`skills`, `commands`, `agents`, `hooks`, `mcpServers`, `lspServers`, `outputStyles`, `workflows`), `experimental` (`themes`, `monitors`, `evals`). Unknown top-level keys are stripped with a warning, so `validate --strict` fails.

`userConfig` fields: `type` (string, number, boolean, directory, file), `title`, `description`, `required`, `default`, `options` (2.1.271+), `multiple`, `sensitive`, `min`, `max`. Used as `${user_config.KEY}` or `CLAUDE_PLUGIN_OPTION_<KEY>` in hooks.

CLI: `claude plugin init | install | uninstall | enable | disable | update | list | details | configure | prune | tag | validate [--strict] | test | eval | eval init | marketplace ...`.

Plugin facts (learned while porting pstack, recheck after updates):

- `.claude-plugin/plugin.json` alone makes a folder a valid plugin. Skills load from `skills/<folder>/SKILL.md`, agents from `agents/*.md` as `pickle:<name>`.
- A skill named like its plugin becomes `/pickle:pickle`, which is why the entry skill is `pickle-mode`.
- A skill that must load a `disable-model-invocation` skill has to Read its `SKILL.md`.
- `skillOverrides` in settings does not apply to plugin skills.
- `npx skills add PickleBoxer/pickle --skill '*'` installs skill files only: no agents, mod or `userConfig`. Skills must work without them.
- Version is semver in `plugin.json`. Claude Code updates users when it changes. Tag each release `v<version>`.

## Mods

A plugin with function hooks. Claude Code 2.1.287+ (verified on 2.1.296), early access, moves between releases. The generated types are the authority. Load the `plugin-authoring` skill before writing mod code, and write it in this repo.

- Files: `hooks/hooks.json` (`{ "modules": ["./register.tsx"] }`) and `hooks/register.tsx` exporting `register: Register` from `'claude-code'`. `$.state` keys go in `types/index.d.ts` under `interface PluginState`, named in `plugin.json` as `"types"`; `validate` checks them.
- Every hook is `($, e, next)`. `next(e)` continues, returning without it answers alone, `next({ ...e, x })` rewrites.
- No DOM, no Node, everything through `$`. Only static `import` of the plugin's own files and `'claude-code'`.
- UI: `$.ui.resolve(e)` gives `Box`, `Text`, `Button`. Panes via `$.ui.open` plus a `ui.render` hook on `Pane`, bands via `AbovePrompt`. Draws only in the terminal and the desktop Code tab. Hooks still run under `claude -p`.
- Slash commands: `$.command.register` in `session.start`, answered by `command.run`.
- Guards (`tool.call`, `prompt.submit`, `command.run`, ...) are skipped if they throw, unless `.catch` answers: `on(...).catch(($, e, next) => next.called ? next(e) : { deny: 'why' })`.
- Types: the engine writes the gitignored `.claude-plugin/types/` when it loads the mod from a watched folder. `tsc -p .` type-checks. `claude --debug` shows skipped hooks.
- Tests: `*.test.ts` importing `test`, `expect`, `mock` from `claude-code/testing`, run by `claude plugin test .`, which needs at least one test. Loop UI tests over `['terminal', 'desktop'] as const`.
- Events pstack's mod used: `skill.prompt`, `tool.call`, `agent.spawn`, `prompt.submit`, `prompt.compose`, `session.compact`, `command.run`, `command.describe`, `ui.render`.

## Project instructions and modes

| Feature | Summary |
|---|---|
| CLAUDE.md | every session. `@path` imports, 4 hops. `AGENTS.md` read when no CLAUDE.md exists (configurable) |
| `.claude/rules/*.md` | optional `paths` frontmatter scopes a rule to matching files. User rules in `~/.claude/rules/` |
| Auto memory | `MEMORY.md` first 200 lines or 25 KB at start, topic files on demand |
| Output styles | Default, Proactive, Concise, Explanatory, Learning, or custom |
| Permission modes | default, acceptEdits, plan, auto, dontAsk, bypassPermissions. `--permission-prompts none` for unattended runs |
| Headless `-p` | `--output-format`, `--json-schema`, `--allowedTools`, `--max-budget-usd`. `--bare` skips plugins, skills, hooks, CLAUDE.md |

## Unverified

Open items. Test each with a throwaway skill under `claude --plugin-dir` before pickle relies on it, then move the answer into the section above.

1. Glob and Grep in interactive sessions (measured present only under `claude -p`).
2. Haiku calling a skill from a long skill body as reliably as from the short probe bodies.

Resolved on 2026-10-14 (measured, see the sections above): Skill tool calls between plugin skills, nesting depth and forks, `paths` on plugin skills, `metadata` under `--strict`, bundled skills through the Skill tool, preloading `user-invocable: false` skills, `pickle-explorer` search on macOS (since removed).
