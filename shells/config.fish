# =============================================================================
# config.fish — single-file fish configuration
#
# Source from your ~/.config/fish/config.fish:
#
#     test -r /path/to/config.fish; and source /path/to/config.fish
#
# Reads (if present, silently skipped otherwise):
#     ~/.envs       — shared environment variables (see envs.example)
#     ~/.aliases    — shared aliases               (see aliases.example)
#
# Self-contained: does NOT source any other file in this repo.
# Targets fish 3.5+ (uses `string`, `path`, contains, set -q semantics).
# =============================================================================
# Fish shell options
set -g fish_greeting ""  # Disable default greeting

# 启用 Vi 模式
fish_vi_key_bindings

# ==================== 插入模式 (Insert Mode) ====================
bind -M insert \ca beginning-of-line          # Ctrl+A 行首
bind -M insert \ce end-of-line               # Ctrl+E 行尾
bind -M insert \cf forward-char              # Ctrl+F 前进一个字符
bind -M insert \cb backward-char             # Ctrl+B 后退一个字符
bind -M insert \cd delete-char               # Ctrl+D 删除字符
bind -M insert \ch backward-delete-char      # Ctrl+H 向前删除
bind -M insert \ck kill-line                 # Ctrl+K 删除到行尾
bind -M insert \cu backward-kill-line        # Ctrl+U 删除整行
bind -M insert \cw backward-kill-word        # Ctrl+W 删除前一个单词
bind -M insert \cy yank                      # Ctrl+Y 粘贴

# 历史搜索增强
bind -M insert \cr history-search-backward   # Ctrl+R 反向搜索历史
bind -M insert \cs history-search-forward    # Ctrl+S 正向搜索历史
bind -M insert \cp up-or-search              # Ctrl+P 上一条历史
bind -M insert \cn down-or-search            # Ctrl+N 下一条历史

# Alt 组合键 (Meta)
bind -M insert \ef forward-word              # Alt+F 前进一个单词
bind -M insert \eb backward-word             # Alt+B 后退一个单词
bind -M insert \ed kill-word                 # Alt+D 删除单词
bind -M insert \e\x7f backward-kill-word     # Alt+Backspace 删除前一个单词
bind -M insert \e. yank-last-arg             # Alt+. 插入上一个命令的最后参数

# 补全增强
bind -M insert \t complete                   # Tab 补全
bind -M insert \e\* insert-completions       # Alt+* 插入所有补全

# 特殊编辑功能
bind -M insert \ct transpose-chars           # Ctrl+T 交换字符
bind -M insert \et transpose-words           # Alt+T 交换单词
bind -M insert \eu upcase-word               # Alt+U 单词转大写
bind -M insert \el downcase-word             # Alt+L 单词转小写
bind -M insert \ec capitalize-word           # Alt+C 单词首字母大写

# 括号和引号匹配
bind -M insert \cv quoted-insert             # Ctrl+V 插入特殊字符

# ==================== 普通模式 (Command Mode) ====================
bind -M default \ca beginning-of-line        # Ctrl+A 行首
bind -M default \ce end-of-line              # Ctrl+E 行尾
bind -M default \cf forward-char             # Ctrl+F 前进
bind -M default \cb backward-char            # Ctrl+B 后退
bind -M default \cd delete-char              # Ctrl+D 删除字符
bind -M default \ck kill-line                # Ctrl+K 删除到行尾
bind -M default \cu backward-kill-line       # Ctrl+U 删除整行
bind -M default \cw backward-kill-word       # Ctrl+W 删除单词
bind -M default \cy yank                     # Ctrl+Y 粘贴

bind -M default \cr history-search-backward  # Ctrl+R 反向搜索
bind -M default \cs history-search-forward   # Ctrl+S 正向搜索
bind -M default \cp up-or-search             # Ctrl+P 上一条历史
bind -M default \cn down-or-search           # Ctrl+N 下一条历史

# Vi 风格增强
bind -M default gg history-beginning-search-backward  # gg 跳到历史开头
bind -M default G history-beginning-search-forward   # G 跳到历史结尾
bind -M default v edit_command_buffer               # v 进入临时编辑器

# 单词移动
bind -M default \ef forward-word              # Alt+F 前进单词
bind -M default \eb backward-word             # Alt+B 后退单词

# 大小写转换
bind -M default \~ toggle-case                # ~ 切换大小写

# ==================== 箭头键增强 ====================
bind -M insert \e\[A history-search-backward   # 上箭头
bind -M insert \e\[B history-search-forward    # 下箭头
bind -M default \e\[A history-search-backward  # 上箭头
bind -M default \e\[B history-search-forward   # 下箭头

bind -M insert \e\[H beginning-of-line         # Home
bind -M insert \e\[F end-of-line              # End
bind -M default \e\[H beginning-of-line        # Home
bind -M default \e\[F end-of-line             # End

bind -M insert \e\[5~ history-search-backward  # Page Up
bind -M insert \e\[6~ history-search-forward   # Page Down

bind -M insert \e\[3~ delete-char              # Delete
bind -M default \e\[3~ delete-char             # Delete

# Enable color support (fish has this by default, but let's be explicit)
set -gx CLICOLOR 1


# =============================================================================
# SECTION 1 — OS detection ($SHELLS_OS)
# =============================================================================
# fish has no built-in OS variable; `uname -s` once is the cheapest source.

switch (uname -s | string lower)
    case 'linux*'       ; set -gx SHELLS_OS linux
    case 'darwin*'      ; set -gx SHELLS_OS macos
    case 'freebsd*'     ; set -gx SHELLS_OS freebsd
    case 'cygwin*'      ; set -gx SHELLS_OS cygwin
    case 'msys*' 'mingw*'; set -gx SHELLS_OS windows
    case '*'            ; set -gx SHELLS_OS unknown
end
if test "$SHELLS_OS" = linux; and test -r /proc/version
    read -l __shells_pv < /proc/version
    if string match -qir 'microsoft|wsl' -- $__shells_pv
        set -gx SHELLS_OS wsl
    end
    set -e __shells_pv
end


# =============================================================================
# SECTION 2 — Shell environment (interactive fish behavior)
# =============================================================================
# All defaults use `set -q VAR; or set -gx VAR ...` so user values (parent env
# or ~/.envs loaded in SECTION 3) take precedence over defaults here.

# ---- Editor / pager ---------------------------------------------------------
set -q EDITOR; or set -gx EDITOR vim
set -q VISUAL; or set -gx VISUAL $EDITOR
set -q PAGER; or set -gx PAGER less
set -q LESS; or set -gx LESS '-R -F -X'

# (fish has its own history; bash HISTSIZE/HISTCONTROL/HISTIGNORE don't apply.)

# ---- XDG Base Directory -----------------------------------------------------
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_DATA_HOME;   or set -gx XDG_DATA_HOME   $HOME/.local/share
set -q XDG_CACHE_HOME;  or set -gx XDG_CACHE_HOME  $HOME/.cache
set -q XDG_STATE_HOME;  or set -gx XDG_STATE_HOME  $HOME/.local/state

# ---- Cygwin / MSYS native symlink support -----------------------------------
switch $SHELLS_OS
    case cygwin
        set -gx CYGWIN winsymlinks:native
        set -gx MSYS   winsymlinks:nativestrict
    case windows
        set -gx MSYS   winsymlinks:nativestrict
end


# =============================================================================
# SECTION 3 — User file loaders (~/.envs and ~/.aliases)
# =============================================================================
# Loaded early so user-supplied env values override SECTION 2 / SECTION 4
# defaults (which use `set -q ...; or set ...`).

# Dedup-prepend a colon-separated list onto $PATH (leftmost wins).
# Existing PATH preserved at the tail — caller need not include {PATH}.
function __shells_path_prepend
    set -l new
    for p in (string split : -- $argv[1]) $PATH
        test -z "$p"; and continue
        contains -- $p $new; and continue
        set -a new $p
    end
    set -gx PATH $new
end

# Parse a KEY=VALUE file into the environment (PATH gets special handling).
function __shells_load_envs
    set -l file $argv[1]
    test -r $file; or return 0
    while read -l line
        set line (string trim -- $line)
        test -z "$line"; and continue
        string match -q '#*' -- $line; and continue
        string match -q '*=*' -- $line; or continue
        set -l parts (string split -m 1 = -- $line)
        set -l key (string trim -- $parts[1])
        set -l val (string trim -- $parts[2])
        string match -qr '^[A-Za-z_][A-Za-z0-9_]*$' -- $key; or continue
        # Strip a single outer pair of matching quotes
        switch $val
            case '"*"' "'*'"
                set val (string sub -s 2 -e -1 -- $val)
        end
        # Expand {HOME} / {PATH} placeholders
        set val (string replace -a '{HOME}' $HOME -- $val)
        set val (string replace -a '{PATH}' (string join : -- $PATH) -- $val)
        if test $key = PATH
            __shells_path_prepend $val
        else
            set -gx $key $val
        end
    end < $file
end

# Parse a name=command file into fish aliases.
function __shells_load_aliases
    set -l file $argv[1]
    test -r $file; or return 0
    while read -l line
        set line (string trim -- $line)
        test -z "$line"; and continue
        string match -q '#*' -- $line; and continue
        string match -q '*=*' -- $line; or continue
        set -l parts (string split -m 1 = -- $line)
        set -l name (string trim -- $parts[1])
        set -l body $parts[2]
        string match -qr '^[A-Za-z_][A-Za-z0-9_-]*$' -- $name; or continue
        switch $body
            case '"*"' "'*'"
                set body (string sub -s 2 -e -1 -- $body)
        end
        # fish `alias name=value` registers a function; aliases used here are
        # one-shot commands (no $1, $@ etc.), matching the .aliases format spec.
        alias $name $body
    end < $file
end

__shells_load_envs    $HOME/.envs
__shells_load_aliases $HOME/.aliases

functions -e __shells_path_prepend __shells_load_envs __shells_load_aliases


# =============================================================================
# SECTION 4 — Language & toolchain environment variables (non-PATH)
# =============================================================================
# Detected paths (GOROOT/JAVA_HOME/ANACONDA_HOME/...) are skipped if already
# set, so user values from ~/.envs win.

# ---- Node.js ecosystem ------------------------------------------------------
set -q NPM_CONFIG_PREFIX; or set -gx NPM_CONFIG_PREFIX $HOME/.npm-global
set -q PNPM_HOME;         or set -gx PNPM_HOME         $HOME/.pnpm-global
test -d $HOME/.fnm;        and set -gx FNM_DIR      $HOME/.fnm
test -d $HOME/.bun;        and set -gx BUN_INSTALL  $HOME/.bun
test -d $HOME/.deno;       and set -gx DENO_INSTALL $HOME/.deno
# nvm has no native fish support; users who want it typically install bass +
# nvm.fish. This config intentionally does NOT touch NVM_DIR — set it yourself
# in ~/.envs if you load nvm via a wrapper.

# ---- Go ---------------------------------------------------------------------
set -q GOPATH; or set -gx GOPATH $HOME/go
if not set -q GOROOT
    for d in /home/linuxbrew/.linuxbrew/opt/go/libexec /opt/homebrew/opt/go/libexec /usr/local/go $HOME/.local/go
        if test -d $d
            set -gx GOROOT $d
            break
        end
    end
end

# ---- Python (Anaconda / Poetry / Pyenv detection) ---------------------------
if not set -q ANACONDA_HOME
    for d in $HOME/anaconda3 $HOME/miniconda3 /opt/anaconda3 /opt/miniconda3
        if test -d $d
            set -gx ANACONDA_HOME $d
            break
        end
    end
end
test -d $HOME/.poetry; and set -gx POETRY_HOME $HOME/.poetry
test -d $HOME/.pyenv;  and set -gx PYENV_ROOT  $HOME/.pyenv

# ---- Java (JAVA_HOME only; JAVA_OPTS intentionally NOT set — pollutes JVMs) -
if not set -q JAVA_HOME
    if test -x /usr/libexec/java_home
        set -gx JAVA_HOME (/usr/libexec/java_home 2>/dev/null)
    else
        for d in /usr/lib/jvm/default-java /usr/lib/jvm/java-11-openjdk-amd64
            if test -d $d
                set -gx JAVA_HOME $d
                break
            end
        end
    end
end

# ---- Linux/WSL system libs (used by rustc / CUDA builds) --------------------
switch $SHELLS_OS
    case linux wsl
        for p in /usr/lib/x86_64-linux-gnu /usr/lib/aarch64-linux-gnu
            test -d $p; or continue
            if set -q LIBRARY_PATH; and test -n "$LIBRARY_PATH"
                set -gx LIBRARY_PATH "$p:$LIBRARY_PATH"
            else
                set -gx LIBRARY_PATH $p
            end
            if set -q LD_LIBRARY_PATH; and test -n "$LD_LIBRARY_PATH"
                set -gx LD_LIBRARY_PATH "$p:$LD_LIBRARY_PATH"
            else
                set -gx LD_LIBRARY_PATH $p
            end
            set -gx RUSTFLAGS "-L $p"
            break
        end
end

# ---- Docker -----------------------------------------------------------------
set -q DOCKER_BUILDKIT;          or set -gx DOCKER_BUILDKIT          1
set -q COMPOSE_DOCKER_CLI_BUILD; or set -gx COMPOSE_DOCKER_CLI_BUILD 1


# =============================================================================
# SECTION 5 — PATH (unified, sub-sections by purpose)
# =============================================================================
# In fish, $PATH is a native list — no colon parsing needed.

# ---- Helpers ----------------------------------------------------------------
# Variadic: each arg is added if it exists and isn't already in PATH.
# Semantics match repeated calls — `prepend A B C` ⇒ `C B A …PATH` (C leftmost).
# Empty / missing args silently filtered by the `-d` check.
function __shells_prepend_dir
    for d in $argv
        test -d "$d"; or continue
        contains -- $d $PATH; and continue
        set -gx PATH $d $PATH
    end
end
function __shells_append_dir
    for d in $argv
        test -d "$d"; or continue
        contains -- $d $PATH; and continue
        set -gx PATH $PATH $d
    end
end

# ---- Local user bins (lowest priority — appended) ---------------------------
__shells_append_dir \
    $HOME/.lmstudio/bin \
    $HOME/.local/bin \
    $HOME/bin \
    $HOME/Applications \
    $HOME/.local/Applications

# ---- Tool installation dirs (prepended — leftmost wins) ---------------------
set -l __shells_cargo $HOME/.cargo
set -q CARGO_HOME; and set __shells_cargo $CARGO_HOME
__shells_prepend_dir \
    $__shells_cargo/bin \
    $HOME/.rd/bin \
    $HOME/.opencode/bin
set -e __shells_cargo
# Cargo's fish env file (if present) augments PATH / RUSTUP_HOME / etc.
test -r $HOME/.cargo/env.fish; and source $HOME/.cargo/env.fish

# ---- Language runtimes (uses env vars set in SECTION 4) ---------------------
# Node ecosystem — last arg ends up leftmost (matches bash sequential semantics)
set -l __shells_node_dirs
set -q BUN_INSTALL;  and set -a __shells_node_dirs $BUN_INSTALL/bin
set -q DENO_INSTALL; and set -a __shells_node_dirs $DENO_INSTALL/bin
set -a __shells_node_dirs \
    $NPM_CONFIG_PREFIX/bin \
    $PNPM_HOME \
    $HOME/.yarn/bin \
    $HOME/.config/yarn/global/node_modules/.bin \
    $HOME/.volta/bin \
    $HOME/.fnm \
    $HOME/.local/share/npm/bin
__shells_prepend_dir $__shells_node_dirs
set -e __shells_node_dirs

# Python ecosystem
set -l __shells_py_dirs
set -q PYENV_ROOT;    and set -a __shells_py_dirs $PYENV_ROOT/bin
set -q ANACONDA_HOME; and set -a __shells_py_dirs $ANACONDA_HOME/bin
set -q POETRY_HOME;   and set -a __shells_py_dirs $POETRY_HOME/bin
set -a __shells_py_dirs \
    $HOME/.poetry/bin \
    $HOME/.local/pipx/bin
__shells_prepend_dir $__shells_py_dirs
set -e __shells_py_dirs

# Go
set -l __shells_go_dirs $GOPATH/bin
set -q GOROOT; and set -a __shells_go_dirs $GOROOT/bin
__shells_prepend_dir $__shells_go_dirs
set -e __shells_go_dirs

# ---- Linux package-manager dirs (appended — low priority) -------------------
switch $SHELLS_OS
    case linux wsl
        __shells_append_dir \
            /snap/bin \
            /var/lib/flatpak/exports/bin \
            $HOME/.local/share/flatpak/exports/bin \
            /opt/bin
end

# ---- Windows-environment integration ----------------------------------------
switch $SHELLS_OS
    case wsl
        __shells_append_dir \
            "/mnt/c/Program Files/Microsoft VS Code/bin" \
            "/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin"
    case cygwin
        __shells_prepend_dir /mingw64/bin
        __shells_append_dir \
            "/cygdrive/c/Program Files/Microsoft VS Code/bin" \
            "/cygdrive/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin"
    case windows
        __shells_prepend_dir /mingw64/bin
        __shells_append_dir \
            "/c/Program Files/Microsoft VS Code/bin" \
            "/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin"
end

# ---- Homebrew (auto-detect prefix; sets PATH/MANPATH/INFOPATH/HOMEBREW_*) ---
for __shells_brew in \
    /home/linuxbrew/.linuxbrew/bin/brew \
    $HOME/.linuxbrew/bin/brew \
    /opt/homebrew/bin/brew \
    /usr/local/bin/brew
    if test -x $__shells_brew
        $__shells_brew shellenv fish | source
        break
    end
end
set -e __shells_brew

functions -e __shells_prepend_dir __shells_append_dir


# =============================================================================
# SECTION 6 — File listing & navigation aliases
# =============================================================================

# ---- ls / grep family (OS-aware color) --------------------------------------
switch $SHELLS_OS
    case linux wsl cygwin windows
        alias ls 'ls --color=auto'
    case macos freebsd
        alias ls 'ls -G'
        set -gx CLICOLOR 1
end

alias ll 'ls -alFh'
alias la 'ls -A'
alias l  'ls -CF'
alias lt 'ls -alFht'

alias grep  'grep --color=auto'
alias fgrep 'fgrep --color=auto'
alias egrep 'egrep --color=auto'

# ---- Directory navigation / reload / path -----------------------------------
alias ..   'cd ..'
alias ...  'cd ../..'
alias .... 'cd ../../..'
# fish 3.4+ supports `cd -` natively (toggle to previous dir). fish refuses
# to define a function named `-`, so we leave it as bash's `cd -` equivalent.

alias now    'date +%Y-%m-%dT%H:%M:%S%z'
alias reload 'source $__fish_config_dir/config.fish'

# `path` prints $PATH entries one per line. NOTE: this shadows fish 3.5+'s
# `path` builtin — use `builtin path basename` (etc.) to access it.
function path --description 'Print $PATH entries one per line'
    printf '%s\n' $PATH
end


# =============================================================================
# SECTION 7 — OS-specific aliases (clipboard / file manager / package manager)
# =============================================================================

switch $SHELLS_OS
    case macos
        alias clip   pbcopy
        alias paste  pbpaste
        alias finder 'open .'
        alias brewup 'brew update && brew upgrade && brew cleanup'
    case linux wsl
        if type -q wl-copy
            alias clip  wl-copy
            alias paste wl-paste
        else if type -q xclip
            alias clip  'xclip -selection clipboard'
            alias paste 'xclip -selection clipboard -o'
        else if type -q xsel
            alias clip  'xsel --clipboard --input'
            alias paste 'xsel --clipboard --output'
        end
        test "$SHELLS_OS" = wsl; and alias explorer 'explorer.exe .'
        type -q brew; and alias brewup 'brew update && brew upgrade && brew cleanup'
        type -q apt;  and alias aptup  'sudo apt update && sudo apt upgrade'
    case cygwin windows
        alias clip clip.exe
        alias open start
end


# =============================================================================
# SECTION 8 — Network helpers & HTTP proxy
# =============================================================================

# ---- IP / port helpers ------------------------------------------------------
function myip --description 'Show public IP'
    curl -fsS https://ifconfig.me; and echo
end

switch $SHELLS_OS
    case linux wsl
        alias localip 'hostname -I'
        alias ports   'ss -tulnp'
    case macos freebsd
        alias localip 'ipconfig getifaddr en0 2>/dev/null; or ipconfig getifaddr en1'
        alias ports   'lsof -nP -iTCP -sTCP:LISTEN'
end

# ---- Proxy toggle -----------------------------------------------------------
# Override PROXY_HOST / PROXY_PORT in ~/.envs before sourcing.
set -q PROXY_HOST; or set -gx PROXY_HOST 127.0.0.1
set -q PROXY_PORT; or set -gx PROXY_PORT 3067

# Original alias form, superseded by the `proxy` function below.
# alias proxy 'set -gx http_proxy "http://$PROXY_HOST:$PROXY_PORT"; set -gx https_proxy $http_proxy; set -gx HTTP_PROXY $http_proxy; set -gx HTTPS_PROXY $http_proxy; echo "proxy on  ($PROXY_HOST:$PROXY_PORT)"'

# Usage:
#   proxy                    # http://$PROXY_HOST:$PROXY_PORT
#   proxy 10808              # default host, given port
#   proxy 192.168.1.1 7890   # explicit host and port
function proxy --description 'Enable HTTP proxy'
    set -l host
    set -l port
    switch (count $argv)
        case 0
            set host $PROXY_HOST; set port $PROXY_PORT
        case 1
            set host $PROXY_HOST; set port $argv[1]
        case 2
            set host $argv[1];    set port $argv[2]
        case '*'
            echo "usage: proxy [[host] port]" >&2
            return 2
    end
    set -l url "http://$host:$port"
    set -gx http_proxy  $url
    set -gx https_proxy $url
    set -gx HTTP_PROXY  $url
    set -gx HTTPS_PROXY $url
    echo "proxy on  ($host:$port)"
end

function socks5 --description 'Enable SOCKS5 proxy'
    set -l host
    set -l port
    switch (count $argv)
        case 0
            set host $PROXY_HOST; set port $PROXY_PORT
        case 1
            set host $PROXY_HOST; set port $argv[1]
        case 2
            set host $argv[1];    set port $argv[2]
        case '*'
            echo "usage: socks5 [[host] port]" >&2
            return 2
    end
    set -l url "socks5://$host:$port"
    set -gx all_proxy $url
    set -gx ALL_PROXY $url
    echo "socks5 on ($host:$port)"
end

function unproxy --description 'Disable all proxies'
    set -e http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY
    echo "proxy off"
end

function proxyinfo --description 'Show current proxy state'
    set -l h unset; set -q http_proxy;  and set h $http_proxy
    set -l hs unset; set -q https_proxy; and set hs $https_proxy
    set -l s unset; set -q all_proxy;   and set s $all_proxy
    printf "http : %s\nhttps: %s\nsocks: %s\n" $h $hs $s
end


# =============================================================================
# SECTION 9 — Custom utility functions
# =============================================================================

function mkcd --description 'mkdir -p <dir> && cd into it'
    if test -z "$argv[1]"
        echo "usage: mkcd <dir>" >&2
        return 2
    end
    mkdir -p -- $argv[1]; and cd -- $argv[1]
end

function bak --description 'Backup file/dir to <name>.bak.<timestamp> (cp -a)'
    if test -z "$argv[1]"
        echo "usage: bak <path>" >&2
        return 2
    end
    cp -a -- $argv[1] $argv[1].bak.(date +%Y%m%d_%H%M%S)
end

function mbak --description 'Move file/dir to <name>.bak.<timestamp>'
    if test -z "$argv[1]"
        echo "usage: mbak <path>" >&2
        return 2
    end
    mv -- $argv[1] $argv[1].bak.(date +%Y%m%d_%H%M%S)
end

function weather --description 'Weather report via wttr.in'
    curl -fsS "https://wttr.in/$argv[1]"
end


# =============================================================================
# SECTION 10 — Interactive prompt (fish_prompt)
# =============================================================================
# Selection order:
#   1. starship  — if installed (best UX, written in Rust, very fast)
#   2. fast native — pure fish builtins for layout; one `date` fork for time
#      (fish has no builtin time-format equivalent of bash's `\t`/`printf %T`).
#      Walks PWD upward looking for .git; zero git forks outside repos.
#
# Opt-out: set SHELLS_NO_PROMPT=1 in ~/.envs before sourcing.

if not set -q SHELLS_NO_PROMPT
    if type -q starship
        starship init fish | source
    else
        # Cache whether git is installed (saves a `type -q` per prompt).
        type -q git; and set -g __shells_has_git 1

        # Cache color escapes once — set_color is a builtin (no fork) but the
        # cache avoids re-running it 7+ times per prompt.
        set -g __shells_c_reset   (set_color normal)
        set -g __shells_c_gray    (set_color brblack)
        set -g __shells_c_white   (set_color brwhite)
        set -g __shells_c_red     (set_color red)
        set -g __shells_c_green   (set_color green)
        set -g __shells_c_blue    (set_color blue)
        set -g __shells_c_magenta (set_color magenta)
        set -g __shells_c_cyan    (set_color cyan)

        function fish_prompt --description 'Custom fast prompt'
            set -l rc $status   # capture before any other status-modifying call

            set -l now (date +%H:%M:%S)
            set -l cwd (string replace -r "^$HOME" '~' -- $PWD)

            # Python venv / conda env — both env-var lookups, no fork
            set -l venv
            if set -q VIRTUAL_ENV
                set venv (string match -r '[^/]+$' -- $VIRTUAL_ENV)
            else if set -q CONDA_DEFAULT_ENV; and test "$CONDA_DEFAULT_ENV" != base
                set venv $CONDA_DEFAULT_ENV
            end

            # Git: walk PWD upwards looking for .git — zero forks if not in a repo
            set -l git_info
            if set -q __shells_has_git
                set -l d $PWD
                while test "$d" != / -a -n "$d"
                    if test -e "$d/.git"
                        set -l branch (git symbolic-ref --short HEAD 2>/dev/null; or git rev-parse --short HEAD 2>/dev/null)
                        if test -n "$branch"
                            set -l dirty
                            # `git diff-index --quiet HEAD` is far faster than
                            # `git status --porcelain` on large repos.
                            git diff-index --quiet HEAD -- 2>/dev/null; or set dirty '*'
                            set git_info "$branch$dirty"
                        end
                        break
                    end
                    set d (string replace -r '/[^/]*$' '' -- $d)
                end
            end

            # Emit prompt in one printf pass (each %s consumes one arg)
            printf '%s[%s]%s %s%s%s@%s%s %s[%s]%s' \
                $__shells_c_gray   $now    $__shells_c_reset \
                $__shells_c_green  $USER   $__shells_c_white "@$hostname" $__shells_c_reset \
                $__shells_c_blue   "$cwd" $__shells_c_reset
            test -n "$venv"     ; and printf ' %s(%s)%s' $__shells_c_cyan    $venv     $__shells_c_reset
            test -n "$git_info" ; and printf ' %s%s%s'   $__shells_c_magenta $git_info $__shells_c_reset
            test $rc -ne 0      ; and printf ' %s[%s]%s' $__shells_c_red     $rc       $__shells_c_reset
            printf '\n%s$ %s' $__shells_c_cyan $__shells_c_reset
        end
    end
end
