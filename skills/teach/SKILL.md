---
name: teach
description: Explains a change, subsystem or idea plainly so the user actually understands it, by running the how and why skills and weaving what they find into one explanation that builds up diagram by diagram. Use for "teach me this", "help me really understand X", or "explain this change or subsystem to me".
argument-hint: "[change, subsystem or question]"
disable-model-invocation: true
metadata:
  upstream: pstack/skills/teach
  upstream-version: 0.15.29
---

# Teach

**Explain what a thing is, how it works and why it is built that way, in one plain account at the user's pace. The goal is that they understand it, not that you change anything.**

What to teach, from the user: $ARGUMENTS

Teach sits on top of two investigation skills. Get your bearings on what the work is and what it touches, then load the **how** skill (Skill tool, `pickle:how`) for how it works and the **why** skill (Skill tool, `pickle:why`) for why it is that way. They do their own digging. Blend what they find into one plain explanation, lead with what matters to the user, and go deeper when they ask. Reword freely for teaching, with one exception: keep why's confidence language intact. Its hedges are findings, not style.

1. **Decide the few things they should walk away understanding.** Choose them from why they are asking (about to change it, reviewing it, debugging it, new to it) and what they already know, both read from the conversation, not quizzed out of them. Skip what they plainly know. Put the depth where their question is.
2. **Let how and why do the work. Don't redo it.** Read the code yourself to get oriented, then call both skills in one message and combine the results. Match the size to the question: both for a subsystem, maybe one for a small change. Keep why narrow by default, since its full sweep is slow. Put the narrowing in the question you pass it: a scoped question, and the evidence categories to skip with the reason, such as "git and the PR only; the other categories are skipped because this is a two-line change". why records skipped categories and their reasons in Sources Consulted. Widen it only when the reasons are the point.
3. **Start with a plain definition.** Name the thing and say what it is in general terms, the way a senior engineer would say it out loud, with its common name if it has one. Then tie it to the case in front of you ("in X, we use this to ...") and build from there: how it works, the deeper reasons, the edge cases. For each part, explain the idea so it clicks: the problem it solves and how it actually works. Walk through what happens as the user does the thing (opens a long chat, scrolls up) when that is what makes it land. Listing functions and constants is reference, not teaching. Give the smallest complete answer first, a sentence or two, then stop. Add layers when they ask. Never a wall of text.
4. **Keep it a conversation, not a lecture or a performance.** Offer to go deeper or move on, and follow their lead. No quizzes, no pacing theater. Don't print "Pause", don't ask them to say it back, and don't flag a part as important or hard ("this is the tricky part", "here is where it gets interesting"). Just say it. When you would pause, stop and let them respond. In a non-interactive run (`-p`, a scheduled task), deliver it in one go and put any offer to go deeper at the end.
5. **Show, don't only tell, and build the picture up diagram by diagram.** When code is the fastest way to land it, quote the few lines that matter with `file:line`, or the hunk from `git diff`. Draw when a picture lands faster than words. Draw in ASCII inside a fenced code block (boxes, arrows, short labels), which shows the same in the terminal, the desktop app and the IDEs. For anything with three or more moving parts, don't draw one diagram with all of them. Draw a short series where each diagram redraws the last and adds one part, so the user watches the system assemble. To teach a flow from A to B to C, draw it three times: A to B, then redraw and add C, then redraw and add the return edge or the next piece. One diagram with everything, especially one saved for the end, is reference, not teaching. A single simple point needs no figure.

## Voice

Write every response through the **unslop** skill (Skill tool, `pickle:unslop`), in plain spoken English, the way you would explain it to a colleague. Be tight, not terse. State the concrete mechanism, not a metaphor, a framing or a preview of what is coming. This is the target density: "Virtualization runs in two parts, one for rendering and one for loading from disk. When an item scrolls out past the buffer, both its DOM node and its in-memory data are evicted."

- Prefer periods over commas. Keep each sentence to one or two commas, and split it when clauses pile up.
- Give each concept one name and keep it. If the project has a `GLOSSARY.md` (or a `GLOSSARY-MAP.md`), use its terms.
- Don't print framing labels ("the key insight", "at its core", "the thing to walk away with", "TL;DR").
- No mirror sentences ("A without B, or B without A") and no tidy closers ("the rest follows", "it all falls out").
- The words in these steps are directions to you, not labels to print. Don't echo the structure as headers or stock phrases.

**Reply:** the explanation itself, never a report about what you did. Lead with the main point, then the plain account of what it is, how it works and why, and the threads worth chasing with `/pickle:how` or `/pickle:why`.
