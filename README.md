# RTL Fixer for AI IDEs

Automatic RTL (Right-to-Left) text direction fix for Persian, Arabic, and Hebrew in AI-powered IDEs.

## Supported IDEs

| IDE | Status |
|-----|--------|
| **Kiro** | ✅ Supported |
| **Windsurf** | ✅ Supported |
| **Antigravity** | ✅ Supported |
| **Cursor** | 🔜 Coming soon |

## Features

- 🔄 Auto-detect RTL text (Persian/Arabic/Hebrew)
- ⚡ Real-time - Works during AI streaming
- 💻 Code-aware - Keeps code blocks LTR
- 🎯 UI-safe - Only affects message content, not buttons/menus

## Installation

### Kiro

```powershell
.\patch-kiro-v2.ps1
# Restart Kiro
```

### Windsurf

```powershell
.\patch-windsurf-v2.ps1
# Restart Windsurf
```

### Antigravity

```powershell
# Recommended (Smart/Partial)
.\patch-antigravity-v2.ps1

# Legacy (Global/Full)
.\patch-antigravity.ps1
```

## Uninstall

```powershell
# Kiro
.\unpatch-kiro.ps1

# Windsurf
.\unpatch-windsurf.ps1

# Antigravity
.\unpatch-antigravity.ps1
```

## Re-apply After IDE Updates

When the IDE updates, the patch may be overwritten. Run unpatch first, then patch again:

```powershell
.\unpatch-kiro.ps1
.\patch-kiro-v2.ps1
```

## Files

| File | Description |
|------|-------------|
| `patch-kiro-v2.ps1` | Patch Kiro (recommended) |
| `patch-windsurf-v2.ps1` | Patch Windsurf (recommended) |
| `patch-kiro.ps1` | Patch Kiro v1 (legacy) |
| `patch-windsurf.ps1` | Patch Windsurf v1 (legacy) |
| `unpatch-kiro.ps1` | Remove patch from Kiro |
| `unpatch-windsurf.ps1` | Remove patch from Windsurf |
| `patch-antigravity-v2.ps1` | Patch Antigravity (recommended) |
| `patch-antigravity.ps1` | Patch Antigravity v1 (legacy) |
| `unpatch-antigravity.ps1` | Remove patch from Antigravity |

## v1 vs v2

- **v1**: Targets all elements including `div`, `span` - may affect UI
- **v2**: Only targets `p`, `li`, `h1-h6`, `blockquote` - UI-safe ✅

## How It Works

The scripts inject JavaScript that:
1. Detects RTL characters: `/[\u0600-\u06FF\u0590-\u05FF]/`
2. Sets `direction: rtl` on matching text elements
3. Skips buttons, inputs, nav, code blocks
4. Uses MutationObserver for streaming content

## License

MIT
