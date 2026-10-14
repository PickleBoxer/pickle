---
name: setup
description: Detects the project's stack and writes the pickle profile, .claude/pickle.md, with its packs, verify commands and gates. Use when the user runs /pickle:setup.
argument-hint: "[project dir]"
disable-model-invocation: true
---

# pickle setup

Write the profile `pickle-mode` reads: `.claude/pickle.md` in the project root. Paths below are relative to this file. Copy these steps into the todo list.

1. If `.claude/pickle.md` exists, read it. The run then updates it: keep its gates, conventions and notes unless the user says otherwise.
2. Run `bash scripts/detect-stack.sh <project dir>` (absolute path to the script) and read its JSON. It is a draft from manifests and lockfiles:
   - `profile`: the template in `profiles/` to start from.
   - `stacks`, `packs`: every stack found and the packs that exist for them.
   - `verify`: candidate commands per purpose, empty when nothing was found.
   - `subprojects`: manifests below the root. If the root has no stack, ask once which subprojects pickle should cover, then run the script on each and merge the results.
   - `task_runner`: the Makefile, justfile or Taskfile and its targets. Targets named like a purpose (`test`, `lint`, `phpstan`) are already first in `verify`. Read the recipe before choosing one: a target can need running containers or credentials, or run far more than its name says.
   - `ci`: CI config files. `lsp`: one entry per pack, see step 7.
3. Check the draft against the project. The CI config wins over the script: read each file in `ci` and take the commands CI runs, with their flags and environment prefix (Sail, DDEV, Docker, workspace filters). Then the task runner recipes, the README and `CLAUDE.md`. Replace every placeholder such as `<scheme>` with a real value from the project, for example from `xcodebuild -list`. Drop a verify line that has no command. Never invent one.
4. Read `profiles/<profile>.md`. Fill it: the verify commands, `packs` from the script, `conventions` from skills that `CLAUDE.md` names, and the template's default gates. Follow the template's setup notes, then remove the notes comment.
5. Show the full profile and ask once with `AskUserQuestion`: write it, change something (gates, commands, conventions), or cancel. Apply changes and show it again only if the user changed something.
6. Write `.claude/pickle.md`. Do not commit it.
7. Language servers: for each `lsp` entry where `enabled` or `server_found` is false, tell the user once what is missing. `enabled: false`: install the plugin with `/plugin install <plugin>`. `server_found: false`: run the `install` command. Do not install either yourself.
8. Reply with the profile path, what was detected, what came from CI, what the user changed, and any missing language server. Suggest `/pickle:pickle-mode <task>` as the next step.

## Profile format

`pickle-mode` reads this shape. Keep it.

```markdown
---
stack: <profile name>
packs: [<pack names, or paths to pack files in the project>]
conventions: [<skills the project follows>]
gates: [<actions to stop and ask before>]
---

## Verify

- test: <command>
- types: <command>
- lint: <command>
- ui: <how to check what a user sees>
```

A purpose with two commands gets two lines with the same key. Free-form notes for `pickle-mode` go in a `## Notes` section after Verify.
