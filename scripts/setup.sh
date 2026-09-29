#!/usr/bin/env bash
# ==============================================================================
# CryptPad Initial Instance Setup Script (Linux / Production Server)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

STORAGE_PATH="${CPAD_STORAGE_PATH:-/media/cryptpad}"

echo "=================================================="
echo "    CryptPad Instance Setup & Hardening Initializer"
echo "=================================================="
echo "==> Target storage path: $STORAGE_PATH"

# 1. Create required filesystem data directories
echo "==> Creating storage and cache directories in $STORAGE_PATH..."
mkdir -p "$STORAGE_PATH"/{blob,block,data,files,customize,onlyoffice-dist,onlyoffice-conf}

# 2. Set container ownership (UID 4001 is cryptpad inside container)
echo "==> Adjusting permissions for CryptPad container (UID 4001)..."
if command -v chown &>/dev/null; then
    chown -R 4001:4001 "$STORAGE_PATH" 2>/dev/null || {
        echo "Note: Run with sudo if permission is denied:"
        echo "  sudo chown -R 4001:4001 $STORAGE_PATH"
    }
fi

# 3. Copy customize template if not yet present in storage path
if [ ! -f "$STORAGE_PATH/customize/application_config.js" ] && [ -f "customize/application_config.js" ]; then
    echo "==> Initializing customize/application_config.js in $STORAGE_PATH..."
    cp -r customize/* "$STORAGE_PATH/customize/" 2>/dev/null || true
fi

# 4. Securely generate loginSalt if still set to placeholder
APP_CONFIG="$STORAGE_PATH/customize/application_config.js"
if [ -f "$APP_CONFIG" ]; then
    if grep -q "CHANGE_THIS_ON_INITIAL_SETUP_WITH_OPENSSL_RAND_HEX_32" "$APP_CONFIG"; then
        echo "==> Generating cryptographically secure loginSalt..."
        NEW_SALT=$(openssl rand -hex 32 2>/dev/null || head -c 32 /dev/urandom | xxd -p -c 32)
        sed -i "s/CHANGE_THIS_ON_INITIAL_SETUP_WITH_OPENSSL_RAND_HEX_32/$NEW_SALT/g" "$APP_CONFIG"
        echo "--------------------------------------------------"
        echo "SUCCESS: Generated instance loginSalt:"
        echo "  $NEW_SALT"
        echo "CRITICAL: Back up $APP_CONFIG!"
        echo "Changing this salt in the future WILL BREAK logins for all users."
        echo "--------------------------------------------------"
    else
        echo "==> loginSalt is already configured in $APP_CONFIG."
    fi
fi

# 5. Initialize .env file if missing
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    echo "==> Copying .env.example to .env..."
    cp .env.example .env
fi

echo ""
echo "Setup complete! Next steps:"
echo "  1. Verify permissions: sudo chown -R 4001:4001 $STORAGE_PATH"
echo "  2. Start the instance: docker compose up -d"
echo "  3. View onboarding logs: docker compose logs -f"
echo "  4. Visit https://pad.dhovin.me/checkup/ to run diagnostics."
