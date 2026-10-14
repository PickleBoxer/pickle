---
stack: laravel
packs: [php]
conventions: []
gates: [migrations on shared databases, deploy, queue and scheduler config, .env files]
---

## Verify

- test: <test>
- types: <types>
- lint: <lint>
- ui: <ui>

<!-- Setup notes, removed when the profile is written:
- Commands run inside the project's environment. With Sail, DDEV or Docker, prefix them (`./vendor/bin/sail`, `ddev exec`) when the CI config or README does.
- Prefer `--parallel` for tests when the CI config uses it.
- A frontend with its own tooling (React, Vue, TypeScript) adds its commands as extra lines, for example a second `types:` line.
- conventions: skills the project follows, for example spatie-guidelines or livewire-4, when CLAUDE.md or the installed skills name them.
-->
