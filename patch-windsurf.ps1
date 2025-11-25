# RTL Fixer for Windsurf
# Patches Windsurf to support RTL text (Persian/Arabic/Hebrew) in chat

$basePath = "$env:LOCALAPPDATA\Programs\Windsurf\resources\app\extensions\windsurf"
$htmlPath = "$basePath\cascade-panel.html"

Write-Host "RTL Fixer for Windsurf" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan

if (-not (Test-Path $htmlPath)) {
    Write-Host "Error: Windsurf not found at expected path" -ForegroundColor Red
    Write-Host "Path: $htmlPath" -ForegroundColor Gray
    exit 1
}

$content = Get-Content $htmlPath -Raw -Encoding UTF8
if ($content -match "RTL_FIXER") {
    Write-Host "Already patched!" -ForegroundColor Yellow
    exit 0
}

# Backup
Copy-Item $htmlPath "$htmlPath.backup" -Force
Write-Host "Backup: $htmlPath.backup" -ForegroundColor Gray

# RTL Fixer script to inject before </body>
$rtlScript = @"
    <!-- RTL_FIXER - github.com/mohammad-rj/rtl-fixer-ide -->
    <script>
    (function(){if(window.__rtl)return;window.__rtl=1;const R=/[\u0600-\u06FF\u0590-\u05FF]/,P=new WeakSet,fix=e=>{if(!e||P.has(e)||e.closest('pre,code,.monaco-editor')||e.children.length>10)return;const t=e.innerText||'';if(!R.test(t))return;P.add(e);e.style.direction='rtl';e.style.textAlign='right';e.style.unicodeBidi='plaintext';e.querySelectorAll('code,pre,kbd').forEach(c=>{c.style.direction='ltr';c.style.textAlign='left'})},scan=()=>document.querySelectorAll('p,li,div,span,h1,h2,h3,h4,h5,h6,td,th,.prose').forEach(fix);scan();new MutationObserver(()=>{clearTimeout(window.__rtlT);window.__rtlT=setTimeout(scan,100)}).observe(document.body,{childList:1,subtree:1,characterData:1});console.log('RTL Fixer Active')})();
    </script>
  </body>
"@

# Replace </body> with script + </body>
$newContent = $content -replace '</body>', $rtlScript
Set-Content $htmlPath $newContent -Encoding UTF8

Write-Host "Patched successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Restart Windsurf to apply changes." -ForegroundColor Yellow
