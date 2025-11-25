# RTL Fixer for AI IDEs

Automatic RTL (Right-to-Left) text direction fix for Persian, Arabic, and Hebrew in AI-powered IDEs.

## Supported IDEs

| IDE | Status | Patch Method |
|-----|--------|--------------|
| **Kiro** | ✅ Supported | JS injection into `index.js` |
| **Windsurf** | ✅ Supported | HTML script injection |
| **Cursor** | 🔜 Coming soon | Similar to Kiro |

## Features

- 🔄 **Auto-detect** RTL text (Persian/Arabic/Hebrew)
- ⚡ **Real-time** - Works during AI streaming
- 💻 **Code-aware** - Keeps code blocks LTR
- 🚀 **Performance** - Debounced MutationObserver

## Installation

### Kiro

```powershell
# Run in PowerShell
.\patch-kiro.ps1
# Restart Kiro
```

### Windsurf

```powershell
# Run in PowerShell
.\patch-windsurf.ps1
# Restart Windsurf
```

## Re-apply After Updates

When the IDE updates, the patch may be overwritten. Just run the script again.

## Uninstall

Restore from backups:

```powershell
# Kiro
$path = "$env:LOCALAPPDATA\Programs\Kiro\resources\app\extensions\kiro.kiro-agent\packages\continuedev\gui\dist\assets"
Copy-Item "$path\index.js.backup" "$path\index.js" -Force

# Windsurf
$path = "$env:LOCALAPPDATA\Programs\Windsurf\resources\app\extensions\windsurf"
Copy-Item "$path\cascade-panel.html.backup" "$path\cascade-panel.html" -Force
```

## How It Works

The scripts inject a small JavaScript snippet that:

1. Detects RTL characters using regex: `/[\u0600-\u06FF\u0590-\u05FF]/`
2. Sets `direction: rtl` and `text-align: right` on matching elements
3. Uses MutationObserver to handle streaming content
4. Preserves LTR direction for code blocks

## Contributing

PRs welcome! If you've patched another IDE, please share.

## License

MIT
