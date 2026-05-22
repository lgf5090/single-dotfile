# Alacritty Configuration

This configuration replicates the wezterm setup with:
- Catppuccin Mocha theme
- Hack Nerd Font (12pt)
- 95% opacity, no window decorations
- 120x30 initial window size
- Custom keybindings

## Shell Configuration

The default shell is set to fish. To change this based on your OS:

### Linux/macOS
Edit `alacritty.toml` and change the shell program:
```toml
[terminal.shell]
program = "/usr/bin/zsh"  # or "/bin/bash", "/usr/bin/fish", etc.
```

### Windows
```toml
[terminal.shell]
program = "pwsh.exe"
args = ["-NoExit", "-NoLogo"]
```

## Keybindings

- Alt+F: Toggle fullscreen
- Alt+T: New window
- Alt+Q: Quit
- Ctrl+Shift+Q: Quit
- Ctrl+Shift+C: Copy
- Ctrl+Shift+V: Paste