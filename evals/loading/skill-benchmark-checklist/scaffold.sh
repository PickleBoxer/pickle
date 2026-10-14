#!/usr/bin/env bash
# Fixture for loading-skill-benchmark-checklist: the perf fixture plus a one-shot timing script.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../perf/scaffold.sh"

mkdir -p bench
cat > bench/orders.sh <<'SH'
#!/usr/bin/env bash
# Times one request to the orders index.
start=$(date +%s%N)
curl -s -o /dev/null http://localhost:8000/orders
end=$(date +%s%N)
echo "$(( (end - start) / 1000000 )) ms"
SH
chmod +x bench/orders.sh
git add bench
git_eval commit -qm "add orders bench"
