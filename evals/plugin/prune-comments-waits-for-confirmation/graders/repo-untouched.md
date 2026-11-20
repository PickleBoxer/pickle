---
type: regex
target: trace
pattern: 'git\s+(commit|checkout|switch|reset|restore|stash|add|rm|mv|clean)\b'
match: not_contains
---
