# Review

Read by the code-review-and-quality skill, from `/pickle:review` and `/pickle:ship`. The five-axis review always runs; these add to it. Reviews only report.

## Lanes

One subagent per lane, run when a changed file matches When. A lane whose skill or agent is not installed is skipped and named in the review.

| Lane | When | Skill or agent |
|------|------|----------------|
| {{Laravel practices}} | {{`*.php`}} | {{skill `laravel-best-practices`}} |
| {{React}} | {{`*.tsx`, `*.ts`}} | {{skill `vercel-react-best-practices`}} |
| {{Simplify}} | {{`*.php`}} | {{agent `laravel:laravel-simplifier`}} |

## Checks

This repo's rules, applied with the five axes. A broken check is a required change. A check flagged twice belongs in a test or lint rule: see `docs/agents/boundaries.md`.

- {{Every controller action authorizes through a policy.}}
