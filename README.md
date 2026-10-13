# pickle

Language-agnostic engineering playbooks and principles for Claude Code. Start it on a task that deserves the full process. pickle picks the playbook, loads only the principles and language pack it needs, and reads how your project tests and runs from a small profile.

> Early. The repo is being bootstrapped: evals first, skills next. Nothing installable yet.

## How it will work

```
/pickle:pickle-mode add an OrderStatus enum to orders
/pickle:pickle-mode extract the payment gateway behind an interface
```

- **Full process.** A read-only explorer, design options, an implementer subagent and a reviewer. For small tasks, don't start pickle.
- **Playbooks.** feature, bug fix, refactor, investigate, perf, prototype and more. Read only when matched.
- **Principles.** Short background skills, loaded by name when a playbook step needs one.
- **Language packs.** PHP, TypeScript and Swift ship with pickle. They load only when Claude touches matching files.
- **Project profile.** `/pickle:setup` detects your stack and writes `.claude/pickle.md` with your test, type and lint commands.

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
