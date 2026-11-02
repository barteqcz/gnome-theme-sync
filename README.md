# GNOME Theme Sync

Automatically synchronizes GTK3 and Papirus icon themes with GNOME's light/dark mode preference.

## Features

- GTK3 theme and icon theme synchronization with the dark/light GNOME theme.
- Runs automatically at GNOME login.
- Installs a global systemd user service for all users.

## Requirements

- GNOME Desktop
- `systemd`
- The GTK3 theme you want to use and the icon theme you want to use

## Installation

Run the following command in your terminal:

```bash
wget -qO- https://raw.githubusercontent.com/barteqcz/gnome-theme-sync/main/install.sh | sudo bash
```

## Theme Mapping

| Appearance | GTK3 Theme | Icon Theme |
|---|---|---|
| Light | `adw-gtk3` | `Papirus-Light` |
| Dark | `adw-gtk3-dark` | `Papirus-Dark` |

If you wish to use a different icon theme, or a different GTK3 theme, change these:
```
LIGHT_GTK="adw-gtk3"
DARK_GTK="adw-gtk3-dark"
LIGHT_ICONS="Papirus-Light"
DARK_ICONS="Papirus-Dark"
```
To whatever you want to use.
 
## Service Management

Check service status:

```bash
systemctl --user status gnome-theme-sync
```

Stop the service:

```bash
systemctl --user stop gnome-theme-sync
```

Restart the service:

```bash
systemctl --user restart gnome-theme-sync
```

## Uninstallation

```bash
systemctl --global disable gnome-theme-sync.service
sudo rm /etc/systemd/user/gnome-theme-sync.service
sudo rm /usr/local/bin/gnome-theme-sync
```

## Notes

- Installation requires root privileges.
- Synchronization runs independently for each user.
- Required themes must be installed separately.
- The service starts automatically when users log into GNOME.
