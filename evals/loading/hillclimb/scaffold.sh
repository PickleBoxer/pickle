#!/usr/bin/env bash
# Fixture for loading-hillclimb: the shared Laravel base plus what this task needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
cat > phpunit.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<phpunit bootstrap="vendor/autoload.php" colors="true">
    <testsuites>
        <testsuite name="Feature"><directory>tests/Feature</directory></testsuite>
    </testsuites>
    <php>
        <env name="DB_CONNECTION" value="mysql"/>
        <env name="BCRYPT_ROUNDS" value="12"/>
    </php>
</phpunit>
EOF
mkdir -p tests
cat > tests/Pest.php <<'EOF'
<?php

uses(Tests\TestCase::class, Illuminate\Foundation\Testing\RefreshDatabase::class)->in('Feature');

beforeEach(function () {
    $this->artisan('db:seed');
});
EOF
base_commit
