# ConnectTunnel Manager

**Professional GUI management tools for SonicWall/Aventail ConnectTunnel on Linux**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)
[![Python](https://img.shields.io/badge/Python-3.6%2B-blue.svg)](https://www.python.org/)

Version: 1.0.2  
License: MIT  
Platform: Linux (optimized for KDE Plasma)  
Repository: https://github.com/mrmagicbg/connecttunnel-manager

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

If ConnectTunnel is installed in a non-standard location, edit the scripts:

```bash
# Edit in each bin/ script
nano ~/.local/bin/connecttunnel-control-panel

tunnel_path = Path("/usr/local/Aventail")
# To your path:
tunnel_path = Path("/opt/Aventail")
```

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
