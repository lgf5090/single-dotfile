# ST (Simple Terminal) Configuration

This configuration is based on the wezterm setup and provides:
- Catppuccin Mocha theme
- Hack Nerd Font with fallbacks
- 95% opacity
- 120x30 initial window size
- Custom keybindings

## Installation

1. Clone the st source code:
   ```bash
   git clone https://git.suckless.org/st
   cd st
   ```

2. Copy this config.h to the st source directory:
   ```bash
   cp ~/.config/st/config.h .
   ```

3. Compile and install:
   ```bash
   sudo make clean install
   ```

## Notes

- ST requires recompilation for configuration changes
- Make sure you have the Hack Nerd Font installed
- The alpha transparency requires a compositor like picom
- Default shell is set to fish (change in config.h if needed)

## Keybindings

- Alt+F: Toggle fullscreen
- Alt+Q: Quit
- Ctrl+Shift+C: Copy
- Ctrl+Shift+V: Paste