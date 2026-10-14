# Credits

pickle adapts ideas from [pstack](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan ([@poteto](https://github.com/poteto)), published by Cursor in [cursor/plugins](https://github.com/cursor/plugins) under the MIT license.

What pickle takes from pstack:

- Playbooks copied into the todo list, with a reason for every skipped step.
- Naming the data shape before writing code.
- Verifying on the real surface, not a proxy.
- Engineering principles, merged and rewritten language-agnostic. Language rules come from each project's conventions.

[UPSTREAM.md](UPSTREAM.md) maps each pickle file to its pstack source and records the pstack version it was last compared against. pickle does not track pstack's wording. Differences are deliberate: one full process with playbooks and principles loaded only when the task needs them, a project profile with the project's own conventions, and Claude Code native skills and agents.

The Claude Code port of pstack is [PickleBoxer/pstack](https://github.com/PickleBoxer/pstack).
