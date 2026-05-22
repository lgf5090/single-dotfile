# Ghostty Configuration

This configuration replicates the wezterm setup with:
- Catppuccin Mocha theme
- Hack Nerd Font (12pt)
- 95% opacity, no window decorations
- 120x30 initial window size
- Shell integration enabled

## Installation

1. Install Ghostty from: https://ghostty.org/
2. The configuration will be automatically loaded from `~/.config/ghostty/config`

## Shell Configuration

The shell integration is enabled by default. Ghostty will automatically detect your preferred shell, but you can specify one by adding to the config:

```
shell-integration-features = cursor,sudo,title
```

## Platform-specific Notes

### macOS
Ghostty integrates well with macOS and supports native features.

### Linux
Make sure you have a compositor for transparency effects.

### Windows
Ghostty has excellent Windows support with native performance.

## Keybindings

- Alt+F: Toggle fullscreen
- Alt+T: New tab
- Alt+Q: Quit
- Alt+\: Split right
- Alt+Enter: Split down