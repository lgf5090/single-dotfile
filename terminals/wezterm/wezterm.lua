local wezterm = require 'wezterm'
local config  = wezterm.config_builder()

-- ============================================================
-- 平台检测
-- ============================================================
local is_windows = wezterm.target_triple == 'x86_64-pc-windows-msvc'
local is_linux   = wezterm.target_triple:find('linux') ~= nil
local is_darwin  = wezterm.target_triple:find('darwin') ~= nil

-- ============================================================
-- 工具函数（Unix/macOS 专用）
-- ============================================================

--- 在 PATH 中查找命令的完整路径
local function which(cmd)
    local h = io.popen('which ' .. cmd .. ' 2>/dev/null')
    if not h then return nil end
    local p = h:read('*l')
    h:close()
    return (p and p ~= '') and p or nil
end

--- 检查绝对路径文件是否可读
local function file_exists(path)
    local f = io.open(path, 'r')
    if f then f:close(); return true end
    return false
end

--- 检查可执行文件是否可用（绝对路径或命令名均可）
local function executable(path)
    return path:sub(1, 1) == '/' and file_exists(path) or which(path) ~= nil
end

-- ============================================================
-- 启动时窗口居中
-- ============================================================
wezterm.on('gui-startup', function(cmd)
    local _, _, win = wezterm.mux.spawn_window(cmd or {})
    local gui = win:gui_window()
    local scr = wezterm.gui.screens().active
    local w   = math.floor(scr.width  * 0.6)
    local h   = math.floor(scr.height * 0.6)
    gui:set_inner_size(w, h)
    gui:set_position(
        math.floor((scr.width  - w) / 2),
        math.floor((scr.height - h) / 2)
    )
end)

-- ============================================================
-- 外观
-- ============================================================
config.color_scheme = 'Catppuccin Mocha'

config.font = wezterm.font_with_fallback {
    'Hack Nerd Font',
    'JetBrains Mono',
    'DejaVu Sans Mono',
    'Courier New',
}
config.font_size = 12.0

-- 光标：闪烁竖线，匀速闪烁
config.default_cursor_style  = 'BlinkingBar'
config.cursor_blink_rate     = 500   -- ms
config.cursor_blink_ease_in  = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- 关闭响铃
config.audible_bell = 'Disabled'

-- ============================================================
-- 窗口
-- ============================================================
config.window_decorations        = 'NONE'
config.window_background_opacity = 0.95
config.window_padding            = { left = 10, right = 10, top = 10, bottom = 10 }
config.initial_cols              = 120
config.initial_rows              = 30
config.scrollback_lines          = 10000   -- 滚动缓冲区行数
config.window_close_confirmation = 'NeverPrompt'
config.exit_behavior             = 'Close'
config.exit_behavior_messaging   = 'None'

-- ============================================================
-- 标签页
-- ============================================================
config.use_fancy_tab_bar            = true
config.tab_bar_at_bottom            = false
config.hide_tab_bar_if_only_one_tab = false

wezterm.on('format-tab-title', function(tab)
    local proc = tab.active_pane.foreground_process_name or 'shell'
    local name = proc:match('([^/\\]+)$') or proc
    return { { Text = string.format(' %d: %s ', tab.tab_index + 1, name) } }
end)

-- ============================================================
-- 忽略关闭确认的进程
-- ============================================================
config.skip_close_confirmation_for_processes_named = {
    -- Unix Shells
    'bash', 'bash.exe', 'zsh',  'zsh.exe',  'fish', 'fish.exe',
    'sh',   'sh.exe',   'dash', 'dash.exe',  'ash',  'ash.exe',
    'ksh',  'ksh.exe',  'csh',  'csh.exe',   'tcsh', 'tcsh.exe',
    'nu',   'nu.exe',   'elvish', 'elvish.exe',
    -- Windows Shells
    'pwsh', 'pwsh.exe', 'powershell', 'powershell.exe', 'cmd', 'cmd.exe',
    -- Terminal Multiplexers
    'tmux',   'tmux.exe',   'screen', 'screen.exe',
    'zellij', 'zellij.exe', 'byobu',  'byobu.exe',
    -- Remote
    'ssh',    'ssh.exe',    'mosh',   'mosh.exe',
    'ftp',    'ftp.exe',    'sftp',   'sftp.exe',
    'scp',    'scp.exe',    'rsync',  'rsync.exe',
    'telnet', 'telnet.exe',
    -- Editors
    'vim',     'vim.exe',     'nvim',    'nvim.exe',
    'emacs',   'emacs.exe',   'nano',    'nano.exe',    'micro', 'micro.exe',
    'helix',   'helix.exe',   'hx',      'hx.exe',
    'kakoune', 'kakoune.exe', 'kak',     'kak.exe',
    -- Python
    'python',  'python.exe',  'python3', 'python3.exe',
    'ipython', 'ipython.exe', 'jupyter', 'jupyter.exe',
    -- JavaScript / TypeScript
    'node', 'node.exe', 'deno', 'deno.exe', 'bun', 'bun.exe',
    -- Other REPLs
    'ghci',    'ghci.exe',    'irb',    'irb.exe',
    'ruby',    'ruby.exe',    'lua',    'lua.exe',
    'php',     'php.exe',     'perl',   'perl.exe',
    'R',       'R.exe',       'julia',  'julia.exe',
    'scala',   'scala.exe',   'racket', 'racket.exe',
    'clojure', 'clojure.exe', 'clj',    'clj.exe',
    -- Databases
    'mysql',     'mysql.exe',     'psql',      'psql.exe',
    'sqlite3',   'sqlite3.exe',   'mongosh',   'mongosh.exe',
    'mongo',     'mongo.exe',     'redis-cli', 'redis-cli.exe',
    -- Containers / Orchestration
    'docker',  'docker.exe',  'podman',  'podman.exe',
    'kubectl', 'kubectl.exe', 'helm',    'helm.exe',
    -- VCS & Git TUIs
    'git', 'git.exe', 'tig',     'tig.exe',
    'lazygit', 'lazygit.exe', 'gitui', 'gitui.exe',
    -- Build & Package Managers
    'make',  'make.exe',  'cmake', 'cmake.exe',
    'cargo', 'cargo.exe', 'npm',   'npm.exe',
    'yarn',  'yarn.exe',  'pnpm',  'pnpm.exe',
    'pip',   'pip.exe',   'conda', 'conda.exe', 'mamba', 'mamba.exe',
    -- System Monitors
    'htop',    'htop.exe',    'btop',    'btop.exe',
    'top',     'top.exe',     'iotop',   'iotop.exe',
    'iftop',   'iftop.exe',   'nethogs', 'nethogs.exe',
    'glances', 'glances.exe',
    -- File Managers
    'ranger', 'ranger.exe', 'lf',   'lf.exe',
    'nnn',    'nnn.exe',    'mc',   'mc.exe',
    'vifm',   'vifm.exe',   'yazi', 'yazi.exe',
    -- Modern CLI Replacements
    'bat',   'bat.exe',   'eza',   'eza.exe',   'exa',   'exa.exe',
    'fd',    'fd.exe',    'rg',    'rg.exe',    'fzf',   'fzf.exe',
    'ag',    'ag.exe',    'jq',    'jq.exe',    'yq',    'yq.exe',
    'delta', 'delta.exe', 'procs', 'procs.exe', 'dust',  'dust.exe',
    'duf',   'duf.exe',
    'lazydocker', 'lazydocker.exe',
    -- Dotfile Managers
    'chezmoi', 'chezmoi.exe', 'stow', 'stow.exe',
    -- WSL
    'wsl', 'wsl.exe', 'wsl2', 'wsl2.exe',
    -- Pagers & Text Tools
    'less',  'less.exe',  'more',  'more.exe',  'man',   'man.exe',
    'info',  'info.exe',  'watch', 'watch.exe',
    'grep',  'grep.exe',  'sed',   'sed.exe',   'awk',   'awk.exe',
    'tail',  'tail.exe',  'head',  'head.exe',
    'sort',  'sort.exe',  'uniq',  'uniq.exe',  'wc',    'wc.exe',
    -- Network & Download
    'curl',     'curl.exe',     'wget',     'wget.exe',
    'aria2c',   'aria2c.exe',   'ping',     'ping.exe',
    'dig',      'dig.exe',      'nslookup', 'nslookup.exe',
    -- Dev Servers
    'serve',       'serve.exe',
    'http-server', 'http-server.exe',
    'live-server', 'live-server.exe',
}

-- ============================================================
-- Shell 与启动菜单
-- ============================================================
if is_windows then
    local profile = os.getenv('USERPROFILE') or ''

    config.default_prog = { 'pwsh.exe', '-NoExit', '-NoLogo' }
    config.launch_menu  = {
        { label = 'PowerShell Core', args = { 'pwsh.exe',       '-NoExit', '-NoLogo' } },
        { label = 'PowerShell',      args = { 'powershell.exe', '-NoExit', '-NoLogo' } },
        { label = 'Command Prompt',  args = { 'cmd.exe' } },
        { label = 'Nushell',         args = { 'nu.exe' } },
        { label = 'Nushell (cargo)', args = { profile .. '\\.cargo\\bin\\nu.exe' } },
        { label = 'Git Bash',        args = { 'C:\\Program Files\\Git\\bin\\bash.exe', '-i', '-l' } },
        { label = 'MSYS2 Bash',      args = { 'C:\\msys64\\usr\\bin\\bash.exe',        '-i', '-l' } },
        { label = 'Cygwin Bash',     args = { 'C:\\cygwin64\\bin\\bash.exe',           '-i', '-l' } },
    }

else
    -- Unix / macOS 平台

    -- 按优先级自动选择默认 shell
    local function find_default_shell()
        local order = is_darwin and { 'zsh', 'bash', 'fish' } or { 'bash', 'zsh', 'fish' }
        for _, sh in ipairs(order) do
            local p = which(sh)
            if p then return p end
        end
        return is_darwin and 'zsh' or 'bash'  -- 兜底值
    end

    config.default_prog = { find_default_shell(), '-i', '-l' }

    -- 检测 Homebrew 安装前缀（按常见路径优先级）
    local brew_prefix
    for _, p in ipairs { '/opt/homebrew', '/usr/local', '/home/linuxbrew/.linuxbrew' } do
        if file_exists(p .. '/bin/brew') then
            brew_prefix = p
            break
        end
    end

    -- 动态构建启动菜单（跳过未安装的 shell）
    local menu = {}
    local home  = os.getenv('HOME') or ''

    local function add(label, args)
        if executable(args[1]) then
            menu[#menu + 1] = { label = label, args = args }
        end
    end

    -- 系统 PATH 中的 shell
    add('Bash',            { 'bash', '-i', '-l' })
    add('Zsh',             { 'zsh',  '-i', '-l' })
    add('Fish',            { 'fish', '-i', '-l' })
    add('Nushell',         { 'nu' })
    add('PowerShell Core', { 'pwsh' })
    add('Nushell (cargo)', { home .. '/.cargo/bin/nu' })

    -- Homebrew 提供的 shell（若检测到 brew 则追加）
    if brew_prefix then
        local suffix = ({
            ['/opt/homebrew']              = 'homebrew',
            ['/usr/local']                 = 'homebrew',
            ['/home/linuxbrew/.linuxbrew'] = 'linuxbrew',
        })[brew_prefix] or 'brew'
        local bp = brew_prefix
        add(string.format('Bash  (%s)', suffix), { bp .. '/bin/bash',  '-i', '-l' })
        add(string.format('Zsh   (%s)', suffix), { bp .. '/bin/zsh',   '-i', '-l' })
        add(string.format('Fish  (%s)', suffix), { bp .. '/bin/fish',  '-i', '-l' })
        add(string.format('Nu    (%s)', suffix), { bp .. '/bin/nu' })
        add(string.format('Pwsh  (%s)', suffix), { bp .. '/bin/pwsh' })
    end

    config.launch_menu = menu
end

-- ============================================================
-- 快捷键
-- ============================================================
local act = wezterm.action

config.keys = {
    -- 全屏切换
    { key = 'f',     mods = 'ALT',        action = act.ToggleFullScreen },

    -- 标签页
    { key = 't',     mods = 'ALT',        action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'w',     mods = 'ALT',        action = act.CloseCurrentPane { confirm = false } },
    { key = '[',     mods = 'ALT',        action = act.ActivateTabRelative(-1) },
    { key = ']',     mods = 'ALT',        action = act.ActivateTabRelative(1)  },
    -- 标签页直跳 ALT+1~9
    { key = '1', mods = 'ALT', action = act.ActivateTab(0) },
    { key = '2', mods = 'ALT', action = act.ActivateTab(1) },
    { key = '3', mods = 'ALT', action = act.ActivateTab(2) },
    { key = '4', mods = 'ALT', action = act.ActivateTab(3) },
    { key = '5', mods = 'ALT', action = act.ActivateTab(4) },
    { key = '6', mods = 'ALT', action = act.ActivateTab(5) },
    { key = '7', mods = 'ALT', action = act.ActivateTab(6) },
    { key = '8', mods = 'ALT', action = act.ActivateTab(7) },
    { key = '9', mods = 'ALT', action = act.ActivateTab(8) },

    -- 面板分割
    { key = '\\',    mods = 'ALT',        action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'Enter', mods = 'ALT',        action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },

    -- 面板导航 ALT+HJKL（Vim 风格）
    { key = 'h',     mods = 'ALT',        action = act.ActivatePaneDirection 'Left'  },
    { key = 'l',     mods = 'ALT',        action = act.ActivatePaneDirection 'Right' },
    { key = 'k',     mods = 'ALT',        action = act.ActivatePaneDirection 'Up'    },
    { key = 'j',     mods = 'ALT',        action = act.ActivatePaneDirection 'Down'  },

    -- 字体大小
    { key = '=',     mods = 'CTRL',       action = act.IncreaseFontSize },
    { key = '-',     mods = 'CTRL',       action = act.DecreaseFontSize },
    { key = '0',     mods = 'CTRL',       action = act.ResetFontSize    },

    -- 复制 / 粘贴
    { key = 'c',     mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard'    },
    { key = 'v',     mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },

    -- 退出应用
    { key = 'q',     mods = 'ALT',        action = act.QuitApplication },
    { key = 'q',     mods = 'CTRL|SHIFT', action = act.QuitApplication },
}

return config
