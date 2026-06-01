-- =============================================================================
--  Neovim 0.11+ Pure-Builtins Configuration
--  No third-party plugins. Place at ~/.config/nvim/init.lua
--
--  注：Neovim 0.10+ 已内置 gcc / gc 注释切换，无需手动实现。
-- =============================================================================

-- ─── 1. Options ───────────────────────────────────────────────────────────────
local opt          = vim.opt

-- 行号
opt.number         = true
opt.relativenumber = true

-- 缩进
opt.tabstop        = 4
opt.shiftwidth     = 4
opt.softtabstop    = 4
opt.expandtab      = true
opt.smartindent    = true

-- 搜索
opt.hlsearch       = true
opt.incsearch      = true
opt.ignorecase     = true
opt.smartcase      = true

-- 外观
opt.termguicolors  = true
opt.cursorline     = true
opt.signcolumn     = "yes"
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.wrap           = false
opt.colorcolumn    = "80"
opt.showmode       = false
opt.showmatch      = true -- 括号高亮配对（新增）
opt.matchtime      = 2
opt.smoothscroll   = true -- 平滑滚动，Neovim 0.10+（新增）
opt.fillchars      = {
    eob  = " ", -- 隐藏缓冲区末尾的 ~ 号（新增）
    vert = "│", -- 更清晰的分屏分隔符（新增）
}

-- 文件 / Buffer
opt.fileencoding   = "utf-8"
opt.swapfile       = false
opt.backup         = false
opt.undofile       = true
opt.undodir        = vim.fs.joinpath(vim.fn.stdpath("data"), "undo")

-- 分屏
opt.splitright     = true
opt.splitbelow     = true

-- 补全
opt.completeopt    = { "menu", "menuone", "noselect", "popup" }
opt.pumheight      = 10
opt.shortmess:append("c") -- 抑制补全菜单中的多余提示（新增）

-- 杂项
opt.mouse = "a"
vim.schedule(function() vim.opt.clipboard = "unnamedplus" end)
opt.updatetime = 250
opt.timeoutlen = 300
opt.list       = true
opt.listchars  = {
    tab            = "» ",
    trail          = "·",
    nbsp           = "␣",
    leadmultispace = "│   ",
}
-- :s 替换实时预览，split 模式在下方弹窗（Neovim 专属，新增）
opt.inccommand = "split"

-- :find — 递归模糊查找
opt.path:append("**")
opt.wildmenu = true
opt.wildmode = { "longest:full", "full" }
opt.wildignore:append({
    "*/node_modules/*", "*/.git/*", "*/target/*", "*/dist/*", "*/build/*",
})

-- :grep — 优先用 ripgrep
if vim.fn.executable("rg") == 1 then
    opt.grepprg    = "rg --vimgrep --no-heading --smart-case"
    opt.grepformat = "%f:%l:%c:%m"
end

-- ─── 2. 配色方案 ──────────────────────────────────────────────────────────────
-- Neovim 内置: habamax / retrobox / sorbet / vague / lunaperche / quiet
pcall(vim.cmd.colorscheme, "habamax")

-- ─── 3. Statusline & Tabline ──────────────────────────────────────────────────
opt.laststatus  = 3 -- 全局单条 statusline（Neovim 0.8+）
opt.showtabline = 2 -- 始终显示 tabline

-- 3-a 自定义高亮组
--   使用 nvim_set_hl 而非 'hi' 命令，不会被 colorscheme 的 link 意外覆盖。
--   colorscheme 已在第 2 节加载，此处调用时高亮基础色已就绪；
--   ColorScheme 事件负责处理后续 :colorscheme 切换。
local function setup_hl()
    local hl = function(name, attrs) vim.api.nvim_set_hl(0, name, attrs) end
    -- 模式指示器：N=蓝 / I=绿 / V=橙 / R=红 / C=紫
    hl("SLModeN", { bg = "#5f87af", fg = "#1c1c1c", bold = true })
    hl("SLModeI", { bg = "#87af5f", fg = "#1c1c1c", bold = true })
    hl("SLModeV", { bg = "#d7875f", fg = "#1c1c1c", bold = true })
    hl("SLModeR", { bg = "#d75f5f", fg = "#ffffff", bold = true })
    hl("SLModeC", { bg = "#875fd7", fg = "#ffffff", bold = true })
    -- 状态栏区段
    hl("SLGit", { bg = "#2d2d2d", fg = "#87af87" })
    hl("SLFile", { bg = "#1e1e1e", fg = "#d0d0d0" })
    hl("SLMod", { bg = "#1e1e1e", fg = "#d7875f", bold = true })
    hl("SLDiagE", { bg = "#1e1e1e", fg = "#d75f5f", bold = true }) -- LSP 错误
    hl("SLDiagW", { bg = "#1e1e1e", fg = "#d7af5f", bold = true }) -- LSP 警告
    hl("SLInfo", { bg = "#141414", fg = "#767676" })
    hl("SLPos", { bg = "#2d2d2d", fg = "#eeeeee" })
    hl("SLPct", { bg = "#141414", fg = "#767676" })
    -- 标签栏
    hl("TLSel", { bg = "#5f87af", fg = "#1c1c1c", bold = true })
    hl("TLSelMod", { bg = "#5f87af", fg = "#d75f00", bold = true })
    hl("TLNorm", { bg = "#2d2d2d", fg = "#8a8a8a" })
    hl("TLNormMod", { bg = "#2d2d2d", fg = "#d7875f", bold = true })
    hl("TLFill", { bg = "#141414", fg = "#3a3a3a" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
    group    = vim.api.nvim_create_augroup("StatusHL", { clear = true }),
    callback = setup_hl,
})
setup_hl()

-- 3-b 模式映射表
local CTRL_V = vim.api.nvim_replace_termcodes("<C-v>", true, true, true)
local CTRL_S = vim.api.nvim_replace_termcodes("<C-s>", true, true, true)
local mode_map = {
    n        = { "NORMAL", "SLModeN" },
    no       = { "N·PEND", "SLModeN" },
    niI      = { "N·INS", "SLModeN" },
    i        = { "INSERT", "SLModeI" },
    ic       = { "I·COMP", "SLModeI" },
    v        = { "VISUAL", "SLModeV" },
    V        = { "V·LINE", "SLModeV" },
    [CTRL_V] = { "V·BLOCK", "SLModeV" },
    s        = { "SELECT", "SLModeV" },
    S        = { "S·LINE", "SLModeV" },
    [CTRL_S] = { "S·BLOCK", "SLModeV" },
    R        = { "REPLACE", "SLModeR" },
    Rv       = { "V·REPL", "SLModeR" },
    c        = { "COMMAND", "SLModeC" },
    cv       = { "EX", "SLModeC" },
    r        = { "PROMPT", "SLModeC" },
    ["!"]    = { "SHELL", "SLModeC" },
    t        = { "TERMINAL", "SLModeC" },
}

-- 3-c 异步 Git 分支
--   vim.system 完全不阻塞 UI，回调通过 schedule_wrap 安全回到主线程。
--   原 Vim 版只能用同步 system()；这是 Neovim 专属优势。
local _git_branch = ""
local function update_git_branch()
    if vim.bo.buftype ~= "" then return end
    local dir = vim.fn.expand("%:p:h")
    if dir == "" then return end
    vim.system(
        { "git", "-C", dir, "rev-parse", "--abbrev-ref", "HEAD" },
        { text = true },
        vim.schedule_wrap(function(result)
            if result.code == 0 then
                local b = vim.trim(result.stdout)
                _git_branch = (b ~= "" and b ~= "HEAD") and b or ""
            else
                _git_branch = ""
            end
            vim.cmd("redrawstatus!")
        end)
    )
end

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "DirChanged" }, {
    group    = vim.api.nvim_create_augroup("GitBranch", { clear = true }),
    callback = update_git_branch,
})
update_git_branch()

-- 3-d 活动窗口追踪
--   statusline 求值期间 current_win = statusline_win，无法从内部区分活动窗口，
--   需要在 WinEnter 事件中提前记录。
local _sl_focused = vim.api.nvim_get_current_win()
vim.api.nvim_create_autocmd("WinEnter", {
    group    = vim.api.nvim_create_augroup("SLFocus", { clear = true }),
    callback = function() _sl_focused = vim.api.nvim_get_current_win() end,
})

local ff_map = { unix = "LF", dos = "CRLF", mac = "CR" }

-- 3-e Statusline 主函数（⎇ = U+2387；不支持则改为 @ 即可）
function _G.MyStatusline()
    local winid = vim.g.statusline_winid

    -- 非活动窗口：显示简化版，颜色由 StatusLineNC 接管
    if winid ~= _sl_focused then
        return "%#StatusLineNC# %f %m%r%=%{&filetype} "
    end

    local buf      = vim.api.nvim_win_get_buf(winid)
    local mode_str = vim.api.nvim_get_mode().mode
    local info     = mode_map[mode_str]
        or mode_map[mode_str:sub(1, 1)]
        or { "??????", "SLModeN" }

    -- 左侧：模式 → git → 文件名 → 标志
    local s        = "%#" .. info[2] .. "# " .. info[1] .. " "

    if _git_branch ~= "" then
        s = s .. "%#SLGit# ⎇ " .. _git_branch .. " "
    end

    s = s .. "%#SLFile# %f "

    if vim.bo[buf].modified then s = s .. "%#SLMod#[+]%#SLFile# " end
    if vim.bo[buf].readonly then s = s .. "%#SLMod#[RO]%#SLFile# " end

    -- LSP 诊断计数（Neovim 专属功能）
    local dc = vim.diagnostic.count(buf)
    local de = dc[vim.diagnostic.severity.ERROR] or 0
    local dw = dc[vim.diagnostic.severity.WARN] or 0
    if de > 0 then s = s .. "%#SLDiagE# ● E:" .. de .. " " end
    if dw > 0 then s = s .. "%#SLDiagW# ▲ W:" .. dw .. " " end

    -- 右侧：文件类型 · 编码 [换行] → 行:列 → 百分比
    s         = s .. "%="

    local ft  = vim.bo[buf].filetype
    ft        = (ft ~= "") and ft or "none"
    local enc = vim.bo[buf].fileencoding
    enc       = (enc ~= "") and enc or vim.o.encoding
    local ff  = ff_map[vim.bo[buf].fileformat] or vim.bo[buf].fileformat

    s         = s .. "%#SLInfo# " .. ft .. "  " .. enc .. " [" .. ff .. "] "
    s         = s .. "%#SLPos# %l:%c "
    s         = s .. "%#SLPct# %p%% "
    return s
end

opt.statusline = "%!v:lua.MyStatusline()"

-- 3-f Tabline（● = U+25CF 修改指示；不支持则改 * 即可）
function _G.MyTabline()
    local parts = {}
    local cur   = vim.api.nvim_get_current_buf()
    for _, bnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[bnr].buflisted then
            local name = vim.api.nvim_buf_get_name(bnr)
            name       = (name == "") and "[No Name]" or vim.fs.basename(name)
            local mod  = vim.bo[bnr].modified
            if bnr == cur then
                parts[#parts + 1] = "%#TLSel# " .. bnr .. " " .. name .. " "
                if mod then parts[#parts + 1] = "%#TLSelMod#●%#TLSel# " end
            else
                parts[#parts + 1] = "%#TLNorm# " .. bnr .. " " .. name .. " "
                if mod then parts[#parts + 1] = "%#TLNormMod#●%#TLNorm# " end
            end
        end
    end
    parts[#parts + 1] = "%#TLFill#"
    return table.concat(parts)
end

opt.tabline          = "%!v:lua.MyTabline()"

-- ─── 4. Keymaps ───────────────────────────────────────────────────────────────
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

local function map(mode, lhs, rhs, desc, extra)
    local o = { silent = true, desc = desc }
    if extra then for k, v in pairs(extra) do o[k] = v end end
    vim.keymap.set(mode, lhs, rhs, o)
end

-- 通用
map("n", "<leader>w", "<cmd>w<cr>", "Save file")
map("n", "<leader>q", "<cmd>q<cr>", "Quit")
map("n", "<leader>Q", "<cmd>qa!<cr>", "Force quit all")
map("n", "<Esc>", "<cmd>nohl<cr>", "Clear search highlight")

-- 窗口导航
map("n", "<C-h>", "<C-w>h", "Window left")
map("n", "<C-j>", "<C-w>j", "Window down")
map("n", "<C-k>", "<C-w>k", "Window up")
map("n", "<C-l>", "<C-w>l", "Window right")

-- 滚动 / 搜索时保持光标居中（新增）
map("n", "<C-d>", "<C-d>zz", "Scroll down (centered)")
map("n", "<C-u>", "<C-u>zz", "Scroll up (centered)")
map("n", "n", "nzzzv", "Next search (centered)")
map("n", "N", "Nzzzv", "Prev search (centered)")

-- Buffer 管理
map("n", "<S-l>", "<cmd>bnext<cr>", "Next buffer")
map("n", "<S-h>", "<cmd>bprevious<cr>", "Prev buffer")
map("n", "<leader>bd", "<cmd>bdelete<cr>", "Delete buffer")

-- 分屏
map("n", "<leader>sv", "<cmd>vsplit<cr>", "Vertical split")
map("n", "<leader>sh", "<cmd>split<cr>", "Horizontal split")

-- Visual 缩进保持选区
map("v", "<", "<gv", "Indent left")
map("v", ">", ">gv", "Indent right")

-- 选中行上下移动
map("v", "J", ":m '>+1<CR>gv=gv", "Move lines down")
map("v", "K", ":m '<-2<CR>gv=gv", "Move lines up")

-- 文件浏览（netrw）
map("n", "<leader>e", "<cmd>Lex 30<cr>", "Toggle file tree")

-- 文件 / Buffer 查找（内置伪 Telescope）
map("n", "<leader>ff", ":find ", "Find files", { silent = false })
map("n", "<leader>fg", ":silent grep! ", "Live grep", { silent = false })
-- fG：直接搜索光标下的词并打开 quickfix（新增）
map("n", "<leader>fG", function()
    local word = vim.fn.expand("<cword>")
    vim.cmd("silent grep! " .. vim.fn.shellescape(word))
    vim.cmd("copen")
end, "Grep word under cursor")
map("n", "<leader>fb", ":ls<cr>:b ", "Find buffers", { silent = false })
map("n", "<leader>fh", ":help ", "Help tags", { silent = false })
map("n", "<leader>fr", "<cmd>browse oldfiles<cr>", "Recent files")

-- 全局搜索替换当前词（新增）
map("n", "<leader>rw",
    ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
    "Search/replace word under cursor",
    { silent = false })

-- 诊断开关（新增，Neovim 专属）
map("n", "<leader>td", function()
    local en = not vim.diagnostic.is_enabled()
    vim.diagnostic.enable(en)
    vim.notify(en and "Diagnostics ON" or "Diagnostics OFF", vim.log.levels.INFO)
end, "Toggle diagnostics")

-- Quickfix / Loclist
map("n", "<leader>xx", function() vim.diagnostic.setqflist({ open = true }) end,
    "Diagnostics (qflist)")
map("n", "<leader>xd", function() vim.diagnostic.setloclist({ open = true }) end,
    "Buffer diagnostics (loclist)")

-- 补全弹出菜单
map("i", "<Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, "Next item / Tab", { expr = true })
map("i", "<S-Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, "Prev item / S-Tab", { expr = true })
-- 新增：Enter 直接确认补全选项
map("i", "<CR>", function()
    return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
end, "Confirm completion / Enter", { expr = true })

-- ─── 5. Treesitter（内置 parser，无需安装）────────────────────────────────────
local builtin_ts = {
    c = true,
    lua = true,
    vim = true,
    vimdoc = true,
    query = true,
    markdown = true,
    markdown_inline = true,
}
vim.api.nvim_create_autocmd("FileType", {
    group    = vim.api.nvim_create_augroup("BuiltinTreesitter", { clear = true }),
    callback = function(args)
        if builtin_ts[args.match] then pcall(vim.treesitter.start, args.buf) end
    end,
})

-- ─── 6. LSP ───────────────────────────────────────────────────────────────────

-- 6-a LspAttach：键位 + 内置补全
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("BuiltinLsp", { clear = true }),
    callback = function(args)
        local b = args.buf
        local function bmap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = b, silent = true, desc = desc })
        end
        bmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
        bmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        bmap("n", "gr", vim.lsp.buf.references, "References")
        bmap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        -- K (hover) 由 Neovim 0.11 自动绑定
        bmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        bmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        bmap("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")
        bmap("n", "[d", function()
            vim.diagnostic.jump({ count = -1, float = true })
        end, "Prev diagnostic")
        bmap("n", "]d", function()
            vim.diagnostic.jump({ count = 1, float = true })
        end, "Next diagnostic")
        bmap("n", "<leader>dl", vim.diagnostic.open_float, "Diagnostic float")
        bmap("n", "<leader>fm", function()
            vim.lsp.buf.format({ async = true })
        end, "Format file")

        -- 内置 LSP 补全（Neovim 0.11+）
        if vim.lsp.completion and vim.lsp.completion.enable then
            vim.lsp.completion.enable(true, args.data.client_id, b, { autotrigger = true })
        end
    end,
})

-- 6-b 诊断配置（新增规范 Unicode 符号，替代原来的纯文字 prefix）
vim.diagnostic.config({
    virtual_text     = { prefix = "●" },
    signs            = {
        text = {
            [vim.diagnostic.severity.ERROR] = "●",
            [vim.diagnostic.severity.WARN]  = "▲",
            [vim.diagnostic.severity.HINT]  = "◆",
            [vim.diagnostic.severity.INFO]  = "○",
        },
    },
    underline        = true,
    update_in_insert = false,
    severity_sort    = true,
    float            = { border = "rounded", source = true, header = "" },
})

-- 6-c Server 配置（可执行文件不存在时跳过，避免启动时报错）
local function lsp(name, cfg)
    if vim.fn.executable(cfg.cmd[1]) ~= 1 then return end
    vim.lsp.config(name, cfg)
    vim.lsp.enable(name)
end

lsp("lua_ls", {
    cmd          = { "lua-language-server" },
    filetypes    = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
    settings     = {
        Lua = {
            runtime     = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace   = { checkThirdParty = false },
            telemetry   = { enable = false },
        },
    },
})

lsp("pyright", {
    cmd          = { "pyright-langserver", "--stdio" },
    filetypes    = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
})

lsp("ts_ls", {
    cmd          = { "typescript-language-server", "--stdio" },
    filetypes    = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
})

lsp("gopls", {
    cmd          = { "gopls" },
    filetypes    = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
})

lsp("rust_analyzer", {
    cmd          = { "rust-analyzer" },
    filetypes    = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
})

lsp("clangd", {
    cmd          = { "clangd" },
    filetypes    = { "c", "cpp", "objc", "objcpp" },
    root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
})

lsp("bashls", {
    cmd          = { "bash-language-server", "start" },
    filetypes    = { "sh", "bash" },
    root_markers = { ".git" },
})

lsp("jsonls", {
    cmd          = { "vscode-json-language-server", "--stdio" },
    filetypes    = { "json", "jsonc" },
    root_markers = { ".git" },
})

-- ─── 7. 自动命令 ──────────────────────────────────────────────────────────────
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- 保存前去除尾随空白
local trim_skip = { markdown = true, gitcommit = true, mail = true, diff = true, patch = true }
autocmd("BufWritePre", {
    group    = augroup("TrimWhitespace", { clear = true }),
    pattern  = "*",
    callback = function()
        if trim_skip[vim.bo.filetype] then return end
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[keeppatterns %s/\s\+$//e]])
        vim.api.nvim_win_set_cursor(0, pos)
    end,
})

-- 终端进入插入模式
autocmd("TermOpen", {
    group    = augroup("TermInsert", { clear = true }),
    callback = function() vim.cmd("startinsert") end,
})

-- 特定 filetype 使用 2-space 缩进
autocmd("FileType", {
    group    = augroup("IndentOverride", { clear = true }),
    pattern  = { "lua", "javascript", "typescript", "html", "css", "json", "yaml" },
    callback = function()
        vim.opt_local.tabstop    = 2
        vim.opt_local.shiftwidth = 2
    end,
})

-- Yank 高亮（vim.hl.on_yank 是 Neovim 内置，比 Vim 的 matchadd 方案更简洁）
autocmd("TextYankPost", {
    group    = augroup("YankHighlight", { clear = true }),
    callback = function()
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
    end,
})

-- Tabline 重绘（buffer 增删 / 修改时）
autocmd({ "BufAdd", "BufDelete", "BufWritePost", "BufModifiedSet" }, {
    group    = augroup("RedrawTabline", { clear = true }),
    callback = function() vim.cmd("redrawtabline") end,
})
