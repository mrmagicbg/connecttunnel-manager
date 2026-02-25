# Changelog

All notable changes to ConnectTunnel Manager will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.2] - 2026-02-26

### 🐛 Fixed
- **`find_tunnel_pid` always returned exit 0**: Removed trailing `|| true` that
  masked the actual exit code, making running/stopped detection unreliable
- **`show_menu` readline fallback wrong check**: Condition was testing `$?` (the
  exit code of the preceding `echo`) instead of `$REPLY` (the actual user input);
  readline history loading now triggers correctly only when user confirms with Y/y
- **`install.sh --prefix` silently ignored**: `BIN_DIR`, `SHARE_DIR`,
  `APPLICATIONS_DIR`, and `DOC_DIR` were computed at file load time before
  argument parsing; moved recomputation inside `main()` after `--prefix` is parsed
- **`debug-disconnect.sh` missing `read -r`**: Added `-r` flag to prevent
  backslash interpretation in the "Press Enter" prompt
- **Control Panel UI thread freeze on disconnect**: Replaced two sequential
  `time.sleep(1)` calls in `disconnect_tunnel()` (holding the Qt event loop for
  2 s) with a non-blocking `QTimer.singleShot` chain using
  `_check_after_sigterm()` and `_finalize_disconnect()` callbacks
- **Unused `import time`** removed from control panel (no longer needed after
  sleep → QTimer migration)
- **Bare `except:` in lock file cleanup**: Tightened to `except OSError as e:`
  with stderr logging

---

## [1.0.1] - 2026-01-27

### � Published
- **GitHub Release**: Published to https://github.com/mrmagicbg/connecttunnel-manager
- **Installation**: Now supports `git clone` installation from GitHub

### 🐛 Fixed
- **Disconnect Java dialog error**: Replaced `startct.sh stop` with direct process termination to avoid "Another instance running" Java dialog
- **Disconnect panel freeze**: UI no longer freezes during disconnect - now completes in ~2 seconds
- **Disconnect timeout error**: Increased disconnect timeout from 5 to 30 seconds to handle slow VPN shutdowns
- **Better error handling**: Added specific timeout exception handling with automatic force-kill fallback
- **Process verification**: Added post-disconnect verification to confirm tunnel is fully stopped
- **Multiple process cleanup**: Now also kills `startctui.sh` processes during disconnect
- **Single instance enforcement**: Control Panel now uses file locking to prevent multiple instances
- **Double-click protection**: Disabled connect button during connection to prevent duplicate launches
- **Already-running detection**: Added live status check before attempting connection

### ⚙️ Changed
- Disconnect now uses direct `pkill` commands instead of `startct.sh stop` script
- Graceful shutdown (SIGTERM) attempted first, then force kill (SIGKILL) if needed
- Improved disconnect reliability in Control Panel
- Enhanced error messages with more helpful information
- Better handling when ConnectTunnel is already running
- Disconnect button now disabled during operation and re-enabled when complete

### 🗑️ Removed
- **System Tray Manager** - Removed due to threading issues on KDE Plasma
- **Taskbar Launcher** - Removed to simplify project (Control Panel is recommended)

---

## [1.0.0] - 2026-01-27

### 🎉 Initial Release

First public release of ConnectTunnel Manager - professional GUI tools for managing SonicWall/Aventail ConnectTunnel on Linux systems.

### ✨ Added

#### Control Panel
- Full-featured desktop window with taskbar presence
- Large, accessible Connect/Disconnect buttons
- Real-time connection status display (🟢 Connected / ⚫ Disconnected)
- "Show Tunnel Window" button to bring ConnectTunnel to foreground
- Modern, clean PyQt5-based interface
- Automatic process monitoring every 2 seconds
- Graceful disconnect with confirmation dialog
- Informational tooltips and status messages

#### CLI Helper
- Command-line interface for all operations
- Interactive menu system (kdialog/zenity)
- Quick action flags:
  - `--connect` - Start ConnectTunnel
  - `--disconnect` - Stop ConnectTunnel
  - `--toggle` - Toggle connection state
  - `--status` - Check current status
  - `--show-window` - Bring window to front
  - `--menu` - Show interactive menu
  - `--setup-shortcuts` - Display keyboard shortcut instructions
- Perfect for scripting and automation

#### Installation System
- Comprehensive bash installer (`install.sh`)
- Interactive installation modes:
  - Full installation (all components)
  - Individual tool selection
  - Custom component installation
- Automatic dependency detection and installation assistance
- Desktop shortcut creation
- Autostart configuration
- Custom installation prefix support
- Automatic uninstaller creation

#### Desktop Integration
- XDG desktop entry files for all tools
- Proper categorization (Network, RemoteAccess)
- Icon theme integration (network-vpn)
- Application menu integration
- Autostart support for KDE Plasma and GNOME

#### Documentation
- Comprehensive README with:
  - Feature comparison table
  - Detailed usage instructions
  - Troubleshooting guide
  - Installation options
  - Configuration examples
- This CHANGELOG
- Usage examples and quick start guides

### 🔧 Technical Details

#### Architecture
- Modular design with separate tools
- Shared ConnectTunnel process management logic
- PyQt5-based GUI components
- Pure bash alternatives for minimal dependencies

#### Compatibility
- Tested on KDE Plasma (primary target)
- Compatible with GNOME, XFCE, and other desktop environments
- Supports Ubuntu, Fedora, Arch Linux, and derivatives
- Python 3.6+ requirement for GUI tools
- Works with ConnectTunnel 12.50.00212 and compatible versions

#### Dependencies
- **Required**: Python 3.6+, bash
- **Recommended**: PyQt5 (for GUI tools)
- **Optional**: wmctrl, kdialog, zenity, devilspie2

### 🎯 Problem Solved

Addresses the critical usability issue where ConnectTunnel's Java-based system tray icon on KDE Plasma:
- ❌ Shows no context menu on right-click
- ❌ Cannot be disconnected without command line
- ❌ Cannot be exited gracefully
- ❌ Provides no connection status visibility

ConnectTunnel Manager provides three professional solutions to this problem, each suited to different user preferences and system configurations.

### 📋 Known Issues

None at initial release.

### 🔮 Future Plans

Potential features for future releases:
- [ ] Connection profiles management
- [ ] VPN status notifications with connection time
- [ ] Automatic reconnection on disconnect
- [ ] Network change detection
- [ ] Connection statistics and logging
- [ ] Multi-tunnel support
- [ ] GTK+ version for systems without Qt
- [ ] Configuration GUI
- [ ] Plasma widget integration
- [ ] Translation support (i18n)

### 📦 Distribution

- Installation via bash script
- Installs to `~/.local` by default
- No root privileges required for user installation
- Uninstaller included

### 🙏 Acknowledgments

Created to solve a real frustration experienced by Linux users of ConnectTunnel on KDE Plasma. Special thanks to the open-source community for the tools and libraries that made this project possible:
- PyQt5 project
- wmctrl developers
- KDE Plasma team
- All contributors to the Linux desktop ecosystem

---

## Version Format

Versions follow Semantic Versioning:
- **MAJOR.MINOR.PATCH** (e.g., 1.0.0)
- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## Release Notes Legend

- ✨ **Added**: New features
- 🔧 **Changed**: Changes in existing functionality
- 🐛 **Fixed**: Bug fixes
- 🗑️ **Deprecated**: Soon-to-be removed features
- ❌ **Removed**: Removed features
- 🔒 **Security**: Security fixes

---

[1.0.0]: https://github.com/yourproject/connecttunnel-manager/releases/tag/v1.0.0
