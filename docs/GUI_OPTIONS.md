# ConnectTunnel Control Panel

## The Problem
ConnectTunnel's Java GUI lacks proper Linux desktop integration on KDE Plasma, making it difficult to manage connections efficiently. The default system tray icon often doesn't show context menus, and there's no easy way to disconnect without command-line access.

## The Solution

**ConnectTunnel Manager** provides a simple, reliable Control Panel interface for managing your ConnectTunnel VPN connection.

**Repository:** https://github.com/mrmagicbg/connecttunnel-manager

---

## ⭐ Control Panel Window

**Best for:** All users who want reliable, easy-to-use VPN management

### Features:
- ✅ **Always visible** on taskbar
- ✅ **Large, clear buttons** for Connect/Disconnect
- ✅ **Real-time status** monitoring (🟢 Connected / ⚫ Disconnected)
- ✅ **Show Window** button to bring ConnectTunnel to front
- ✅ **Modern interface** with PyQt5
- ✅ **Works perfectly** on KDE Plasma

### Installation:
```bash
# Clone from GitHub
git clone https://github.com/mrmagicbg/connecttunnel-manager.git
cd connecttunnel-manager

# Run installer
bash install.sh

# Launch
connecttunnel-control-panel
```

### Visual Layout:
```
┌────────────────────────────────────┐
│  ConnectTunnel Control Panel  ×    │
├────────────────────────────────────┤
│                                    │
│    ConnectTunnel Manager           │
│                                    │
│  ┌─ Connection Status ──────────┐ │
│  │                               │ │
│  │      🟢 Connected             │ │
│  │                               │ │
│  └───────────────────────────────┘ │
│                                    │
│  ┌─ Controls ────────────────────┐ │
│  │                               │ │
│  │  [ 🔌 Connect Tunnel ]        │ │
│  │                               │ │
│  │  [ 🔌 Disconnect ]            │ │
│  │                               │ │
│  │  [ 🪟 Show Tunnel Window ]    │ │
│  │                               │ │
│  └───────────────────────────────┘ │
│                                    │
│  [ ❌ Exit Manager ]               │
│                                    │
└────────────────────────────────────┘
```

### Make it Auto-Start:
```bash
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/connecttunnel-panel.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=ConnectTunnel Control Panel
Exec=connecttunnel-control-panel
Icon=network-vpn
X-KDE-autostart-after=panel
EOF
```

---

## 🔧 CLI Helper (Bonus)

For automation and scripting, the package also includes a command-line helper:

```bash
# Interactive menu
connecttunnel-helper

# Quick actions
connecttunnel-helper --connect
connecttunnel-helper --disconnect
connecttunnel-helper --toggle
connecttunnel-helper --status

# Setup keyboard shortcuts
connecttunnel-helper --setup-shortcuts
```

---

## 📋 Requirements

### Required:
- **ConnectTunnel** installed at `/usr/local/Aventail` (or custom path)
- **Linux** OS (tested on KDE Plasma)
- **Python 3.6+**

### For Control Panel:
- **PyQt5**
  ```bash
  pip3 install PyQt5
  # or
  sudo apt-get install python3-pyqt5
  ```

### Optional:
- **wmctrl** - For window management
  ```bash
  sudo apt-get install wmctrl
  ```

---

## 🐛 Troubleshooting

### PyQt5 won't install:
```bash
# Try with system package manager
sudo apt-get install python3-pyqt5
```

### "ConnectTunnel not found" error:
```bash
# Check installation path
ls -la /usr/local/Aventail/startctui.sh

# If different location, edit the control panel script:
nano ~/.local/bin/connecttunnel-control-panel
# Change: self.tunnel_path = Path("/usr/local/Aventail")
```

### Window won't show with "Show Window" button:
```bash
# Install wmctrl
sudo apt-get install wmctrl
```

### Control Panel won't start:
```bash
# Check Python and PyQt5
python3 -c "import PyQt5; print('PyQt5 OK')"

# Run from terminal to see errors
connecttunnel-control-panel
```

---

## 🎯 Why Control Panel?

**Simple and Reliable:**
- No complex configuration needed
- Works out of the box
- Large, accessible buttons
- Always visible status
- Perfect for daily VPN use

**Tested and Proven:**
- Optimized for KDE Plasma
- Handles disconnect issues (no freeze/timeout)
- Single-instance protection
- Clean shutdown with confirmation

**Easy to Use:**
- Click "Connect Tunnel" - done
- Click "Disconnect" - done
- See status at a glance
- No learning curve

---

## 📚 More Information

- **Full Documentation**: [README.md](../README.md)
- **Installation Guide**: [INSTALL.md](../INSTALL.md)
- **Quick Start**: [QUICKSTART.md](../QUICKSTART.md)
- **Troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Version History**: [CHANGELOG.md](../CHANGELOG.md)

---

## 🚀 Get Started

```bash
git clone https://github.com/mrmagicbg/connecttunnel-manager.git
cd connecttunnel-manager
bash install.sh
```

**Enjoy hassle-free ConnectTunnel management! 🎉**

