# Issue tracker: Jira

Issues and specs for this repo live in Jira project **{{KEY}}** on `{{site}}.atlassian.net`. Use Atlassian's MCP server for all operations: `{{server name}}` in this repo's sessions.

## Conventions

Every Jira tool takes a `cloudId`: `{{cloudId}}` for this site (from `getAccessibleAtlassianResources`).

- **Create an issue**: `createJiraIssue` with `projectKey: "{{KEY}}"`, an issue type (`{{Task}}`), a summary and a description.
- **Read an issue**: `getJiraIssue` with the key (`{{KEY}}-123`).
- **List issues**: `searchJiraIssuesUsingJql` with JQL such as `project = {{KEY}} AND statusCategory != Done ORDER BY created DESC`.
- **Make an issue a sub-task of a parent**: `convertJiraIssueHierarchy`. Without it, put `Part of {{KEY}}-<n>` at the top of the description.
- **Comment on an issue**: `addOrEditJiraIssueComment`.
- **Apply / remove labels, edit fields**: `editJiraIssue`.
- **Change status or close**: `listJiraIssueTransitions` for the transition id, then `transitionJiraIssue`. Comment first when the reason matters.

## When a skill says "publish to the issue tracker"

Create a Jira issue in project **{{KEY}}**.

## When a skill says "fetch the relevant ticket"

Read it as in **Read an issue** above.
