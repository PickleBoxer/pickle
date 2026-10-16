# pickle

Engineering workflow skills for Claude Code, built on Addy Osmani's [agent-skills](https://github.com/addyosmani/agent-skills). Start a task with `/pickle:pickle-mode` and it picks the workflow skills that fit, from spec and planning to review and shipping.

> Early. agent-skills is the baseline, and pickle's own pieces are added back one at a time when evals or real use show a gap. Nothing installable yet.

## How it will work

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
- **Language skill.** pickle's `typescript-best-practices` gives default TypeScript idioms when your project has none of its own.

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

### Agents

`code-reviewer`, `security-auditor`, `test-engineer` and `web-performance-auditor`. A project or user agent with the same name overrides pickle's. See [docs/agents.md](docs/agents.md).

Shared checklists (testing, security, performance, accessibility, observability, definition of done) live in [references/](references/). To roll pickle out on a new or existing codebase, see [docs/adoption-guide.md](docs/adoption-guide.md).

## How pickle differs from agent-skills

- `pickle-mode` is user-only, so it stays out of every session's context until you start it.
- Commands live under `pickle:`, so `/pickle:review` never clashes with the built-in `/review`.
- Agent names stay bare, so your own agents can override them.
- Vendored skills will be trimmed where evals show they are too long or overlap.
- `typescript-best-practices` is added.

## Install

Once the first release lands:

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

`context-engineering` also suggests documentation, database and GitHub servers for richer context. Any of them helps, none is required.

## Credits

Built on Addy Osmani's [agent-skills](https://github.com/addyosmani/agent-skills), with `typescript-best-practices` from Lauren Tan's [pstack](https://github.com/cursor/plugins/tree/main/pstack). See [CREDITS.md](CREDITS.md).

## License

MIT
