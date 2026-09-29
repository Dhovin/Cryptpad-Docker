# ==============================================================================
# CryptPad Initial Instance Setup Script (Windows PowerShell)
# ==============================================================================
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
Set-Location $repoRoot

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "    CryptPad Instance Setup & Hardening Initializer" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Create required filesystem directories
Write-Host "==> Creating storage and cache directories..." -ForegroundColor Yellow
$dirs = @(
    "data/blob",
    "data/block",
    "data/data",
    "data/files",
    "customize",
    "onlyoffice-dist",
    "onlyoffice-conf"
)
foreach ($d in $dirs) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
    }
}

# 2. Securely generate loginSalt if still set to placeholder
$appConfigPath = "customize/application_config.js"
if (Test-Path $appConfigPath) {
    $content = Get-Content $appConfigPath -Raw
    if ($content -match "CHANGE_THIS_ON_INITIAL_SETUP_WITH_OPENSSL_RAND_HEX_32") {
        Write-Host "==> Generating cryptographically secure loginSalt..." -ForegroundColor Yellow
        $bytes = New-Object byte[] 32
        $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
        $rng.GetBytes($bytes)
        $newSalt = ($bytes | ForEach-Object { $_.ToString("x2") }) -join ""

        $content = $content.Replace("CHANGE_THIS_ON_INITIAL_SETUP_WITH_OPENSSL_RAND_HEX_32", $newSalt)
        Set-Content -Path $appConfigPath -Value $content -NoNewline

        Write-Host "--------------------------------------------------" -ForegroundColor Green
        Write-Host "SUCCESS: Generated instance loginSalt:" -ForegroundColor Green
        Write-Host "  $newSalt" -ForegroundColor White
        Write-Host "CRITICAL: Back up customize/application_config.js!" -ForegroundColor Red
        Write-Host "Changing this salt in the future WILL BREAK logins for all users." -ForegroundColor Red
        Write-Host "--------------------------------------------------" -ForegroundColor Green
    } else {
        Write-Host "==> loginSalt is already configured in $appConfigPath. Preserving existing salt." -ForegroundColor Green
    }
}

# 3. Initialize .env file if missing
if (-not (Test-Path ".env") -and (Test-Path ".env.example")) {
    Write-Host "==> Copying .env.example to .env..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "Please edit .env to configure your CPAD_MAIN_DOMAIN and CPAD_SANDBOX_DOMAIN." -ForegroundColor Yellow
} else {
    Write-Host "==> .env file found. Preserving existing environment configuration." -ForegroundColor Green
}

Write-Host ""
Write-Host "Setup complete! Next steps:" -ForegroundColor Cyan
Write-Host "  1. Review and edit .env with your domain names and settings."
Write-Host "  2. Start the instance: docker compose up -d"
Write-Host "  3. View onboarding logs: docker compose logs -f"
Write-Host "  4. Visit https://<your-main-domain>/checkup/ to run diagnostics."
