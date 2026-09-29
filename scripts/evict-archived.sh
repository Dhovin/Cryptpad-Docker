#!/usr/bin/env bash
# ==============================================================================
# CryptPad Evict Archived Data Cron Wrapper
# ==============================================================================
# Permanently removes data archived longer than archiveRetentionTime.
# Recommended cron schedule: Twice a month (7th and 22nd at 01:30)
# 30 1 7,22 * * /path/to/Cryptpad/scripts/evict-archived.sh > /dev/null
# ==============================================================================
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

echo "==> Running CryptPad archived data purging..."
docker compose exec -T cryptpad node scripts/evict-archived.js
