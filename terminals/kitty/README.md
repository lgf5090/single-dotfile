# Kitty Configuration

This configuration mirrors the wezterm setup featuring:
- Catppuccin Mocha theme
- Hack Nerd Font with symbol mapping
- 95% opacity, no window decorations
- 120x30 initial window size
- Powerline-style tabs

## Shell Integration

Kitty's shell integration is enabled by default. For different shells:

### Fish (default)
Already configured in kitty.conf

### Zsh
Add to your .zshrc:
```bash
if [[ "$TERM" == "xterm-kitty" ]]; then
    alias ssh="kitty +kitten ssh"
fi
```

### Windows PowerShell
Edit kitty.conf and change:
```
shell pwsh.exe -NoExit -NoLogo
```

## Features

- Alt+F: Toggle fullscreen
- Alt+T: New tab
- Alt+Q: Quit
- Alt+\: Horizontal split
- Alt+Enter: Vertical split
- Powerline tab style with process names

```md
tab_title_template
tab_title_template "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{tab.last_focused_progress_percent}{title}"
A template to render the tab title. The default just renders the title with optional symbols for bell and activity. If you wish to include the tab-index as well, use something like: {index}:{title}. Useful if you have shortcuts mapped for goto_tab N. If you prefer to see the index as a superscript, use {sup.index}. All data available is:

title
The current tab title.

index
The tab index usable with goto_tab N shortcuts.

layout_name
The current layout name.

session_name
The name of the kitty session file from which this tab was created, if any.

active_session_name
The name of the kitty session file from which the active window in this tab was created, if any.

num_windows
The number of windows in the tab.

num_window_groups
The number of window groups (a window group is a window and all of its overlay windows) in the tab.

tab.active_wd
The working directory of the currently active window in the tab (expensive, requires syscall). Use tab.active_oldest_wd to get the directory of the oldest foreground process rather than the newest.

tab.active_exe
The name of the executable running in the foreground of the currently active window in the tab (expensive, requires syscall). Use tab.active_oldest_exe for the oldest foreground process.

max_title_length
The maximum title length available.

keyboard_mode
The name of the current keyboard mode or the empty string if no keyboard mode is active.

tab.last_focused_progress_percent
If a command running in a window reports the progress for a task, show this progress as a percentage from the most recently focused window in the tab. Empty string if no progress is reported.

tab.progress_percent
If a command running in a window reports the progress for a task, show this progress as a percentage from all windows in the tab, averaged. Empty string is no progress is reported.

custom
This will call a function named draw_title(data) from the file tab_bar.py placed in the kitty config directory. The function will be passed a dictionary of data, the same data that can be used in this template. It can then perform arbitrarily complex processing and return a string. For example: tab_title_template "{custom}" will use the output of the function as the tab title. Any print statements in the draw_title() will print to the STDOUT of the kitty process, useful for debugging.

Note that formatting is done by Python’s string formatting machinery, so you can use, for instance, {layout_name[:2].upper()} to show only the first two letters of the layout name, upper-cased. If you want to style the text, you can use styling directives, for example: {fmt.fg.red}red{fmt.fg.tab}normal{fmt.bg._00FF00}greenbg{fmt.bg.tab}. Similarly, for bold and italic: {fmt.bold}bold{fmt.nobold}normal{fmt.italic}italic{fmt.noitalic}. The 256 eight terminal colors can be used as fmt.fg.color0 through fmt.fg.color255. Note that for backward compatibility, if {bell_symbol} or {activity_symbol} are not present in the template, they are prepended to it.

active_tab_title_template
active_tab_title_template none
Template to use for active tabs. If not specified falls back to tab_title_template.

active_tab_foreground, active_tab_background, active_tab_font_style, inactive_tab_foreground, inactive_tab_background, inactive_tab_font_style
active_tab_foreground   #000
active_tab_background   #eee
active_tab_font_style   bold-italic
inactive_tab_foreground #444
inactive_tab_background #999
inactive_tab_font_style normal
Tab bar colors and styles.

tab_bar_background
tab_bar_background none
Background color for the tab bar. Defaults to using the terminal background color.

tab_bar_margin_color
tab_bar_margin_color none
Color for the tab bar margin area. Defaults to using the terminal background color for margins above and below the tab bar. For side margins the default color is chosen to match the background color of the neighboring tab.
```