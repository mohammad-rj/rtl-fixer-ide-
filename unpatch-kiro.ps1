# Unpatch RTL Fixer from Kiro
# Restores original files from backup

$basePath = "$env:LOCALAPPDATA\Programs\Kiro\resources\app\extensions\kiro.kiro-agent\packages\continuedev\gui\dist\assets"
$jsPath = "$basePath\index.js"
$backupPath = "$jsPath.backup"

Write-Host "Unpatch RTL Fixer - Kiro" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

if (-not (Test-Path $backupPath)) {
    Write-Host "Error: No backup found at $backupPath" -ForegroundColor Red
    exit 1
}

Copy-Item $backupPath $jsPath -Force
Write-Host "Restored from backup!" -ForegroundColor Green
Write-Host "Restart Kiro to apply." -ForegroundColor Yellow
