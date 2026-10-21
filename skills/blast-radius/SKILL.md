---
name: blast-radius
description: Finds what a change could break outside its diff before it ships, and proves the one fact the change is safe because of by running real code. Use for "blast radius of X", "what could this break", or before merging a small diff you don't trust yet.
argument-hint: "[change, diff, PR or commit]"
metadata:
  upstream: pstack/skills/blast-radius
  upstream-version: 0.15.25
---

# Blast radius

Find what a change breaks somewhere else, before it ships. The **how** skill (Skill tool, `pickle:how`) tells you what the code does, and the **why** skill (Skill tool, `pickle:why`) tells you why it is shaped that way. This skill tells you what the change breaks outside the diff.

Listing the callers is not the job. Grep finds those in a second. The job is the breakage grep won't show you.

## Don't trust your own writeup

A blast-radius writeup that sounds right is worthless: it reads as convincing whether or not it is true. Find the one or two facts the whole case depends on and prove them by running code.

### How sure are you

For each fact the change's safety depends on, take it as far down this ladder as is cheap, and say where it stopped.

1. **Said.** You said so. Worthless on its own.
2. **Pointed.** A real `file:line`, or the library's own source.
3. **Walked.** You traced the failure step by step and showed it can't be reached.
4. **Ran.** A script or test calls the real code and fails loudly if you're wrong.
5. **Reproduced.** You saw it in the running app.

Level 4 is usually one small script that imports the library version the app ships and calls the exact function you're worried about.

## Steps

1. **Read the change.** The diff, the symbols it adds, changes and deletes, and what it now does differently, including what the diff doesn't spell out. Pull the PR and commit messages with `gh` or the **why** skill (Skill tool, `pickle:why`).
2. **Find the one fact it's safe because of.** Most changes that look risky are safe because of a single fact, such as "this call only drops cache entries that are already dead". Find it. If it holds, most risky cases clear at once. Spend your time here, not on a long list of maybes.
3. **Look where grep stops.**
   - Read the source of the library you call, at its pinned version, with any local patch.
   - Work out when things run: async ordering, teardown and unmount, retries, queued jobs.
   - Follow what a symbol search misses: JSON an API returns, a database column, a wire format, another service or language reading the same bytes, a feature flag, config, code several hops downstream.
4. **Rate each risk honestly.** Give it a real chance of happening and a real cost if it does. Keep the risks you confirmed. List the ones you checked and cleared separately. Cite a real `file:line`. A search that finds nothing is still an answer. Never invent a caller or an API.
5. **Prove the one fact.** Write a script or test that runs the real code, run it, and paste the output.

## What to hand back

- **What it does.** What changed, including the part that isn't obvious.
- **The one fact it's safe because of.** State it, name the ladder level you reached, and show the proof. If you couldn't prove it, write **unproven**.
- **Risks.** For each: how it breaks, the `file:line`, how likely and how bad, and how to check. Paste the proof for the ones that matter.
- **Cleared.** What you checked and why it's fine.
- **Before you merge.** The cheapest test or repro that would catch the real bug, including the script you wrote.

Write it per the **unslop** skill (Skill tool, `pickle:unslop`), cite real code, and strip anything private before it goes anywhere public.
