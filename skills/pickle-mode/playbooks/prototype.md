# Prototype

Tools: none required.

You own the decision, not the code. Speed beats polish: no tests, no abstractions, no production wiring.

1. Copy these steps into the todo list. Mark a skipped step `skip: <reason>`.
2. Name the decision the prototype exists to make. No decision means no prototype: switch to feature.
3. Build in a scratch location apart from production code, with the lightest stack that shows the idea. For a behaviour or timing question, the smallest script that exercises it.
4. When comparing versions, build them side by side or behind one switch, each labelled. Add a version the user did not ask for when it widens the choice.
5. Look at each version the way the user will: `verify.ui` from the profile for anything visible, the output or timing for a behaviour question.
6. Report the versions, the evidence for each, the trade-offs, a recommendation and the scratch path. Say plainly that the code is throwaway. End with the Loaded line.
