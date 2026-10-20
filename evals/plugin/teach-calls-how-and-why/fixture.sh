#!/usr/bin/env bash
# A tiny TypeScript HTTP client. The retry cap of 5 and the 30-second ceiling come from a later
# commit whose message gives the reason, so why has something to find in git history.
set -euo pipefail
git init -q
mkdir -p src
c() { git add -A && git -c user.name=eval -c user.email=eval@example.com commit -qm "$1"; }
cat > src/client.ts <<'TS'
export async function request(url: string): Promise<Response> {
  return fetch(url);
}
TS
c "add http client"
cat > src/client.ts <<'TS'
const MAX_ATTEMPTS = 5;
const BASE_DELAY_MS = 200;
const MAX_DELAY_MS = 30_000;

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

export async function request(url: string): Promise<Response> {
  for (let attempt = 1; ; attempt++) {
    const res = await fetch(url);
    if (res.status !== 429 && res.status < 500) return res;
    if (attempt === MAX_ATTEMPTS) return res;
    const delay = Math.min(BASE_DELAY_MS * 2 ** (attempt - 1), MAX_DELAY_MS);
    await sleep(delay + Math.random() * delay);
  }
}
TS
c "fix(client): retry 429 and 5xx with capped backoff

- The payments API allows 100 requests per minute per key and answers 429 past it
- Unbounded retries during the March outage kept us over the limit for 40 minutes
- Cap at 5 attempts and 30 s per wait, with jitter so workers do not retry in step"
