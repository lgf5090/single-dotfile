# =============================================================================
# config.nu — single-file nushell configuration
#
# === ONE-TIME BOOTSTRAP (required before first source) =======================
# nushell parses `source` at parse-time, so the alias cache file must exist
# before this config is loaded. From inside nushell, run ONCE:
#
#     mkdir ($nu.cache-dir | path join "shells")
#     touch ($nu.cache-dir | path join "shells" "aliases.nu")
#
# Then add to your $nu.config-path:
#
#     source /path/to/config.nu
#
# Reads (if present, silently skipped otherwise):
#     ~/.envs       — shared environment variables (loaded at runtime)
#     ~/.aliases    — shared aliases               (parse-time; needs regen)
#
# After editing ~/.aliases, run `shells-regen-aliases` then restart nu
# (nushell caches alias defs at parse time; re-source alone won't pick them up).
#
# Self-contained: does NOT source any other file in this repo.
# Targets nushell 0.100+ (uses $nu.home-dir/cache-dir, `path type`, append/uniq).
# =============================================================================

# Vi mode + reedline tuning
$env.config.edit_mode = "vi"
$env.config.show_banner = false
$env.config.history.max_size = 100_000
$env.config.history.sync_on_enter = true
$env.config.history.file_format = "sqlite"

# Two-table keybinding append — every record runs through reedline at startup,
# so each entry should map to an event/edit that exists in the current nushell
# version. Anything not nu-native (bash's `gg`/`G` history-history-jump,
# `quoted-insert`, `yank-last-arg`) is intentionally omitted.
$env.config.keybindings = ($env.config.keybindings | append [
    # ---- Insert/Normal: 基本移动 -------------------------------------------
    { name: shells_bol     modifier: control  keycode: char_a   mode: [vi_insert vi_normal emacs] event: { edit: MoveToLineStart } }   # Ctrl+A 行首
    { name: shells_eol     modifier: control  keycode: char_e   mode: [vi_insert vi_normal emacs] event: { edit: MoveToLineEnd } }     # Ctrl+E 行尾
    { name: shells_fwd     modifier: control  keycode: char_f   mode: [vi_insert vi_normal emacs] event: { edit: MoveRight } }         # Ctrl+F 前进
    { name: shells_bwd     modifier: control  keycode: char_b   mode: [vi_insert vi_normal emacs] event: { edit: MoveLeft } }          # Ctrl+B 后退
    { name: shells_del     modifier: control  keycode: char_d   mode: [vi_insert]                 event: { edit: Delete } }            # Ctrl+D 删除字符
    { name: shells_bksp    modifier: control  keycode: char_h   mode: [vi_insert vi_normal emacs] event: { edit: Backspace } }         # Ctrl+H 向前删除
    { name: shells_killln  modifier: control  keycode: char_k   mode: [vi_insert vi_normal emacs] event: { edit: CutToLineEnd } }      # Ctrl+K 删除到行尾
    { name: shells_unixln  modifier: control  keycode: char_u   mode: [vi_insert vi_normal emacs] event: { edit: CutFromLineStart } }  # Ctrl+U 删除整行
    { name: shells_killw   modifier: control  keycode: char_w   mode: [vi_insert vi_normal emacs] event: { edit: BackspaceWord } }     # Ctrl+W 删除前一个单词
    { name: shells_yank    modifier: control  keycode: char_y   mode: [vi_insert vi_normal emacs] event: { edit: PasteCutBufferBefore } } # Ctrl+Y 粘贴

    # ---- 历史搜索 ----------------------------------------------------------
    # Ctrl+R 打开 history menu (nu reedline's interactive search; closest to bash's reverse-i-search)
    { name: shells_hist_menu modifier: control  keycode: char_r mode: [vi_insert vi_normal emacs] event: { send: menu name: history_menu } }
    { name: shells_prev_hist modifier: control  keycode: char_p mode: [vi_insert vi_normal emacs] event: { send: PreviousHistory } }   # Ctrl+P
    { name: shells_next_hist modifier: control  keycode: char_n mode: [vi_insert vi_normal emacs] event: { send: NextHistory } }       # Ctrl+N

    # ---- Alt 组合键 --------------------------------------------------------
    { name: shells_fwdw    modifier: alt      keycode: char_f   mode: [vi_insert vi_normal emacs] event: { edit: MoveWordRight } }     # Alt+F
    { name: shells_bwdw    modifier: alt      keycode: char_b   mode: [vi_insert vi_normal emacs] event: { edit: MoveWordLeft } }      # Alt+B
    { name: shells_delw    modifier: alt      keycode: char_d   mode: [vi_insert vi_normal emacs] event: { edit: DeleteWord } }        # Alt+D
    { name: shells_bkspw   modifier: alt      keycode: backspace mode: [vi_insert vi_normal emacs] event: { edit: BackspaceWord } }     # Alt+Backspace

    # ---- 补全 --------------------------------------------------------------
    { name: shells_tab     modifier: none     keycode: tab      mode: [vi_insert emacs]           event: { until: [{ send: menu name: completion_menu }, { send: menunext }, { edit: Complete }] } }

    # ---- 特殊编辑 ----------------------------------------------------------
    { name: shells_xchars  modifier: control  keycode: char_t   mode: [vi_insert vi_normal emacs] event: { edit: SwapGraphemes } }     # Ctrl+T 交换字符
    { name: shells_xwords  modifier: alt      keycode: char_t   mode: [vi_insert vi_normal emacs] event: { edit: SwapWords } }         # Alt+T 交换单词
    { name: shells_upw     modifier: alt      keycode: char_u   mode: [vi_insert vi_normal emacs] event: { edit: UppercaseWord } }     # Alt+U 单词转大写
    { name: shells_dnw     modifier: alt      keycode: char_l   mode: [vi_insert vi_normal emacs] event: { edit: LowercaseWord } }     # Alt+L 单词转小写
    { name: shells_capc    modifier: alt      keycode: char_c   mode: [vi_insert vi_normal emacs] event: { edit: CapitalizeChar } }    # Alt+C 单词首字母大写

    # ---- Vi 风格增强 -------------------------------------------------------
    { name: shells_edit    modifier: none     keycode: char_v   mode: [vi_normal]                 event: { send: OpenEditor } }        # v 进入临时编辑器 ($EDITOR)

    # ---- 箭头键 / 导航键 ---------------------------------------------------
    { name: shells_home    modifier: none     keycode: home     mode: [vi_insert vi_normal emacs] event: { edit: MoveToLineStart } }   # Home
    { name: shells_end_    modifier: none     keycode: end      mode: [vi_insert vi_normal emacs] event: { edit: MoveToLineEnd } }     # End
    { name: shells_del2    modifier: none     keycode: delete   mode: [vi_insert vi_normal emacs] event: { edit: Delete } }            # Delete
])


# =============================================================================
# SECTION 1 — OS detection ($SHELLS_OS)
# =============================================================================
# $nu.os-info is a struct populated at startup — no fork to `uname`.

$env.SHELLS_OS = (
    match $nu.os-info.name {
        "linux" => (
            if ("/proc/version" | path exists) and (
                open --raw /proc/version | str downcase | (
                    ($in | str contains "microsoft") or ($in | str contains "wsl")
                )
            ) { "wsl" } else { "linux" }
        )
        "macos" => "macos"
        "freebsd" => "freebsd"
        "windows" => "windows"
        _ => "unknown"
    }
)


# =============================================================================
# SECTION 2 — Shell environment (interactive nushell behavior)
# =============================================================================
# All defaults use `if ($env.X? | is-empty) { ... }` so user values (parent env
# or ~/.envs loaded in SECTION 3) take precedence over what's set here.

# ---- Editor / pager ---------------------------------------------------------
if ($env.EDITOR? | is-empty) { $env.EDITOR = "vim" }
if ($env.VISUAL? | is-empty) { $env.VISUAL = $env.EDITOR }
if ($env.PAGER?  | is-empty) { $env.PAGER  = "less" }
if ($env.LESS?   | is-empty) { $env.LESS   = "-R -F -X" }

# ---- XDG Base Directory -----------------------------------------------------
if ($env.XDG_CONFIG_HOME? | is-empty) { $env.XDG_CONFIG_HOME = ($nu.home-dir | path join ".config") }
if ($env.XDG_DATA_HOME?   | is-empty) { $env.XDG_DATA_HOME   = ($nu.home-dir | path join ".local" "share") }
if ($env.XDG_CACHE_HOME?  | is-empty) { $env.XDG_CACHE_HOME  = ($nu.home-dir | path join ".cache") }
if ($env.XDG_STATE_HOME?  | is-empty) { $env.XDG_STATE_HOME  = ($nu.home-dir | path join ".local" "state") }

# ---- Cygwin / MSYS native symlink support -----------------------------------
# Native Windows nu ignores these, but subshells (msys2/git bash) launched
# from nu will inherit them — matches the bash config's intent.
match $env.SHELLS_OS {
    "cygwin"  => { $env.CYGWIN = "winsymlinks:native"; $env.MSYS = "winsymlinks:nativestrict" }
    "windows" => { $env.MSYS = "winsymlinks:nativestrict" }
    _ => {}
}


# =============================================================================
# SECTION 3 — User file loaders (~/.envs and ~/.aliases)
# =============================================================================
# Loaded early so user-supplied env values override SECTION 2 / SECTION 4
# defaults.
#
# ~/.aliases needs the parse-time alias-cache workaround — see file header
# and SECTION 12 (`shells-regen-aliases` + `source` at the very bottom).

# Dedup-prepend a `:`-separated list onto $env.PATH (leftmost wins).
# Existing PATH is always preserved at the tail — caller need not include {PATH}.
def --env __shells_path_prepend [str: string] {
    $env.PATH = (
        $str | split row ":"
        | where { |x| ($x | is-not-empty) }
        | append $env.PATH
        | uniq
    )
}

# Parse a KEY=VALUE file into the environment (PATH gets special handling).
def --env __shells_load_envs [file: string] {
    if not ($file | path exists) { return }
    for line in (open --raw $file | lines) {
        mut line = ($line | str trim --left)
        if ($line | is-empty) or ($line | str starts-with "#") { continue }
        if not ($line | str contains "=") { continue }
        let eq = ($line | str index-of "=")
        let key = ($line | str substring ..($eq - 1) | str trim --right)
        mut val = ($line | str substring ($eq + 1).. | str trim)
        # Validate key: [A-Za-z_][A-Za-z0-9_]*
        if ($key | parse --regex '^[A-Za-z_][A-Za-z0-9_]*$' | is-empty) { continue }
        # Strip a single pair of matching outer quotes
        if ($val | str length) >= 2 {
            let f = ($val | str substring 0..0)
            let l = ($val | str substring (-1..))
            if (($f == '"' and $l == '"') or ($f == "'" and $l == "'")) {
                $val = ($val | str substring 1..-2)
            }
        }
        $val = (
            $val
            | str replace --all "{HOME}" $nu.home-dir
            | str replace --all "{PATH}" ($env.PATH | str join (char path_sep))
        )
        if $key == "PATH" {
            __shells_path_prepend $val
        } else {
            load-env { ($key): $val }
        }
    }
}

__shells_load_envs ($nu.home-dir | path join ".envs")


# =============================================================================
# SECTION 4 — Language & toolchain environment variables (non-PATH)
# =============================================================================
# Detected paths (GOROOT/JAVA_HOME/ANACONDA_HOME/...) are skipped if already
# set, so users can override via ~/.envs (loaded above).

# Returns the first existing directory from $args, or null.
def __shells_first_dir [...args: string] {
    for d in $args {
        if (($d | is-not-empty) and ($d | path exists) and (($d | path type) == "dir")) {
            return $d
        }
    }
    null
}

# ---- Node.js ecosystem ------------------------------------------------------
if ($env.NPM_CONFIG_PREFIX? | is-empty) { $env.NPM_CONFIG_PREFIX = ($nu.home-dir | path join ".npm-global") }
if ($env.PNPM_HOME?         | is-empty) { $env.PNPM_HOME         = ($nu.home-dir | path join ".pnpm-global") }
if (($nu.home-dir | path join ".fnm")          | path exists)   { $env.FNM_DIR      = ($nu.home-dir | path join ".fnm") }
if (($nu.home-dir | path join ".bun")          | path exists)   { $env.BUN_INSTALL  = ($nu.home-dir | path join ".bun") }
if (($nu.home-dir | path join ".deno")         | path exists)   { $env.DENO_INSTALL = ($nu.home-dir | path join ".deno") }
# nvm has no native nushell support (nvm.sh is bash-only). nu users typically
# use fnm or volta instead; set NVM_DIR yourself in ~/.envs if you load nvm via
# a wrapper from another shell.

# ---- Go ---------------------------------------------------------------------
if ($env.GOPATH? | is-empty) { $env.GOPATH = ($nu.home-dir | path join "go") }
if ($env.GOROOT? | is-empty) {
    let d = (__shells_first_dir
        "/home/linuxbrew/.linuxbrew/opt/go/libexec"
        "/opt/homebrew/opt/go/libexec"
        "/usr/local/go"
        ($nu.home-dir | path join ".local" "go"))
    if ($d | is-not-empty) { $env.GOROOT = $d }
}

# ---- Python (Anaconda / Poetry / Pyenv detection) ---------------------------
if ($env.ANACONDA_HOME? | is-empty) {
    let d = (__shells_first_dir
        ($nu.home-dir | path join "anaconda3")
        ($nu.home-dir | path join "miniconda3")
        "/opt/anaconda3"
        "/opt/miniconda3")
    if ($d | is-not-empty) { $env.ANACONDA_HOME = $d }
}
if (($nu.home-dir | path join ".poetry") | path exists) { $env.POETRY_HOME = ($nu.home-dir | path join ".poetry") }
if (($nu.home-dir | path join ".pyenv")  | path exists) { $env.PYENV_ROOT  = ($nu.home-dir | path join ".pyenv") }

# ---- Java (JAVA_HOME only; JAVA_OPTS intentionally NOT set — pollutes JVMs) -
if ($env.JAVA_HOME? | is-empty) {
    if ("/usr/libexec/java_home" | path exists) {
        $env.JAVA_HOME = (try { ^/usr/libexec/java_home | str trim } catch { "" })
        if ($env.JAVA_HOME | is-empty) { hide-env JAVA_HOME }
    } else {
        let d = (__shells_first_dir "/usr/lib/jvm/default-java" "/usr/lib/jvm/java-11-openjdk-amd64")
        if ($d | is-not-empty) { $env.JAVA_HOME = $d }
    }
}

# ---- Linux/WSL system libs (used by rustc / CUDA builds) --------------------
if ($env.SHELLS_OS in ["linux" "wsl"]) {
    for p in ["/usr/lib/x86_64-linux-gnu" "/usr/lib/aarch64-linux-gnu"] {
        if not ($p | path exists) { continue }
        $env.LIBRARY_PATH    = (if ($env.LIBRARY_PATH?    | is-not-empty) { $"($p):($env.LIBRARY_PATH)" }    else { $p })
        $env.LD_LIBRARY_PATH = (if ($env.LD_LIBRARY_PATH? | is-not-empty) { $"($p):($env.LD_LIBRARY_PATH)" } else { $p })
        $env.RUSTFLAGS       = $"-L ($p)"
        break
    }
}

# ---- Docker -----------------------------------------------------------------
if ($env.DOCKER_BUILDKIT?          | is-empty) { $env.DOCKER_BUILDKIT          = "1" }
if ($env.COMPOSE_DOCKER_CLI_BUILD? | is-empty) { $env.COMPOSE_DOCKER_CLI_BUILD = "1" }


# =============================================================================
# SECTION 5 — PATH (unified, sub-sections by purpose)
# =============================================================================

# ---- Helpers ----------------------------------------------------------------
# Variadic: each arg is added if it exists (and is a dir) and isn't already in PATH.
# Semantics match repeated calls — `prepend A B C` ⇒ `[C B A …PATH]` (C leftmost).
# `uniq` keeps first occurrence, so prepended items always win.
def --env __shells_prepend_dir [...dirs: string] {
    for d in $dirs {
        if (($d | is-not-empty) and ($d | path exists) and (($d | path type) == "dir")) {
            $env.PATH = ($env.PATH | prepend $d | uniq)
        }
    }
}
def --env __shells_append_dir [...dirs: string] {
    for d in $dirs {
        if (($d | is-not-empty) and ($d | path exists) and (($d | path type) == "dir")) {
            $env.PATH = ($env.PATH | append $d | uniq)
        }
    }
}

# ---- Local user bins (lowest priority — appended) ---------------------------
__shells_append_dir ...[
    ($nu.home-dir | path join ".lmstudio" "bin")
    ($nu.home-dir | path join ".local" "bin")
    ($nu.home-dir | path join "bin")
    ($nu.home-dir | path join "Applications")
    ($nu.home-dir | path join ".local" "Applications")
]

# ---- Tool installation dirs (prepended — leftmost wins) ---------------------
let __shells_cargo = ($env.CARGO_HOME? | default ($nu.home-dir | path join ".cargo"))
__shells_prepend_dir ...[
    ($__shells_cargo | path join "bin")
    ($nu.home-dir | path join ".rd" "bin")
    ($nu.home-dir | path join ".opencode" "bin")
]
# Cargo's bash env file just adds $CARGO_HOME/bin to PATH and exports
# RUSTUP_HOME / etc. — the PATH bit is already handled above, so we skip
# sourcing it. (nushell `source` is parse-time; conditional source of a
# possibly-missing file would crash parse.)

# ---- Language runtimes (uses env vars set in SECTION 4) ---------------------
# Node ecosystem
__shells_prepend_dir ...[
    (if ($env.BUN_INSTALL?  | is-not-empty) { $env.BUN_INSTALL  | path join "bin" } else { "" })
    (if ($env.DENO_INSTALL? | is-not-empty) { $env.DENO_INSTALL | path join "bin" } else { "" })
    ($env.NPM_CONFIG_PREFIX | path join "bin")
    $env.PNPM_HOME
    ($nu.home-dir | path join ".yarn" "bin")
    ($nu.home-dir | path join ".config" "yarn" "global" "node_modules" ".bin")
    ($nu.home-dir | path join ".volta" "bin")
    ($nu.home-dir | path join ".fnm")
    ($nu.home-dir | path join ".local" "share" "npm" "bin")
]

# Python ecosystem
__shells_prepend_dir ...[
    (if ($env.PYENV_ROOT?    | is-not-empty) { $env.PYENV_ROOT    | path join "bin" } else { "" })
    (if ($env.ANACONDA_HOME? | is-not-empty) { $env.ANACONDA_HOME | path join "bin" } else { "" })
    (if ($env.POETRY_HOME?   | is-not-empty) { $env.POETRY_HOME   | path join "bin" } else { "" })
    ($nu.home-dir | path join ".poetry" "bin")
    ($nu.home-dir | path join ".local" "pipx" "bin")
]

# Go
__shells_prepend_dir ...[
    ($env.GOPATH | path join "bin")
    (if ($env.GOROOT? | is-not-empty) { $env.GOROOT | path join "bin" } else { "" })
]

# ---- Linux package-manager dirs (appended — low priority) -------------------
if $env.SHELLS_OS in ["linux" "wsl"] {
    __shells_append_dir ...[
        "/snap/bin"
        "/var/lib/flatpak/exports/bin"
        ($nu.home-dir | path join ".local" "share" "flatpak" "exports" "bin")
        "/opt/bin"
    ]
}

# ---- Windows-environment integration ----------------------------------------
match $env.SHELLS_OS {
    "wsl" => {
        __shells_append_dir ...[
            "/mnt/c/Program Files/Microsoft VS Code/bin"
            $"/mnt/c/Users/($env.USER? | default '')/AppData/Local/Programs/Microsoft VS Code/bin"
        ]
    }
    "cygwin" => {
        __shells_prepend_dir "/mingw64/bin"
        __shells_append_dir ...[
            "/cygdrive/c/Program Files/Microsoft VS Code/bin"
            $"/cygdrive/c/Users/($env.USER? | default '')/AppData/Local/Programs/Microsoft VS Code/bin"
        ]
    }
    "windows" => {
        __shells_prepend_dir "/mingw64/bin"
        __shells_append_dir ...[
            "/c/Program Files/Microsoft VS Code/bin"
            $"/c/Users/($env.USER? | default '')/AppData/Local/Programs/Microsoft VS Code/bin"
        ]
    }
    _ => {}
}

# ---- Homebrew (auto-detect prefix; sets PATH + HOMEBREW_*) -----------------
# Manual prefix detection only — `source-env $brew_init` would need parse-time
# file existence, which we can't guarantee on first install.
for brew in [
    "/home/linuxbrew/.linuxbrew/bin/brew"
    ($nu.home-dir | path join ".linuxbrew" "bin" "brew")
    "/opt/homebrew/bin/brew"
    "/usr/local/bin/brew"
] {
    if ($brew | path exists) {
        let prefix = (try { ^$brew --prefix | str trim } catch { "" })
        if ($prefix | is-not-empty) {
            $env.HOMEBREW_PREFIX     = $prefix
            $env.HOMEBREW_CELLAR     = ($prefix | path join "Cellar")
            $env.HOMEBREW_REPOSITORY = $prefix
            __shells_prepend_dir ($prefix | path join "bin") ($prefix | path join "sbin")
        }
        break
    }
}


# =============================================================================
# SECTION 6 — File listing & navigation aliases
# =============================================================================
# nushell's `ls` is a built-in returning a structured table — we do NOT
# shadow it. The bash convenience flags map to nu's `ls` options:
#   ll → long listing with hidden
#   la → include hidden
#   l  → default
#   lt → long listing sorted by mtime (descending = newest first)
# These are aliases so they're parse-time fast (no def wrapper overhead).

alias ll = ls -la
alias la = ls -a
alias l  = ls

# `lt` needs a sort, so it's a function (alias bodies are single commands).
def lt [path?: string] {
    let items = (if ($path | is-empty) { ls -la } else { ls -la $path })
    $items | sort-by modified --reverse
}

# grep family — use external ^grep (nu has its own `find` for tables).
alias grep  = ^grep --color=auto
alias fgrep = ^fgrep --color=auto
alias egrep = ^egrep --color=auto

alias md = mkdir

alias cls = clear

# Directory nav aliases (`..`, `...`, `....`) and `-` (cd back) aren't valid
# nushell identifiers, so `cd ..` is the closest equivalent. nu's `cd -`
# toggles to the previous directory natively.

def now    [] { date now | format date "%Y-%m-%dT%H:%M:%S%z" }
def reload [] { exec nu }                       # re-exec nushell (full reload)
def path   [] { $env.PATH }                     # nu auto-formats the list


# =============================================================================
# SECTION 7 — OS-specific aliases (clipboard / file manager / package manager)
# =============================================================================
# Defined as `def`s instead of `alias`es so the OS dispatch happens at call
# time (the platform is only known after $env.SHELLS_OS is computed in
# SECTION 1, which is runtime — after parse). Cost per call: one match on a
# small string. Negligible.

def --wrapped clip [...args: string] {
    match $env.SHELLS_OS {
        "macos" => { $in | ^pbcopy ...$args }
        "linux" | "wsl" => {
            if      (which wl-copy | is-not-empty) { $in | ^wl-copy ...$args }
            else if (which xclip   | is-not-empty) { $in | ^xclip -selection clipboard ...$args }
            else if (which xsel    | is-not-empty) { $in | ^xsel --clipboard --input ...$args }
            else { error make { msg: "no clipboard helper (install wl-clipboard / xclip / xsel)" } }
        }
        "cygwin" | "windows" => { $in | ^clip.exe ...$args }
        _ => { error make { msg: $"clip: unsupported OS ($env.SHELLS_OS)" } }
    }
}

def --wrapped paste [...args: string] {
    match $env.SHELLS_OS {
        "macos" => { ^pbpaste ...$args }
        "linux" | "wsl" => {
            if      (which wl-paste | is-not-empty) { ^wl-paste ...$args }
            else if (which xclip    | is-not-empty) { ^xclip -selection clipboard -o ...$args }
            else if (which xsel     | is-not-empty) { ^xsel --clipboard --output ...$args }
            else { error make { msg: "no clipboard helper (install wl-clipboard / xclip / xsel)" } }
        }
        _ => { error make { msg: $"paste: unsupported OS ($env.SHELLS_OS)" } }
    }
}

# `open` is a nushell built-in (reads files into structured data) — we don't
# shadow it. macOS users can call `^open .` directly to open Finder. WSL users
# get an `explorer` helper since explorer.exe isn't standardly aliased.
if $env.SHELLS_OS == "wsl" {
    def explorer [] { ^explorer.exe . }
}

def brewup [] { ^brew update; ^brew upgrade; ^brew cleanup }
def aptup  [] { ^sudo apt update; ^sudo apt upgrade }


# =============================================================================
# SECTION 8 — Network helpers & HTTP proxy
# =============================================================================

# ---- IP / port helpers ------------------------------------------------------
def myip [] { http get https://ifconfig.me | str trim }

def localip [] {
    match $env.SHELLS_OS {
        "linux" | "wsl"      => { ^hostname -I | str trim }
        "macos" | "freebsd"  => {
            let ip = (try { ^ipconfig getifaddr en0 | str trim } catch { "" })
            if ($ip | is-not-empty) { $ip } else { try { ^ipconfig getifaddr en1 | str trim } catch { "" } }
        }
        "windows" => { sys net | get ipv4 | flatten | first }
        _ => ""
    }
}

def ports [] {
    match $env.SHELLS_OS {
        "linux" | "wsl"     => { ^ss -tulnp }
        "macos" | "freebsd" => { ^lsof -nP -iTCP -sTCP:LISTEN }
        _ => "ports: unsupported OS"
    }
}

# ---- Proxy toggle -----------------------------------------------------------
# Override PROXY_HOST / PROXY_PORT in ~/.envs (or your rc) before sourcing.
if ($env.PROXY_HOST? | is-empty) { $env.PROXY_HOST = "127.0.0.1" }
if ($env.PROXY_PORT? | is-empty) { $env.PROXY_PORT = "3067" }

# Usage:
#   proxy                    # http://$PROXY_HOST:$PROXY_PORT
#   proxy 10808              # default host, given port
#   proxy 192.168.1.1 7890   # explicit host and port
def --env proxy [...args: string] {
    let n = ($args | length)
    let host = if $n == 2 { $args.0 } else { $env.PROXY_HOST }
    let port = if $n == 2 { $args.1 } else if $n == 1 { $args.0 } else { $env.PROXY_PORT }
    if $n > 2 { print -e "usage: proxy [[host] port]"; return }
    let url = $"http://($host):($port)"
    $env.http_proxy  = $url
    $env.https_proxy = $url
    $env.HTTP_PROXY  = $url
    $env.HTTPS_PROXY = $url
    print $"proxy on  \(($host):($port)\)"
}

def --env socks5 [...args: string] {
    let n = ($args | length)
    let host = if $n == 2 { $args.0 } else { $env.PROXY_HOST }
    let port = if $n == 2 { $args.1 } else if $n == 1 { $args.0 } else { $env.PROXY_PORT }
    if $n > 2 { print -e "usage: socks5 [[host] port]"; return }
    let url = $"socks5://($host):($port)"
    $env.all_proxy = $url
    $env.ALL_PROXY = $url
    print $"socks5 on \(($host):($port)\)"
}

def --env unproxy [] {
    hide-env --ignore-errors http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY
    print "proxy off"
}

def proxyinfo [] {
    print $"http : ($env.http_proxy?  | default 'unset')"
    print $"https: ($env.https_proxy? | default 'unset')"
    print $"socks: ($env.all_proxy?   | default 'unset')"
}


# =============================================================================
# SECTION 9 — Custom utility functions
# =============================================================================

# mkdir -p <dir> && cd into it
def --env mkcd [dir: string] {
    mkdir $dir
    cd $dir
}

# Backup a file/dir to <name>.bak.<timestamp>. nu's `cp -r` preserves attrs
# on Unix; we shell out to `cp -a` for parity with the bash version (which
# also copies symlinks as links rather than dereferencing).
def bak [path: string] {
    let ts = (date now | format date "%Y%m%d_%H%M%S")
    ^cp -a $path $"($path).bak.($ts)"
}

# Same as bak but moves instead of copies
def mbak [path: string] {
    let ts = (date now | format date "%Y%m%d_%H%M%S")
    mv $path $"($path).bak.($ts)"
}

# Weather report via wttr.in (optional location; default = geolocation by IP)
def weather [location?: string] {
    http get $"https://wttr.in/($location | default '')"
}

def uuid [] {
    random uuid
}

# =============================================================================
# SECTION 10 — ~/.aliases regenerator
# =============================================================================
# Reads ~/.aliases, validates each entry, and writes an alias-cache file at
# $nu.cache-dir/shells/aliases.nu. The cache is sourced at the bottom of this
# file (parse-time) — after editing ~/.aliases, run `shells-regen-aliases`
# and restart nu so the new cache is picked up at parse.
# save ($nu.data-dir | path join "vendor/autoload/auto-sources.nu") --force

def --env shells-regen-aliases [] {
    let infile  = ($nu.home-dir  | path join ".aliases")
    let outfile = ($nu.data-dir | path join "vendor/autoload/aliases.nu")
    if not ($infile | path exists) {
        print -e $"~/.aliases not found at ($infile) — nothing to regen."
        return
    }
    let cache_dir = ($outfile | path dirname)
    if not ($cache_dir | path exists) { mkdir $cache_dir }

    let entries = (
        open --raw $infile | lines | each { |line|
            mut line = ($line | str trim --left)
            if ($line | is-empty) or ($line | str starts-with "#") { return null }
            if not ($line | str contains "=") { return null }
            let eq = ($line | str index-of "=")
            let name = ($line | str substring ..($eq - 1) | str trim --right)
            mut body = ($line | str substring ($eq + 1)..)
            if ($name | parse --regex '^[A-Za-z_][A-Za-z0-9_-]*$' | is-empty) { return null }
            if ($body | str length) >= 2 {
                let f = ($body | str substring 0..0)
                let l = ($body | str substring (-1..))
                if (($f == '"' and $l == '"') or ($f == "'" and $l == "'")) {
                    $body = ($body | str substring 1..-2)
                }
            }
            $"alias ($name) = ($body)"
        } | compact
    )

    $"# Auto-generated by shells-regen-aliases — DO NOT EDIT\n# Source: ($infile)\n($entries | str join "\n")\n" | save -f $outfile
    print $"Wrote ($entries | length) aliases to ($outfile)"
    print "Restart nu (or re-source the main config) to pick up the new aliases."
}

# ---- Auto-regen on staleness -----------------------------------------------
# If ~/.aliases is newer than the cache (or cache is missing), regenerate it
# and warn the user. NOTE: the SECTION 12 `source $cache` at the bottom of this
# file runs at PARSE time — which is before any runtime code — so this session
# has already loaded the OLD aliases. The auto-regen helps the *next* nu start
# pick up the new ones with no manual `shells-regen-aliases` step.
# save ($nu.data-dir | path join "vendor/autoload/auto-sources.nu") --force
do {
    let a = ($nu.home-dir  | path join ".aliases")
    let c = ($nu.data-dir | path join "vendor/autoload/aliases.nu")
    if ($a | path exists) and (
        (not ($c | path exists))
        or ((ls -al $a | get 0.modified) > (ls -al $c | get 0.modified))
    ) {
        shells-regen-aliases
        print -e $"(ansi yellow)Note: alias cache was stale and has been regenerated. Run `exec nu` to load the new aliases.(ansi reset)"
    }
}


# =============================================================================
# SECTION 11 — Interactive prompt ($env.PROMPT_COMMAND)
# =============================================================================
# Selection order:
#   1. starship  — if installed (best UX, written in Rust, very fast)
#   2. fast native — pure nu builtins for layout; the only forks are `git`
#      calls inside repos. Walks PWD upward looking for .git; zero forks
#      outside repos.
#
# Opt-out: set SHELLS_NO_PROMPT=1 in ~/.envs before sourcing.

# Walk PWD upwards looking for .git — returns " branch[*]" or empty string.
# `.git` is a directory in normal repos, a file in worktrees/submodules.
def __shells_git_prompt [] {
    if (which git | is-empty) { return "" }
    mut d = $env.PWD
    loop {
        let g = ($d | path join ".git")
        if ($g | path exists) {
            let branch = (
                try { ^git symbolic-ref --short HEAD | str trim }
                catch { try { ^git rev-parse --short HEAD | str trim } catch { "" } }
            )
            if ($branch | is-empty) { return "" }
            # `git diff-index --quiet HEAD` is much faster than
            # `git status --porcelain` on large repos (no scan).
            let dirty = (try { ^git diff-index --quiet HEAD --; "" } catch { "*" })
            return $" (ansi magenta)($branch)($dirty)(ansi reset)"
        }
        let parent = ($d | path dirname)
        if $parent == $d { return "" }
        $d = $parent
    }
}

if ($env.SHELLS_NO_PROMPT? | is-empty) {
    # %F{8}-equivalent: `ansi grey` = `\e[38;5;8m`, matches bash `\e[90m`.
    # User/host cached: $env.USER is set on Unix; sys host runs once per
    # prompt but is a cheap intrinsic (no fork).
    #
    # Starship users: skip our prompt by setting SHELLS_NO_PROMPT=1 in ~/.envs
    # and putting `starship init nu | save -f /some/path.nu` then
    # `source /some/path.nu` in your own $nu.config-path before this file.
    # (nu's parse-time source can't conditionally include starship's init.)
    $env.PROMPT_COMMAND = {||
        let rc  = ($env.LAST_EXIT_CODE? | default 0)
        let now = (date now | format date "%H:%M:%S")
        let cwd = (
            if ($env.PWD | str starts-with $nu.home-dir) {
                "~" + ($env.PWD | str substring ($nu.home-dir | str length)..)
            } else { $env.PWD }
        )
        let user = ($env.USER? | default ($env.USERNAME? | default ""))
        let host = (sys host | get hostname)

        let venv = (
            if ($env.VIRTUAL_ENV? | is-not-empty) {
                $" (ansi cyan)\(($env.VIRTUAL_ENV | path basename)\)(ansi reset)"
            } else if (($env.CONDA_DEFAULT_ENV? | default "") not-in ["" "base"]) {
                $" (ansi cyan)\(($env.CONDA_DEFAULT_ENV)\)(ansi reset)"
            } else { "" }
        )
        let git    = (__shells_git_prompt)
        let rc_dsp = if $rc != 0 { $" (ansi red)[($rc)](ansi reset)" } else { "" }

        $"(ansi grey)[($now)](ansi reset) (ansi green)($user)(ansi white)@($host)(ansi reset) (ansi blue)[($cwd)](ansi reset)($venv)($git)($rc_dsp)\n"
    }
    $env.PROMPT_INDICATOR           = $"(ansi cyan)$(ansi reset) "
    $env.PROMPT_INDICATOR_VI_INSERT = $"(ansi cyan)$(ansi reset) "
    $env.PROMPT_INDICATOR_VI_NORMAL = $"(ansi yellow): (ansi reset)"
    $env.PROMPT_COMMAND_RIGHT       = ""
}



# atuin https://docs.atuin.sh/cli/guide/delete-history/
# Atuin configuration for Nushell
if (which atuin | is-not-empty) {
    $env.ATUIN_DB_PATH = $"($env.HOME)/.local/share/atuin/history_nu.db"
    mkdir ($nu.data-dir | path join "vendor/autoload")
    atuin init nu --disable-up-arrow | save -f ($nu.data-dir | path join "vendor/autoload/atuin.nu")
}

# zoxide https://github.com/ajeetdsouza/zoxide
if (which zoxide | is-not-empty) {
    mkdir ($nu.data-dir | path join "vendor/autoload")
    zoxide init nushell | save -f ($nu.data-dir | path join "vendor/autoload/zoxide.nu")
}
