#!/usr/bin/env bash
# Print one pull request's state as one JSON object for the babysit playbook: state,
# merge state, review decision, checks and unresolved review threads. Read-only.
# Usage: pr-state.sh [pr number, url or branch]. Defaults to the current branch's PR.
# Review threads come from GraphQL: `gh pr view --json` has no review-thread field.
set -euo pipefail

for tool in gh jq; do
  command -v "$tool" >/dev/null 2>&1 || { echo "error: $tool is not installed" >&2; exit 1; }
done

pr="$(gh pr view ${1:+"$1"} --json number,url,title,state,isDraft,headRefName,baseRefName,mergeable,mergeStateStatus,reviewDecision,statusCheckRollup)"

# owner/name from the PR url: https://github.com/<owner>/<name>/pull/<n>
read -r owner name number < <(jq -r '.url | capture("github\\.com/(?<o>[^/]+)/(?<r>[^/]+)/pull/(?<n>[0-9]+)") | "\(.o) \(.r) \(.n)"' <<<"$pr")

threads="$(gh api graphql -F owner="$owner" -F name="$name" -F number="$number" -f query='
query($owner: String!, $name: String!, $number: Int!) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        pageInfo { hasNextPage }
        nodes {
          isResolved isOutdated path line
          comments(first: 1) { totalCount nodes { author { login } body url } }
        }
      }
    }
  }
}')"

jq -n --argjson pr "$pr" --argjson t "$threads" '
  ($pr.statusCheckRollup // []) as $raw
  | [$raw[] | {
      name: (.name // .context),
      workflow: (.workflowName // null),
      # CheckRun has status and conclusion, StatusContext has state.
      result: (if .__typename == "StatusContext" then (.state | ascii_downcase)
               elif .status != "COMPLETED" then "pending"
               else (.conclusion // "unknown" | ascii_downcase) end),
      url: (.detailsUrl // .targetUrl // null)
    }] as $checks
  | $t.data.repository.pullRequest.reviewThreads as $rt
  | {
      number: $pr.number, url: $pr.url, title: $pr.title,
      state: $pr.state, draft: $pr.isDraft,
      head: $pr.headRefName, base: $pr.baseRefName,
      mergeable: $pr.mergeable, merge_state: $pr.mergeStateStatus,
      review_decision: $pr.reviewDecision,
      checks: {
        failing: [$checks[] | select(.result | IN("failure", "error", "timed_out", "cancelled", "action_required", "startup_failure"))],
        pending: [$checks[] | select(.result | IN("pending", "expected"))],
        passed: ([$checks[] | select(.result | IN("success", "neutral", "skipped"))] | length),
        other: [$checks[] | select(.result | IN("failure", "error", "timed_out", "cancelled", "action_required", "startup_failure",
          "pending", "expected", "success", "neutral", "skipped") | not)]
      },
      unresolved_threads: [$rt.nodes[] | select(.isResolved | not) | {
        path, line, outdated: .isOutdated,
        author: .comments.nodes[0].author.login,
        comments: .comments.totalCount,
        body: (.comments.nodes[0].body | if length > 500 then .[:500] + "..." else . end),
        url: .comments.nodes[0].url
      }],
      threads_truncated: $rt.pageInfo.hasNextPage
    }'
