---
description: A small diff the user doesn't trust, asking what it could break elsewhere. blast-radius should fire, and the reply should name what breaks outside the diff and the one fact its safety rests on.
expected_outcome: The reply flags that clients reading `created_at` from the API response break, and names the fact the change's safety depends on as proven or unproven.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

This diff looks harmless but I don't trust it. What could it break somewhere else before I merge it?

```diff
diff --git a/src/serializers/order.js b/src/serializers/order.js
--- a/src/serializers/order.js
+++ b/src/serializers/order.js
@@ -1,9 +1,9 @@
 function serializeOrder(order) {
   return {
     id: order.id,
     total: order.totalCents / 100,
-    created_at: order.createdAt.toISOString(),
+    createdAt: order.createdAt.toISOString(),
     status: order.status,
   };
 }

 module.exports = { serializeOrder };
```
