---
name: improve-codebase-architecture
description: Scan a codebase for deepening opportunities, present them as an offline HTML report, then grill through whichever one you pick. Add "report only" to stop after the report.
argument-hint: "[area, pain point or spec path] [report only]"
disable-model-invocation: true
metadata:
  upstream: mattpocock-skills/skills/engineering/improve-codebase-architecture
  upstream-version: 1.3.1
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities**: refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

Direction from the user: $ARGUMENTS

## Rules

- **No code changes.** The run produces a conversation and one HTML report in `.scratch/reports/`. `GLOSSARY.md` and ADR edits happen only in step 4, through their skills.
- **Stop after the report.** Ask which candidate to explore and wait. Propose no interfaces before the user picks one.
- **"report only"** in the direction: end after step 3 with the report path and a one-line summary per candidate. Ask nothing.

Load the vocabulary first with the **codebase-design** skill (Skill tool, `pickle:codebase-design`): **module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality**, the deletion test, "the interface is the test surface", "one adapter means a hypothetical seam, two means a real one". Use these terms exactly in every candidate; don't drift into "component", "service", "API" or "boundary". For domain concepts, use the terms in `GLOSSARY.md`: "the Order intake module", not "the FooBarHandler" and not "the Order service".

## 1. Scope

Deepening a module pays off by making future changes to it easier, so weight the parts of the codebase that change. Decide *where* to look before you look:

- If the direction names a module, subsystem, pain point or spec, take it and skip the hot-spot search. For a spec, ask: what would make this change easy?
- Otherwise, find the hot spots:

  ```bash
  git log --since="6 months ago" --name-only --format= | grep -v '^$' | sort | uniq -c | sort -rn | head -30
  ```

  If that is empty, use `git log -n 200 --name-only --format=` instead. Group the busiest files into 1 to 3 areas. If changes are scattered with no clear hot spot, widen the net.

Read the domain docs before exploring: `docs/agents/domain.md` if it exists, then `GLOSSARY.md` (or `GLOSSARY-MAP.md`) and the ADRs that touch each area. If none exist, go on without them.

## 2. Explore

Spawn one explorer per area with the Agent tool, all in one message so they run at the same time, `subagent_type: Explore`. If the Agent tool is not available, explore each area yourself in turn.

A subagent sees none of this conversation. Each brief carries:

- the area's paths and why it is a hot spot
- the glossary terms and ADR titles for the area
- the codebase-design vocabulary above, and the deletion test
- the friction questions:
  - Where does understanding one concept mean bouncing between many small modules?
  - Where are modules **shallow**, with an interface nearly as complex as the implementation?
  - Where were pure functions extracted for testability, while the bugs hide in how they're called (no **locality**)?
  - Where do modules leak across their seams, for example the same rule in two places?
  - What is untested, or hard to test through its current interface?
- what to return, per candidate: files, the friction with file and line evidence, the deletion test result ("concentrates" or "just moves"), the dependency category (`in-process`, `local-substitutable`, `ports & adapters`, `mock`, as in `${CLAUDE_PLUGIN_ROOT}/skills/codebase-design/references/deepening.md`), and any ADR it would contradict

Keep a candidate only when deleting the shallow modules would concentrate complexity behind a smaller interface. If a candidate contradicts an ADR, keep it only when the friction is real enough to reopen the ADR, and mark it.

## 3. Report

Write one self-contained HTML file, following [references/html-report.md](references/html-report.md). It is fully offline: inline CSS and hand-built SVG, no scripts, no CDN. Write it to `.scratch/reports/architecture-review-<timestamp>.html` at the repo root, with `<timestamp>` from `date +%Y-%m-%d-%H%M`, so reports collect in one place and each run gets a fresh file. Create the folder if it is missing. It is the only file the run writes outside step 4. Open it (`open` on macOS, `xdg-open` on Linux) and give the absolute path.

At most 6 candidates, strongest first. Each card has:

- **Files**: the modules involved
- **Problem**: why the current shape causes friction
- **Solution**: what would change, in plain English
- **Wins**: in terms of locality and leverage, and how tests improve
- **Before / after diagram**
- **Strength**: `Strong`, `Worth exploring` or `Speculative`

End with a **Top recommendation**: the candidate to tackle first and why. If every candidate is `Speculative`, say plainly that the scan found nothing worth doing now.

In the reply, give the path and one line per candidate, then ask: "Which of these would you like to explore?" Stop there.

## 4. Grill the chosen candidate

Once the user picks one, settle its design in rounds. Each round asks every open decision whose prerequisites are already settled, numbered, each with your recommended answer, worded so "yes" accepts it. Wait for the answers, then ask the next round. A question that depends on another question in the same round belongs to a later round.

Start from: where the seam goes, what sits behind it, the dependency category and its adapters, which tests survive and which are replaced, and only then the shape of the interface.

- **Facts are your job.** When a question needs a fact from the code, send an Explore subagent instead of asking the user, and ask the rest of the round meanwhile. Decisions are the user's.
- **Probe vague answers.** If the user answers "cleaner" or "more scalable", ask what they would actually want if they didn't have to justify it.
- **Alternative interfaces**: use the design-it-twice step of the **codebase-design** skill (Skill tool, `pickle:codebase-design`).
- **Naming**: when the deepened module is named after a concept not in `GLOSSARY.md`, or a term gets sharpened, update the glossary with the **domain-modeling** skill (Skill tool, `pickle:domain-modeling`).
- **Rejection**: when the user rejects the candidate for a reason a future review would need, offer an ADR: "Want me to record this as an ADR so future architecture reviews don't re-suggest it?" On yes, write it with the **documentation-and-adrs** skill (Skill tool, `pickle:documentation-and-adrs`). Skip ephemeral reasons ("not now") and self-evident ones.

Grilling is done when no decision is left open and the user confirms the shared understanding. Don't implement.

## 5. Hand off

The output is a decision, not a diff. Take one candidate per session: carry the decision forward, not the report. Suggest the next step: a spec with the **spec-driven-development** skill (Skill tool, `pickle:spec-driven-development`), then tasks with the **planning-and-task-breakdown** skill (Skill tool, `pickle:planning-and-task-breakdown`). The other candidates can become issues for later, in the tracker `docs/agents/issue-tracker.md` names.
