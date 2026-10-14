#!/usr/bin/env bash
# Detects the project's stack and prints one JSON object for /pickle:setup.
# Usage: detect-stack.sh [project-dir]. Read-only. Scans the root only, not subprojects.
# Commands are a draft from manifests and lockfiles. The CI config is the better source.
set -euo pipefail

cd "${1:-.}"
config_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

has() { [ -e "$1" ]; }
# Matches a "key": in a JSON file, good enough for dependency and script names.
json_key() { [ -f "$1" ] && grep -q "\"$2\"[[:space:]]*:" "$1"; }
q() { if [ -z "$1" ]; then printf 'null'; else printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"; fi; }
list() { local out="" x; for x in "$@"; do out="$out${out:+,}$(q "$x")"; done; printf '[%s]' "$out"; }

stacks=()
langs=()

# PHP
php_test="" php_types="" php_lint="" php_ui=""
if has composer.json; then
  langs+=(php)
  if json_key composer.json laravel/framework || has artisan; then
    stacks+=(laravel)
    php_test="php artisan test"
    url="$(grep -m1 '^APP_URL=' .env 2>/dev/null | cut -d= -f2- | tr -d '"' || true)"
    php_ui="browser at ${url:-the app URL}"
  else
    stacks+=(php)
  fi
  if json_key composer.json test; then php_test="composer test"
  elif [ -z "$php_test" ] && json_key composer.json pestphp/pest; then php_test="vendor/bin/pest"
  elif [ -z "$php_test" ] && json_key composer.json phpunit/phpunit; then php_test="vendor/bin/phpunit"; fi
  if json_key composer.json larastan/larastan || json_key composer.json phpstan/phpstan || has phpstan.neon || has phpstan.neon.dist; then
    php_types="vendor/bin/phpstan analyse"
  elif json_key composer.json vimeo/psalm || has psalm.xml; then php_types="vendor/bin/psalm"; fi
  if json_key composer.json laravel/pint || has pint.json; then php_lint="vendor/bin/pint --test"
  elif json_key composer.json friendsofphp/php-cs-fixer; then php_lint="vendor/bin/php-cs-fixer fix --dry-run --diff"
  elif has phpcs.xml || has phpcs.xml.dist; then php_lint="vendor/bin/phpcs"; fi
fi

# JavaScript and TypeScript
pm="" js_test="" js_types="" js_lint="" js_ui=""
if has tsconfig.json && ! has package.json; then
  langs+=(typescript); stacks+=(typescript-node); js_types="tsc --noEmit"
fi
if has package.json; then
  if has pnpm-lock.yaml; then pm=pnpm; run="pnpm"; x="pnpm exec"
  elif has yarn.lock; then pm=yarn; run="yarn"; x="yarn"
  elif has bun.lock || has bun.lockb; then pm=bun; run="bun run"; x="bunx"
  else pm=npm; run="npm run"; x="npx"; fi
  ts=false
  if has tsconfig.json || json_key package.json typescript; then ts=true; langs+=(typescript); fi
  # A Laravel app ships a package.json for Vite. It is a JS stack only when it has its own tooling.
  if json_key package.json react || json_key package.json next; then stacks+=(typescript-react)
  elif $ts; then stacks+=(typescript-node)
  elif [ ${#stacks[@]} -eq 0 ]; then stacks+=(javascript); fi
  if json_key package.json test; then js_test="$run test"
  elif json_key package.json vitest; then js_test="$x vitest run"
  elif json_key package.json jest; then js_test="$x jest"; fi
  if json_key package.json typecheck; then js_types="$run typecheck"
  elif json_key package.json vue-tsc; then js_types="$x vue-tsc --noEmit"
  elif $ts; then js_types="$x tsc --noEmit"; fi
  if json_key package.json lint; then js_lint="$run lint"
  elif json_key package.json @biomejs/biome; then js_lint="$x biome check"
  elif json_key package.json eslint; then js_lint="$x eslint ."; fi
  if json_key package.json dev; then js_ui="browser on the dev server ($run dev)"; fi
fi

# Swift
swift_test="" swift_types="" swift_lint="" swift_ui=""
xcode="$(ls -d ./*.xcworkspace ./*.xcodeproj 2>/dev/null | grep -v '/project.xcworkspace' | head -1 || true)"
if has Package.swift || [ -n "$xcode" ]; then
  langs+=(swift)
  stacks+=(swift)
  if [ -n "$xcode" ]; then
    flag="-project"; case "$xcode" in *.xcworkspace) flag="-workspace" ;; esac
    name="${xcode#./}"; case "$name" in *" "*) name="'$name'" ;; esac
    if grep -qs 'SDKROOT = iphoneos' ./*.xcodeproj/project.pbxproj; then
      dest="'platform=iOS Simulator,name=<device>'"; swift_ui="simulator"
    else
      dest="'platform=macOS'"; swift_ui="run the app"
    fi
    swift_test="xcodebuild test $flag $name -scheme <scheme> -destination $dest"
    swift_types="xcodebuild build $flag $name -scheme <scheme> -destination $dest"
  else
    swift_test="swift test"
    swift_types="swift build"
  fi
  if has .swiftlint.yml; then swift_lint="swiftlint"
  elif has .swift-format; then swift_lint="swift format lint --recursive ."; fi
fi

# Other stacks: commands only, no language server entry yet.
other_test="" other_types="" other_lint=""
if has go.mod; then
  stacks+=(go); other_test="go test ./..."; other_types="go vet ./..."
  has .golangci.yml || has .golangci.yaml && other_lint="golangci-lint run"
fi
if has pyproject.toml; then
  stacks+=(python)
  if has uv.lock; then py="uv run "; elif has poetry.lock; then py="poetry run "; else py=""; fi
  grep -q pytest pyproject.toml && other_test="${py}pytest"
  if grep -q '\[tool.mypy\]' pyproject.toml; then other_types="${py}mypy ."
  elif grep -q '\[tool.pyright\]' pyproject.toml; then other_types="${py}pyright"; fi
  grep -q '\[tool.ruff' pyproject.toml && other_lint="${py}ruff check ."
fi

# Task runners. A project's own target usually wraps the right flags and environment,
# so matching targets go first in each verify list.
runner="" runner_file="" targets=()
if [ -f Makefile ]; then runner=make; runner_file=Makefile
  while IFS= read -r t; do targets+=("$t"); done < <(grep -oE '^[A-Za-z0-9_.-]+:([^=]|$)' Makefile | cut -d: -f1 | grep -v '^\.' | awk '!seen[$0]++')
elif [ -f justfile ] || [ -f Justfile ]; then runner=just; runner_file="$( [ -f justfile ] && echo justfile || echo Justfile )"
  while IFS= read -r t; do targets+=("$t"); done < <(grep -oE '^@?[A-Za-z0-9_-]+( [^:=]*)?:([^=]|$)' "$runner_file" | sed -E 's/^@//; s/[ :].*//' | awk '!seen[$0]++')
elif [ -f Taskfile.yml ] || [ -f Taskfile.yaml ]; then runner=task; runner_file="$( [ -f Taskfile.yml ] && echo Taskfile.yml || echo Taskfile.yaml )"
  while IFS= read -r t; do targets+=("$t"); done < <(sed -n '/^tasks:/,/^[^ ]/p' "$runner_file" | grep -oE '^  [A-Za-z0-9_:-]+:' | sed -E 's/^  //; s/:$//')
fi
task_test=() task_types=() task_lint=()
for t in "${targets[@]+"${targets[@]}"}"; do
  case "$t" in
    test|tests|test-*|test_*|*-test|*:test) task_test+=("$runner $t") ;;
    typecheck|type-check|types|check-types|tsc|phpstan|stan|analyse|analyze|psalm|mypy|pyright) task_types+=("$runner $t") ;;
    lint|lint-*|lint_*|*-lint|*:lint|pint|cs|fmt-check|format-check|style) task_lint+=("$runner $t") ;;
  esac
done

# Profile template: the first stack that has one wins.
profile=generic
for s in "${stacks[@]+"${stacks[@]}"}"; do
  case "$s" in laravel|typescript-react|typescript-node|swift) profile="$s"; break ;; esac
done

# Subprojects one or two levels down, for monorepos. Setup runs this script on each.
subprojects=()
while IFS= read -r m; do
  d="$(dirname "$m")"; d="${d#./}"
  [ "$d" = . ] && continue
  [[ " ${subprojects[*]+"${subprojects[*]}"} " == *" $d "* ]] || subprojects+=("$d")
done < <(find . -maxdepth 3 -mindepth 1 \( -name node_modules -o -name vendor -o -name Pods -o -name 'build' -o -name '.?*' \) -prune -o \
  \( -name composer.json -o -name package.json -o -name Package.swift -o -name go.mod -o -name pyproject.toml -o -name '*.xcodeproj' -o -name Makefile -o -name justfile \) -print 2>/dev/null | sort)

ci=()
for f in .github/workflows/*.yml .github/workflows/*.yaml .gitlab-ci.yml bitbucket-pipelines.yml .circleci/config.yml azure-pipelines.yml; do
  [ -f "$f" ] && ci+=("$f")
done

# Files that may hold coding rules, by name. Setup reads each and keeps the real ones.
conventions=()
while IFS= read -r f; do conventions+=("${f#./}"); done < <(find . -maxdepth 3 -mindepth 1 \
  \( -name node_modules -o -name vendor -o -name Pods -o -name build -o -name dist -o -name .git -o -name storage \) -prune -o \
  -type f \( \
    \( \( -iname '*convention*' -o -iname '*standard*' -o -iname '*style*guide*' -o -iname '*guideline*' -o -iname '*coding*' -o -iname 'contributing*' \) \
       \( -iname '*.md' -o -iname '*.mdc' -o -iname '*.txt' -o -iname '*.rst' \) \) \
    -o -path './.cursor/rules/*' -o -name .cursorrules -o -name .windsurfrules -o -name .clinerules \
    -o -path './.github/copilot-instructions.md' -o -path './.github/instructions/*' \
  \) -print 2>/dev/null | sort)

# LSP plugin per language: enabled in settings, and the server binary on PATH.
enabled() {
  local f
  for f in "$config_dir/settings.json" .claude/settings.json .claude/settings.local.json; do
    [ -f "$f" ] && grep -q "\"$1\"[[:space:]]*:[[:space:]]*true" "$f" && return 0
  done
  return 1
}
lsp_entry() { # language plugin server install
  local on=false found=false
  enabled "$2" && on=true
  command -v "$3" >/dev/null 2>&1 && found=true
  printf '{"language":%s,"plugin":%s,"enabled":%s,"server":%s,"server_found":%s,"install":%s}' \
    "$(q "$1")" "$(q "$2")" "$on" "$(q "$3")" "$found" "$(q "$4")"
}
lsp=()
for p in "${langs[@]+"${langs[@]}"}"; do
  case "$p" in
    php)
      if enabled laravel-lsp@laravel || { [[ " ${stacks[*]} " == *" laravel "* ]] && ! enabled php-lsp@claude-plugins-official; }; then
        lsp+=("$(lsp_entry php laravel-lsp@laravel laravel-lsp 'composer global require laravel/lsp')")
      else
        lsp+=("$(lsp_entry php php-lsp@claude-plugins-official intelephense 'npm install -g intelephense')")
      fi ;;
    typescript) lsp+=("$(lsp_entry typescript typescript-lsp@claude-plugins-official typescript-language-server 'npm install -g typescript-language-server typescript')") ;;
    swift) lsp+=("$(lsp_entry swift swift-lsp@claude-plugins-official sourcekit-lsp 'ships with Xcode and the Swift toolchain')") ;;
  esac
done
lsp_json="[$(IFS=,; printf '%s' "${lsp[*]+"${lsp[*]}"}")]"

cmd() { # name values...: one JSON list per verify purpose, empty values dropped
  local vals=() v; shift
  for v in "$@"; do [ -n "$v" ] && vals+=("$v"); done
  list "${vals[@]+"${vals[@]}"}"
}

printf '{\n'
printf '  "profile": %s,\n' "$(q "$profile")"
printf '  "stacks": %s,\n' "$(list "${stacks[@]+"${stacks[@]}"}")"
printf '  "package_manager": %s,\n' "$(q "$pm")"
printf '  "verify": {\n'
printf '    "test": %s,\n' "$(cmd test "${task_test[@]+"${task_test[@]}"}" "$php_test" "$js_test" "$swift_test" "$other_test")"
printf '    "types": %s,\n' "$(cmd types "${task_types[@]+"${task_types[@]}"}" "$php_types" "$js_types" "$swift_types" "$other_types")"
printf '    "lint": %s,\n' "$(cmd lint "${task_lint[@]+"${task_lint[@]}"}" "$php_lint" "$js_lint" "$swift_lint" "$other_lint")"
printf '    "ui": %s\n' "$(cmd ui "$php_ui" "$swift_ui" "$js_ui")"
printf '  },\n'
printf '  "task_runner": %s,\n' "$( [ -n "$runner" ] && printf '{"tool":%s,"file":%s,"targets":%s}' "$(q "$runner")" "$(q "$runner_file")" "$(list "${targets[@]+"${targets[@]}"}")" || printf null )"
printf '  "subprojects": %s,\n' "$(list "${subprojects[@]+"${subprojects[@]}"}")"
printf '  "ci": %s,\n' "$(list "${ci[@]+"${ci[@]}"}")"
printf '  "convention_files": %s,\n' "$(list "${conventions[@]+"${conventions[@]}"}")"
printf '  "lsp": %s\n' "$lsp_json"
printf '}\n'
