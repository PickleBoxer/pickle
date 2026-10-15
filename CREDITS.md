# Credits

pickle adapts ideas from [pstack](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan ([@poteto](https://github.com/poteto)), published by Cursor in [cursor/plugins](https://github.com/cursor/plugins) under the MIT license.

What pickle takes from pstack:

- `typescript-best-practices`, ported as a default for TypeScript projects.
- The design of the removed playbooks, principles and tools, kept as `pending` rows in [UPSTREAM.md](UPSTREAM.md) to re-add when needed.

[UPSTREAM.md](UPSTREAM.md) maps each pickle file to its pstack source and records the pstack version it was last compared against. pickle does not track pstack's wording.

pickle also ships skills, commands and agents from [agent-skills](https://github.com/addyosmani/agent-skills) by Addy Osmani, under the MIT license. They are vendored: upstream text with local edits, synced by `scripts/vendor-sync.sh`. Each vendored skill folder carries the upstream `LICENSE`, [LICENSES/agent-skills.txt](LICENSES/agent-skills.txt) covers the commands and agents, and [UPSTREAM.md](UPSTREAM.md) records the agent-skills version pickle is on.

The Claude Code port of pstack is [PickleBoxer/pstack](https://github.com/PickleBoxer/pstack).
