---
description: A firing eval. Three pass-through order modules and a test that mocks all of them. codebase-design should fire on its own description, and the reply should judge the modules shallow and deepen them behind one interface.
expected_outcome: codebase-design is invoked; the reply applies the deletion test or names the modules shallow, proposes one deeper module with a small interface, and moves the tests to that interface instead of mocking each layer.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

These order modules feel over-split. Each one forwards to the next, and to test the discount rule I have to mock all three. Should I merge them, and where should the interface sit?

```ts
// orderHandler.ts
export function handleOrder(req: OrderRequest, validator: Validator, repo: Repo) {
  return validator.validate(req, repo);
}

// orderValidator.ts
export function validate(req: OrderRequest, repo: Repo) {
  if (req.items.length === 0) throw new Error("empty order");
  return repo.save(req);
}

// orderRepo.ts
export function save(req: OrderRequest, db: Db) {
  const subtotal = req.items.reduce((sum, i) => sum + i.priceCents * i.qty, 0);
  const total = subtotal > 10_000 ? Math.round(subtotal * 0.9) : subtotal;
  return db.insert("orders", { ...req, totalCents: total });
}

// orderHandler.test.ts
const repo = { save: vi.fn() };
const validator = { validate: vi.fn((req, r) => r.save(req)) };
handleOrder(req, validator, repo);
expect(repo.save).toHaveBeenCalledWith(req);
```
