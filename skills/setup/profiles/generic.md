---
stack: <stack>
packs: []
conventions: []
gates: [database migrations, deploy, secrets and .env files]
---

## Verify

- test: <test>
- types: <types>
- lint: <lint>

<!-- Setup notes, removed when the profile is written:
- Fill each command from the CI config, the README, a Makefile or justfile, or the manifest scripts. Drop a line that has no command, never invent one.
- packs: a pack only when one exists for the language (php, typescript, swift), or a path to the project's own pack file.
- A monorepo with several stacks: one line per command, prefixed with the subproject, for example `- test: cd api && composer test`.
-->
