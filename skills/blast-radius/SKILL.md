---
name: blast-radius
description: Finds what a change could break outside its diff before it ships, and proves the one fact it is safe because of by running real code instead of writing it up. Use for "blast radius of X", "what could this break", "is this safe to merge", or a small diff you don't trust.
argument-hint: "[change: branch, PR, commit or files]"
metadata:
  upstream: pstack/skills/blast-radius
  upstream-version: 0.15.24
---

# Blast radius

Change: $ARGUMENTS

With no change named, use the diff against the base branch (default `main`), including the working tree.

`how` says what the code does, `why` says why it has its shape, blast radius says what the change breaks somewhere else. Listing callers is not the job: Grep finds those in a second. The job is the breakage Grep won't show.

## Don't trust your own writeup

A writeup that sounds right reads as convincing whether or not it is true. Find the one or two facts the change's safety rests on and prove them by running code.

For each such fact, get it as far down this list as is cheap, and say where it stopped:

1. You said so. Worthless on its own.
2. You pointed at the line: a real `path:line` in the project or in the library's own source.
3. You walked the bad case step by step and showed it cannot be reached.
4. You ran it: a script or test that calls the real code and fails loudly if you are wrong.
5. You reproduced it in the running app.

Level 4 is usually one small script that loads the same library version the app ships and calls the exact function you worry about.

## Steps

1. Read the change: the diff, the symbols it adds, changes and deletes, and what it now does differently, including what the diff does not spell out. Read the PR body and commits (`git log`, `gh pr view`).
2. Find the one fact it is safe because of. Most risky-looking changes are safe because of a single fact, like "this call only drops cache entries that are already dead". If it holds, most risks clear at once. Spend your time here, not on a long list of maybes.
3. Look where Grep stops. Read the source of the library you call, at its pinned version, with any local patch. Work out when things run: async scheduling, teardown and shutdown, framework lifecycle hooks. Follow what a symbol search misses: the JSON an API returns, a DB column, a wire format, another service or language reading the same bytes, a feature flag, a job or cache three hops downstream.
4. Be honest about each risk: a real chance of happening and a real cost if it does. Keep the confirmed ones. List the ones you checked and cleared apart. Cite a real `path:line`, report an empty search as a result, and never invent a caller or an API.
5. Prove the one fact. Write a script or test that runs the real code, run it, and paste what happened. Keep the script outside the change unless it belongs in the test suite.
6. For a big or wide change, get a second, independent read: run the **interrogate** skill (Skill tool, `pickle:interrogate`) with `panel` on the change, passing the safety fact and your risks as the intent. Merge what it finds into Risks.

## Hand back

- **What it does.** What changed, including the part that is not obvious.
- **The fact it is safe because of.** State it, the level it reached, and the proof. If you could not prove it, write `unproven`.
- **Risks.** Each: how it breaks, `path:line`, how likely and how bad, and how to check. Paste the proof for the ones that matter.
- **Cleared.** What you checked and why it is fine.
- **Before you merge.** The cheapest test or repro that catches the real bug, including the script you wrote.

Run the **unslop** skill (Skill tool, `pickle:unslop`) on the writeup. Strip anything private before it goes anywhere public.
