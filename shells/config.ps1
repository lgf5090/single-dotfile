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
    # [OPT-1] Consolidate all Set-PSReadLineOption calls into ONE invocation
    #         via splatting — avoids 8 separate cmdlet pipeline setups.
    # [OPT-7] Add HistorySaveStyle SaveIncrementally for cross-session safety.
    $PSReadLineOpts = @{
        EditMode                    = 'Vi'
        BellStyle                   = 'None'
        HistoryNoDuplicates         = $true
        HistorySearchCursorMovesToEnd = $true   # [OPT-1-fix] was duplicated
        PredictionSource            = 'History'
        PredictionViewStyle         = 'ListView'
        MaximumHistoryCount         = 10000
        HistorySaveStyle            = 'SaveIncrementally'  # [OPT-7]
    }
    # Set HistorySavePath to XDG-compliant location if available
    $__psrl_hist_dir = if ($env:XDG_STATE_HOME)
    { "$env:XDG_STATE_HOME/powershell"
    } else
    { "$HOME/.local/state/powershell"
    }
    if (-not [System.IO.Directory]::Exists($__psrl_hist_dir))
    { $null = New-Item -ItemType Directory -Path $__psrl_hist_dir -Force -ErrorAction Ignore
    }
    $PSReadLineOpts['HistorySavePath'] = "$__psrl_hist_dir/PSReadLineHistory.txt"
    Remove-Variable __psrl_hist_dir -ErrorAction Ignore

    Set-PSReadLineOption @PSReadLineOpts -ErrorAction Ignore
    Remove-Variable PSReadLineOpts -ErrorAction Ignore

    # [OPT-8] Filter sensitive commands from history
    Set-PSReadLineOption -AddToHistoryHandler {
        param($line)
        if ($line -match '(?i)(password|secret|token|api[_-]?key)\s*[=:]')
        {
            return 'SkipAndAdd'   # run but don't save
        }
        return 'MemoryAndFile'
    } -ErrorAction Ignore

    $__shells_vi_insert = [ordered]@{
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
        'Ctrl+l'        = 'ClearScreen'          # [OPT-9]
        'Ctrl+z'        = 'Undo'                 # [OPT-10]
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
    $__shells_vi_command = [ordered]@{
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
        'Ctrl+l'    = 'ClearScreen'              # [OPT-9]
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
    foreach ($e in $__shells_vi_insert.GetEnumerator())
    {
        try
        { Set-PSReadLineKeyHandler -Chord $e.Key -ViMode Insert  -Function $e.Value
        } catch
        {
        }
    }
    foreach ($e in $__shells_vi_command.GetEnumerator())
    {
        try
        { Set-PSReadLineKeyHandler -Chord $e.Key -ViMode Command -Function $e.Value
        } catch
        {
        }
    }
    Remove-Variable -Name __shells_vi_insert, __shells_vi_command -Scope Script -ErrorAction Ignore
}


# =============================================================================
# SECTION 1 — OS detection ($SHELLS_OS)
# =============================================================================
$SHELLS_OS = if ($IsMacOS)
{ 'macos'
} elseif ($IsLinux)
{
    if ([System.IO.File]::Exists('/proc/version') -and
        [System.IO.File]::ReadAllText('/proc/version') -match '(?i)microsoft|wsl')
    { 'wsl'
    } else
    { 'linux'
    }
} elseif ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6)
{ 'windows'
} else
{ 'unknown'
}
$env:SHELLS_OS = $SHELLS_OS


# =============================================================================
# SECTION 2 — Shell environment
# =============================================================================
if (-not $env:EDITOR)
{ $env:EDITOR = 'vim'
}
if (-not $env:VISUAL)
{ $env:VISUAL = $env:EDITOR
}
if (-not $env:PAGER)
{ $env:PAGER  = 'less'
}
if (-not $env:LESS)
{ $env:LESS   = '-R -F -X'
}

if (-not $env:XDG_CONFIG_HOME)
{ $env:XDG_CONFIG_HOME = "$HOME/.config"
}
if (-not $env:XDG_DATA_HOME)
{ $env:XDG_DATA_HOME   = "$HOME/.local/share"
}
if (-not $env:XDG_CACHE_HOME)
{ $env:XDG_CACHE_HOME  = "$HOME/.cache"
}
if (-not $env:XDG_STATE_HOME)
{ $env:XDG_STATE_HOME  = "$HOME/.local/state"
}

switch ($SHELLS_OS)
{
    'windows'
    { $env:MSYS = 'winsymlinks:nativestrict'
    }
}


# =============================================================================
# SECTION 3 — User file loaders (~/.envs and ~/.aliases)
# =============================================================================
$__shells_psep = [System.IO.Path]::PathSeparator

function script:__shells_path_prepend([string]$str)
{
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $out  = [System.Collections.Generic.List[string]]::new()
    # [OPT] Split input on BOTH ':' and ';' for cross-platform .envs compatibility
    $sep_re = if ($__shells_psep -eq ';')
    { '[;:]'
    } else
    { '[:;]'
    }
    foreach ($p in ($str -split $sep_re) + ($env:PATH -split $__shells_psep))
    {
        if (-not $p)
        { continue
        }
        if (-not $seen.Add($p))
        { continue
        }
        $out.Add($p)
    }
    $env:PATH = $out -join $__shells_psep
}

function script:__shells_load_envs([string]$file)
{
    if (-not [System.IO.File]::Exists($file))
    { return
    }
    foreach ($line in [System.IO.File]::ReadAllLines($file))
    {
        $line = $line.TrimStart()
        if (-not $line -or $line[0] -eq '#')
        { continue
        }
        $eq = $line.IndexOf('=')
        if ($eq -lt 1)
        { continue
        }
        $key = $line.Substring(0, $eq).TrimEnd()
        $val = $line.Substring($eq + 1).Trim()
        if ($key -notmatch '^[A-Za-z_][A-Za-z0-9_]*$')
        { continue
        }
        if ($val.Length -ge 2)
        {
            $f = $val[0]; $l = $val[$val.Length - 1]
            if (($f -eq '"' -and $l -eq '"') -or ($f -eq "'" -and $l -eq "'"))
            { $val = $val.Substring(1, $val.Length - 2)
            }
        }
        $val = $val.Replace('{HOME}', $HOME).Replace('{PATH}', $env:PATH)
        if ($key -eq 'PATH')
        { __shells_path_prepend $val
        } else
        { [System.Environment]::SetEnvironmentVariable($key, $val)
        }
    }
}

function script:__shells_load_aliases([string]$file)
{
    if (-not [System.IO.File]::Exists($file))
    { return
    }
    foreach ($line in [System.IO.File]::ReadAllLines($file))
    {
        $line = $line.TrimStart()
        if (-not $line -or $line[0] -eq '#')
        { continue
        }
        $eq = $line.IndexOf('=')
        if ($eq -lt 1)
        { continue
        }
        $name = $line.Substring(0, $eq).TrimEnd()
        $body = $line.Substring($eq + 1)
        if ($name -notmatch '^[A-Za-z_][A-Za-z0-9_-]*$')
        { continue
        }
        if ($body.Length -ge 2)
        {
            $f = $body[0]; $l = $body[$body.Length - 1]
            if (($f -eq '"' -and $l -eq '"') -or ($f -eq "'" -and $l -eq "'"))
            { $body = $body.Substring(1, $body.Length - 2)
            }
        }
        Set-Item -LiteralPath "function:global:$name" `
            -Value ([scriptblock]::Create("$body `@args"))
    }
}

__shells_load_envs    "$HOME/.envs"
__shells_load_aliases "$HOME/.aliases"

Remove-Item function:__shells_path_prepend,
function:__shells_load_envs,
function:__shells_load_aliases -ErrorAction Ignore


# =============================================================================
# SECTION 4 — Language & toolchain environment variables (non-PATH)
# =============================================================================
if (-not $env:NPM_CONFIG_PREFIX)
{ $env:NPM_CONFIG_PREFIX = "$HOME/.npm-global"
}
if (-not $env:PNPM_HOME)
{ $env:PNPM_HOME         = "$HOME/.pnpm-global"
}
if ([System.IO.Directory]::Exists("$HOME/.fnm"))
{ $env:FNM_DIR     = "$HOME/.fnm"
}
if ([System.IO.Directory]::Exists("$HOME/.bun"))
{ $env:BUN_INSTALL = "$HOME/.bun"
}
if ([System.IO.Directory]::Exists("$HOME/.deno"))
{ $env:DENO_INSTALL= "$HOME/.deno"
}

if (-not $env:GOPATH)
{ $env:GOPATH = "$HOME/go"
}
if (-not $env:GOROOT)
{
    foreach ($d in '/home/linuxbrew/.linuxbrew/opt/go/libexec',
        '/opt/homebrew/opt/go/libexec', '/usr/local/go', "$HOME/.local/go")
    {
        if ([System.IO.Directory]::Exists($d))
        { $env:GOROOT = $d; break
        }
    }
}

if (-not $env:ANACONDA_HOME)
{
    foreach ($d in "$HOME/anaconda3", "$HOME/miniconda3",
        '/opt/anaconda3', '/opt/miniconda3')
    {
        if ([System.IO.Directory]::Exists($d))
        { $env:ANACONDA_HOME = $d; break
        }
    }
}
if ([System.IO.Directory]::Exists("$HOME/.poetry"))
{ $env:POETRY_HOME = "$HOME/.poetry"
}
if ([System.IO.Directory]::Exists("$HOME/.pyenv"))
{ $env:PYENV_ROOT  = "$HOME/.pyenv"
}

if (-not $env:JAVA_HOME)
{
    if ([System.IO.File]::Exists('/usr/libexec/java_home'))
    { $env:JAVA_HOME = (& /usr/libexec/java_home 2>$null)
    } else
    {
        foreach ($d in '/usr/lib/jvm/default-java',
            '/usr/lib/jvm/java-11-openjdk-amd64')
        {
            if ([System.IO.Directory]::Exists($d))
            { $env:JAVA_HOME = $d; break
            }
        }
    }
}

if ($SHELLS_OS -eq 'linux' -or $SHELLS_OS -eq 'wsl')
{
    foreach ($p in '/usr/lib/x86_64-linux-gnu', '/usr/lib/aarch64-linux-gnu')
    {
        if (-not [System.IO.Directory]::Exists($p))
        { continue
        }
        $env:LIBRARY_PATH    = if ($env:LIBRARY_PATH)
        { "${p}:$env:LIBRARY_PATH"
        } else
        { $p
        }
        $env:LD_LIBRARY_PATH = if ($env:LD_LIBRARY_PATH)
        { "${p}:$env:LD_LIBRARY_PATH"
        } else
        { $p
        }
        $env:RUSTFLAGS       = "-L $p"
        break
    }
}

if (-not $env:DOCKER_BUILDKIT)
{ $env:DOCKER_BUILDKIT          = '1'
}
if (-not $env:COMPOSE_DOCKER_CLI_BUILD)
{ $env:COMPOSE_DOCKER_CLI_BUILD = '1'
}


# =============================================================================
# SECTION 5 — PATH
# =============================================================================
function script:__shells_prepend_dir
{
    $sep = $__shells_psep
    foreach ($d in $args)
    {
        if (-not $d)
        { continue
        }
        if (-not [System.IO.Directory]::Exists($d))
        { continue
        }
        if (-not "$sep$env:PATH$sep".Contains("$sep$d$sep"))
        { $env:PATH = "$d$sep$env:PATH"
        }
    }
}
function script:__shells_append_dir
{
    $sep = $__shells_psep
    foreach ($d in $args)
    {
        if (-not $d)
        { continue
        }
        if (-not [System.IO.Directory]::Exists($d))
        { continue
        }
        if (-not "$sep$env:PATH$sep".Contains("$sep$d$sep"))
        { $env:PATH = "$env:PATH$sep$d"
        }
    }
}

__shells_append_dir `
    "$HOME/.lmstudio/bin" `
    "$HOME/.local/bin"    `
    "$HOME/bin"           `
    "$HOME/Applications"  `
    "$HOME/.local/Applications"

$__shells_cargo = if ($env:CARGO_HOME)
{ $env:CARGO_HOME
} else
{ "$HOME/.cargo"
}
__shells_prepend_dir `
    "$__shells_cargo/bin" `
    "$HOME/.rd/bin"       `
    "$HOME/.opencode/bin"
Remove-Variable __shells_cargo -Scope Script -ErrorAction Ignore
if ([System.IO.File]::Exists("$HOME/.cargo/env.ps1"))
{ . "$HOME/.cargo/env.ps1"
}

__shells_prepend_dir `
$(if ($env:BUN_INSTALL)
    { "$env:BUN_INSTALL/bin"
    }) `
$(if ($env:DENO_INSTALL)
    { "$env:DENO_INSTALL/bin"
    }) `
    "$env:NPM_CONFIG_PREFIX/bin" `
    $env:PNPM_HOME               `
    "$HOME/.yarn/bin"            `
    "$HOME/.config/yarn/global/node_modules/.bin" `
    "$HOME/.volta/bin"           `
    "$HOME/.fnm"                 `
    "$HOME/.local/share/npm/bin"

__shells_prepend_dir `
$(if ($env:PYENV_ROOT)
    { "$env:PYENV_ROOT/bin"
    }) `
$(if ($env:ANACONDA_HOME)
    { "$env:ANACONDA_HOME/bin"
    }) `
$(if ($env:POETRY_HOME)
    { "$env:POETRY_HOME/bin"
    }) `
    "$HOME/.poetry/bin"  `
    "$HOME/.local/pipx/bin"

__shells_prepend_dir `
    "$env:GOPATH/bin" `
$(if ($env:GOROOT)
    { "$env:GOROOT/bin"
    })

if ($SHELLS_OS -eq 'linux' -or $SHELLS_OS -eq 'wsl')
{
    __shells_append_dir `
        '/snap/bin'                                    `
        '/var/lib/flatpak/exports/bin'                 `
        "$HOME/.local/share/flatpak/exports/bin"       `
        '/opt/bin'
}

switch ($SHELLS_OS)
{
    'wsl'
    {
        __shells_append_dir `
            '/mnt/c/Program Files/Microsoft VS Code/bin' `
            "/mnt/c/Users/$env:USER/AppData/Local/Programs/Microsoft VS Code/bin"
    }
    'windows'
    {
        __shells_append_dir `
            "$env:ProgramFiles\Microsoft VS Code\bin"          `
            "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin"
    }
}

foreach ($__shells_brew in '/home/linuxbrew/.linuxbrew/bin/brew',
    "$HOME/.linuxbrew/bin/brew", '/opt/homebrew/bin/brew', '/usr/local/bin/brew')
{
    if (-not [System.IO.File]::Exists($__shells_brew))
    { continue
    }
    $__shells_brew_init = & $__shells_brew shellenv pwsh 2>$null
    if ($LASTEXITCODE -eq 0 -and $__shells_brew_init)
    { $__shells_brew_init -join "`n" | Invoke-Expression
    } else
    {
        $prefix = (& $__shells_brew --prefix 2>$null | Select-Object -First 1)
        if ($prefix)
        {
            $env:HOMEBREW_PREFIX     = $prefix
            $env:HOMEBREW_CELLAR     = "$prefix/Cellar"
            $env:HOMEBREW_REPOSITORY = $prefix
            __shells_prepend_dir "$prefix/bin" "$prefix/sbin"
        }
    }
    break
}
Remove-Variable __shells_brew, __shells_brew_init -Scope Script -ErrorAction Ignore

Remove-Item function:__shells_prepend_dir,
function:__shells_append_dir -ErrorAction Ignore
Remove-Variable __shells_psep -ErrorAction Ignore


# =============================================================================
# SECTION 6 — File listing & navigation aliases
# =============================================================================
# All helpers use PowerShell built-in cmdlets only — no external binaries.
#
#   ls / la / l / ll / lt  →  Get-ChildItem  (built-in)
#   grep / fgrep / egrep   →  Select-String  (built-in)

# [OPT-4] Shared human-readable size formatter — used by both ll and lt
$__shells_size_fmt = {
    if ($_.PSIsContainer)
    { '<DIR>'
    } else
    {
        $n = $_.Length
        if     ($n -ge 1GB)
        { '{0:N1}G' -f ($n / 1GB)
        } elseif ($n -ge 1MB)
        { '{0:N1}M' -f ($n / 1MB)
        } elseif ($n -ge 1KB)
        { '{0:N1}K' -f ($n / 1KB)
        } else
        { "${n}B"
        }
    }
}

$__shells_ls_table = @(
    'Mode',
    @{ N = 'Modified'; E = { $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm') } },
    @{ N = 'Size';     E = $__shells_size_fmt },
    'Name'
)

# ---- ls family (Get-ChildItem) ----------------------------------------------
function global:ls
{ Get-ChildItem        @args
}
function global:la
{ Get-ChildItem -Force @args
}
function global:l
{ Get-ChildItem        @args | Format-Wide -AutoSize -Property Name
}

function global:ll
{
    Get-ChildItem -Force @args | Format-Table -AutoSize $__shells_ls_table
}

function global:lt
{
    Get-ChildItem -Force @args |
        Sort-Object LastWriteTime -Descending |
        Format-Table -AutoSize $__shells_ls_table
}

# ---- grep family (Select-String) -------------------------------------------
function global:grep
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Pattern,
        [Parameter(Position = 1, ValueFromRemainingArguments)]
        [string[]]$Path
    )
    if ($Path)
    { Select-String -Pattern $Pattern -Path $Path
    } else
    { $input | Select-String -Pattern $Pattern
    }
}

function global:fgrep
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Pattern,
        [Parameter(Position = 1, ValueFromRemainingArguments)]
        [string[]]$Path
    )
    if ($Path)
    { Select-String -SimpleMatch -Pattern $Pattern -Path $Path
    } else
    { $input | Select-String -SimpleMatch -Pattern $Pattern
    }
}

function global:egrep
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Pattern,
        [Parameter(Position = 1, ValueFromRemainingArguments)]
        [string[]]$Path
    )
    if ($Path)
    { Select-String -Pattern $Pattern -Path $Path
    } else
    { $input | Select-String -Pattern $Pattern
    }
}

# ---- Directory navigation / reload / path -----------------------------------
function global:..
{ Set-Location ..
}
function global:...
{ Set-Location ../..
}
function global:....
{ Set-Location ../../..
}

function global:md
{
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

function global:now
{ Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz'
}
function global:reload
{
    # [OPT-15] Guard: only reload if $PROFILE actually exists
    if ($PROFILE -and (Test-Path $PROFILE))
    { . $PROFILE
    } else
    { Write-Warning "No `$PROFILE found at: $PROFILE"
    }
}
function global:path
{ $env:PATH -split [System.IO.Path]::PathSeparator
}


# =============================================================================
# SECTION 7 — OS-specific aliases (clipboard / file manager / package manager)
# =============================================================================
switch ($SHELLS_OS)
{
    'macos'
    {
        function global:clip
        { $input | Set-Clipboard
        }
        function global:paste
        { Get-Clipboard
        }
        function global:finder
        { open . @args
        }
        function global:brewup
        { brew update; brew upgrade; brew cleanup
        }
    }
    { $_ -eq 'linux' -or $_ -eq 'wsl' }
    {
        function global:clip
        { $input | Set-Clipboard
        }
        function global:paste
        { Get-Clipboard
        }
        if ($SHELLS_OS -eq 'wsl')
        {
            function global:explorer
            { explorer.exe . @args
            }
        }
        if (Get-Command brew -ErrorAction Ignore)
        {
            function global:brewup
            { brew update; brew upgrade; brew cleanup
            }
        }
        if (Get-Command apt -ErrorAction Ignore)
        {
            function global:aptup
            { sudo apt update; sudo apt upgrade
            }
        }
    }
    'windows'
    {
        function global:clip
        { $input | Set-Clipboard
        }
        function global:paste
        { Get-Clipboard
        }
        function global:open
        { Start-Process @args
        }
    }
}


# =============================================================================
# SECTION 8 — Network helpers & HTTP proxy
# =============================================================================
# [OPT-2] Cross-platform localip & ports — Get-NetIPAddress / Get-NetTCPConnection
#         are Windows-ONLY. Provide native fallbacks for Linux/macOS.

function global:myip
{
    # [OPT-14] Add error handling + fallback API
    try
    {
        return (Invoke-RestMethod -Uri 'https://ifconfig.me' -TimeoutSec 5).Trim()
    } catch
    {
        try
        {
            return (Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 5).Trim()
        } catch
        {
            Write-Warning 'Failed to retrieve public IP'
        }
    }
}

function global:localip
{
    switch ($SHELLS_OS)
    {
        'windows'
        {
            (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Ignore |
                Where-Object {
                    $_.IPAddress -notlike '127.*' -and
                    $_.IPAddress -notlike '169.254.*'
                } |
                Select-Object -ExpandProperty IPAddress) -join ' '
        }
        'macos'
        {
            # ipconfig getifaddr works for each interface; fallback to ifconfig
            $ips = @()
            foreach ($iface in 'en0','en1','en2')
            {
                $ip = & ipconfig getifaddr $iface 2>$null
                if ($ip)
                { $ips += $ip
                }
            }
            if (-not $ips)
            {
                # fallback: parse ifconfig
                $raw = & ifconfig 2>$null
                $raw | Select-String 'inet (\d+\.\d+\.\d+\.\d+)' |
                    ForEach-Object { $_.Matches[0].Groups[1].Value } |
                    Where-Object { $_ -ne '127.0.0.1' }
            } else
            { $ips
            }
        }
        default  # linux / wsl
        {
            # hostname -I is the simplest cross-platform Linux approach
            $raw = (& hostname -I 2>$null)
            if ($raw)
            { $raw.Trim()
            } else
            {
                # fallback: parse ip addr
                & ip -4 addr show 2>$null |
                    Select-String 'inet (\d+\.\d+\.\d+\.\d+)' |
                    ForEach-Object { $_.Matches[0].Groups[1].Value } |
                    Where-Object { $_ -ne '127.0.0.1' }
            }
        }
    }
}

function global:ports
{
    switch ($SHELLS_OS)
    {
        'windows'
        {
            Get-NetTCPConnection -State Listen -ErrorAction Ignore |
                Select-Object LocalAddress, LocalPort, OwningProcess |
                Sort-Object LocalPort
        }
        { $_ -eq 'linux' -or $_ -eq 'wsl' }
        {
            # ss is available on all modern Linux distros
            & ss -tulnp 2>$null | Select-Object -Skip 1 |
                ForEach-Object {
                    if ($_ -match '(\S+)\s+(\S+)\s+\S+\s+(\S+):(\d+)\s+\S+\s+\S+\s+(.*)')
                    {
                        [PSCustomObject]@{
                            Proto   = $Matches[1]
                            State   = $Matches[2]
                            Address = $Matches[3]
                            Port    = [int]$Matches[4]
                            Process = $Matches[5]
                        }
                    }
                } | Sort-Object Port | Format-Table -AutoSize
        }
        'macos'
        {
            & lsof -iTCP -sTCP:LISTEN -nP 2>$null |
                Select-Object -Skip 1 |
                ForEach-Object {
                    $cols = $_ -split '\s+'
                    if ($cols.Count -ge 9)
                    {
                        [PSCustomObject]@{
                            Command = $cols[0]
                            PID     = $cols[1]
                            User    = $cols[2]
                            Name    = $cols[8]
                        }
                    }
                } | Sort-Object Name | Format-Table -AutoSize
        }
    }
}

# ---- Proxy toggle -----------------------------------------------------------
# [OPT-11] Consolidate proxy helpers with shared internal function
if (-not $env:PROXY_HOST)
{ $env:PROXY_HOST = '127.0.0.1'
}
if (-not $env:PROXY_PORT)
{ $env:PROXY_PORT = '3067'
}

function script:__shells_parse_proxy_args
{
    $h = $env:PROXY_HOST; $p = $env:PROXY_PORT
    switch ($args.Count)
    {
        0
        {
        }
        1
        { $p = $args[0]
        }
        2
        { $h = $args[0]; $p = $args[1]
        }
        default
        { Write-Error 'usage: proxy [[host] port]'; return $null
        }
    }
    return @{ Host = $h; Port = $p }
}

function global:proxy
{
    $r = __shells_parse_proxy_args @args
    if (-not $r)
    { return
    }
    $url = "http://$($r.Host):$($r.Port)"
    $env:http_proxy = $url; $env:https_proxy = $url
    $env:HTTP_PROXY = $url; $env:HTTPS_PROXY = $url
    "proxy on  ($($r.Host):$($r.Port))"
}

function global:socks5
{
    $r = __shells_parse_proxy_args @args
    if (-not $r)
    { return
    }
    $url = "socks5://$($r.Host):$($r.Port)"
    $env:all_proxy = $url; $env:ALL_PROXY = $url
    "socks5 on ($($r.Host):$($r.Port))"
}

function global:unproxy
{
    foreach ($v in 'http_proxy','https_proxy','HTTP_PROXY','HTTPS_PROXY','all_proxy','ALL_PROXY')
    { [System.Environment]::SetEnvironmentVariable($v, $null)
    }
    'proxy off'
}

function global:proxyinfo
{
    "http : $(if ($env:http_proxy)  { $env:http_proxy }  else { 'unset' })"
    "https: $(if ($env:https_proxy) { $env:https_proxy } else { 'unset' })"
    "socks: $(if ($env:all_proxy)   { $env:all_proxy }   else { 'unset' })"
}

Remove-Item function:__shells_parse_proxy_args -ErrorAction Ignore


# =============================================================================
# SECTION 9 — Custom utility functions
# =============================================================================
function global:mkcd
{
    if (-not $args[0])
    { Write-Error 'usage: mkcd <dir>'; return
    }
    $null = New-Item -ItemType Directory -Force -Path $args[0] -ErrorAction Stop
    Set-Location -LiteralPath $args[0]
}

function global:bak
{
    if (-not $args[0])
    { Write-Error 'usage: bak <path>'; return
    }
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    Copy-Item -LiteralPath $args[0] -Destination "$($args[0]).bak.$ts" -Recurse -Force
}

function global:mbak
{
    if (-not $args[0])
    { Write-Error 'usage: mbak <path>'; return
    }
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    Move-Item -LiteralPath $args[0] -Destination "$($args[0]).bak.$ts"
}

function global:weather
{ Invoke-RestMethod -Uri "https://wttr.in/$($args[0])" -TimeoutSec 10 -ErrorAction Ignore
}

function global:uuid
{ (New-Guid).Guid
}

# [OPT-13] Additional utility functions

# touch — create empty file or update timestamp
function global:touch
{
    foreach ($f in $args)
    {
        if ([System.IO.File]::Exists($f))
        { [System.IO.File]::SetLastWriteTime($f, [datetime]::Now)
        } else
        { $null = New-Item -ItemType File -Path $f -Force
        }
    }
}

# which — cross-platform command lookup
function global:which
{
    foreach ($cmd in $args)
    {
        $found = Get-Command $cmd -ErrorAction Ignore
        if ($found)
        {
            if ($found.Source)
            { $found.Source
            } else
            { $found.CommandType.ToString() + ': ' + $found.Name
            }
        } else
        { Write-Warning "${cmd}: not found"
        }
    }
}

# extract — universal archive extractor (delegates to native tools)
function global:extract
{
    if (-not $args[0])
    { Write-Error 'usage: extract <archive>'; return
    }
    $file = $args[0]
    if (-not (Test-Path $file))
    { Write-Error "File not found: $file"; return
    }
    switch -Regex ($file)
    {
        '\.tar\.gz$|\.tgz$'
        { tar xzf $file
        }
        '\.tar\.bz2$|\.tbz2$'
        { tar xjf $file
        }
        '\.tar\.xz$|\.txz$'
        { tar xJf $file
        }
        '\.tar$'
        { tar xf  $file
        }
        '\.zip$'
        { Expand-Archive -Path $file -DestinationPath . -Force
        }
        '\.gz$'
        { gunzip $file
        }
        '\.bz2$'
        { bunzip2 $file
        }
        '\.7z$'
        { 7z x $file
        }
        '\.rar$'
        { unrar x $file
        }
        default
        { Write-Error "Unsupported archive format: $file"
        }
    }
}

# mktmp — create and cd into a temporary directory
function global:mktmp
{
    $d = New-Item -ItemType Directory -Path ([System.IO.Path]::Combine(
            [System.IO.Path]::GetTempPath(), "ps_$(Get-Date -Format 'yyyyMMdd_HHmmss')"))
    Set-Location -LiteralPath $d.FullName
    $d.FullName
}


# =============================================================================
# SECTION 10 — Interactive prompt (function:prompt)
# =============================================================================
if (-not $env:SHELLS_NO_PROMPT)
{
    if (Get-Command starship -ErrorAction Ignore)
    {
        Invoke-Expression (& starship init powershell)
    } elseif (Get-Command Set-PSReadLineOption -ErrorAction Ignore)
    {
        $e = [char]27
        $global:__shells_has_git   = [bool](Get-Command git -ErrorAction Ignore)
        $global:__shells_user      = if ($env:USER)
        { $env:USER
        } else
        { $env:USERNAME
        }
        $global:__shells_host      = [System.Net.Dns]::GetHostName()
        $global:__shells_c_reset   = "$e[0m"
        $global:__shells_c_gray    = "$e[90m"
        $global:__shells_c_red     = "$e[31m"
        $global:__shells_c_green   = "$e[32m"
        $global:__shells_c_blue    = "$e[34m"
        $global:__shells_c_magenta = "$e[35m"
        $global:__shells_c_cyan    = "$e[36m"
        $global:__shells_c_white   = "$e[97m"

        function global:prompt
        {
            $ok = $?; $rc = $LASTEXITCODE
            if ($null -eq $rc)
            { $rc = 0
            }
            if (-not $ok -and $rc -eq 0)
            { $rc = 1
            }

            $now = (Get-Date).ToString('HH:mm:ss')
            $cwd = $PWD.Path
            if ($cwd.StartsWith($HOME, [System.StringComparison]::Ordinal))
            { $cwd = '~' + $cwd.Substring($HOME.Length)
            }

            $extra = ''
            if ($env:VIRTUAL_ENV)
            { $extra = " $($__shells_c_cyan)($(Split-Path -Leaf $env:VIRTUAL_ENV))$($__shells_c_reset)"
            } elseif ($env:CONDA_DEFAULT_ENV -and $env:CONDA_DEFAULT_ENV -ne 'base')
            { $extra = " $($__shells_c_cyan)($env:CONDA_DEFAULT_ENV)$($__shells_c_reset)"
            }

            # [OPT-5][OPT-6] Optimized git status: single `git status` call
            # replaces manual directory walk + 3 separate git invocations.
            if ($__shells_has_git)
            {
                $gitOut = & git status --porcelain -b 2>$null
                if ($LASTEXITCODE -eq 0 -and $gitOut)
                {
                    # First line: ## branch...upstream [ahead N, behind M]
                    $headLine = $gitOut | Select-Object -First 1
                    if ($headLine -match '^## (\S+?)(?:\.\.\.|$)')
                    {
                        $branch = $Matches[1] -replace '\{|\}', ''
                        # Any remaining lines = dirty (uncommitted changes)
                        $dirtyLines = $gitOut | Select-Object -Skip 1
                        $dirty = if ($dirtyLines)
                        { '*'
                        } else
                        { ''
                        }
                        $extra += " $($__shells_c_magenta)$branch$dirty$($__shells_c_reset)"
                    }
                }
            }

            $p  = "$($__shells_c_gray)[$now]$($__shells_c_reset)"
            $p += " $($__shells_c_green)$__shells_user$($__shells_c_white)@$__shells_host$($__shells_c_reset)"
            $p += " $($__shells_c_blue)[$cwd]$($__shells_c_reset)"
            $p += $extra
            if ($rc -ne 0)
            { $p += " $($__shells_c_red)[$rc]$($__shells_c_reset)"
            }
            $p += "`n$($__shells_c_cyan)`$$($__shells_c_reset) "

            $global:LASTEXITCODE = 0
            $p
        }
    }
}



# atuin https://docs.atuin.sh/cli/guide/delete-history/
# Atuin configuration for PowerShell
if (Get-Command atuin -ErrorAction SilentlyContinue)
{
    $env:ATUIN_DB_PATH = "$env:USERPROFILE\.local\share\atuin\history_powershell.db"
    Invoke-Expression (& { atuin init powershell --disable-up-arrow | Out-String })
}
