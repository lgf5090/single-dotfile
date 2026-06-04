#!/usr/bin/env bash
# ============================================================
#  ollama-update.sh — Ollama Linux 手动更新脚本
#  用法: sudo bash ollama-update.sh [--force]
#        --force  即使已是最新版也强制重装
# ============================================================
set -euo pipefail

# ── 颜色 ────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BLUE='\033[0;34m'; NC='\033[0m'

# ── 日志 ────────────────────────────────────────────────────
info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()   { echo -e "${RED}[ERR ]${NC}  $*" >&2; exit 1; }

# ── 常量 ────────────────────────────────────────────────────
INSTALL_BIN="/usr/bin/ollama"       # 官方安装路径（解压至 /usr）
LIB_DIR="/usr/lib/ollama"           # GPU 共享库路径
GITHUB_API="https://api.github.com/repos/ollama/ollama/releases/latest"
TMP_DIR=$(mktemp -d)

trap 'rm -rf "$TMP_DIR"' EXIT

# ── 前置检查 ─────────────────────────────────────────────────
check_root() {
    [[ $EUID -eq 0 ]] || die "请以 root 身份运行: sudo $0"
}

check_deps() {
    local missing=()
    for cmd in curl tar zstd grep sed sort; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        warn "缺少依赖: ${missing[*]}"
        info "尝试自动安装缺失依赖..."
        apt-get install -y "${missing[@]}" 2>/dev/null \
            || die "自动安装失败，请手动安装: ${missing[*]}"
    fi
}

# ── 系统信息 ─────────────────────────────────────────────────
detect_arch() {
    case "$(uname -m)" in
        x86_64)  echo "amd64" ;;
        aarch64) echo "arm64" ;;
        armv7l)  echo "arm"   ;;
        *)       die "不支持的架构: $(uname -m)" ;;
    esac
}

current_version() {
    if command -v ollama &>/dev/null; then
        ollama --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 || true
    fi
}

latest_version() {
    local ver
    ver=$(curl -fsSL --retry 3 --connect-timeout 10 \
          -H "Accept: application/vnd.github+json" \
          "$GITHUB_API" \
          | grep '"tag_name"' \
          | sed -E 's/.*"v?([0-9]+\.[0-9]+\.[0-9]+)".*/\1/' \
          | head -1)
    [[ -n "$ver" ]] || die "无法获取最新版本，请检查网络连接"
    echo "$ver"
}

# ── 版本比较: ver_lt A B → A < B 时返回 true ─────────────────
ver_lt() {
    [[ "$1" != "$2" ]] && \
        [[ "$(printf '%s\n%s' "$1" "$2" | sort -V | head -1)" == "$1" ]]
}

# ── 服务管理 ─────────────────────────────────────────────────
service_ctl() {
    local action="$1"
    if systemctl list-unit-files ollama.service &>/dev/null 2>&1; then
        info "systemctl $action ollama ..."
        systemctl "$action" ollama && ok "服务 $action 成功" \
            || warn "服务 $action 失败，请手动处理"
    else
        warn "未找到 ollama.service，跳过 $action"
    fi
}

# ── 下载 ─────────────────────────────────────────────────────
download_tarball() {
    local ver="$1" arch="$2"
    # 官方发布格式为 .tar.zst，需要 zstd 支持
    local filename="ollama-linux-${arch}.tar.zst"
    local url="https://github.com/ollama/ollama/releases/download/v${ver}/${filename}"
    local dest="${TMP_DIR}/${filename}"

    info "下载: $url"
    curl -fL --retry 3 --connect-timeout 15 \
         --progress-bar -o "$dest" "$url" \
        || die "下载失败，请检查网络或 GitHub 访问权限"

    echo "$dest"
}

# ── 安装 ─────────────────────────────────────────────────────
install_files() {
    local archive="$1"

    # 备份旧版二进制
    if [[ -f "$INSTALL_BIN" ]]; then
        cp -f "$INSTALL_BIN" "${INSTALL_BIN}.bak"
        info "旧版本已备份至 ${INSTALL_BIN}.bak"
    fi

    # 与官方脚本保持一致：解压至 /usr
    # tarball 内含 bin/ollama 和 lib/ollama/，自然落位到正确路径
    info "解压至 /usr ..."
    tar --zstd -xf "$archive" -C /usr \
        || die "解压失败，文件可能损坏"

    ok "文件安装完成"
    info "  二进制: $INSTALL_BIN"
    [[ -d "$LIB_DIR" ]] && info "  GPU 库:  $LIB_DIR"
}

# ── 主流程 ────────────────────────────────────────────────────
main() {
    local force=false
    [[ "${1:-}" == "--force" ]] && force=true

    echo -e "${BLUE}"
    cat <<'BANNER'
  ╔══════════════════════════════════════════╗
  ║     Ollama Linux 手动更新脚本 v1.1       ║
  ╚══════════════════════════════════════════╝
BANNER
    echo -e "${NC}"

    check_root
    check_deps

    local arch cur latest
    arch=$(detect_arch)
    cur=$(current_version)
    latest=$(latest_version)

    info "系统架构:  $arch"
    info "当前版本:  ${cur:-未安装}"
    info "最新版本:  $latest"
    echo

    # 已是最新且未指定 --force
    if [[ -n "$cur" ]] && ! ver_lt "$cur" "$latest" && [[ "$force" == false ]]; then
        ok "已是最新版本 v${latest}，无需更新"
        ok "若需强制重装，请加参数: sudo $0 --force"
        exit 0
    fi

    [[ -n "$cur" ]] \
        && info "升级路径: v${cur} → v${latest}" \
        || info "首次安装: v${latest}"

    # 停止服务 → 下载 → 安装 → 启动服务
    service_ctl stop

    local archive
    archive=$(download_tarball "$latest" "$arch")
    install_files "$archive"

    service_ctl start

    # 版本核验
    echo
    local final
    final=$(current_version)
    if [[ "$final" == "$latest" ]]; then
        ok "✓ 更新完成！当前版本: v${final}"
    else
        warn "安装完毕，但版本核验异常（期望 v${latest}，实际 v${final:-?}）"
        warn "请手动运行: ollama --version"
    fi
}

main "$@"
