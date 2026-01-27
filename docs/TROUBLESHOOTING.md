# Troubleshooting Guide

Common issues and solutions for ConnectTunnel Manager.

---

## "Another instance of this Application is running"

### Symptom
Error dialog appears when clicking "Connect Tunnel" or "Disconnect" button:
```
Error
Another instance of this Application is running. 
Please close the application and then retry.
```

### Cause
This error comes from **ConnectTunnel itself** (the Java VPN client), not our manager. ConnectTunnel only allows ONE instance to run at a time.

### Why It Happens
1. **You're already connected** - The tunnel is running in background (when clicking Connect)
2. **The startct.sh script launches Java** - Which detects existing instance (FIXED in v1.0.1)
3. **Clicking Connect button twice** - Double-click launched two instances

### Solution

**Version 1.0.1+ automatically fixes this!** Disconnect now uses direct `pkill` commands instead of the `startct.sh stop` script that was causing the Java dialog.

If you still see this error:

#### Option 1: Check if Already Connected (Easiest)
1. Look at the status in Control Panel - does it say "🟢 Connected"?
2. If yes, you don't need to connect! You're already connected.
3. Use "Show Tunnel Window" button instead

#### Option 2: Kill Existing Process
```bash
# Check if ConnectTunnel is running
pgrep -f SnwlConnect

# If yes, kill it
pkill -9 -f SnwlConnect
pkill -9 -f startctui

# Wait 2 seconds, then try connecting again
```

#### Option 3: Use CLI Helper
```bash
connecttunnel-helper --status  # Check status
connecttunnel-helper --disconnect  # Disconnect if needed
connecttunnel-helper --connect  # Connect fresh
```

#### Option 4: Restart Control Panel
1. Close Control Panel completely (click X or Exit Manager)
2. Wait 5 seconds
3. Launch again: `connecttunnel-control-panel`
4. Check status before clicking Connect

### Prevention
**Version 1.0.1 includes fixes** to prevent this:
- Status is checked RIGHT BEFORE attempting connection
- Connect button disabled during connection
- Better "already running" detection
- **Disconnect uses direct pkill (no Java dialog)**
- **Disconnect completes in ~2 seconds (no freeze)**

---

## "ConnectTunnel Control Panel is already running"

### Symptom
Error when trying to launch a second Control Panel:
```
Already Running
ConnectTunnel Control Panel is already running.
Please check your taskbar.
```

### Cause
The Control Panel enforces single-instance to prevent confusion with multiple windows showing different states.

### Solution
1. **Check taskbar** - Is the Control Panel already there?
2. **If hung, kill it:**
   ```bash
   pkill -f connecttunnel-control-panel
   # Wait 2 seconds
   connecttunnel-control-panel  # Launch fresh
   ```

---

## Disconnect Timeout Error

### Symptom
Error when disconnecting:
```
Disconnect Timeout
Disconnect command timed out after 30 seconds.
Attempting force kill...
```

### Status: FIXED in v1.0.1

**This issue is now resolved.** Disconnect no longer uses the slow `startct.sh stop` script. Instead:
- Uses direct `pkill` commands
- Completes in ~2 seconds
- No timeout errors
- No UI freeze

### How It Works Now
1. Sends graceful SIGTERM to ConnectTunnel process
2. Waits 1 second for clean shutdown
3. If still running, force kills with SIGKILL
4. Verifies disconnection
5. Updates status

**Total time: ~2-3 seconds** instead of 30+ seconds!

---

## Control Panel Not Responding

### Symptom
Window shows "(Not Responding)" in title bar, buttons don't work.

### Cause
1. Disconnect/connect operation hung
2. Python process frozen
3. System resource issues

### Solution
```bash
# Kill and restart
pkill -9 -f connecttunnel-control-panel

# Remove lock file
rm -f /tmp/connecttunnel-control-panel.lock

# Launch fresh
connecttunnel-control-panel
```

---

## Status Shows Wrong State

### Symptom
- Shows "Connected" but VPN isn't working
- Shows "Disconnected" but VPN is active

### Cause
Status check looks for `SnwlConnect.jar` process. Process might be:
- Running but VPN disconnected
- Crashed but status not updated

### Solution
```bash
# Check actual process
ps aux | grep SnwlConnect

# Check actual VPN status
ip route | grep -i aventail  # Look for VPN routes

# Force refresh by disconnecting/reconnecting
connecttunnel-helper --disconnect
sleep 3
connecttunnel-helper --connect
```

---

## Can't Find ConnectTunnel Installation

### Symptom
```
Error
ConnectTunnel not found at /usr/local/Aventail
```

### Cause
ConnectTunnel installed in different location.

### Solution

#### Find Installation
```bash
# Search for ConnectTunnel
find /opt /usr -name "startctui.sh" 2>/dev/null
```

#### Update Manager
Edit the installed binaries to point to correct location:
```bash
# Edit control panel
nano ~/.local/bin/connecttunnel-control-panel

# Find this line (around line 38):
self.tunnel_path = Path("/usr/local/Aventail")

# Change to your path:
self.tunnel_path = Path("/opt/Aventail")  # or wherever you found it
```

Do same for:
- `~/.local/bin/connecttunnel-helper`

---

## PyQt5 Errors

### Symptom
```
ImportError: No module named 'PyQt5'
```

### Solution
```bash
# Install PyQt5
pip3 install PyQt5

# Or with apt (Ubuntu/Debian)
sudo apt install python3-pyqt5

# Verify
python3 -c "import PyQt5; print('OK')"
```

---

## Buttons Grayed Out

### Symptom
All control buttons are disabled/grayed.

### Cause
Manager detected an issue and disabled controls to prevent errors.

### Solution
1. **Check error message** in the info panel at bottom
2. **Restart manager:**
   ```bash
   pkill -f connecttunnel-control-panel
   connecttunnel-control-panel
   ```
3. **Check ConnectTunnel installation:**
   ```bash
   ls -la /usr/local/Aventail/
   ```

---

## "Show Tunnel Window" Does Nothing

### Symptom
Clicking "Show Tunnel Window" button doesn't bring window to foreground.

### Cause
1. Window management tools not installed
2. Wayland limitations
3. ConnectTunnel minimized in unusual way

### Solution

#### Install wmctrl
```bash
sudo apt install wmctrl  # Ubuntu/Debian
sudo dnf install wmctrl  # Fedora
```

#### Manual Method
```bash
# Find window ID
xdotool search --name "Connect Tunnel"

# Raise window (replace XXXXX with ID from above)
xdotool windowactivate XXXXX
```

#### Alternative
Use Alt+Tab to find ConnectTunnel window manually.

---

## Installation Issues

### Can't Run install.sh

**Error:** `bash: install.sh: Permission denied`

**Solution:**
```bash
chmod +x install.sh
bash install.sh
```

### Installation to Different Location

**Want to install somewhere other than `~/.local/`?**

```bash
bash install.sh --prefix=/opt/ct-manager
bash install.sh --prefix=~/Applications
```

---

## Uninstallation

### Clean Removal
```bash
# Use uninstaller
connecttunnel-manager-uninstall

# Or manually:
rm -rf ~/.local/bin/connecttunnel-*
rm -rf ~/.local/share/applications/connecttunnel-*.desktop
rm -rf ~/.local/share/doc/connecttunnel-manager
rm -f /tmp/connecttunnel-control-panel.lock
```

---

## Getting Help

### Before Asking

1. **Check version**: `connecttunnel-helper --version` (if implemented)
2. **Read logs**: Run tools from terminal to see error messages
3. **Check status**: `connecttunnel-helper --status`
4. **Try clean restart**:
   ```bash
   pkill -9 -f SnwlConnect
   pkill -9 -f connecttunnel
   rm -f /tmp/connecttunnel-*.lock
   connecttunnel-control-panel
   ```

### Information to Provide

- Linux distribution and version
- ConnectTunnel version/installation path
- Error messages (exact text or screenshot)
- Output of: `pgrep -a SnwlConnect`
- Manager version (check CHANGELOG.md)

---

## Quick Fixes Summary

| Problem | Quick Fix |
|---------|-----------|
| "Another instance running" | Check status first - you might already be connected |
| Disconnect timeout | Wait for auto force-kill (v1.0.1+) |
| Control Panel frozen | `pkill -f connecttunnel-control-panel` + relaunch |
| Wrong status | `connecttunnel-helper --disconnect` then reconnect |
| Can't install | `chmod +x install.sh && bash install.sh` |
| PyQt5 missing | `pip3 install PyQt5` |

---

*Last updated: January 27, 2026 - Version 1.0.1*
