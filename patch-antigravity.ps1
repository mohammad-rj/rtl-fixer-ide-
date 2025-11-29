# RTL Fixer for Antigravity
# Patches Antigravity to support RTL text (Persian/Arabic/Hebrew) in chat

$basePath = "$env:LOCALAPPDATA\Programs\Antigravity\resources\app\extensions\antigravity"
$htmlPath = "$basePath\cascade-panel.html"

Write-Host "RTL Fixer for Antigravity" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

if (-not (Test-Path $htmlPath)) {
    Write-Host "Error: Antigravity not found at expected path" -ForegroundColor Red
    exit 1
}

# Restore backup first if exists
if (Test-Path "$htmlPath.backup") {
    Copy-Item "$htmlPath.backup" $htmlPath -Force
    Write-Host "Restored from backup" -ForegroundColor Gray
}

# Backup
Copy-Item $htmlPath "$htmlPath.backup" -Force
Write-Host "Backup created" -ForegroundColor Gray

$content = Get-Content $htmlPath -Raw -Encoding UTF8

# RTL Fixer script - targets div, span, etc.
$rtlScript = @"
    <!-- RTL_FIXER -->
    <script>
    (function(){if(window.__rtl)return;window.__rtl=1;
    const R=/[\u0600-\u06FF\u0590-\u05FF]/,P=new WeakSet;
    function fix(e){
      if(!e||P.has(e))return;
      if(e.closest('pre,code,.monaco-editor')||e.children.length>10)return;
      const t=e.innerText||'';
      if(!R.test(t))return;
      P.add(e);
      e.style.direction='rtl';
      e.style.textAlign='right';
      e.style.unicodeBidi='plaintext';
      e.querySelectorAll('code,pre,kbd').forEach(c=>{c.style.direction='ltr';c.style.textAlign='left'});
    }
    function scan(){document.querySelectorAll('p,li,div,span,h1,h2,h3,h4,h5,h6,td,th').forEach(fix);}
    scan();
    new MutationObserver(()=>{clearTimeout(window.__rtlT);window.__rtlT=setTimeout(scan,100)}).observe(document.body,{childList:1,subtree:1,characterData:1});
    console.log('RTL Fixer Active');
    })();
    </script>
  </body>
"@

$newContent = $content -replace '</body>', $rtlScript
Set-Content $htmlPath $newContent -Encoding UTF8

Write-Host "Patched successfully!" -ForegroundColor Green
Write-Host "Restart Antigravity to apply." -ForegroundColor Yellow
