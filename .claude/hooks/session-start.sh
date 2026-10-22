#!/bin/bash
# Cloud sessions only: install playwright-cli and point it at the preinstalled Chromium.
set -euo pipefail
[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0
command -v playwright-cli >/dev/null || npm install -g @playwright/cli@latest >/dev/null 2>&1
cd "$CLAUDE_PROJECT_DIR"
mkdir -p .playwright
[ -f .playwright/cli.config.json ] || echo '{"browser":{"browserName":"chromium","launchOptions":{"executablePath":"/opt/pw-browsers/chromium"}}}' > .playwright/cli.config.json
