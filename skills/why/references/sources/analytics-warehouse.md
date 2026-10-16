# Product analytics warehouse

Example servers: Databricks, Snowflake, BigQuery, ClickHouse, dbt. Analytics is the product and data view: what users did, which experiments ran, how feature use changed, where a threshold came from. Observability is the runtime view.

## What this source contains

- **Product events.** Feature use, clicks, accepts and rejects, client-reported errors. Often a raw event table plus cleaned, typed models built on top of it.
- **Usage and billing events.** For cost-driven or volume-driven decisions.
- **Experiment and feature-flag data.** Exposure and outcome tables.
- **System tables.** Query history, warehouse load and audit logs: "was this query expensive?", "how often did anyone run it?"
- **Model lineage** (dbt or similar). Which pipelines depend on a table or field. Upstream changes often motivate consumer code.
- **Notebooks.** Analyses written before a change. Usually not queryable through a SQL server. If the rationale may live in one, report a gap.

## How to search it

Use the server's read-only SQL tool. If it returns a statement ID, poll for the result instead of running the query again.

1. **Orient before querying.** Table names are company-specific. List tables and describe their columns before you trust a name: `SHOW TABLES ... LIKE '*<keyword>*'`, `DESCRIBE TABLE ...`.
2. **Time-bound every query.** These tables are large and open scans time out. Bracket the ship date, about 30 days either side, wider only for a strong reason.
3. **Prefer cleaned models over raw event tables.** They are deduplicated and typed. Use the raw table only when no model exists yet, or for events newer than the model's refresh.

Patterns that tend to pay off:

1. **Usage trajectory.** Daily event counts around the PR merge. A step from zero to steady volume within a day or two of the merge suggests the PR launched the feature. A decay to zero suggests a removal.
2. **Origin of a threshold or guard.** The median, p99 and max of the relevant value in the 14 days before the PR. A p99 that matches the code's constant suggests the number came from data.
3. **Experiment lookup.** Find the exposure table, then exposure counts by variant for the target's flag key near the PR date.
4. **Query history** for migrations, backfills or performance rewrites: queries that mention the table or symbol in a tight window, sorted by duration or bytes read.
5. **Lineage.** If the target reads or writes a warehouse model whose code lives in this repo, hand that lead to the source control investigator.

## Common pitfalls

- **Logged is not caused.** An event shows someone cared enough to log it, not that the code exists because of it. Pair it with a PR or commit citation before claiming cause.
- **Instrumentation changes.** A step in volume may mean a new event started being logged, not that behavior changed. Check for instrumentation PRs in the same window.
- **Schema drift.** A column today may not have existed when the target was written.
- **Retention and creation dates.** If the window predates the table's retention or creation, that is a gap, not a null result. Say so.
- **Unconfirmed tables.** Never report a result from a table you did not confirm exists.

## What to return

For each relevant finding:

- Type: product event, experiment exposure, usage or billing event, system-table row, or lineage
- Fully qualified table name and the exact query
- Time window
- Compact numeric summary (counts, percentiles, first and last seen). Don't dump raw rows.
- Timing against the target's ship date ("first row 2024-08-15, PR #49074 merged 2024-08-14")
- Relevance and strength: direct, circumstantial or weak
