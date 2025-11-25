# Unpatch RTL Fixer from Windsurf
# Restores original files from backup

$basePath = "$env:LOCALAPPDATA\Programs\Windsurf\resources\app\extensions\windsurf"
$htmlPath = "$basePath\cascade-panel.html"
$backupPath = "$htmlPath.backup"

Write-Host "Unpatch RTL Fixer - Windsurf" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan

if (-not (Test-Path $backupPath)) {
    Write-Host "Error: No backup found at $backupPath" -ForegroundColor Red
    exit 1
}

Copy-Item $backupPath $htmlPath -Force
Write-Host "Restored from backup!" -ForegroundColor Green
Write-Host "Restart Windsurf to apply." -ForegroundColor Yellow
