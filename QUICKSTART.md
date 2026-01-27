# ConnectTunnel Manager - Quick Start

**Get up and running in 2 minutes!**

---

## ⚡ Express Installation

```bash
# Clone from GitHub
git clone https://github.com/mrmagicbg/connecttunnel-manager.git
cd connecttunnel-manager

# Run installer
bash install.sh
```

Follow the prompts:
1. **Dependencies check** - installer will verify Python and PyQt5
2. **Choose installation mode** - select option 2 (Control Panel) for most users
3. **Desktop shortcuts** - say Yes
4. **Done!**

---

## 🚀 Launch

### From Application Menu
Search for "ConnectTunnel" → Click "ConnectTunnel Control Panel"

### From Terminal
```bash
connecttunnel-control-panel
```

---

## 📱 Using Control Panel

1. **Window appears** on your taskbar
2. **Click "Connect Tunnel"** button
3. **Wait 2-3 seconds** - ConnectTunnel starts
4. **Status shows "🟢 Connected"**
5. **Use your VPN normally**
6. **Click "Disconnect"** when done

That's it! 🎉

---

## ❓ Problems?

### "ConnectTunnel not found"
```bash
# Check if installed
ls -la /usr/local/Aventail/startctui.sh
```

### "PyQt5 not found"
```bash
pip3 install PyQt5
# or
sudo apt-get install python3-pyqt5
```

### "Can't disconnect"
```bash
connecttunnel-helper --disconnect
# or force:
pkill -9 -f SnwlConnect
```

---

## 🎯 Daily Usage Tips

### Want keyboard shortcuts?
```bash
connecttunnel-helper --setup-shortcuts
# Follow the instructions
```

### Want autostart?
During installation, say "Yes" when asked about autostart.

---

## 📚 Learn More

- **Full docs**: [README.md](README.md)
- **Usage guide**: [docs/USAGE_GUIDE.md](docs/USAGE_GUIDE.md)
- **Version history**: [CHANGELOG.md](CHANGELOG.md)

---

## 🗑️ Uninstall

```bash
connecttunnel-manager-uninstall
```

---

**Questions?** Read the [README.md](README.md) or check the troubleshooting section.

**Enjoy your functional ConnectTunnel management! 🎊**
