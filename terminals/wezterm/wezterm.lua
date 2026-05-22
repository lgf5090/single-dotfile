local wezterm = require 'wezterm'
local config = wezterm.config_builder()
-- 窗口居中显示
-- wezterm.on('gui-startup', function(cmd)
--   local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
--   local gui = window:gui_window()
  
--   -- 获取屏幕尺寸并居中显示
--   local screen = gui:get_appearance()
--   gui:set_position(1200, 700) -- 可根据需要调整偏移量
-- end)

-- 窗口居中显示
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  local gui_window = window:gui_window()
  
  -- 获取屏幕尺寸
  local screens = wezterm.gui.screens()
  local active_screen = screens["active"]
  
  -- 获取当前窗口尺寸
  local window_size = gui_window:get_dimensions()
  
  -- 计算居中位置（假设你想要窗口占据屏幕的80%宽度和高度）
  local target_width = math.floor(active_screen.width * 0.6)
  local target_height = math.floor(active_screen.height * 0.6)
  
  -- 或者使用固定字符尺寸计算窗口像素尺寸
  -- local cols = 120  -- 你的初始列数
  -- local rows = 35   -- 你的初始行数
  -- local cell_width = 9  -- 取决于你的字体大小，需要调整
  -- local cell_height = 18 -- 取决于你的字体大小，需要调整
  -- target_width = cols * cell_width
  -- target_height = rows * cell_height
  
  -- 计算居中坐标
  local x = math.floor((active_screen.width - target_width) / 2)
  local y = math.floor((active_screen.height - target_height) / 2)
  
  -- 设置窗口尺寸和位置
  gui_window:set_inner_size(target_width, target_height)
  gui_window:set_position(x, y)
end)

-- 检测操作系统
local is_windows = wezterm.target_triple == 'x86_64-pc-windows-msvc'
local is_linux = wezterm.target_triple:find("linux") ~= nil
local is_darwin = wezterm.target_triple:find("darwin") ~= nil

-- Catppuccin Mocha 主题
config.color_scheme = 'Catppuccin Mocha'

-- 字体配置
config.font = wezterm.font_with_fallback {
  'Hack Nerd Font',
  'JetBrains Mono',
  'DejaVu Sans Mono',
  'Courier New',
}
config.font_size = 12.0

-- 窗口配置
-- config.window:set_position(1000, 1000)
config.window_decorations = "NONE"
config.window_background_opacity = 0.95
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- 启动窗口大小和位置
config.initial_cols = 120
config.initial_rows = 30
config.window_close_confirmation = "NeverPrompt"

-- WezTerm 跳过关闭确认的进程名称配置
-- 当这些进程在运行时，关闭终端标签页不会显示确认对话框
config.skip_close_confirmation_for_processes_named = {
  -- ==================== Unix/Linux Shells ====================
  'bash',          -- Bourne Again SHell (最常用的Linux shell)
  'bash.exe',      -- Windows版的Bash (WSL或Git Bash)
  'zsh',           -- Z Shell (macOS默认shell，功能丰富的shell)
  'zsh.exe',       -- Windows版的Zsh
  'csh',           -- C Shell (类C语法的shell)
  'csh.exe',       -- Windows版的C Shell
  'tcsh',          -- TENEX C Shell (csh的增强版)
  'tcsh.exe',      -- Windows版的TC Shell
  'ksh',           -- Korn Shell (结合了sh和csh的特性)
  'ksh.exe',       -- Windows版的Korn Shell
  'fish',          -- Friendly Interactive SHell (用户友好的shell)
  'fish.exe',      -- Windows版的Fish shell
  'nu',            -- Nushell (现代的数据驱动shell)
  'nu.exe',        -- Windows版的Nushell
  'dash',          -- Debian Almquist Shell (轻量级POSIX shell)
  'dash.exe',      -- Windows版的Dash shell
  'ash',           -- Almquist Shell (轻量级shell)
  'ash.exe',       -- Windows版的Ash shell
  'sh',            -- POSIX shell (通常链接到其他shell)
  'sh.exe',        -- Windows版的POSIX shell
  'elvish',        -- 款颇具创新性的现代化命令行 Shell 和编程语言
  'elvish.exe',    -- Windows版的款颇具创新性的现代化命令行 Shell 和编程语言

  -- ==================== Windows Shells ====================
  'pwsh',          -- PowerShell Core (跨平台的PowerShell)
  'pwsh.exe',      -- Windows版的PowerShell Core
  'powershell',    -- Windows PowerShell (传统的PowerShell)
  'powershell.exe',-- Windows版的PowerShell
  'cmd',           -- Windows命令提示符
  'cmd.exe',       -- Windows命令提示符

  -- ==================== 终端多路复用器 ====================
  'tmux',          -- Terminal Multiplexer (终端会话管理)
  'tmux.exe',      -- Windows版的Tmux
  'screen',        -- GNU Screen (终端多路复用器)
  'screen.exe',    -- Windows版的Screen
  'zellij',        -- 现代的终端多路复用器 (Rust编写)
  'zellij.exe',    -- Windows版的Zellij
  'byobu',         -- Tmux和Screen的包装器
  'byobu.exe',     -- Windows版的Byobu

  -- ==================== 配置文件管理器 ====================
  'chezmoi',          -- chezmoi跨平台配置文件管理器
  'chezmoi.exe',      -- Windows版的chezmoi跨平台配置文件管理器
  'stow',             -- chezmoi-Unix Gun平台配置文件管理器

  -- ==================== 远程连接工具 ====================
  'ssh',           -- Secure Shell (安全远程登录)
  'ssh.exe',       -- Windows版的SSH
  'telnet',        -- Telnet协议客户端
  'telnet.exe',    -- Windows版的Telnet
  'ftp',           -- File Transfer Protocol客户端
  'ftp.exe',       -- Windows版的FTP
  'sftp',          -- SSH File Transfer Protocol客户端
  'sftp.exe',      -- Windows版的SFTP
  'scp',           -- Secure Copy Protocol (基于SSH的文件传输)
  'scp.exe',       -- Windows版的SCP
  'rsync',         -- 远程同步工具
  'rsync.exe',     -- Windows版的Rsync
  'mosh',          -- Mobile Shell (移动网络优化的远程shell)
  'mosh.exe',      -- Windows版的Mosh

  -- ==================== 子系统 ====================
  'wsl',           -- Windows Subsystem for Linux
  'wsl.exe',       -- Windows Subsystem for Linux
  'wsl2',          -- Windows Subsystem for Linux 2
  'wsl2.exe',      -- Windows Subsystem for Linux 2

  -- ==================== 文本编辑器 ====================
  'vim',           -- Vi IMproved (终端文本编辑器)
  'vim.exe',       -- Windows版的Vim
  'nvim',          -- Neovim (Vim的现代分支)
  'nvim.exe',      -- Windows版的Neovim
  'emacs',         -- Emacs (可扩展的文本编辑器)
  'emacs.exe',     -- Windows版的Emacs
  'nano',          -- Nano (简单的终端文本编辑器)
  'nano.exe',      -- Windows版的Nano
  'micro',         -- Micro (现代的终端文本编辑器)
  'micro.exe',     -- Windows版的Micro
  'helix',         -- Helix (现代模态文本编辑器)
  'hx',            -- Helix的简写命令
  'helix.exe',     -- Windows版的Helix
  'hx.exe',        -- Windows版的Helix简写
  'kakoune',       -- Kakoune (模态文本编辑器)
  'kak',           -- Kakoune的简写命令
  'kakoune.exe',   -- Windows版的Kakoune
  'kak.exe',       -- Windows版的Kakoune简写

  -- ==================== 编程语言REPL和解释器 ====================
  -- Python
  'python',        -- Python解释器
  'python.exe',    -- Windows版的Python
  'python3',       -- Python3解释器
  'python3.exe',   -- Windows版的Python3
  'ipython',       -- IPython (增强的Python shell)
  'ipython.exe',   -- Windows版的IPython
  'jupyter',       -- Jupyter Notebook
  'jupyter.exe',   -- Windows版的Jupyter

  -- JavaScript/TypeScript
  'node',          -- Node.js JavaScript运行时
  'node.exe',      -- Windows版的Node.js
  'deno',          -- Deno JavaScript/TypeScript运行时
  'deno.exe',      -- Windows版的Deno
  'bun',           -- Bun JavaScript运行时 (快速的all-in-one工具包)
  'bun.exe',       -- Windows版的Bun

  -- 其他语言
  'ghci',          -- Glasgow Haskell Compiler交互环境
  'ghci.exe',      -- Windows版的GHCi
  'irb',           -- Interactive Ruby (Ruby交互环境)
  'irb.exe',       -- Windows版的IRB
  'ruby',          -- Ruby解释器
  'ruby.exe',      -- Windows版的Ruby
  'lua',           -- Lua脚本语言解释器
  'lua.exe',       -- Windows版的Lua
  'php',           -- PHP命令行解释器
  'php.exe',       -- Windows版的PHP
  'perl',          -- Perl脚本语言解释器
  'perl.exe',      -- Windows版的Perl
  'R',             -- R统计计算语言
  'R.exe',         -- Windows版的R
  'julia',         -- Julia高性能科学计算语言
  'julia.exe',     -- Windows版的Julia
  'scala',         -- Scala编程语言REPL
  'scala.exe',     -- Windows版的Scala
  'clojure',       -- Clojure Lisp方言
  'clj',           -- Clojure命令行工具
  'clojure.exe',   -- Windows版的Clojure
  'clj.exe',       -- Windows版的Clojure CLI
  'racket',        -- Racket Lisp方言
  'racket.exe',    -- Windows版的Racket

  -- ==================== 数据库客户端 ====================
  'mysql',         -- MySQL命令行客户端
  'mysql.exe',     -- Windows版的MySQL客户端
  'psql',          -- PostgreSQL交互终端
  'psql.exe',      -- Windows版的PostgreSQL客户端
  'sqlite3',       -- SQLite数据库命令行工具
  'sqlite3.exe',   -- Windows版的SQLite3
  'mongo',         -- MongoDB Shell
  'mongo.exe',     -- Windows版的MongoDB Shell
  'mongosh',       -- MongoDB Shell (新版本)
  'mongosh.exe',   -- Windows版的MongoDB Shell (新版本)
  'redis-cli',     -- Redis命令行客户端
  'redis-cli.exe', -- Windows版的Redis CLI

  -- ==================== 容器和编排工具 ====================
  'docker',        -- Docker命令行接口
  'docker.exe',    -- Windows版的Docker CLI
  'kubectl',       -- Kubernetes命令行工具
  'kubectl.exe',   -- Windows版的Kubectl
  'helm',          -- Kubernetes包管理器
  'helm.exe',      -- Windows版的Helm
  'podman',        -- 无根容器引擎
  'podman.exe',    -- Windows版的Podman

  -- ==================== 版本控制工具 ====================
  'git',           -- Git版本控制系统
  'git.exe',       -- Windows版的Git
  'tig',           -- Git的文本界面
  'tig.exe',       -- Windows版的Tig
  'lazygit',       -- Git的终端UI
  'lazygit.exe',   -- Windows版的Lazygit
  'gitui',         -- 快速的Git终端UI (Rust编写)
  'gitui.exe',     -- Windows版的GitUI

  -- ==================== 构建工具和包管理器 ====================
  'make',          -- GNU Make构建工具
  'make.exe',      -- Windows版的Make
  'cmake',         -- 跨平台构建系统
  'cmake.exe',     -- Windows版的CMake
  'cargo',         -- Rust包管理器和构建工具
  'cargo.exe',     -- Windows版的Cargo
  'npm',           -- Node.js包管理器
  'npm.exe',       -- Windows版的NPM
  'yarn',          -- 快速、可靠、安全的依赖管理工具
  'yarn.exe',      -- Windows版的Yarn
  'pnpm',          -- 快速、节省磁盘空间的包管理器
  'pnpm.exe',      -- Windows版的pnpm
  'pip',           -- Python包安装工具
  'pip.exe',       -- Windows版的pip
  'conda',         -- Anaconda包和环境管理器
  'conda.exe',     -- Windows版的Conda
  'mamba',         -- Conda的快速替代品
  'mamba.exe',     -- Windows版的Mamba

  -- ==================== 系统监控工具 ====================
  'htop',          -- 交互式进程查看器
  'htop.exe',      -- Windows版的Htop
  'btop',          -- 资源监视器 (C++编写)
  'btop.exe',      -- Windows版的Btop
  'top',           -- 任务管理器
  'top.exe',       -- Windows版的Top
  'iotop',         -- I/O监控工具
  'iotop.exe',     -- Windows版的IOtop
  'iftop',         -- 网络使用监控
  'iftop.exe',     -- Windows版的IFtop
  'nethogs',       -- 网络使用按进程监控
  'nethogs.exe',   -- Windows版的Nethogs
  'glances',       -- 跨平台系统监控工具
  'glances.exe',   -- Windows版的Glances

  -- ==================== 文件管理器 ====================
  'ranger',        -- 终端文件管理器
  'ranger.exe',    -- Windows版的Ranger
  'lf',            -- 轻量级终端文件管理器
  'lf.exe',        -- Windows版的lf
  'nnn',           -- 快速终端文件管理器
  'nnn.exe',       -- Windows版的nnn
  'mc',            -- GNU Midnight Commander文件管理器
  'mc.exe',        -- Windows版的Midnight Commander
  'vifm',          -- Vi风格的文件管理器
  'vifm.exe',      -- Windows版的Vifm
  'yazi',          -- 现代终端文件管理器 (Rust编写)
  'yazi.exe',      -- Windows版的Yazi

  -- ==================== 现代CLI工具 ====================
  'bat',           -- cat的现代替代 (语法高亮)
  'bat.exe',       -- Windows版的Bat
  'exa',           -- ls的现代替代 (已停止维护)
  'exa.exe',       -- Windows版的Exa
  'eza',           -- exa的活跃分支
  'eza.exe',       -- Windows版的Eza
  'fd',            -- find的现代替代
  'fd.exe',        -- Windows版的fd
  'rg',            -- ripgrep (grep的快速替代)
  'rg.exe',        -- Windows版的ripgrep
  'fzf',           -- 命令行模糊搜索工具
  'fzf.exe',       -- Windows版的fzf
  'ag',            -- the_silver_searcher (代码搜索工具)
  'ag.exe',        -- Windows版的ag
  'jq',            -- JSON处理器
  'jq.exe',        -- Windows版的jq
  'yq',            -- YAML/JSON/XML处理器
  'yq.exe',        -- Windows版的yq
  'procs',         -- ps的现代替代
  'procs.exe',     -- Windows版的procs
  'dust',          -- du的现代替代
  'dust.exe',      -- Windows版的dust
  'duf',           -- df的现代替代
  'duf.exe',       -- Windows版的duf
  'delta',         -- 语法高亮的diff查看器
  'delta.exe',     -- Windows版的delta
  'lazydocker',    -- Docker的简单终端UI
  'lazydocker.exe',-- Windows版的lazydocker

  -- ==================== 网络和下载工具 ====================
  'curl',          -- 命令行URL传输工具
  'curl.exe',      -- Windows版的curl
  'wget',          -- 网络下载器
  'wget.exe',      -- Windows版的wget
  'aria2c',        -- 轻量级多协议下载器
  'aria2c.exe',    -- Windows版的aria2c
  'ping',          -- 网络连通性测试
  'ping.exe',      -- Windows版的ping
  'traceroute',    -- 网络路由跟踪
  'tracert.exe',   -- Windows版的traceroute (tracert)
  'nslookup',      -- DNS查询工具
  'nslookup.exe',  -- Windows版的nslookup
  'dig',           -- DNS查询工具
  'dig.exe',       -- Windows版的dig

  -- ==================== 压缩和归档工具 ====================
  'tar',           -- 归档工具
  'tar.exe',       -- Windows版的tar
  'gzip',          -- 压缩工具
  'gzip.exe',      -- Windows版的gzip
  'gunzip',        -- 解压工具
  'gunzip.exe',    -- Windows版的gunzip
  'zip',           -- ZIP压缩工具
  'zip.exe',       -- Windows版的zip
  'unzip',         -- ZIP解压工具
  'unzip.exe',     -- Windows版的unzip
  '7z',            -- 7-Zip压缩工具
  '7z.exe',        -- Windows版的7z

  -- ==================== 其他常用工具 ====================
  'less',          -- 分页器
  'less.exe',      -- Windows版的less
  'more',          -- 分页器
  'more.exe',      -- Windows版的more
  'man',           -- 手册页查看器
  'man.exe',       -- Windows版的man
  'info',          -- Info文档查看器
  'info.exe',      -- Windows版的info
  'watch',         -- 重复执行命令
  'watch.exe',     -- Windows版的watch
  'tail',          -- 查看文件尾部
  'tail.exe',      -- Windows版的tail
  'head',          -- 查看文件头部
  'head.exe',      -- Windows版的head
  'grep',          -- 文本搜索工具
  'grep.exe',      -- Windows版的grep
  'sed',           -- 流编辑器
  'sed.exe',       -- Windows版的sed
  'awk',           -- 文本处理工具
  'awk.exe',       -- Windows版的awk
  'sort',          -- 排序工具
  'sort.exe',      -- Windows版的sort
  'uniq',          -- 去重工具
  'uniq.exe',      -- Windows版的uniq
  'wc',            -- 字数统计工具
  'wc.exe',        -- Windows版的wc

  -- ==================== 开发服务器 ====================
  'serve',         -- 简单HTTP服务器 (npm包)
  'serve.exe',     -- Windows版的serve
  'http-server',   -- 简单HTTP服务器
  'http-server.exe', -- Windows版的http-server
  'live-server',   -- 实时重载的HTTP服务器
  'live-server.exe', -- Windows版的live-server
}
-- 强制关闭确认设置
config.exit_behavior = "Close"
config.exit_behavior_messaging = "None"
-- config.exit_behavior_messaging = "Verbose" -- 显示详细的退出信息
-- config.exit_behavior_messaging = "Brief"   -- 显示简短的退出信息

-- 根据系统配置启动菜单
if is_windows then
  config.launch_menu = {
    {
      label = 'PowerShell Core',
      args = { 'pwsh.exe', '-NoExit', '-NoLogo' },
    },
    {
      label = 'PowerShell',
      args = { 'powershell.exe', '-NoExit', '-NoLogo' },
    },
    {
      label = 'Command Prompt',
      args = { 'cmd.exe' },
    },
    {
      label = 'Nushell',
      args = { 'nu.exe' },
    },
    {
      label = 'Nushell(cargo)',
      args = { '~/.cargo/bin/nu.exe' },
    },
    {
      label = 'Git Bash',
      args = { 'C:\\Program Files\\Git\\bin\\bash.exe', '-i', '-l' },
    },
    {
      label = 'MSYS2 Bash',
      args = { 'C:\\msys64\\usr\\bin\\bash.exe', '-i', '-l' },
    },
    {
      label = 'Cygwin Bash',
      args = { 'C:\\cygwin64\\bin\\bash.exe', '-i', '-l' },
    },
  }
  -- 设置Windows默认shell
  config.default_prog = { 'pwsh.exe', '-NoExit', '-NoLogo' }

elseif is_linux or is_darwin then
  config.launch_menu = {
    {
      label = 'Fish',
      args = { 'fish' },
    },
    {
      label = 'Zsh',
      args = { 'zsh' },
    },
    {
      label = 'Bash',
      args = { 'bash' },
    },
    {
      label = 'PowerShell Core',
      args = { 'pwsh' },
    },
    {
      label = 'Nushell',
      args = { 'nu' },
    },
    {
      label = 'Nushell(linuxbrew)',
      args = { '/home/linuxbrew/.linuxbrew/bin/nu' },
    },
    {
      label = 'Nushell(cargo)',
      args = { '~/.cargo/bin/nu' },
    },
  }
  
  -- 设置Unix系统默认shell 
  if is_darwin then
    config.default_prog = { 'zsh' }  -- macOS默认使用zsh
  else
    config.default_prog = { 'fish' } -- Linux默认使用bash
  end
end

-- 标签页配置
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false

-- 自定义标签页标题格式
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local process_name = tab.active_pane.foreground_process_name or 'shell'
  -- 提取程序名称，去除完整路径
  local basename = process_name:match("([^/\\]+)$") or process_name
  local title = tab.tab_index + 1 .. ': ' .. basename
  return {
    { Text = ' ' .. title .. ' ' },
  }
end)

-- 快捷键
config.keys = {
  {
    key = 'f',
    mods = 'ALT',
    action = wezterm.action.ToggleFullScreen,
  },
  {
    key = 't',
    mods = 'ALT',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },
  {
    key = 'q',
    mods = 'ALT',
    action = wezterm.action.QuitApplication,
  },
  {
    key = 'q',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.QuitApplication,
  },
  {
    key = '\\',
    mods = 'ALT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'Enter',
    mods = 'ALT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
}

return config
