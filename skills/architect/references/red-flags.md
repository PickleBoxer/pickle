# Design red flags

Screen every candidate before picking a base. A red flag is a reason to revise or reject the shape.

- **Shallow module.** A large interface that hides little. Callers coordinate several calls to finish one operation, public options expose internal stages, or learning the interface does not spare the caller from learning the implementation. A deep module is not a deep call chain: it concentrates capability behind one interface instead of scattering it across layers.
- **Information leakage.** Several modules depend on the same internal decision: a representation, a policy, a wire or storage format. Changing it needs coordinated edits. Public wire types and pass-through methods that forward the same arguments unchanged are the usual forms.
- **Split ownership.** More than one module writes the same state or keeps its own copy. An agent that edits one writer cannot see the others, so their rules drift apart. Give each piece of state one owner, per **principle-no-shared-writes**.
- **Two ways to do one task.** An agent copies whichever way it finds first, so every way keeps gaining callers. Keep one, move the callers, delete the others in the same change, per **principle-finish-migrations**.
- **Hand-synced list.** Two or more places list the same items, and adding one means editing every list. Keep one list and derive the rest, or make the build fail when they disagree.
