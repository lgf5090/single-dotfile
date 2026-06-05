# =============================================================================
# config.ps1 — single-file PowerShell configuration
#
# Source from your $PROFILE:
#
#     if (Test-Path /path/to/config.ps1) { . /path/to/config.ps1 }
#
# Reads (if present, silently skipped otherwise):
#     ~/.envs       — shared environment variables (see envs.example)
#     ~/.aliases    — shared aliases               (see aliases.example)
#
# Self-contained: does NOT source any other file in this repo.
# Targets PowerShell 7+ (Windows / macOS / Linux). PSReadLine 2.x required for
# Vi-mode bindings (silently skipped on hosts without it, e.g. ISE).
# =============================================================================

# ---- PSReadLine: Vi mode + keybindings (interactive only) -------------------
if (Get-Command Set-PSReadLineOption -ErrorAction Ignore)
{
    Set-PSReadLineOption -EditMode Vi
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd   # 去掉原来的重复调用
    Set-PSReadLineOption -PredictionSource History -ErrorAction Ignore
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -MaximumHistoryCount 10000

    # Vi Insert 模式绑定
    $__vi_insert = [ordered]@{
        'Ctrl+a'        = 'BeginningOfLine'
        'Ctrl+e'        = 'EndOfLine'
        'Ctrl+f'        = 'ForwardChar'
        'Ctrl+b'        = 'BackwardChar'
        'Ctrl+d'        = 'DeleteChar'
        'Ctrl+h'        = 'BackwardDeleteChar'
        'Ctrl+k'        = 'ForwardDeleteLine'
        'Ctrl+u'        = 'BackwardDeleteLine'
        'Ctrl+w'        = 'BackwardKillWord'
        'Ctrl+y'        = 'Yank'
        'Ctrl+r'        = 'ReverseSearchHistory'
        'Ctrl+s'        = 'ForwardSearchHistory'
        'Ctrl+p'        = 'PreviousHistory'
        'Ctrl+n'        = 'NextHistory'
        'Alt+f'         = 'ForwardWord'
        'Alt+b'         = 'BackwardWord'
        'Alt+d'         = 'KillWord'
        'Alt+Backspace' = 'BackwardKillWord'
        'Alt+.'         = 'YankLastArg'
        'Tab'           = 'Complete'
        'Ctrl+t'        = 'SwapCharacters'
        'Alt+u'         = 'UpcaseWord'
        'Alt+l'         = 'DowncaseWord'
        'Alt+c'         = 'CapitalizeWord'
        'UpArrow'       = 'HistorySearchBackward'
        'DownArrow'     = 'HistorySearchForward'
        'Home'          = 'BeginningOfLine'
        'End'           = 'EndOfLine'
        'PageUp'        = 'HistorySearchBackward'
        'PageDown'      = 'HistorySearchForward'
        'Delete'        = 'DeleteChar'
    }

    # Vi Command 模式绑定
    $__vi_command = [ordered]@{
        'Ctrl+a'    = 'BeginningOfLine'
        'Ctrl+e'    = 'EndOfLine'
        'Ctrl+f'    = 'ForwardChar'
        'Ctrl+b'    = 'BackwardChar'
        'Ctrl+d'    = 'DeleteChar'
        'Ctrl+k'    = 'ForwardDeleteLine'
        'Ctrl+u'    = 'BackwardDeleteLine'
        'Ctrl+w'    = 'BackwardKillWord'
        'Ctrl+y'    = 'Yank'
        'Ctrl+r'    = 'ReverseSearchHistory'
        'Ctrl+s'    = 'ForwardSearchHistory'
        'Ctrl+p'    = 'PreviousHistory'
        'Ctrl+n'    = 'NextHistory'
        'g,g'       = 'BeginningOfHistory'
        'G'         = 'EndOfHistory'
        'v'         = 'ViEditVisually'
        'Alt+f'     = 'ForwardWord'
        'Alt+b'     = 'BackwardWord'
        '~'         = 'InvertCase'
        'UpArrow'   = 'PreviousHistory'
        'DownArrow' = 'NextHistory'
        'Home'      = 'BeginningOfLine'
        'End'       = 'EndOfLine'
        'Delete'    = 'DeleteChar'
    }

    foreach ($e in $__vi_insert.GetEnumerator())
    {
        try { Set-PSReadLineKeyHandler -Chord $e.Key -ViMode Insert  -Function $e.Value } catch {}
    }
    foreach ($e in $__vi_command.GetEnumerator())
    {
        try { Set-PSReadLineKeyHandler -Chord $e.Key -ViMode Command -Function $e.Value } catch {}
    }

    # 统一清理临时变量
    Remove-Variable -Name __vi_insert, __vi_command -ErrorAction Ignore
}


# =============================================================================
# SECTION 1 — OS detection ($SHELLS_OS)
# =============================================================================
$SHELLS_OS =
    if ($IsMacOS)  { 'macos' }
    elseif ($IsLinux)
    {
        if ([System.IO.File]::Exists('/proc/version') -and
            [System.IO.File]::ReadAllText('/proc/version') -match '(?i)microsoft|wsl')
        { 'wsl' } else { 'linux' }
    }
    elseif ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) { 'windows' }
    else { 'unknown' }

$env:SHELLS_OS = $SHELLS_OS


# =============================================================================
# SECTION 2 — Shell environment
# =============================================================================
if (-not $env:EDITOR) { $env:EDITOR = 'vim'       }
if (-not $env:VISUAL) { $env:VISUAL = $env:EDITOR }
if (-not $env:PAGER)  { $env:PAGER  = 'less'      }
if (-not $env:LESS)   { $env:LESS   = '-R -F -X'  }

if (-not $env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME = "$HOME/.config"      }
if (-not $env:XDG_DATA_HOME)   { $env:XDG_DATA_HOME   = "$HOME/.local/share" }
if (-not $env:XDG_CACHE_HOME)  { $env:XDG_CACHE_HOME  = "$HOME/.cache"       }
if (-not $env:XDG_STATE_HOME)  { $env:XDG_STATE_HOME  = "$HOME/.local/state" }

if ($SHELLS_OS -eq 'windows') { $env:MSYS = 'winsymlinks:nativestrict' }


# =============================================================================
# SECTION 3 — User file loaders (~/.envs and ~/.aliases)
# =============================================================================
# 使用脚本级变量存储路径分隔符，供后续 PATH 操作复用
$script:__psep = [System.IO.Path]::PathSeparator

function script:__load_envs([string]$File)
{
    if (-not [System.IO.File]::Exists($File)) { return }

    foreach ($line in [System.IO.File]::ReadAllLines($File))
    {
        $line = $line.TrimStart()
        if (-not $line -or $line[0] -eq '#') { continue }

        $eq = $line.IndexOf('=')
        if ($eq -lt 1) { continue }

        $key = $line.Substring(0, $eq).TrimEnd()
        $val = $line.Substring($eq + 1).Trim()

        if ($key -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') { continue }

        # 去除引号
        if ($val.Length -ge 2)
        {
            $f = $val[0]; $l = $val[$val.Length - 1]
            if (($f -eq '"' -and $l -eq '"') -or ($f -eq "'" -and $l -eq "'"))
            { $val = $val.Substring(1, $val.Length - 2) }
        }

        $val = $val.Replace('{HOME}', $HOME).Replace('{PATH}', $env:PATH)

        if ($key -eq 'PATH')
        {
            # 修复原版硬编码 ':' 的 bug，改用平台分隔符
            $seen = [System.Collections.Generic.HashSet[string]]::new(
                        [System.StringComparer]::Ordinal)
            $out  = [System.Collections.Generic.List[string]]::new()
            foreach ($p in ($val -split $script:__psep) +
                           ($env:PATH -split $script:__psep))
            {
                if ($p -and $seen.Add($p)) { $out.Add($p) }
            }
            $env:PATH = $out -join $script:__psep
        }
        else
        {
            [System.Environment]::SetEnvironmentVariable($key, $val)
        }
    }
}

function script:__load_aliases([string]$File)
{
    if (-not [System.IO.File]::Exists($File)) { return }

    foreach ($line in [System.IO.File]::ReadAllLines($File))
    {
        $line = $line.TrimStart()
        if (-not $line -or $line[0] -eq '#') { continue }

        $eq = $line.IndexOf('=')
        if ($eq -lt 1) { continue }

        $name = $line.Substring(0, $eq).TrimEnd()
        $body = $line.Substring($eq + 1)

        if ($name -notmatch '^[A-Za-z_][A-Za-z0-9_-]*$') { continue }

        if ($body.Length -ge 2)
        {
            $f = $body[0]; $l = $body[$body.Length - 1]
            if (($f -eq '"' -and $l -eq '"') -or ($f -eq "'" -and $l -eq "'"))
            { $body = $body.Substring(1, $body.Length - 2) }
        }

        Set-Item -LiteralPath "function:global:$name" `
            -Value ([scriptblock]::Create("$body `@args"))
    }
}

__load_envs    "$HOME/.envs"
__load_aliases "$HOME/.aliases"
Remove-Item -Path function:__load_envs, function:__load_aliases -ErrorAction Ignore


# =============================================================================
# SECTION 4 — Language & toolchain environment variables (non-PATH)
# =============================================================================
if (-not $env:NPM_CONFIG_PREFIX) { $env:NPM_CONFIG_PREFIX = "$HOME/.npm-global"  }
if (-not $env:PNPM_HOME)         { $env:PNPM_HOME         = "$HOME/.pnpm-global" }

# 工具目录检测：存在则设置对应环境变量
$__tool_dirs = @{
    FNM_DIR     = "$HOME/.fnm"
    BUN_INSTALL = "$HOME/.bun"
    DENO_INSTALL= "$HOME/.deno"
    POETRY_HOME = "$HOME/.poetry"
    PYENV_ROOT  = "$HOME/.pyenv"
}
foreach ($kv in $__tool_dirs.GetEnumerator())
{
    if (-not (Get-Item -Path "env:$($kv.Key)" -ErrorAction Ignore) -and
        [System.IO.Directory]::Exists($kv.Value))
    { [System.Environment]::SetEnvironmentVariable($kv.Key, $kv.Value) }
}
Remove-Variable __tool_dirs -ErrorAction Ignore

if (-not $env:GOPATH) { $env:GOPATH = "$HOME/go" }
if (-not $env:GOROOT)
{
    foreach ($d in '/home/linuxbrew/.linuxbrew/opt/go/libexec',
                   '/opt/homebrew/opt/go/libexec',
                   '/usr/local/go',
                   "$HOME/.local/go")
    {
        if ([System.IO.Directory]::Exists($d)) { $env:GOROOT = $d; break }
    }
}

if (-not $env:ANACONDA_HOME)
{
    foreach ($d in "$HOME/anaconda3", "$HOME/miniconda3",
                   '/opt/anaconda3', '/opt/miniconda3')
    {
        if ([System.IO.Directory]::Exists($d)) { $env:ANACONDA_HOME = $d; break }
    }
}

if (-not $env:JAVA_HOME)
{
    if ([System.IO.File]::Exists('/usr/libexec/java_home'))
    {
        $env:JAVA_HOME = (& /usr/libexec/java_home 2>$null)
    }
    else
    {
        foreach ($d in '/usr/lib/jvm/default-java',
                       '/usr/lib/jvm/java-11-openjdk-amd64')
        {
            if ([System.IO.Directory]::Exists($d)) { $env:JAVA_HOME = $d; break }
        }
    }
}

if ($SHELLS_OS -in 'linux', 'wsl')
{
    foreach ($p in '/usr/lib/x86_64-linux-gnu', '/usr/lib/aarch64-linux-gnu')
    {
        if (-not [System.IO.Directory]::Exists($p)) { continue }
        $env:LIBRARY_PATH    = if ($env:LIBRARY_PATH)    { "${p}:$env:LIBRARY_PATH"    } else { $p }
        $env:LD_LIBRARY_PATH = if ($env:LD_LIBRARY_PATH) { "${p}:$env:LD_LIBRARY_PATH" } else { $p }
        $env:RUSTFLAGS       = "-L $p"
        break
    }
}

if (-not $env:DOCKER_BUILDKIT)          { $env:DOCKER_BUILDKIT          = '1' }
if (-not $env:COMPOSE_DOCKER_CLI_BUILD) { $env:COMPOSE_DOCKER_CLI_BUILD = '1' }


# =============================================================================
# SECTION 5 — PATH
# =============================================================================

# 将目录插入 PATH 头部（跳过不存在或已存在的条目）
function script:__prepend_dir
{
    $sep = $script:__psep
    foreach ($d in $args)
    {
        if (-not $d) { continue }
        if (-not [System.IO.Directory]::Exists($d)) { continue }
        if (-not "$sep$env:PATH$sep".Contains("$sep$d$sep"))
        { $env:PATH = "$d$sep$env:PATH" }
    }
}

# 将目录追加到 PATH 尾部（跳过不存在或已存在的条目）
function script:__append_dir
{
    $sep = $script:__psep
    foreach ($d in $args)
    {
        if (-not $d) { continue }
        if (-not [System.IO.Directory]::Exists($d)) { continue }
        if (-not "$sep$env:PATH$sep".Contains("$sep$d$sep"))
        { $env:PATH = "$env:PATH$sep$d" }
    }
}

# 低优先级（追加）：用户个人目录
__append_dir `
    "$HOME/.lmstudio/bin"         `
    "$HOME/.local/bin"            `
    "$HOME/bin"                   `
    "$HOME/Applications"          `
    "$HOME/.local/Applications"

# Rust / Rancher / opencode
$__cargo = if ($env:CARGO_HOME) { $env:CARGO_HOME } else { "$HOME/.cargo" }
__prepend_dir "$__cargo/bin" "$HOME/.rd/bin" "$HOME/.opencode/bin"
Remove-Variable __cargo -ErrorAction Ignore

if ([System.IO.File]::Exists("$HOME/.cargo/env.ps1")) { . "$HOME/.cargo/env.ps1" }

# Node 生态
__prepend_dir `
    $(if ($env:BUN_INSTALL)  { "$env:BUN_INSTALL/bin"  }) `
    $(if ($env:DENO_INSTALL) { "$env:DENO_INSTALL/bin" }) `
    "$env:NPM_CONFIG_PREFIX/bin"                           `
    $env:PNPM_HOME                                         `
    "$HOME/.yarn/bin"                                      `
    "$HOME/.config/yarn/global/node_modules/.bin"          `
    "$HOME/.volta/bin"                                     `
    "$HOME/.fnm"                                           `
    "$HOME/.local/share/npm/bin"

# Python 生态
__prepend_dir `
    $(if ($env:PYENV_ROOT)    { "$env:PYENV_ROOT/bin"    }) `
    $(if ($env:ANACONDA_HOME) { "$env:ANACONDA_HOME/bin" }) `
    $(if ($env:POETRY_HOME)   { "$env:POETRY_HOME/bin"   }) `
    "$HOME/.local/pipx/bin"

# Go
__prepend_dir `
    "$env:GOPATH/bin" `
    $(if ($env:GOROOT) { "$env:GOROOT/bin" })

# Linux / WSL 附加路径
if ($SHELLS_OS -in 'linux', 'wsl')
{
    __append_dir `
        '/snap/bin'                                  `
        '/var/lib/flatpak/exports/bin'               `
        "$HOME/.local/share/flatpak/exports/bin"     `
        '/opt/bin'
}

# VS Code CLI
switch ($SHELLS_OS)
{
    'wsl'
    {
        __append_dir `
            '/mnt/c/Program Files/Microsoft VS Code/bin' `
            "/mnt/c/Users/$env:USER/AppData/Local/Programs/Microsoft VS Code/bin"
    }
    'windows'
    {
        __append_dir `
            "$env:ProgramFiles\Microsoft VS Code\bin"         `
            "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin"
    }
}

# Homebrew（找到第一个即停止）
foreach ($__brew in '/home/linuxbrew/.linuxbrew/bin/brew',
                    "$HOME/.linuxbrew/bin/brew",
                    '/opt/homebrew/bin/brew',
                    '/usr/local/bin/brew')
{
    if (-not [System.IO.File]::Exists($__brew)) { continue }

    $__brew_init = & $__brew shellenv pwsh 2>$null
    if ($LASTEXITCODE -eq 0 -and $__brew_init)
    {
        $__brew_init -join "`n" | Invoke-Expression
    }
    else
    {
        $__prefix = (& $__brew --prefix 2>$null | Select-Object -First 1)
        if ($__prefix)
        {
            $env:HOMEBREW_PREFIX     = $__prefix
            $env:HOMEBREW_CELLAR     = "$__prefix/Cellar"
            $env:HOMEBREW_REPOSITORY = $__prefix
            __prepend_dir "$__prefix/bin" "$__prefix/sbin"
        }
    }
    break
}
Remove-Variable __brew, __brew_init, __prefix -ErrorAction Ignore

# 清理 PATH 辅助函数（不再对外暴露）
Remove-Item -Path function:__prepend_dir, function:__append_dir -ErrorAction Ignore
Remove-Variable __psep -ErrorAction Ignore


# =============================================================================
# SECTION 6 — File listing & navigation aliases
# =============================================================================

# ---- 共享的文件大小格式化脚本块（ll / lt 复用，避免重复） ----------------
$script:__fmt_size = {
    if ($_.PSIsContainer) { '<DIR>' }
    else
    {
        $n = $_.Length
        if     ($n -ge 1GB) { '{0:N1}G' -f ($n / 1GB) }
        elseif ($n -ge 1MB) { '{0:N1}M' -f ($n / 1MB) }
        elseif ($n -ge 1KB) { '{0:N1}K' -f ($n / 1KB) }
        else                { "${n}B" }
    }
}

# 共享的 Format-Table 列定义
$script:__fmt_cols = @(
    'Mode',
    @{ N = 'Modified'; E = { $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm') } },
    @{ N = 'Size';     E = $script:__fmt_size },
    'Name'
)

function global:ls { Get-ChildItem        @args }
function global:la { Get-ChildItem -Force @args }
function global:l  { Get-ChildItem        @args | Format-Wide -AutoSize -Property Name }

function global:ll
{
    Get-ChildItem -Force @args | Format-Table -AutoSize $script:__fmt_cols
}

function global:lt
{
    Get-ChildItem -Force @args |
        Sort-Object LastWriteTime -Descending |
        Format-Table -AutoSize $script:__fmt_cols
}

# ---- grep 族：用单个内部函数实现，对外暴露三个别名 -------------------------
# grep / egrep  → .NET 正则（ERE 等价）
# fgrep         → 字面量匹配（-SimpleMatch）

function script:__grep_impl
{
    param(
        [string]  $Pattern,
        [string[]]$Path,
        [switch]  $Simple
    )
    $extra = if ($Simple) { @{ SimpleMatch = $true } } else { @{} }
    if ($Path) { Select-String -Pattern $Pattern -Path $Path @extra }
    else       { $input | Select-String -Pattern $Pattern @extra }
}

function global:grep
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)] [string]  $Pattern,
        [Parameter(Position = 1, ValueFromRemainingArguments)] [string[]] $Path
    )
    __grep_impl -Pattern $Pattern -Path $Path
}

function global:egrep
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)] [string]  $Pattern,
        [Parameter(Position = 1, ValueFromRemainingArguments)] [string[]] $Path
    )
    __grep_impl -Pattern $Pattern -Path $Path
}

function global:fgrep
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)] [string]  $Pattern,
        [Parameter(Position = 1, ValueFromRemainingArguments)] [string[]] $Path
    )
    __grep_impl -Pattern $Pattern -Path $Path -Simple
}

# ---- 目录导航 ---------------------------------------------------------------
function global:..   { Set-Location ..       }
function global:...  { Set-Location ../..    }
function global:.... { Set-Location ../../.. }

function global:md
{
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

function global:now    { Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz' }
function global:reload { . $PROFILE }
function global:path   { $env:PATH -split [System.IO.Path]::PathSeparator }


# =============================================================================
# SECTION 7 — OS-specific aliases (clipboard / file manager / package manager)
# =============================================================================
switch ($SHELLS_OS)
{
    'macos'
    {
        function global:clip   { $input | Set-Clipboard }
        function global:paste  { Get-Clipboard }
        function global:finder { open . @args }
        function global:brewup { brew update; brew upgrade; brew cleanup }
    }
    { $_ -in 'linux', 'wsl' }
    {
        function global:clip  { $input | Set-Clipboard }
        function global:paste { Get-Clipboard }

        if ($SHELLS_OS -eq 'wsl')
        { function global:explorer { explorer.exe . @args } }

        if (Get-Command brew -ErrorAction Ignore)
        { function global:brewup { brew update; brew upgrade; brew cleanup } }

        if (Get-Command apt -ErrorAction Ignore)
        { function global:aptup { sudo apt update; sudo apt upgrade } }
    }
    'windows'
    {
        function global:clip  { $input | Set-Clipboard }
        function global:paste { Get-Clipboard }
        function global:open  { Start-Process @args }
    }
}


# =============================================================================
# SECTION 8 — Network helpers & HTTP proxy
# =============================================================================
function global:myip
{
    (Invoke-RestMethod -Uri 'https://ifconfig.me' -TimeoutSec 5).Trim()
}

function global:localip
{
    (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Ignore |
        Where-Object {
            $_.IPAddress -notlike '127.*' -and
            $_.IPAddress -notlike '169.254.*'
        } |
        Select-Object -ExpandProperty IPAddress) -join ' '
}

function global:ports
{
    Get-NetTCPConnection -State Listen -ErrorAction Ignore |
        Select-Object LocalAddress, LocalPort, OwningProcess |
        Sort-Object LocalPort
}

# ---- Proxy 配置 -------------------------------------------------------------
if (-not $env:PROXY_HOST) { $env:PROXY_HOST = '127.0.0.1' }
if (-not $env:PROXY_PORT) { $env:PROXY_PORT = '3067'       }

# 提取公共参数解析逻辑，避免 proxy / socks5 重复
function script:__resolve_proxy_addr
{
    param([string[]]$UserArgs)
    $h = $env:PROXY_HOST; $p = $env:PROXY_PORT
    switch ($UserArgs.Count)
    {
        0 {}
        1 { $p = $UserArgs[0] }
        2 { $h = $UserArgs[0]; $p = $UserArgs[1] }
        default { throw 'usage: <cmd> [[host] port]' }
    }
    return $h, $p
}

function global:proxy
{
    try   { $h, $p = __resolve_proxy_addr $args } catch { Write-Error $_; return }
    $url = "http://${h}:${p}"
    $env:http_proxy  = $url; $env:HTTP_PROXY  = $url
    $env:https_proxy = $url; $env:HTTPS_PROXY = $url
    "proxy on  (${h}:${p})"
}

function global:socks5
{
    try   { $h, $p = __resolve_proxy_addr $args } catch { Write-Error $_; return }
    $url = "socks5://${h}:${p}"
    $env:all_proxy = $url; $env:ALL_PROXY = $url
    "socks5 on (${h}:${p})"
}

function global:unproxy
{
    foreach ($v in 'http_proxy','https_proxy','HTTP_PROXY','HTTPS_PROXY',
                   'all_proxy','ALL_PROXY')
    { [System.Environment]::SetEnvironmentVariable($v, $null) }
    'proxy off'
}

function global:proxyinfo
{
    "http : $(if ($env:http_proxy)  { $env:http_proxy }  else { 'unset' })"
    "https: $(if ($env:https_proxy) { $env:https_proxy } else { 'unset' })"
    "socks: $(if ($env:all_proxy)   { $env:all_proxy }   else { 'unset' })"
}


# =============================================================================
# SECTION 9 — Custom utility functions
# =============================================================================
function global:mkcd
{
    if (-not $args[0]) { Write-Error 'usage: mkcd <dir>'; return }
    $null = New-Item -ItemType Directory -Force -Path $args[0] -ErrorAction Stop
    Set-Location -LiteralPath $args[0]
}

function global:bak
{
    if (-not $args[0]) { Write-Error 'usage: bak <path>'; return }
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    Copy-Item -LiteralPath $args[0] -Destination "$($args[0]).bak.$ts" -Recurse -Force
}

function global:mbak
{
    if (-not $args[0]) { Write-Error 'usage: mbak <path>'; return }
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    Move-Item -LiteralPath $args[0] -Destination "$($args[0]).bak.$ts"
}

function global:weather
{ Invoke-RestMethod -Uri "https://wttr.in/$($args[0])"
}

function global:uuid
{ (New-Guid).Guid
}


# =============================================================================
# SECTION 10 — Interactive prompt (function:prompt)
# =============================================================================
if (-not $env:SHELLS_NO_PROMPT)
{
    if (Get-Command starship -ErrorAction Ignore)
    {
        Invoke-Expression (& starship init powershell)
    }
    elseif (Get-Command Set-PSReadLineOption -ErrorAction Ignore)
    {
        $e = [char]27

        # 提前缓存到全局变量，prompt 每次触发时直接读取，无需重算
        $global:__p_has_git   = [bool](Get-Command git -ErrorAction Ignore)
        $global:__p_user      = if ($env:USER) { $env:USER } else { $env:USERNAME }
        $global:__p_host      = [System.Net.Dns]::GetHostName()
        $global:__p_reset     = "$e[0m"
        $global:__p_gray      = "$e[90m"
        $global:__p_red       = "$e[31m"
        $global:__p_green     = "$e[32m"
        $global:__p_blue      = "$e[34m"
        $global:__p_magenta   = "$e[35m"
        $global:__p_cyan      = "$e[36m"
        $global:__p_white     = "$e[97m"

        function global:prompt
        {
            # 立即捕获退出码，避免后续命令覆盖
            $ok = $?
            $rc = $LASTEXITCODE
            if ($null -eq $rc)           { $rc = 0 }
            if (-not $ok -and $rc -eq 0) { $rc = 1 }

            $now = (Get-Date).ToString('HH:mm:ss')

            # ~ 缩写处理
            $cwd = $PWD.Path
            if ($cwd.StartsWith($HOME, [System.StringComparison]::Ordinal))
            { $cwd = '~' + $cwd.Substring($HOME.Length) }

            # 虚拟环境标记
            $extra = ''
            if ($env:VIRTUAL_ENV)
            { $extra = " $($__p_cyan)($(Split-Path -Leaf $env:VIRTUAL_ENV))$($__p_reset)" }
            elseif ($env:CONDA_DEFAULT_ENV -and $env:CONDA_DEFAULT_ENV -ne 'base')
            { $extra = " $($__p_cyan)($env:CONDA_DEFAULT_ENV)$($__p_reset)" }

            # Git 分支（只有检测到 git 命令时才查找）
            # 性能优化：用 git rev-parse 一次性获取 root + HEAD，减少子进程调用
            if ($__p_has_git)
            {
                $gitRoot = & git rev-parse --show-toplevel 2>$null
                if ($LASTEXITCODE -eq 0 -and $gitRoot)
                {
                    $branch = & git symbolic-ref --short HEAD 2>$null
                    if (-not $branch) { $branch = & git rev-parse --short HEAD 2>$null }
                    if ($branch)
                    {
                        # --porcelain 比 diff-index 更快，且能检测未追踪文件
                        $dirty = if (& git status --porcelain 2>$null) { '*' } else { '' }
                        $extra += " $($__p_magenta)${branch}${dirty}$($__p_reset)"
                    }
                }
            }

            $p  = "$($__p_gray)[$now]$($__p_reset)"
            $p += " $($__p_green)$__p_user$($__p_white)@$__p_host$($__p_reset)"
            $p += " $($__p_blue)[$cwd]$($__p_reset)"
            $p += $extra
            if ($rc -ne 0) { $p += " $($__p_red)[$rc]$($__p_reset)" }
            $p += "`n$($__p_cyan)`$$($__p_reset) "

            $global:LASTEXITCODE = 0
            $p
        }
    }
}
