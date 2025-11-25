# RTL Fixer for Kiro v2
# Only targets message content, not UI elements

$basePath = "$env:LOCALAPPDATA\Programs\Kiro\resources\app\extensions\kiro.kiro-agent\packages\continuedev\gui\dist\assets"
$jsPath = "$basePath\index.js"

Write-Host "RTL Fixer for Kiro v2" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan

if (-not (Test-Path $jsPath)) {
    Write-Host "Error: Kiro not found at expected path" -ForegroundColor Red
    exit 1
}

# Restore backup first if exists
if (Test-Path "$jsPath.backup") {
    Copy-Item "$jsPath.backup" $jsPath -Force
    Write-Host "Restored from backup" -ForegroundColor Gray
}

# Backup
Copy-Item $jsPath "$jsPath.backup" -Force
Write-Host "Backup created" -ForegroundColor Gray

# RTL Fixer v2 - only p, li, h1-h6, blockquote - skip buttons/inputs/nav
$rtlScript = @"

/* RTL_FIXER_V2 */
(function(){if(window.__rtl)return;window.__rtl=1;
const R=/[\u0600-\u06FF\u0590-\u05FF]/,P=new WeakSet;
function fix(e){
  if(!e||P.has(e))return;
  if(e.closest('button,input,textarea,nav,header,footer,[role="button"],[role="menu"],[role="toolbar"],[role="navigation"],pre,code,.monaco-editor'))return;
  const t=e.innerText||'';
  if(t.length<2||!R.test(t))return;
  P.add(e);
  e.style.direction='rtl';
  e.style.textAlign='right';
  e.querySelectorAll('code,pre,kbd').forEach(c=>{c.style.direction='ltr';c.style.textAlign='left'});
}
function scan(){document.querySelectorAll('p,li,h1,h2,h3,h4,h5,h6,blockquote,td,th').forEach(fix);}
scan();
new MutationObserver(()=>{clearTimeout(window.__rtlT);window.__rtlT=setTimeout(scan,100)}).observe(document.body,{childList:1,subtree:1,characterData:1});
console.log('RTL Fixer v2 Active');
})();
"@

Add-Content $jsPath $rtlScript -Encoding UTF8
Write-Host "Patched successfully!" -ForegroundColor Green
Write-Host "Restart Kiro to apply." -ForegroundColor Yellow
