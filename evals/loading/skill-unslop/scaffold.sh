#!/usr/bin/env bash
# Fixture for loading-skill-unslop: the shared Laravel base plus release notes full of AI tells.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../_fixture/laravel.sh"

base_files
mkdir -p docs
cat > docs/release-notes.md <<'MD'
# Release Notes: A Pivotal Step Forward

Great news! This release serves as a testament to our commitment to quality, showcasing a vibrant new ordering experience.

- **Performance:** Performance has been significantly enhanced, ensuring a seamless experience.
- **Shipping:** Orders are now shipped faster, fostering customer delight.

It is important to note that, in order to leverage the new flow, teams could potentially want to delve into the updated docs. Not just a refresh, but a whole new paradigm. The future looks bright!
MD
base_commit
