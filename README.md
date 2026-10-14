# pickle

Language-agnostic engineering playbooks and principles for Claude Code. Start it on a task that deserves the full process. pickle picks the playbook, loads only the principles it needs, and reads how your project tests, runs and writes code from a small profile.

> Early. The repo is being bootstrapped: evals first, skills next. Nothing installable yet.

## How it will work

```
/pickle:pickle-mode add an OrderStatus enum to orders
/pickle:pickle-mode extract the payment gateway behind an interface
```

- **Full process.** `how` explains the code, `why` finds the reasons behind it, `architect` sketches the design, an implementer subagent writes it, `interrogate` reviews it, and `swarm` runs parallel workers when a plan needs them. For small tasks, don't start pickle.
- **Playbooks.** feature, bug fix, refactor, investigate, perf, prototype and more. Read only when matched.
- **Principles.** Short engineering rules, read only when a playbook step or a trigger needs one. They cost nothing outside pickle.
- **Before you start.** `/pickle:sharpen <task>` frames the task the way an expert would before doing it. `/pickle:in-your-own-words` plays back your goal and problem so you can correct it.
- **Project profile.** `/pickle:setup` detects your stack and writes `.claude/pickle.md` with your test, type and lint commands and your conventions.
- **Your conventions.** Your project defines its language rules, and they win over pickle's defaults. `/pickle:setup` also adds a language skill for your stack after yours as a fallback: pickle's `typescript-best-practices` for TypeScript, and for Laravel and React the installed `laravel-best-practices` (Laravel Boost) and `vercel-react-best-practices` (Vercel). pickle does not ship those two. If one is missing, setup tells you how to install it. List them under `conventions:` in the profile, as skill names or paths to files in your repo. pickle reads every one before it starts, also for tasks that write no code.

## Writing a conventions file

A conventions file tells pickle how your project applies the principles in its own language and framework. Keep it short, one line per rule, with concrete names and commands: your test framework and how tests assert, how input is validated at the edges, how jobs and scheduled tasks avoid running twice, where the real error log lives, and the traps your stack has bitten you with. Skip what `CLAUDE.md` already says, since it is in context anyway. Then list the file in the profile, for example `conventions: [docs/conventions.md]`.

## Install

Once the first release lands:

```bash
/plugin marketplace add PickleBoxer/claude-plugins
/plugin install pickle@pickleboxer
```

Skills only, without the agents and the mod:

```bash
npx skills add PickleBoxer/pickle --skill '*'
```

## Credits

Built on ideas from Lauren Tan's [pstack](https://github.com/cursor/plugins/tree/main/pstack). See [CREDITS.md](CREDITS.md).

## License

MIT
