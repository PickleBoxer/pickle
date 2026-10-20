#!/usr/bin/env bash
# A Laravel 12 repo on GitHub with Laravel Boost: its MCP server and its guidelines block in CLAUDE.md.
set -euo pipefail
git init -q
git remote add origin git@github.com:acme/shop.git
cat > composer.json <<'JSON'
{
    "require": { "php": "^8.4", "laravel/framework": "^12.0" },
    "require-dev": { "laravel/boost": "^2.4", "pestphp/pest": "^4.0" }
}
JSON
cat > composer.lock <<'JSON'
{
    "packages": [
        { "name": "laravel/framework", "version": "v12.31.1" }
    ],
    "packages-dev": [
        { "name": "laravel/boost", "version": "v2.4.6" },
        { "name": "pestphp/pest", "version": "v4.1.0" }
    ]
}
JSON
cat > .mcp.json <<'JSON'
{
    "mcpServers": {
        "laravel-boost": { "command": "php", "args": ["artisan", "boost:mcp"] }
    }
}
JSON
cat > CLAUDE.md <<'MD'
<laravel-boost-guidelines>
=== foundation rules ===

# Laravel Boost Guidelines

- Use the `search-docs` tool before other approaches for Laravel ecosystem documentation.

</laravel-boost-guidelines>
MD
