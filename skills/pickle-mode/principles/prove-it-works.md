# Prove it works

Check the real thing, not a proxy. A claim without direct evidence is a guess.

**Check directly.**

- Run the project's verify commands from the profile and read the output. "It compiles" is not "it works".
- Observe the actual behaviour on the surface the user uses: the endpoint, the page, the CLI, the job.
- Read the actual value, not a cached or derived copy. Check that a process is alive, not that its log file is recent.
- A subagent's report is a claim. Check the artifact it points to.
- When a check fails strangely, suspect the way you observed before suspecting the system.

**Script the check when you can.** A small script or test that reruns the comparison beats a one-time look, and a reviewer can rerun it.

**Explain every number** (timings, query counts, scores) before you trust, report or act on it.

- Ask "why not twice as good?" Name what limits the result (CPU, a lock, the database, the network, the load generator) from a profile or counters, not from reading code.
- List what else the number could be measuring and rule each out: errors, skipped or cached work, code that never ran, an untuned side, noise, a part too small to matter.
- Report the number with its evidence: run count, spread and the limit you found.

**Report honestly.** Say what was verified, how, and what was not. "Not verified" is a valid result. A claimed pass that was never run is not.
