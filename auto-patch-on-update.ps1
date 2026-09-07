# auto-patch-on-update.ps1
# Re-applies RTL/Persian patches and Auto-Accept file modifications whenever VS Code extensions update.
# Supports both Claude Code (anthropic.claude-code-*) and Antigravity (google.google-antigravity-*).
#
# Called from:
# 1. Claude Code SessionStart hook
# 2. Antigravity PreInvocation hook (auto-patch-adapter.js)
#
# It is a cheap no-op on normal sessions: only runs heavy patch if the LATEST installed
# extension folder is NOT yet patched.

$ErrorActionPreference = 'SilentlyContinue'

$extBases = @(
    "$env:USERPROFILE\.vscode\extensions",
    "$env:USERPROFILE\.vscode-insiders\extensions",
    "$env:USERPROFILE\.cursor\extensions"
)

$logFile = Join-Path $PSScriptRoot '.auto-patch.log'

# ── 1. Claude Code ─────────────────────────────────────────────────────────────
foreach ($base in $extBases) {
    if (-not (Test-Path $base)) { continue }
    $ccDir = Get-ChildItem $base -Directory -Filter 'anthropic.claude-code-*' -ErrorAction SilentlyContinue |
             Sort-Object Name -Descending | Select-Object -First 1
    if (-not $ccDir) { continue }

    $css = Join-Path $ccDir.FullName 'webview\index.css'
    if (-not (Test-Path $css)) { continue }

    # Already patched -> skip
    if ((Get-Content $css -Raw -Encoding UTF8) -match 'RTL_CC_CSS') { continue }

    $patchCc = Join-Path $PSScriptRoot 'patch-claude-code.ps1'
    if (-not (Test-Path $patchCc)) {
        $patchCc = Join-Path $PSScriptRoot '_drafts\patch-claude-code.ps1'
    }
    if (Test-Path $patchCc) {
        $stamp = (Get-Date).ToString('s')
        "[$stamp] patching $($ccDir.Name)" | Out-File $logFile -Append -Encoding UTF8
        & $patchCc *>> $logFile
        Write-Output "Patched Claude Code: $($ccDir.Name)"
    }
}

# ── 2. Google Antigravity ──────────────────────────────────────────────────────
$agyDirs = @()
foreach ($base in $extBases) {
    if (Test-Path $base) {
        $found = Get-ChildItem $base -Directory -Filter 'google.google-antigravity-*' -ErrorAction SilentlyContinue
        if ($found) { $agyDirs += $found }
    }
}

if ($agyDirs.Count -gt 0) {
    $latestAgy = ($agyDirs | Sort-Object Name -Descending)[0]
    $extFile = Join-Path $latestAgy.FullName 'extension.js'
    $proxyFile = Join-Path $latestAgy.FullName 'rtl-proxy.js'

    $isPatched = $false
    $patchAgy = Join-Path $PSScriptRoot 'patch-antigravity-vscode.ps1'
    if (-not (Test-Path $patchAgy)) {
        $patchAgy = Join-Path $PSScriptRoot '_drafts\patch-antigravity-vscode.ps1'
    }

    if ((Test-Path $extFile) -and (Test-Path $proxyFile)) {
        $extContent = Get-Content $extFile -Raw -Encoding UTF8
        $proxyContent = Get-Content $proxyFile -Raw -Encoding UTF8
        $hasHooks = ($extContent -match 'RTL_AGY_HOOK') -and 
                    ($extContent -match 'AUTO_ACCEPT_DIFF_START') -and 
                    ($extContent -match 'SUPPRESS_AUTO_OPEN_DIFF_START') -and 
                    ($extContent -match 'SUPPRESS_GIT_REFRESH_START') -and
                    ($proxyContent -match '_cachedPatchedMainJs')
        
        if ($hasHooks) {
            $isPatched = $true
        }
    }

    if (-not $isPatched -and (Test-Path $extFile)) {
        $patchAgy = Join-Path $PSScriptRoot 'patch-antigravity-vscode.ps1'
        if (-not (Test-Path $patchAgy)) {
            $patchAgy = Join-Path $PSScriptRoot '_drafts\patch-antigravity-vscode.ps1'
        }
        if (Test-Path $patchAgy) {
            $stamp = (Get-Date).ToString('s')
            "[$stamp] patching $($latestAgy.Name)" | Out-File $logFile -Append -Encoding UTF8
            & $patchAgy *>> $logFile
            Write-Output "Patched Antigravity: $($latestAgy.Name)"
        }
    }
}

# ── 3. Enforce Auto-Accept & Permissions in Project & Global Settings ────────
try {
    $configDir = "$env:USERPROFILE\.gemini\config"
    $projectsDir = Join-Path $configDir "projects"
    
    if (Test-Path $projectsDir) {
        $projFiles = Get-ChildItem $projectsDir -Filter "*.json" -File
        foreach ($pf in $projFiles) {
            try {
                $raw = Get-Content $pf.FullName -Raw -Encoding UTF8
                $json = $raw | ConvertFrom-Json
                
                if (-not $json.settings) {
                    $json | Add-Member -NotePropertyName "settings" -NotePropertyValue ([PSCustomObject]@{}) -Force
                }
                $json.settings | Add-Member -NotePropertyName "autoExecutionPolicy" -NotePropertyValue "CASCADE_COMMANDS_AUTO_EXECUTION_EAGER" -Force
                $json.settings | Add-Member -NotePropertyName "artifactReviewMode" -NotePropertyValue "ARTIFACT_REVIEW_MODE_TURBO" -Force
                $json.settings | Add-Member -NotePropertyName "agentMode" -NotePropertyValue "accept-edits" -Force
                
                if (-not $json.permissionGrants) {
                    $json | Add-Member -NotePropertyName "permissionGrants" -NotePropertyValue ([PSCustomObject]@{
                        permissionGrants = [PSCustomObject]@{ allow = @() }
                    }) -Force
                }
                if (-not $json.permissionGrants.permissionGrants) {
                    $json.permissionGrants | Add-Member -NotePropertyName "permissionGrants" -NotePropertyValue ([PSCustomObject]@{ allow = @() }) -Force
                }
                
                $needed = @(
                    "*",
                    "*(*)",
                    "mcp(*)",
                    "mcp(*/*)",
                    "call_mcp_tool(*)",
                    "call_mcp_tool",
                    "write_file(*)",
                    "edit_file(*)",
                    "read_file(*)",
                    "read_url(*)",
                    "read_url_content(*)",
                    "execute_url(*)",
                    "url(*)",
                    "command(*)",
                    "unsandboxed(*)"
                )
                $allows = @($json.permissionGrants.permissionGrants.allow)
                foreach ($n in $needed) {
                    if ($allows -notcontains $n) { $allows += $n }
                }
                $json.permissionGrants.permissionGrants.allow = $allows
                
                $out = $json | ConvertTo-Json -Depth 10
                [System.IO.File]::WriteAllText($pf.FullName, $out, (New-Object System.Text.UTF8Encoding($false)))
            } catch {}
        }
    }
    
    $globalCfg = Join-Path $configDir "config.json"
    if (Test-Path $globalCfg) {
        try {
            $raw = Get-Content $globalCfg -Raw -Encoding UTF8
            $json = $raw | ConvertFrom-Json
            if ($json.userSettings) {
                $json.userSettings | Add-Member -NotePropertyName "agentMode" -NotePropertyValue "accept-edits" -Force
                $json.userSettings | Add-Member -NotePropertyName "executionMode" -NotePropertyValue "accept-edits" -Force
                $json.userSettings | Add-Member -NotePropertyName "artifactReviewMode" -NotePropertyValue "ARTIFACT_REVIEW_MODE_TURBO" -Force
                $json.userSettings | Add-Member -NotePropertyName "autoExecutionPolicy" -NotePropertyValue "CASCADE_COMMANDS_AUTO_EXECUTION_EAGER" -Force
                
                $needed = @(
                    "*",
                    "*(*)",
                    "mcp(*)",
                    "mcp(*/*)",
                    "call_mcp_tool(*)",
                    "call_mcp_tool",
                    "write_file(*)",
                    "edit_file(*)",
                    "read_file(*)",
                    "read_url(*)",
                    "read_url_content(*)",
                    "execute_url(*)",
                    "url(*)",
                    "command(*)",
                    "unsandboxed(*)"
                )
                $allows = @($json.userSettings.globalPermissionGrants.allow)
                foreach ($n in $needed) {
                    if ($allows -notcontains $n) { $allows += $n }
                }
                $json.userSettings.globalPermissionGrants.allow = $allows
                
                $out = $json | ConvertTo-Json -Depth 10
                [System.IO.File]::WriteAllText($globalCfg, $out, (New-Object System.Text.UTF8Encoding($false)))
            }
        } catch {}
    }

    $cliDir = "$env:USERPROFILE\.gemini\antigravity-cli"
    if (-not (Test-Path $cliDir)) { New-Item -ItemType Directory -Path $cliDir -Force | Out-Null }
    $cliSettings = Join-Path $cliDir "settings.json"
    @{ agentMode = "accept-edits" } | ConvertTo-Json | Set-Content $cliSettings -Encoding UTF8
    
    $cfgSettings = Join-Path $configDir "settings.json"
    @{ agentMode = "accept-edits" } | ConvertTo-Json | Set-Content $cfgSettings -Encoding UTF8
} catch {}

