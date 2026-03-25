# ConnectTunnel Manager

**Complete installer and GUI management tools for SonicWall/Aventail ConnectTunnel on Linux**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)
[![Python](https://img.shields.io/badge/Python-3.6%2B-blue.svg)](https://www.python.org/)

Version: 2.0.0  
License: MIT  
Platform: Linux (Ubuntu 24.04+, GNOME and KDE Plasma)  
Repository: https://github.com/mrmagicbg/connecttunnel-manager

> **📦 All-in-one Installer:**  
> Clone from GitHub and run `bash install.sh`.  
> The installer handles everything: Java 11, ConnectTunnel itself, start-script
> patching, and the optional Manager GUI — pick the right mode for your desktop.

---

## 📋 Overview

ConnectTunnel Manager provides a unified installer and enhanced GUI tools for the
SonicWall/Aventail ConnectTunnel VPN client on Linux.

The bundled installer addresses two core problems:

1. **Java version mismatch** — `SnwlConnect.jar` requires Java 11 exactly.  
   Ubuntu 24.04 ships with Java 21 by default, which breaks the client.  
   The installer installs `openjdk-11-jre` and permanently pins the start scripts
   to use it, so the VPN works reliably on every launch.

2. **Missing tray context menu on KDE Plasma** — The Java-based system tray icon
   provides no Disconnect or Exit option under KDE. The Manager control panel
   fills this gap with large, visible buttons and live connection status.

---

## 🎯 Installation Modes

The single `install.sh` script supports three modes, selected interactively:

| # | Mode | What it installs | Manager |
|---|------|-----------------|---------|
| 1 | **GNOME** | Java 11 + ConnectTunnel + Java 11 patch | Optional |
| 2 | **KDE** | Java 11 + ConnectTunnel + Java 11 patch | Mandatory |
| 3 | **Uninstall** | — | Removes tools and/or VPN client |

### Why Java 11?

`SnwlConnect.jar` (version 12.50.00212) is compiled for Java 11.  
Running it with Java 8 or Java 21 silently fails or crashes.  
Ubuntu 24.04 does not ship Java 11 by default, but it is available in the
official repositories as `openjdk-11-jre`.

The installer installs `openjdk-11-jre` and injects the following block at the
top of both `/usr/local/Aventail/startctui.sh` and `/usr/local/Aventail/startct.sh`:

```bash
# --- Java 11 pinned by ConnectTunnel installer ---
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"
# -------------------------------------------------
```

This ensures the Java version check inside the scripts and the final
`java -jar SnwlConnect.jar` call both use Java 11, regardless of what `java`
defaults to system-wide.

### Why is the Manager mandatory on KDE?

KDE Plasma's system tray does not render the Java tray icon's right-click context
menu. Without it there is no visible way to Disconnect or Exit ConnectTunnel.  
The Control Panel provides those actions in a regular window that stays on the
taskbar.

On GNOME the Java tray icon is more functional, so the Manager is offered as an
optional convenience.

---

## 📦 Installation

### Prerequisites

- Linux (Ubuntu 24.04 recommended, Debian-based for auto-dependency install)
- `sudo` access (required to install Java 11 and ConnectTunnel)
- The bundled ConnectTunnel package is included in `install/ConnectTunnel_Linux64-12.50.00212/`

### Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/mrmagicbg/connecttunnel-manager.git
cd connecttunnel-manager

# 2. Run the installer
bash install.sh
```

The installer prompts you to select a mode:

```
Choose installation mode:  (detected: GNOME)

  1) GNOME  — Install Java 11 + ConnectTunnel, patch for Java 11.
              Manager (Control Panel) is optional.

  2) KDE    — Same as GNOME but Manager is mandatory.
              (Native Java tray lacks a Disconnect button on KDE.)

  3) Uninstall — Remove Manager tools and/or ConnectTunnel.

  4) Exit

Select [1-4]:
```

### Mode 1 — GNOME

```
Select [1-4]: 1
```

Steps performed:
1. Installs `openjdk-11-jre` (skips if already present)
2. Runs the bundled ConnectTunnel installer (prompts to reinstall if already present)
3. Patches `startctui.sh` and `startct.sh` with the Java 11 export block
4. Asks: *"Also install the ConnectTunnel Manager?"* → answer y/N
5. If Manager requested, asks about autostart at login

### Mode 2 — KDE

```
Select [1-4]: 2
```

Same steps as GNOME, but the Manager (Control Panel + CLI Helper) is always
installed. You will still be asked whether to autostart the Control Panel at login.

### Mode 3 — Uninstall

```
Select [1-4]: 3
```

1. Removes all ConnectTunnel Manager tools from `~/.local`
2. Asks: *"Also remove the ConnectTunnel VPN client itself?"*  
   - If yes: calls `sudo /usr/local/Aventail/uninstall.sh`
   - If no: the VPN client is left intact

### Non-interactive (scripted) usage

```bash
# GNOME mode directly
bash install.sh --gnome

# KDE mode directly
bash install.sh --kde

# Uninstall directly
bash install.sh --uninstall

# Show help
bash install.sh --help
```

### Custom Java 11 path

If `openjdk-11-jre` installs to a non-standard location, override before running:

```bash
JAVA11_HOME=/path/to/java11 bash install.sh
```

---

## 🔧 Requirements

| Requirement | Purpose | Auto-installed? |
|-------------|---------|----------------|
| `openjdk-11-jre` | Run `SnwlConnect.jar` | ✅ Yes (apt) |
| `python3` | Control Panel | ✅ Yes (apt) |
| `python3-pyqt5` | Control Panel GUI | ✅ Yes (apt) |
| `wmctrl` | Bring VPN window to front | ✅ Yes (apt) |
| `kdialog` / `zenity` | CLI Helper dialogs | Usually pre-installed |

---

## 🚀 Usage after installation

### Launching ConnectTunnel (GNOME, no Manager)

```bash
/usr/local/Aventail/startctui.sh
```

Java 11 is pinned automatically by the patched start script.

### Launching the Manager (GNOME with Manager, or KDE)

```bash
# GUI Control Panel (stays on taskbar)
connecttunnel-control-panel

# CLI Helper
connecttunnel-helper --menu
```

Or find **ConnectTunnel Control Panel** in your application launcher.

### Control Panel Features

1. **Connect** — Launches the ConnectTunnel UI
2. **Disconnect** — Terminates the VPN session (with confirmation)
3. **Show Window** — Brings the ConnectTunnel window to front
4. **Status** — Live connection indicator (🟢 Connected / ⚫ Disconnected)

### CLI Helper Commands

```bash
connecttunnel-helper                  # Interactive menu
connecttunnel-helper --connect        # Start tunnel
connecttunnel-helper --disconnect     # Stop tunnel
connecttunnel-helper --toggle         # Toggle state
connecttunnel-helper --status         # Print status
connecttunnel-helper --show-window    # Bring window to front
```

---

## ⚙️ Configuration

### Custom ConnectTunnel installation path

Both tools respect the `CONNECTTUNNEL_PATH` environment variable:

```bash
# One-off
CONNECTTUNNEL_PATH=/opt/Aventail connecttunnel-control-panel

# Persistent — add to ~/.bashrc or ~/.zshrc
export CONNECTTUNNEL_PATH=/opt/Aventail
```

### Autostart

To add the Control Panel to desktop autostart after installation:

```bash
mkdir -p ~/.config/autostart
cp ~/.local/share/applications/connecttunnel-control-panel.desktop \
   ~/.config/autostart/
```

---

## 📚 Project structure

```
connecttunnel-manager/
├── install.sh                          # Unified installer (entry point)
├── README.md                           # This file
├── CHANGELOG.md                        # Version history
├── LICENSE                             # MIT License
├── install/
│   └── ConnectTunnel_Linux64-12.50.00212/
│       ├── install.sh                  # Vendor installer (called by our installer)
│       ├── ConnectTunnel-Linux64-12.50.00212.tar.bz2
│       └── version
├── bin/
│   ├── connecttunnel-control-panel     # PyQt5 GUI control panel
│   └── connecttunnel-helper            # Bash CLI helper
├── share/
│   └── applications/
│       └── connecttunnel-control-panel.desktop
└── docs/
    ├── USAGE_GUIDE.md
    ├── GUI_OPTIONS.md
    ├── TROUBLESHOOTING.md
    └── DISCONNECT_FIX.md
```

### Installed files (Manager)

```
~/.local/bin/
├── connecttunnel-control-panel
├── connecttunnel-helper
└── connecttunnel-manager-uninstall

~/.local/share/applications/
└── connecttunnel-control-panel.desktop

~/.local/share/doc/connecttunnel-manager/
├── README.md
├── CHANGELOG.md
└── docs/
```

---

## 🐛 Troubleshooting

### ConnectTunnel UI doesn't open

**Cause:** Wrong Java version in PATH.  
**Verify the patch was applied:**
```bash
head -8 /usr/local/Aventail/startctui.sh
```
Expected output includes `export JAVA_HOME=...` lines.

**Run manually to test:**
```bash
/usr/lib/jvm/java-11-openjdk-amd64/bin/java -jar /usr/local/Aventail/ui/SnwlConnect.jar
```

**Re-apply the patch:**
```bash
bash install.sh --gnome   # or --kde
# When asked about reinstalling CT, choose N (skip)
# The patch will be re-applied
```

### "openjdk-11-jre" not found

On non-Debian systems, install Java 11 manually, then set `JAVA11_HOME`:
```bash
# Fedora/RHEL
sudo dnf install java-11-openjdk

# Arch
sudo pacman -S jre11-openjdk

# Then re-run with custom path
JAVA11_HOME=/usr/lib/jvm/java-11-openjdk bash install.sh
```

### PyQt5 not found

```bash
# Ubuntu/Debian
sudo apt-get install python3-pyqt5

# Fedora
sudo dnf install python3-qt5

# Via pip
pip3 install --user PyQt5
```

### Show Window doesn't work

```bash
sudo apt-get install wmctrl
# or
sudo apt-get install xdotool
```

### Disconnect doesn't work

```bash
# Check if ConnectTunnel is running
pgrep -f SnwlConnect

# Force terminate
pkill -9 -f SnwlConnect
```

### Scripts not in PATH

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 🔄 Updating

```bash
cd connecttunnel-manager
git pull
bash install.sh --gnome   # or --kde
```

When prompted about reinstalling ConnectTunnel, choose **N** to skip the vendor
installer and only re-apply the Java 11 patch and reinstall the Manager tools.

---

## 🗑️ Uninstallation

### Via installer (recommended)

```bash
bash install.sh --uninstall
# — or —
bash install.sh   # then choose option 3
```

Choose whether to also remove the ConnectTunnel VPN client when prompted.

### Via uninstaller script (Manager only)

```bash
# Remove Manager tools only
connecttunnel-manager-uninstall

# Remove Manager tools AND ConnectTunnel VPN client
connecttunnel-manager-uninstall --vpn
```

### Manual removal

```bash
# Manager tools
rm -f ~/.local/bin/connecttunnel-*
rm -f ~/.local/share/applications/connecttunnel-*.desktop
rm -f ~/.config/autostart/connecttunnel-*.desktop
rm -rf ~/.local/share/doc/connecttunnel-manager

# ConnectTunnel VPN client (requires sudo)
sudo /usr/local/Aventail/uninstall.sh
```

---

## 📊 Which mode do I need?

| I use... | Recommended mode |
|----------|-----------------|
| GNOME, just need VPN working | Mode 1, decline Manager |
| GNOME, want GUI control panel | Mode 1, accept Manager |
| KDE Plasma | Mode 2 (Manager mandatory) |
| Scripting / headless | Mode 1, use `connecttunnel-helper` |

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

## 📝 License

MIT License — see [LICENSE](LICENSE) for details.

---

## 🏆 Credits

**ConnectTunnel Manager** is an independent project created to improve the Linux
user experience for SonicWall/Aventail ConnectTunnel.

Not affiliated with or endorsed by SonicWall, Inc.

> **📦 Easy Install:** Clone from GitHub and run the installer.  
> It installs on top of your existing ConnectTunnel installation and adds GUI management functionality.

---

## 📋 Overview

ConnectTunnel Manager provides enhanced GUI tools for managing ConnectTunnel VPN connections on Linux systems. It solves the common issue where ConnectTunnel's Java-based system tray icon lacks a functional context menu on KDE Plasma and other desktop environments, making it difficult to disconnect or exit the application.

**What This Does:** Installs **on top of** your existing ConnectTunnel installation to add GUI management tools. Your ConnectTunnel installation remains unchanged.

### The Problem

- ❌ No connection status visibility

### The Solution

- ✅ **Control Panel**: Desktop window with large buttons and status display (Recommended)

- ✅ **CLI Helper**: Command-line helper for scripting/automation
---

## 🎯 Features

### 1. Control Panel (Recommended)
- **Always visible** window on taskbar
- **Large, clear buttons** for Connect/Disconnect
- **Real-time status** monitoring (🟢 Connected / ⚫ Disconnected)
- **Modern interface** with clean design
- **Process management** - automatic monitoring
- **Window management** - bring ConnectTunnel to front

### 2. CLI Helper
- **Command-line interface** for scripting
- **Menu system** with kdialog/zenity support
- **Quick actions**: --connect, --disconnect, --toggle
- **Status checking** and window management

---

## 📦 Installation

### Quick Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/mrmagicbg/connecttunnel-manager.git
cd connecttunnel-manager

# Run the installer
bash install.sh
```

The installer will:
1. Check for ConnectTunnel installation
2. Verify dependencies (Python3, PyQt5, etc.)
3. Offer to install missing packages
4. Let you choose which tools to install
5. Create desktop shortcuts
6. Optionally set up autostart

### Installation Modes

#### Full Installation (All Tools)
```bash
bash install.sh --auto
```

#### Interactive (Choose Components)
```bash
bash install.sh
```

#### Custom Prefix
```bash
bash install.sh --prefix=/opt/connecttunnel-manager
```

#### Skip Dependency Check
```bash
bash install.sh --no-deps
```

---

## 🔧 Requirements

- **ConnectTunnel** installed at `/usr/local/Aventail` (or custom path)
- **Linux** OS (Ubuntu, Fedora, Arch, etc.)
- **Python 3.6+** (for GUI tools)
- **PyQt5** - For Control Panel
  ```bash
  pip3 install PyQt5
  # or
   sudo apt-get install python3-pyqt5
  ```

### Optional
- **wmctrl** - For window management
  ```bash
  sudo apt-get install wmctrl
  ```
- **kdialog** or **zenity** - For dialog boxes (usually pre-installed)
- **devilspie2** - Alternative window manager
  ```bash
  sudo apt-get install devilspie2
  ```

---

## 🚀 Usage

### After Installation

The tools will be available in your application menu and can be launched via:

```bash
# Control Panel (stays on taskbar)
connecttunnel-control-panel

# CLI Helper (for scripts)
connecttunnel-helper --menu
```

### Control Panel Features

1. **Connect**: Click the large "Connect Tunnel" button
2. **Disconnect**: Click "Disconnect" (with confirmation)
3. **Show Window**: Bring ConnectTunnel window to front
4. **Status**: Real-time connection status display
5. **Exit**: Close the manager (with disconnect option)

### CLI Helper Commands

```bash
# Show interactive menu
connecttunnel-helper

# Connect
connecttunnel-helper --connect

# Disconnect
connecttunnel-helper --disconnect

# Toggle connect/disconnect
connecttunnel-helper --toggle

# Check status
connecttunnel-helper --status

# Show window
connecttunnel-helper --show-window

# Setup keyboard shortcuts (instructions)
connecttunnel-helper --setup-shortcuts
```

---

## ⚙️ Configuration

### Custom ConnectTunnel Path

If ConnectTunnel is installed in a non-standard location, set the
`CONNECTTUNNEL_PATH` environment variable — no file editing required:

```bash
# One-off launch
CONNECTTUNNEL_PATH=/opt/Aventail connecttunnel-control-panel

# Persistent — add to ~/.bashrc or ~/.zshrc
export CONNECTTUNNEL_PATH=/opt/Aventail
```

You can also pass it to the installer so the variable propagates during install:

```bash
CONNECTTUNNEL_PATH=/opt/Aventail bash install.sh
```

Alternatively, edit the scripts directly after installation:

### Autostart Setup

To start a tool automatically on login:

#### Via Installer
Run `install.sh` and select "Yes" when asked about autostart.

#### Manual Setup
```bash
mkdir -p ~/.config/autostart
cp ~/.local/share/applications/connecttunnel-control-panel.desktop ~/.config/autostart/
```

### KDE Plasma Integration

#### Window Rules (Optional)
Create rules to control ConnectTunnel window behavior:
1. System Settings → Window Management → Window Rules
2. Add new rule for "SnwlConnect"
3. Configure skip taskbar, position, etc.

---

## 📚 Documentation

### Directory Structure

```
connecttunnel-manager/
├── install.sh              # Main installer
├── README.md               # This file
├── CHANGELOG.md            # Version history
├── LICENSE                 # MIT License
├── bin/                    # Executable scripts
│   ├── connecttunnel-control-panel
│   └── connecttunnel-helper
├── share/
│   ├── applications/       # Desktop entry files
│   │   └── connecttunnel-control-panel.desktop
│   └── icons/              # Icons (if any)
└── docs/                   # Additional documentation
    ├── USAGE_GUIDE.md
    ├── GUI_OPTIONS.md
    ├── TROUBLESHOOTING.md
    └── DISCONNECT_FIX.md
```

### Installed Files

After installation:
```
~/.local/bin/
├── connecttunnel-control-panel
├── connecttunnel-helper
└── connecttunnel-manager-uninstall

~/.local/share/applications/
└── connecttunnel-control-panel.desktop

~/.local/share/doc/connecttunnel-manager/
├── README.md
├── CHANGELOG.md
└── docs/
```

---

## 🐛 Troubleshooting

### Issue: "ConnectTunnel not found"
**Solution:** Verify ConnectTunnel installation:
```bash
ls -la /usr/local/Aventail/startctui.sh
```

If in a different location, update the scripts or reinstall with:
```bash
CONNECTTUNNEL_PATH=/your/path bash install.sh
```

### Issue: "PyQt5 not found"

**Solution:** Install PyQt5:
```bash
# Via pip3
pip3 install PyQt5

# Via package manager (Ubuntu/Debian)
sudo apt-get install python3-pyqt5

# Via package manager (Fedora)
sudo dnf install python3-qt5
```

### Issue: "Show Window" doesn't work

**Solution:** Install window management tools:
```bash
sudo apt-get install wmctrl
# or
sudo apt-get install xdotool
```

### Issue: Disconnect doesn't work

**Solution:** 
   ```bash
   pgrep -f SnwlConnect
   ```
2. Try force disconnect:
   ```bash
   pkill -9 -f SnwlConnect
   ```

### Issue: Script won't run

**Solution:** Ensure scripts are executable:
```bash
chmod +x ~/.local/bin/connecttunnel-*
```
## 🔄 Updating
To update to a new version:

1. **Download** the new version
2. **Run uninstaller**:
   ```bash
   connecttunnel-manager-uninstall
   ```
3. **Install new version**:
   ```bash
   bash install.sh
   ```
Or simply run the installer again to overwrite files.

---

## 🗑️ Uninstallation
### Via Uninstaller (Recommended)

```bash
connecttunnel-manager-uninstall
```

### Manual Removal

```bash
rm -f ~/.local/bin/connecttunnel-*

# Remove desktop files
rm -f ~/.local/share/applications/connecttunnel-*.desktop

# Remove autostart
rm -f ~/.config/autostart/connecttunnel-*.desktop
# Remove documentation
rm -rf ~/.local/share/doc/connecttunnel-manager
```

---

## 📊 Comparison: Which Tool to Use?
| Feature | Control Panel | CLI Helper |
|---------|--------------|------------|
| **Visibility** | Always visible window | Terminal only |
| **UI Complexity** | Simple, clear | Menu/flags |
| **Python Required** | Yes (PyQt5) | No |
| **Dependencies** | Moderate (PyQt5) | Minimal (bash + wmctrl optional) |
| **Best For** | Daily use, clarity | Automation and scripts |
| **Autostart Friendly** | Yes | Via user shortcuts |
| **KDE Integration** | Excellent | N/A |

### Recommendations

- **Most Users**: Start with **Control Panel**
- **Scripting**: Use **CLI Helper**

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository


## 📝 License

MIT License - see LICENSE file for details.

---

## 📧 Support

For issues, questions, or suggestions:

1. Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
2. Review [CHANGELOG.md](CHANGELOG.md) for known issues
3. [Create an issue](https://github.com/mrmagicbg/connecttunnel-manager/issues) on GitHub

---

## 🏆 Credits

**ConnectTunnel Manager** is an independent project created to improve the Linux user experience for SonicWall/Aventail ConnectTunnel.

Not affiliated with or endorsed by SonicWall, Inc.

---

## 📅 Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

**Current Version: 1.0.0** (January 2026)

---

## 🎯 Quick Start Guide

### For First-Time Users

1. **Clone & Install**:
   ```bash
   git clone https://github.com/mrmagicbg/connecttunnel-manager.git
   cd connecttunnel-manager
   bash install.sh
   ```

2. **Choose** Control Panel when prompted

3. **Launch** from application menu or:
   ```bash
   connecttunnel-control-panel
   ```

4. **Click** "Connect Tunnel" button

5. **Enjoy** hassle-free ConnectTunnel management!

### Having Issues?

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for solutions to common problems:
- "Another instance of this Application is running" error
- Disconnect timeout issues
- Control Panel not responding
- And more...

---

*Made with ❤️ for Linux users frustrated by non-functional tray icons*
