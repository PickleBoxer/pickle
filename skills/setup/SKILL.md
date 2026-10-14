---
name: setup
description: Detects the project's stack and writes the pickle profile, .claude/pickle.md, with its conventions, verify commands and gates. Use when the user runs /pickle:setup.
argument-hint: "[project dir]"
disable-model-invocation: true
---

# pickle setup

Write the profile `pickle-mode` reads: `.claude/pickle.md` in the project root. Paths below are relative to this file. Copy these steps into the todo list.

1. If `.claude/pickle.md` exists, read it. The run then updates it: verify commands are detected again, gates and conventions are kept unless the user says otherwise, and notes are kept only if they pass the notes rule in step 4. Drop any field that is not in the profile format below.
2. Run `bash scripts/detect-stack.sh <project dir>` (absolute path to the script) and read its JSON. It is a draft from manifests and lockfiles:
   - `profile`: the template in `profiles/` to start from.
   - `stacks`: every stack found.
   - `verify`: candidate commands per purpose, empty when nothing was found.
   - `subprojects`: manifests below the root. If the root has no stack, ask once which subprojects pickle should cover, then run the script on each and merge the results.
   - `task_runner`: the Makefile, justfile or Taskfile and its targets. Targets named like a purpose (`test`, `lint`, `phpstan`) are already first in `verify`. Read the recipe before choosing one: a target can need running containers or credentials, or run far more than its name says.
   - `ci`: CI config files. `lsp`: one entry per language, see step 7.
   - `language_skills`: the language skills for every stack found, in precedence order. `installed` is `pickle` (ships with pickle), `project` or `personal` (found in `.claude/skills/` or the personal skills folder), or null (not installed). `url` is the skill's source, `install` the commands that install it, one per option. pickle never copies a third-party skill.
   - `convention_files`: files whose names suggest coding rules (standards, style guides, guidelines, contributing, other agents' rule files). Candidates only, see step 4.
3. Check the draft against the project. The CI config wins over the script: read each file in `ci` and take the commands CI runs, with their flags and environment prefix (Sail, DDEV, Docker, workspace filters). Then the task runner recipes, the README and `CLAUDE.md`. Replace every placeholder the project can answer, such as `<scheme>`, with a real value, for example from `xcodebuild -list`. Keep a placeholder only for an argument each task supplies, such as the test path when the project must never run the full suite. Drop a verify line that has no command. Never invent one.
4. Read `profiles/<profile>.md`. Fill it: the verify commands, `conventions`, and the template's default gates. Conventions are how this project writes code: skills that `CLAUDE.md` or `AGENTS.md` names, and files in the project that set coding rules. Read each file in `convention_files`, and follow links to rule files from `CLAUDE.md`, `AGENTS.md` and the README, since a file can have any name. Keep a file only if it states how code is written here: a `CONTRIBUTING.md` about issues and releases is not a convention. List each skill by name and each file by its path from the project root. Leave out a file `CLAUDE.md` already imports: it is in context anyway. Then append each entry in `language_skills` whose `installed` is not null, in its order, after the project's own conventions: the order is precedence, project first. A `pickle` entry is `pickle:<name>` when this skill runs as `/pickle:setup`, the bare name when pickle is installed without the plugin. Other entries keep their bare name. Skip one the user removed in an earlier profile. Follow the template's setup notes, then remove the notes comment. Notes hold facts about this project only. Never copy a rule that `CLAUDE.md` or the user's own instructions already give, such as commit or reply style: it is in context anyway.
5. Ask once with `AskUserQuestion`: write it, change something (gates, commands, conventions), or cancel. Put the full profile in the question text, and when updating, also what changed from the old file and every note dropped, with the reason. The user decides from the question alone. Apply changes and show it again only if the user changed something.
6. Write `.claude/pickle.md`. Do not commit it.
7. Language servers and skills: for each `lsp` entry where `enabled` or `server_found` is false, tell the user once what is missing. `enabled: false`: install the plugin with `/plugin install <plugin>`. `server_found: false`: run the `install` command. For each `language_skills` entry with `installed: null`, say the stack's language skill is missing, link its `url`, and give every `install` option. For `laravel-best-practices` the first option installs Laravel Boost, which also adds its guidelines, other skills and MCP server; the second installs the skill alone, but leaves 6 of its 19 rule files as unrendered Blade templates that its links miss, so recommend Boost. Then say a rerun of `/pickle:setup` adds it to the profile. Do not install any of them yourself.
8. Reply with the profile path, what was detected, what came from CI, what the user changed, and any missing language server or language skill. Suggest `/pickle:pickle-mode <task>` as the next step.

## Profile format

`pickle-mode` reads this shape. Keep it.

```markdown
---
stack: <profile name>
conventions: [<skill names, or paths to files in the project>]
gates: [<actions to stop and ask before>]
---

## Verify

- test: <command>
- types: <command>
- lint: <command>
- ui: <how to check what a user sees>
```

A purpose with two commands gets two lines with the same key. Free-form notes for `pickle-mode` go in a `## Notes` section after Verify.
