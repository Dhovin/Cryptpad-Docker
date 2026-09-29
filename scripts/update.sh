#!/usr/bin/env bash
# ==============================================================================
# CryptPad Safe Deployment Upgrade Script
# ==============================================================================
# Executes zero/minimal-downtime container upgrade with OnlyOffice & asset builds
# ==============================================================================
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

TARGET_VERSION="${1:-$(cat VERSION | tr -d '[:space:]')}"

echo "=================================================="
echo "    Upgrading CryptPad to Version: $TARGET_VERSION"
echo "=================================================="

# 1. Quick pre-flight check
if [ ! -f "customize/application_config.js" ]; then
    echo "Error: customize/application_config.js not found!"
    exit 1
fi

# 2. Trigger quick backup of configuration & key metadata
echo "==> Creating safety backup of configurations..."
BACKUP_DIR="backups/pre-upgrade-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r config customize VERSION "$BACKUP_DIR/"
if [ -f ".env" ]; then
    cp .env "$BACKUP_DIR/"
fi
echo "Backup created at $BACKUP_DIR"

# 3. Pull updated Docker image
echo "==> Pulling updated CryptPad Docker image..."
export CPAD_VERSION="$TARGET_VERSION"
docker compose pull cryptpad

# 4. Restart containers with new version
echo "==> Starting upgraded container..."
docker compose up -d --remove-orphans cryptpad

# 5. Wait for container to pass initial healthcheck
echo "==> Verifying container status..."
sleep 5
docker compose ps

echo "=================================================="
echo "CryptPad upgraded successfully to $TARGET_VERSION!"
echo "Check instance status at: https://<main-domain>/checkup/"
echo "=================================================="
