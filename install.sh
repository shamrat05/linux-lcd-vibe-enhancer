#!/usr/bin/env bash
# ==============================================================================
# Linux LCD Vibe Enhancer - Installer Script
# AMOLED-like Contrast, DCI-P3 Color Calibrations, and Crisp Font Optimizations
# ==============================================================================

set -euo pipefail

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BLUE}${BOLD}====================================================${NC}"
echo -e "${BLUE}${BOLD}      Installing Linux LCD Vibe Enhancer...         ${NC}"
echo -e "${BLUE}${BOLD}====================================================${NC}"

# Check current desktop environment
DESKTOP="${XDG_CURRENT_DESKTOP:-}"
echo -e "* Desktop environment detected: ${BOLD}${DESKTOP}${NC}"

# 1. Copying local configuration files
echo -e "\n${BLUE}[1/6] Copying configuration files...${NC}"

# Autostart configuration
mkdir -p "$HOME/.config/autostart"
cp config/autostart/apply-display-vibe.sh "$HOME/.config/autostart/"
cp config/autostart/display-vibe.desktop "$HOME/.config/autostart/"
chmod +x "$HOME/.config/autostart/apply-display-vibe.sh"
echo -e "  ${GREEN}✓${NC} Autostart script and desktop entry installed."

# Fontconfig configuration
mkdir -p "$HOME/.config/fontconfig"
cp config/fontconfig/fonts.conf "$HOME/.config/fontconfig/"
echo -e "  ${GREEN}✓${NC} Fontconfig local settings installed."

# Xresources configuration
if [ -f config/Xresources ]; then
    cp config/Xresources "$HOME/.Xresources"
    if command -v xrdb >/dev/null 2>&1; then
        xrdb -merge "$HOME/.Xresources" || true
    fi
    echo -e "  ${GREEN}✓${NC} Xresources font/DPI configurations applied."
fi

# xprofile performance configuration
if [ -f config/xprofile ]; then
    cp config/xprofile "$HOME/.xprofile"
    chmod +x "$HOME/.xprofile"
    echo -e "  ${GREEN}✓${NC} xprofile performance enhancements installed."
fi

# ICC color profiles
mkdir -p "$HOME/.local/share/icc"
cp icc/ASUS_DCIP3.icm "$HOME/.local/share/icc/"
cp icc/ASUS_DisplayP3.icm "$HOME/.local/share/icc/"
cp icc/ASUS_sRGB.icm "$HOME/.local/share/icc/"
echo -e "  ${GREEN}✓${NC} ASUS color profiles (DCI-P3, Display-P3, sRGB) copied to local share."

# Premium dark wallpapers installation
if [ -d wallpapers ]; then
    mkdir -p "$HOME/Pictures"
    cp wallpapers/od_gargantua.png wallpapers/od_space01.png wallpapers/od_hills.png wallpapers/web_sunset_mountains.png "$HOME/Pictures/"
    echo -e "  ${GREEN}✓${NC} Premium minimalist dark wallpapers installed."
fi


# 2. Registering and applying DCI-P3 color profile via colord
echo -e "\n${BLUE}[2/6] Setting up colord color profiles...${NC}"
if command -v colormgr >/dev/null 2>&1; then
    # Dynamically find the primary display device ID
    DEVICE_ID=$(colormgr get-devices | grep -E -A 10 "Type:[[:space:]]*display" | grep "Device ID:" | head -n 1 | awk -F': ' '{print $2}' | xargs || true)
    
    if [ -n "$DEVICE_ID" ]; then
        echo -e "  Found display device: ${BOLD}${DEVICE_ID}${NC}"
        
        # Import and register the profile
        echo -e "  Importing ASUS DCI-P3 profile..."
        PROFILE_PATH="$HOME/.local/share/icc/ASUS_DCIP3.icm"
        
        # Use colormgr to import
        colormgr import-profile "$PROFILE_PATH" || true
        
        # Build colord profile ID from filename checksum
        CHECKSUM=$(md5sum "$PROFILE_PATH" | awk '{print $1}')
        PROFILE_ID="icc-${CHECKSUM}"
        
        # Add profile to device and make default
        colormgr device-add-profile "$DEVICE_ID" "$PROFILE_ID" || true
        colormgr device-make-profile-default "$DEVICE_ID" "$PROFILE_ID" && \
            echo -e "  ${GREEN}✓${NC} ASUS DCI-P3 set as default system color profile." || \
            echo -e "  ${YELLOW}!${NC} Note: Could not set default profile via colormgr automatically. You can do this manually in Settings > Color."
    else
        echo -e "  ${YELLOW}!${NC} No active colord display device found automatically. You can manually apply the DCI-P3 profile in your system's Color settings."
    fi
else
    echo -e "  ${YELLOW}!${NC} colormgr utility not found. Color profiles copied but not registered. Install 'colord' or apply manually."
fi

# 3. Applying font and text scaling configurations
echo -e "\n${BLUE}[3/6] Applying font settings and text scaling...${NC}"
if command -v gsettings >/dev/null 2>&1; then
    # Apply fonts (Inter and JetBrains Mono)
    echo -e "  Configuring system fonts to Inter and JetBrains Mono..."
    
    # Check if Cinnamon desktop interface schema exists
    if gsettings list-schemas | grep -q "org.cinnamon.desktop.interface"; then
        gsettings set org.cinnamon.desktop.interface font-name 'Inter 10'
        gsettings set org.cinnamon.desktop.wm.preferences titlebar-font 'Inter Semi-Bold 10'
        gsettings set org.nemo.desktop font 'Inter 10'
        gsettings set org.cinnamon.desktop.interface text-scaling-factor 1.15
        
        # Subpixel antialiasing & slight hinting
        gsettings set org.cinnamon.settings-daemon.plugins.xsettings antialiasing 'rgba'
        gsettings set org.cinnamon.settings-daemon.plugins.xsettings hinting 'slight'
        gsettings set org.cinnamon.settings-daemon.plugins.xsettings rgba-order 'rgb'

        # Premium Smooth Animations (Windows 11 / macOS style Scale transitions)
        gsettings set org.cinnamon desktop-effects-close 'scale'
        gsettings set org.cinnamon desktop-effects-map 'scale'
        gsettings set org.cinnamon desktop-effects-minimize 'traditional'

        # Theme alignment (Align Window borders with GTK theme)
        gsettings set org.cinnamon.desktop.wm.preferences theme 'Orchis-Dark'

        # Configure Tilix copy/paste shortcuts to be Windows-like (Ctrl+C / Ctrl+V)
        if gsettings list-schemas | grep -q "com.gexperts.Tilix.Keybindings"; then
            gsettings set com.gexperts.Tilix.Keybindings terminal-copy '<Ctrl>c'
            gsettings set com.gexperts.Tilix.Keybindings terminal-paste '<Ctrl>v'
        fi

        # Windows-like system keybindings (Win+L to Lock, Win+R to Run, Ctrl+Shift+Esc for Task Manager)
        gsettings set org.cinnamon.desktop.keybindings.wm panel-run-dialog "['<Alt>F2', '<Super>r']"
        gsettings set org.cinnamon.desktop.keybindings looking-glass-keybinding "['<Super><Shift>l']"
        gsettings set org.cinnamon.desktop.keybindings.media-keys screensaver "['<Control><Alt>l', '<Super>l', 'XF86ScreenSaver']"
        gsettings set org.cinnamon.desktop.keybindings custom-list "['custom0', 'custom1', 'custom2']"
        gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom2/ name 'Task Manager'
        gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom2/ command 'gnome-system-monitor'
        gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom2/ binding "['<Primary><Shift>Escape']"

        # Apply Premium dark wallpaper (Sunset Mountains minimalist design)
        gsettings set org.cinnamon.desktop.background picture-uri "file://$HOME/Pictures/web_sunset_mountains.png"
    fi
    
    # Apply to GNOME schemas (used by many GTK apps)
    if gsettings list-schemas | grep -q "org.gnome.desktop.interface"; then
        gsettings set org.gnome.desktop.interface font-name 'Inter 10'
        gsettings set org.gnome.desktop.interface document-font-name 'Inter 10'
        gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 10'
        gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Inter Semi-Bold 10'
        gsettings set org.gnome.desktop.interface text-scaling-factor 1.15
    fi
    
    echo -e "  ${GREEN}✓${NC} Font parameters and 1.15 (115%) scaling factor applied successfully."
else
    echo -e "  ${YELLOW}!${NC} gsettings not found. Font changes were not applied automatically."
fi

# 4. Cleaning up old configuration conflicts
echo -e "\n${BLUE}[4/6] Checking for system configuration conflicts...${NC}"
if [ -f /etc/fonts/local.conf ]; then
    # Check if /etc/fonts/local.conf has syntax error
    if fc-list : family 2>&1 | grep -q "syntax error"; then
        echo -e "  ${RED}${BOLD}WARNING:${NC} A broken /etc/fonts/local.conf file was detected."
        echo -e "  This file contains Xft settings in plain text, which causes Fontconfig to crash/throw errors."
        echo -e "  To fix this syntax error, run the following command in a terminal:"
        echo -e "  ${BOLD}sudo rm -f /etc/fonts/local.conf${NC}"
    else
        echo -e "  No active Fontconfig syntax errors detected."
    fi
else
    echo -e "  No conflicting global local.conf found."
fi

# 5. Patching and compiling ELAN SPI fingerprint driver for press/tap support
echo -e "\n${BLUE}[5/6] Checking and patching ELAN SPI fingerprint driver...${NC}"
LIBFPRINT_DIR="$HOME/libfprint-mincrmatt12"
if [ -d "$LIBFPRINT_DIR" ]; then
    echo -e "  Found custom libfprint repository at $LIBFPRINT_DIR."
    DRIVER_FILE="$LIBFPRINT_DIR/libfprint/drivers/elanspi.c"
    if [ -f "$DRIVER_FILE" ]; then
        echo -e "  Patching elanspi.c to use press/tap mode..."
        sed -i 's/dev_class->scan_type = FP_SCAN_TYPE_SWIPE;/dev_class->scan_type = FP_SCAN_TYPE_PRESS;/g' "$DRIVER_FILE"
        
        echo -e "  Compiling patched libfprint..."
        ninja -C "$LIBFPRINT_DIR/build" >/dev/null
        
        echo -e "  Installing patched libfprint (requires sudo)..."
        sudo ninja -C "$LIBFPRINT_DIR/build" install >/dev/null
        
        echo -e "  Restarting fprintd service..."
        sudo systemctl restart fprintd || true
        echo -e "  ${GREEN}✓${NC} Patched ELAN SPI fingerprint driver compiled and installed successfully."
    else
        echo -e "  ${YELLOW}!${NC} Could not find elanspi.c at $DRIVER_FILE."
    fi
else
    echo -e "  ${YELLOW}!${NC} Custom libfprint repository not found at $LIBFPRINT_DIR. Skipping fingerprint driver patch."
fi

# 6. Refreshing caches and applying changes
echo -e "\n${BLUE}[6/6] Refreshing display and font configurations...${NC}"
echo -e "  Rebuilding font cache..."
fc-cache -fv >/dev/null || true

echo -e "  Applying active screen parameters (RGB Full and Contrast Gamma)..."
# Trigger the autostart script to apply display settings immediately
if [ -f "$HOME/.config/autostart/apply-display-vibe.sh" ]; then
    bash "$HOME/.config/autostart/apply-display-vibe.sh" || true
fi

echo -e "\n${GREEN}${BOLD}====================================================${NC}"
echo -e "${GREEN}${BOLD}      Installation Completed Successfully!          ${NC}"
echo -e "${GREEN}${BOLD}====================================================${NC}"
echo -e "Please log out and log back in to ensure all changes (especially fonts) take full effect."
