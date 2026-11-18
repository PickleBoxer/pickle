# Set up a home repo

A home repo is one repository that holds your shared skills, shared docs and an instruction file that points to your other repos. You start agent sessions there, and the agent follows a pointer when a task needs another repo. You get one copy of your agent setup, one place to start agents, and changes across repos from one session. If you can have a monorepo, use that instead; a home repo is for separate repos.

Based on [The Home Repo Pattern](https://www.aihero.dev/the-home-repo-pattern) (AI Hero). Claude Code facts are marked **read** with their docs page; **inferred** marks our untested conclusions.

## Decide first

| Decision | Default |
|---|---|
| Where it lives | Next to your repos: `~/dev/code/home` beside `~/dev/code/api` |
| Personal or team | Personal first; share it once it works |
| Which repos | Repos with a commit in the last year |
| Instruction file | `AGENTS.md`, plus a `CLAUDE.md` that only says `@AGENTS.md`, which Claude Code loads in its place (**read**, `/en/memory.mdx`) |

## 1. Create the repo

```bash
mkdir -p ~/dev/code/home/.claude/skills ~/dev/code/home/docs && cd ~/dev/code/home && git init && printf '@AGENTS.md\n' > CLAUDE.md && printf '.claude/settings.local.json\n' > .gitignore
```

```
home/
├── AGENTS.md                  rules for every repo, pointers to each repo
├── CLAUDE.md                  @AGENTS.md
├── .claude/
│   ├── settings.json          shared: plugins, permissions
│   ├── settings.local.json    your paths, not committed
│   └── skills/                shared skills
└── docs/                      shared docs: coding standards, commit rules
```

## 2. Take stock

List your repos, newest commit first (change `~/dev` to your code folder):

```bash
find ~/dev -maxdepth 4 -name .git -type d -prune 2>/dev/null | while read -r g; do r=${g%/.git}; printf '%s\t%s\t%s\n' "$(git -C "$r" log -1 --format=%cs 2>/dev/null)" "$r" "$(git -C "$r" remote get-url origin 2>/dev/null || echo none)"; done | sort -r
```

List skills by name; a count above 1 is a duplicate:

```bash
find ~/dev ~/.claude/skills -name SKILL.md -not -path '*/node_modules/*' -not -path '*/vendor/*' 2>/dev/null | xargs -n1 dirname | xargs -n1 basename | sort | uniq -c | sort -rn
```

List instruction files, then read them for sections that repeat across repos:

```bash
find ~/dev ~/.claude -maxdepth 5 \( -name CLAUDE.md -o -name AGENTS.md \) -not -path '*/node_modules/*' -not -path '*/plugins/*' 2>/dev/null
```

Skip `.env` files and other secrets. Put each item in one bucket, and write the result as a table (item, path, bucket, destination) before you change anything:

| Bucket | Example | Goes to |
|---|---|---|
| Shared | Your coding standards, commit rules, general skills in `~/.claude/skills` | Home repo |
| Duplicate | The same skill or rule copied into several repos | Home repo, one copy, the newest |
| Repo-specific | A repo's test commands, architecture notes, the skills its team uses | Stays in the repo |
| Installed | Plugins, skills a framework package generates | Stays installed |

A skill in a repo that anyone opens without the home repo stays in that repo, even when the home repo gets a copy. See step 5.

## 3. Write AGENTS.md

Keep it under 200 lines (**read**, `/en/memory.mdx`).

```md
# AGENTS.md

This is the home repo. Start sessions here. Shared skills are in
`.claude/skills/`, shared docs in `docs/`.

## Working in another repo

- Find it under "Other repos". If its path is missing, clone it there.
- Before you change it, read its own `CLAUDE.md` or `AGENTS.md`. Where it
  conflicts with this file, the repo wins.
- List its `.claude/skills/`. If they are not loaded, ask me to run
  `/add-dir <path>`, and until then read the `SKILL.md` files that fit.
- Run its checks, branch, commit and file issues in that repo.
- For a feature across repos, plan it here, then work one repo at a time.

## Shared rules

- Coding standards: `docs/coding-standards.md`

## Other repos

- api (Laravel API for orders): ~/dev/code/api. Clone from git@github.com:acme/api.git if missing.
- storefront (Nuxt storefront): ~/dev/code/storefront. Clone from git@github.com:acme/storefront.git if missing.
- infra (Terraform): ~/dev/code/infra. Clone from git@github.com:acme/infra.git if missing. Ask before any change.
```

One line per repo: name, what it is, path, remote, any warning. Past about 20 repos, point to one file per area instead (`Billing: see repos/billing.md`), each listing its repos.

The "read its own" and "list its skills" rules are needed because Claude Code does not load other repos' instructions or skills from settings-added directories (**read**, `/en/permissions.mdx`).

## 4. Configure Claude Code

Give the agent file access to the repos in `.claude/settings.local.json` (paths differ per machine):

```json
{
  "permissions": {
    "additionalDirectories": ["../api/", "../storefront/", "../infra/"]
  }
}
```

Reads there need no prompt; edits follow your permission mode. It applies after you accept the trust dialog for the home repo (**read**, `/en/permissions.mdx`, `/en/settings-reference.mdx`).

Plugins for every session go in the committed `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "acme-tools": { "source": { "source": "github", "repo": "acme/claude-plugins" } }
  },
  "enabledPlugins": { "code-formatter@acme-tools": true }
}
```

This turns a plugin on but does not install it. Each person runs `claude plugin install code-formatter@acme-tools --scope project` once (**read**, `/en/settings-reference.mdx`).

## 5. Copy the shared material

Copy shared and duplicate items in, then commit in the home repo:

```bash
cp -R ~/dev/code/api/.claude/skills/release-notes ~/dev/code/home/.claude/skills/
```

A skill removed from a repo stops loading in sessions started inside it. So remove repo copies only where nobody uses the repo without the home repo, and do it on a branch:

```bash
git -C ~/dev/code/api switch -c chore/move-shared-agent-files && git -C ~/dev/code/api rm -r .claude/skills/release-notes
```

Where someone does use the repo on its own, keep both copies and sync changes by hand. Never move repo-specific skills.

## 6. Use repo skills

What a home repo session loads from another repo (**read**, `/en/skills.mdx`, `/en/permissions.mdx`):

| How it reaches the repo | Skills | `CLAUDE.md` |
|---|---|---|
| `additionalDirectories` (step 4) | No | No |
| `/add-dir ../api`, or `claude --add-dir ../api` | Yes, for the session | Only with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` |
| Session started in the repo | Yes | Yes |

So when a task works in a repo, run `/add-dir ../api`. Add only the repos the task needs: every loaded skill's description stays in context, and a framework package can bring 20 skills per repo (**inferred**).

If both have a skill with the same name, `/pest-testing` runs the home repo's and `/api:pest-testing` the repo's (Claude Code 2.1.309+, **read**). Keep the repo's version when they differ.

Alternative: clone the repos into a gitignored folder inside the home repo (`home/src/api`). Skills and `CLAUDE.md` files below the start folder load once Claude touches a file there (**read**). Untested with nested git repos (**inferred**), and every path to your clones changes.

## 7. Check

From `cd ~/dev/code/home && claude`:

1. `/` lists the skills in `.claude/skills/`.
2. "Which repos can you work in?" matches "Other repos".
3. "How do I run the api repo's tests?" reads `api/CLAUDE.md` without a permission prompt.
4. After `/add-dir ../api`, `/` lists api's skills.
5. With a repo's folder renamed, the agent offers to clone it.

## Daily use

- **Start in the home repo** and name the repos: "Add an export endpoint in api and a download button in storefront."
- **One worktree per feature**, so several agents can share a repo: `git -C ~/dev/code/api worktree add ~/dev/code/worktrees/api-export -b export`. Add the worktrees folder to `additionalDirectories`.
- **File issues where they belong**: `gh issue create -R acme/api`.
- **Keep pointers current**, and move a rule into the home repo the second time you copy it.
- **For a team**, commit everything except `settings.local.json`, keep the same folder layout on every machine (or use paths like `../api`), and review skill changes like code.

## Let an agent set it up

The prompt below runs steps 2 to 5 with you. Start a session in the folder that holds your repos (`~/dev/code`), paste it, and answer its questions. It only reads until you approve the plan, and it never pushes. The article has its own version of this prompt; ours adds the repo-skills rules from steps 5 and 6.

```text
Set up a home repo with me. A home repo is one git repo that holds my
shared agent skills, my shared agent docs and an AGENTS.md that points
to my other repos. I will start my agent sessions from it.

## How you work

- Find facts yourself with the filesystem, git and gh. Use subagents
  for wide searches. Bring me decisions, not facts you could look up.
- Ask in rounds. Number each question, give your recommended answer,
  and phrase it so that "yes" accepts the recommendation. Hold back a
  question that depends on one still open until a later round.
- Until I approve the plan in Step 3, only read. Change no file.
- Never open .env files or other secrets.
- Never push, and never commit in my other repos.

## Step 1: Find the repos

Find every git repo under my home directory. Skip dependency and build
folders (node_modules, vendor, .venv, dist). For each repo record its
path, remote URL, visibility (public or private, from gh where it can
tell) and last commit date.

Round 1 questions:
- Which repos the home repo points to. Recommend the ones with a commit
  in the last year.
- Where the home repo lives, and whether it is new or an existing repo.
  Recommend a new private repo next to the others.
- Whether it is personal or shared with a team.
- Which instruction file my agent loads at session start: AGENTS.md,
  CLAUDE.md or both. Recommend what my current repos show.
- Which repos anyone opens without the home repo: teammates,
  contractors, CI. Recommend "all team repos" if unsure.

Done when every repo is marked in or out and these questions have
answers.

## Step 2: Find the shared material

In the chosen repos and in my user-level folders (~/.claude/skills,
~/.claude/CLAUDE.md, ~/.claude/rules), list:
- every skill: a folder with a SKILL.md;
- every AGENTS.md, CLAUDE.md and .claude/rules file;
- every doc written for agents: coding standards, commit rules,
  glossaries, ADRs, review checklists.

Put each item in exactly one bucket:
- shared: true for every repo, such as my coding standards;
- duplicate: the same item in several places. Diff the copies and mark
  the newest. Note where they differ;
- repo-specific: about one repo's code, commands or domain, including
  skills its team uses there;
- installed: from a plugin, a marketplace or a package that generates
  it (for example Laravel Boost skills).

Done when every item is in exactly one bucket.

## Step 3: Agree the plan

Show one table: item, current path, bucket, destination, and whether the
repo copy is removed or kept. Rules:
- shared and duplicate items go to the home repo as one copy, the
  newest version;
- repo copies are removed only in repos nobody opens without the home
  repo. Everywhere else they stay, so those users keep them;
- repo-specific items stay in their repo;
- installed items stay installed and are not copied.

Under the table, show the full AGENTS.md for the home repo:
1. Two lines on what the home repo is and where its shared skills and
   docs are.
2. A "Working in another repo" section with these rules:
   - find the repo under Other repos; clone it to that path if missing;
   - read its own AGENTS.md or CLAUDE.md before changing it; the repo
     wins where it conflicts with this file;
   - list its .claude/skills/; if they are not loaded, ask me to run
     /add-dir <path>, and until then read the SKILL.md files that fit;
   - run its checks, branch, commit and file issues in that repo.
3. A "Shared rules" section that links the shared docs.
4. An "Other repos" section with one line per repo:
     <name> (<what it is>): <local path>. Clone from <remote> if missing.
   Add a warning where a repo needs one, such as "ask before any change".
   Past about 20 repos, group the lines into one file per area under
   repos/ and point to those files instead.

Also show the .claude/settings.local.json you will write, with every
chosen repo under permissions.additionalDirectories as a path relative
to the home repo.

Settle open points in more rounds. Done when I approve the table, the
AGENTS.md and the settings file.

## Step 4: Apply the plan

1. Create the home repo with AGENTS.md, .claude/skills/ and docs/. If
   my agent loads CLAUDE.md, add a CLAUDE.md that only says @AGENTS.md.
2. Write .claude/settings.local.json and add it to .gitignore.
3. Copy each shared and duplicate item in. Keep skill folders whole,
   with all their files.
4. Commit in the home repo. Do not push.
5. In each repo where the table says "removed", create a new local
   branch, remove those copies and cut the moved sections from its
   AGENTS.md or CLAUDE.md. Leave the changes uncommitted for me.

Done when every row of the table is applied.

## Step 5: Report

Report each table row with its outcome, the branch you created in each
repo, and every item you skipped with the reason. Then list the checks
for me to run in a new session started in the home repo:
- "/" lists the shared skills;
- asking "which repos can you work in?" matches Other repos;
- after /add-dir for one repo, "/" lists that repo's skills.
```

With pickle installed, start the prompt with `/pickle:pickle-mode` to have it pick skills such as `interview-me` for the decision rounds (**inferred**).

## Troubleshooting

- **Reads in another repo ask for permission:** the path is missing from `additionalDirectories`, or the home repo is not trusted yet.
- **A repo's skills or rules are ignored:** run `/add-dir` for it (step 6) and check the "Working in another repo" rules are in `AGENTS.md`.
- **The wrong copy of a skill runs:** use `/<repo>:<skill>`, or delete the home repo copy.
- **A plugin is enabled but missing:** run its `claude plugin install` (step 4).
