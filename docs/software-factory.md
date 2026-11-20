# Set up a software factory

A software factory is a loop that takes work in (an issue, an alert, a ticket), runs agents through each stage of delivery and hands people only the decisions that need them. One coding agent does one task when you ask. A factory connects many agent runs into a loop that keeps going, shares context between stages, keeps a record of every run and measures whether the whole thing is worth what it costs.

You can run one on your own machine with a small script, or buy one from a provider. This guide explains the idea, helps you pick where it runs, and sets up a local one with [Sandcastle](https://github.com/mattpocock/sandcastle) or with Claude Code alone.

Based on [What is a software factory](https://www.warp.dev/articles/what-is-a-software-factory) (Warp), [Software Factory](https://factory.com/product/software-factory) (Factory) and the [Sandcastle docs](https://github.com/mattpocock/sandcastle/tree/main/docs/guide). Claude Code facts are marked **read** with their docs page; **inferred** marks our untested conclusions. Both vendor pages report results from their own customers and codebases, not independent benchmarks.

## What it is

### The loop

| Stage | The agent | The person |
|---|---|---|
| Intake | Picks up work from GitHub, Linear, Jira, Slack or an error tracker | Labels what the factory may take |
| Triage | Reproduces the issue and sorts it: automate, needs a spec, or needs a person | Takes what triage hands back |
| Spec | Drafts the scope and asks about gaps | Answers and approves the spec |
| Implementation | Writes the code and tests on its own branch | Nothing, unless the agent gets stuck |
| Review and verification | A second agent reviews the diff; a third runs the build or the app to check it works | Reads the summary, not every line |
| Ship | Opens the PR; CI runs | Approves and merges |
| Monitor | Watches production and files the next issue | Decides what is worth fixing |

The last stage feeds the first, so the loop closes. A pipeline that stops at "PR opened" is a set of point automations, not yet a factory.

### Factory or coding agent

| | Coding agent | Software factory |
|---|---|---|
| Started by | You, per task | An event: a label, a schedule, an alert |
| Covers | One stage, usually implementation | Every stage, triage to monitoring |
| Context | One session | Shared across stages and runs |
| Record | The session transcript | A log of every run, its cost and its outcome |
| Where people work | In the loop, at every step | At decision points: spec, approval, merge |

### The layers

Warp names seven layers a factory needs. Start each one small; you do not need all of them on day one.

| Layer | What it holds | Smallest version |
|---|---|---|
| Factory as code | The prompts, scripts and config that define the loop, in git | A `.sandcastle/` folder or a `scripts/factory/` folder |
| Context | What agents know about your code and rules | `AGENTS.md`, skills, a glossary |
| Compute | Where agent runs execute | A sandbox on your laptop |
| Inference | Models and harnesses | One agent CLI with an API key |
| Orchestration | Starts, tracks and recovers runs | A script that loops over labelled issues |
| Access | How work gets in and out | `gh` and a label |
| Improvement | Metrics that show the loop is getting better | A CSV row per run |

## When to use one

Use a factory for work that is repeatable, has a clear input and a checkable result, and has a person to hand back to:

- Bug fixes from a labelled issue queue
- Dependency updates and lint or type fixes
- Docs that drift from code
- First-pass code review and security review on every PR
- Incident follow-up: a failing alert becomes a draft PR

Do not start with work that has no test to say it is done, that touches money or auth without a review, or that needs a design decision on every run. Do not buy a full assembly line before one loop has proved itself.

## Where it runs

| Option | Who runs the compute | Good for | Watch out for | Examples |
|---|---|---|---|---|
| Local | Your machine, in a sandbox or container | Learning, one person, private code that must stay on your machine | Stops when the laptop sleeps; your API keys and quota | Sandcastle, Claude Code worktrees and `--bg` sessions |
| CI | Your CI runners | Loops started by GitHub events | Run time limits, secrets in CI | Claude Code GitHub Actions, a Sandcastle script in a workflow |
| Hosted cloud | A provider | Runs while you are away, no infrastructure | Code leaves your machine; per-run cost | Claude Code scheduled tasks, Warp, Factory SaaS |
| Hybrid | Provider control plane, your compute | Teams that need their own network or data rules | Two systems to operate | Warp self-hosted, Factory Hybrid, Claude Code self-hosted environments |
| On-prem or air-gapped | Your data center | Regulated code, no outside network | You run everything, including models | Factory On-Prem and Air-Gapped |

Sandcastle supports native (Seatbelt on macOS, Bubblewrap on Linux and WSL2), Docker, Podman and cloud sandboxes (Vercel, Daytona, E2B, Modal, Fly.io), so a Sandcastle factory can move from local to cloud compute by changing one line.

## Decide first

| Decision | Default |
|---|---|
| First workflow | Bug fixes from issues with a label such as `afk` |
| First repo | A low-stakes one: an internal tool or a docs site |
| Where it runs | Local, in a sandbox |
| Harness | Sandcastle with Claude Code; Claude Code alone if you do not want a dependency |
| Where commits land | A branch per issue, opened as a draft PR |
| Who merges | Always a person |
| Trial length | About a month, then decide with the metrics from step 5 |

## 1. Pick one workflow

Write the workflow down before you build it. One line each:

- **Input:** what starts a run (an issue labelled `afk`).
- **Done:** what a good result looks like (a draft PR whose tests pass).
- **Fallback:** what happens when the agent fails (a comment on the issue, label changed to `needs-human`).
- **Limit:** the most the loop may spend per run and per day.

If you cannot write the "Done" line, the workflow is not ready for a factory.

## 2. Set up a local factory with Sandcastle

Sandcastle is a TypeScript library that starts a coding agent inside a sandbox, lets it work on a branch and merges its commits back. You write the orchestration as a script, so the factory is code you can review.

Install it in the repo the factory works on, then run its one-time setup:

```bash
npm install --save-dev @ai-hero/sandcastle
```

```bash
npx @ai-hero/sandcastle init
```

`init` creates `.sandcastle/` and checks that the native sandbox works. Native sandboxes hide your stored logins, so the agent authenticates only from `.sandcastle/.env`:

```bash
cp .sandcastle/.env.example .sandcastle/.env
```

Set `CLAUDE_CODE_OAUTH_TOKEN` in it (get one with `claude setup-token`), or `ANTHROPIC_API_KEY`. Keep `.sandcastle/.env` out of git.

```
repo/
├── .sandcastle/
│   ├── .env              agent credentials, not committed
│   ├── .env.example      committed
│   ├── main.mts          the factory script
│   └── prompt.md         what the agent does in each run
└── AGENTS.md             the context every run starts with
```

### Choose a branch strategy

| Strategy | Where commits land | Use it for |
|---|---|---|
| `head` | Straight into your working directory, no branch | Trying a prompt while you watch |
| `merge-to-head` | A temporary branch in a worktree, merged back at the end; HEAD is untouched if the merge fails | Unattended runs you want merged locally |
| `branch` | A branch you name, in a worktree | One branch per issue, opened as a PR |

### Write the loop

This script takes every open issue labelled `afk`, runs one agent per issue on its own branch, then pushes the branch and opens a draft PR. Untested (**inferred**); check `run()`'s options against the Sandcastle reference for your version.

```ts
// .sandcastle/main.mts
import { execFileSync } from "node:child_process";
import { run, claudeCode } from "@ai-hero/sandcastle";
import { seatbelt } from "@ai-hero/sandcastle/sandboxes/seatbelt"; // bwrap() on Linux, docker() anywhere

type Issue = { number: number; title: string; body: string };

const gh = (...args: string[]) => execFileSync("gh", args, { encoding: "utf8" });

const issues: Issue[] = JSON.parse(
  gh("issue", "list", "--label", "afk", "--state", "open", "--json", "number,title,body"),
);

for (const issue of issues) {
  const branch = `agent/issue-${issue.number}`;
  try {
    await run({
      agent: claudeCode("claude-opus-5-5"),
      sandbox: seatbelt(),
      branchStrategy: { type: "branch", branch },
      prompt: `Fix issue #${issue.number}: ${issue.title}\n\n${issue.body}\n\nFollow .sandcastle/prompt.md.`,
    });
    execFileSync("git", ["push", "-u", "origin", branch]);
    gh("pr", "create", "--draft", "--head", branch, "--title", issue.title, "--body", `Closes #${issue.number}`);
  } catch (error) {
    gh("issue", "comment", String(issue.number), "--body", `Factory run failed: ${String(error)}`);
    gh("issue", "edit", String(issue.number), "--remove-label", "afk", "--add-label", "needs-human");
  }
}
```

`.sandcastle/prompt.md` holds the rules every run follows:

```md
You are fixing one GitHub issue in this repo.

- Read AGENTS.md first.
- Reproduce the bug with a failing test before you change code.
- Keep the change to what the issue asks.
- Run the project's checks. Commit only when they pass.
- If you cannot finish, commit nothing and explain why in your last message.
```

Run it:

```bash
npx tsx .sandcastle/main.mts
```

To run several issues at once, start the `run()` calls together with `Promise.all`; each gets its own worktree. Raise `maxIterations` when one issue needs more than one pass.

## 3. Or use Claude Code alone

Claude Code has the parts of a local factory built in. You trade Sandcastle's sandbox per run and its script API for no extra dependency.

| Factory part | Claude Code feature | Source |
|---|---|---|
| One isolated checkout per run | `claude --worktree <name>` creates `.claude/worktrees/<name>/` on branch `worktree-<name>` | **read**, [worktrees](https://code.claude.com/docs/en/worktrees) |
| Unattended run | `claude --bg "<prompt>"` starts a background session that moves into its own worktree before it edits; `claude agents` shows every session and which need you | **read**, [agent-view](https://code.claude.com/docs/en/agent-view) |
| A step in a script | `claude -p "<prompt>" --allowedTools "Read,Edit,Bash"` exits non-zero when the run fails | **read**, [headless](https://code.claude.com/docs/en/headless) |
| Sandbox | `/sandbox` or `sandbox.enabled` limits the files and hosts shell commands can reach; file tools, hooks and MCP servers run outside it | **read**, [sandboxing](https://code.claude.com/docs/en/sandboxing) |
| Event-driven runs in CI | Claude Code GitHub Actions | **read**, [github-actions](https://code.claude.com/docs/en/github-actions) |
| Runs in the cloud on a schedule, an API call or a GitHub event | Scheduled tasks, at claude.ai/code/routines or `/schedule` (research preview) | **read**, [routines](https://code.claude.com/docs/en/routines) |

A minimal loop with `claude -p`:

```bash
gh issue list --label afk --state open --json number --jq '.[].number' | while read -r n; do claude -p --worktree "issue-$n" "Fix GitHub issue #$n. Read it with gh issue view $n. Add a failing test first, run the checks, commit when they pass, then push the branch and open a draft PR with gh pr create --draft." --allowedTools "Read,Edit,Write,Bash(gh *),Bash(git *),Bash(npm test *)"; done
```

`claude -p --worktree` skips the workspace trust check (**read**, [worktrees](https://code.claude.com/docs/en/worktrees)), so run it only in repos you trust. Add `.claude/worktrees/` to `.gitignore`. For isolation beyond shell commands, run Claude Code itself in a container or VM (**read**, [sandbox-environments](https://code.claude.com/docs/en/sandbox-environments)).

## 4. Add the gates with pickle

The loop is only as good as the checks between stages. pickle's workflow skills cover most of them, so a factory run that starts with `/pickle:pickle-mode` gets them without extra prompt text (**inferred**):

| Stage | pickle skill |
|---|---|
| Triage, unclear issue | `pickle:interview-me` (asks before it guesses), `pickle:spec-driven-development` |
| Spec into tasks | `pickle:planning-and-task-breakdown` |
| Implementation | `pickle:incremental-implementation`, `pickle:test-driven-development` |
| Review | `pickle:code-review-and-quality`, `pickle:security-and-hardening` |
| Quality bar the agent may not lower | `pickle:constraint-driven-development` |
| Ship | `pickle:git-workflow-and-versioning`, `pickle:shipping-and-launch` |
| Monitor | `pickle:observability-and-instrumentation`, `pickle:debugging-and-error-recovery` |

For an unattended run, give the agent its answers up front, since `interview-me` would otherwise wait for a person. Put "If the issue is unclear, comment your questions on it and stop" in the prompt.

Load pickle in a Sandcastle or `claude -p` run with `--plugin-dir` or by installing it for the project, and check that the run's transcript shows the skills firing before you rely on them (**inferred**).

## 5. Measure

Log one row per run. Without it you cannot tell whether the factory pays for itself.

| Metric | What it tells you |
|---|---|
| Cost per merged PR | Total spend divided by PRs merged |
| Acceptance rate | PRs merged without big changes, out of PRs opened |
| Intervention rate | Runs where a person had to step in |
| Cycle time | Issue labelled to PR merged |

Keep the transcripts too, so you can replay a bad run. After about a month, keep the workflow, change its prompt, or drop it. Add a second workflow only when the first one's numbers hold.

## Move to a provider

Move when the local loop works and you need one of these:

- Runs while your machine is off: Claude Code scheduled tasks, or a Sandcastle cloud sandbox.
- Several people sharing one factory, with one audit trail and one set of credentials.
- Many models behind one router, so you are not tied to one vendor.
- Compliance: SOC 2, data residency, on-prem or air-gapped.

What to compare, beyond price:

| Question | Why it matters |
|---|---|
| Is the factory defined as code you can export? | Lets you review changes and leave the vendor |
| Where does the compute run, and does code leave your network? | Decides SaaS, hybrid or on-prem |
| Which models and harnesses can it use? | Avoids a forced migration when the leading model changes |
| Do secrets enter the agent's context? | Leaked keys in transcripts and PRs |
| Can you see cost and outcome per run? | Without it you cannot do step 5 |

## Let an agent set it up

The prompt below runs steps 1 to 3 with you. Start a session in the repo the factory will work on, paste it, and answer its questions. It only reads until you approve the plan, and it never pushes or opens PRs during setup.

```text
Set up a local software factory in this repo with me. A software
factory is a loop: work comes in (a labelled issue), an agent runs in a
sandbox on its own branch, checks run, and a draft PR comes out for a
person to merge.

## How you work

- Find facts yourself from the repo, git and gh. Bring me decisions,
  not facts you could look up.
- Ask in rounds. Number each question, give your recommended answer,
  and phrase it so that "yes" accepts the recommendation.
- Until I approve the plan in Step 3, only read. Change no file.
- Never open .env files or other secrets. Never push, never open a PR,
  never create or edit issues during setup.

## Step 1: Read the repo

Find: the language and package manager, the test, lint and type-check
commands, the CI config, AGENTS.md or CLAUDE.md, open issues and their
labels, and whether Docker is installed. Note which checks a change
must pass before it is done.

Round 1 questions:
- Which workflow the factory runs first. Recommend bug fixes from
  issues with a new label "afk".
- Which harness: Sandcastle (a TypeScript script, sandbox per run) or
  Claude Code alone (claude -p with --worktree). Recommend Sandcastle
  for a Node project, Claude Code alone otherwise.
- Which sandbox: native (Seatbelt on macOS, Bubblewrap on Linux) or
  Docker. Recommend native.
- Where commits land. Recommend one branch per issue, as a draft PR.
- The most one run and one day may spend.

## Step 2: Write the definition of done

For the chosen workflow, write one line each for input, done, fallback
and limit. "Done" must name the commands that must pass.

## Step 3: Agree the plan

Show:
- the files you will add, with their full contents: the factory script,
  the per-run prompt, the env example, the .gitignore lines;
- the label to create and the fallback label;
- where each run's cost and outcome is logged (one CSV row per run);
- the exact command I run to start the loop.

Settle open points in more rounds. Done when I approve the plan.

## Step 4: Apply the plan

Add the files. Leave the changes uncommitted for me. Do not run the
loop.

## Step 5: Report

List the files added, the commands I run next (install, init, copy the
env example, create the label, start the loop), and one issue I could
label to try it on.
```

With pickle installed, start the prompt with `/pickle:pickle-mode` to have it pick `interview-me` for the rounds and `ci-cd-and-automation` for the loop (**inferred**).

## Troubleshooting

- **The agent cannot log in inside the sandbox:** native sandboxes hide stored logins. Set `CLAUDE_CODE_OAUTH_TOKEN` or `ANTHROPIC_API_KEY` in `.sandcastle/.env`.
- **A run edited your working copy:** you used the `head` strategy. Use `branch` or `merge-to-head` for unattended runs.
- **PRs pile up faster than you review them:** you moved the bottleneck to review. Add an automated review gate, lower how many issues get the label, or make "Done" stricter.
- **Runs pass but the PRs are wrong:** the checks do not test what the issue asks. Have the prompt write a failing test first, and review the test before the code.
- **Costs climb with no extra merges:** look at intervention and acceptance rates, cut the workflows that miss, and set a per-run limit.
