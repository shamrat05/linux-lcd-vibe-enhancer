#!/usr/bin/env bash
# ==============================================================================
# Linux LCD Vibe Enhancer - Uninstaller Script
# Restores default system settings for display, color, and fonts
# ==============================================================================

set -euo pipefail

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${YELLOW}${BOLD}====================================================${NC}"
echo -e "${YELLOW}${BOLD}      Uninstalling Linux LCD Vibe Enhancer...       ${NC}"
echo -e "${YELLOW}${BOLD}====================================================${NC}"

# 1. Removing local configuration files
echo -e "\n${BLUE}[1/4] Removing configuration files...${NC}"

# Remove autostart script and entry
if [ -f "$HOME/.config/autostart/apply-display-vibe.sh" ]; then
    rm -f "$HOME/.config/autostart/apply-display-vibe.sh"
fi
if [ -f "$HOME/.config/autostart/display-vibe.desktop" ]; then
    rm -f "$HOME/.config/autostart/display-vibe.desktop"
fi
echo -e "  ${GREEN}✓${NC} Autostart display tuner removed."

# Remove local font config
if [ -f "$HOME/.config/fontconfig/fonts.conf" ]; then
    rm -f "$HOME/.config/fontconfig/fonts.conf"
fi
echo -e "  ${GREEN}✓${NC} Local fontconfig settings removed."

# Remove Xresources
if [ -f "$HOME/.Xresources" ]; then
    rm -f "$HOME/.Xresources"
    if command -v xrdb >/dev/null 2>&1; then
        echo "" | xrdb -load || true
    fi
    echo -e "  ${GREEN}✓${NC} Local Xresources configuration removed."
fi

# Keep ICC files in local share but we won't delete them as they are useful.

# 2. Resetting active display settings
echo -e "\n${BLUE}[2/4] Resetting display contrast and color range...${NC}"
if command -v xrandr >/dev/null 2>&1; then
    xrandr --output eDP-1-1 --set "Broadcast RGB" "Automatic" 2>/dev/null || true
    xgamma -gamma 1.0 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Display RGB range and gamma reset to system default (1.0)."
else
    echo -e "  ${YELLOW}!${NC} xrandr not found. Display settings could not be reset."
fi

# 3. Resetting default color profile
echo -e "\n${BLUE}[3/4] Resetting system color profile...${NC}"
if command -v colormgr >/dev/null 2>&1; then
    DEVICE_ID=$(colormgr get-devices | grep -E -A 10 "Type:[[:space:]]*display" | grep "Device ID:" | head -n 1 | awk -F': ' '{print $2}' | xargs || true)
    
    if [ -n "$DEVICE_ID" ]; then
        # Try to find default EDID profile or fallback
        EDID_PROFILE=$(colormgr get-profiles | grep -E -B 2 -A 5 -i "edid" | grep "Profile ID:" | head -n 1 | awk -F': ' '{print $2}' | xargs || true)
        
        if [ -n "$EDID_PROFILE" ]; then
            colormgr device-make-profile-default "$DEVICE_ID" "$EDID_PROFILE" && \
                echo -e "  ${GREEN}✓${NC} Reset system color profile to default EDID profile." || \
                echo -e "  ${YELLOW}!${NC} Failed to make EDID profile default automatically."
        else
            echo -e "  ${YELLOW}!${NC} Could not locate default EDID profile in colord."
        fi
    fi
fi

# 4. Resetting font settings
echo -e "\n${BLUE}[4/4] Restoring original system fonts and scaling...${NC}"
if command -v gsettings >/dev/null 2>&1; then
    # Reset Cinnamon desktop interface settings
    if gsettings list-schemas | grep -q "org.cinnamon.desktop.interface"; then
        gsettings set org.cinnamon.desktop.interface font-name 'Noto Sans 11'
        gsettings set org.cinnamon.desktop.wm.preferences titlebar-font 'Ubuntu Medium 10'
        gsettings set org.nemo.desktop font 'Ubuntu 12'
        gsettings set org.cinnamon.desktop.interface text-scaling-factor 1.0
        
        # Reset defaults
        gsettings set org.cinnamon.settings-daemon.plugins.xsettings antialiasing 'rgba'
        gsettings set org.cinnamon.settings-daemon.plugins.xsettings hinting 'slight'
        gsettings set org.cinnamon.settings-daemon.plugins.xsettings rgba-order 'rgb'

        # Reset animations to traditional
        gsettings set org.cinnamon desktop-effects-close 'traditional'
        gsettings set org.cinnamon desktop-effects-map 'traditional'
        gsettings set org.cinnamon desktop-effects-minimize 'traditional'

        # Reset theme borders to Mint-Y
        gsettings set org.cinnamon.desktop.wm.preferences theme 'Mint-Y'

        # Reset Tilix shortcuts
        if gsettings list-schemas | grep -q "com.gexperts.Tilix.Keybindings"; then
            gsettings set com.gexperts.Tilix.Keybindings terminal-copy '<Ctrl><Shift>c'
            gsettings set com.gexperts.Tilix.Keybindings terminal-paste '<Ctrl><Shift>v'
        fi

        # Reset system keybindings back to defaults
        gsettings set org.cinnamon.desktop.keybindings.wm panel-run-dialog "['<Alt>F2']"
        gsettings set org.cinnamon.desktop.keybindings looking-glass-keybinding "['<Super>l']"
        gsettings set org.cinnamon.desktop.keybindings.media-keys screensaver "['<Control><Alt>l', 'XF86ScreenSaver']"
        gsettings set org.cinnamon.desktop.keybindings custom-list "['custom0', 'custom1']"
    fi
    
    # Reset GNOME desktop interface settings
    if gsettings list-schemas | grep -q "org.gnome.desktop.interface"; then
        gsettings set org.gnome.desktop.interface font-name 'Noto Sans 11'
        gsettings set org.gnome.desktop.interface document-font-name 'Sans 20'
        gsettings set org.gnome.desktop.interface monospace-font-name 'DejaVu Sans Mono 10'
        gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Ubuntu Medium 10'
        gsettings set org.gnome.desktop.interface text-scaling-factor 1.0
    fi
    echo -e "  ${GREEN}✓${NC} Reset fonts and text scaling back to system defaults (Noto Sans, 1.0x)."
fi

# Rebuild font cache
fc-cache -fv >/dev/null || true

echo -e "\n${GREEN}${BOLD}====================================================${NC}"
echo -e "${GREEN}${BOLD}      Uninstallation Completed Successfully!        ${NC}"
echo -e "${GREEN}${BOLD}====================================================${NC}"
echo -e "Please log out and log back in to ensure all settings refresh fully."
