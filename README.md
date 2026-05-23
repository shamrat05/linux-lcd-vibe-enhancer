# 🌟 Linux LCD Vibe Enhancer

AMOLED-like contrast tuning, DCI-P3 wide-gamut calibration, and ultra-crisp font rendering configurations for ASUS VivoBook and other Linux-based LCD displays.

If your LCD screen looks washed out, has poor contrast, or features blurry text that causes eye strain, this optimizer configures a premium, eye-friendly display setup.

---

## ✨ Features

### 📺 1. AMOLED Vibe Display Settings
* **Full RGB Range**: Overrides the GPU's default "Automatic" range setting to guarantee a full `0-255` digital dynamic range. This eliminates washed-out, grayish blacks.
* **Gamma Calibration (0.90)**: Calibrates the screen's gamma curve to `0.90`. This deepens shadow details and increases contrast, giving your LCD screen a punchy, vibrant "AMOLED feel."
* **System-Wide Startup persistence**: Installs an autostart daemon to apply these display parameters every time you boot.

### 🎨 2. ASUS DCI-P3 Color Calibrations
* Integrates calibrated wide-gamut ICC profiles (`ASUS_DCIP3.icm` and `ASUS_DisplayP3.icm`) dynamically with the system color daemon (`colord`) for optimal, professional color reproduction.

### 🔠 3. Ultra-Legible Font Rendering
* **Premium UI Fonts**: Switches the default desktop UI font to **Inter** (regular & semi-bold) and the terminal/coding font to **JetBrains Mono**.
* **Pixel-Density Scaling (1.15 / 115%)**: Calibrated to match the physical DPI of a 15.6" 1080p screen (~141 DPI). Text becomes incredibly readable without reducing screen real estate too much.
* **Subpixel RGB Antialiasing**: Configures subpixel RGBA rendering and slight font hinting to maximize text sharpness.

---

## 📂 Repository Structure

```
linux-lcd-vibe-enhancer/
├── install.sh              # Automated script to set up everything
├── uninstall.sh            # Reverts all settings back to Linux defaults
├── README.md               # Documentation guide
├── config/
│   ├── autostart/          # Autostart scripts to persist gamma/RGB changes
│   │   ├── apply-display-vibe.sh
│   │   └── display-vibe.desktop
│   └── fontconfig/         # Font antialiasing settings
│       └── fonts.conf
└── icc/                    # Calibrated ICC color profiles
    ├── ASUS_DCIP3.icm
    ├── ASUS_DisplayP3.icm
    └── ASUS_sRGB.icm
```

---

## 🚀 Quick Start / Installation

Clone this repository and run the installer:

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/linux-lcd-vibe-enhancer.git
cd linux-lcd-vibe-enhancer
./install.sh
```

### ⚠️ Pre-requisites & Troubleshooting

#### 1. System Requirements
* Designed for **X11 display server sessions** (utilizes `xrandr` and `xgamma`).
* Native settings support for **Cinnamon** and **GNOME** desktop environments (Linux Mint, Ubuntu, Debian, etc.).

#### 2. Fixing Fontconfig Syntax Errors
If your system terminal warns you with `Fontconfig error: "/etc/fonts/local.conf", line 1: syntax error`, it means a legacy/broken configuration is present. Clean it up with:
```bash
sudo rm -f /etc/fonts/local.conf
```
*(The local user font settings inside this repository do not require sudo and will take precedence.)*

---

## 🔄 Uninstallation

If you ever wish to revert all display settings, gamma levels, font parameters, and scaling values back to Mint/Linux out-of-the-box defaults, simply run:

```bash
./uninstall.sh
```

---

## 📄 License
This project is open-source and free to share and modify. Customize the gamma value in `config/autostart/apply-display-vibe.sh` to match your personal screen preferences!
