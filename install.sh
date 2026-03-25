#!/bin/bash
#
# ConnectTunnel - Unified Installer
# ===================================
#
# Installs SonicWall/Aventail Connect Tunnel and optionally the
# ConnectTunnel Manager GUI tools on Linux.
#
# Installation modes
# ------------------
#   1) GNOME   – Installs Java 11, ConnectTunnel (bundled package), and
#                patches the start scripts to always use Java 11.
#                The ConnectTunnel Manager control panel is optional.
#   2) KDE     – Same as GNOME but the Manager is installed automatically
#                because the native Java tray icon has no functional context
#                menu on KDE Plasma (no Disconnect / Exit option).
#   3) Uninstall – Removes the ConnectTunnel Manager tools and, optionally,
#                  ConnectTunnel itself via the vendor uninstall script.
#
# Version: 2.0.0
# License: MIT
#

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Paths ────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CT_INSTALLER_DIR="${SCRIPT_DIR}/install/ConnectTunnel_Linux64-12.50.00212"
CT_INSTALL_PATH="/usr/local/Aventail"

INSTALL_PREFIX="${HOME}/.local"
BIN_DIR="${INSTALL_PREFIX}/bin"
SHARE_DIR="${INSTALL_PREFIX}/share"
APPLICATIONS_DIR="${SHARE_DIR}/applications"
AUTOSTART_DIR="${HOME}/.config/autostart"
DOC_DIR="${SHARE_DIR}/doc/connecttunnel-manager"

# Java 11 paths (standard Ubuntu/Debian openjdk-11-jre location)
JAVA11_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
JAVA11_BIN="${JAVA11_HOME}/bin/java"

VERSION="2.0.0"

# ─── Print helpers ────────────────────────────────────────────────────────────
print_header() {
    echo -e "${BLUE}"
    echo "═══════════════════════════════════════════════════════════"
    echo "  ConnectTunnel Unified Installer  v${VERSION}"
    echo "  SonicWall/Aventail Connect Tunnel + Manager for Linux"
    echo "═══════════════════════════════════════════════════════════"
    echo -e "${NC}"
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
print_step()    { echo -e "\n${CYAN}${BOLD}▶ $1${NC}"; }

# ─── Sudo check ───────────────────────────────────────────────────────────────
ensure_sudo() {
    if ! sudo -n true 2>/dev/null; then
        print_info "This installer requires sudo for system-level operations."
        sudo -v || { print_error "sudo access required. Aborting."; exit 1; }
    fi
}

# ─── Desktop environment detection ───────────────────────────────────────────
detect_desktop() {
    local de="unknown"
    if [[ "${XDG_CURRENT_DESKTOP}" == *"KDE"*    ]] ||
       [[ "${DESKTOP_SESSION}"      == *"plasma"* ]] ||
       [[ "${KDE_FULL_SESSION}"     == "true"     ]]; then
        de="kde"
    elif [[ "${XDG_CURRENT_DESKTOP}" == *"GNOME"* ]] ||
         [[ "${DESKTOP_SESSION}"      == *"gnome"* ]]; then
        de="gnome"
    fi
    echo "${de}"
}

# ─── Java 11 installation ─────────────────────────────────────────────────────
install_java11() {
    print_step "Checking for Java 11..."

    if [ -x "${JAVA11_BIN}" ]; then
        local ver
        ver=$("${JAVA11_BIN}" -version 2>&1 | head -1)
        print_success "Java 11 already installed: ${ver}"
        return 0
    fi

    print_info "Java 11 not found at ${JAVA11_BIN}."

    if ! command -v apt-get &>/dev/null; then
        print_error "apt-get not found. Please install openjdk-11-jre manually, then re-run."
        print_info "  sudo apt install openjdk-11-jre"
        exit 1
    fi

    print_info "Installing openjdk-11-jre via apt..."
    sudo apt-get update -qq
    sudo apt-get install -y openjdk-11-jre

    if [ -x "${JAVA11_BIN}" ]; then
        print_success "Java 11 installed: $("${JAVA11_BIN}" -version 2>&1 | head -1)"
    else
        print_error "Java 11 installation failed. Expected binary at ${JAVA11_BIN}"
        print_info "If Java 11 is installed at a different path, set JAVA11_HOME before running:"
        print_info "  JAVA11_HOME=/path/to/java11 bash install.sh"
        exit 1
    fi
}

# ─── ConnectTunnel installation ───────────────────────────────────────────────
install_connecttunnel() {
    print_step "Installing ConnectTunnel VPN client..."

    if [ ! -d "${CT_INSTALLER_DIR}" ]; then
        print_error "ConnectTunnel installer not found at: ${CT_INSTALLER_DIR}"
        exit 1
    fi

    if [ -f "${CT_INSTALL_PATH}/startctui.sh" ]; then
        print_warning "ConnectTunnel is already installed at ${CT_INSTALL_PATH}"
        echo ""
        read -rp "  Reinstall / upgrade? [y/N] " yn
        echo ""
        if [[ ! "${yn}" =~ ^[Yy]$ ]]; then
            print_info "Skipping ConnectTunnel installation. Existing install will be used."
            return 0
        fi
        # Uninstall first so the bundled installer can proceed with --auto
        if [ -x "${CT_INSTALL_PATH}/uninstall.sh" ]; then
            print_info "Removing existing ConnectTunnel installation..."
            sudo "${CT_INSTALL_PATH}/uninstall.sh"
        fi
    fi

    print_info "Running ConnectTunnel installer (this requires root)..."
    (
        cd "${CT_INSTALLER_DIR}"
        sudo bash install.sh --auto
    )

    if [ -f "${CT_INSTALL_PATH}/startctui.sh" ]; then
        print_success "ConnectTunnel installed at ${CT_INSTALL_PATH}"
    else
        print_error "ConnectTunnel installation appears to have failed."
        exit 1
    fi
}

# ─── Java 11 patch for start scripts ─────────────────────────────────────────
#
# Both startctui.sh and startct.sh call `java` directly.  We inject an
# export block after the shebang line so both the java-version check inside
# the scripts and the final `java -jar` call use the pinned Java 11 binary.
#
patch_start_scripts_java11() {
    print_step "Patching ConnectTunnel start scripts to pin Java 11..."

    # Write a helper patching script to /tmp so we can run it under sudo
    local patch_helper
    patch_helper="$(mktemp /tmp/ct_java11_patch.XXXXXX.sh)"

    cat > "${patch_helper}" << 'PATCHSCRIPT'
#!/bin/bash
# Inserts JAVA_HOME / PATH export block after the shebang of a script file.
# Usage: this_script.sh <target_file> <java11_home>
FILE="$1"
JAVA11_HOME="$2"

if grep -q "Java 11 pinned by ConnectTunnel installer" "${FILE}"; then
    echo "ALREADY_PATCHED"
    exit 0
fi

TMPFILE="$(mktemp)"
# Line 1: shebang
head -1 "${FILE}" > "${TMPFILE}"
# Inject Java 11 block
cat >> "${TMPFILE}" << JAVABLOCK

# --- Java 11 pinned by ConnectTunnel installer ---
export JAVA_HOME="${JAVA11_HOME}"
export PATH="\$JAVA_HOME/bin:\$PATH"
# -------------------------------------------------

JAVABLOCK
# Remaining lines
tail -n +2 "${FILE}" >> "${TMPFILE}"
cp "${TMPFILE}" "${FILE}"
chmod +x "${FILE}"
rm -f "${TMPFILE}"
echo "PATCHED"
PATCHSCRIPT

    chmod +x "${patch_helper}"

    local patched_any=false
    for script in startctui.sh startct.sh; do
        local full_path="${CT_INSTALL_PATH}/${script}"
        if [ ! -f "${full_path}" ]; then
            print_warning "${full_path} not found — skipping."
            continue
        fi

        local result
        result=$(sudo bash "${patch_helper}" "${full_path}" "${JAVA11_HOME}" 2>&1)
        if [ "${result}" = "ALREADY_PATCHED" ]; then
            print_success "${script} — already patched."
        elif [ "${result}" = "PATCHED" ]; then
            print_success "${script} — patched to use Java 11."
            patched_any=true
        else
            print_error "Failed to patch ${script}: ${result}"
        fi
    done

    rm -f "${patch_helper}"

    if [ "${patched_any}" = true ]; then
        print_info "Verify with: head -8 ${CT_INSTALL_PATH}/startctui.sh"
    fi
}

# ─── Manager installation (Control Panel + CLI Helper) ───────────────────────
install_manager_tools() {
    print_step "Installing ConnectTunnel Manager..."

    # Ensure manager dependencies are available
    local missing_deps=()
    if ! command -v python3 &>/dev/null; then
        missing_deps+=("python3")
    fi
    if ! python3 -c "import PyQt5" 2>/dev/null; then
        missing_deps+=("python3-pyqt5")
    fi
    if ! command -v wmctrl &>/dev/null; then
        missing_deps+=("wmctrl")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_warning "Missing packages: ${missing_deps[*]}"
        read -rp "  Install them now? [Y/n] " yn
        echo ""
        if [[ ! "${yn}" =~ ^[Nn]$ ]]; then
            if command -v apt-get &>/dev/null; then
                sudo apt-get install -y "${missing_deps[@]}"
            else
                print_warning "Cannot auto-install. Please install manually: ${missing_deps[*]}"
            fi
        fi
    fi

    mkdir -p "${BIN_DIR}" "${APPLICATIONS_DIR}" "${DOC_DIR}"

    # Binaries
    cp "${SCRIPT_DIR}/bin/connecttunnel-control-panel" "${BIN_DIR}/"
    chmod +x "${BIN_DIR}/connecttunnel-control-panel"
    print_success "Installed connecttunnel-control-panel"

    cp "${SCRIPT_DIR}/bin/connecttunnel-helper" "${BIN_DIR}/"
    chmod +x "${BIN_DIR}/connecttunnel-helper"
    print_success "Installed connecttunnel-helper"

    # Desktop entry
    sed "s|INSTALL_PREFIX|${INSTALL_PREFIX}|g" \
        "${SCRIPT_DIR}/share/applications/connecttunnel-control-panel.desktop" \
        > "${APPLICATIONS_DIR}/connecttunnel-control-panel.desktop"
    chmod +x "${APPLICATIONS_DIR}/connecttunnel-control-panel.desktop"
    print_success "Installed desktop shortcut"

    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "${APPLICATIONS_DIR}" 2>/dev/null || true
    fi

    # Documentation
    cp -f "${SCRIPT_DIR}/README.md"    "${DOC_DIR}/" 2>/dev/null || true
    cp -f "${SCRIPT_DIR}/CHANGELOG.md" "${DOC_DIR}/" 2>/dev/null || true
    cp -r "${SCRIPT_DIR}/docs/."       "${DOC_DIR}/" 2>/dev/null || true
    print_success "Documentation installed to ${DOC_DIR}"

    # Uninstaller
    _create_uninstaller
}

# ─── Ask about autostart ──────────────────────────────────────────────────────
ask_autostart() {
    echo ""
    read -rp "  Start the Control Panel automatically at login? [y/N] " yn
    echo ""
    if [[ "${yn}" =~ ^[Yy]$ ]]; then
        mkdir -p "${AUTOSTART_DIR}"
        sed "s|INSTALL_PREFIX|${INSTALL_PREFIX}|g" \
            "${SCRIPT_DIR}/share/applications/connecttunnel-control-panel.desktop" \
            > "${AUTOSTART_DIR}/connecttunnel-control-panel.desktop"
        print_success "Control Panel will start automatically at login."
    fi
}

# ─── Uninstaller script creation ─────────────────────────────────────────────
_create_uninstaller() {
    local uninstall_bin="${BIN_DIR}/connecttunnel-manager-uninstall"

    cat > "${uninstall_bin}" << 'UNINSTALL_EOF'
#!/bin/bash
#
# ConnectTunnel Manager - Uninstaller
# Removes ConnectTunnel Manager tools from ~/.local
# Run with --vpn to also remove the ConnectTunnel VPN client itself.
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BIN_DIR="${HOME}/.local/bin"
APPLICATIONS_DIR="${HOME}/.local/share/applications"
AUTOSTART_DIR="${HOME}/.config/autostart"
DOC_DIR="${HOME}/.local/share/doc/connecttunnel-manager"
CT_INSTALL_PATH="/usr/local/Aventail"

REMOVE_VPN=false
for arg in "$@"; do
    [[ "${arg}" == "--vpn" ]] && REMOVE_VPN=true
done

echo -e "${BLUE}ConnectTunnel Manager - Uninstaller${NC}"
echo ""

echo "Removing ConnectTunnel Manager tools..."

rm -f  "${BIN_DIR}/connecttunnel-control-panel"
rm -f  "${BIN_DIR}/connecttunnel-helper"
rm -f  "${BIN_DIR}/connecttunnel-manager-uninstall"
rm -f  "${APPLICATIONS_DIR}"/connecttunnel-*.desktop
rm -f  "${AUTOSTART_DIR}"/connecttunnel-*.desktop
rm -rf "${DOC_DIR}"

if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "${APPLICATIONS_DIR}" 2>/dev/null || true
fi

echo -e "${GREEN}✓${NC} ConnectTunnel Manager removed."

if [ "${REMOVE_VPN}" = true ]; then
    echo ""
    echo -e "${YELLOW}⚠${NC}  Removing ConnectTunnel VPN client..."
    if [ -x "${CT_INSTALL_PATH}/uninstall.sh" ]; then
        sudo "${CT_INSTALL_PATH}/uninstall.sh"
        echo -e "${GREEN}✓${NC} ConnectTunnel VPN client removed."
    else
        echo -e "${RED}✗${NC} ConnectTunnel uninstaller not found at ${CT_INSTALL_PATH}/uninstall.sh"
        echo "    Remove manually: sudo rm -rf ${CT_INSTALL_PATH}"
    fi
fi

echo ""
echo "Done."
UNINSTALL_EOF

    chmod +x "${uninstall_bin}"
    print_success "Uninstaller created: ${uninstall_bin}"
}

# ─── PATH hint ───────────────────────────────────────────────────────────────
check_path() {
    if [[ ":${PATH}:" != *":${BIN_DIR}:"* ]]; then
        print_warning "${BIN_DIR} is not in your PATH."
        echo ""
        echo "  Add this to your ~/.bashrc or ~/.zshrc:"
        echo "    export PATH=\"\${HOME}/.local/bin:\$PATH\""
        echo "  Then reload with: source ~/.bashrc"
        echo ""
    fi
}

# ─── Summary ─────────────────────────────────────────────────────────────────
print_summary_vpn_only() {
    echo ""
    echo -e "${GREEN}"
    echo "═══════════════════════════════════════════════════════════"
    echo "  ConnectTunnel Installation Complete!"
    echo "═══════════════════════════════════════════════════════════"
    echo -e "${NC}"
    echo ""
    echo "  ConnectTunnel is installed at ${CT_INSTALL_PATH}"
    echo ""
    echo "  Launch the VPN UI:"
    echo "    ${CT_INSTALL_PATH}/startctui.sh"
    echo ""
    echo "  Java 11 is pinned — the start scripts set JAVA_HOME automatically."
    echo ""
}

print_summary_with_manager() {
    echo ""
    echo -e "${GREEN}"
    echo "═══════════════════════════════════════════════════════════"
    echo "  ConnectTunnel + Manager Installation Complete!"
    echo "═══════════════════════════════════════════════════════════"
    echo -e "${NC}"
    echo ""
    echo "  ConnectTunnel VPN client:  ${CT_INSTALL_PATH}"
    echo "  Control Panel:             ${BIN_DIR}/connecttunnel-control-panel"
    echo "  CLI Helper:                ${BIN_DIR}/connecttunnel-helper"
    echo "  Documentation:             ${DOC_DIR}"
    echo "  Uninstaller:               ${BIN_DIR}/connecttunnel-manager-uninstall"
    echo ""
    echo "  Quick start:"
    echo "    connecttunnel-control-panel"
    echo ""
    check_path
}

# ─── Mode: GNOME ─────────────────────────────────────────────────────────────
mode_gnome() {
    echo ""
    print_info "Selected: GNOME installation"
    echo ""

    ensure_sudo
    install_java11
    install_connecttunnel
    patch_start_scripts_java11

    echo ""
    read -rp "  Also install the ConnectTunnel Manager (Control Panel + CLI Helper)? [y/N] " yn
    echo ""
    if [[ "${yn}" =~ ^[Yy]$ ]]; then
        install_manager_tools
        ask_autostart
        print_summary_with_manager
    else
        print_info "Skipping Manager installation."
        print_summary_vpn_only
    fi
}

# ─── Mode: KDE ───────────────────────────────────────────────────────────────
mode_kde() {
    echo ""
    print_info "Selected: KDE installation"
    print_info "The ConnectTunnel Manager is required on KDE because the native"
    print_info "Java system tray icon has no functional Disconnect / Exit menu."
    echo ""

    ensure_sudo
    install_java11
    install_connecttunnel
    patch_start_scripts_java11
    install_manager_tools
    ask_autostart
    print_summary_with_manager
}

# ─── Mode: Uninstall ─────────────────────────────────────────────────────────
mode_uninstall() {
    echo ""
    print_info "Selected: Uninstall"
    echo ""

    # Remove Manager tools
    local removed_manager=false
    for f in \
        "${BIN_DIR}/connecttunnel-control-panel" \
        "${BIN_DIR}/connecttunnel-helper" \
        "${BIN_DIR}/connecttunnel-manager-uninstall"; do
        if [ -f "${f}" ]; then
            rm -f "${f}"
            removed_manager=true
        fi
    done
    rm -f  "${APPLICATIONS_DIR}"/connecttunnel-*.desktop
    rm -f  "${AUTOSTART_DIR}"/connecttunnel-*.desktop
    rm -rf "${DOC_DIR}"
    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "${APPLICATIONS_DIR}" 2>/dev/null || true
    fi
    if [ "${removed_manager}" = true ]; then
        print_success "ConnectTunnel Manager tools removed."
    else
        print_info "No ConnectTunnel Manager tools were installed — nothing to remove."
    fi

    # Optionally remove ConnectTunnel itself
    echo ""
    if [ -x "${CT_INSTALL_PATH}/uninstall.sh" ]; then
        read -rp "  Also remove the ConnectTunnel VPN client itself? [y/N] " yn
        echo ""
        if [[ "${yn}" =~ ^[Yy]$ ]]; then
            print_info "Running ConnectTunnel uninstaller (requires sudo)..."
            ensure_sudo
            sudo "${CT_INSTALL_PATH}/uninstall.sh"
            print_success "ConnectTunnel VPN client removed."
        else
            print_info "ConnectTunnel VPN client left in place at ${CT_INSTALL_PATH}"
        fi
    else
        print_info "ConnectTunnel VPN client not found at ${CT_INSTALL_PATH} — already uninstalled."
    fi

    echo ""
    print_success "Uninstall complete."
}

# ─── Main menu ───────────────────────────────────────────────────────────────
show_main_menu() {
    local detected
    detected="$(detect_desktop)"
    local hint=""
    [ "${detected}" = "kde"   ] && hint="  (detected: KDE Plasma)"
    [ "${detected}" = "gnome" ] && hint="  (detected: GNOME)"

    echo ""
    echo -e "${BOLD}Choose installation mode:${NC}${hint}"
    echo ""
    echo "  1) GNOME  — Install Java 11 + ConnectTunnel, patch for Java 11."
    echo "              Manager (Control Panel) is optional."
    echo ""
    echo "  2) KDE    — Same as GNOME but Manager is mandatory."
    echo "              (Native Java tray lacks a Disconnect button on KDE.)"
    echo ""
    echo "  3) Uninstall — Remove Manager tools and/or ConnectTunnel."
    echo ""
    echo "  4) Exit"
    echo ""
    read -rp "Select [1-4]: " choice
    echo ""

    case "${choice}" in
        1) mode_gnome    ;;
        2) mode_kde      ;;
        3) mode_uninstall ;;
        4) echo "Aborted."; exit 0 ;;
        *) print_error "Invalid option '${choice}'."; show_main_menu ;;
    esac
}

# ─── Entry point ─────────────────────────────────────────────────────────────
main() {
    print_header

    case "${1:-}" in
        --help|-h)
            cat << 'HELP'
Usage: bash install.sh [MODE]

Modes (non-interactive):
  --gnome       Run GNOME installation flow
  --kde         Run KDE installation flow
  --uninstall   Run uninstall flow

Options:
  --help        Show this help

Environment variables:
  JAVA11_HOME   Override the Java 11 home directory
                Default: /usr/lib/jvm/java-11-openjdk-amd64

HELP
            exit 0
            ;;
        --gnome)      mode_gnome     ;;
        --kde)        mode_kde       ;;
        --uninstall)  mode_uninstall ;;
        "")           show_main_menu ;;
        *)
            print_error "Unknown argument: $1"
            echo "Run 'bash install.sh --help' for usage."
            exit 1
            ;;
    esac
}

main "$@"
