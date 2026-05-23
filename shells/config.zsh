# =============================================================================
# config.zsh — single-file zsh configuration
#
# Source from your ~/.zshrc:
#
#     [ -r /path/to/config.zsh ] && . /path/to/config.zsh
#
# Reads (if present, silently skipped otherwise):
#     ~/.envs       — shared environment variables (see envs.example)
#     ~/.aliases    — shared aliases               (see aliases.example)
#
# Self-contained: does NOT source any other file in this repo.
# Targets zsh 5.0+ (uses typeset -U, glob qualifiers, $+commands, %F prompt).
# =============================================================================

# Set history options
# 历史记录文件路径
export HISTFILE=~/.zsh_history
# 内存中保存的历史条数
export HISTSIZE=10000
# 文件中保存的历史条数
export SAVEHIST=10000
# 追加而不是覆盖历史文件
setopt APPEND_HISTORY
# 多个终端会话共享历史（实时同步）
setopt SHARE_HISTORY
# 去除重复命令
setopt HIST_IGNORE_DUPS
# 去除连续重复命令
setopt HIST_IGNORE_ALL_DUPS
# 记录命令执行时间
setopt EXTENDED_HISTORY


# Only in interactive shell
if [[ -o interactive ]]; then
    # 启用 Vi 模式
    bindkey -v

    # `v` in vi-cmd opens $EDITOR — autoload the widget once.
    autoload -Uz edit-command-line
    zle -N edit-command-line

    # ==================== 插入模式 (Insert Mode) ====================
    # 基本移动
    bindkey -M viins '^A'    beginning-of-line               # Ctrl+A 行首
    bindkey -M viins '^E'    end-of-line                     # Ctrl+E 行尾
    bindkey -M viins '^F'    forward-char                    # Ctrl+F 前进一个字符
    bindkey -M viins '^B'    backward-char                   # Ctrl+B 后退一个字符
    bindkey -M viins '^D'    delete-char                     # Ctrl+D 删除字符
    bindkey -M viins '^H'    backward-delete-char            # Ctrl+H 向前删除
    bindkey -M viins '^K'    kill-line                       # Ctrl+K 删除到行尾
    bindkey -M viins '^U'    backward-kill-line              # Ctrl+U 删除整行
    bindkey -M viins '^W'    backward-kill-word              # Ctrl+W 删除前一个单词
    bindkey -M viins '^Y'    yank                            # Ctrl+Y 粘贴

    # 历史搜索增强
    bindkey -M viins '^R'    history-incremental-search-backward  # Ctrl+R 反向搜索历史
    bindkey -M viins '^S'    history-incremental-search-forward   # Ctrl+S 正向搜索历史
    bindkey -M viins '^P'    up-history                      # Ctrl+P 上一条历史
    bindkey -M viins '^N'    down-history                    # Ctrl+N 下一条历史

    # Alt 组合键 (Meta — `\e` prefix is the ESC code Alt sends)
    bindkey -M viins '\ef'   forward-word                    # Alt+F 前进一个单词
    bindkey -M viins '\eb'   backward-word                   # Alt+B 后退一个单词
    bindkey -M viins '\ed'   kill-word                       # Alt+D 删除单词
    bindkey -M viins '\e^?'  backward-kill-word              # Alt+Backspace 删除前一个单词
    bindkey -M viins '\e.'   insert-last-word                # Alt+. 插入上一个命令的最后参数

    # 补全增强
    bindkey -M viins '^I'    expand-or-complete              # Tab 补全

    # 特殊编辑功能
    bindkey -M viins '^T'    transpose-chars                 # Ctrl+T 交换字符
    bindkey -M viins '\et'   transpose-words                 # Alt+T 交换单词
    bindkey -M viins '\eu'   up-case-word                    # Alt+U 单词转大写
    bindkey -M viins '\el'   down-case-word                  # Alt+L 单词转小写
    bindkey -M viins '\ec'   capitalize-word                 # Alt+C 单词首字母大写

    # 括号和引号匹配
    bindkey -M viins '^V'    quoted-insert                   # Ctrl+V 插入特殊字符

    # ==================== 普通模式 (Command Mode) ====================
    bindkey -M vicmd '^A'    beginning-of-line               # Ctrl+A 行首
    bindkey -M vicmd '^E'    end-of-line                     # Ctrl+E 行尾
    bindkey -M vicmd '^F'    forward-char                    # Ctrl+F 前进
    bindkey -M vicmd '^B'    backward-char                   # Ctrl+B 后退
    bindkey -M vicmd '^D'    delete-char                     # Ctrl+D 删除字符
    bindkey -M vicmd '^K'    kill-line                       # Ctrl+K 删除到行尾
    bindkey -M vicmd '^U'    backward-kill-line              # Ctrl+U 删除整行
    bindkey -M vicmd '^W'    backward-kill-word              # Ctrl+W 删除单词
    bindkey -M vicmd '^Y'    yank                            # Ctrl+Y 粘贴

    bindkey -M vicmd '^R'    history-incremental-search-backward  # Ctrl+R 反向搜索
    bindkey -M vicmd '^S'    history-incremental-search-forward   # Ctrl+S 正向搜索
    bindkey -M vicmd '^P'    up-history                      # Ctrl+P 上一条历史
    bindkey -M vicmd '^N'    down-history                    # Ctrl+N 下一条历史

    # Vi 风格增强
    bindkey -M vicmd 'gg'    beginning-of-buffer-or-history  # gg 跳到历史开头
    bindkey -M vicmd 'G'     end-of-buffer-or-history        # G 跳到历史结尾
    bindkey -M vicmd 'v'     edit-command-line               # v 进入临时编辑器

    # 单词移动
    bindkey -M vicmd '\ef'   forward-word                    # Alt+F 前进单词
    bindkey -M vicmd '\eb'   backward-word                   # Alt+B 后退单词

    # ==================== 箭头键增强 ====================
    bindkey -M viins '\e[A'  history-beginning-search-backward  # 上箭头 (prefix search)
    bindkey -M viins '\e[B'  history-beginning-search-forward   # 下箭头
    bindkey -M vicmd '\e[A'  up-history                      # 上箭头
    bindkey -M vicmd '\e[B'  down-history                    # 下箭头

    bindkey -M viins '\e[H'  beginning-of-line               # Home
    bindkey -M viins '\e[F'  end-of-line                     # End
    bindkey -M vicmd '\e[H'  beginning-of-line               # Home
    bindkey -M vicmd '\e[F'  end-of-line                     # End

    bindkey -M viins '\e[5~' history-beginning-search-backward  # Page Up
    bindkey -M viins '\e[6~' history-beginning-search-forward   # Page Down

    bindkey -M viins '\e[3~' delete-char                     # Delete
    bindkey -M vicmd '\e[3~' delete-char                     # Delete

    # Enable color support (`$+commands[x]` is a zsh builtin lookup — no fork).
    (( $+commands[dircolors] )) && eval "$(dircolors -b)"
fi


# =============================================================================
# SECTION 1 — OS detection ($SHELLS_OS)
# =============================================================================
# `${var:l}` lowercases — zsh-native, no `tr` fork.

case ${OSTYPE:l} in
    linux*)        SHELLS_OS=linux   ;;
    darwin*)       SHELLS_OS=macos   ;;
    freebsd*)      SHELLS_OS=freebsd ;;
    cygwin*)       SHELLS_OS=cygwin  ;;
    msys*|mingw*)  SHELLS_OS=windows ;;
    *)             SHELLS_OS=unknown ;;
esac
if [[ $SHELLS_OS == linux && -r /proc/version ]]; then
    IFS= read -r __shells_pv < /proc/version
    case ${__shells_pv:l} in
        *microsoft*|*wsl*) SHELLS_OS=wsl ;;
    esac
    unset __shells_pv
fi
export SHELLS_OS


# =============================================================================
# SECTION 2 — Shell environment (interactive zsh behavior)
# =============================================================================
# All defaults use `: ${VAR:=...}` so user values (parent env or ~/.envs
# loaded in SECTION 3) take precedence over what's set here.

# ---- Editor / pager ---------------------------------------------------------
: ${EDITOR:=vim}
: ${VISUAL:=$EDITOR}
: ${PAGER:=less}
: ${LESS:=-R -F -X}
export EDITOR VISUAL PAGER LESS

# ---- zsh history (analogous to bash HISTSIZE / HISTCONTROL / HISTIGNORE) ----
: ${HISTFILE:=$HOME/.zsh_history}
: ${HISTSIZE:=10000}
: ${SAVEHIST:=20000}
# HIST_IGNORE_ALL_DUPS  = remove older duplicates (bash's `erasedups`)
# HIST_IGNORE_SPACE     = entries starting with space aren't saved (bash `ignorespace`)
# HIST_IGNORE_DUPS      = consecutive duplicates aren't saved      (bash `ignoredups`)
# HIST_REDUCE_BLANKS    = collapse extra whitespace in saved entries
# SHARE_HISTORY         = sync history across concurrent sessions
# APPEND_HISTORY        = append on exit, don't overwrite
# EXTENDED_HISTORY      = save timestamp + duration with each entry
setopt APPEND_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE \
       HIST_REDUCE_BLANKS HIST_FIND_NO_DUPS SHARE_HISTORY EXTENDED_HISTORY

# ---- XDG Base Directory -----------------------------------------------------
: ${XDG_CONFIG_HOME:=$HOME/.config}
: ${XDG_DATA_HOME:=$HOME/.local/share}
: ${XDG_CACHE_HOME:=$HOME/.cache}
: ${XDG_STATE_HOME:=$HOME/.local/state}
export XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME XDG_STATE_HOME

# ---- Cygwin / MSYS native symlink support -----------------------------------
case $SHELLS_OS in
    cygwin)  export CYGWIN=winsymlinks:native MSYS=winsymlinks:nativestrict ;;
    windows) export MSYS=winsymlinks:nativestrict ;;
esac


# =============================================================================
# SECTION 3 — User file loaders (~/.envs and ~/.aliases)
# =============================================================================
# Loaded early so user-supplied env values override SECTION 2 / SECTION 4
# defaults (which use `: ${VAR:=...}`).
#
# zsh's killer feature: `typeset -U path` makes the `path` array (linked to
# `$PATH`) auto-deduplicate on every assignment, keeping the leftmost
# occurrence. Every PATH operation in this file collapses to a plain array
# assignment — no dedup loop, no `case ":$PATH:" in *":$d:"*` test.
typeset -U path PATH
export PATH

# Dedup-prepend a `:`-separated list onto $PATH (leftmost wins).
# Existing PATH is always preserved at the tail — caller need not include {PATH}.
__shells_path_prepend() {
    local p
    local -a entries
    for p in ${(s.:.)1}; do
        [[ -n $p ]] && entries+=($p)
    done
    # `entries` first, then current path. typeset -U drops duplicates from the
    # right, so each entry's leftmost position wins.
    path=($entries $path)
}

# Parse a KEY=VALUE file into the environment (PATH gets special handling).
__shells_load_envs() {
    local file=$1 line key val
    [[ -r $file ]] || return 0
    while IFS= read -r line || [[ -n $line ]]; do
        line=${line#${line%%[![:space:]]*}}                  # ltrim
        [[ -z $line || ${line[1]} == '#' ]] && continue
        [[ $line == *=* ]] || continue
        key=${line%%=*}; val=${line#*=}
        key=${key%${key##*[![:space:]]}}                     # rtrim key
        val=${val#${val%%[![:space:]]*}}                     # ltrim val
        val=${val%${val##*[![:space:]]}}                     # rtrim val
        case $key in ''|[0-9]*|*[!A-Za-z0-9_]*) continue ;; esac
        case $val in \"*\"|\'*\') val=${val[2,-2]} ;; esac   # strip outer quotes
        val=${val//\{HOME\}/$HOME}
        val=${val//\{PATH\}/$PATH}
        if [[ $key == PATH ]]; then
            __shells_path_prepend $val
        else
            export ${key}=$val
        fi
    done < $file
}

# Parse a name=command file into zsh aliases.
__shells_load_aliases() {
    local file=$1 line name body
    [[ -r $file ]] || return 0
    while IFS= read -r line || [[ -n $line ]]; do
        line=${line#${line%%[![:space:]]*}}
        [[ -z $line || ${line[1]} == '#' ]] && continue
        [[ $line == *=* ]] || continue
        name=${line%%=*}; body=${line#*=}
        name=${name%${name##*[![:space:]]}}
        case $name in ''|[0-9-]*|*[!A-Za-z0-9_-]*) continue ;; esac
        case $body in \"*\"|\'*\') body=${body[2,-2]} ;; esac
        # zsh `alias name=value` takes value literally — no re-parsing.
        alias -- $name=$body
    done < $file
}

__shells_load_envs    $HOME/.envs
__shells_load_aliases $HOME/.aliases

unset -f __shells_path_prepend __shells_load_envs __shells_load_aliases


# =============================================================================
# SECTION 4 — Language & toolchain environment variables (non-PATH)
# =============================================================================
# Detected paths (GOROOT/JAVA_HOME/ANACONDA_HOME/...) are skipped if already
# set, so users can override via ~/.envs (loaded above).
#
# `(N-/)` is a zsh glob qualifier: N = no error if missing, - = follow symlinks,
# / = directories only. A non-existent or non-directory path expands to
# nothing, so the loop body doesn't run — replaces every `[ -d ]` test.

# ---- Node.js ecosystem ------------------------------------------------------
: ${NPM_CONFIG_PREFIX:=$HOME/.npm-global}
: ${PNPM_HOME:=$HOME/.pnpm-global}
export NPM_CONFIG_PREFIX PNPM_HOME
[[ -d $HOME/.fnm  ]]       && export FNM_DIR=$HOME/.fnm
[[ -d $HOME/.bun  ]]       && export BUN_INSTALL=$HOME/.bun
[[ -d $HOME/.deno ]]       && export DENO_INSTALL=$HOME/.deno
# nvm is intentionally NOT auto-sourced (nvm.sh adds ~200-500 ms to startup).
# Users who want it can add to ~/.zshrc:
#     [[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh

# ---- Go ---------------------------------------------------------------------
: ${GOPATH:=$HOME/go}
export GOPATH
# Anonymous function for local scope — `local` at script top-level prints the
# variable on assignment (zsh treats it as `typeset` there).
[[ -z $GOROOT ]] && () {
    local d
    for d in /home/linuxbrew/.linuxbrew/opt/go/libexec(N-/) \
             /opt/homebrew/opt/go/libexec(N-/) \
             /usr/local/go(N-/) \
             $HOME/.local/go(N-/); do
        export GOROOT=$d
        return
    done
}

# ---- Python (Anaconda / Poetry / Pyenv detection) ---------------------------
[[ -z $ANACONDA_HOME ]] && () {
    local d
    for d in $HOME/anaconda3(N-/) $HOME/miniconda3(N-/) /opt/anaconda3(N-/) /opt/miniconda3(N-/); do
        export ANACONDA_HOME=$d
        return
    done
}
[[ -d $HOME/.poetry ]] && export POETRY_HOME=$HOME/.poetry
[[ -d $HOME/.pyenv  ]] && export PYENV_ROOT=$HOME/.pyenv

# ---- Java (JAVA_HOME only; JAVA_OPTS intentionally NOT set — pollutes JVMs) -
[[ -z $JAVA_HOME ]] && () {
    if [[ -x /usr/libexec/java_home ]]; then
        JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null) && export JAVA_HOME
        return
    fi
    local d
    for d in /usr/lib/jvm/default-java(N-/) /usr/lib/jvm/java-11-openjdk-amd64(N-/); do
        export JAVA_HOME=$d
        return
    done
}

# ---- Linux/WSL system libs (used by rustc / CUDA builds) --------------------
case $SHELLS_OS in
    linux|wsl)
        for __shells_libdir in /usr/lib/x86_64-linux-gnu /usr/lib/aarch64-linux-gnu; do
            [[ -d $__shells_libdir ]] || continue
            export LIBRARY_PATH="$__shells_libdir${LIBRARY_PATH:+:$LIBRARY_PATH}"
            export LD_LIBRARY_PATH="$__shells_libdir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
            export RUSTFLAGS="-L $__shells_libdir"
            break
        done
        unset __shells_libdir
        ;;
esac

# ---- Docker -----------------------------------------------------------------
: ${DOCKER_BUILDKIT:=1}
: ${COMPOSE_DOCKER_CLI_BUILD:=1}
export DOCKER_BUILDKIT COMPOSE_DOCKER_CLI_BUILD


# =============================================================================
# SECTION 5 — PATH (unified, sub-sections by purpose)
# =============================================================================

# ---- Helpers ----------------------------------------------------------------
# Variadic: each arg is added if it exists and isn't already in PATH.
# Semantics match repeated calls — `prepend A B C` ⇒ `C:B:A:PATH` (C leftmost).
# Conditional args via `${VAR:+$VAR/bin}` expand to "" when VAR is empty;
# the `-d $d` test then filters them out silently.
# Dedup is handled by `typeset -U path` (declared in SECTION 3) — no extra
# membership test needed.
__shells_prepend_dir() {
    local d
    for d in "$@"; do
        [[ -n $d && -d $d ]] && path=($d $path)
    done
}
__shells_append_dir() {
    local d
    for d in "$@"; do
        [[ -n $d && -d $d ]] && path=($path $d)
    done
}

# ---- Local user bins (lowest priority — appended) ---------------------------
__shells_append_dir \
    $HOME/.lmstudio/bin \
    $HOME/.local/bin \
    $HOME/bin \
    $HOME/Applications \
    $HOME/.local/Applications

# ---- Tool installation dirs (prepended — leftmost wins) ---------------------
__shells_prepend_dir \
    ${CARGO_HOME:-$HOME/.cargo}/bin \
    $HOME/.rd/bin \
    $HOME/.opencode/bin
# Cargo's own env file (if present) augments PATH / RUSTUP_HOME / etc.
[[ -r $HOME/.cargo/env ]] && . $HOME/.cargo/env

# ---- Language runtimes (uses env vars set in SECTION 4) ---------------------
# Node ecosystem
__shells_prepend_dir \
    ${BUN_INSTALL:+$BUN_INSTALL/bin} \
    ${DENO_INSTALL:+$DENO_INSTALL/bin} \
    $NPM_CONFIG_PREFIX/bin \
    $PNPM_HOME \
    $HOME/.yarn/bin \
    $HOME/.config/yarn/global/node_modules/.bin \
    $HOME/.volta/bin \
    $HOME/.fnm \
    $HOME/.local/share/npm/bin

# Python ecosystem
__shells_prepend_dir \
    ${PYENV_ROOT:+$PYENV_ROOT/bin} \
    ${ANACONDA_HOME:+$ANACONDA_HOME/bin} \
    ${POETRY_HOME:+$POETRY_HOME/bin} \
    $HOME/.poetry/bin \
    $HOME/.local/pipx/bin

# Go
__shells_prepend_dir \
    $GOPATH/bin \
    ${GOROOT:+$GOROOT/bin}

# ---- Linux package-manager dirs (appended — low priority) -------------------
case $SHELLS_OS in
    linux|wsl)
        __shells_append_dir \
            /snap/bin \
            /var/lib/flatpak/exports/bin \
            $HOME/.local/share/flatpak/exports/bin \
            /opt/bin
        ;;
esac

# ---- Windows-environment integration ----------------------------------------
# WSL / Cygwin / MSYS2 (Git Bash): bring in MSYS2 native bin + Windows VS Code
case $SHELLS_OS in
    wsl)
        __shells_append_dir \
            "/mnt/c/Program Files/Microsoft VS Code/bin" \
            "/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin"
        ;;
    cygwin)
        __shells_prepend_dir /mingw64/bin
        __shells_append_dir \
            "/cygdrive/c/Program Files/Microsoft VS Code/bin" \
            "/cygdrive/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin"
        ;;
    windows)
        __shells_prepend_dir /mingw64/bin
        __shells_append_dir \
            "/c/Program Files/Microsoft VS Code/bin" \
            "/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin"
        ;;
esac

# ---- Homebrew (auto-detect prefix; sets PATH/MANPATH/INFOPATH/HOMEBREW_*) ---
# `brew shellenv zsh` emits zsh-syntax env exports; eval'd directly.
() {
    local brew
    for brew in /home/linuxbrew/.linuxbrew/bin/brew \
                $HOME/.linuxbrew/bin/brew \
                /opt/homebrew/bin/brew \
                /usr/local/bin/brew; do
        if [[ -x $brew ]]; then
            eval "$($brew shellenv zsh)"
            return
        fi
    done
}

unset -f __shells_prepend_dir __shells_append_dir


# =============================================================================
# SECTION 6 — File listing & navigation aliases
# =============================================================================

# ---- ls / grep family (OS-aware color) --------------------------------------
case $SHELLS_OS in
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

alias md='mkdir -p'

alias now='date +%Y-%m-%dT%H:%M:%S%z'
alias cls='clear'

alias reload='. ~/.zshrc'

# `path` prints $PATH entries one per line — uses zsh's native `path` array.
# NOTE: zsh exposes `path` as a builtin array variable (linked to $PATH); this
# function shadows it. Use `print -l -- $PATH_ARRAY_NAME` if you need raw access.
path() { print -l -- $path }


# =============================================================================
# SECTION 7 — OS-specific aliases (clipboard / file manager / package manager)
# =============================================================================
# `$+commands[x]` is a zsh associative-array lookup — true if `x` is on PATH.
# Same effect as bash's `command -v x >/dev/null 2>&1`, but no fork.

case $SHELLS_OS in
    macos)
        alias clip='pbcopy'
        alias paste='pbpaste'
        alias finder='open .'
        alias brewup='brew update && brew upgrade && brew cleanup'
        ;;
    linux|wsl)
        if   (( $+commands[wl-copy] )); then                        # Wayland
            alias clip='wl-copy'
            alias paste='wl-paste'
        elif (( $+commands[xclip] )); then                          # X11
            alias clip='xclip -selection clipboard'
            alias paste='xclip -selection clipboard -o'
        elif (( $+commands[xsel] )); then                           # X11 fallback
            alias clip='xsel --clipboard --input'
            alias paste='xsel --clipboard --output'
        fi
        [[ $SHELLS_OS == wsl ]] && alias explorer='explorer.exe .'
        (( $+commands[brew] )) && alias brewup='brew update && brew upgrade && brew cleanup'
        (( $+commands[apt]  )) && alias aptup='sudo apt update && sudo apt upgrade'
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
myip() { curl -fsS https://ifconfig.me && print }

case $SHELLS_OS in
    linux|wsl)         alias localip='hostname -I'; alias ports='ss -tulnp' ;;
    macos|freebsd)     alias localip='ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1'
                       alias ports='lsof -nP -iTCP -sTCP:LISTEN' ;;
esac

# ---- Proxy toggle -----------------------------------------------------------
# Override PROXY_HOST / PROXY_PORT in ~/.envs (or your rc) before sourcing.
: ${PROXY_HOST:=127.0.0.1}
: ${PROXY_PORT:=3067}

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
        *) print -u2 "usage: proxy [[host] port]"; return 2 ;;
    esac
    url="http://$host:$port"
    export http_proxy=$url https_proxy=$url HTTP_PROXY=$url HTTPS_PROXY=$url
    print "proxy on  ($host:$port)"
}

socks5() {
    local host port url
    case $# in
        0) host=$PROXY_HOST port=$PROXY_PORT ;;
        1) host=$PROXY_HOST port=$1 ;;
        2) host=$1 port=$2 ;;
        *) print -u2 "usage: socks5 [[host] port]"; return 2 ;;
    esac
    url="socks5://$host:$port"
    export all_proxy=$url ALL_PROXY=$url
    print "socks5 on ($host:$port)"
}

unproxy() {
    unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY
    print "proxy off"
}

proxyinfo() {
    printf "http : %s\nhttps: %s\nsocks: %s\n" \
        "${http_proxy:-unset}" "${https_proxy:-unset}" "${all_proxy:-unset}"
}


# =============================================================================
# SECTION 9 — Custom utility functions
# =============================================================================

# mkdir -p <dir> && cd into it
mkcd() {
    [[ -z $1 ]] && { print -u2 "usage: mkcd <dir>"; return 2 }
    mkdir -p -- $1 && cd -- $1
}

# Backup a file/dir to <name>.bak.<timestamp> (cp -a preserves attrs/symlinks).
# `${(%):-%D{...}}` is zsh prompt expansion applied to a parameter default —
# pure builtin, no `date` fork, no zmodload needed.
bak() {
    [[ -z $1 ]] && { print -u2 "usage: bak <path>"; return 2 }
    cp -a -- $1 $1.bak.${(%):-%D{%Y%m%d_%H%M%S}}
}

# Same as bak but moves instead of copies
mbak() {
    [[ -z $1 ]] && { print -u2 "usage: mbak <path>"; return 2 }
    mv -- $1 $1.bak.${(%):-%D{%Y%m%d_%H%M%S}}
}

# Weather report via wttr.in (optional location; default = geolocation by IP)
weather() {
    curl -fsS "https://wttr.in/${1:-}"
}


# =============================================================================
# SECTION 10 — Interactive prompt (PROMPT + precmd hook)
# =============================================================================
# Selection order:
#   1. starship  — if installed (best UX, written in Rust, very fast)
#   2. fast native — pure zsh prompt-expansion (%n / %~ / %D{...} / %F{N}),
#      plus a precmd hook that walks PWD for .git. Zero forks outside repos.
#
# Opt-out: set SHELLS_NO_PROMPT=1 in ~/.envs before sourcing.
#
# Color codes match the bash config 1:1 — zsh's `%F{N}` for N in 0..15 emits
# the same ANSI sequence as `\e[3Nm` / `\e[9(N-8)m`. The reference code's
# multi-language version detection was deliberately omitted (each version
# subcommand is a 10-30 ms fork — multi-lang repos could push prompt latency
# past 300 ms). `$VIRTUAL_ENV` / `$CONDA_DEFAULT_ENV` are still shown
# (env-var lookup, no fork).

if [[ -o interactive && -z ${SHELLS_NO_PROMPT:-} ]]; then
    if (( $+commands[starship] )); then
        eval "$(starship init zsh)"
    else
        # Cache whether git is installed (saves a `$+commands` lookup per prompt).
        (( $+commands[git] )) && typeset -g __shells_has_git=1

        # `${...}` substitution in PROMPT requires PROMPT_SUBST. `%F{}/%f` and
        # other `%`-sequences work without it.
        setopt PROMPT_SUBST

        # Declare globals up-front so PROMPT can reference them before the
        # first precmd run (e.g. on the very first prompt).
        typeset -g __shells_extra='' __shells_rc_display=''

        __shells_precmd() {
            # Capture exit code FIRST — everything below resets $?.
            local rc=$?
            if (( rc != 0 )); then
                __shells_rc_display=" %F{red}[$rc]%f"
            else
                __shells_rc_display=''
            fi

            # Python venv / conda env name — free (no fork). `${var:t}` is
            # zsh's :tail modifier (basename without forking `basename`).
            if [[ -n $VIRTUAL_ENV ]]; then
                __shells_extra=" %F{cyan}(${VIRTUAL_ENV:t})%f"
            elif [[ -n $CONDA_DEFAULT_ENV && $CONDA_DEFAULT_ENV != base ]]; then
                __shells_extra=" %F{cyan}($CONDA_DEFAULT_ENV)%f"
            else
                __shells_extra=''
            fi

            # Git: walk PWD upwards looking for .git — zero forks if not in a
            # repo. `.git` is a directory in normal repos, a file in
            # worktrees/submodules.
            if (( ${+__shells_has_git} )); then
                local d=$PWD branch dirty
                while [[ -n $d && $d != / ]]; do
                    if [[ -e $d/.git ]]; then
                        branch=$(git symbolic-ref --short HEAD 2>/dev/null) \
                            || branch=$(git rev-parse --short HEAD 2>/dev/null)
                        if [[ -n $branch ]]; then
                            # `git diff-index --quiet HEAD` is much faster than
                            # `git status --porcelain` on large repos (no scan).
                            dirty=''
                            git diff-index --quiet HEAD -- 2>/dev/null || dirty='*'
                            __shells_extra+=" %F{magenta}${branch}${dirty}%f"
                        fi
                        break
                    fi
                    d=${d%/*}
                done
            fi
        }

        # `precmd_functions` is a zsh array of functions called before each
        # prompt. `+=` appends so the user's existing precmd hooks keep running.
        # Guard against duplicates so `reload` doesn't stack the callback.
        if [[ -z ${precmd_functions[(r)__shells_precmd]} ]]; then
            precmd_functions+=(__shells_precmd)
        fi

        # %F{8}  = bright black (matches bash \e[90m)
        # %F{15} = bright white (matches bash \e[97m)
        # %(?.X.Y) — show X if last exit==0 else Y; we hard-code the non-zero
        # branch in __shells_rc_display so the user gets the actual code.
        PROMPT=$'%F{8}[%D{%H:%M:%S}]%f %F{green}%n%F{15}@%m%f %F{blue}[%~]%f${__shells_extra}${__shells_rc_display}\n%F{cyan}$%f '
    fi
fi



# =============================================================================
# SECTION 11 — Zsh Plugins
# =============================================================================
# 11.1. zsh-autosuggestions:
# # Fish-like fast/unobtrusive autosuggestions for zsh.
# https://github.com/zsh-users/zsh-autosuggestions
# v0.7.1
# Copyright (c) 2013 Thiago de Arruda
# Copyright (c) 2016-2021 Eric Freese
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

#--------------------------------------------------------------------#
# Global Configuration Variables                                     #
#--------------------------------------------------------------------#

# Color to use when highlighting suggestion
# Uses format of `region_highlight`
# More info: http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets
(( ! ${+ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE} )) &&
typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Prefix to use when saving original versions of bound widgets
(( ! ${+ZSH_AUTOSUGGEST_ORIGINAL_WIDGET_PREFIX} )) &&
typeset -g ZSH_AUTOSUGGEST_ORIGINAL_WIDGET_PREFIX=autosuggest-orig-

# Strategies to use to fetch a suggestion
# Will try each strategy in order until a suggestion is returned
(( ! ${+ZSH_AUTOSUGGEST_STRATEGY} )) && {
	typeset -ga ZSH_AUTOSUGGEST_STRATEGY
	ZSH_AUTOSUGGEST_STRATEGY=(history)
}

# Widgets that clear the suggestion
(( ! ${+ZSH_AUTOSUGGEST_CLEAR_WIDGETS} )) && {
	typeset -ga ZSH_AUTOSUGGEST_CLEAR_WIDGETS
	ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(
		history-search-forward
		history-search-backward
		history-beginning-search-forward
		history-beginning-search-backward
		history-beginning-search-forward-end
		history-beginning-search-backward-end
		history-substring-search-up
		history-substring-search-down
		up-line-or-beginning-search
		down-line-or-beginning-search
		up-line-or-history
		down-line-or-history
		accept-line
		copy-earlier-word
	)
}

# Widgets that accept the entire suggestion
(( ! ${+ZSH_AUTOSUGGEST_ACCEPT_WIDGETS} )) && {
	typeset -ga ZSH_AUTOSUGGEST_ACCEPT_WIDGETS
	ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(
		forward-char
		end-of-line
		vi-forward-char
		vi-end-of-line
		vi-add-eol
	)
}

# Widgets that accept the entire suggestion and execute it
(( ! ${+ZSH_AUTOSUGGEST_EXECUTE_WIDGETS} )) && {
	typeset -ga ZSH_AUTOSUGGEST_EXECUTE_WIDGETS
	ZSH_AUTOSUGGEST_EXECUTE_WIDGETS=(
	)
}

# Widgets that accept the suggestion as far as the cursor moves
(( ! ${+ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS} )) && {
	typeset -ga ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS
	ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
		forward-word
		emacs-forward-word
		vi-forward-word
		vi-forward-word-end
		vi-forward-blank-word
		vi-forward-blank-word-end
		vi-find-next-char
		vi-find-next-char-skip
	)
}

# Widgets that should be ignored (globbing supported but must be escaped)
(( ! ${+ZSH_AUTOSUGGEST_IGNORE_WIDGETS} )) && {
	typeset -ga ZSH_AUTOSUGGEST_IGNORE_WIDGETS
	ZSH_AUTOSUGGEST_IGNORE_WIDGETS=(
		orig-\*
		beep
		run-help
		set-local-history
		which-command
		yank
		yank-pop
		zle-\*
	)
}

# Pty name for capturing completions for completion suggestion strategy
(( ! ${+ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME} )) &&
typeset -g ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME=zsh_autosuggest_completion_pty

#--------------------------------------------------------------------#
# Utility Functions                                                  #
#--------------------------------------------------------------------#

_zsh_autosuggest_escape_command() {
	setopt localoptions EXTENDED_GLOB

	# Escape special chars in the string (requires EXTENDED_GLOB)
	echo -E "${1//(#m)[\"\'\\()\[\]|*?~]/\\$MATCH}"
}

#--------------------------------------------------------------------#
# Widget Helpers                                                     #
#--------------------------------------------------------------------#

_zsh_autosuggest_incr_bind_count() {
	typeset -gi bind_count=$((_ZSH_AUTOSUGGEST_BIND_COUNTS[$1]+1))
	_ZSH_AUTOSUGGEST_BIND_COUNTS[$1]=$bind_count
}

# Bind a single widget to an autosuggest widget, saving a reference to the original widget
_zsh_autosuggest_bind_widget() {
	typeset -gA _ZSH_AUTOSUGGEST_BIND_COUNTS

	local widget=$1
	local autosuggest_action=$2
	local prefix=$ZSH_AUTOSUGGEST_ORIGINAL_WIDGET_PREFIX

	local -i bind_count

	# Save a reference to the original widget
	case $widgets[$widget] in
		# Already bound
		user:_zsh_autosuggest_(bound|orig)_*)
			bind_count=$((_ZSH_AUTOSUGGEST_BIND_COUNTS[$widget]))
			;;

		# User-defined widget
		user:*)
			_zsh_autosuggest_incr_bind_count $widget
			zle -N $prefix$bind_count-$widget ${widgets[$widget]#*:}
			;;

		# Built-in widget
		builtin)
			_zsh_autosuggest_incr_bind_count $widget
			eval "_zsh_autosuggest_orig_${(q)widget}() { zle .${(q)widget} }"
			zle -N $prefix$bind_count-$widget _zsh_autosuggest_orig_$widget
			;;

		# Completion widget
		completion:*)
			_zsh_autosuggest_incr_bind_count $widget
			eval "zle -C $prefix$bind_count-${(q)widget} ${${(s.:.)widgets[$widget]}[2,3]}"
			;;
	esac

	# Pass the original widget's name explicitly into the autosuggest
	# function. Use this passed in widget name to call the original
	# widget instead of relying on the $WIDGET variable being set
	# correctly. $WIDGET cannot be trusted because other plugins call
	# zle without the `-w` flag (e.g. `zle self-insert` instead of
	# `zle self-insert -w`).
	eval "_zsh_autosuggest_bound_${bind_count}_${(q)widget}() {
		_zsh_autosuggest_widget_$autosuggest_action $prefix$bind_count-${(q)widget} \$@
	}"

	# Create the bound widget
	zle -N -- $widget _zsh_autosuggest_bound_${bind_count}_$widget
}

# Map all configured widgets to the right autosuggest widgets
_zsh_autosuggest_bind_widgets() {
	emulate -L zsh

 	local widget
	local ignore_widgets

	ignore_widgets=(
		.\*
		_\*
		${_ZSH_AUTOSUGGEST_BUILTIN_ACTIONS/#/autosuggest-}
		$ZSH_AUTOSUGGEST_ORIGINAL_WIDGET_PREFIX\*
		$ZSH_AUTOSUGGEST_IGNORE_WIDGETS
	)

	# Find every widget we might want to bind and bind it appropriately
	for widget in ${${(f)"$(builtin zle -la)"}:#${(j:|:)~ignore_widgets}}; do
		if [[ -n ${ZSH_AUTOSUGGEST_CLEAR_WIDGETS[(r)$widget]} ]]; then
			_zsh_autosuggest_bind_widget $widget clear
		elif [[ -n ${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[(r)$widget]} ]]; then
			_zsh_autosuggest_bind_widget $widget accept
		elif [[ -n ${ZSH_AUTOSUGGEST_EXECUTE_WIDGETS[(r)$widget]} ]]; then
			_zsh_autosuggest_bind_widget $widget execute
		elif [[ -n ${ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS[(r)$widget]} ]]; then
			_zsh_autosuggest_bind_widget $widget partial_accept
		else
			# Assume any unspecified widget might modify the buffer
			_zsh_autosuggest_bind_widget $widget modify
		fi
	done
}

# Given the name of an original widget and args, invoke it, if it exists
_zsh_autosuggest_invoke_original_widget() {
	# Do nothing unless called with at least one arg
	(( $# )) || return 0

	local original_widget_name="$1"

	shift

	if (( ${+widgets[$original_widget_name]} )); then
		zle $original_widget_name -- $@
	fi
}

#--------------------------------------------------------------------#
# Highlighting                                                       #
#--------------------------------------------------------------------#

# If there was a highlight, remove it
_zsh_autosuggest_highlight_reset() {
	typeset -g _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT

	if [[ -n "$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT" ]]; then
		region_highlight=("${(@)region_highlight:#$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT}")
		unset _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT
	fi
}

# If there's a suggestion, highlight it
_zsh_autosuggest_highlight_apply() {
	typeset -g _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT

	if (( $#POSTDISPLAY )); then
		typeset -g _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT="$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) $ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"
		region_highlight+=("$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT")
	else
		unset _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT
	fi
}

#--------------------------------------------------------------------#
# Autosuggest Widget Implementations                                 #
#--------------------------------------------------------------------#

# Disable suggestions
_zsh_autosuggest_disable() {
	typeset -g _ZSH_AUTOSUGGEST_DISABLED
	_zsh_autosuggest_clear
}

# Enable suggestions
_zsh_autosuggest_enable() {
	unset _ZSH_AUTOSUGGEST_DISABLED

	if (( $#BUFFER )); then
		_zsh_autosuggest_fetch
	fi
}

# Toggle suggestions (enable/disable)
_zsh_autosuggest_toggle() {
	if (( ${+_ZSH_AUTOSUGGEST_DISABLED} )); then
		_zsh_autosuggest_enable
	else
		_zsh_autosuggest_disable
	fi
}

# Clear the suggestion
_zsh_autosuggest_clear() {
	# Remove the suggestion
	POSTDISPLAY=

	_zsh_autosuggest_invoke_original_widget $@
}

# Modify the buffer and get a new suggestion
_zsh_autosuggest_modify() {
	local -i retval

	# Only available in zsh >= 5.4
	local -i KEYS_QUEUED_COUNT

	# Save the contents of the buffer/postdisplay
	local orig_buffer="$BUFFER"
	local orig_postdisplay="$POSTDISPLAY"

	# Clear suggestion while waiting for next one
	POSTDISPLAY=

	# Original widget may modify the buffer
	_zsh_autosuggest_invoke_original_widget $@
	retval=$?

	emulate -L zsh

	# Don't fetch a new suggestion if there's more input to be read immediately
	if (( $PENDING > 0 || $KEYS_QUEUED_COUNT > 0 )); then
		POSTDISPLAY="$orig_postdisplay"
		return $retval
	fi

	# Optimize if manually typing in the suggestion or if buffer hasn't changed
	if [[ "$BUFFER" = "$orig_buffer"* && "$orig_postdisplay" = "${BUFFER:$#orig_buffer}"* ]]; then
		POSTDISPLAY="${orig_postdisplay:$(($#BUFFER - $#orig_buffer))}"
		return $retval
	fi

	# Bail out if suggestions are disabled
	if (( ${+_ZSH_AUTOSUGGEST_DISABLED} )); then
		return $?
	fi

	# Get a new suggestion if the buffer is not empty after modification
	if (( $#BUFFER > 0 )); then
		if [[ -z "$ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE" ]] || (( $#BUFFER <= $ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE )); then
			_zsh_autosuggest_fetch
		fi
	fi

	return $retval
}

# Fetch a new suggestion based on what's currently in the buffer
_zsh_autosuggest_fetch() {
	if (( ${+ZSH_AUTOSUGGEST_USE_ASYNC} )); then
		_zsh_autosuggest_async_request "$BUFFER"
	else
		local suggestion
		_zsh_autosuggest_fetch_suggestion "$BUFFER"
		_zsh_autosuggest_suggest "$suggestion"
	fi
}

# Offer a suggestion
_zsh_autosuggest_suggest() {
	emulate -L zsh

	local suggestion="$1"

	if [[ -n "$suggestion" ]] && (( $#BUFFER )); then
		POSTDISPLAY="${suggestion#$BUFFER}"
	else
		POSTDISPLAY=
	fi
}

# Accept the entire suggestion
_zsh_autosuggest_accept() {
	local -i retval max_cursor_pos=$#BUFFER

	# When vicmd keymap is active, the cursor can't move all the way
	# to the end of the buffer
	if [[ "$KEYMAP" = "vicmd" ]]; then
		max_cursor_pos=$((max_cursor_pos - 1))
	fi

	# If we're not in a valid state to accept a suggestion, just run the
	# original widget and bail out
	if (( $CURSOR != $max_cursor_pos || !$#POSTDISPLAY )); then
		_zsh_autosuggest_invoke_original_widget $@
		return
	fi

	# Only accept if the cursor is at the end of the buffer
	# Add the suggestion to the buffer
	BUFFER="$BUFFER$POSTDISPLAY"

	# Remove the suggestion
	POSTDISPLAY=

	# Run the original widget before manually moving the cursor so that the
	# cursor movement doesn't make the widget do something unexpected
	_zsh_autosuggest_invoke_original_widget $@
	retval=$?

	# Move the cursor to the end of the buffer
	if [[ "$KEYMAP" = "vicmd" ]]; then
		CURSOR=$(($#BUFFER - 1))
	else
		CURSOR=$#BUFFER
	fi

	return $retval
}

# Accept the entire suggestion and execute it
_zsh_autosuggest_execute() {
	# Add the suggestion to the buffer
	BUFFER="$BUFFER$POSTDISPLAY"

	# Remove the suggestion
	POSTDISPLAY=

	# Call the original `accept-line` to handle syntax highlighting or
	# other potential custom behavior
	_zsh_autosuggest_invoke_original_widget "accept-line"
}

# Partially accept the suggestion
_zsh_autosuggest_partial_accept() {
	local -i retval cursor_loc

	# Save the contents of the buffer so we can restore later if needed
	local original_buffer="$BUFFER"

	# Temporarily accept the suggestion.
	BUFFER="$BUFFER$POSTDISPLAY"

	# Original widget moves the cursor
	_zsh_autosuggest_invoke_original_widget $@
	retval=$?

	# Normalize cursor location across vi/emacs modes
	cursor_loc=$CURSOR
	if [[ "$KEYMAP" = "vicmd" ]]; then
		cursor_loc=$((cursor_loc + 1))
	fi

	# If we've moved past the end of the original buffer
	if (( $cursor_loc > $#original_buffer )); then
		# Set POSTDISPLAY to text right of the cursor
		POSTDISPLAY="${BUFFER[$(($cursor_loc + 1)),$#BUFFER]}"

		# Clip the buffer at the cursor
		BUFFER="${BUFFER[1,$cursor_loc]}"
	else
		# Restore the original buffer
		BUFFER="$original_buffer"
	fi

	return $retval
}

() {
	typeset -ga _ZSH_AUTOSUGGEST_BUILTIN_ACTIONS

	_ZSH_AUTOSUGGEST_BUILTIN_ACTIONS=(
		clear
		fetch
		suggest
		accept
		execute
		enable
		disable
		toggle
	)

	local action
	for action in $_ZSH_AUTOSUGGEST_BUILTIN_ACTIONS modify partial_accept; do
		eval "_zsh_autosuggest_widget_$action() {
			local -i retval

			_zsh_autosuggest_highlight_reset

			_zsh_autosuggest_$action \$@
			retval=\$?

			_zsh_autosuggest_highlight_apply

			zle -R

			return \$retval
		}"
	done

	for action in $_ZSH_AUTOSUGGEST_BUILTIN_ACTIONS; do
		zle -N autosuggest-$action _zsh_autosuggest_widget_$action
	done
}

#--------------------------------------------------------------------#
# Completion Suggestion Strategy                                     #
#--------------------------------------------------------------------#
# Fetches a suggestion from the completion engine
#

_zsh_autosuggest_capture_postcompletion() {
	# Always insert the first completion into the buffer
	compstate[insert]=1

	# Don't list completions
	unset 'compstate[list]'
}

_zsh_autosuggest_capture_completion_widget() {
	# Add a post-completion hook to be called after all completions have been
	# gathered. The hook can modify compstate to affect what is done with the
	# gathered completions.
	local -a +h comppostfuncs
	comppostfuncs=(_zsh_autosuggest_capture_postcompletion)

	# Only capture completions at the end of the buffer
	CURSOR=$#BUFFER

	# Run the original widget wrapping `.complete-word` so we don't
	# recursively try to fetch suggestions, since our pty is forked
	# after autosuggestions is initialized.
	zle -- ${(k)widgets[(r)completion:.complete-word:_main_complete]}

	if is-at-least 5.0.3; then
		# Don't do any cr/lf transformations. We need to do this immediately before
		# output because if we do it in setup, onlcr will be re-enabled when we enter
		# vared in the async code path. There is a bug in zpty module in older versions
		# where the tty is not properly attached to the pty slave, resulting in stty
		# getting stopped with a SIGTTOU. See zsh-workers thread 31660 and upstream
		# commit f75904a38
		stty -onlcr -ocrnl -F /dev/tty
	fi

	# The completion has been added, print the buffer as the suggestion
	echo -nE - $'\0'$BUFFER$'\0'
}

zle -N autosuggest-capture-completion _zsh_autosuggest_capture_completion_widget

_zsh_autosuggest_capture_setup() {
	# There is a bug in zpty module in older zsh versions by which a
	# zpty that exits will kill all zpty processes that were forked
	# before it. Here we set up a zsh exit hook to SIGKILL the zpty
	# process immediately, before it has a chance to kill any other
	# zpty processes.
	if ! is-at-least 5.4; then
		zshexit() {
			# The zsh builtin `kill` fails sometimes in older versions
			# https://unix.stackexchange.com/a/477647/156673
			kill -KILL $$ 2>&- || command kill -KILL $$

			# Block for long enough for the signal to come through
			sleep 1
		}
	fi

	# Try to avoid any suggestions that wouldn't match the prefix
	zstyle ':completion:*' matcher-list ''
	zstyle ':completion:*' path-completion false
	zstyle ':completion:*' max-errors 0 not-numeric

	bindkey '^I' autosuggest-capture-completion
}

_zsh_autosuggest_capture_completion_sync() {
	_zsh_autosuggest_capture_setup

	zle autosuggest-capture-completion
}

_zsh_autosuggest_capture_completion_async() {
	_zsh_autosuggest_capture_setup

	zmodload zsh/parameter 2>/dev/null || return # For `$functions`

	# Make vared completion work as if for a normal command line
	# https://stackoverflow.com/a/7057118/154703
	autoload +X _complete
	functions[_original_complete]=$functions[_complete]
	function _complete() {
		unset 'compstate[vared]'
		_original_complete "$@"
	}

	# Open zle with buffer set so we can capture completions for it
	vared 1
}

_zsh_autosuggest_strategy_completion() {
	# Reset options to defaults and enable LOCAL_OPTIONS
	emulate -L zsh

	# Enable extended glob for completion ignore pattern
	setopt EXTENDED_GLOB

	typeset -g suggestion
	local line REPLY

	# Exit if we don't have completions
	whence compdef >/dev/null || return

	# Exit if we don't have zpty
	zmodload zsh/zpty 2>/dev/null || return

	# Exit if our search string matches the ignore pattern
	[[ -n "$ZSH_AUTOSUGGEST_COMPLETION_IGNORE" ]] && [[ "$1" == $~ZSH_AUTOSUGGEST_COMPLETION_IGNORE ]] && return

	# Zle will be inactive if we are in async mode
	if zle; then
		zpty $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME _zsh_autosuggest_capture_completion_sync
	else
		zpty $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME _zsh_autosuggest_capture_completion_async "\$1"
		zpty -w $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME $'\t'
	fi

	{
		# The completion result is surrounded by null bytes, so read the
		# content between the first two null bytes.
		zpty -r $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME line '*'$'\0''*'$'\0'

		# Extract the suggestion from between the null bytes.  On older
		# versions of zsh (older than 5.3), we sometimes get extra bytes after
		# the second null byte, so trim those off the end.
		# See http://www.zsh.org/mla/workers/2015/msg03290.html
		suggestion="${${(@0)line}[2]}"
	} always {
		# Destroy the pty
		zpty -d $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME
	}
}

#--------------------------------------------------------------------#
# History Suggestion Strategy                                        #
#--------------------------------------------------------------------#
# Suggests the most recent history item that matches the given
# prefix.
#

_zsh_autosuggest_strategy_history() {
	# Reset options to defaults and enable LOCAL_OPTIONS
	emulate -L zsh

	# Enable globbing flags so that we can use (#m) and (x~y) glob operator
	setopt EXTENDED_GLOB

	# Escape backslashes and all of the glob operators so we can use
	# this string as a pattern to search the $history associative array.
	# - (#m) globbing flag enables setting references for match data
	# TODO: Use (b) flag when we can drop support for zsh older than v5.0.8
	local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"

	# Get the history items that match the prefix, excluding those that match
	# the ignore pattern
	local pattern="$prefix*"
	if [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]]; then
		pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)"
	fi

	# Give the first history item matching the pattern as the suggestion
	# - (r) subscript flag makes the pattern match on values
	typeset -g suggestion="${history[(r)$pattern]}"
}

#--------------------------------------------------------------------#
# Match Previous Command Suggestion Strategy                         #
#--------------------------------------------------------------------#
# Suggests the most recent history item that matches the given
# prefix and whose preceding history item also matches the most
# recently executed command.
#
# For example, suppose your history has the following entries:
#   - pwd
#   - ls foo
#   - ls bar
#   - pwd
#
# Given the history list above, when you type 'ls', the suggestion
# will be 'ls foo' rather than 'ls bar' because your most recently
# executed command (pwd) was previously followed by 'ls foo'.
#
# Note that this strategy won't work as expected with ZSH options that don't
# preserve the history order such as `HIST_IGNORE_ALL_DUPS` or
# `HIST_EXPIRE_DUPS_FIRST`.

_zsh_autosuggest_strategy_match_prev_cmd() {
	# Reset options to defaults and enable LOCAL_OPTIONS
	emulate -L zsh

	# Enable globbing flags so that we can use (#m) and (x~y) glob operator
	setopt EXTENDED_GLOB

	# TODO: Use (b) flag when we can drop support for zsh older than v5.0.8
	local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"

	# Get the history items that match the prefix, excluding those that match
	# the ignore pattern
	local pattern="$prefix*"
	if [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]]; then
		pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)"
	fi

	# Get all history event numbers that correspond to history
	# entries that match the pattern
	local history_match_keys
	history_match_keys=(${(k)history[(R)$~pattern]})

	# By default we use the first history number (most recent history entry)
	local histkey="${history_match_keys[1]}"

	# Get the previously executed command
	local prev_cmd="$(_zsh_autosuggest_escape_command "${history[$((HISTCMD-1))]}")"

	# Iterate up to the first 200 history event numbers that match $prefix
	for key in "${(@)history_match_keys[1,200]}"; do
		# Stop if we ran out of history
		[[ $key -gt 1 ]] || break

		# See if the history entry preceding the suggestion matches the
		# previous command, and use it if it does
		if [[ "${history[$((key - 1))]}" == "$prev_cmd" ]]; then
			histkey="$key"
			break
		fi
	done

	# Give back the matched history entry
	typeset -g suggestion="$history[$histkey]"
}

#--------------------------------------------------------------------#
# Fetch Suggestion                                                   #
#--------------------------------------------------------------------#
# Loops through all specified strategies and returns a suggestion
# from the first strategy to provide one.
#

_zsh_autosuggest_fetch_suggestion() {
	typeset -g suggestion
	local -a strategies
	local strategy

	# Ensure we are working with an array
	strategies=(${=ZSH_AUTOSUGGEST_STRATEGY})

	for strategy in $strategies; do
		# Try to get a suggestion from this strategy
		_zsh_autosuggest_strategy_$strategy "$1"

		# Ensure the suggestion matches the prefix
		[[ "$suggestion" != "$1"* ]] && unset suggestion

		# Break once we've found a valid suggestion
		[[ -n "$suggestion" ]] && break
	done
}

#--------------------------------------------------------------------#
# Async                                                              #
#--------------------------------------------------------------------#

_zsh_autosuggest_async_request() {
	zmodload zsh/system 2>/dev/null # For `$sysparams`

	typeset -g _ZSH_AUTOSUGGEST_ASYNC_FD _ZSH_AUTOSUGGEST_CHILD_PID

	# If we've got a pending request, cancel it
	if [[ -n "$_ZSH_AUTOSUGGEST_ASYNC_FD" ]] && { true <&$_ZSH_AUTOSUGGEST_ASYNC_FD } 2>/dev/null; then
		# Close the file descriptor and remove the handler
		builtin exec {_ZSH_AUTOSUGGEST_ASYNC_FD}<&-
		zle -F $_ZSH_AUTOSUGGEST_ASYNC_FD

		# We won't know the pid unless the user has zsh/system module installed
		if [[ -n "$_ZSH_AUTOSUGGEST_CHILD_PID" ]]; then
			# Zsh will make a new process group for the child process only if job
			# control is enabled (MONITOR option)
			if [[ -o MONITOR ]]; then
				# Send the signal to the process group to kill any processes that may
				# have been forked by the suggestion strategy
				kill -TERM -$_ZSH_AUTOSUGGEST_CHILD_PID 2>/dev/null
			else
				# Kill just the child process since it wasn't placed in a new process
				# group. If the suggestion strategy forked any child processes they may
				# be orphaned and left behind.
				kill -TERM $_ZSH_AUTOSUGGEST_CHILD_PID 2>/dev/null
			fi
		fi
	fi

	# Fork a process to fetch a suggestion and open a pipe to read from it
	builtin exec {_ZSH_AUTOSUGGEST_ASYNC_FD}< <(
		# Tell parent process our pid
		echo $sysparams[pid]

		# Fetch and print the suggestion
		local suggestion
		_zsh_autosuggest_fetch_suggestion "$1"
		echo -nE "$suggestion"
	)

	# There's a weird bug here where ^C stops working unless we force a fork
	# See https://github.com/zsh-users/zsh-autosuggestions/issues/364
	autoload -Uz is-at-least
	is-at-least 5.8 || command true

	# Read the pid from the child process
	read _ZSH_AUTOSUGGEST_CHILD_PID <&$_ZSH_AUTOSUGGEST_ASYNC_FD

	# When the fd is readable, call the response handler
	zle -F "$_ZSH_AUTOSUGGEST_ASYNC_FD" _zsh_autosuggest_async_response
}

# Called when new data is ready to be read from the pipe
# First arg will be fd ready for reading
# Second arg will be passed in case of error
_zsh_autosuggest_async_response() {
	emulate -L zsh

	local suggestion

	if [[ -z "$2" || "$2" == "hup" ]]; then
		# Read everything from the fd and give it as a suggestion
		IFS='' read -rd '' -u $1 suggestion
		zle autosuggest-suggest -- "$suggestion"

		# Close the fd
		builtin exec {1}<&-
	fi

	# Always remove the handler
	zle -F "$1"
	_ZSH_AUTOSUGGEST_ASYNC_FD=
}

#--------------------------------------------------------------------#
# Start                                                              #
#--------------------------------------------------------------------#

# Start the autosuggestion widgets
_zsh_autosuggest_start() {
	# By default we re-bind widgets on every precmd to ensure we wrap other
	# wrappers. Specifically, highlighting breaks if our widgets are wrapped by
	# zsh-syntax-highlighting widgets. This also allows modifications to the
	# widget list variables to take effect on the next precmd. However this has
	# a decent performance hit, so users can set ZSH_AUTOSUGGEST_MANUAL_REBIND
	# to disable the automatic re-binding.
	if (( ${+ZSH_AUTOSUGGEST_MANUAL_REBIND} )); then
		add-zsh-hook -d precmd _zsh_autosuggest_start
	fi

	_zsh_autosuggest_bind_widgets
}

# Mark for auto-loading the functions that we use
autoload -Uz add-zsh-hook is-at-least

# Automatically enable asynchronous mode in newer versions of zsh. Disable for
# older versions because there is a bug when using async mode where ^C does not
# work immediately after fetching a suggestion.
# See https://github.com/zsh-users/zsh-autosuggestions/issues/364
if is-at-least 5.0.8; then
	typeset -g ZSH_AUTOSUGGEST_USE_ASYNC=
fi

# Start the autosuggestion widgets on the next precmd
add-zsh-hook precmd _zsh_autosuggest_start
