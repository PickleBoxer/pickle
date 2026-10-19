---
type: llm
---

PASS if the reply judges the handler and validator as shallow or pass-through (for example by imagining them deleted and seeing complexity vanish rather than spread), proposes one deeper order module with a small interface that owns validation, pricing and saving, and says the tests should go through that interface with the database as the only substituted dependency, instead of mocking each module.

FAIL if the reply keeps all three modules and only tidies them, recommends more mocks, or never says where the tests should sit.
