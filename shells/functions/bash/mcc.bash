#!/bin/bash

# Claude Code 多供应商切换工具
#
# 用法：
#   mcc <provider> [key_suffix] [-r|--resume] [-m|--model <model>] [-e|--effort max|normal|min]
#   mcc -l | --list
#
# 新增供应商：在 _MCC_PROVIDERS 中添加一行即可，补全自动生效。

# ============================================================
# 供应商配置（唯一数据源）
# 字段：default_url | api_key_env | base_url_env | big_model | small_model
#
# big_model   → ANTHROPIC_MODEL / DEFAULT_OPUS / DEFAULT_SONNET
# small_model → DEFAULT_HAIKU / CLAUDE_CODE_SUBAGENT_MODEL
# 留空       → 不设置模型变量（适用于透传代理）
# ============================================================
declare -gA _MCC_PROVIDERS=(
    [agentrouter]="https://agentrouter.org|AGENTROUTER_API_KEY|AGENTROUTER_BASE_URL||"
    [anyrouter]="https://anyrouter.top|ANYROUTER_API_KEY|ANYROUTER_BASE_URL||"
    [deepseek]="https://api.deepseek.com/anthropic|DEEPSEEK_API_KEY|DEEPSEEK_BASE_URL|deepseek-v4-pro[1m]|deepseek-v4-flash"
    [kimi]="https://api.moonshot.cn/anthropic|MOONSHOT_API_KEY|MOONSHOT_BASE_URL|kimi-k2.6|kimi-k2.6"
    [glm]="https://open.bigmodel.cn/api/anthropic|GLM_API_KEY|GLM_BASE_URL|GLM-5.1|GLM-5.1"
    [siliconflow]="https://api.siliconflow.cn/|SILICONFLOW_API_KEY|SILICONFLOW_BASE_URL|deepseek-ai/DeepSeek-V4-Pro|deepseek-ai/DeepSeek-V4-Flash"
)

# 别名 → 规范名（新增别名只需在此添加一行）
declare -gA _MCC_ALIASES=(
    [tr]=agentrouter
    [yr]=anyrouter
    [ds]=deepseek
    [km]=kimi
    [sf]=siliconflow
)

# --effort 合法取值（首项为默认值）
declare -ga _MCC_EFFORT_LEVELS=(max normal min)

# 由 mcc 托管的环境变量（每次调用都会先清理，避免上一次设置残留）
# 含已废弃变量（如 ANTHROPIC_SMALL_FAST_MODEL）以防新旧版混用
declare -ga _MCC_MANAGED_VARS=(
    ANTHROPIC_MODEL
    ANTHROPIC_DEFAULT_OPUS_MODEL
    ANTHROPIC_DEFAULT_SONNET_MODEL
    ANTHROPIC_DEFAULT_HAIKU_MODEL
    ANTHROPIC_SMALL_FAST_MODEL
    CLAUDE_CODE_SUBAGENT_MODEL
    CLAUDE_CODE_EFFORT_LEVEL
    API_TIMEOUT_MS
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
)

# ============================================================
# 内部工具函数
# ============================================================

# 解析供应商配置到 _MCC_* 变量
_mcc_parse_config() {
    IFS='|' read -r _MCC_DEFAULT_URL _MCC_KEY_ENV _MCC_URL_ENV _MCC_BIG_MODEL _MCC_SMALL_MODEL \
        <<< "${_MCC_PROVIDERS[$1]}"
}

# 检测 $1 是否在剩余参数中（用于校验受限取值集合）
_mcc_in() {
    local needle="$1"; shift
    local item
    for item in "$@"; do [[ "$item" == "$needle" ]] && return 0; done
    return 1
}

# 输出错误到 stderr（调用方负责 return 退出码）
_mcc_err() { echo "Error: $*" >&2; }

# 掩码显示 API key（仅展示前8位）
_mcc_mask() { echo "${1:0:8}****"; }

# 打印供应商列表及用法说明
_mcc_list() {
    echo "Providers:"
    echo "----------"
    local p a aliases display
    for p in $(printf '%s\n' "${!_MCC_PROVIDERS[@]}" | sort); do
        _mcc_parse_config "$p"
        # 收集该规范名的所有别名
        aliases=""
        for a in "${!_MCC_ALIASES[@]}"; do
            [[ "${_MCC_ALIASES[$a]}" == "$p" ]] && aliases+="$a, "
        done
        display="$p"
        [[ -n "$aliases" ]] && display+=" (${aliases%, })"
        local url="${!_MCC_URL_ENV:-$_MCC_DEFAULT_URL}"
        local from_env=""; [[ -n "${!_MCC_URL_ENV}" ]] && from_env="  [from \$$_MCC_URL_ENV]"
        local model_info=""
        if [[ -n "$_MCC_BIG_MODEL" ]]; then
            model_info="  big=$_MCC_BIG_MODEL"
            [[ "$_MCC_SMALL_MODEL" != "$_MCC_BIG_MODEL" ]] && model_info+=" / small=$_MCC_SMALL_MODEL"
        fi
        printf "  %-20s %s%s%s\n" "$display" "$url" "$from_env" "$model_info"
    done
    cat <<'EOF'

Usage:
  mcc <provider> [key_suffix] [-r|--resume] [-m|--model <model>] [-e|--effort max|normal|min]
  mcc -l|--list

Examples:
  mcc tr                              # 默认 key
  mcc yr 5433                         # ANYROUTER_API_KEY_5433
  mcc ds -m deepseek-v4-pro[1m]      # 覆盖模型（big + small 均设为该值）
  mcc ds -e normal                    # 指定 effort level
  mcc kimi 1234 --resume              # 带 key 后缀 + 恢复会话

Override base URL:
  export DEEPSEEK_BASE_URL='https://custom.host'

Model env vars applied (when model is configured):
  ANTHROPIC_MODEL
  ANTHROPIC_DEFAULT_OPUS_MODEL   ← big_model
  ANTHROPIC_DEFAULT_SONNET_MODEL ← big_model
  ANTHROPIC_DEFAULT_HAIKU_MODEL  ← small_model
  CLAUDE_CODE_SUBAGENT_MODEL     ← small_model
  CLAUDE_CODE_EFFORT_LEVEL       ← max (default) | normal | min
EOF
}

# ============================================================
# Bash 补全（动态读取 _MCC_PROVIDERS，无需手动同步）
# ============================================================
_mcc_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    # --model 后由用户自行输入
    [[ "$prev" == "-m" || "$prev" == "--model" ]] && return 0

    # --effort 补全固定值
    if [[ "$prev" == "-e" || "$prev" == "--effort" ]]; then
        COMPREPLY=( $(compgen -W "${_MCC_EFFORT_LEVELS[*]}" -- "$cur") )
        return 0
    fi

    local providers opts
    providers=$(printf '%s ' "${!_MCC_PROVIDERS[@]}" "${!_MCC_ALIASES[@]}")
    opts="-l --list -r --resume -m --model -e --effort"

    case ${COMP_CWORD} in
        1)
            COMPREPLY=( $(compgen -W "$providers $opts" -- "$cur") )
            ;;
        2)
            local p="${COMP_WORDS[1]}"
            p="${_MCC_ALIASES[$p]:-$p}"
            if [[ -v _MCC_PROVIDERS[$p] ]]; then
                _mcc_parse_config "$p"
                local suffixes="" var
                while IFS= read -r var; do
                    [[ "$var" =~ ^${_MCC_KEY_ENV}_(.+)$ ]] && suffixes+="${BASH_REMATCH[1]} "
                done < <(compgen -v "${_MCC_KEY_ENV}_")
                COMPREPLY=( $(compgen -W "$suffixes $opts" -- "$cur") )
            fi
            ;;
        *)
            COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
            ;;
    esac
}

complete -F _mcc_completion mcc

# ============================================================
# 主函数
# ============================================================
function mcc() {
    if [[ $# -eq 0 ]]; then
        _mcc_err "provider required"; echo
        _mcc_list; return 1
    fi

    if [[ "$1" == "-l" || "$1" == "--list" ]]; then
        _mcc_list; return 0
    fi

    local provider="$1"; shift
    # 规范化别名
    provider="${_MCC_ALIASES[$provider]:-$provider}"

    if [[ ! -v _MCC_PROVIDERS[$provider] ]]; then
        _mcc_err "unknown provider '$provider'"
        echo "       Run 'mcc --list' to see available providers." >&2
        return 1
    fi

    _mcc_parse_config "$provider"

    # 解析剩余参数（顺序任意）
    local key_suffix="" custom_model="" effort="" resume=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -r|--resume) resume=true; shift ;;
            -m|--model)
                [[ $# -lt 2 ]] && { _mcc_err "--model requires a value"; return 1; }
                custom_model="$2"; shift 2
                ;;
            -e|--effort)
                [[ $# -lt 2 ]] && { _mcc_err "--effort requires a value (${_MCC_EFFORT_LEVELS[*]})"; return 1; }
                _mcc_in "$2" "${_MCC_EFFORT_LEVELS[@]}" || {
                    _mcc_err "--effort must be one of: ${_MCC_EFFORT_LEVELS[*]}"; return 1
                }
                effort="$2"; shift 2
                ;;
            -*)
                _mcc_err "unknown option '$1'"; return 1
                ;;
            *)
                [[ -n "$key_suffix" ]] && { _mcc_err "unexpected argument '$1'"; return 1; }
                key_suffix="$1"; shift
                ;;
        esac
    done

    # 确定 API key
    local key_var="${_MCC_KEY_ENV}${key_suffix:+_$key_suffix}"
    if [[ -z "${!key_var}" ]]; then
        _mcc_err "'$key_var' is not set"
        echo "       export $key_var=your_api_key" >&2
        return 1
    fi

    # 确定 base URL（环境变量优先）
    local base_url="${!_MCC_URL_ENV:-$_MCC_DEFAULT_URL}"

    # 确定模型（--model 同时覆盖 big 和 small）
    local big_model small_model
    if [[ -n "$custom_model" ]]; then
        big_model="$custom_model"
        small_model="$custom_model"
    else
        big_model="$_MCC_BIG_MODEL"
        small_model="$_MCC_SMALL_MODEL"
    fi

    # 打印启动摘要（key 掩码）
    printf "Provider  : %s\n"   "$provider"
    printf "Base URL  : %s%s\n" "$base_url" "${!_MCC_URL_ENV:+  (from \$$_MCC_URL_ENV)}"
    printf "API Key   : %s  (%s)\n" "$(_mcc_mask "${!key_var}")" "$key_var"
    if [[ -n "$big_model" ]]; then
        printf "Big Model : %s\n" "$big_model"
        printf "Sm Model  : %s\n" "$small_model"
        printf "Effort    : %s\n" "${effort:-${_MCC_EFFORT_LEVELS[0]}}"
    fi
    $resume && printf "Mode      : resume\n"
    echo

    # 清理上次会话留下的相关环境变量（变量列表见 _MCC_MANAGED_VARS）
    unset "${_MCC_MANAGED_VARS[@]}"

    export ANTHROPIC_BASE_URL="$base_url"
    export ANTHROPIC_AUTH_TOKEN="${!key_var}"

    if [[ -n "$big_model" ]]; then
        export ANTHROPIC_MODEL="$big_model"
        export ANTHROPIC_DEFAULT_OPUS_MODEL="$big_model"
        export ANTHROPIC_DEFAULT_SONNET_MODEL="$big_model"
        export ANTHROPIC_DEFAULT_HAIKU_MODEL="$small_model"
        export CLAUDE_CODE_SUBAGENT_MODEL="$small_model"
        export CLAUDE_CODE_EFFORT_LEVEL="${effort:-${_MCC_EFFORT_LEVELS[0]}}"
        export API_TIMEOUT_MS=600000
        export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
    fi

    # 启动（数组传参，避免 eval）
    local -a cmd=(claude --dangerously-skip-permissions)
    $resume && cmd+=(--resume)
    "${cmd[@]}"
}