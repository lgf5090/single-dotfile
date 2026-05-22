# Foot Configuration

This configuration replicates the wezterm setup with:
- Catppuccin Mocha theme
- Hack Nerd Font (12pt)
- 95% opacity
- 1200x600px initial window size (≈120x30 chars)
- Fish shell as default

## Installation

1. Install foot: `sudo apt install foot` (Ubuntu/Debian) or equivalent
2. The configuration will be loaded from `~/.config/foot/foot.ini`

## Shell Configuration

The default shell is set to fish. To change this, edit the `foot.ini` file:

```ini
[main]
shell = /bin/bash  # or /usr/bin/zsh, /usr/bin/fish, etc.
```

## Platform Support

Foot is primarily designed for Wayland on Linux. For X11, consider using a different terminal emulator from this collection.

## Features

- Excellent performance on Wayland
- Low memory usage
- Good font rendering
- URL detection and launching

## Keybindings

- Alt+F: Toggle fullscreen
- Alt+Q: Quit
- Ctrl+Shift+C: Copy
- Ctrl+Shift+V: Paste
- Shift+Page Up/Down: Scroll