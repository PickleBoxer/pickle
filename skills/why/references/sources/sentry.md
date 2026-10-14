# Error tracking (Sentry)

The exceptions behind a guard, a retry or a fix. Adapt for Rollbar or Bugsnag by reading the server's tools first.

## Search

1. Find the organization and project if you do not know them.
2. Search issues by the exception classes the target handles, its function or class names, the error strings it checks and its file path.
3. For a candidate issue, check first seen and last seen against the target's ship date, the affected releases, and whether the frequency spiked and then stopped.
4. Open a full event: does the stack trace pass through the target? Do tags and breadcrumbs match what the code guards against?
5. List releases around the target's commit date and match them to the PR's merge date.

AI root-cause summaries are a hypothesis, not evidence. The events and stack traces are.

## Report per issue

ID and title, project, first and last seen, event count, affected releases, a verbatim stack trace excerpt that shows the link to the target, how first and last seen line up with the ship date, link, resolution notes.
