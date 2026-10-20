# Issue tracker: Linear

Issues and specs for this repo live in Linear, team **{{team name}}**{{, project **{{project}}**}}. Use Linear's MCP server for all operations: `{{server name}}` in this repo's sessions.

## Conventions

Tool names below are the ones the server listed when setup ran; check the server's tool list if a call fails.

- **Create an issue**: `{{save_issue}}` with `title`, `team: "{{team name}}"` and a markdown `description`{{, `project: "{{project}}"`}}.
- **Read an issue**: `{{get_issue}}` with the identifier (`{{ENG}}-123`).
- **List issues**: `{{list_issues}}` filtered by `team`, `state` or `label`.
- **Make an issue a sub-issue of a parent**: set `parentId` to the parent's UUID (read it with `{{get_issue}}`; an identifier like `{{ENG}}-123` is rejected).
- **Comment on an issue**: `{{create_comment}}` with the issue id and `body`.
- **Apply / remove labels, change state**: `{{save_issue}}` with the issue `id` and the new `labels` or `state`.
- **Close**: set the state to the team's done state with `{{save_issue}}`, after a comment saying why.

## When a skill says "publish to the issue tracker"

Create a Linear issue in team **{{team name}}**.

## When a skill says "fetch the relevant ticket"

Read it as in **Read an issue** above.
