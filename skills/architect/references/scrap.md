# When to scrap the sketch

Read while implementing against an architect sketch. If implementation keeps producing friction the sketch cannot absorb, throw the sketch out. Do not bolt fixes onto a wrong design, per **principle-redesign-from-first-principles** and **principle-fix-root-causes**.

The signal is a pattern, not one instance:

- The same shape of workaround in unrelated places.
- Several unrelated edge cases that each need a special-case branch.
- Types that only compile with escape hatches: untyped values, casts, optional fields that are always set in practice.
- A lock, when the sketch said the state was not shared.
- Callers that must know the abstraction's internal rules to use it.
- Two or more independent deviations from the sketch with the same shape.

A few edge cases do not condemn a design. Complexity in the data is not complexity in the design.

To scrap:

1. Run the **how** skill (Skill tool, `pickle:how`) over what has been built.
2. Redesign as if the new constraints had been there from day one.
3. Subtract before adding, per **principle-laziness**: the new sketch is smaller than the old one before it grows.
4. Run the **architect** skill (Skill tool, `pickle:architect`) again with what you learned.
