# =============================================================================
# config.bash — single-file bash configuration
#
# Source from your ~/.bashrc:
#
#     [ -r /path/to/config.bash ] && . /path/to/config.bash
#
# Reads (if present, silently skipped otherwise):
#     ~/.envs       — shared environment variables (see envs.example)
#     ~/.aliases    — shared aliases               (see aliases.example)
#
# Self-contained: does NOT source any other file in this repo.
# =============================================================================

# Only in interactive shell
if [[ $- == *i* ]]; then
    # 启用 Vi 模式
    set -o vi

    # ==================== 插入模式 (Insert Mode) ====================
    # 基本移动
    bind -m vi-insert '"\C-a": beginning-of-line'         # Ctrl+A 行首
    bind -m vi-insert '"\C-e": end-of-line'              # Ctrl+E 行尾
    bind -m vi-insert '"\C-f": forward-char'             # Ctrl+F 前进一个字符
    bind -m vi-insert '"\C-b": backward-char'            # Ctrl+B 后退一个字符
    bind -m vi-insert '"\C-d": delete-char'              # Ctrl+D 删除字符
    bind -m vi-insert '"\C-h": backward-delete-char'     # Ctrl+H 向前删除
    bind -m vi-insert '"\C-k": kill-line'                # Ctrl+K 删除到行尾
    bind -m vi-insert '"\C-u": unix-line-discard'        # Ctrl+U 删除整行
    bind -m vi-insert '"\C-w": backward-kill-word'       # Ctrl+W 删除前一个单词
    bind -m vi-insert '"\C-y": yank'                     # Ctrl+Y 粘贴

    # 历史搜索增强
    bind -m vi-insert '"\C-r": reverse-search-history'   # Ctrl+R 反向搜索历史
    bind -m vi-insert '"\C-s": forward-search-history'   # Ctrl+S 正向搜索历史
    bind -m vi-insert '"\C-p": previous-history'         # Ctrl+P 上一条历史
    bind -m vi-insert '"\C-n": next-history'             # Ctrl+N 下一条历史

    # Alt 组合键 (Meta)
    bind -m vi-insert '"\ef": forward-word'              # Alt+F 前进一个单词
    bind -m vi-insert '"\eb": backward-word'             # Alt+B 后退一个单词
    bind -m vi-insert '"\ed": kill-word'                 # Alt+D 删除单词
    bind -m vi-insert '"\e\C-?": backward-kill-word'     # Alt+Backspace 删除前一个单词
    bind -m vi-insert '"\e.": yank-last-arg'             # Alt+. 插入上一个命令的最后参数

    # 补全增强
    bind -m vi-insert '"\t": complete'                   # Tab 补全

    # 特殊编辑功能
    bind -m vi-insert '"\C-t": transpose-chars'          # Ctrl+T 交换字符
    bind -m vi-insert '"\et": transpose-words'           # Alt+T 交换单词
    bind -m vi-insert '"\eu": upcase-word'               # Alt+U 单词转大写
    bind -m vi-insert '"\el": downcase-word'             # Alt+L 单词转小写
    bind -m vi-insert '"\ec": capitalize-word'           # Alt+C 单词首字母大写

    # 括号和引号匹配
    bind -m vi-insert '"\C-v": quoted-insert'            # Ctrl+V 插入特殊字符

    # ==================== 普通模式 (Command Mode) ====================
    bind -m vi-command '"\C-a": beginning-of-line'       # Ctrl+A 行首
    bind -m vi-command '"\C-e": end-of-line'             # Ctrl+E 行尾
    bind -m vi-command '"\C-f": forward-char'            # Ctrl+F 前进
    bind -m vi-command '"\C-b": backward-char'           # Ctrl+B 后退
    bind -m vi-command '"\C-d": delete-char'             # Ctrl+D 删除字符
    bind -m vi-command '"\C-k": kill-line'               # Ctrl+K 删除到行尾
    bind -m vi-command '"\C-u": unix-line-discard'       # Ctrl+U 删除整行
    bind -m vi-command '"\C-w": backward-kill-word'      # Ctrl+W 删除单词
    bind -m vi-command '"\C-y": yank'                    # Ctrl+Y 粘贴

    bind -m vi-command '"\C-r": reverse-search-history'  # Ctrl+R 反向搜索
    bind -m vi-command '"\C-s": forward-search-history'  # Ctrl+S 正向搜索
    bind -m vi-command '"\C-p": previous-history'        # Ctrl+P 上一条历史
    bind -m vi-command '"\C-n": next-history'            # Ctrl+N 下一条历史

    # Vi 风格增强
    bind -m vi-command 'gg: beginning-of-history'        # gg 跳到历史开头
    bind -m vi-command 'G: end-of-history'               # G 跳到历史结尾
    bind -m vi-command 'v: edit-and-execute-command'     # v 进入临时编辑器

    # 单词移动
    bind -m vi-command '"\ef": forward-word'             # Alt+F 前进单词
    bind -m vi-command '"\eb": backward-word'            # Alt+B 后退单词

    # ==================== 箭头键增强 ====================
    bind -m vi-insert '"\e[A": history-search-backward'  # 上箭头
    bind -m vi-insert '"\e[B": history-search-forward'   # 下箭头
    bind -m vi-command '"\e[A": previous-history'        # 上箭头
    bind -m vi-command '"\e[B": next-history'            # 下箭头

    bind -m vi-insert '"\e[H": beginning-of-line'        # Home
    bind -m vi-insert '"\e[F": end-of-line'             # End
    bind -m vi-command '"\e[H": beginning-of-line'       # Home
    bind -m vi-command '"\e[F": end-of-line'            # End

    bind -m vi-insert '"\e[5~": history-search-backward' # Page Up
    bind -m vi-insert '"\e[6~": history-search-forward'  # Page Down

    bind -m vi-insert '"\e[3~": delete-char'             # Delete
    bind -m vi-command '"\e[3~": delete-char'            # Delete

    # Enable color support
    if command -v dircolors >/dev/null 2>&1; then
        eval "$(dircolors -b)"
    fi
fi

# =============================================================================
# SECTION 1 — OS detection ($SHELLS_OS)
# =============================================================================

case ${OSTYPE,,} in
    linux*)        SHELLS_OS=linux   ;;
    darwin*)       SHELLS_OS=macos   ;;
    freebsd*)      SHELLS_OS=freebsd ;;
    cygwin*)       SHELLS_OS=cygwin  ;;
    msys*|mingw*)  SHELLS_OS=windows ;;
    *)             SHELLS_OS=unknown ;;
esac
if [ "$SHELLS_OS" = linux ] && [ -r /proc/version ]; then
    IFS= read -r __shells_pv < /proc/version
    case ${__shells_pv,,} in
        *microsoft*|*wsl*) SHELLS_OS=wsl ;;
    esac
    unset __shells_pv
fi
export SHELLS_OS


# =============================================================================
# SECTION 2 — Shell environment (interactive bash behavior)
# =============================================================================
# All defaults use `: "${VAR:=...}"` so user values (parent env or ~/.envs
# loaded in SECTION 3) take precedence over what's set here.

# ---- Editor / pager ---------------------------------------------------------
: "${EDITOR:=vim}"
: "${VISUAL:=$EDITOR}"
: "${PAGER:=less}"
: "${LESS:=-R -F -X}"
export EDITOR VISUAL PAGER LESS

# ---- Bash history -----------------------------------------------------------
: "${HISTSIZE:=10000}"
: "${HISTFILESIZE:=20000}"
: "${HISTCONTROL:=ignoreboth:erasedups}"
: "${HISTIGNORE:=ls:ll:la:l:cd:pwd:exit:clear}"
shopt -s histappend                          # append on exit, don't overwrite

# ---- XDG Base Directory -----------------------------------------------------
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
export XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME XDG_STATE_HOME

# ---- Cygwin / MSYS native symlink support -----------------------------------
case "$SHELLS_OS" in
    cygwin)  export CYGWIN="winsymlinks:native" MSYS=winsymlinks:nativestrict ;;
    windows) export MSYS=winsymlinks:nativestrict ;;
esac


# =============================================================================
# SECTION 3 — User file loaders (~/.envs and ~/.aliases)
# =============================================================================
# Loaded early so user-supplied env values override SECTION 2 / SECTION 4
# defaults (which use `: "${VAR:=...}"` and `if [ -z "$VAR" ]`).

# Dedup-prepend a colon-separated list onto $PATH (leftmost wins).
# Existing PATH is always preserved at the tail — caller need not include {PATH}.
# Pure string ops (no associative arrays) — runs on bash 3.2 (macOS default).
__shells_path_prepend() {
    local out="" p IFS=:
    for p in $1:$PATH; do
        [ -z "$p" ] && continue
        case ":$out:" in *":$p:"*) continue ;; esac
        out="${out:+$out:}$p"
    done
    PATH=$out
    export PATH
}

# Parse a KEY=VALUE file into the environment (PATH gets special handling).
__shells_load_envs() {
    local file=$1 line key val
    [ -r "$file" ] || return 0
    while IFS= read -r line || [ -n "$line" ]; do
        line=${line#"${line%%[![:space:]]*}"}                 # ltrim
        case $line in ''|'#'*) continue ;; *=*) ;; *) continue ;; esac
        key=${line%%=*}; val=${line#*=}
        key=${key%"${key##*[![:space:]]}"}                    # rtrim key
        val=${val#"${val%%[![:space:]]*}"}                    # ltrim val
        val=${val%"${val##*[![:space:]]}"}                    # rtrim val
        case $key in ''|*[!A-Za-z0-9_]*|[0-9]*) continue ;; esac
        case $val in \"*\"|\'*\') val=${val:1:-1} ;; esac    # strip outer quotes
        val=${val//\{HOME\}/$HOME}
        val=${val//\{PATH\}/$PATH}
        if [ "$key" = PATH ]; then
            __shells_path_prepend "$val"
        else
            export "$key=$val"
        fi
    done < "$file"
}

# Parse a name=command file into bash aliases.
__shells_load_aliases() {
    local file=$1 line name body
    [ -r "$file" ] || return 0
    while IFS= read -r line || [ -n "$line" ]; do
        line=${line#"${line%%[![:space:]]*}"}
        case $line in ''|'#'*) continue ;; *=*) ;; *) continue ;; esac
        name=${line%%=*}; body=${line#*=}
        name=${name%"${name##*[![:space:]]}"}
        case $name in ''|*[!A-Za-z0-9_-]*|[0-9-]*) continue ;; esac
        case $body in \"*\"|\'*\') body=${body:1:-1} ;; esac
        # `alias name=value` takes value literally — no re-parsing.
        alias "$name=$body"
    done < "$file"
}

__shells_load_envs    "$HOME/.envs"
__shells_load_aliases "$HOME/.aliases"

unset -f __shells_path_prepend __shells_load_envs __shells_load_aliases


# =============================================================================
# SECTION 4 — Language & toolchain environment variables (non-PATH)
# =============================================================================
# Detected paths (GOROOT/JAVA_HOME/ANACONDA_HOME/...) are skipped if already
# set, so users can override via ~/.envs (loaded above).

# ---- Node.js ecosystem ------------------------------------------------------
: "${NPM_CONFIG_PREFIX:=$HOME/.npm-global}"
: "${PNPM_HOME:=$HOME/.pnpm-global}"
export NPM_CONFIG_PREFIX PNPM_HOME
[ -d "$HOME/.fnm" ]        && export FNM_DIR="$HOME/.fnm"
[ -d "$HOME/.bun" ]        && export BUN_INSTALL="$HOME/.bun"
[ -d "$HOME/.deno" ]       && export DENO_INSTALL="$HOME/.deno"
# nvm is intentionally NOT auto-sourced (nvm.sh adds ~200-500 ms to startup).
# Users who want it can add to ~/.bashrc:
#     [ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"

# ---- Go ---------------------------------------------------------------------
: "${GOPATH:=$HOME/go}"
export GOPATH
if [ -z "$GOROOT" ]; then
    for __shells_goroot in \
        /home/linuxbrew/.linuxbrew/opt/go/libexec \
        /opt/homebrew/opt/go/libexec \
        /usr/local/go \
        "$HOME/.local/go"
    do
        [ -d "$__shells_goroot" ] && { export GOROOT="$__shells_goroot"; break; }
    done
    unset __shells_goroot
fi

# ---- Python (Anaconda / Poetry / Pyenv detection) ---------------------------
if [ -z "$ANACONDA_HOME" ]; then
    for __shells_conda in "$HOME/anaconda3" "$HOME/miniconda3" /opt/anaconda3 /opt/miniconda3; do
        [ -d "$__shells_conda" ] && { export ANACONDA_HOME="$__shells_conda"; break; }
    done
    unset __shells_conda
fi
[ -d "$HOME/.poetry" ] && export POETRY_HOME="$HOME/.poetry"
[ -d "$HOME/.pyenv" ]  && export PYENV_ROOT="$HOME/.pyenv"

# ---- Java (JAVA_HOME only; JAVA_OPTS intentionally NOT set — pollutes JVMs) -
if [ -z "$JAVA_HOME" ]; then
    if [ -x /usr/libexec/java_home ]; then
        JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null) && export JAVA_HOME
    else
        for __shells_jdk in /usr/lib/jvm/default-java /usr/lib/jvm/java-11-openjdk-amd64; do
            [ -d "$__shells_jdk" ] && { export JAVA_HOME="$__shells_jdk"; break; }
        done
        unset __shells_jdk
    fi
fi

# ---- Linux/WSL system libs (used by rustc / CUDA builds) --------------------
case "$SHELLS_OS" in
    linux|wsl)
        for __shells_libdir in \
            /usr/lib/x86_64-linux-gnu \
            /usr/lib/aarch64-linux-gnu
        do
            [ -d "$__shells_libdir" ] || continue
            export LIBRARY_PATH="$__shells_libdir${LIBRARY_PATH:+:$LIBRARY_PATH}"
            export LD_LIBRARY_PATH="$__shells_libdir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
            export RUSTFLAGS="-L $__shells_libdir"
            break
        done
        unset __shells_libdir
        ;;
esac

# ---- Docker -----------------------------------------------------------------
: "${DOCKER_BUILDKIT:=1}"
: "${COMPOSE_DOCKER_CLI_BUILD:=1}"
export DOCKER_BUILDKIT COMPOSE_DOCKER_CLI_BUILD


# =============================================================================
# SECTION 5 — PATH (unified, sub-sections by purpose)
# =============================================================================

# ---- Helpers ----------------------------------------------------------------
# Variadic: each arg is added if it exists and isn't already in PATH.
# Semantics match repeated calls — `prepend A B C` ⇒ `C:B:A:PATH` (C leftmost).
# Conditional args via `${VAR:+$VAR/bin}` expand to "" when VAR is empty and
# get silently filtered by the -d check.
__shells_prepend_dir() {
    local d
    for d; do
        [ -d "$d" ] && case ":$PATH:" in *":$d:"*) ;; *) PATH="$d:$PATH" ;; esac
    done
}
__shells_append_dir() {
    local d
    for d; do
        [ -d "$d" ] && case ":$PATH:" in *":$d:"*) ;; *) PATH="$PATH:$d" ;; esac
    done
}

# ---- Local user bins (lowest priority — appended) ---------------------------
__shells_append_dir \
    "$HOME/.lmstudio/bin" \
    "$HOME/.local/bin" \
    "$HOME/bin" \
    "$HOME/Applications" \
    "$HOME/.local/Applications"

# ---- Tool installation dirs (prepended — leftmost wins) ---------------------
__shells_prepend_dir \
    "${CARGO_HOME:-$HOME/.cargo}/bin" \
    "$HOME/.rd/bin" \
    "$HOME/.opencode/bin"
# Cargo's own env file (if present) augments PATH / RUSTUP_HOME / etc.
[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# ---- Language runtimes (uses env vars set in SECTION 4) ---------------------
# Node ecosystem
__shells_prepend_dir \
    "${BUN_INSTALL:+$BUN_INSTALL/bin}" \
    "${DENO_INSTALL:+$DENO_INSTALL/bin}" \
    "$NPM_CONFIG_PREFIX/bin" \
    "$PNPM_HOME" \
    "$HOME/.yarn/bin" \
    "$HOME/.config/yarn/global/node_modules/.bin" \
    "$HOME/.volta/bin" \
    "$HOME/.fnm" \
    "$HOME/.local/share/npm/bin"

# Python ecosystem
__shells_prepend_dir \
    "${PYENV_ROOT:+$PYENV_ROOT/bin}" \
    "${ANACONDA_HOME:+$ANACONDA_HOME/bin}" \
    "${POETRY_HOME:+$POETRY_HOME/bin}" \
    "$HOME/.poetry/bin" \
    "$HOME/.local/pipx/bin"

# Go
__shells_prepend_dir \
    "$GOPATH/bin" \
    "${GOROOT:+$GOROOT/bin}"

# ---- Linux package-manager dirs (appended — low priority) -------------------
case "$SHELLS_OS" in
    linux|wsl)
        __shells_append_dir \
            "/snap/bin" \
            "/var/lib/flatpak/exports/bin" \
            "$HOME/.local/share/flatpak/exports/bin" \
            "/opt/bin"
        ;;
esac

# ---- Windows-environment integration ----------------------------------------
# WSL / Cygwin / MSYS2 (Git Bash): bring in MSYS2 native bin + Windows VS Code
case "$SHELLS_OS" in
    wsl)
        __shells_append_dir \
            "/mnt/c/Program Files/Microsoft VS Code/bin" \
            "/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin"
        ;;
    cygwin)
        __shells_prepend_dir "/mingw64/bin"
        __shells_append_dir \
            "/cygdrive/c/Program Files/Microsoft VS Code/bin" \
            "/cygdrive/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin"
        ;;
    windows)
        __shells_prepend_dir "/mingw64/bin"
        __shells_append_dir \
            "/c/Program Files/Microsoft VS Code/bin" \
            "/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin"
        ;;
esac

# ---- Homebrew (auto-detect prefix; sets PATH/MANPATH/INFOPATH/HOMEBREW_*) ---
for __shells_brew in \
    /home/linuxbrew/.linuxbrew/bin/brew \
    "$HOME/.linuxbrew/bin/brew" \
    /opt/homebrew/bin/brew \
    /usr/local/bin/brew
do
    if [ -x "$__shells_brew" ]; then
        eval "$("$__shells_brew" shellenv bash)"
        break
    fi
done
unset __shells_brew

export PATH
unset -f __shells_prepend_dir __shells_append_dir


# =============================================================================
# SECTION 6 — File listing & navigation aliases
# =============================================================================

# ---- ls / grep family (OS-aware color) --------------------------------------
case "$SHELLS_OS" in
    linux|wsl|cygwin|windows)  alias ls='ls --color=auto' ;;
    macos|freebsd)             alias ls='ls -G'; export CLICOLOR=1 ;;
esac

alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -alFht'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ---- Directory navigation / reload / path -----------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

alias now='date +%Y-%m-%dT%H:%M:%S%z'
alias cls='clear'

alias reload='. ~/.bashrc'
alias path='printf "%s\n" "$PATH" | tr ":" "\n"'


# =============================================================================
# SECTION 7 — OS-specific aliases (clipboard / file manager / package manager)
# =============================================================================

case "$SHELLS_OS" in
    macos)
        alias clip='pbcopy'
        alias paste='pbpaste'
        alias finder='open .'
        alias brewup='brew update && brew upgrade && brew cleanup'
        ;;
    linux|wsl)
        if command -v wl-copy >/dev/null 2>&1; then        # Wayland
            alias clip='wl-copy'
            alias paste='wl-paste'
        elif command -v xclip >/dev/null 2>&1; then        # X11
            alias clip='xclip -selection clipboard'
            alias paste='xclip -selection clipboard -o'
        elif command -v xsel >/dev/null 2>&1; then         # X11 fallback
            alias clip='xsel --clipboard --input'
            alias paste='xsel --clipboard --output'
        fi
        [ "$SHELLS_OS" = wsl ] && alias explorer='explorer.exe .'
        command -v brew >/dev/null 2>&1 && alias brewup='brew update && brew upgrade && brew cleanup'
        command -v apt  >/dev/null 2>&1 && alias aptup='sudo apt update && sudo apt upgrade'
        ;;
    cygwin|windows)
        alias clip='clip.exe'
        alias open='start'
        ;;
esac


# =============================================================================
# SECTION 8 — Network helpers & HTTP proxy
# =============================================================================

# ---- IP / port helpers ------------------------------------------------------
myip() { curl -fsS https://ifconfig.me && echo; }

case "$SHELLS_OS" in
    linux|wsl)         alias localip='hostname -I'; alias ports='ss -tulnp' ;;
    macos|freebsd)     alias localip='ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1'
                       alias ports='lsof -nP -iTCP -sTCP:LISTEN' ;;
esac

# ---- Proxy toggle -----------------------------------------------------------
# Override PROXY_HOST / PROXY_PORT in ~/.envs (or your rc) before sourcing.
: "${PROXY_HOST:=127.0.0.1}"
: "${PROXY_PORT:=3067}"

# Original alias form, superseded by the `proxy` function below.
# alias proxy='_p="http://$PROXY_HOST:$PROXY_PORT"; export http_proxy=$_p https_proxy=$_p HTTP_PROXY=$_p HTTPS_PROXY=$_p; unset _p; echo "proxy on  ($PROXY_HOST:$PROXY_PORT)"'

# Usage:
#   proxy                    # http://$PROXY_HOST:$PROXY_PORT
#   proxy 10808              # default host, given port
#   proxy 192.168.1.1 7890   # explicit host and port
proxy() {
    local host port url
    case $# in
        0) host=$PROXY_HOST port=$PROXY_PORT ;;
        1) host=$PROXY_HOST port=$1 ;;
        2) host=$1 port=$2 ;;
        *) echo "usage: proxy [[host] port]" >&2; return 2 ;;
    esac
    url="http://$host:$port"
    export http_proxy=$url https_proxy=$url HTTP_PROXY=$url HTTPS_PROXY=$url
    echo "proxy on  ($host:$port)"
}

# Usage: same as proxy, but sets socks5 (all_proxy / ALL_PROXY).
socks5() {
    local host port url
    case $# in
        0) host=$PROXY_HOST port=$PROXY_PORT ;;
        1) host=$PROXY_HOST port=$1 ;;
        2) host=$1 port=$2 ;;
        *) echo "usage: socks5 [[host] port]" >&2; return 2 ;;
    esac
    url="socks5://$host:$port"
    export all_proxy=$url ALL_PROXY=$url
    echo "socks5 on ($host:$port)"
}

unproxy() {
    unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY
    echo "proxy off"
}

alias proxyinfo='printf "http : %s\nhttps: %s\nsocks: %s\n" "${http_proxy:-unset}" "${https_proxy:-unset}" "${all_proxy:-unset}"'


# =============================================================================
# SECTION 9 — Custom utility functions
# =============================================================================

# mkdir -p <dir> && cd into it
mkcd() {
    [ -z "$1" ] && { echo "usage: mkcd <dir>" >&2; return 2; }
    mkdir -p -- "$1" && cd -- "$1"
}

# Backup a file/dir to <name>.bak.<timestamp> (cp -a preserves attrs/symlinks)
bak() {
    [ -z "$1" ] && { echo "usage: bak <path>" >&2; return 2; }
    local ts
    printf -v ts '%(%Y%m%d_%H%M%S)T' -1
    cp -a -- "$1" "$1.bak.$ts"
}

# Same as bak but moves instead of copies
mbak() {
    [ -z "$1" ] && { echo "usage: mbak <path>" >&2; return 2; }
    local ts
    printf -v ts '%(%Y%m%d_%H%M%S)T' -1
    mv -- "$1" "$1.bak.$ts"
}

# Weather report via wttr.in (optional location; default = geolocation by IP)
weather() {
    curl -fsS "https://wttr.in/${1:-}"
}


# =============================================================================
# SECTION 10 — Interactive prompt (PS1)
# =============================================================================
# Selection order:
#   1. starship  — if installed (best UX, written in Rust, very fast)
#   2. fast native — pure bash builtins (\t / \u@\h / \w), plus python venv
#      and minimal git info. Zero forks outside git repos.
#
# Opt-out: set SHELLS_NO_PROMPT=1 in ~/.envs before sourcing.
#
# The reference code's 18-language version detection was deliberately omitted —
# each `python --version` / `node --version` / etc. is a fork (~10-30 ms), so a
# multi-language repo could push prompt latency past 300 ms. `$VIRTUAL_ENV` /
# `$CONDA_DEFAULT_ENV` are still shown (env-var lookup, no fork). Users who
# want full detection can layer their own callback onto PROMPT_COMMAND.

if [[ $- == *i* ]] && [ -z "${SHELLS_NO_PROMPT:-}" ]; then
    if command -v starship >/dev/null 2>&1; then
        eval "$(starship init bash)"
    else
        # Cache whether git is installed (saves a builtin call per prompt).
        command -v git >/dev/null 2>&1 && __shells_has_git=1

        # Color escapes wrapped in \[ \] so readline counts them as zero-width
        # (otherwise long prompts wrap incorrectly).
        __shells_c_reset='\[\e[0m\]'
        __shells_c_gray='\[\e[90m\]'
        __shells_c_red='\[\e[31m\]'
        __shells_c_green='\[\e[32m\]'
        __shells_c_blue='\[\e[34m\]'
        __shells_c_magenta='\[\e[35m\]'
        __shells_c_cyan='\[\e[36m\]'
        __shells_c_white='\[\e[97m\]'

        # PROMPT_COMMAND callback — rebuilds PS1 before each prompt.
        __shells_prompt() {
            local rc=$? extra='' d=$PWD branch dirty

            # Python venv / conda env name — free (no fork)
            if [ -n "${VIRTUAL_ENV:-}" ]; then
                extra+=" ${__shells_c_cyan}(${VIRTUAL_ENV##*/})${__shells_c_reset}"
            elif [ -n "${CONDA_DEFAULT_ENV:-}" ] && [ "$CONDA_DEFAULT_ENV" != base ]; then
                extra+=" ${__shells_c_cyan}($CONDA_DEFAULT_ENV)${__shells_c_reset}"
            fi

            # Git: walk PWD upwards looking for .git — zero forks if not in a repo.
            if [ -n "$__shells_has_git" ]; then
                while [ "$d" != / ] && [ -n "$d" ]; do
                    if [ -e "$d/.git" ]; then
                        branch=$(git symbolic-ref --short HEAD 2>/dev/null) \
                            || branch=$(git rev-parse --short HEAD 2>/dev/null)
                        if [ -n "$branch" ]; then
                            # `git diff-index --quiet HEAD` is much faster than
                            # `git status --porcelain` on large repos (no scan).
                            dirty=''
                            git diff-index --quiet HEAD -- 2>/dev/null || dirty='*'
                            extra+=" ${__shells_c_magenta}${branch}${dirty}${__shells_c_reset}"
                        fi
                        break
                    fi
                    d=${d%/*}
                done
            fi

            PS1="${__shells_c_gray}[\t]${__shells_c_reset}"
            PS1+=" ${__shells_c_green}\u${__shells_c_white}@\h${__shells_c_reset}"
            PS1+=" ${__shells_c_blue}[\w]${__shells_c_reset}"
            PS1+="$extra"
            [ "$rc" -ne 0 ] && PS1+=" ${__shells_c_red}[$rc]${__shells_c_reset}"
            PS1+="\n${__shells_c_cyan}\$${__shells_c_reset} "
        }

        # Prepend our callback so user's existing PROMPT_COMMAND still runs.
        # Guard against duplicates so `reload` doesn't stack the callback.
        case ";${PROMPT_COMMAND:-};" in
            *";__shells_prompt;"*) ;;
            *) PROMPT_COMMAND="__shells_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
        esac
    fi
fi
