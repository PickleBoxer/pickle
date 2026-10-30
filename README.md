# pickle

Engineering workflow skills for Claude Code, built on Addy Osmani's [agent-skills](https://github.com/addyosmani/agent-skills). Start a task with `/pickle:pickle-mode` and it picks the workflow skills that fit, from spec and planning to review and shipping.

> Early. agent-skills is the baseline, and pickle's own pieces are added back one at a time when evals or real use show a gap. Releases stay below 1.0 until the evals are done.

## How it works

```
/pickle:pickle-mode add an OrderStatus enum to orders
/pickle:pickle-mode extract the payment gateway behind an interface
```

- **Entry skill.** `pickle-mode` is agent-skills' `using-agent-skills`, rewritten on `main` and started only by you: a list of the workflow skills by phase, from Define to Ship, that it loads for the task, plus the operating rules every skill follows (surface assumptions, push back, keep scope, verify).
- **24 workflow skills** from [agent-skills](https://github.com/addyosmani/agent-skills). pickle-mode picks from them, and they also load on their own when a task matches.
  - Define: `interview-me`, `idea-refine`, `spec-driven-development`, `constraint-driven-development`
  - Plan: `planning-and-task-breakdown`
  - Build: `incremental-implementation`, `test-driven-development`, `context-engineering`, `source-driven-development`, `doubt-driven-development`, `frontend-ui-engineering`, `api-and-interface-design`
  - Verify: `browser-testing-with-devtools`, `debugging-and-error-recovery`
  - Review: `code-review-and-quality`, `code-simplification`, `security-and-hardening`, `performance-optimization`
  - Ship: `git-workflow-and-versioning`, `ci-cd-and-automation`, `deprecation-and-migration`, `documentation-and-adrs`, `observability-and-instrumentation`, `shipping-and-launch`

### Added by pickle

These sit beside the workflow skills: pickle-mode routes to some of them, workflow skills point to them where they help, and you can call the ones in the `/` menu yourself.

| Skill | Kind | What it does | How it loads |
|---|---|---|---|
| `how` | investigation | Explains how a part of the code works | `/pickle:how`, on its own, or from `context-engineering` and `doubt-driven-development` |
| `why` | investigation | Finds why code is shaped that way, from git history, PRs and any MCP servers you have added | `/pickle:why`, on its own, or from `debugging-and-error-recovery`, `code-simplification`, `deprecation-and-migration`, `doubt-driven-development` and `documentation-and-adrs` |
| `blast-radius` | investigation | Finds what a change could break outside its diff, and proves the change is safe by running real code | `/pickle:blast-radius`, on its own, or from pickle-mode Review |
| `technical-writing` | writing | Applies a layered standard to docs, PR descriptions and commit messages | On its own, or from pickle-mode and `documentation-and-adrs` |
| `unslop` | writing | Removes AI writing patterns from any prose | On its own, or from `technical-writing` |
| `typescript-best-practices` | language | Default TypeScript idioms when your project has none of its own | On its own, for `.ts` and `.tsx` work |
| `prototype` | design | Builds throwaway code to settle a design question by trying it: a logic demo, UI variants or a timing script. The prototype and its verdict stay on a throwaway branch | `/pickle:prototype`, on its own, or from pickle-mode Define. `test-driven-development`, `frontend-ui-engineering` and `security-and-hardening` treat its throwaways as the exception to their rules |
| `codebase-design` | extension | Deep modules, seams, the deletion test | From workflow skills only, not in the `/` menu |
| `domain-modeling` | extension | Your project's `GLOSSARY.md` | From workflow skills only, not in the `/` menu |
| `teach` | user-only | Explains a change or subsystem so you understand it: runs `how` and `why` and builds the picture up diagram by diagram | `/pickle:teach`, with the change, subsystem or question |
| `sharpen` | user-only | Rewrites a task prompt to be deeper, not bigger, and hands it back without doing the task | `/pickle:sharpen`, with the prompt |
| `setup` | user-only | Records where your issues and domain docs live, in `docs/agents/` | `/pickle:setup`, once per repo |
| `reflect` | user-only | Reviews a finished session and proposes fixes, checks and scripts first, then skill edits and pointers. Applies only the rows you approve | `/pickle:reflect`, with a session ID, a `.jsonl` path or `last N` |
| `improve-codebase-architecture` | user-only | Scans for shallow modules worth deepening, writes an offline HTML report to `docs/agents/reports/` and grills you through the one you pick | `/pickle:improve-codebase-architecture`, or as a weekly [scheduled report](#scheduled-reports) |
| `audit-architecture` | user-only | Reviews every subsystem for simpler ways to represent state and data, verifies each finding and writes a P0 to P3 report to `docs/agents/reports/`. Every run audits the whole codebase | `/pickle:audit-architecture`, with an optional path, or as a [scheduled report](#scheduled-reports) |

### Scheduled reports

Some skills are worth running on a schedule: they read the codebase, write a report and change no code. Run them as a local [routine](https://code.claude.com/docs/en/desktop-scheduled-tasks) in Claude Code Desktop, which runs on your machine with your local files and tools.

| Skill | Routine instructions | Cadence |
|---|---|---|
| `improve-codebase-architecture` | `/pickle:improve-codebase-architecture report only` | Weekly |
| `audit-architecture` | `/pickle:audit-architecture` | Weekly or monthly |

To set one up:

1. In the **Code** tab, open **Routines**, click **New routine** and choose **Local**.
2. Paste the routine instructions, pick the repo folder, and set the schedule to **Weekly** with a day and time.
3. Click **Run now** once and allow each tool it asks for, so later runs don't stall on a permission prompt.

Each run opens a session under **Scheduled** in the sidebar, with the report path and a one-line summary per candidate. Reports collect in `docs/agents/reports/`. Add that folder to `.gitignore` unless you want to keep them in the repo. To work through a candidate, run the skill yourself and name that area.

- Choose **Local**, not **Cloud**. A [cloud routine](https://code.claude.com/docs/en/routines) runs on a fresh clone, and cloud sessions don't install plugins, so pickle is not there.
- A local routine runs only while the app is open and the computer is awake. After a missed run, Desktop starts one catch-up run on wake.
- Leave the worktree toggle off, so the report lands in your checkout. The run reads the folder as it is, uncommitted changes included.

### Commands

| Doing | Command |
|---|---|
| Define what to build | `/pickle:spec` |
| Plan it in small tasks | `/pickle:plan` |
| Build one slice, or `auto` for the whole plan | `/pickle:build` |
| Prove it works | `/pickle:test` |
| Set the quality bar | `/pickle:constraints` |
| Review before merge | `/pickle:review` |
| Audit web performance | `/pickle:webperf` |
| Simplify code | `/pickle:code-simplify` |
| Ship | `/pickle:ship` |

### In the app

pickle includes a mod that points you to the right command in the terminal and the desktop Code tab:

- **Welcome band.** Above the prompt, buttons put `/pickle:pickle-mode`, `/pickle:sharpen` or `/pickle:setup` in the prompt box, or open the guide. It stays until you click Hide or run a `/pickle:` command.
- **Tips.** The first prompt in a session that reads like a task shows a tip for `/pickle:pickle-mode`. After a turn that edits files, the prompt box suggests `/pickle:review` (Tab to take it).
- **Guide.** `/pickle-guide` opens a pane of the commands and user-only skills by phase. Click one to put it in the prompt box.

### Agents

`code-reviewer`, `security-auditor`, `test-engineer` and `web-performance-auditor`. A project or user agent with the same name overrides pickle's. See [docs/agents.md](docs/agents.md).

Shared checklists (testing, security, performance, accessibility, observability, definition of done) live in [references/](references/). To roll pickle out on a new or existing codebase, see [docs/adoption-guide.md](docs/adoption-guide.md).

## How pickle differs from agent-skills

- `pickle-mode` is user-only, so it stays out of every session's context until you start it.
- Commands live under `pickle:`, so `/pickle:review` never clashes with the built-in `/review`.
- Agent names stay bare, so your own agents can override them.
- Vendored skills will be trimmed where evals show they are too long or overlap.
- `typescript-best-practices`, `how`, `why`, `technical-writing`, `unslop`, `blast-radius`, `reflect`, `teach` and `sharpen` are added from pstack. `reflect` also takes the environment checks from Matt Pocock's `retro`.
- `codebase-design`, `domain-modeling`, `setup`, `improve-codebase-architecture` and `prototype` are added from Matt Pocock's skills, `prototype` merged with pstack's Prototype playbook. ADRs default to `docs/adr/`.

## Install

The mod needs Claude Code 2.1.287 or later, or the desktop app's 2.1.286. Mod APIs change between releases; this release is tested with 2.1.309.

```bash
/plugin marketplace add PickleBoxer/claude-plugins
/plugin install pickle@pickleboxer
```

To try it now from a clone:

```bash
git clone https://github.com/PickleBoxer/pickle.git
claude --plugin-dir ./pickle
```

### Optional extras

pickle ships no MCP server. Some skills do more when you add one yourself:

| MCP server | Used by | Without it |
|---|---|---|
| [Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp) | `browser-testing-with-devtools`, the browser section of `test-driven-development`, traces in `performance-optimization` | No live DOM, console, network or performance checks. Setup is in `browser-testing-with-devtools`. |
| An issue tracker, docs, chat, observability, error-tracking or analytics server (for example Linear, Notion, Slack, Datadog, Sentry, Databricks) | `why` | `why` searches only git and `gh`, answers inline, and lists each missing category as a gap. |

`context-engineering` also suggests documentation, database and GitHub servers for richer context. Any of them helps, none is required.

pickle depends on no other plugin. One skill hands work to a plugin you install yourself:

| Plugin | Used by | Without it |
|---|---|---|
| [skill-creator](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator) | `reflect`, for skill edits longer than a line, description tuning and new skills | `reflect` applies one-line skill edits only and gives you the install command. |

```bash
/plugin install skill-creator@claude-plugins-official
```

For typed languages, install a [code intelligence plugin](https://code.claude.com/docs/en/plugins/code-intelligence) and its language server. Claude then finds definitions and references by symbol instead of by text search, which means fewer file reads, and it sees type errors right after its edits. pickle doesn't require one. For TypeScript:

```bash
npm install -g typescript-language-server typescript
```

```bash
/plugin install typescript-lsp@claude-plugins-official
```

`pickle-mode` adds one task list entry per skill it will use, when Claude Code provides the task tools. Some models get them only when you opt in, with either of these:

```bash
CLAUDE_CODE_ENABLE_TODO_TOOLS=1 claude
```

```bash
claude --allowedTools TaskCreate
```

## Credits

Built on Addy Osmani's [agent-skills](https://github.com/addyosmani/agent-skills), with `typescript-best-practices`, `how`, `why`, `technical-writing`, `unslop`, `blast-radius`, `reflect`, `teach` and `sharpen` from Lauren Tan's [pstack](https://github.com/cursor/plugins/tree/main/pstack), and `codebase-design`, `domain-modeling`, `setup`, `improve-codebase-architecture` and `prototype` from Matt Pocock's [skills](https://github.com/mattpocock/skills). See [CREDITS.md](CREDITS.md).

## License

MIT
