#!/usr/bin/env bash
# Fixture for loading-language-react: a small React app whose profile lists the project's own
# conventions, then pickle's typescript-best-practices, then Vercel's vercel-react-best-practices.
# Personal skills do not load in an eval run, so the case grades that the Loaded line names it
# after the other conventions, loaded or flagged as missing, not the skill body.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

mkdir -p src docs .claude
cat > package.json <<'JSON'
{
  "name": "acme-orders-ui",
  "type": "module",
  "scripts": { "dev": "vite", "test": "vitest run", "typecheck": "tsc --noEmit", "lint": "eslint ." },
  "dependencies": { "react": "^19.0.0", "react-dom": "^19.0.0" },
  "devDependencies": { "typescript": "^5.6.0", "vite": "^6.0.0", "vitest": "^2.1.0", "eslint": "^9.0.0" }
}
JSON
echo '{ "compilerOptions": { "strict": true, "jsx": "react-jsx", "module": "esnext", "target": "es2022" } }' > tsconfig.json
cat > src/OrderList.tsx <<'TSX'
import { useEffect, useState } from "react";

type Order = { id: string; status: string };

export function OrderList() {
  const [orders, setOrders] = useState<Order[]>([]);
  useEffect(() => {
    fetch("/api/orders").then((r) => r.json()).then(setOrders);
  }, []);
  return (
    <ul>
      {orders.map((o) => (
        <li key={o.id}>{o.id}: {o.status}</li>
      ))}
    </ul>
  );
}
TSX
cat > docs/conventions.md <<'MD'
# Conventions

- Components are function components in src/, one per file, tested with Vitest and Testing Library.
- Server data goes through src/api.ts, never a raw fetch in a component.
MD
cat > .claude/pickle.md <<'MD'
---
stack: typescript-react
conventions: [docs/conventions.md, pickle:typescript-best-practices, vercel-react-best-practices]
gates: [deploy, .env files]
---
## Verify
- test: npm test
- types: npm run typecheck
- lint: npm run lint
- ui: browser on the dev server (npm run dev)
MD
git init -q -b main
git add -A
git_eval commit -qm "initial orders ui"
