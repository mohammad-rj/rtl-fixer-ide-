# Claude Code VSCode Extension - RTL Patcher
# Patches webview/index.css (RTL styles) + webview/index.js (content-based auto-direction)
# Supports VS Code, VS Code Insiders, and Cursor.

param(
    [switch]$Unpatch,
    [switch]$ListOnly
)

$ErrorActionPreference = "Stop"

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host " Claude Code RTL Patcher" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# ── 1. Locate Claude Code Extension ──────────────────────────────────────────
$extBases = @(
    "$env:USERPROFILE\.vscode\extensions",
    "$env:USERPROFILE\.vscode-insiders\extensions",
    "$env:USERPROFILE\.cursor\extensions"
)

$targetDirs = @()
foreach ($base in $extBases) {
    if (-not (Test-Path $base)) { continue }
    $found = Get-ChildItem $base -Directory -Filter "anthropic.claude-code-*" -ErrorAction SilentlyContinue
    if ($found) {
        $targetDirs += $found
    }
}

if ($targetDirs.Count -eq 0) {
    Write-Host "Error: Claude Code extension not found in any extensions directory." -ForegroundColor Red
    exit 1
}

# Sort and take the latest version
$claudeDir = ($targetDirs | Sort-Object Name -Descending)[0].FullName
$cssFile = "$claudeDir\webview\index.css"
$jsFile  = "$claudeDir\webview\index.js"

Write-Host "`nExtension : $claudeDir" -ForegroundColor Gray
Write-Host "Target CSS: $cssFile" -ForegroundColor Gray
Write-Host "Target JS : $jsFile" -ForegroundColor Gray

if (-not (Test-Path $cssFile)) {
    Write-Host "Error: index.css not found at $cssFile" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $jsFile)) {
    Write-Host "Error: index.js not found at $jsFile" -ForegroundColor Red
    exit 1
}

if ($ListOnly) {
    Write-Host "`nFound extension: $claudeDir" -ForegroundColor Green
    exit 0
}

$cssBackup = "$cssFile.rtl-backup"
$jsBackup  = "$jsFile.rtl-backup"

# ── 2. Unpatch Mode ───────────────────────────────────────────────────────────
if ($Unpatch) {
    $ok = $true
    if (Test-Path $cssBackup) {
        Copy-Item $cssBackup $cssFile -Force
        Write-Host "CSS restored from backup." -ForegroundColor Green
    } else {
        Write-Host "Warning: CSS backup not found, skipping." -ForegroundColor Yellow
        $ok = $false
    }
    if (Test-Path $jsBackup) {
        Copy-Item $jsBackup $jsFile -Force
        Write-Host "JS restored from backup." -ForegroundColor Green
    } else {
        Write-Host "Warning: JS backup not found, skipping." -ForegroundColor Yellow
        $ok = $false
    }
    if ($ok) {
        Write-Host "`nUnpatched successfully. Restart VS Code." -ForegroundColor Green
    }
    exit 0
}

# ── 3. Patch Mode ─────────────────────────────────────────────────────────────
$cssContent = Get-Content $cssFile -Raw -Encoding UTF8
$jsContent  = Get-Content $jsFile  -Raw -Encoding UTF8

# If already patched, restore original first to ensure clean state
if ($cssContent -match "RTL_CC_CSS|RTL_CC_CSS_V[0-9]") {
    Write-Host "`nPrevious CSS patch detected, re-patching from backup..." -ForegroundColor Yellow
    if (Test-Path $cssBackup) {
        Copy-Item $cssBackup $cssFile -Force
        $cssContent = Get-Content $cssFile -Raw -Encoding UTF8
    } else {
        Write-Host "Error: Patched CSS but no backup found." -ForegroundColor Red
        exit 1
    }
}
if ($jsContent -match "RTL_CC_AUTODIR|RTL_CC_INPUT") {
    Write-Host "Previous JS patch detected, re-patching from backup..." -ForegroundColor Yellow
    if (Test-Path $jsBackup) {
        Copy-Item $jsBackup $jsFile -Force
        $jsContent = Get-Content $jsFile -Raw -Encoding UTF8
    } else {
        Write-Host "Error: Patched JS but no backup found." -ForegroundColor Red
        exit 1
    }
}

# Create backups if not existing
if (-not (Test-Path $cssBackup)) {
    Copy-Item $cssFile $cssBackup -Force
    Write-Host "CSS backup created." -ForegroundColor Gray
}
if (-not (Test-Path $jsBackup)) {
    Copy-Item $jsFile $jsBackup -Force
    Write-Host "JS backup created." -ForegroundColor Gray
}

# ── 4. CSS Patch ──────────────────────────────────────────────────────────────
$rtlCSS = @'

/* RTL_CC_CSS_V16 */
*{unicode-bidi:normal!important}
[dir="rtl"]{direction:rtl!important;text-align:right!important}
.messageInput_cKsPxg,.mentionMirror_cKsPxg,textarea,input{unicode-bidi:plaintext!important}
code,kbd{direction:ltr!important;unicode-bidi:embed!important;display:inline-block}
pre,pre code{direction:ltr!important;unicode-bidi:isolate!important;text-align:left!important}
pre[data-rtl="prose"],pre[data-rtl="prose"] code{direction:rtl!important;unicode-bidi:plaintext!important;text-align:right!important}
'@

Write-Host "Injecting RTL CSS..." -ForegroundColor Gray
[System.IO.File]::WriteAllText($cssFile, ($cssContent + $rtlCSS), (New-Object System.Text.UTF8Encoding($false)))

# ── 5. JS Patch ───────────────────────────────────────────────────────────────
$rtlJS = @'

;(function(){
  if (typeof document === 'undefined' || window.__RTL_CC_AUTODIR__) return;
  window.__RTL_CC_AUTODIR__ = true;
  /* RTL_CC_AUTODIR_V3 */
  var rx = {
    test: function(s) {
      if (!s) return false;
      for (var i = 0; i < s.length; i++) {
        var c = s.charCodeAt(i);
        if ((c >= 1536 && c <= 1791) || (c >= 1872 && c <= 1919) || (c >= 64336 && c <= 65023) || (c >= 65136 && c <= 65279)) {
          return true;
        }
      }
      return false;
    }
  };

  var box = {
    test: function(s) {
      if (!s) return false;
      for (var i = 0; i < s.length; i++) {
        var c = s.charCodeAt(i);
        if ((c >= 0x2500 && c <= 0x259F) || (c >= 0x2190 && c <= 0x21FF) || (c >= 0x2B00 && c <= 0x2BFF)) {
          return true;
        }
      }
      return false;
    }
  };

  var SEL = 'p,li,h1,h2,h3,h4,h5,h6,blockquote,td,th,[class*="userMessage"],[class*="assistantMessage"],[class*="prompt"],[class*="bubble"],[class*="prose"]';

  function setDir(el) {
    try {
      if (el.closest && el.closest('pre, code, kbd, .katex, .math, [class*="monaco"]')) return;
      var t = el.textContent || '';
      if (rx.test(t)) {
        el.setAttribute('dir', 'rtl');
      } else if (el.getAttribute('dir') === 'rtl') {
        el.removeAttribute('dir');
      }
    } catch(e) {}
  }

  function setPre(pre) {
    try {
      var t = pre.textContent || '';
      if (rx.test(t) && !box.test(t)) {
        pre.setAttribute('data-rtl', 'prose');
      } else if (pre.getAttribute('data-rtl') === 'prose') {
        pre.removeAttribute('data-rtl');
      }
    } catch(e) {}
  }

  function setInput(el) {
    try {
      var val = el.value !== undefined ? el.value : (el.textContent || '');
      if (rx.test(val)) {
        el.setAttribute('dir', 'rtl');
      } else {
        el.setAttribute('dir', 'ltr');
      }
    } catch(e) {}
  }

  function apply(root) {
    try {
      if (root.matches) {
        if (root.matches(SEL)) setDir(root);
        if (root.matches('pre')) setPre(root);
        if (root.matches('textarea, input, [contenteditable="true"]')) setInput(root);
      }
      if (root.querySelectorAll) {
        root.querySelectorAll(SEL).forEach(setDir);
        root.querySelectorAll('pre').forEach(setPre);
        root.querySelectorAll('textarea, input, [contenteditable="true"]').forEach(setInput);
      }
    } catch(e) {}
  }

  document.addEventListener('input', function(e) {
    var t = e.target;
    if (t && (t.tagName === 'TEXTAREA' || t.tagName === 'INPUT' || t.isContentEditable)) {
      setInput(t);
    }
  }, true);

  function init() {
    apply(document.body);
    try {
      new MutationObserver(function(muts) {
        for (var i = 0; i < muts.length; i++) {
          var m = muts[i];
          if (m.addedNodes) {
            for (var j = 0; j < m.addedNodes.length; j++) {
              var n = m.addedNodes[j];
              if (n.nodeType === 1) apply(n);
            }
          }
          if (m.type === 'characterData' && m.target.parentElement) {
            var pe = m.target.parentElement;
            var p = pe.closest && pe.closest(SEL);
            if (p) setDir(p);
            var pr = pe.closest && pe.closest('pre');
            if (pr) setPre(pr);
          }
        }
      }).observe(document.body, { childList: true, subtree: true, characterData: true });
    } catch(e) {}
  }

  if (document.body) init();
  else document.addEventListener('DOMContentLoaded', init);
})();
'@

Write-Host "Injecting autodir JS..." -ForegroundColor Gray
[System.IO.File]::WriteAllText($jsFile, ($jsContent + $rtlJS), (New-Object System.Text.UTF8Encoding($false)))

Write-Host "`n  RTL Fix Applied Successfully!" -ForegroundColor Green
Write-Host "   Persian/Arabic messages get dir=rtl, code blocks remain LTR" -ForegroundColor Gray
Write-Host "`n  Action Required:" -ForegroundColor Yellow
Write-Host "   1. Reload window in VS Code (Ctrl+Shift+P -> Developer: Reload Window)" -ForegroundColor White
Write-Host "   2. Open Claude Code panel and enjoy clean RTL!" -ForegroundColor White
Write-Host "`n  To unpatch: .\patch-claude-code.ps1 -Unpatch" -ForegroundColor Cyan
Write-Host ""

