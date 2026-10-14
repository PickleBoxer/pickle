---
stack: typescript-node
conventions: []
gates: [database migrations, deploy, publishing a package, .env files]
---

## Verify

- test: <test>
- types: <types>
- lint: <lint>

<!-- Setup notes, removed when the profile is written:
- conventions: after the project's own, add `pickle:typescript-best-practices` (pickle's TypeScript defaults; `typescript-best-practices` when pickle is installed without the plugin).
- Use the package manager the lockfile names, and the package.json scripts when they exist.
- A library has no ui line. A server adds `- ui: request <url>` when there is a local URL to check.
- In a workspace, scripts may need a filter (`pnpm --filter <pkg>`), as the CI config runs them.
-->
