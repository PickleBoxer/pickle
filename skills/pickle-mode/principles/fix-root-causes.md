# Fix root causes

Applies when debugging, investigating wrong behaviour or failing CI, or when a fix is about to target a symptom with a guard, retry or workaround.

Do not fix symptoms. Trace the problem to its cause and fix it there.

**Pattern:**

- **Reproduce first.** A bug you cannot trigger is a bug you cannot confirm fixed.
- **Ask "why" until you reach the cause.** Each answer must come from evidence, not from reading code and guessing.
- **Instrument when stuck.** Add logging, read the actual error, inspect the real state.
- **No silencing guards.** A null check that hides a crash, a retry that hides a failure, or a catch that swallows an error is a symptom fix.
- **A workaround that needs a paragraph of explanation means the code is wrong.** Fix the code, not the comment.
- **Fix the pattern, not the instance.** Search for the same mistake elsewhere and fix every occurrence.
- **"Fails after restart" means suspect state first:** caches, config, lock files, queued jobs, stored sessions.

**When fixes keep failing, attack the premise.** If two or more fixes that share one assumption have failed the same check, the assumption is the suspect, not the fixes.

1. Write down the premise: the one sentence every failed fix assumed.
2. Before the next fix, gather evidence about the premise, for example which actors, inputs or records hold the problem every time.
3. If the same few always do, find what assigns them that role and remove the asymmetry instead of compensating for it.
4. If the evidence is even, the premise is not the cause. Look elsewhere.
