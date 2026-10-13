# Eval

Experimental, ported from pstack.

Tools: by what is compared, see step 2. Subagents as candidates and judge when no tool fits.

You own the experiment design. The result is only as good as the blinding.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Name the variants and pick the tool by what they are:
   - Prompts or model settings in an app that calls Claude: `/claude-api build-eval` builds the eval set and runs it.
   - A Claude Code skill: the `skill-creator` skill's eval loop.
   - A Claude Code plugin: `claude plugin eval`, which runs each case in a fresh session with and without the plugin.
   - Anything else: subagents as candidates and judge, steps 4 to 6.
   Every run spends the user's account. Ask before running.
3. State what counts as success and write a rubric of 3 to 6 concrete criteria. Use real inputs from the project, several of them, including hard ones.
4. Blind every candidate:
   - No word like eval, test, judge, score, compare or benchmark in any prompt, file or folder a candidate sees.
   - A candidate does not know other candidates exist.
   - Do not ask a candidate which rules it followed. Judge from what it did.
5. Run each variant on the same inputs, several times each, to see the spread as well as the average.
6. Judge with one judge that sees outputs by neutral label only, never by variant name, and scores all of them in one pass on the rubric.
7. Read the outputs yourself. Where you disagree with the judge, find out whether the rubric or the judge is at fault (**principle-prove-it-works**).
8. Report the variants, the rubric, the scores with their spread, your own reading, and whether to adopt a variant. End with the Loaded line.
