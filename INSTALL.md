# Installation Guide

## Requirements

### Before You Install

✅ **ConnectTunnel must be already installed** on your system  
✅ Typically installed at `/usr/local/Aventail`  
✅ This package adds GUI management tools on top of ConnectTunnel

### System Requirements

- Linux operating system (any distribution)
- ConnectTunnel installed and working
- Python 3.6+ (for GUI tools)
- Bash shell

---

## Quick Install

### 1. Clone from GitHub

```bash
git clone https://github.com/mrmagicbg/connecttunnel-manager.git
cd connecttunnel-manager
```

### 2. Run Installer

```bash
cd connecttunnel-manager
bash install.sh
```

### 3. Follow Prompts

The installer will:
1. Check for ConnectTunnel installation
2. Verify dependencies (Python, PyQt5)
3. Offer to install missing packages
4. Let you choose which tools to install
5. Create desktop shortcuts
6. Optionally set up autostart

### 4. Done!

Launch from:
- Application menu: Search "ConnectTunnel"
- Terminal: `connecttunnel-control-panel`

---

## Installation Options

### Full Automatic Install

Installs everything with no prompts:

```bash
bash install.sh --auto
```

### Control Panel Only

For most users - just the desktop window:

```bash
bash install.sh
# Select option 2 when prompted
```

### Custom Installation

Choose exactly what you want:

```bash
bash install.sh
# Select option 5 (Custom)
# Answer each prompt
```

### System-wide Installation

Install for all users (requires sudo):

```bash
sudo bash install.sh --prefix=/opt/connecttunnel-manager
```

---

## What Gets Installed

### User Installation (Default)

Files go to `~/.local/`:

```
~/.local/bin/
├── connecttunnel-control-panel
├── connecttunnel-helper
└── connecttunnel-manager-uninstall

~/.local/share/applications/
└── connecttunnel-control-panel.desktop

~/.local/share/doc/connecttunnel-manager/
└── Documentation files
```

### System-wide Installation

Files go to custom prefix (e.g., `/opt/`):

```
/opt/connecttunnel-manager/bin/
/opt/connecttunnel-manager/share/
```

---

## Dependencies

### Required

- Python 3.6+
- ConnectTunnel installed

### Recommended (for GUI tools)

**PyQt5** - Install via:

```bash
# Via pip
pip3 install PyQt5

# Via apt (Ubuntu/Debian)
sudo apt-get install python3-pyqt5

# Via dnf (Fedora)
sudo dnf install python3-qt5
```

### Optional

**Window management:**
```bash
sudo apt-get install wmctrl
```

**Dialog boxes:**
```bash
sudo apt-get install kdialog  # KDE
# or
sudo apt-get install zenity   # GNOME
```

---

## Troubleshooting Installation

### "ConnectTunnel not found"

**Cause:** Installer can't find ConnectTunnel

**Solution 1:** Enter path when prompted
```bash
# During installation, when asked for path:
/usr/local/Aventail
# or wherever you installed it
```

**Solution 2:** Skip check
```bash
bash install.sh --no-deps
```

### "PyQt5 not found"

**Cause:** Python GUI library missing

**Solution:**
```bash
pip3 install PyQt5
# Then re-run installer
```

### "Permission denied"

**Cause:** No write access to install location

**Solution 1:** Use default user installation (no sudo needed)
```bash
bash install.sh
# Installs to ~/.local (your home directory)
```

**Solution 2:** Use sudo for system-wide
```bash
sudo bash install.sh --prefix=/opt/connecttunnel-manager
```

### "Command not found" after install

**Cause:** `~/.local/bin` not in PATH

**Solution:** Add to PATH
```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## Verifying Installation

### Check Installed Files

```bash
# Check binaries
ls -la ~/.local/bin/connecttunnel-*

# Check desktop files
ls -la ~/.local/share/applications/connecttunnel-*.desktop
```

### Test Launch

```bash
# Try launching control panel
connecttunnel-control-panel

# Or with full path
~/.local/bin/connecttunnel-control-panel
```

### Check Version

```bash
# View installed docs
ls ~/.local/share/doc/connecttunnel-manager/
```

---

## Post-Installation

### Add to Autostart (Optional)

If you didn't during installation:

```bash
# Copy desktop file to autostart
cp ~/.local/share/applications/connecttunnel-control-panel.desktop \
   ~/.config/autostart/
```

### Create Aliases (Optional)

```bash
# Add to ~/.bashrc
alias ct='connecttunnel-control-panel'
alias cth='connecttunnel-helper'
```

---

## Updating

To update to a new version:

```bash
# Uninstall old version
connecttunnel-manager-uninstall

# Install new version
cd /path/to/new/connecttunnel-manager
bash install.sh
```

---

## Uninstalling

### Via Uninstaller (Recommended)

```bash
connecttunnel-manager-uninstall
```

### Manual Removal

```bash
# Remove binaries
rm -f ~/.local/bin/connecttunnel-*

# Remove desktop files
rm -f ~/.local/share/applications/connecttunnel-*.desktop

# Remove autostart
rm -f ~/.config/autostart/connecttunnel-*.desktop

# Remove documentation
rm -rf ~/.local/share/doc/connecttunnel-manager
```

---

## Multiple Installations

You can have multiple copies of the package:

```bash
# Development version
~/dev/connecttunnel-manager/

# Production version
~/apps/connecttunnel-manager/

# Just don't run both installers simultaneously
```

Each installation is independent.

---

## Next Steps

After successful installation:

1. **Read Quick Start:** `cat QUICKSTART.md`
2. **Launch tool:** From app menu or terminal
3. **Connect to VPN:** Click "Connect Tunnel" button
4. **Read full docs:** `cat README.md`

---

## Support

- Installation issues: See troubleshooting above
- Usage questions: See USAGE_GUIDE.md
- General help: See README.md

---

**Installation is easy and safe!** Your ConnectTunnel installation is never modified - this package just adds management tools on top of it.
