#!/usr/bin/env bash
# ==============================================================================
# CryptPad Initial Instance Setup Script (Linux / Production Server)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

echo "=================================================="
echo "    CryptPad Instance Setup & Hardening Initializer"
echo "=================================================="

# 1. Create required filesystem data directories
echo "==> Creating storage and cache directories..."
mkdir -p data/blob data/block data/data data/files
mkdir -p customize onlyoffice-dist onlyoffice-conf

# 2. Set container ownership (UID 4001 is cryptpad inside container)
echo "==> Adjusting permissions for CryptPad container (UID 4001)..."
if command -v chown &>/dev/null; then
    chown -R 4001:4001 data customize onlyoffice-dist onlyoffice-conf 2>/dev/null || {
        echo "Note: Could not run chown without sudo. If running Docker on Linux, ensure permissions with:"
        echo "  sudo chown -R 4001:4001 data customize onlyoffice-dist onlyoffice-conf"
    }
fi

# 3. Securely generate loginSalt if still set to placeholder
APP_CONFIG="customize/application_config.js"
if [ -f "$APP_CONFIG" ]; then
    if grep -q "CHANGE_THIS_ON_INITIAL_SETUP_WITH_OPENSSL_RAND_HEX_32" "$APP_CONFIG"; then
        echo "==> Generating cryptographically secure loginSalt..."
        NEW_SALT=$(openssl rand -hex 32 2>/dev/null || head -c 32 /dev/urandom | xxd -p -c 32)
        sed -i "s/CHANGE_THIS_ON_INITIAL_SETUP_WITH_OPENSSL_RAND_HEX_32/$NEW_SALT/g" "$APP_CONFIG"
        echo "--------------------------------------------------"
        echo "SUCCESS: Generated instance loginSalt:"
        echo "  $NEW_SALT"
        echo "CRITICAL: Back up customize/application_config.js!"
        echo "Changing this salt in the future WILL BREAK logins for all users."
        echo "--------------------------------------------------"
    else
        echo "==> loginSalt is already configured in $APP_CONFIG. Preserving existing salt."
    fi
fi

# 4. Initialize .env file if missing
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    echo "==> Copying .env.example to .env..."
    cp .env.example .env
    echo "Please edit .env to configure your CPAD_MAIN_DOMAIN and CPAD_SANDBOX_DOMAIN."
else
    echo "==> .env file found. Preserving existing environment configuration."
fi

echo ""
echo "Setup complete! Next steps:"
echo "  1. Review and edit .env with your domain names and settings."
echo "  2. Start the instance: docker compose up -d"
echo "  3. View onboarding logs: docker compose logs -f"
echo "  4. Visit https://<your-main-domain>/checkup/ to run diagnostics."
