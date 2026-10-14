# Epistemics

Code shows what it does, not why it exists. The why lives in commits, PRs, tickets, docs and conversations, all incomplete and sometimes contradictory. Say what the record supports and no more.

## Tiers

Every claim sits in one tier. The tier sets its section and its wording.

1. **Direct.** Someone wrote down why: a PR description, a ticket, a code comment, a design doc, a chat message from the author. Wording: plain and cited. "This exists because X (PR #123)."
2. **Supported.** Several indirect items point the same way, none says it outright: a PR titled "improve performance", a `perf` label, tests that all use large inputs. Wording: confident but derived, each item cited. "The evidence points to X: A, B and C."
3. **Inferred.** A reasonable reading nothing states: the fix merged the same day the error peaked, so it was likely a hotfix. Wording: hedged, chain visible. "Given A and B, C seems likely."
4. **Speculative.** A plausible story on thin evidence that other stories fit as well. Wording: "One possibility is X, but there is no direct evidence." Usually under Competing hypotheses.
5. **Unknown.** You looked and did not find it. Name what you searched and where.

## Wording

- "because", "the reason is", "was designed to", "fixes", "the team decided" claim Direct or Supported evidence. A citation sits next to them.
- Hedges mark interpretation: "appears to", "likely", "suggests", "is consistent with", "may have been".
- Avoid "obviously", "clearly", "of course", "just", "I think".

## Traps

- **Recency.** The last commit is rarely the whole story. The shape is often many earlier decisions. Trace back.
- **Rationalization.** Code that makes sense today may have been written for reasons that no longer hold, or were wrong. A consistent pattern may be copy and paste. Absence of evidence is not evidence of absence.
- **The user's hypothesis.** Check it like any other candidate. If the evidence does not support it, say so and give what it does support.
- **Contradictions.** Show both sides with citations. Do not pick the tidier one.
- **Gaps.** An honest "we don't know" with the searches named is a result. A confident guess in its place harms the user, who will act on it.

## Before returning

- Every claim under What we found has a citation, or moves down a tier.
- Wording matches the tier.
- No code is cited as evidence of its own intent.
- What we don't know names specific gaps. An empty one is suspicious.
