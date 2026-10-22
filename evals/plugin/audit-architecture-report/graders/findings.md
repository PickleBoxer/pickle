---
type: llm
---

PASS if the reply gives the report's path and covers every subsystem: a finding for src/orders that replaces the isPaid, isShipped and isCancelled booleans and their optional fields with one status union or state machine; a finding for src/notify that replaces the switch on channel repeated in send, preview and cost with one per-channel table or registry; a finding for src/reports that indexes customers by id instead of calling find inside loops; and an explicit skip for src/format. The findings are grouped into P0 to P3 tiers by ID, and the reply ends without asking the user anything.

FAIL if any of the three findings is missing, src/format gets a recommendation, a finding cites no file, the reply proposes or shows a code change it says it made, or it ends with a question.
