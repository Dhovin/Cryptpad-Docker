#!/usr/bin/env bash
# ==============================================================================
# CryptPad Evict Inactive Data Cron Wrapper
# ==============================================================================
# Moves destroyed & inactive pads to the archive directory based on inactiveTime.
# Recommended cron schedule: Twice a month (1st and 15th at 01:30)
# 30 1 1,15 * * /path/to/Cryptpad/scripts/evict-inactive.sh > /dev/null
# ==============================================================================
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

echo "==> Running CryptPad inactive data eviction..."
docker compose exec -T cryptpad node scripts/evict-inactive.js
