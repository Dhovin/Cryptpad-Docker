#!/usr/bin/env bash
# ==============================================================================
# CryptPad Backup Script
# ==============================================================================
# Archives data, keys, configurations, and customizations into a timestamped tarball
# ==============================================================================
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DEST="${1:-backups}"
ARCHIVE_NAME="cryptpad-backup-${TIMESTAMP}.tar.gz"

mkdir -p "$BACKUP_DEST"

echo "==> Creating CryptPad backup: $BACKUP_DEST/$ARCHIVE_NAME ..."

tar -czf "$BACKUP_DEST/$ARCHIVE_NAME" \
    --exclude='backups' \
    --exclude='onlyoffice-dist' \
    --exclude='onlyoffice-conf/onlyoffice-builds.git' \
    data/ \
    customize/ \
    config/ \
    VERSION \
    docker-compose.yml \
    $( [ -f ".env" ] && echo ".env" )

echo "==> Backup complete! File size:"
ls -lh "$BACKUP_DEST/$ARCHIVE_NAME"
