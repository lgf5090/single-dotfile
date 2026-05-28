# =============================================================================
# config.win.ps1 — single-file Windows PowerShell 5.1 configuration
#
# Source from your $PROFILE:
#
#     if (Test-Path \path\to\config.win.ps1) { . \path\to\config.win.ps1 }
#
# Reads (if present, silently skipped otherwise):
#     ~\.envs       — shared environment variables (see envs.example)
#     ~\.aliases    — shared aliases               (see aliases.example)
#
# Targets Windows PowerShell 5.1 (built into Windows 10/11). For PowerShell 7+
# on any OS, use config.ps1 instead.
#
# Differences vs config.ps1:
#   - Vi mode removed (PSReadLine in 5.1 has incomplete Vi support); PSReadLine
#     keeps its Emacs defaults plus prefix-search arrow keys.
#   - $IsWindows/$IsLinux/$IsMacOS don't exist in 5.1 — OS detection is dropped;
#     this file is Windows-only.
#   - Unix-only branches removed: /proc/version, Homebrew, /usr/lib/...,
#     /usr/libexec/java_home, pbcopy/xclip/wl-copy.
#   - Toolchain detection uses Windows install paths (Program Files, AppData,
#     LOCALAPPDATA, ProgramData, %USERPROFILE%).
# =============================================================================

# ---- PSReadLine: options + minimal binds (interactive only) -----------------
# `Set-PSReadLineOption` exists when PSReadLine is loaded (default in Win 10
# 1809+ consoles). Older PSReadLine 1.x lacks some options — try/catch each.
if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue)
{
    Set-PSReadLineOption -EditMode Emacs
    try
    { Set-PSReadLineOption -BellStyle None
    } catch
    {
    }
    try
    { Set-PSReadLineOption -HistoryNoDuplicates
    } catch
    {
    }
    try
    { Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    } catch
    {
    }
    # -PredictionSource requires PSReadLine 2.1.0+.
    try
    { Set-PSReadLineOption -PredictionSource History
    } catch
    {
    }

    # Up/Down arrows: prefix-search through history (the most-requested override
    # beyond Emacs defaults). PSReadLine's Emacs mode already covers Ctrl+A/E/R,
    # Alt+F/B/D, etc., so we don't re-bind those.
    try
    {
        Set-PSReadLineKeyHandler -Chord UpArrow   -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Chord DownArrow -Function HistorySearchForward
    } catch
    {
    }
}


# =============================================================================
# SECTION 1 — OS marker
# =============================================================================
# Windows-only file; no detection needed. SHELLS_OS is exported so downstream
# tools that branch on it (and shared scripts) see the right value.

$SHELLS_OS    = 'windows'
$env:SHELLS_OS = 'windows'


# =============================================================================
# SECTION 2 — Shell environment defaults
# =============================================================================
# All defaults use `if (-not $env:VAR) { ... }` so user values (parent env
# or ~\.envs loaded in SECTION 3) take precedence over what's set here.

# ---- Editor / pager ---------------------------------------------------------
if (-not $env:EDITOR)
{ $env:EDITOR = 'notepad'
}
if (-not $env:VISUAL)
{ $env:VISUAL = $env:EDITOR
}
if (-not $env:PAGER)
{ $env:PAGER  = 'more'
}
# LESS is *nix-specific; harmless on Windows, useful if you run less.exe from
# Git for Windows or msys2.
if (-not $env:LESS)
{ $env:LESS   = '-R -F -X'
}

# ---- XDG Base Directory (some cross-platform tools respect these) -----------
if (-not $env:XDG_CONFIG_HOME)
{ $env:XDG_CONFIG_HOME = "$HOME\.config"
}
if (-not $env:XDG_DATA_HOME)
{ $env:XDG_DATA_HOME   = "$HOME\.local\share"
}
if (-not $env:XDG_CACHE_HOME)
{ $env:XDG_CACHE_HOME  = "$HOME\.cache"
}
if (-not $env:XDG_STATE_HOME)
{ $env:XDG_STATE_HOME  = "$HOME\.local\state"
}

# ---- MSYS native symlink support (affects subshells like Git Bash / msys2) --
if (-not $env:MSYS)
{ $env:MSYS = 'winsymlinks:nativestrict'
}


# =============================================================================
# SECTION 3 — User file loaders (~\.envs and ~\.aliases)
# =============================================================================
# Loaded early so user-supplied env values override SECTION 2 / SECTION 4
# defaults (which use `if (-not $env:VAR) { ... }`).

# Dedup-prepend a `:`-separated list (envs.example format) onto $env:PATH.
# Existing PATH preserved at the tail — caller need not include {PATH}.
function script:__shells_path_prepend([string]$str)
{
    $seen = [System.Collections.Generic.HashSet[string]]::new()
    $out  = [System.Collections.Generic.List[string]]::new()
    # `:` is always the envs.example separator regardless of host OS; the
    # destination PATH uses `;` (Windows native).
    foreach ($p in ($str -split ':') + ($env:PATH -split ';'))
    {
        if (-not $p)
        { continue
        }
        if (-not $seen.Add($p))
        { continue
        }
        $out.Add($p)
    }
    $env:PATH = $out -join ';'
}

# Parse a KEY=VALUE file into the environment (PATH gets special handling).
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
        # Strip a single pair of matching outer quotes
        if ($val.Length -ge 2)
        {
            $f = $val[0]; $l = $val[$val.Length - 1]
            if (($f -eq '"' -and $l -eq '"') -or ($f -eq "'" -and $l -eq "'"))
            {
                $val = $val.Substring(1, $val.Length - 2)
            }
        }
        $val = $val.Replace('{HOME}', $HOME).Replace('{PATH}', $env:PATH)
        if ($key -eq 'PATH')
        {
            __shells_path_prepend $val
        } else
        {
            [System.Environment]::SetEnvironmentVariable($key, $val)
        }
    }
}

# Parse a name=command file into PowerShell functions.
# PowerShell aliases (`Set-Alias`) cannot carry literal args, so each entry
# becomes a function `name { body @args }` — call semantics match bash aliases.
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
            {
                $body = $body.Substring(1, $body.Length - 2)
            }
        }
        # aliases.example forbids `name` colliding with the body's first word,
        # so plain `body @args` won't self-recurse.
        Set-Item -LiteralPath "function:global:$name" `
            -Value ([scriptblock]::Create("$body `@args"))
    }
}

__shells_load_envs    "$HOME\.envs"
__shells_load_aliases "$HOME\.aliases"

Remove-Item function:__shells_path_prepend, `
    function:__shells_load_envs, `
    function:__shells_load_aliases -ErrorAction SilentlyContinue


# =============================================================================
# SECTION 4 — Language & toolchain environment variables (non-PATH)
# =============================================================================
# Detected paths (GOROOT/JAVA_HOME/ANACONDA_HOME/...) are skipped if already
# set, so users can override via ~\.envs (loaded above).

# ---- Node.js ecosystem ------------------------------------------------------
if (-not $env:NPM_CONFIG_PREFIX)
{ $env:NPM_CONFIG_PREFIX = "$env:APPDATA\npm"
}
if (-not $env:PNPM_HOME)
{ $env:PNPM_HOME         = "$env:LOCALAPPDATA\pnpm"
}
if ([System.IO.Directory]::Exists("$HOME\.fnm"))
{ $env:FNM_DIR     = "$HOME\.fnm"
}
if ([System.IO.Directory]::Exists("$HOME\.bun"))
{ $env:BUN_INSTALL = "$HOME\.bun"
}
if ([System.IO.Directory]::Exists("$HOME\.deno"))
{ $env:DENO_INSTALL= "$HOME\.deno"
}
# nvm on Windows = nvm-windows, which manages PATH itself (no env var needed).

# ---- Go ---------------------------------------------------------------------
if (-not $env:GOPATH)
{ $env:GOPATH = "$HOME\go"
}
if (-not $env:GOROOT)
{
    foreach ($d in "$env:ProgramFiles\Go", "$HOME\.local\go")
    {
        if ([System.IO.Directory]::Exists($d))
        { $env:GOROOT = $d; break
        }
    }
}

# ---- Python (Anaconda / Poetry / pyenv-win detection) -----------------------
if (-not $env:ANACONDA_HOME)
{
    foreach ($d in "$HOME\anaconda3", "$HOME\miniconda3",
        "$env:ProgramData\Anaconda3", "$env:ProgramData\Miniconda3")
    {
        if ([System.IO.Directory]::Exists($d))
        { $env:ANACONDA_HOME = $d; break
        }
    }
}
if ([System.IO.Directory]::Exists("$HOME\.poetry"))
{ $env:POETRY_HOME = "$HOME\.poetry"
}
if ([System.IO.Directory]::Exists("$HOME\.pyenv-win"))
{ $env:PYENV       = "$HOME\.pyenv-win"
}

# ---- Java (JAVA_HOME) -------------------------------------------------------
# Most JDK installers set JAVA_HOME via the registry; if missing, probe common
# install roots and pick the first jdk-* directory found.
if (-not $env:JAVA_HOME)
{
    foreach ($root in "$env:ProgramFiles\Eclipse Adoptium",
        "$env:ProgramFiles\Java",
        "$env:ProgramFiles\Microsoft\jdk")
    {
        if (-not [System.IO.Directory]::Exists($root))
        { continue
        }
        $jdk = Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^jdk' } |
            Select-Object -First 1
        if ($jdk)
        { $env:JAVA_HOME = $jdk.FullName; break
        }
    }
}

# ---- Docker -----------------------------------------------------------------
if (-not $env:DOCKER_BUILDKIT)
{ $env:DOCKER_BUILDKIT          = '1'
}
if (-not $env:COMPOSE_DOCKER_CLI_BUILD)
{ $env:COMPOSE_DOCKER_CLI_BUILD = '1'
}


# =============================================================================
# SECTION 5 — PATH (unified, sub-sections by purpose)
# =============================================================================

# ---- Helpers ----------------------------------------------------------------
# Variadic: each arg is added if it exists and isn't already in PATH.
# Semantics match repeated calls — `prepend A B C` ⇒ `C;B;A;…PATH` (C leftmost).
# Empty / missing args are silently filtered by the Directory.Exists check.
# Membership test uses substring search on a `;`-wrapped PATH — single O(n)
# string scan, no allocation.
function script:__shells_prepend_dir
{
    foreach ($d in $args)
    {
        if (-not $d)
        { continue
        }
        if (-not [System.IO.Directory]::Exists($d))
        { continue
        }
        if (-not ";$env:PATH;".Contains(";$d;"))
        {
            $env:PATH = "$d;$env:PATH"
        }
    }
}
function script:__shells_append_dir
{
    foreach ($d in $args)
    {
        if (-not $d)
        { continue
        }
        if (-not [System.IO.Directory]::Exists($d))
        { continue
        }
        if (-not ";$env:PATH;".Contains(";$d;"))
        {
            $env:PATH = "$env:PATH;$d"
        }
    }
}

# ---- Local user bins (lowest priority — appended) ---------------------------
__shells_append_dir `
    "$HOME\bin" `
    "$HOME\.local\bin" `
    "$HOME\Applications"

# ---- Tool installation dirs (prepended — leftmost wins) ---------------------
$__shells_cargo = if ($env:CARGO_HOME)
{ $env:CARGO_HOME
} else
{ "$HOME\.cargo"
}
__shells_prepend_dir `
    "$__shells_cargo\bin" `
    "$HOME\.opencode\bin"
Remove-Variable __shells_cargo -Scope Script -ErrorAction SilentlyContinue
# Cargo's pwsh env file (if present) augments PATH / RUSTUP_HOME / etc.
if ([System.IO.File]::Exists("$HOME\.cargo\env.ps1"))
{ . "$HOME\.cargo\env.ps1"
}

# ---- Language runtimes (uses env vars set in SECTION 4) ---------------------
# Node ecosystem
__shells_prepend_dir `
$(if ($env:BUN_INSTALL)
    { "$env:BUN_INSTALL\bin"
    }) `
$(if ($env:DENO_INSTALL)
    { "$env:DENO_INSTALL\bin"
    }) `
    $env:NPM_CONFIG_PREFIX `
    $env:PNPM_HOME `
    "$HOME\.yarn\bin" `
    "$env:LOCALAPPDATA\Yarn\bin" `
    "$HOME\.volta\bin" `
    "$HOME\.fnm"

# Python ecosystem
__shells_prepend_dir `
$(if ($env:PYENV)
    { "$env:PYENV\pyenv-win\bin"
    }) `
$(if ($env:PYENV)
    { "$env:PYENV\pyenv-win\shims"
    }) `
$(if ($env:ANACONDA_HOME)
    { $env:ANACONDA_HOME
    }) `
$(if ($env:ANACONDA_HOME)
    { "$env:ANACONDA_HOME\Scripts"
    }) `
$(if ($env:POETRY_HOME)
    { "$env:POETRY_HOME\bin"
    })

# Go
__shells_prepend_dir `
    "$env:GOPATH\bin" `
$(if ($env:GOROOT)
    { "$env:GOROOT\bin"
    })

# ---- VS Code (installer usually adds this, but explicit doesn't hurt) -------
__shells_append_dir `
    "$env:ProgramFiles\Microsoft VS Code\bin" `
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin"

Remove-Item function:__shells_prepend_dir, `
    function:__shells_append_dir -ErrorAction SilentlyContinue


# =============================================================================
# SECTION 6 — File listing & navigation
# =============================================================================
# Windows ships no `ls`/`grep` binaries (Get-ChildItem covers ls; Select-String
# covers grep). PS 5.1's default `ls` alias already maps to Get-ChildItem; we
# add ll/la/l/lt as wrappers with sensible flag sets.

function global:ll
{ Get-ChildItem -Force @args
}
function global:la
{ Get-ChildItem -Force @args
}
function global:l
{ Get-ChildItem @args
}
function global:lt
{ Get-ChildItem -Force @args | Sort-Object LastWriteTime
}

# ---- Directory navigation / reload / path -----------------------------------
# Function names with dots are valid identifiers in PS 5.1 (parsed as commands
# at command position, resolved via the function table).
function global:..
{ Set-Location ..
}
function global:...
{ Set-Location ..\..
}
function global:....
{ Set-Location ..\..\..
}
# `cd -` (toggle previous dir) is not supported in PS 5.1; use Push-Location
# / Pop-Location explicitly when you need a directory stack.

function global:md
{
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

function global:now
{ Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz'
}
function global:reload
{ . $PROFILE
}
function global:path
{ $env:PATH -split ';'
}


# =============================================================================
# SECTION 7 — System helpers (clipboard / file manager)
# =============================================================================
# Set-Clipboard / Get-Clipboard are built-in PS 5.0+ cmdlets; no extra modules
# needed. clip.exe is shipped with Windows but Set-Clipboard handles unicode
# correctly (clip.exe loses encoding via STDIN on some console code pages).

function global:clip
{ $input | Set-Clipboard
}
function global:paste
{ Get-Clipboard
}
function global:explorer
{ explorer.exe $args
}
function global:open
{ Start-Process @args
}


# =============================================================================
# SECTION 8 — Network helpers & HTTP proxy
# =============================================================================

# ---- IP / port helpers ------------------------------------------------------
function global:myip
{
    (Invoke-RestMethod -Uri 'https://ifconfig.me' -TimeoutSec 5).Trim()
}

function global:localip
{
    (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
        Select-Object -ExpandProperty IPAddress) -join ' '
}
function global:ports
{
    Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
        Select-Object LocalAddress, LocalPort, OwningProcess
}

# ---- Proxy toggle -----------------------------------------------------------
# Override PROXY_HOST / PROXY_PORT in ~\.envs (or your $PROFILE) before sourcing.
if (-not $env:PROXY_HOST)
{ $env:PROXY_HOST = '127.0.0.1'
}
if (-not $env:PROXY_PORT)
{ $env:PROXY_PORT = '3067'
}

# Usage:
#   proxy                    # http://$PROXY_HOST:$PROXY_PORT
#   proxy 10808              # default host, given port
#   proxy 192.168.1.1 7890   # explicit host and port
function global:proxy
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
        { Write-Error 'usage: proxy [[host] port]'; return
        }
    }
    $url = "http://${h}:${p}"
    $env:http_proxy = $url; $env:https_proxy = $url
    $env:HTTP_PROXY = $url; $env:HTTPS_PROXY = $url
    "proxy on  (${h}:${p})"
}

function global:socks5
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
        { Write-Error 'usage: socks5 [[host] port]'; return
        }
    }
    $url = "socks5://${h}:${p}"
    $env:all_proxy = $url; $env:ALL_PROXY = $url
    "socks5 on (${h}:${p})"
}

function global:unproxy
{
    foreach ($v in 'http_proxy','https_proxy','HTTP_PROXY','HTTPS_PROXY','all_proxy','ALL_PROXY')
    {
        [System.Environment]::SetEnvironmentVariable($v, $null)
    }
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

# mkdir -p <dir> && cd into it
function global:mkcd
{
    if (-not $args[0])
    { Write-Error 'usage: mkcd <dir>'; return
    }
    $null = New-Item -ItemType Directory -Force -Path $args[0] -ErrorAction Stop
    Set-Location -LiteralPath $args[0]
}

# Backup a file/dir to <name>.bak.<timestamp> (Copy-Item -Recurse preserves attrs)
function global:bak
{
    if (-not $args[0])
    { Write-Error 'usage: bak <path>'; return
    }
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    Copy-Item -LiteralPath $args[0] -Destination "$($args[0]).bak.$ts" -Recurse -Force
}

# Same as bak but moves instead of copies
function global:mbak
{
    if (-not $args[0])
    { Write-Error 'usage: mbak <path>'; return
    }
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    Move-Item -LiteralPath $args[0] -Destination "$($args[0]).bak.$ts"
}

# Weather report via wttr.in (optional location; default = geolocation by IP)
function global:weather
{
    Invoke-RestMethod -Uri "https://wttr.in/$($args[0])"
}

function global:uuid {
    (New-Guid).Guid
}

# =============================================================================
# SECTION 10 — Interactive prompt (function:prompt)
# =============================================================================
# Selection order:
#   1. starship  — if installed (best UX, written in Rust, very fast)
#   2. fast native — pure .NET / pwsh builtins for layout; Get-Date is a
#      cmdlet (no fork). Walks PWD upward looking for .git; zero git forks
#      outside repos.
#
# Opt-out: set SHELLS_NO_PROMPT=1 in ~\.envs before sourcing.
#
# Note: VT escape sequences (ANSI color) need to be enabled in the console
# host. Windows Terminal, ConEmu, VS Code, and Windows 10 1709+ conhost all
# support them by default. On older conhost without VT enabled, the escape
# sequences print literally — switch to Windows Terminal or set
# SHELLS_NO_PROMPT=1.

if (-not $env:SHELLS_NO_PROMPT)
{
    if (Get-Command starship -ErrorAction SilentlyContinue)
    {
        Invoke-Expression (& starship init powershell)
    } else
    {
        # Cache values that never change per-prompt.
        # ESC = [char]27 — works on both Windows PowerShell 5.1 and pwsh 7+.
        $e = [char]27
        $global:__shells_has_git = [bool](Get-Command git -ErrorAction SilentlyContinue)
        $global:__shells_user    = if ($env:USERNAME)
        { $env:USERNAME
        } else
        { $env:USER
        }
        $global:__shells_host    = [System.Net.Dns]::GetHostName()
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
            # Capture status FIRST — every other command resets $?/$LASTEXITCODE.
            $ok = $?; $rc = $LASTEXITCODE
            if ($null -eq $rc)
            { $rc = 0
            }
            if (-not $ok -and $rc -eq 0)
            { $rc = 1
            }

            $now = (Get-Date).ToString('HH:mm:ss')
            $cwd = $PWD.Path
            # Case-insensitive on Windows: C:\Users\Foo vs c:\users\foo are the
            # same physical path; OrdinalIgnoreCase keeps the `~` substitution
            # working regardless of how the user cd'd in.
            if ($cwd.StartsWith($HOME, [System.StringComparison]::OrdinalIgnoreCase))
            {
                $cwd = '~' + $cwd.Substring($HOME.Length)
            }

            # Python venv / conda env — env-var lookups, no fork
            $extra = ''
            if ($env:VIRTUAL_ENV)
            {
                $extra = " $($__shells_c_cyan)($(Split-Path -Leaf $env:VIRTUAL_ENV))$($__shells_c_reset)"
            } elseif ($env:CONDA_DEFAULT_ENV -and $env:CONDA_DEFAULT_ENV -ne 'base')
            {
                $extra = " $($__shells_c_cyan)($env:CONDA_DEFAULT_ENV)$($__shells_c_reset)"
            }

            # Git: walk PWD upwards looking for .git — zero forks if not in a repo.
            # `.git` is a directory in normal repos, a file in worktrees/submodules.
            if ($__shells_has_git)
            {
                $d = $PWD.Path
                while ($d)
                {
                    $g = "$d\.git"
                    if ([System.IO.Directory]::Exists($g) -or [System.IO.File]::Exists($g))
                    {
                        $branch = & git symbolic-ref --short HEAD 2>$null
                        if (-not $branch)
                        { $branch = & git rev-parse --short HEAD 2>$null
                        }
                        if ($branch)
                        {
                            # `git diff-index --quiet HEAD` is much faster than
                            # `git status --porcelain` on large repos (no scan).
                            & git diff-index --quiet HEAD -- 2>$null
                            $dirty = if ($LASTEXITCODE -ne 0)
                            { '*'
                            } else
                            { ''
                            }
                            $extra += " $($__shells_c_magenta)$branch$dirty$($__shells_c_reset)"
                        }
                        break
                    }
                    $parent = [System.IO.Path]::GetDirectoryName($d)
                    if (-not $parent -or $parent -eq $d)
                    { break
                    }
                    $d = $parent
                }
            }

            # Build prompt as one concatenated string — single write to host.
            $p = "$($__shells_c_gray)[$now]$($__shells_c_reset)"
            $p += " $($__shells_c_green)$__shells_user$($__shells_c_white)@$__shells_host$($__shells_c_reset)"
            $p += " $($__shells_c_blue)[$cwd]$($__shells_c_reset)"
            $p += $extra
            if ($rc -ne 0)
            { $p += " $($__shells_c_red)[$rc]$($__shells_c_reset)"
            }
            $p += "`n$($__shells_c_cyan)`$$($__shells_c_reset) "

            # Reset $LASTEXITCODE so the next prompt doesn't show a stale code.
            $global:LASTEXITCODE = 0
            $p
        }
    }
}
