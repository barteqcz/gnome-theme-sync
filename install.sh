#!/usr/bin/env bash
set -euo pipefail

# Ensure script is executed with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run this installation script with sudo or as root." >&2
    exit 1
fi

SCRIPT_PATH="/usr/local/bin/gnome-theme-sync"
SERVICE_PATH="/etc/systemd/user/gnome-theme-sync.service"

echo "Installing executable to ${SCRIPT_PATH}..."
cat << 'EOF' > "$SCRIPT_PATH"
#!/usr/bin/env bash
# Keeps the GTK3 theme and icon theme in sync with GNOME's light/dark preference.
set -euo pipefail

SCHEMA="org.gnome.desktop.interface"

LIGHT_GTK="adw-gtk3"
DARK_GTK="adw-gtk3-dark"
LIGHT_ICONS="Papirus-Light"
DARK_ICONS="Papirus-Dark"

apply_theme() {
    local scheme gtk_theme icon_theme

    scheme=$(gsettings get "$SCHEMA" color-scheme)

    # color-scheme is 'default', 'prefer-dark' or 'prefer-light'
    if [[ "$scheme" == *prefer-dark* ]]; then
        gtk_theme="$DARK_GTK"
        icon_theme="$DARK_ICONS"
    else
        gtk_theme="$LIGHT_GTK"
        icon_theme="$LIGHT_ICONS"
    fi

    # Only write when the value actually differs, to avoid needless churn
    [[ "$(gsettings get "$SCHEMA" gtk-theme)" == "'$gtk_theme'" ]] ||
        gsettings set "$SCHEMA" gtk-theme "$gtk_theme"
    [[ "$(gsettings get "$SCHEMA" icon-theme)" == "'$icon_theme'" ]] ||
        gsettings set "$SCHEMA" icon-theme "$icon_theme"
}

# Apply once at startup so the themes match the current setting
apply_theme

# Then react to every change of color-scheme
gsettings monitor "$SCHEMA" color-scheme | while read -r _; do
    apply_theme
done
EOF

chmod 755 "$SCRIPT_PATH"

echo "Installing system-wide user service to ${SERVICE_PATH}..."
cat << 'EOF' > "$SERVICE_PATH"
[Unit]
Description=Sync GTK3 and icon themes with GNOME light/dark preference
PartOf=graphical-session.target
After=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/local/bin/gnome-theme-sync
Restart=on-failure
RestartSec=3

[Install]
WantedBy=graphical-session.target
EOF

chmod 644 "$SERVICE_PATH"

echo "Enabling service system-wide for all users..."
systemctl --global enable gnome-theme-sync.service

echo "Installation complete! The theme sync service is now active for all existing and new users upon login."
