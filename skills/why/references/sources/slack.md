# Team chat (Slack)

Decisions made in conversation that never reached a doc. Adapt for Teams or Discord by reading the server's tools first. Some servers need authentication: if it fails, stop and report the gap.

## Search

1. Messages from the PR author in the days around the merge date.
2. The PR URL, or `/pull/<n>`: PRs get linked when they are discussed.
3. The error strings the code handles: incident threads surface.
4. Incident channels (`#incident-*`, `#sev-*`) around the date the code was added, when the code is defensive.

Always fetch the whole thread. A single message reads differently out of context.

## Pitfalls

- Retention: very old messages may be gone. Name the date where results stop.
- DMs are usually not searchable. Say so as a known gap.
- A joke is not a decision. Look for a considered exchange.
