# RTL Fixer for AI IDEs & Extensions

Automatic RTL (Right-to-Left) text direction fix for Persian, Arabic, and Hebrew in AI-powered IDEs and VS Code extensions.

## Supported Environments

| Tool / IDE | Target | Status |
|------------|--------|--------|
| **Google Antigravity** | VS Code Extension (`google.google-antigravity`) | ✅ Fully Supported |
| **Claude Code** | VS Code Extension (`anthropic.claude-code`) | ✅ Fully Supported |
| **Kiro** | IDE Application | ✅ Supported |
| **Windsurf** | IDE Application | ✅ Supported |
| **Cursor** | VS Code / IDE | 🔜 Coming soon |

---

## ⚡ Quick Install (One-Liner in PowerShell)

You can run the patch directly in PowerShell without manually cloning the repository:

### Google Antigravity (VS Code Extension)
```powershell
irm https://raw.githubusercontent.com/mohammad-rj/rtl-fixer-ide-/master/patch-antigravity-vscode.ps1 | iex
```

### Claude Code (VS Code Extension)
```powershell
irm https://raw.githubusercontent.com/mohammad-rj/rtl-fixer-ide-/master/patch-claude-code.ps1 | iex
```

*After running either script, reload VS Code by pressing `Ctrl+Shift+P` -> `Developer: Reload Window`.*

---

## Features

- 🔄 **Real-Time Auto-Direction:** Automatically detects Persian, Arabic, and Hebrew characters during streaming.
- 🎨 **Persian Typography (Vazirmatn):** Injects clean font hierarchy and readable styling.
- 💻 **Code-Aware:** Strict LTR protection for code blocks, inline code, ASCII diagrams, and KaTeX math formulas.
- ⌨️ **Live Input Detection:** Automatically flips text direction of prompt inputs and textareas as you type.
- 🗂️ **Auxiliary Pane Collapse (Antigravity):** Prevents the right diff/files-changed pane from popping up automatically.
- 🚀 **Auto-Accept Diffs (Antigravity):** Automatically accepts file changes without endless confirm dialogs.

---

## Manual Installation (Local Clone)

```powershell
# Clone the repository
git clone https://github.com/mohammad-rj/rtl-fixer-ide-.git
cd rtl-fixer-ide-

# Patch Antigravity in VS Code
.\patch-antigravity-vscode.ps1

# Patch Claude Code in VS Code
.\patch-claude-code.ps1

# Patch Kiro IDE
.\patch-kiro-v2.ps1

# Patch Windsurf IDE
.\patch-windsurf-v2.ps1
```

---

## Uninstall

To restore original backups:

```powershell
# Antigravity (VS Code)
.\patch-antigravity-vscode.ps1 -Unpatch

# Claude Code (VS Code)
.\patch-claude-code.ps1 -Unpatch

# Kiro
.\unpatch-kiro.ps1

# Windsurf
.\unpatch-windsurf.ps1
```

---

## Re-apply After Extensions Update

When VS Code extensions update, run the patch command again. You can also automate this via `auto-patch-on-update.ps1`.

---

## License

MIT
