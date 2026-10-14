# Observability (New Relic)

The runtime signal behind a timeout, a retry, a limit or a circuit breaker: what happened in production, not what was planned. Tool names vary by server and version: read the server's tool list and schemas first.

## Search

1. Find the entity (the APM service, browser app or host) that runs the target.
2. Alert policies and conditions: a condition whose threshold matches the code's limit is close to direct evidence. Note the query and the threshold.
3. Dashboards on that entity: the widgets that measure what the code guards.
4. NRQL over the window around the change, for example 30 days before and after. Errors (`TransactionError`), slow transactions (`Transaction` with `duration`), and log lines with the error strings the code handles. Aggregate with `FACET` and `TIMESERIES` instead of listing raw rows.
5. Deployment markers and change tracking: did a deploy of the target line up with a change in the signal?
6. Incidents and issues opened on the entity around the date the code was added.

## Pitfalls

- A spike before a merge and calm after it suggests, not proves. Check what else deployed in that window.
- A metric shows someone cared enough to measure it, not that the code exists because of it.
- Data retention may not reach the change date. Name the cutoff as a gap.

## Report per item

Type (alert condition, dashboard, NRQL result, deployment, incident), name or ID, owner and date, the query or threshold verbatim, and how it bears on the question.
