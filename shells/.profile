# 设置语言环境为中文 UTF-8
# export LANG=zh_CN.UTF-8
# export LANGUAGE=zh_CN:zh
# export LC_ALL=zh_CN.UTF-8

# 或者如果上面不行，尝试：
# export LANG=C.UTF-8
# export LC_ALL=C.UTF-8



# common
alias cls='clear'

alias ff='fastfetch'

alias h='history'
alias hist='history'
alias md='mkdir -p'

alias cma='chezmoi apply'
alias cmaf='chezmoi apply --force'

# cd aliases
alias cdl='cd ~/Downloads'
alias cdw='cd ~/workspace'
alias cdm='cd ~/Documents'
alias cdt='cd ~/Desktop'
alias cdv='cd ~/Videos'
alias cds='cd ~/Music'
alias cdp='cd ~/Pictures'
alias cdd='cd ~/.local/share/chezmoi'
alias cdc='cd ~/.local/share/chezmoi'

# ls alias
alias l='ls -S --color=always'
alias ll='ls -lhS --color=always --group-directories-first'
alias la='ls -lhaS --color=always --group-directories-first'
alias lsf="ls -lhaS --color=always --group-directories-first | grep --color=never '^-'"
alias lsd="ls -lhaS --color=always --group-directories-first | grep --color=never '^d'"
alias lsl="ls -lhaS --color=always --group-directories-first | grep --color=never '^l'"
alias lsc="ls -lhaS --color=always --group-directories-first | grep --color=never '^c'"
alias lsb="ls -lhaS --color=always --group-directories-first | grep --color=never '^b'"
alias lsp="ls -lhaS --color=always --group-directories-first | grep --color=never '^p'"
alias lss="ls -lhaS --color=always --group-directories-first | grep --color=never '^s'"
alias lsfl="ls -lhaS --color=always --group-directories-first | grep --color=never '^[l-]'"
alias lsdl="ls -lhaS --color=always --group-directories-first | grep --color=never '^[dl]'"
alias lsdev="ls -lhaS --color=always --group-directories-first | grep --color=never '^[cb]'"
alias lsspec="ls -lhaS --color=always --group-directories-first | grep --color=never '^[ps]'"

# grep series aliases
alias grep='grep --color=always'
alias fgrep='fgrep --color=always'
alias egrep='egrep --color=always'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# System info aliases
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Git Aliases
alias gst='git status'
alias gstsb='git status -sb'
alias gcl='git clone'
alias gpl='git pull'
alias gph='git push'
alias gco='git checkout'
alias gco='git checkout -b'
alias gad='git add'
alias gaa='git add --all'
alias gcm='git commit -m'
alias gac='git add . && git commit -m'
alias gbr='git branch'
alias glg='git log --oneline --graph'
alias gdf='git diff'
alias grs='git reset'
alias gsh='git stash'

# Directory operations
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
