# Upgrading CryptPad

This document details how CryptPad updates are delivered to this repository, how to review automated Pull Requests, and how to deploy upgrades safely.

---

## 1. Automated Pull Request Workflow

Whenever a new version of CryptPad is published upstream, `.github/workflows/check-upstream.yml` will automatically open a Pull Request in this repository titled:

`chore(deps): upgrade CryptPad to <version>`

### Anatomy of an Upgrade PR
Each automated PR includes:
* **Upstream Release Notes**: The full release notes from the CryptPad development team, highlighting bug fixes, new features, and any required configuration tweaks.
* **OnlyOffice Status**:
  * `install-onlyoffice.sh is unchanged`: Safe to deploy; existing OnlyOffice builds remain compatible.
  * `OnlyOffice Updates Detected`: Upstream updated `install-onlyoffice.sh`. The container entrypoint will automatically download and update the OnlyOffice editors and wasm converters in `./onlyoffice-dist` upon deployment.
* **Verification Checklist**: Key checkpoints (e.g. verifying `loginSalt` remains intact).

---

## 2. Reviewing and Merging an Upgrade

1. **Review the PR Description**: Check if there are any database schema migrations or manual configuration notes mentioned by the CryptPad team.
2. **Verify CI Checks**: Ensure the `Validate Configuration & Syntax` workflow passed successfully.
3. **Merge the PR**: Click **Merge Pull Request** on GitHub into `main`.

---

## 3. Deploying to Your Server

On your host server, apply the upgrade using the provided update script:

```bash
cd /path/to/Cryptpad

# Pull latest commits from main
git pull origin main

# Run the upgrade routine
./scripts/update.sh
```

### What `scripts/update.sh` Does:
1. Creates an automatic safety backup of your current `config/`, `customize/`, and `.env` files in `backups/pre-upgrade-<timestamp>`.
2. Pulls the new Docker image (`cryptpad/cryptpad:version-<new_version>`).
3. Recreates the container with the updated image.
4. CryptPad's container entrypoint checks if OnlyOffice builds need updating and applies them to the `./onlyoffice-dist` volume.
5. Verifies container health.

---

## 4. Post-Upgrade Verification

1. **Diagnostics Page**: Visit `https://<CPAD_MAIN_DOMAIN>/checkup/` and verify that all diagnostics pass (WebSockets, CSP, origins).
2. **Test Document Creation**:
   * Create a Rich Text document.
   * Create a Spreadsheet / OnlyOffice document to confirm OnlyOffice loads properly.
3. **Check Logs**:
   ```bash
   docker compose logs -f --tail=100 cryptpad
   ```

---

## 5. Rollback Procedure

In the unlikely event that an upstream release causes an issue on your instance:

1. **Revert the Version**:
   Edit `VERSION` or `.env` and set `CPAD_VERSION` back to the previous version (e.g., `2026.5.0`).
2. **Restart with Previous Image**:
   ```bash
   docker compose up -d
   ```
3. If necessary, restore the configuration backup created in `backups/pre-upgrade-<timestamp>`.
