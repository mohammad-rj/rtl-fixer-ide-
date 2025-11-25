# RTL Fixer for Kiro
# Patches Kiro to support RTL text (Persian/Arabic/Hebrew) in chat

$basePath = "$env:LOCALAPPDATA\Programs\Kiro\resources\app\extensions\kiro.kiro-agent\packages\continuedev\gui\dist\assets"
$jsPath = "$basePath\index.js"

Write-Host "RTL Fixer for Kiro" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan

if (-not (Test-Path $jsPath)) {
    Write-Host "Error: Kiro not found at expected path" -ForegroundColor Red
    Write-Host "Path: $jsPath" -ForegroundColor Gray
    exit 1
}

$content = Get-Content $jsPath -Tail 3 -Encoding UTF8
if ($content -match "RTL_FIXER") {
    Write-Host "Already patched!" -ForegroundColor Yellow
    exit 0
}

# Backup
Copy-Item $jsPath "$jsPath.backup" -Force
Write-Host "Backup: $jsPath.backup" -ForegroundColor Gray

# RTL Fixer script
$rtlScript = @"

/* RTL_FIXER - github.com/mohammad-rj/rtl-fixer-ide */
(function(){if(window.__rtl)return;window.__rtl=1;const R=/[\u0600-\u06FF\u0590-\u05FF]/,P=new WeakSet,fix=e=>{if(!e||P.has(e)||e.closest('pre,code,.monaco-editor')||e.children.length>10)return;const t=e.innerText||'';if(!R.test(t))return;P.add(e);e.style.direction='rtl';e.style.textAlign='right';e.style.unicodeBidi='plaintext';e.querySelectorAll('code,pre,kbd').forEach(c=>{c.style.direction='ltr';c.style.textAlign='left'})},scan=()=>document.querySelectorAll('p,li,div,span,h1,h2,h3,h4,h5,h6,td,th').forEach(fix);scan();new MutationObserver(()=>{clearTimeout(window.__rtlT);window.__rtlT=setTimeout(scan,100)}).observe(document.body,{childList:1,subtree:1,characterData:1});console.log('RTL Fixer Active')})();
"@

Add-Content $jsPath $rtlScript -Encoding UTF8
Write-Host "Patched successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Restart Kiro to apply changes." -ForegroundColor Yellow
