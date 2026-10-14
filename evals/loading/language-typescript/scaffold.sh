#!/usr/bin/env bash
# Fixture for loading-language-typescript: a small TypeScript service whose profile lists
# the project's own conventions first, then pickle's typescript-best-practices.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

mkdir -p src docs .claude
cat > package.json <<'JSON'
{
  "name": "acme-orders",
  "type": "module",
  "scripts": { "test": "vitest run", "typecheck": "tsc --noEmit", "lint": "eslint ." },
  "devDependencies": { "typescript": "^5.6.0", "vitest": "^2.1.0", "eslint": "^9.0.0" },
  "dependencies": { "zod": "^3.23.0" }
}
JSON
echo '{ "compilerOptions": { "strict": true, "module": "nodenext", "target": "es2022" } }' > tsconfig.json
cat > src/orders.ts <<'TS'
export type Order = { id: string; status: string; shippedAt?: Date };

export function ship(order: Order): Order {
  if (order.status !== "paid") throw new Error("not paid");
  return { ...order, status: "shipped", shippedAt: new Date() };
}
TS
cat > src/api.ts <<'TS'
import { ship, type Order } from "./orders.js";

export function handle(body: any): Order {
  const order = body.order as Order;
  if (body.command === "ship") return ship(order);
  throw new Error("unknown command");
}
TS
cat > docs/conventions.md <<'MD'
# Conventions

- Tests are Vitest files next to the code, `*.test.ts`, calling the exported functions.
- Request bodies are parsed with zod schemas in src/schemas.ts.
- Errors crossing the API are `{ error: string }`, never thrown strings.
MD
cat > .claude/pickle.md <<'MD'
---
stack: typescript-node
conventions: [docs/conventions.md, pickle:typescript-best-practices]
gates: [deploy, publishing a package, .env files]
---
## Verify
- test: npm test
- types: npm run typecheck
- lint: npm run lint
MD
git init -q -b main
git add -A
git_eval commit -qm "initial orders service"
