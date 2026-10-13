# Opening a PR

Tools: `review`.

The project's CLAUDE.md wins on commits, branches and publishing. If it forbids the agent to commit or push, prepare everything and hand the user the commands.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Read the branch: `git status`, `git log` and `git diff` against the base branch. Stop and ask if the tree holds unrelated work.
3. Run `review` on the full diff if no review ran this session. Fix what it finds that is real.
4. Verify with `verify.test`, `verify.types` and `verify.lint` from the profile (**principle-prove-it-works**). Do not open a PR on a red check without saying so in the description.
5. Shape the commits into small, ordered units, each landable on its own (**principle-small-verified-steps**). Titles follow the project's convention, or `type(scope): title` if it has none.
6. Write the title and description for a reviewer who has the diff (**principle-minimize-reader-load**). Short sections, drop any with nothing to say: Why, What changed, Scope (what it leaves out), Risk, Verification (the commands run and their result).
7. Push and open the PR with the project's forge tool, ready for review, not a draft. Pushing publishes: if the user did not ask for the PR in this session, confirm first.
8. Report the PR URL and anything left open. End with the Loaded line.
