# ConnectTunnel Manager - Usage Guide

Complete guide to using ConnectTunnel Manager tools.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Control Panel](#control-panel)
3. [System Tray](#system-tray)
4. [Taskbar Launcher](#taskbar-launcher)
5. [CLI Helper](#cli-helper)
6. [Advanced Usage](#advanced-usage)
7. [Tips & Tricks](#tips--tricks)

---

## Getting Started

### First Launch

After installation, launch your preferred tool:

**From Application Menu:**
- Search for "ConnectTunnel" in your application launcher
- Select the tool you want to use

**From Command Line:**
```bash
# Control Panel
connecttunnel-control-panel

# System Tray
connecttunnel-tray

# CLI Helper
connecttunnel-helper --menu
```

### Choosing the Right Tool

| Use Case | Recommended Tool |
|----------|-----------------|
| Daily desktop use | Control Panel |
| Minimal interface | System Tray |
| No Python available | Taskbar Launcher |
| Scripting/automation | CLI Helper |
| Always visible status | Control Panel |

---

## Control Panel

### Overview

The Control Panel is a desktop window that stays on your taskbar, providing easy access to all ConnectTunnel functions.

### Features

#### Connection Management
1. **Connect Button**: Click to start ConnectTunnel
   - Starts the VPN connection
   - Shows progress message
   - Automatically updates status

2. **Disconnect Button**: Click to stop ConnectTunnel
   - Shows confirmation dialog
   - Gracefully stops the connection
   - Cleans up processes

#### Status Display
- **🟢 Connected**: VPN is active (green indicator)
- **⚫ Disconnected**: VPN is inactive (red indicator)
- **Status Bar**: Shows current state and process ID

#### Window Management
- **Show Tunnel Window**: Brings ConnectTunnel UI to foreground
  - Useful when window is hidden or minimized
  - Uses wmctrl or xdotool
  - Keyboard shortcut: Click button

#### Information Panel
- Real-time status updates
- Connection information
- Error messages (if any)
- Usage tips

### Workflow Example

```
1. Launch Control Panel
   → Window appears on taskbar

2. Click "Connect Tunnel"
   → ConnectTunnel starts
   → Status shows "🟢 Connected"
   → Connect button grays out
   → Disconnect button activates

3. Use VPN normally
   → Status automatically monitored
   → Process ID displayed

4. Click "Disconnect" when done
   → Confirmation dialog appears
   → Click "Yes" to disconnect
   → Status shows "⚫ Disconnected"

5. Close Control Panel or leave it running
   → Window stays on taskbar for quick access
```

### Keyboard Navigation

- **Tab**: Navigate between buttons
- **Enter**: Activate focused button
- **Escape**: Cancel dialogs
- **Alt+F4**: Close window (prompts if connected)

---

## System Tray

### Overview

Minimal system tray icon with full functionality via context menu.

### Features

#### Tray Icon
- **Icon**: Network VPN icon (uses system theme)
- **Tooltip**: Shows current connection status
- **Behavior**: Stays in system tray

#### Context Menu (Right-Click)

```
⚫ Disconnected                    # Status indicator
────────────────────────────
🔌 Connect Tunnel                  # Start VPN
🔌 Disconnect                      # Stop VPN
────────────────────────────
🪟 Show Window                     # Bring CT to front
────────────────────────────
ℹ️ About                           # About dialog
────────────────────────────
❌ Exit Manager                    # Close tray app
```

#### Desktop Notifications

Automatic notifications for:
- ✅ Connection successful
- ❌ Connection failed
- ⚠️ Disconnected
- ℹ️ Status changes

#### Double-Click Behavior

- **If disconnected**: Starts connection
- **If connected**: Shows ConnectTunnel window

### Workflow Example

```
1. Launch System Tray
   → Icon appears in system tray
   → Notification: "Running in system tray"

2. Right-click tray icon
   → Menu appears
   → Select "Connect Tunnel"
   → Notification: "Starting connection..."

3. Wait for connection
   → Notification: "Connected successfully"
   → Tray tooltip updates to "Connected"
   → Menu updates status to "🟢 Connected"

4. Double-click icon
   → ConnectTunnel window comes to front

5. Right-click → Disconnect
   → Confirmation dialog
   → Select "Yes"
   → Notification: "Disconnected"

6. Right-click → Exit Manager
   → Optionally disconnect
   → Tray icon disappears
```

### Auto-Start Setup

To have System Tray start automatically:

```bash
# Already set up during installation if selected
# Or manually:
cp ~/.local/share/applications/connecttunnel-tray.desktop \
   ~/.config/autostart/
```

---

## Taskbar Launcher

### Overview

Keeps ConnectTunnel window visible on the taskbar instead of hiding in the system tray.

### How It Works

1. Launches ConnectTunnel normally
2. Prevents window from being hidden
3. Uses window management tools (wmctrl or devilspie2)
4. Original ConnectTunnel UI remains accessible

### Usage

```bash
# Launch ConnectTunnel with taskbar visibility
connecttunnel-taskbar-launcher

# Or with specific method
connecttunnel-taskbar-launcher --wmctrl
connecttunnel-taskbar-launcher --devilspie
```

### Requirements

**One of:**
- wmctrl (recommended)
- devilspie2
- None (uses Java hints as fallback)

**Install:**
```bash
sudo apt-get install wmctrl
# or
sudo apt-get install devilspie2
```

### Workflow Example

```
1. Run launcher
   → ConnectTunnel starts
   → Window appears on taskbar
   → Window stays visible (doesn't hide in tray)

2. Use ConnectTunnel normally
   → Original UI and functions
   → Always accessible from taskbar

3. Disconnect from CT UI
   → Or close window normally
   → Process terminates
```

### Desktop Shortcut

Create a launcher on your desktop:

```bash
cp ~/.local/share/applications/connecttunnel-taskbar.desktop \
   ~/Desktop/
chmod +x ~/Desktop/connecttunnel-taskbar.desktop
```

---

## CLI Helper

### Overview

Command-line tool for scripting and quick actions.

### Commands

#### Interactive Menu
```bash
connecttunnel-helper
# or
connecttunnel-helper --menu
```

Shows graphical menu (kdialog or zenity) with options:
- Connect
- Disconnect  
- Show Window
- Status

#### Connect
```bash
connecttunnel-helper --connect
```
Starts ConnectTunnel VPN connection.

#### Disconnect
```bash
connecttunnel-helper --disconnect
```
Stops ConnectTunnel VPN connection.

#### Toggle
```bash
connecttunnel-helper --toggle
```
If disconnected → connect  
If connected → disconnect

#### Status Check
```bash
connecttunnel-helper --status
```
Displays current connection status:
- Exit code 0: Connected
- Exit code 1: Disconnected

#### Show Window
```bash
connecttunnel-helper --show-window
```
Brings ConnectTunnel window to foreground.

### Scripting Examples

#### Auto-Connect on Login
```bash
# Add to ~/.bashrc or startup script
connecttunnel-helper --connect
```

#### Disconnect Before Shutdown
```bash
# Create systemd service or shutdown script
#!/bin/bash
connecttunnel-helper --disconnect
```

#### Status Check Script
```bash
#!/bin/bash
if connecttunnel-helper --status; then
    echo "VPN is active"
    # Do something when connected
else
    echo "VPN is inactive"
    # Do something when disconnected
fi
```

#### Periodic Status Check
```bash
# Add to cron: check every 5 minutes
*/5 * * * * connecttunnel-helper --status || connecttunnel-helper --connect
```

### Integration with Desktop Environment

#### KDE Plasma Shortcuts

1. System Settings → Shortcuts → Custom Shortcuts
2. Create new group: "ConnectTunnel"
3. Add shortcuts:

```
Disconnect (Ctrl+Alt+D):
  Command: connecttunnel-helper --disconnect

Toggle (Ctrl+Alt+C):
  Command: connecttunnel-helper --toggle

Menu (Ctrl+Alt+T):
  Command: connecttunnel-helper --menu
```

---

## Advanced Usage

### Multiple Simultaneous Tools

You can run multiple tools simultaneously:

```bash
# System tray + Control Panel
connecttunnel-tray &
connecttunnel-control-panel &
```

They will share process monitoring and won't conflict.

### Custom Installation Path

If ConnectTunnel is not at `/usr/local/Aventail`:

```bash
# Edit the script
nano ~/.local/bin/connecttunnel-control-panel

# Find and change:
tunnel_path = Path("/usr/local/Aventail")
# To:
tunnel_path = Path("/your/custom/path")
```

### Process Monitoring

All tools monitor the ConnectTunnel process every 2 seconds:
- Automatically detect disconnections
- Update status displays
- Clean up if process dies

### Window Management Troubleshooting

If "Show Window" doesn't work:

```bash
# Install window management tools
sudo apt-get install wmctrl xdotool

# Test manually
wmctrl -a SnwlConnect
# or
xdotool search --name "SnwlConnect" windowactivate
```

---

## Tips & Tricks

### Tip 1: Quick Disconnect from Anywhere

Set up keyboard shortcut:
```bash
Ctrl+Alt+D → connecttunnel-helper --disconnect
```

Now you can disconnect from any application without switching windows!

### Tip 2: Status in Terminal Prompt

Add to `.bashrc`:
```bash
vpn_status() {
    if connecttunnel-helper --status 2>/dev/null; then
        echo "[VPN]"
    fi
}
PS1='$(vpn_status)\u@\h:\w\$ '
```

Shows `[VPN]` in prompt when connected.

### Tip 3: Notification on Disconnect

Create a monitor script:
```bash
#!/bin/bash
while true; do
    if ! connecttunnel-helper --status; then
        notify-send "ConnectTunnel" "VPN Disconnected!" -u critical
        break
    fi
    sleep 30
done
```

### Tip 4: Auto-Reconnect

```bash
# Add to startup
while true; do
    if ! connecttunnel-helper --status; then
        connecttunnel-helper --connect
    fi
    sleep 60
done &
```

### Tip 5: Integration with Network Manager

Create dispatcher script at `/etc/NetworkManager/dispatcher.d/99-connecttunnel`:
```bash
#!/bin/bash
case "$2" in
    up)
        /home/username/.local/bin/connecttunnel-helper --connect
        ;;
    down)
        /home/username/.local/bin/connecttunnel-helper --disconnect
        ;;
esac
```

---

## Troubleshooting

See main [README.md](../README.md#troubleshooting) for comprehensive troubleshooting guide.

### Quick Fixes

**Tool won't start:**
```bash
# Check dependencies
python3 -c "import PyQt5"
which wmctrl

# Make executable
chmod +x ~/.local/bin/connecttunnel-*
```

**Disconnect doesn't work:**
```bash
# Force kill
pkill -9 -f SnwlConnect
```

**Can't find window:**
```bash
# List all windows
wmctrl -l | grep -i connect

# Bring to front manually
wmctrl -a SnwlConnect
```

---

## Support

For more help:
- Read [README.md](../README.md)
- Check [CHANGELOG.md](../CHANGELOG.md)
- Review [troubleshooting section](../README.md#troubleshooting)

---

*Happy tunneling! 🚇*
