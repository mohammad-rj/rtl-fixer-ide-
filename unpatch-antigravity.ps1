# Unpatch RTL Fixer from Antigravity
# Restores original files from backup

$basePath = "$env:LOCALAPPDATA\Programs\Antigravity\resources\app\extensions\antigravity"
$htmlPath = "$basePath\cascade-panel.html"
$backupPath = "$htmlPath.backup"

Write-Host "Unpatch RTL Fixer - Antigravity" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

if (-not (Test-Path $backupPath)) {
    Write-Host "Error: No backup found at $backupPath" -ForegroundColor Red
    exit 1
}

Copy-Item $backupPath $htmlPath -Force
Write-Host "Restored from backup!" -ForegroundColor Green
Write-Host "Restart Antigravity to apply." -ForegroundColor Yellow

