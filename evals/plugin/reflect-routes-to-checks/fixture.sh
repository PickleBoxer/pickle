#!/usr/bin/env bash
# A small TypeScript repo with eslint but no no-console rule, no CI and no pre-commit hook, and
# `npm test` left at the npm default. .scratch/session.jsonl is a past session in it: the agent
# ran `npm test` three times before the user named `npm run test:unit`, read the same file three
# times, and left a console.log the user says they flagged before.
set -euo pipefail
git init -q
mkdir -p src tests .scratch
cat > package.json <<'JSON'
{
  "name": "shop",
  "private": true,
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "test:unit": "vitest run",
    "lint": "eslint src"
  }
}
JSON
cat > eslint.config.js <<'JS'
export default [{ files: ["src/**/*.ts"], rules: { "no-unused-vars": "error" } }];
JS
printf '# Shop\n\nRun the unit tests with `npm run test:unit`.\n' > README.md
printf '# Shop\n\nRun the tests before you finish.\n' > CLAUDE.md
cat > src/money.ts <<'TS'
export function formatPrice(cents: number): string {
  return `€${(cents / 100).toFixed(2)}`;
}
TS
git add -A && git -c user.name=eval -c user.email=eval@example.com commit -qm "initial shop"

S=00000000-0000-4000-8000-000000000001
m() { printf '{"type":"%s","sessionId":"%s","version":"2.1.0","cwd":"/work/shop","gitBranch":"main",%s}\n' "$1" "$S" "$2"; }
u() { m user "\"message\":{\"role\":\"user\",\"content\":$1}"; }
a() { m assistant "\"message\":{\"id\":\"$1\",\"role\":\"assistant\",\"content\":$2,\"usage\":{\"input_tokens\":10,\"cache_read_input_tokens\":20000,\"cache_creation_input_tokens\":500,\"output_tokens\":200}}"; }
call() { printf '[{"type":"tool_use","id":"%s","name":"%s","input":%s}]' "$1" "$2" "$3"; }
ok() { u "[{\"type\":\"tool_result\",\"tool_use_id\":\"$1\",\"content\":$2}]"; }
bad() { u "[{\"type\":\"tool_result\",\"tool_use_id\":\"$1\",\"is_error\":true,\"content\":$2}]"; }
{
  u '"Add a formatCents helper to src/money.ts that formats without the euro sign, with a test."'
  a m1 "$(call t1 Read '{"file_path":"/work/shop/src/money.ts"}')"; ok t1 '"export function formatPrice..."'
  a m2 "$(call t2 Edit '{"file_path":"/work/shop/src/money.ts","old_string":"}","new_string":"}\nexport function formatCents(c: number) { console.log(c); return (c / 100).toFixed(2); }"}')"; ok t2 '"ok"'
  a m3 "$(call t3 Write '{"file_path":"/work/shop/tests/money.test.ts","content":"..."}')"; ok t3 '"ok"'
  a m4 "$(call t4 Bash '{"command":"npm test"}')"; bad t4 '"Error: no test specified"'
  a m5 "$(call t5 Read '{"file_path":"/work/shop/src/money.ts"}')"; ok t5 '"..."'
  a m6 "$(call t6 Bash '{"command":"npm test"}')"; bad t6 '"Error: no test specified"'
  a m7 "$(call t7 Bash '{"command":"npm test"}')"; bad t7 '"Error: no test specified"'
  a m8 '[{"type":"text","text":"The test script is not configured, so I could not run the tests. The helper is added."}]'
  u '"Use npm run test:unit, it is in the README. And remove the console.log, we never ship console.log. I told you that last week too."'
  a m9 "$(call t8 Read '{"file_path":"/work/shop/src/money.ts"}')"; ok t8 '"..."'
  a m10 "$(call t9 Edit '{"file_path":"/work/shop/src/money.ts","old_string":"console.log(c); ","new_string":""}')"; ok t9 '"ok"'
  a m11 "$(call t10 Bash '{"command":"npm run test:unit"}')"; ok t10 '"1 passed"'
  a m12 '[{"type":"text","text":"Removed the console.log, and the test passes with npm run test:unit."}]'
} > .scratch/session.jsonl
