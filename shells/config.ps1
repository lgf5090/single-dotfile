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
# `Set-PSReadLineOption` only exists when the PSReadLine module is loaded
# (default in pwsh 7+ console hosts; absent in ISE / non-interactive hosts).
if (Get-Command Set-PSReadLineOption -ErrorAction Ignore) {
    # 启用 Vi 模式
    Set-PSReadLineOption -EditMode Vi
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -PredictionSource History -ErrorAction Ignore

    # Two-table bind loop — one Set-PSReadLineKeyHandler call per binding is
    # unavoidable (the cmdlet has no batch mode), so we trade verbosity for
    # data-driven clarity. -ErrorAction Ignore silently skips functions that
    # don't exist in older PSReadLine builds.
    $__shells_vi_insert = [ordered]@{
        # 基本移动
        'Ctrl+a'        = 'BeginningOfLine'           # Ctrl+A 行首
        'Ctrl+e'        = 'EndOfLine'                 # Ctrl+E 行尾
        'Ctrl+f'        = 'ForwardChar'               # Ctrl+F 前进一个字符
        'Ctrl+b'        = 'BackwardChar'              # Ctrl+B 后退一个字符
        'Ctrl+d'        = 'DeleteChar'                # Ctrl+D 删除字符
        'Ctrl+h'        = 'BackwardDeleteChar'        # Ctrl+H 向前删除
        'Ctrl+k'        = 'ForwardDeleteLine'         # Ctrl+K 删除到行尾
        'Ctrl+u'        = 'BackwardDeleteLine'        # Ctrl+U 删除整行
        'Ctrl+w'        = 'BackwardKillWord'          # Ctrl+W 删除前一个单词
        'Ctrl+y'        = 'Yank'                      # Ctrl+Y 粘贴
        # 历史搜索
        'Ctrl+r'        = 'ReverseSearchHistory'      # Ctrl+R 反向搜索历史
        'Ctrl+s'        = 'ForwardSearchHistory'      # Ctrl+S 正向搜索历史
        'Ctrl+p'        = 'PreviousHistory'           # Ctrl+P 上一条历史
        'Ctrl+n'        = 'NextHistory'               # Ctrl+N 下一条历史
        # Alt 组合键
        'Alt+f'         = 'ForwardWord'               # Alt+F 前进一个单词
        'Alt+b'         = 'BackwardWord'              # Alt+B 后退一个单词
        'Alt+d'         = 'KillWord'                  # Alt+D 删除单词
        'Alt+Backspace' = 'BackwardKillWord'          # Alt+Backspace 删除前一个单词
        'Alt+.'         = 'YankLastArg'               # Alt+. 插入上一个命令的最后参数
        # 补全
        'Tab'           = 'Complete'                  # Tab 补全
        # 特殊编辑
        'Ctrl+t'        = 'SwapCharacters'            # Ctrl+T 交换字符
        'Alt+u'         = 'UpcaseWord'                # Alt+U 单词转大写
        'Alt+l'         = 'DowncaseWord'              # Alt+L 单词转小写
        'Alt+c'         = 'CapitalizeWord'            # Alt+C 单词首字母大写
        # (Ctrl+V "quoted-insert" omitted — PSReadLine has no equivalent.)
        # 箭头键 / 导航键
        'UpArrow'       = 'HistorySearchBackward'     # 上箭头
        'DownArrow'     = 'HistorySearchForward'      # 下箭头
        'Home'          = 'BeginningOfLine'           # Home
        'End'           = 'EndOfLine'                 # End
        'PageUp'        = 'HistorySearchBackward'     # Page Up
        'PageDown'      = 'HistorySearchForward'      # Page Down
        'Delete'        = 'DeleteChar'                # Delete
    }
    $__shells_vi_command = [ordered]@{
        'Ctrl+a'    = 'BeginningOfLine'               # Ctrl+A 行首
        'Ctrl+e'    = 'EndOfLine'                     # Ctrl+E 行尾
        '9'         = 'EndOfLine'                     # 9 行尾
        'Ctrl+f'    = 'ForwardChar'                   # Ctrl+F 前进
        'Ctrl+b'    = 'BackwardChar'                  # Ctrl+B 后退
        'Ctrl+d'    = 'DeleteChar'                    # Ctrl+D 删除字符
        'Ctrl+k'    = 'ForwardDeleteLine'             # Ctrl+K 删除到行尾
        'Ctrl+u'    = 'BackwardDeleteLine'            # Ctrl+U 删除整行
        'Ctrl+w'    = 'BackwardKillWord'              # Ctrl+W 删除单词
        'Ctrl+y'    = 'Yank'                          # Ctrl+Y 粘贴
        'Ctrl+r'    = 'ReverseSearchHistory'          # Ctrl+R 反向搜索
        'Ctrl+s'    = 'ForwardSearchHistory'          # Ctrl+S 正向搜索
        'Ctrl+p'    = 'PreviousHistory'               # Ctrl+P 上一条历史
        'Ctrl+n'    = 'NextHistory'                   # Ctrl+N 下一条历史
        'g,g'       = 'BeginningOfHistory'            # gg 跳到历史开头
        'G'         = 'EndOfHistory'                  # G 跳到历史结尾
        'v'         = 'ViEditVisually'                # v 进入临时编辑器
        'Alt+f'     = 'ForwardWord'                   # Alt+F 前进单词
        'Alt+b'     = 'BackwardWord'                  # Alt+B 后退单词
        '~'         = 'InvertCase'                    # ~ 切换大小写
        'UpArrow'   = 'PreviousHistory'               # 上箭头
        'DownArrow' = 'NextHistory'                   # 下箭头
        'Home'      = 'BeginningOfLine'               # Home
        'End'       = 'EndOfLine'                     # End
        'Delete'    = 'DeleteChar'                    # Delete
    }
    # Try/catch per binding — PSReadLine's ValidateSet on -Function rejects
    # unknown names *before* -ErrorAction takes effect, so a single unknown
    # function would otherwise abort the entire $PROFILE load.
    foreach ($e in $__shells_vi_insert.GetEnumerator()) {
        try { Set-PSReadLineKeyHandler -Chord $e.Key -ViMode Insert -Function $e.Value } catch { }
    }
    foreach ($e in $__shells_vi_command.GetEnumerator()) {
        try { Set-PSReadLineKeyHandler -Chord $e.Key -ViMode Command -Function $e.Value } catch { }
    }
    Remove-Variable -Name __shells_vi_insert, __shells_vi_command -Scope Script -ErrorAction Ignore
}


# =============================================================================
# SECTION 1 — OS detection ($SHELLS_OS)
# =============================================================================
# Pwsh 6+ exposes $IsWindows / $IsLinux / $IsMacOS; on Windows PowerShell 5.1
# those don't exist but the host is always Windows.

$SHELLS_OS = if ($IsMacOS) { 'macos' }
    elseif ($IsLinux) {
        if ([System.IO.File]::Exists('/proc/version') -and
            [System.IO.File]::ReadAllText('/proc/version') -match '(?i)microsoft|wsl') {
            'wsl'
        } else { 'linux' }
    }
    elseif ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) { 'windows' }
    else { 'unknown' }
$env:SHELLS_OS = $SHELLS_OS


# =============================================================================
# SECTION 2 — Shell environment (interactive pwsh behavior)
# =============================================================================
# All defaults use `if (-not $env:VAR) { ... }` so user values (parent env
# or ~/.envs loaded in SECTION 3) take precedence over what's set here.

# ---- Editor / pager ---------------------------------------------------------
if (-not $env:EDITOR) { $env:EDITOR = 'vim' }
if (-not $env:VISUAL) { $env:VISUAL = $env:EDITOR }
if (-not $env:PAGER)  { $env:PAGER  = 'less' }
if (-not $env:LESS)   { $env:LESS   = '-R -F -X' }

# (PowerShell uses PSReadLine history; bash HISTSIZE/HISTCONTROL don't apply.
#  History tuning lives in PSReadLine setup above and Set-PSReadLineOption.)

# ---- XDG Base Directory -----------------------------------------------------
if (-not $env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME = "$HOME/.config" }
if (-not $env:XDG_DATA_HOME)   { $env:XDG_DATA_HOME   = "$HOME/.local/share" }
if (-not $env:XDG_CACHE_HOME)  { $env:XDG_CACHE_HOME  = "$HOME/.cache" }
if (-not $env:XDG_STATE_HOME)  { $env:XDG_STATE_HOME  = "$HOME/.local/state" }

# ---- Cygwin / MSYS native symlink support -----------------------------------
# Native Windows pwsh ignores these, but subshells (msys2/git bash) launched
# from pwsh will inherit them — matches the bash config's intent.
switch ($SHELLS_OS) {
    'windows' { $env:MSYS = 'winsymlinks:nativestrict' }
}


# =============================================================================
# SECTION 3 — User file loaders (~/.envs and ~/.aliases)
# =============================================================================
# Loaded early so user-supplied env values override SECTION 2 / SECTION 4
# defaults (which use `if (-not $env:VAR) { ... }`).

# Cache the platform path separator (`:` on Unix, `;` on Windows) — used in
# every PATH operation below.
$__shells_psep = [System.IO.Path]::PathSeparator

# Dedup-prepend a `:`-separated list (envs.example format) onto $env:PATH.
# Existing PATH is always preserved at the tail — caller need not include {PATH}.
function script:__shells_path_prepend([string]$str) {
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $out = [System.Collections.Generic.List[string]]::new()
    # `:` is always the envs.example separator regardless of host OS.
    foreach ($p in ($str -split ':') + ($env:PATH -split $__shells_psep)) {
        if (-not $p) { continue }
        if (-not $seen.Add($p)) { continue }
        $out.Add($p)
    }
    $env:PATH = $out -join $__shells_psep
}

# Parse a KEY=VALUE file into the environment (PATH gets special handling).
function script:__shells_load_envs([string]$file) {
    if (-not [System.IO.File]::Exists($file)) { return }
    foreach ($line in [System.IO.File]::ReadAllLines($file)) {
        $line = $line.TrimStart()
        if (-not $line -or $line[0] -eq '#') { continue }
        $eq = $line.IndexOf('=')
        if ($eq -lt 1) { continue }
        $key = $line.Substring(0, $eq).TrimEnd()
        $val = $line.Substring($eq + 1)
        if ($key -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') { continue }
        # Strip a single pair of matching outer quotes
        if ($val.Length -ge 2) {
            $f = $val[0]; $l = $val[$val.Length - 1]
            if (($f -eq '"' -and $l -eq '"') -or ($f -eq "'" -and $l -eq "'")) {
                $val = $val.Substring(1, $val.Length - 2)
            }
        }
        $val = $val.Replace('{HOME}', $HOME).Replace('{PATH}', $env:PATH)
        if ($key -eq 'PATH') {
            __shells_path_prepend $val
        } else {
            [System.Environment]::SetEnvironmentVariable($key, $val)
        }
    }
}

# Parse a name=command file into PowerShell functions.
# PowerShell aliases (`Set-Alias`) cannot carry literal args, so each entry
# becomes a function `name { body @args }` — call semantics match bash aliases.
function script:__shells_load_aliases([string]$file) {
    if (-not [System.IO.File]::Exists($file)) { return }
    foreach ($line in [System.IO.File]::ReadAllLines($file)) {
        $line = $line.TrimStart()
        if (-not $line -or $line[0] -eq '#') { continue }
        $eq = $line.IndexOf('=')
        if ($eq -lt 1) { continue }
        $name = $line.Substring(0, $eq).TrimEnd()
        $body = $line.Substring($eq + 1)
        if ($name -notmatch '^[A-Za-z_][A-Za-z0-9_-]*$') { continue }
        if ($body.Length -ge 2) {
            $f = $body[0]; $l = $body[$body.Length - 1]
            if (($f -eq '"' -and $l -eq '"') -or ($f -eq "'" -and $l -eq "'")) {
                $body = $body.Substring(1, $body.Length - 2)
            }
        }
        # aliases.example forbids `name` colliding with the body's first word,
        # so plain `body @args` won't self-recurse.
        Set-Item -LiteralPath "function:global:$name" `
                 -Value ([scriptblock]::Create("$body `@args"))
    }
}

__shells_load_envs    "$HOME/.envs"
__shells_load_aliases "$HOME/.aliases"

Remove-Item function:__shells_path_prepend, `
            function:__shells_load_envs, `
            function:__shells_load_aliases -ErrorAction Ignore


# =============================================================================
# SECTION 4 — Language & toolchain environment variables (non-PATH)
# =============================================================================
# Detected paths (GOROOT/JAVA_HOME/ANACONDA_HOME/...) are skipped if already
# set, so users can override via ~/.envs (loaded above).

# ---- Node.js ecosystem ------------------------------------------------------
if (-not $env:NPM_CONFIG_PREFIX) { $env:NPM_CONFIG_PREFIX = "$HOME/.npm-global" }
if (-not $env:PNPM_HOME)         { $env:PNPM_HOME         = "$HOME/.pnpm-global" }
if ([System.IO.Directory]::Exists("$HOME/.fnm"))   { $env:FNM_DIR     = "$HOME/.fnm" }
if ([System.IO.Directory]::Exists("$HOME/.bun"))   { $env:BUN_INSTALL = "$HOME/.bun" }
if ([System.IO.Directory]::Exists("$HOME/.deno"))  { $env:DENO_INSTALL= "$HOME/.deno" }
# nvm has no native PowerShell support; users typically use nvm-windows (which
# manages PATH itself) or nvm.fish/bass on Unix. This config does NOT touch
# NVM_DIR — set it yourself in ~/.envs if you load nvm via a wrapper.

# ---- Go ---------------------------------------------------------------------
if (-not $env:GOPATH) { $env:GOPATH = "$HOME/go" }
if (-not $env:GOROOT) {
    foreach ($d in '/home/linuxbrew/.linuxbrew/opt/go/libexec',
                   '/opt/homebrew/opt/go/libexec',
                   '/usr/local/go',
                   "$HOME/.local/go") {
        if ([System.IO.Directory]::Exists($d)) { $env:GOROOT = $d; break }
    }
}

# ---- Python (Anaconda / Poetry / Pyenv detection) ---------------------------
if (-not $env:ANACONDA_HOME) {
    foreach ($d in "$HOME/anaconda3", "$HOME/miniconda3",
                   '/opt/anaconda3', '/opt/miniconda3') {
        if ([System.IO.Directory]::Exists($d)) { $env:ANACONDA_HOME = $d; break }
    }
}
if ([System.IO.Directory]::Exists("$HOME/.poetry")) { $env:POETRY_HOME = "$HOME/.poetry" }
if ([System.IO.Directory]::Exists("$HOME/.pyenv"))  { $env:PYENV_ROOT  = "$HOME/.pyenv" }

# ---- Java (JAVA_HOME only; JAVA_OPTS intentionally NOT set — pollutes JVMs) -
if (-not $env:JAVA_HOME) {
    if ([System.IO.File]::Exists('/usr/libexec/java_home')) {
        $env:JAVA_HOME = (& /usr/libexec/java_home 2>$null)
    } else {
        foreach ($d in '/usr/lib/jvm/default-java',
                       '/usr/lib/jvm/java-11-openjdk-amd64') {
            if ([System.IO.Directory]::Exists($d)) { $env:JAVA_HOME = $d; break }
        }
    }
}

# ---- Linux/WSL system libs (used by rustc / CUDA builds) --------------------
if ($SHELLS_OS -eq 'linux' -or $SHELLS_OS -eq 'wsl') {
    foreach ($p in '/usr/lib/x86_64-linux-gnu', '/usr/lib/aarch64-linux-gnu') {
        if (-not [System.IO.Directory]::Exists($p)) { continue }
        $env:LIBRARY_PATH    = if ($env:LIBRARY_PATH)    { "${p}:$env:LIBRARY_PATH" }    else { $p }
        $env:LD_LIBRARY_PATH = if ($env:LD_LIBRARY_PATH) { "${p}:$env:LD_LIBRARY_PATH" } else { $p }
        $env:RUSTFLAGS       = "-L $p"
        break
    }
}

# ---- Docker -----------------------------------------------------------------
if (-not $env:DOCKER_BUILDKIT)          { $env:DOCKER_BUILDKIT          = '1' }
if (-not $env:COMPOSE_DOCKER_CLI_BUILD) { $env:COMPOSE_DOCKER_CLI_BUILD = '1' }


# =============================================================================
# SECTION 5 — PATH (unified, sub-sections by purpose)
# =============================================================================

# ---- Helpers ----------------------------------------------------------------
# Variadic: each arg is added if it exists and isn't already in PATH.
# Semantics match repeated calls — `prepend A B C` ⇒ `C;B;A;…PATH` (C leftmost).
# Empty / missing args are silently filtered by the Directory.Exists check.
# Membership test uses substring search on a `sep`-wrapped PATH — single O(n)
# string scan, no allocation.
function script:__shells_prepend_dir {
    $sep = $__shells_psep
    foreach ($d in $args) {
        if (-not $d) { continue }
        if (-not [System.IO.Directory]::Exists($d)) { continue }
        if (-not "$sep$env:PATH$sep".Contains("$sep$d$sep")) {
            $env:PATH = "$d$sep$env:PATH"
        }
    }
}
function script:__shells_append_dir {
    $sep = $__shells_psep
    foreach ($d in $args) {
        if (-not $d) { continue }
        if (-not [System.IO.Directory]::Exists($d)) { continue }
        if (-not "$sep$env:PATH$sep".Contains("$sep$d$sep")) {
            $env:PATH = "$env:PATH$sep$d"
        }
    }
}

# ---- Local user bins (lowest priority — appended) ---------------------------
__shells_append_dir `
    "$HOME/.lmstudio/bin" `
    "$HOME/.local/bin" `
    "$HOME/bin" `
    "$HOME/Applications" `
    "$HOME/.local/Applications"

# ---- Tool installation dirs (prepended — leftmost wins) ---------------------
$__shells_cargo = if ($env:CARGO_HOME) { $env:CARGO_HOME } else { "$HOME/.cargo" }
__shells_prepend_dir `
    "$__shells_cargo/bin" `
    "$HOME/.rd/bin" `
    "$HOME/.opencode/bin"
Remove-Variable __shells_cargo -Scope Script -ErrorAction Ignore
# Cargo's pwsh env file (if present) augments PATH / RUSTUP_HOME / etc.
if ([System.IO.File]::Exists("$HOME/.cargo/env.ps1")) { . "$HOME/.cargo/env.ps1" }

# ---- Language runtimes (uses env vars set in SECTION 4) ---------------------
# Node ecosystem
__shells_prepend_dir `
    $(if ($env:BUN_INSTALL)  { "$env:BUN_INSTALL/bin" }) `
    $(if ($env:DENO_INSTALL) { "$env:DENO_INSTALL/bin" }) `
    "$env:NPM_CONFIG_PREFIX/bin" `
    $env:PNPM_HOME `
    "$HOME/.yarn/bin" `
    "$HOME/.config/yarn/global/node_modules/.bin" `
    "$HOME/.volta/bin" `
    "$HOME/.fnm" `
    "$HOME/.local/share/npm/bin"

# Python ecosystem
__shells_prepend_dir `
    $(if ($env:PYENV_ROOT)    { "$env:PYENV_ROOT/bin" }) `
    $(if ($env:ANACONDA_HOME) { "$env:ANACONDA_HOME/bin" }) `
    $(if ($env:POETRY_HOME)   { "$env:POETRY_HOME/bin" }) `
    "$HOME/.poetry/bin" `
    "$HOME/.local/pipx/bin"

# Go
__shells_prepend_dir `
    "$env:GOPATH/bin" `
    $(if ($env:GOROOT) { "$env:GOROOT/bin" })

# ---- Linux package-manager dirs (appended — low priority) -------------------
if ($SHELLS_OS -eq 'linux' -or $SHELLS_OS -eq 'wsl') {
    __shells_append_dir `
        '/snap/bin' `
        '/var/lib/flatpak/exports/bin' `
        "$HOME/.local/share/flatpak/exports/bin" `
        '/opt/bin'
}

# ---- Windows-environment integration ----------------------------------------
switch ($SHELLS_OS) {
    'wsl' {
        __shells_append_dir `
            '/mnt/c/Program Files/Microsoft VS Code/bin' `
            "/mnt/c/Users/$env:USER/AppData/Local/Programs/Microsoft VS Code/bin"
    }
    'windows' {
        # Native pwsh on Windows — VS Code is typically in %LOCALAPPDATA% or
        # Program Files. PATH usually already contains these via the installer,
        # but add them explicitly for parity.
        __shells_append_dir `
            "$env:ProgramFiles\Microsoft VS Code\bin" `
            "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin"
    }
}

# ---- Homebrew (auto-detect prefix; sets PATH/MANPATH/INFOPATH/HOMEBREW_*) ---
# Brew supports `shellenv pwsh` in newer versions; fall back to manual env
# setup for older installs (which only know bash/zsh/fish).
foreach ($__shells_brew in '/home/linuxbrew/.linuxbrew/bin/brew',
                           "$HOME/.linuxbrew/bin/brew",
                           '/opt/homebrew/bin/brew',
                           '/usr/local/bin/brew') {
    if (-not [System.IO.File]::Exists($__shells_brew)) { continue }
    $__shells_brew_init = & $__shells_brew shellenv pwsh 2>$null
    if ($LASTEXITCODE -eq 0 -and $__shells_brew_init) {
        $__shells_brew_init -join "`n" | Invoke-Expression
    } else {
        $prefix = (& $__shells_brew --prefix 2>$null | Select-Object -First 1)
        if ($prefix) {
            $env:HOMEBREW_PREFIX     = $prefix
            $env:HOMEBREW_CELLAR     = "$prefix/Cellar"
            $env:HOMEBREW_REPOSITORY = $prefix
            __shells_prepend_dir "$prefix/bin" "$prefix/sbin"
        }
    }
    break
}
Remove-Variable __shells_brew, __shells_brew_init -Scope Script -ErrorAction Ignore

Remove-Item function:__shells_prepend_dir, `
            function:__shells_append_dir -ErrorAction Ignore
Remove-Variable __shells_psep -ErrorAction Ignore


# =============================================================================
# SECTION 6 — File listing & navigation aliases
# =============================================================================
# PowerShell precedence is Alias > Function, but PSReadLine on pwsh 7+ doesn't
# ship `ls`/`grep` as aliases on Unix. On Windows pwsh, `ls` IS an alias for
# Get-ChildItem — we leave it untouched (no Unix ls binary anyway). On Unix we
# define functions that shell out to the resolved binary path; embedding the
# absolute path at function-creation time avoids both Get-Command-per-call cost
# and self-recursion risk.

# Resolve external commands once at startup; cache their full paths.
$__shells_ls   = (Get-Command ls    -CommandType Application -ErrorAction Ignore | Select-Object -First 1).Source
$__shells_grep = (Get-Command grep  -CommandType Application -ErrorAction Ignore | Select-Object -First 1).Source
$__shells_fgrep= (Get-Command fgrep -CommandType Application -ErrorAction Ignore | Select-Object -First 1).Source
$__shells_egrep= (Get-Command egrep -CommandType Application -ErrorAction Ignore | Select-Object -First 1).Source

# ---- ls family (OS-aware color flag) ----------------------------------------
if ($__shells_ls) {
    $f = if ($SHELLS_OS -eq 'macos' -or $SHELLS_OS -eq 'freebsd') {
        $env:CLICOLOR = '1'; '-G'
    } else { '--color=auto' }
    # Single source of truth: ll/la/l/lt call our `ls` function (which knows the
    # binary path). Definition order matters — `ls` first so the others resolve.
    Set-Item function:global:ls -Value ([scriptblock]::Create("& '$__shells_ls' $f `@args"))
    Set-Item function:global:ll -Value ([scriptblock]::Create("ls -alFh `@args"))
    Set-Item function:global:la -Value ([scriptblock]::Create("ls -A `@args"))
    Set-Item function:global:l  -Value ([scriptblock]::Create("ls -CF `@args"))
    Set-Item function:global:lt -Value ([scriptblock]::Create("ls -alFht `@args"))
}

# ---- grep family ------------------------------------------------------------
if ($__shells_grep)  { Set-Item function:global:grep  -Value ([scriptblock]::Create("& '$__shells_grep' --color=auto `@args")) }
if ($__shells_fgrep) { Set-Item function:global:fgrep -Value ([scriptblock]::Create("& '$__shells_fgrep' --color=auto `@args")) }
if ($__shells_egrep) { Set-Item function:global:egrep -Value ([scriptblock]::Create("& '$__shells_egrep' --color=auto `@args")) }

Remove-Variable __shells_ls, __shells_grep, __shells_fgrep, __shells_egrep -Scope Script -ErrorAction Ignore

# ---- Directory navigation / reload / path -----------------------------------
# Function names with dots are valid in PowerShell.
function global:..   { Set-Location .. }
function global:...  { Set-Location ../.. }
function global:.... { Set-Location ../../.. }
# `cd -` works natively in pwsh 7+ (toggle to previous dir). The bash `alias -`
# can't be replicated — `-` is not a valid PowerShell function name.

function global:now    { Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz' }
function global:reload { . $PROFILE }
# `path` prints $PATH entries one per line.
function global:path   { $env:PATH -split [System.IO.Path]::PathSeparator }


# =============================================================================
# SECTION 7 — OS-specific aliases (clipboard / file manager / package manager)
# =============================================================================
# Helper: define a function only if the underlying app exists. Avoids Get-Command
# at call time and lets us silently skip missing tools.
function script:__shells_wrap([string]$name, [string]$cmd, [string]$prefix = '') {
    $bin = (Get-Command $cmd -CommandType Application -ErrorAction Ignore | Select-Object -First 1).Source
    if ($bin) {
        Set-Item -LiteralPath "function:global:$name" `
                 -Value ([scriptblock]::Create("& '$bin' $prefix `@args"))
    }
    [bool]$bin
}

switch ($SHELLS_OS) {
    'macos' {
        $null = __shells_wrap clip   pbcopy
        $null = __shells_wrap paste  pbpaste
        function global:finder { open . @args }
        function global:brewup { brew update; brew upgrade; brew cleanup }
    }
    { $_ -eq 'linux' -or $_ -eq 'wsl' } {
        # Try Wayland → X11 → X11 fallback. First successful wrap wins.
        if (__shells_wrap clip wl-copy) {
            $null = __shells_wrap paste wl-paste
        } elseif (__shells_wrap clip xclip '-selection clipboard') {
            $null = __shells_wrap paste xclip '-selection clipboard -o'
        } elseif (__shells_wrap clip xsel '--clipboard --input') {
            $null = __shells_wrap paste xsel '--clipboard --output'
        }
        if ($SHELLS_OS -eq 'wsl') {
            function global:explorer { explorer.exe . @args }
        }
        if (Get-Command brew -ErrorAction Ignore) {
            function global:brewup { brew update; brew upgrade; brew cleanup }
        }
        if (Get-Command apt  -ErrorAction Ignore) {
            function global:aptup  { sudo apt update; sudo apt upgrade }
        }
    }
    'windows' {
        $null = __shells_wrap clip clip.exe
        # `open` mirrors bash's `start` — Start-Process is the pwsh equivalent
        # and handles URLs, files, and executables.
        function global:open { Start-Process @args }
    }
}

Remove-Item function:__shells_wrap -ErrorAction Ignore


# =============================================================================
# SECTION 8 — Network helpers & HTTP proxy
# =============================================================================

# ---- IP / port helpers ------------------------------------------------------
function global:myip { (Invoke-RestMethod -Uri 'https://ifconfig.me' -TimeoutSec 5).Trim() }

switch ($SHELLS_OS) {
    { $_ -eq 'linux' -or $_ -eq 'wsl' } {
        function global:localip { hostname -I }
        function global:ports   { ss -tulnp }
    }
    { $_ -eq 'macos' -or $_ -eq 'freebsd' } {
        function global:localip {
            $ip = ipconfig getifaddr en0 2>$null
            if (-not $ip) { $ip = ipconfig getifaddr en1 2>$null }
            $ip
        }
        function global:ports { lsof -nP -iTCP -sTCP:LISTEN }
    }
    'windows' {
        function global:localip {
            (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Ignore |
                Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
                Select-Object -ExpandProperty IPAddress) -join ' '
        }
        function global:ports {
            Get-NetTCPConnection -State Listen -ErrorAction Ignore |
                Select-Object LocalAddress, LocalPort, OwningProcess
        }
    }
}

# ---- Proxy toggle -----------------------------------------------------------
# Override PROXY_HOST / PROXY_PORT in ~/.envs (or your $PROFILE) before sourcing.
if (-not $env:PROXY_HOST) { $env:PROXY_HOST = '127.0.0.1' }
if (-not $env:PROXY_PORT) { $env:PROXY_PORT = '3067' }

# Usage:
#   proxy                    # http://$PROXY_HOST:$PROXY_PORT
#   proxy 10808              # default host, given port
#   proxy 192.168.1.1 7890   # explicit host and port
function global:proxy {
    $h = $env:PROXY_HOST; $p = $env:PROXY_PORT
    switch ($args.Count) {
        0 { }
        1 { $p = $args[0] }
        2 { $h = $args[0]; $p = $args[1] }
        default { Write-Error 'usage: proxy [[host] port]'; return }
    }
    $url = "http://${h}:${p}"
    $env:http_proxy = $url; $env:https_proxy = $url
    $env:HTTP_PROXY = $url; $env:HTTPS_PROXY = $url
    "proxy on  (${h}:${p})"
}

function global:socks5 {
    $h = $env:PROXY_HOST; $p = $env:PROXY_PORT
    switch ($args.Count) {
        0 { }
        1 { $p = $args[0] }
        2 { $h = $args[0]; $p = $args[1] }
        default { Write-Error 'usage: socks5 [[host] port]'; return }
    }
    $url = "socks5://${h}:${p}"
    $env:all_proxy = $url; $env:ALL_PROXY = $url
    "socks5 on (${h}:${p})"
}

function global:unproxy {
    foreach ($v in 'http_proxy','https_proxy','HTTP_PROXY','HTTPS_PROXY','all_proxy','ALL_PROXY') {
        [System.Environment]::SetEnvironmentVariable($v, $null)
    }
    'proxy off'
}

function global:proxyinfo {
    "http : $(if ($env:http_proxy)  { $env:http_proxy }  else { 'unset' })"
    "https: $(if ($env:https_proxy) { $env:https_proxy } else { 'unset' })"
    "socks: $(if ($env:all_proxy)   { $env:all_proxy }   else { 'unset' })"
}


# =============================================================================
# SECTION 9 — Custom utility functions
# =============================================================================

# mkdir -p <dir> && cd into it
function global:mkcd {
    if (-not $args[0]) { Write-Error 'usage: mkcd <dir>'; return }
    $null = New-Item -ItemType Directory -Force -Path $args[0] -ErrorAction Stop
    Set-Location -LiteralPath $args[0]
}

# Backup a file/dir to <name>.bak.<timestamp> (Copy-Item -Recurse preserves attrs)
function global:bak {
    if (-not $args[0]) { Write-Error 'usage: bak <path>'; return }
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    Copy-Item -LiteralPath $args[0] -Destination "$($args[0]).bak.$ts" -Recurse -Force
}

# Same as bak but moves instead of copies
function global:mbak {
    if (-not $args[0]) { Write-Error 'usage: mbak <path>'; return }
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    Move-Item -LiteralPath $args[0] -Destination "$($args[0]).bak.$ts"
}

# Weather report via wttr.in (optional location; default = geolocation by IP)
function global:weather {
    # Plain-text response — use Invoke-RestMethod to get the string body directly.
    Invoke-RestMethod -Uri "https://wttr.in/$($args[0])"
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
# Opt-out: set SHELLS_NO_PROMPT=1 in ~/.envs before sourcing.

if (-not $env:SHELLS_NO_PROMPT) {
    if (Get-Command starship -ErrorAction Ignore) {
        Invoke-Expression (& starship init powershell)
    } elseif (Get-Command Set-PSReadLineOption -ErrorAction Ignore) {
        # Cache values that never change per-prompt:
        #   - whether git is on PATH (saves a Get-Command per prompt)
        #   - user / hostname (env-var / native call done once)
        #   - ANSI color escapes (string consts, cheaper than recomputing)
        # ESC = [char]27 — compatible with both Windows PowerShell 5.1 and pwsh 7+.
        $e = [char]27
        $global:__shells_has_git = [bool](Get-Command git -ErrorAction Ignore)
        $global:__shells_user    = if ($env:USER) { $env:USER } else { $env:USERNAME }
        $global:__shells_host    = [System.Net.Dns]::GetHostName()
        $global:__shells_c_reset   = "$e[0m"
        $global:__shells_c_gray    = "$e[90m"
        $global:__shells_c_red     = "$e[31m"
        $global:__shells_c_green   = "$e[32m"
        $global:__shells_c_blue    = "$e[34m"
        $global:__shells_c_magenta = "$e[35m"
        $global:__shells_c_cyan    = "$e[36m"
        $global:__shells_c_white   = "$e[97m"

        function global:prompt {
            # Capture status FIRST — every other command resets $?/$LASTEXITCODE.
            $ok = $?; $rc = $LASTEXITCODE
            if ($null -eq $rc) { $rc = 0 }
            if (-not $ok -and $rc -eq 0) { $rc = 1 }

            $now = (Get-Date).ToString('HH:mm:ss')
            $cwd = $PWD.Path
            if ($cwd.StartsWith($HOME, [System.StringComparison]::Ordinal)) {
                $cwd = '~' + $cwd.Substring($HOME.Length)
            }

            # Python venv / conda env — env-var lookups, no fork
            $extra = ''
            if ($env:VIRTUAL_ENV) {
                $extra = " $($__shells_c_cyan)($(Split-Path -Leaf $env:VIRTUAL_ENV))$($__shells_c_reset)"
            } elseif ($env:CONDA_DEFAULT_ENV -and $env:CONDA_DEFAULT_ENV -ne 'base') {
                $extra = " $($__shells_c_cyan)($env:CONDA_DEFAULT_ENV)$($__shells_c_reset)"
            }

            # Git: walk PWD upwards looking for .git — zero forks if not in a repo.
            # `.git` is a directory in normal repos, a file in worktrees/submodules.
            if ($__shells_has_git) {
                $d = $PWD.Path
                while ($d) {
                    $g = "$d/.git"
                    if ([System.IO.Directory]::Exists($g) -or [System.IO.File]::Exists($g)) {
                        $branch = & git symbolic-ref --short HEAD 2>$null
                        if (-not $branch) { $branch = & git rev-parse --short HEAD 2>$null }
                        if ($branch) {
                            # `git diff-index --quiet HEAD` is much faster than
                            # `git status --porcelain` on large repos (no scan).
                            & git diff-index --quiet HEAD -- 2>$null
                            $dirty = if ($LASTEXITCODE -ne 0) { '*' } else { '' }
                            $extra += " $($__shells_c_magenta)$branch$dirty$($__shells_c_reset)"
                        }
                        break
                    }
                    $parent = [System.IO.Path]::GetDirectoryName($d)
                    if (-not $parent -or $parent -eq $d) { break }
                    $d = $parent
                }
            }

            # Build prompt as one concatenated string — single write to host.
            $p = "$($__shells_c_gray)[$now]$($__shells_c_reset)"
            $p += " $($__shells_c_green)$__shells_user$($__shells_c_white)@$__shells_host$($__shells_c_reset)"
            $p += " $($__shells_c_blue)[$cwd]$($__shells_c_reset)"
            $p += $extra
            if ($rc -ne 0) { $p += " $($__shells_c_red)[$rc]$($__shells_c_reset)" }
            $p += "`n$($__shells_c_cyan)`$$($__shells_c_reset) "

            # Reset $LASTEXITCODE so the next prompt doesn't show a stale code.
            $global:LASTEXITCODE = 0
            $p
        }
    }
}
