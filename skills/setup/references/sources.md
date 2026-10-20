# Docs sources

Where the source-driven-development skill looks before it fetches a page. Versions come from the lockfile; update a row when a major version changes.

| Stack | Installed version | First source | Fallback |
|-------|-------------------|--------------|----------|
| {{Laravel}} | {{12.x}} | {{Boost MCP `search-docs`}} | {{https://laravel.com/docs/12.x}} |
| {{PHP}} | {{8.4}} | | {{https://www.php.net/manual/en/}} |

## How to use it

- Query the first source when it is connected in this session. Boost's `search-docs` answers for the installed versions of Laravel ecosystem packages, so it needs no version in the query.
- When the first source is empty or not connected, fetch the fallback URL for the installed version and say which source you used.
- A package with no row: find its official docs for the version in the lockfile, as source-driven-development describes.
