---
type: regex
target: { source: file, path: CLAUDE.md }
pattern: '<laravel-boost-guidelines>(?:(?!</laravel-boost-guidelines>)[\s\S])*## Agent skills'
match: not_contains
---
