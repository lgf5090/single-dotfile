-- =============================================================================
--  Neovim 0.11+ Pure-Builtins Configuration
--  No third-party plugins. Drop-in replacement for init.lua — rename to
--  init.lua or symlink as ~/.config/nvim/init.lua.
--
--  Built-in substitutes used:
--    nvim-treesitter   →  vim.treesitter.start (parsers shipped with nvim:
--                         c / lua / vim / vimdoc / query / markdown)
--    nvim-cmp / LuaSnip→  vim.lsp.completion.enable + <C-x><C-o> + popupmenu
--    nvim-lspconfig    →  hand-written vim.lsp.config + vim.lsp.enable
--    nvim-tree         →  netrw (:Lex)
--    telescope         →  :find (with path+=**), :grep (with rg), :ls+:b
--    lualine           →  custom 'statusline'
--    bufferline        →  custom 'tabline'
--    gitsigns          →  not replaced (no built-in equivalent)
--    indent-blankline  →  'listchars.leadmultispace'
--    trouble           →  vim.diagnostic.setqflist / setloclist
--    tokyonight        →  built-in 'habamax' (or retrobox / sorbet / vague)
--    autopairs         →  not replaced (intentional — built-in alternatives
--                         tend to surprise more than they help)
-- =============================================================================

-- ─── 1. Options ───────────────────────────────────────────────────────────────
local opt = vim.opt

-- Line numbers
opt.number         = true
opt.relativenumber = true

-- Indentation
opt.tabstop        = 4
opt.shiftwidth     = 4
opt.softtabstop    = 4
opt.expandtab      = true
opt.smartindent    = true

-- Search
opt.hlsearch       = true
opt.incsearch      = true
opt.ignorecase     = true
opt.smartcase      = true

-- Appearance
opt.termguicolors  = true
opt.cursorline     = true
opt.signcolumn     = "yes"
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.wrap           = false
opt.colorcolumn    = "80"
opt.showmode       = false

-- Files
opt.fileencoding   = "utf-8"
opt.swapfile       = false
opt.backup         = false
opt.undofile       = true
opt.undodir        = vim.fs.joinpath(vim.fn.stdpath("data"), "undo")

-- Splits
opt.splitright     = true
opt.splitbelow     = true

-- Completion: popup 让内置 LSP 补全显示文档窗口（nvim 0.11+）
opt.completeopt    = { "menu", "menuone", "noselect", "popup" }
opt.pumheight      = 10

-- Misc
opt.mouse          = "a"
vim.schedule(function() vim.opt.clipboard = "unnamedplus" end)
opt.updatetime     = 250
opt.timeoutlen     = 300
opt.list           = true
opt.listchars      = {
  tab            = "» ",
  trail          = "·",
  nbsp           = "␣",
  -- 内置缩进引导线，替代 indent-blankline
  leadmultispace = "│   ",
}

-- :find 走 'path' —— 加 ** 让它递归，配合 wildmenu 当作粗粒度模糊查找
opt.path:append("**")
opt.wildmenu       = true
opt.wildmode       = { "longest:full", "full" }
opt.wildignore:append({ "*/node_modules/*", "*/.git/*", "*/target/*", "*/dist/*", "*/build/*" })

-- :grep 优先用 ripgrep
if vim.fn.executable("rg") == 1 then
  opt.grepprg    = "rg --vimgrep --no-heading --smart-case"
  opt.grepformat = "%f:%l:%c:%m"
end

-- ─── 2. Statusline / Tabline (built-in) ───────────────────────────────────────
opt.laststatus  = 3   -- 全局 statusline
opt.showtabline = 2   -- 始终显示 tabline（用作 bufferline）

opt.statusline = table.concat({
  " %f",            -- 路径
  " %m%r",          -- modified / readonly 标记
  "%=",             -- 右对齐分隔
  " %{&filetype} ",
  "│ %l:%c ",
  "│ %p%% ",
})

-- bufferline 替代：在 tabline 里列出 buflisted 的 buffer
function _G.MyTabline()
  local parts  = {}
  local cur    = vim.api.nvim_get_current_buf()
  for _, bnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[bnr].buflisted then
      local name = vim.api.nvim_buf_get_name(bnr)
      name = name == "" and "[No Name]" or vim.fs.basename(name)
      local hl   = bnr == cur and "%#TabLineSel#" or "%#TabLine#"
      local flag = vim.bo[bnr].modified and "+" or " "
      parts[#parts + 1] = string.format("%s %d:%s%s ", hl, bnr, name, flag)
    end
  end
  parts[#parts + 1] = "%#TabLineFill#"
  return table.concat(parts)
end
opt.tabline = "%!v:lua.MyTabline()"

-- ─── 3. Keymaps ───────────────────────────────────────────────────────────────
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

local function map(mode, lhs, rhs, desc, extra)
  local o = { silent = true, desc = desc }
  if extra then for k, v in pairs(extra) do o[k] = v end end
  vim.keymap.set(mode, lhs, rhs, o)
end

-- General
map("n", "<leader>w",  "<cmd>w<cr>",         "Save file")
map("n", "<leader>q",  "<cmd>q<cr>",         "Quit")
map("n", "<leader>Q",  "<cmd>qa!<cr>",       "Force quit all")
map("n", "<Esc>",      "<cmd>nohl<cr>",      "Clear search highlight")

-- Window navigation
map("n", "<C-h>",      "<C-w>h",             "Window left")
map("n", "<C-j>",      "<C-w>j",             "Window down")
map("n", "<C-k>",      "<C-w>k",             "Window up")
map("n", "<C-l>",      "<C-w>l",             "Window right")

-- Buffer management
map("n", "<S-l>",      "<cmd>bnext<cr>",     "Next buffer")
map("n", "<S-h>",      "<cmd>bprevious<cr>", "Prev buffer")
map("n", "<leader>bd", "<cmd>bdelete<cr>",   "Delete buffer")

-- Splits
map("n", "<leader>sv", "<cmd>vsplit<cr>",    "Vertical split")
map("n", "<leader>sh", "<cmd>split<cr>",     "Horizontal split")

-- Stay in indent mode after shifting
map("v", "<",          "<gv",                "Indent left")
map("v", ">",          ">gv",                "Indent right")

-- Move selected lines
map("v", "J",          ":m '>+1<CR>gv=gv",   "Move lines down")
map("v", "K",          ":m '<-2<CR>gv=gv",   "Move lines up")

-- File explorer: 内置 netrw（左侧边栏）
map("n", "<leader>e",  "<cmd>Lex 30<cr>",    "Toggle file tree (netrw)")

-- 伪 Telescope：靠内置命令 + 'path'+=** / grepprg=rg
map("n", "<leader>ff", ":find ",                       "Find files (:find)",  { silent = false })
map("n", "<leader>fg", ":silent grep! ",               "Live grep (:grep)",   { silent = false })
map("n", "<leader>fb", ":ls<cr>:b ",                   "Find buffers",        { silent = false })
map("n", "<leader>fh", ":help ",                       "Help tags",           { silent = false })
map("n", "<leader>fr", "<cmd>browse oldfiles<cr>",     "Recent files")

-- Diagnostics list: 内置 quickfix / loclist 替代 trouble
map("n", "<leader>xx", function() vim.diagnostic.setqflist({ open = true }) end,
  "Diagnostics (qflist)")
map("n", "<leader>xd", function() vim.diagnostic.setloclist({ open = true }) end,
  "Buffer diagnostics (loclist)")

-- Tab/S-Tab 在补全弹出菜单里翻页（pum 不可见时是普通 Tab）
map("i", "<Tab>",   function() return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"   end,
  "Next item / Tab",   { expr = true })
map("i", "<S-Tab>", function() return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>" end,
  "Prev item / S-Tab", { expr = true })

-- ─── 4. Color Scheme (built-in) ───────────────────────────────────────────────
-- nvim 0.10+ 自带：habamax / retrobox / sorbet / vague / lunaperche / quiet
pcall(vim.cmd.colorscheme, "habamax")

-- ─── 5. Treesitter (built-in parsers only) ────────────────────────────────────
-- Neovim 自带这些 parser，可以直接启用高亮，无需安装。
local builtin_ts = {
  c = true, lua = true, vim = true, vimdoc = true, query = true, markdown = true,
  markdown_inline = true,
}
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("BuiltinTreesitter", { clear = true }),
  callback = function(args)
    if builtin_ts[args.match] then pcall(vim.treesitter.start, args.buf) end
  end,
})

-- ─── 6. LSP (no nvim-lspconfig — cmd / filetypes / root_markers spelled out) ──

-- 6a. LspAttach: 每次有 server 连接到 buffer 时挂键位 + 启用内置补全
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("BuiltinLsp", { clear = true }),
  callback = function(args)
    local b = args.buf
    local function bmap(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = b, silent = true, desc = desc })
    end
    bmap("n", "gd",         vim.lsp.buf.definition,      "Go to definition")
    bmap("n", "gD",         vim.lsp.buf.declaration,     "Go to declaration")
    bmap("n", "gr",         vim.lsp.buf.references,      "References")
    bmap("n", "gi",         vim.lsp.buf.implementation,  "Go to implementation")
    -- K (hover) 由 nvim 0.11+ 自动绑定
    bmap("n", "<leader>rn", vim.lsp.buf.rename,          "Rename symbol")
    bmap("n", "<leader>ca", vim.lsp.buf.code_action,     "Code action")
    bmap("n", "<leader>D",  vim.lsp.buf.type_definition, "Type definition")
    bmap("n", "[d",         function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
    bmap("n", "]d",         function() vim.diagnostic.jump({ count =  1, float = true }) end, "Next diagnostic")
    bmap("n", "<leader>dl", vim.diagnostic.open_float,   "Diagnostic float")
    bmap("n", "<leader>fm", function() vim.lsp.buf.format({ async = true }) end, "Format file")

    -- 内置 LSP 补全（nvim 0.11+）。autotrigger 在用户停顿时自动弹菜单。
    -- 如果嫌烦可以改为 false，手动 <C-x><C-o> 触发 omnifunc。
    if vim.lsp.completion and vim.lsp.completion.enable then
      vim.lsp.completion.enable(true, args.data.client_id, b, { autotrigger = true })
    end
  end,
})

-- 6b. Diagnostic display
vim.diagnostic.config({
  virtual_text     = { prefix = "●" },
  signs            = true,
  underline        = true,
  update_in_insert = false,
  severity_sort    = true,
  float            = { border = "rounded", source = true },
})

-- 6c. Server configs —— 没有 nvim-lspconfig，只能自己写 cmd / filetypes /
-- root_markers。每个 server 仅在它的可执行存在时才 enable，避免 nvim 0.11
-- 启动时打印 "command not found" 错误。
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

-- ─── 7. Autocommands ──────────────────────────────────────────────────────────
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- 去尾随空白
local trim_skip = { markdown = true, gitcommit = true, mail = true, diff = true, patch = true }
autocmd("BufWritePre", {
  group   = augroup("TrimWhitespace", { clear = true }),
  pattern = "*",
  callback = function()
    if trim_skip[vim.bo.filetype] then return end
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})

-- 打开终端时自动进入插入模式
autocmd("TermOpen", {
  group    = augroup("TermInsert", { clear = true }),
  callback = function() vim.cmd("startinsert") end,
})

-- 特定文件类型 2-space 缩进
autocmd("FileType", {
  group   = augroup("IndentOverride", { clear = true }),
  pattern = { "lua", "javascript", "typescript", "html", "css", "json", "yaml" },
  callback = function()
    vim.opt_local.tabstop    = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- yank 高亮
autocmd("TextYankPost", {
  group    = augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- 触发 tabline 重绘（buffer 增删/修改时）
autocmd({ "BufAdd", "BufDelete", "BufWritePost", "BufModifiedSet" }, {
  group    = augroup("RedrawTabline", { clear = true }),
  callback = function() vim.cmd("redrawtabline") end,
})
