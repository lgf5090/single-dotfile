<#
.SYNOPSIS
    Claude Code 多供应商切换工具 (PowerShell)

.DESCRIPTION
    用法:
      mcc <provider> [key_suffix] [-Resume] [-Model <model>] [-Effort <level>] [-List | -Help]
    
    新增供应商只需在 $_MCC_PROVIDERS 中添加一行即可，补全自动生效。
#>

# ============================================================
# 供应商配置（唯一数据源）
# 每个哈希表：Name, DefaultUrl, ApiKeyEnv, BaseUrlEnv, BigModel, SmallModel
# 留空字符串表示不设置模型变量（适用于透传代理）
# ============================================================
$_MCC_PROVIDERS = @(
    @{ Name = 'agentrouter'; DefaultUrl = 'https://agentrouter.org';              ApiKeyEnv = 'AGENTROUTER_API_KEY'; BaseUrlEnv = 'AGENTROUTER_BASE_URL'; BigModel = '';              SmallModel = '' },
    @{ Name = 'anyrouter';   DefaultUrl = 'https://anyrouter.top';                ApiKeyEnv = 'ANYROUTER_API_KEY';   BaseUrlEnv = 'ANYROUTER_BASE_URL';   BigModel = '';              SmallModel = '' },
    @{ Name = 'deepseek';    DefaultUrl = 'https://api.deepseek.com/anthropic';   ApiKeyEnv = 'DEEPSEEK_API_KEY';    BaseUrlEnv = 'DEEPSEEK_BASE_URL';    BigModel = 'deepseek-v4-pro[1m]'; SmallModel = 'deepseek-v4-flash' },
    @{ Name = 'moonshot';    DefaultUrl = 'https://api.moonshot.cn/anthropic';    ApiKeyEnv = 'MOONSHOT_API_KEY';    BaseUrlEnv = 'MOONSHOT_BASE_URL';    BigModel = 'kimi-k2.6';       SmallModel = 'kimi-k2.6' },
    @{ Name = 'glm';         DefaultUrl = 'https://open.bigmodel.cn/api/anthropic'; ApiKeyEnv = 'GLM_API_KEY';        BaseUrlEnv = 'GLM_BASE_URL';        BigModel = 'GLM-5.1';          SmallModel = 'GLM-5.1' },
    @{ Name = 'siliconflow'; DefaultUrl = 'https://api.siliconflow.cn/';          ApiKeyEnv = 'SILICONFLOW_API_KEY'; BaseUrlEnv = 'SILICONFLOW_BASE_URL'; BigModel = 'deepseek-ai/DeepSeek-V4-Pro'; SmallModel = 'deepseek-ai/DeepSeek-V4-Flash' }
)

# 别名 → 规范名
$_MCC_ALIASES = @(
    @{ Alias = 'tr';   Canonical = 'agentrouter' },
    @{ Alias = 'yr';   Canonical = 'anyrouter' },
    @{ Alias = 'ds';   Canonical = 'deepseek' },
    @{ Alias = 'km';   Canonical = 'moonshot' },
    @{ Alias = 'kimi'; Canonical = 'moonshot' },
    @{ Alias = 'sf';   Canonical = 'siliconflow' }
)

# --effort 合法取值（首项为默认值）
$_MCC_EFFORT_LEVELS = @('max', 'normal', 'min')

# 由 mcc 托管的环境变量（每次调用前清理）
$_MCC_MANAGED_VARS = @(
    'ANTHROPIC_MODEL',
    'ANTHROPIC_DEFAULT_OPUS_MODEL',
    'ANTHROPIC_DEFAULT_SONNET_MODEL',
    'ANTHROPIC_DEFAULT_HAIKU_MODEL',
    'ANTHROPIC_SMALL_FAST_MODEL',
    'CLAUDE_CODE_SUBAGENT_MODEL',
    'CLAUDE_CODE_EFFORT_LEVEL',
    'API_TIMEOUT_MS',
    'CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC'
)

# ============================================================
# 内部工具函数
# ============================================================
function _mcc_err {
    Write-Host "Error: $args" -ForegroundColor Red
}

function _mcc_mask {
    param([string]$key)
    if ($key.Length -le 8) { return "$key****" }
    return $key.Substring(0, 8) + "****"
}

function _mcc_origin {
    param([string]$varName)
    $val = [Environment]::GetEnvironmentVariable($varName)
    if ($val) { return "  (from `$$varName)" } else { return "" }
}

function _mcc_resolve_alias {
    param([string]$name)
    foreach ($a in $_MCC_ALIASES) {
        if ($a.Alias -eq $name) { return $a.Canonical }
    }
    return $name
}

function _mcc_provider_exists {
    param([string]$name)
    foreach ($p in $_MCC_PROVIDERS) {
        if ($p.Name -eq $name) { return $true }
    }
    return $false
}

# 解析 provider 配置到脚本级变量
function _mcc_parse_config {
    param([string]$name)
    $script:_mcc_config = $null
    foreach ($p in $_MCC_PROVIDERS) {
        if ($p.Name -eq $name) {
            $script:_mcc_config = @{
                DefaultUrl    = $p.DefaultUrl
                ApiKeyEnv     = $p.ApiKeyEnv
                BaseUrlEnv    = $p.BaseUrlEnv
                BigModel      = $p.BigModel
                SmallModel    = $p.SmallModel
            }
            $prefix = $p.ApiKeyEnv -replace '_API_KEY$', ''
            $script:_mcc_config['BigModelEnv']   = "${prefix}_BIG_MODEL"
            $script:_mcc_config['SmallModelEnv'] = "${prefix}_SMALL_MODEL"
            return
        }
    }
}

function _mcc_list {
    Write-Host "Providers:`n----------"
    foreach ($p in ($_MCC_PROVIDERS | Sort-Object Name)) {
        $aliases = ($_MCC_ALIASES | Where-Object { $_.Canonical -eq $p.Name }).Alias
        $display = $p.Name
        if ($aliases) { $display += " ($($aliases -join ', '))" }

        _mcc_parse_config $p.Name
        $cfg = $script:_mcc_config

        # 修复动态环境变量读取
        $url = [Environment]::GetEnvironmentVariable($cfg.BaseUrlEnv)
        if (-not $url) { $url = $cfg.DefaultUrl }
        $fromEnv = _mcc_origin $cfg.BaseUrlEnv

        $big = [Environment]::GetEnvironmentVariable($cfg.BigModelEnv)
        if (-not $big) { $big = $cfg.BigModel }
        $small = [Environment]::GetEnvironmentVariable($cfg.SmallModelEnv)
        if (-not $small) { $small = $cfg.SmallModel }

        $modelInfo = ""
        if ($big -or $small) {
            if (-not $big) { $big = $small }
            if (-not $small) { $small = $big }
            $modelInfo = "  big=$big$(_mcc_origin $cfg.BigModelEnv)"
            # 仅当 small 与 big 不同或显式设置了 small 环境变量时才显示 small
            if ($small -ne $big -or [Environment]::GetEnvironmentVariable($cfg.SmallModelEnv)) {
                $modelInfo += " / small=$small$(_mcc_origin $cfg.SmallModelEnv)"
            }
        }
        Write-Host ("  {0,-20} {1}{2}{3}" -f $display, $url, $fromEnv, $modelInfo)
    }

    $helpText = @"

Usage:
  mcc <provider> [key_suffix] [-Resume] [-Model <model>] [-Effort <level>]
  mcc -List
  mcc -Help

Examples:
  mcc tr                              # 默认 key
  mcc yr 5433                         # ANYROUTER_API_KEY_5433
  mcc ds -Model deepseek-v4-pro[1m]  # 覆盖模型
  mcc ds -Effort normal               # 指定 effort level
  mcc kimi 1234 -Resume               # 带 key 后缀 + 恢复会话

Override base URL / model (env var prefix matches the provider's *_API_KEY):
  `$env:DEEPSEEK_BASE_URL = 'https://custom.host'
  `$env:DEEPSEEK_BIG_MODEL = 'custom-pro'
  `$env:DEEPSEEK_SMALL_MODEL = 'custom-flash'

Model env vars applied (when model is configured):
  ANTHROPIC_MODEL
  ANTHROPIC_DEFAULT_OPUS_MODEL   ← big_model
  ANTHROPIC_DEFAULT_SONNET_MODEL ← big_model
  ANTHROPIC_DEFAULT_HAIKU_MODEL  ← small_model
  CLAUDE_CODE_SUBAGENT_MODEL     ← small_model
  CLAUDE_CODE_EFFORT_LEVEL       ← max (default) | normal | min

Run 'mcc -Help' for full help with all scenarios and caveats.
"@
    Write-Host $helpText
}

function _mcc_help {
    $help = @'
mcc - Claude Code 多供应商切换工具 (PowerShell)

SYNOPSIS
  mcc <provider> [key_suffix] [-Resume] [-Model <model>] [-Effort <level>]
  mcc -List                  显示供应商表
  mcc -Help                  显示本帮助

ARGUMENTS
  <provider>        供应商规范名或别名（运行 mcc -List 查看完整列表）
  [key_suffix]      可选，API key 后缀；将选用 <PREFIX>_API_KEY_<suffix>

OPTIONS
  -Resume           恢复上次会话（向 claude 传 --resume）
  -Model <model>    临时覆盖 big & small model（同时生效，仅本次）
  -Effort <level>   设置努力等级（max / normal / min，默认 max）
  -List             显示供应商表
  -Help             显示本帮助

ENVIRONMENT VARIABLES
  约定：<PREFIX> 为 *_API_KEY 中 _API_KEY 之前的部分（如 DEEPSEEK_API_KEY → DEEPSEEK）。

  $env:<PREFIX>_API_KEY                  必填，主 API key
  $env:<PREFIX>_API_KEY_<suffix>         可选，备用 key（通过 [key_suffix] 选择）
  $env:<PREFIX>_BASE_URL                 可选，覆盖配置的默认 URL
  $env:<PREFIX>_BIG_MODEL                可选，覆盖配置的默认 big model
  $env:<PREFIX>_SMALL_MODEL              可选，覆盖配置的默认 small model

PRIORITY
  模型:    -Model  >  $env:<PREFIX>_BIG/SMALL_MODEL  >  供应商配置默认值
  URL:     $env:<PREFIX>_BASE_URL                    >  供应商配置默认值
  API key: 由 [key_suffix] 选定具体的 KEY 变量

SCENARIOS (参数顺序任意，可自由组合)
  # 1) 基础调用
  mcc deepseek
  mcc ds

  # 2) 多账号切换：备用 key
  mcc yr 5433                       # 用 $env:ANYROUTER_API_KEY_5433
  mcc deepseek work                 # 用 $env:DEEPSEEK_API_KEY_work

  # 3) 恢复上次会话
  mcc ds -Resume

  # 4) 临时换模型
  mcc ds -Model deepseek-v4-pro[1m]

  # 5) 调整努力等级
  mcc ds -Effort normal

  # 6) 持久化覆盖模型（影响所有 mcc ds 调用）
  $env:DEEPSEEK_BIG_MODEL = 'my-pro'
  $env:DEEPSEEK_SMALL_MODEL = 'my-flash'
  mcc ds

  # 7) 透传代理启用模型（agentrouter / anyrouter 默认无模型配置）
  $env:AGENTROUTER_BIG_MODEL = 'foo'
  mcc tr

  # 8) 自定义 URL
  $env:DEEPSEEK_BASE_URL = 'https://my-proxy.example.com'
  mcc ds

  # 9) 组合：suffix + resume + 临时模型 + 努力等级
  mcc ds 5433 -Resume -Model custom-model -Effort min

  # 10) 仅命令行覆盖一边：通过环境变量分别控制
  $env:DEEPSEEK_BIG_MODEL = 'big-only'
  mcc ds

NOTES
  · -Model 同时覆盖 big & small；若需分别控制请改用 *_BIG_MODEL / *_SMALL_MODEL
  · 优先级 CLI > 环境变量 > 配置默认；摘要中的 (from $VAR) 表示来自环境覆盖
  · 透传代理需额外指定 -Model 或 *_BIG_MODEL 才会导出模型变量
  · big / small 任一为空时会复用另一个，避免导出空字符串
  · CLAUDE_CODE_EFFORT_LEVEL 仅在最终有模型时才导出
  · 每次 mcc 调用会先清理由 _MCC_MANAGED_VARS 定义的环境变量
  · claude 启动时固定附加 --dangerously-skip-permissions
  · API key 在摘要中只显示前 8 位，其余以 **** 掩码
  · 未识别的 provider 会报错；运行 mcc -List 查看可用列表

SEE ALSO
  mcc -List                        供应商表（含别名 / 默认 URL / 默认模型）
'@
    Write-Host $help
}

# ============================================================
# 主函数
# ============================================================
function mcc {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Provider,

        [Parameter(Position = 1)]
        [string]$KeySuffix,

        [switch]$Resume,
        [string]$Model,
        [ValidateSet('max', 'normal', 'min')]
        [string]$Effort,
        [switch]$List,
        [switch]$Help
    )

    if ($List) { _mcc_list; return }
    if ($Help) { _mcc_help; return }

    if (-not $Provider) {
        _mcc_err "provider required"
        _mcc_list
        return
    }

    if ($Args.Count -gt 0) {
        _mcc_err "unexpected arguments: $($Args -join ' ')"
        return
    }

    $canon = _mcc_resolve_alias $Provider
    if (-not (_mcc_provider_exists $canon)) {
        _mcc_err "unknown provider '$Provider'"
        Write-Host "       Run 'mcc -List' to see available providers." -ForegroundColor Yellow
        return
    }
    _mcc_parse_config $canon
    $cfg = $script:_mcc_config

    # 确定 API key
    $keyVar = $cfg.ApiKeyEnv
    if ($KeySuffix) { $keyVar += "_$KeySuffix" }
    $apiKey = [Environment]::GetEnvironmentVariable($keyVar)
    if (-not $apiKey) {
        _mcc_err "'$keyVar' is not set"
        Write-Host "       `$env:$keyVar = 'your_api_key'" -ForegroundColor Yellow
        return
    }

    # 确定 base URL
    $baseUrl = [Environment]::GetEnvironmentVariable($cfg.BaseUrlEnv)
    if (-not $baseUrl) { $baseUrl = $cfg.DefaultUrl }

    # 确定模型
    if ($Model) {
        $bigModel = $Model
        $smallModel = $Model
    } else {
        $bigModel = [Environment]::GetEnvironmentVariable($cfg.BigModelEnv)
        $smallModel = [Environment]::GetEnvironmentVariable($cfg.SmallModelEnv)
        if (-not $bigModel) { $bigModel = $cfg.BigModel }
        if (-not $smallModel) { $smallModel = $cfg.SmallModel }
        if (-not $bigModel) { $bigModel = $smallModel }
        if (-not $smallModel) { $smallModel = $bigModel }
    }

    # 启动摘要
    Write-Host "Provider  : $canon"
    Write-Host ("Base URL  : $baseUrl$(_mcc_origin $cfg.BaseUrlEnv)")
    Write-Host ("API Key   : $(_mcc_mask $apiKey)  (`$env:$keyVar)")
    if ($bigModel) {
        $bigTag = if ($Model) { "" } else { _mcc_origin $cfg.BigModelEnv }
        $smallTag = if ($Model) { "" } else { _mcc_origin $cfg.SmallModelEnv }
        Write-Host ("Big Model : $bigModel$bigTag")
        Write-Host ("Sm Model  : $smallModel$smallTag")
        $effortLevel = if ($Effort) { $Effort } else { $_MCC_EFFORT_LEVELS[0] }
        Write-Host ("Effort    : $effortLevel")
    }
    if ($Resume) { Write-Host "Mode      : resume" }
    Write-Host ""

    # 清理上次托管的环境变量
    foreach ($varName in $_MCC_MANAGED_VARS) {
        Remove-Item "env:$varName" -ErrorAction SilentlyContinue
    }

    # 设置新环境变量（仅当前进程）
    $env:ANTHROPIC_BASE_URL   = $baseUrl
    $env:ANTHROPIC_AUTH_TOKEN = $apiKey

    if ($bigModel) {
        $env:ANTHROPIC_MODEL                = $bigModel
        $env:ANTHROPIC_DEFAULT_OPUS_MODEL   = $bigModel
        $env:ANTHROPIC_DEFAULT_SONNET_MODEL = $bigModel
        $env:ANTHROPIC_DEFAULT_HAIKU_MODEL  = $smallModel
        $env:CLAUDE_CODE_SUBAGENT_MODEL     = $smallModel
        if ($Effort) {
            $env:CLAUDE_CODE_EFFORT_LEVEL = $Effort
        } else {
            $env:CLAUDE_CODE_EFFORT_LEVEL = $_MCC_EFFORT_LEVELS[0]
        }
        $env:API_TIMEOUT_MS = 600000
        $env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1
    }

    # 启动 claude
    $claudeArgs = @('--dangerously-skip-permissions')
    if ($Resume) { $claudeArgs += '--resume' }
    & claude $claudeArgs
}

# ============================================================
# 补全器（动态补全 provider 和 key_suffix）
# ============================================================
$mccCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    if ($parameterName -eq 'Provider') {
        $names = $_MCC_PROVIDERS | ForEach-Object { $_.Name }
        $aliases = $_MCC_ALIASES | ForEach-Object { $_.Alias }
        $candidates = $names + $aliases | Where-Object { $_ -like "$wordToComplete*" }
        return $candidates | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
    }
    
    if ($parameterName -eq 'KeySuffix') {
        # 提取已输入的 provider（第一个非选项参数）
        $providerArg = $commandAst.CommandElements | Where-Object { $_.ParameterName -eq 'Provider' } |
                       Select-Object -First 1 | ForEach-Object { $_.Extent.Text }
        if (-not $providerArg) { return }
        $canon = _mcc_resolve_alias $providerArg
        if (-not (_mcc_provider_exists $canon)) { return }
        _mcc_parse_config $canon
        $prefix = $script:_mcc_config.ApiKeyEnv + "_"
        $suffixes = Get-ChildItem env: | Where-Object { $_.Name -like "$prefix*" } |
                    ForEach-Object { $_.Name.Substring($prefix.Length) } |
                    Where-Object { $_ -like "$wordToComplete*" }
        return $suffixes | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
    }
}

# 注册补全
Register-ArgumentCompleter -CommandName mcc -ParameterName Provider -ScriptBlock $mccCompleter
Register-ArgumentCompleter -CommandName mcc -ParameterName KeySuffix -ScriptBlock $mccCompleter