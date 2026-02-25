#!/bin/bash
#
# ConnectTunnel Manager - Installation Script
# ============================================
#
# This script installs the ConnectTunnel Manager suite, which provides
# GUI tools for managing SonicWall/Aventail ConnectTunnel on Linux systems,
# especially KDE Plasma where the native Java tray icon lacks functionality.
#
# Version: 1.0.0
# Author: ConnectTunnel Manager Project
# License: MIT
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation paths
INSTALL_PREFIX="${HOME}/.local"
BIN_DIR="${INSTALL_PREFIX}/bin"
SHARE_DIR="${INSTALL_PREFIX}/share"
APPLICATIONS_DIR="${SHARE_DIR}/applications"
AUTOSTART_DIR="${HOME}/.config/autostart"
DOC_DIR="${SHARE_DIR}/doc/connecttunnel-manager"

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ConnectTunnel installation path
CONNECTTUNNEL_PATH="/usr/local/Aventail"

# Flags
INSTALL_DESKTOP=true
INSTALL_AUTOSTART=false
INSTALL_DEPENDENCIES=true
SELECTED_TOOL=""
INSTALL_CONTROL_PANEL=false
INSTALL_HELPER=false

# Functions
print_header() {
    echo -e "${BLUE}"
    echo "═══════════════════════════════════════════════════════════"
    echo "  ConnectTunnel Manager - Installation Script"
    echo "  Version 1.0.0"
    echo "═══════════════════════════════════════════════════════════"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

check_connecttunnel() {
    if [ ! -f "${CONNECTTUNNEL_PATH}/startctui.sh" ]; then
        print_error "ConnectTunnel not found at ${CONNECTTUNNEL_PATH}"
        echo ""
        read -p "Enter ConnectTunnel installation path (or press Enter to skip): " custom_path
        if [ -n "$custom_path" ] && [ -f "$custom_path/startctui.sh" ]; then
            CONNECTTUNNEL_PATH="$custom_path"
            print_success "Found ConnectTunnel at ${CONNECTTUNNEL_PATH}"
        else
            print_warning "ConnectTunnel not found. You'll need to configure paths manually later."
            sleep 2
        fi
    else
        print_success "Found ConnectTunnel at ${CONNECTTUNNEL_PATH}"
    fi
}

check_dependencies() {
    print_info "Checking dependencies..."
    
    local missing_deps=()
    
    # Check Python3
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    else
        print_success "Python3 found: $(python3 --version)"
    fi
    
    # Check pip3
    if ! command -v pip3 &> /dev/null; then
        missing_deps+=("python3-pip")
    else
        print_success "pip3 found"
    fi
    
    # Check PyQt5 (for GUI tools)
    if ! python3 -c "import PyQt5" 2>/dev/null; then
        print_warning "PyQt5 not found (required for GUI tools)"
        missing_deps+=("python3-pyqt5")
    else
        print_success "PyQt5 found"
    fi
    
    # Check wmctrl (optional)
    if ! command -v wmctrl &> /dev/null; then
        print_warning "wmctrl not found (optional, for window management)"
    else
        print_success "wmctrl found"
    fi
    
    # Check dialog tools
    if command -v kdialog &> /dev/null; then
        print_success "kdialog found (KDE)"
    elif command -v zenity &> /dev/null; then
        print_success "zenity found (GNOME)"
    else
        print_warning "No dialog tool found (kdialog or zenity recommended)"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo ""
        print_warning "Missing dependencies: ${missing_deps[*]}"
        
        if [ "$INSTALL_DEPENDENCIES" = true ]; then
            echo ""
            read -p "Install missing dependencies? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_dependencies "${missing_deps[@]}"
            fi
        fi
    fi
}

install_dependencies() {
    local deps=("$@")
    print_info "Installing dependencies..."
    
    # Detect package manager
    if command -v apt-get &> /dev/null; then
        echo "Using apt-get..."
        
        # Try to install without sudo first
        for dep in "${deps[@]}"; do
            if [ "$dep" = "python3-pyqt5" ]; then
                # Try pip3 first
                if pip3 install PyQt5 2>/dev/null; then
                    print_success "Installed PyQt5 via pip3"
                else
                    print_warning "Could not install PyQt5 via pip3"
                    echo "You may need to run: sudo apt-get install python3-pyqt5"
                fi
            else
                print_warning "Some dependencies require sudo. Please run:"
                echo "  sudo apt-get install ${deps[*]}"
            fi
        done
    elif command -v dnf &> /dev/null; then
        print_info "Detected dnf (Fedora/RHEL)"
        echo "Please run: sudo dnf install ${deps[*]}"
    elif command -v pacman &> /dev/null; then
        print_info "Detected pacman (Arch)"
        echo "Please run: sudo pacman -S ${deps[*]}"
    else
        print_warning "Could not detect package manager"
        echo "Please install these packages manually: ${deps[*]}"
    fi
}

show_menu() {
    echo ""
    echo "Choose installation mode:"
    echo ""
    echo "1) Full Installation (Control Panel + CLI Helper + desktop shortcut)"
    echo "2) Control Panel only"
    echo "3) Cancel installation"
    echo ""
    read -p "Select option [1-3]: " choice
    
    case $choice in
        1) SELECTED_TOOL="all" ;;
        2) SELECTED_TOOL="control-panel" ;;
        3) exit 0 ;;
        *) print_error "Invalid option"; show_menu ;;
    esac
}

create_directories() {
    print_info "Creating installation directories..."
    
    mkdir -p "${BIN_DIR}"
    mkdir -p "${APPLICATIONS_DIR}"
    mkdir -p "${DOC_DIR}"
    
    if [ "$INSTALL_AUTOSTART" = true ]; then
        mkdir -p "${AUTOSTART_DIR}"
    fi
    
    print_success "Directories created"
}

install_binaries() {
    print_info "Installing binaries..."
    
    if [ "$INSTALL_CONTROL_PANEL" = true ]; then
        cp "${SCRIPT_DIR}/bin/connecttunnel-control-panel" "${BIN_DIR}/"
        chmod +x "${BIN_DIR}/connecttunnel-control-panel"
        print_success "Installed Control Panel"
    fi
    
    if [ "$INSTALL_HELPER" = true ]; then
        cp "${SCRIPT_DIR}/bin/connecttunnel-helper" "${BIN_DIR}/"
        chmod +x "${BIN_DIR}/connecttunnel-helper"
        print_success "Installed CLI Helper"
    fi
}

install_desktop_files() {
    if [ "$INSTALL_DESKTOP" != true ]; then
        return
    fi
    
    print_info "Installing desktop shortcuts..."
    
    if [ "$INSTALL_CONTROL_PANEL" = true ]; then
        sed "s|INSTALL_PREFIX|${INSTALL_PREFIX}|g" \
            "${SCRIPT_DIR}/share/applications/connecttunnel-control-panel.desktop" \
            > "${APPLICATIONS_DIR}/connecttunnel-control-panel.desktop"
        chmod +x "${APPLICATIONS_DIR}/connecttunnel-control-panel.desktop"
        print_success "Installed connecttunnel-control-panel.desktop"
    fi
    
    # Update desktop database
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "${APPLICATIONS_DIR}" 2>/dev/null || true
    fi
}

install_autostart() {
    if [ "$INSTALL_AUTOSTART" != true ]; then
        return
    fi
    
    print_info "Setting up autostart (Control Panel)..."
    sed "s|INSTALL_PREFIX|${INSTALL_PREFIX}|g" \
        "${SCRIPT_DIR}/share/applications/connecttunnel-control-panel.desktop" \
        > "${AUTOSTART_DIR}/connecttunnel-control-panel.desktop"
    print_success "Control Panel added to autostart"
}

install_documentation() {
    print_info "Installing documentation..."
    
    if [ -f "${SCRIPT_DIR}/README.md" ]; then
        cp "${SCRIPT_DIR}/README.md" "${DOC_DIR}/"
    fi
    
    if [ -f "${SCRIPT_DIR}/CHANGELOG.md" ]; then
        cp "${SCRIPT_DIR}/CHANGELOG.md" "${DOC_DIR}/"
    fi
    
    if [ -d "${SCRIPT_DIR}/docs" ]; then
        cp -r "${SCRIPT_DIR}"/docs/* "${DOC_DIR}/" 2>/dev/null || true
    fi
    
    print_success "Documentation installed to ${DOC_DIR}"
}

create_uninstaller() {
    print_info "Creating uninstaller..."
    
    cat > "${BIN_DIR}/connecttunnel-manager-uninstall" << 'UNINSTALL_EOF'
#!/bin/bash
# ConnectTunnel Manager - Uninstaller

BIN_DIR="${HOME}/.local/bin"
APPLICATIONS_DIR="${HOME}/.local/share/applications"
AUTOSTART_DIR="${HOME}/.config/autostart"
DOC_DIR="${HOME}/.local/share/doc/connecttunnel-manager"

echo "Uninstalling ConnectTunnel Manager..."

# Remove binaries
rm -f "${BIN_DIR}/connecttunnel-control-panel"
# rm -f "${BIN_DIR}/connecttunnel-tray"  # Removed component
# rm -f "${BIN_DIR}/connecttunnel-taskbar-launcher"  # Removed component
rm -f "${BIN_DIR}/connecttunnel-helper"
rm -f "${BIN_DIR}/connecttunnel-manager-uninstall"

# Remove desktop files
rm -f "${APPLICATIONS_DIR}/connecttunnel-"*.desktop

# Remove autostart
rm -f "${AUTOSTART_DIR}/connecttunnel-"*.desktop

# Remove documentation
rm -rf "${DOC_DIR}"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "${APPLICATIONS_DIR}" 2>/dev/null || true
fi

echo "✓ ConnectTunnel Manager uninstalled successfully"
UNINSTALL_EOF
    
    chmod +x "${BIN_DIR}/connecttunnel-manager-uninstall"
    print_success "Uninstaller created"
}

check_path() {
    if [[ ":$PATH:" != *":${BIN_DIR}:"* ]]; then
        print_warning "${BIN_DIR} is not in your PATH"
        echo ""
        echo "Add this to your ~/.bashrc or ~/.zshrc:"
        echo "  export PATH=\"\${HOME}/.local/bin:\$PATH\""
        echo ""
    fi
}

print_summary() {
    echo ""
    echo -e "${GREEN}"
    echo "═══════════════════════════════════════════════════════════"
    echo "  Installation Complete!"
    echo "═══════════════════════════════════════════════════════════"
    echo -e "${NC}"
    echo ""
    
    print_info "Installed components:"
    
    if [ -f "${BIN_DIR}/connecttunnel-control-panel" ]; then
        echo "  • Control Panel: connecttunnel-control-panel"
    fi
    
    if [ -f "${BIN_DIR}/connecttunnel-helper" ]; then
        echo "  • CLI Helper: connecttunnel-helper"
    fi
    
    echo ""
    print_info "Quick start:"
    
    if [ -f "${BIN_DIR}/connecttunnel-control-panel" ]; then
        echo "  ${BIN_DIR}/connecttunnel-control-panel"
    fi
    
    echo ""
    print_info "Documentation: ${DOC_DIR}"
    print_info "Uninstall: ${BIN_DIR}/connecttunnel-manager-uninstall"
    
    echo ""
    check_path
}

# Main installation flow
main() {
    print_header
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto)
                SELECTED_TOOL="all"
                INSTALL_DEPENDENCIES=true
                shift
                ;;
            --no-deps)
                INSTALL_DEPENDENCIES=false
                shift
                ;;
            --prefix=*)
                INSTALL_PREFIX="${1#*=}"
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --auto          Automatic installation (all components)"
                echo "  --no-deps       Skip dependency installation"
                echo "  --prefix=PATH   Set installation prefix (default: ~/.local)"
                echo "  --help          Show this help"
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done

    # Recompute directory paths now that INSTALL_PREFIX may have been overridden by --prefix
    BIN_DIR="${INSTALL_PREFIX}/bin"
    SHARE_DIR="${INSTALL_PREFIX}/share"
    APPLICATIONS_DIR="${SHARE_DIR}/applications"
    DOC_DIR="${SHARE_DIR}/doc/connecttunnel-manager"

    # Check ConnectTunnel installation
    check_connecttunnel
    echo ""
    
    # Check dependencies
    check_dependencies
    echo ""
    
    # Show installation menu if not --auto
    if [ -z "$SELECTED_TOOL" ]; then
        show_menu
    fi
    
    # Resolve selections
    case "$SELECTED_TOOL" in
        all)
            INSTALL_CONTROL_PANEL=true
            INSTALL_HELPER=true
            INSTALL_DESKTOP=true
            ;;
        control-panel)
            INSTALL_CONTROL_PANEL=true
            INSTALL_HELPER=false
            INSTALL_DESKTOP=true
            ;;
    esac
    
    echo ""
    print_info "Installing ConnectTunnel Manager..."
    echo ""
    
    # Perform installation
    create_directories
    install_binaries
    install_desktop_files
    install_autostart
    install_documentation
    create_uninstaller
    
    # Print summary
    print_summary
}

# Run main
main "$@"
