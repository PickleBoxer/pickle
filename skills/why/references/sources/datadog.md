# Observability (Datadog)

Same job as `newrelic.md`, for a Datadog server. Read the server's tool list and schemas first.

## Search

1. Find the owning service and its dependencies.
2. Monitors first, then dashboards: a monitor threshold that matches the code's limit is close to direct evidence.
3. Metrics around the change date: did one spike before the merge and settle after?
4. Logs, time-bounded and aggregated: the error patterns the code guards against, in the window before the change.
5. APM spans and traces for timeouts, retries and slow paths.
6. Incidents around the date the code was added. A timeline entry like "added a check for X" is close to direct evidence.

Pitfalls and the report are as in `newrelic.md`. A chart reflects its maker's framing: "retry success rate" shows the team cared about retries, not why one line exists.
