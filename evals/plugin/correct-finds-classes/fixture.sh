#!/usr/bin/env bash
# A TypeScript repo where AGENTS.md says routes go through src/repositories. Twice an agent
# imported src/db.ts in a route and a later commit moved it to the repository. One unrelated
# typo fix happened once. eslint has no no-restricted-imports rule and there is no CI.
set -euo pipefail
git init -q
c() { git add -A && git -c user.name=eval -c user.email=eval@example.com commit -qm "$1"; }
mkdir -p src/routes src/repositories
cat > package.json <<'JSON'
{ "name": "shop", "private": true, "scripts": { "lint": "eslint src", "test": "vitest run" } }
JSON
cat > eslint.config.js <<'JS'
export default [{ files: ["src/**/*.ts"], rules: { "no-unused-vars": "error" } }];
JS
printf '# Shop\n\n- Routes read and write data through `src/repositories`, never by importing `src/db.ts`.\n' > AGENTS.md
cat > src/db.ts <<'TS'
export const db = { query: async (sql: string, args: unknown[] = []) => ({ sql, args, rows: [] as unknown[] }) };
TS
cat > src/repositories/orders.ts <<'TS'
import { db } from "../db";
export const orders = { byId: (id: string) => db.query("select * from orders where id = $1", [id]) };
TS
c "feat(orders): add orders repository"

cat > src/routes/orders.ts <<'TS'
import { db } from "../db";
export const getOrder = (id: string) => db.query("select * from orders where id = $1", [id]);
TS
c "feat(routes): add order route"
cat > src/routes/orders.ts <<'TS'
import { orders } from "../repositories/orders";
export const getOrder = (id: string) => orders.byId(id);
TS
c "fix(routes): use orders repository instead of db in order route"

cat > src/repositories/customers.ts <<'TS'
import { db } from "../db";
export const customers = { byId: (id: string) => db.query("select * from customers where id = $1", [id]) };
TS
cat > src/routes/customers.ts <<'TS'
import { db } from "../db";
export const getCustomer = (id: string) => db.query("select * from customers where id = $1", [id]);
TS
c "feat(routes): add customer route"
cat > src/routes/customers.ts <<'TS'
import { customers } from "../repositories/customers";
export const getCustomer = (id: string) => customers.byId(id);
TS
c "fix(routes): route must not import db directly, again use the repository"

printf '# Shop\n\nOrders and customers API.\n' > README.md
c "docs(readme): add readme"
printf '# Shop\n\nOrders and customers API, with repositories.\n' > README.md
c "docs(readme): fix typo"
