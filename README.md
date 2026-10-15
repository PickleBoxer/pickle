# pickle

Engineering workflow skills for Claude Code, built on Addy Osmani's [agent-skills](https://github.com/addyosmani/agent-skills). Start a task with `/pickle:pickle-mode` and it picks the workflow skills that fit, from spec and planning to review and shipping.

> Early. agent-skills is the baseline, and pickle's own pieces are added back one at a time when evals or real use show a gap. Nothing installable yet.

## How it will work

```
/pickle:pickle-mode add an OrderStatus enum to orders
/pickle:pickle-mode extract the payment gateway behind an interface
```

- **Entry skill.** `pickle-mode` is agent-skills' `using-agent-skills`, renamed: a decision tree that maps the task to the workflow skills, plus the operating rules every skill follows (surface assumptions, push back, keep scope, verify).
- **Engineering skills.** 25 skills from [agent-skills](https://github.com/addyosmani/agent-skills), from spec and planning to review, security and shipping. pickle-mode picks from them, and they also load on their own when a task matches. Its commands come along (`/pickle:spec`, `/pickle:plan`, `/pickle:build`, `/pickle:test`, `/pickle:review`, `/pickle:ship` and more), with the `code-reviewer`, `security-auditor`, `test-engineer` and `web-performance-auditor` agents.
- **Language skill.** pickle's `typescript-best-practices` gives default TypeScript idioms when your project has none of its own.

## Install

Once the first release lands:

```bash
/plugin marketplace add PickleBoxer/claude-plugins
/plugin install pickle@pickleboxer
```

Skills only, without the agents:

```bash
npx skills add PickleBoxer/pickle --skill '*'
```

## Credits

Built on ideas from Lauren Tan's [pstack](https://github.com/cursor/plugins/tree/main/pstack), with skills from Addy Osmani's [agent-skills](https://github.com/addyosmani/agent-skills). See [CREDITS.md](CREDITS.md).

## License

MIT
