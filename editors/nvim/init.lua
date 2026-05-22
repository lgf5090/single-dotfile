-- =============================================================================
--  Neovim 0.12+ Configuration
--  Place this file at ~/.config/nvim/init.lua
--  First launch: press A to install all plugins, quit, then restart Neovim
-- =============================================================================

-- ─── 1. Plugin Management (vim.pack) ─────────────────────────────────────────
vim.pack.add({
  -- Syntax highlighting (pinned to v0.x for stable API)
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "v0.*" },

  -- LSP (provides server defaults: cmd, filetypes, etc.)
  { src = "https://github.com/neovim/nvim-lspconfig" },

  -- Autocompletion
  { src = "https://github.com/hrsh7th/nvim-cmp" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
  { src = "https://github.com/hrsh7th/cmp-buffer" },
  { src = "https://github.com/hrsh7th/cmp-path" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/saadparwaiz1/cmp_luasnip" },

  -- File explorer
  { src = "https://github.com/nvim-tree/nvim-tree.lua" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },

  -- Fuzzy finder
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  -- C sorter for telescope (10-50x faster than the Lua fallback on large
  -- repos). vim.pack 0.12 has no build hook — we run `make` on first launch
  -- via the build block below.
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },

  -- Status line / buffer tabs
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/akinsho/bufferline.nvim" },

  -- Git decorations
  { src = "https://github.com/lewis6991/gitsigns.nvim" },

  -- Auto pairs
  { src = "https://github.com/windwp/nvim-autopairs" },

  -- Indent guides
  { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },

  -- Color scheme
  { src = "https://github.com/folke/tokyonight.nvim" },

  -- Diagnostics list
  { src = "https://github.com/folke/trouble.nvim" },
})

-- Safe require: silently skip if a plugin is not yet installed
local function safe(mod, fn)
  local ok, m = pcall(require, mod)
  if ok then fn(m) end
end

-- Lazy-load helper: 把插件的 setup() 推迟到首次触发命令时。
-- 用于纯按需的插件（nvim-tree / telescope / trouble 等），避免启动时
-- 把整个插件链 require 进来。
local function lazy(mod, setup, cmd)
  local done = false
  return function()
    if not done then
      safe(mod, setup)
      done = true
    end
    vim.cmd(cmd)
  end
end

-- One-time build of telescope-fzf-native's C extension. vim.pack 0.12 has no
-- post-install hook, so we check at startup whether libfzf.so exists and run
-- `make` if not. After a successful build the stat check is a no-op (~µs).
do
  local ok, info = pcall(vim.pack.get, { names = { "telescope-fzf-native.nvim" } })
  if ok and info and info[1] and info[1].path
      and not vim.uv.fs_stat(vim.fs.joinpath(info[1].path, "build", "libfzf.so")) then
    vim.notify("Building telescope-fzf-native (one-time, ~5s)...", vim.log.levels.INFO)
    vim.system({ "make" }, { cwd = info[1].path }):wait()
  end
end

-- ─── 2. Options ───────────────────────────────────────────────────────────────
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

-- Completion
opt.completeopt    = { "menu", "menuone", "noselect" }
opt.pumheight      = 10

-- Misc
opt.mouse          = "a"
-- Defer clipboard provider probe: setting `clipboard` triggers a synchronous
-- check for xclip/wl-copy/pbcopy at startup (~50-100 ms on remote/headless
-- boxes). `vim.schedule` runs after the UI is ready, so startup stays snappy.
vim.schedule(function() vim.opt.clipboard = "unnamedplus" end)
opt.updatetime     = 250
opt.timeoutlen     = 300
opt.list           = true
opt.listchars      = { tab = "» ", trail = "·", nbsp = "␣" }

-- ─── 3. Keymaps ───────────────────────────────────────────────────────────────
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
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
map("v", "<",          "<gv",               "Indent left")
map("v", ">",          ">gv",               "Indent right")

-- Move selected lines up/down
map("v", "J",          ":m '>+1<CR>gv=gv",  "Move lines down")
map("v", "K",          ":m '<-2<CR>gv=gv",  "Move lines up")

-- File explorer (按需 setup —— 见 §10 配置)
map("n", "<leader>e", lazy("nvim-tree", function(m)
  m.setup({
    view     = { width = 30 },
    renderer = { group_empty = true },
    filters  = { dotfiles = false },
    git      = { enable = true },
  })
end, "NvimTreeToggle"), "Toggle file tree")

-- Telescope (按需 setup —— 见 §15a 配置)
local function telescope_setup(m)
  m.setup({})
  pcall(m.load_extension, "fzf")
end
map("n", "<leader>ff", lazy("telescope", telescope_setup, "Telescope find_files"), "Find files")
map("n", "<leader>fg", lazy("telescope", telescope_setup, "Telescope live_grep"),  "Live grep")
map("n", "<leader>fb", lazy("telescope", telescope_setup, "Telescope buffers"),    "Find buffers")
map("n", "<leader>fh", lazy("telescope", telescope_setup, "Telescope help_tags"),  "Help tags")
map("n", "<leader>fr", lazy("telescope", telescope_setup, "Telescope oldfiles"),   "Recent files")

-- Trouble diagnostics (按需 setup —— 见 §15 配置)
map("n", "<leader>xx", lazy("trouble", function(m) m.setup() end,
  "Trouble diagnostics toggle"), "Diagnostics")
map("n", "<leader>xd", lazy("trouble", function(m) m.setup() end,
  "Trouble diagnostics toggle filter.buf=0"), "Buffer diagnostics")

-- ─── 4. Color Scheme ──────────────────────────────────────────────────────────
safe("tokyonight", function(m)
  m.setup({ style = "night", transparent = false })
end)
-- pcall: on first launch the plugin isn't downloaded yet — fall back to the
-- built-in default rather than aborting init.lua with E185.
pcall(vim.cmd.colorscheme, "tokyonight")

-- ─── 5. Treesitter ────────────────────────────────────────────────────────────
safe("nvim-treesitter.configs", function(ts)
  ts.setup({
    ensure_installed = {
      "lua", "python", "javascript", "typescript", "tsx",
      "go", "rust", "c", "cpp", "java",
      "html", "css", "json", "yaml", "toml",
      "markdown", "markdown_inline", "bash", "vim", "vimdoc",
    },
    auto_install = true,
    highlight    = { enable = true },
    indent       = { enable = true },
    incremental_selection = {
      enable  = true,
      keymaps = {
        init_selection   = "<C-space>",
        node_incremental = "<C-space>",
        node_decremental = "<BS>",
      },
    },
  })
end)

-- ─── 6. LSP (Neovim 0.11+ API) ────────────────────────────────────────────────

-- Keymaps attached when an LSP connects to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local b = args.buf
    local function bmap(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = b, silent = true, desc = desc })
    end
    bmap("n", "gd",         vim.lsp.buf.definition,      "Go to definition")
    bmap("n", "gD",         vim.lsp.buf.declaration,     "Go to declaration")
    bmap("n", "gr",         vim.lsp.buf.references,      "References")
    bmap("n", "gi",         vim.lsp.buf.implementation,  "Go to implementation")
    -- K (hover) is bound automatically by nvim 0.11+ on LspAttach.
    bmap("n", "<leader>rn", vim.lsp.buf.rename,          "Rename symbol")
    bmap("n", "<leader>ca", vim.lsp.buf.code_action,     "Code action")
    bmap("n", "<leader>D",  vim.lsp.buf.type_definition, "Type definition")
    bmap("n", "[d",         function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
    bmap("n", "]d",         function() vim.diagnostic.jump({ count =  1, float = true }) end, "Next diagnostic")
    bmap("n", "<leader>dl", vim.diagnostic.open_float,   "Diagnostic float")
    bmap("n", "<leader>fm", function()
      vim.lsp.buf.format({ async = true })
    end, "Format file")
  end,
})

-- Diagnostic display
vim.diagnostic.config({
  virtual_text     = { prefix = "●" },
  signs            = true,
  underline        = true,
  update_in_insert = false,
  severity_sort    = true,
  float            = { border = "rounded", source = true },
})

-- Merge nvim-cmp capabilities into every LSP server. 即便 cmp_nvim_lsp 还未
-- 安装（首次启动时），也至少把内置 capabilities 应用到 "*"，否则补全字段
-- 永远不会下发到 server。
local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
safe("cmp_nvim_lsp", function(c)
  lsp_capabilities = c.default_capabilities(lsp_capabilities)
end)
vim.lsp.config("*", { capabilities = lsp_capabilities })

-- lua_ls: teach it about the vim global
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime     = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace   = { checkThirdParty = false },
      telemetry   = { enable = false },
    },
  },
})

-- Enable servers (skipped silently if the executable is not found)
vim.lsp.enable({
  "lua_ls",
  "pyright",        -- pip install pyright
  "ts_ls",          -- npm i -g typescript-language-server typescript
  "gopls",          -- go install golang.org/x/tools/gopls@latest
  "rust_analyzer",  -- rustup component add rust-analyzer
  "clangd",         -- apt/brew install clangd
  "bashls",         -- npm i -g bash-language-server
  "jsonls",         -- npm i -g vscode-langservers-extracted
  "html",
  "cssls",
})

-- ─── 7. Autocompletion + Auto Pairs (deferred to first InsertEnter) ─────────
-- cmp / luasnip / autopairs 只在插入模式有意义，把它们的 setup 推迟到第一次
-- 进入插入模式，启动期不 require 这条插件链。setup 完成后重新触发一次
-- InsertEnter，让 cmp 内部的事件监听对当前的进入事件生效。
vim.api.nvim_create_autocmd("InsertEnter", {
  once  = true,
  group = vim.api.nvim_create_augroup("CmpLazyLoad", { clear = true }),
  callback = function()
    safe("cmp", function(cmp)
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end)

    safe("nvim-autopairs", function(m)
      m.setup({ check_ts = true })
      safe("nvim-autopairs.completion.cmp", function(ap)
        safe("cmp", function(cmp)
          cmp.event:on("confirm_done", ap.on_confirm_done())
        end)
      end)
    end)

    vim.api.nvim_exec_autocmds("InsertEnter", { modeline = false })
  end,
})

-- ─── 8. Status Line (lualine) ─────────────────────────────────────────────────
safe("lualine", function(m)
  m.setup({
    options = {
      theme                = "tokyonight",
      component_separators = { left = "|", right = "|" },
      section_separators   = { left = "",  right = "" },
      globalstatus         = true,
      icons_enabled        = false,
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { { "filename", path = 1 } }, -- relative path
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  })
end)

-- ─── 9. Buffer Tabs (bufferline) ──────────────────────────────────────────────
safe("bufferline", function(m)
  m.setup({
    options = {
      diagnostics             = "nvim_lsp",
      separator_style         = "thin",
      show_buffer_icons       = false,
      show_buffer_close_icons = false,
      show_close_icon         = false,
      diagnostics_indicator   = function(count, level)
        -- bufferline 传入的 level 是字符串（"error" / "warning" / "info" /
        -- "hint"），不是 vim.diagnostic.severity 枚举。
        local icon = level == "error" and "E" or level == "warning" and "W" or "I"
        return " " .. icon .. count
      end,
    },
  })
end)

-- ─── 10. File Explorer (nvim-tree) ────────────────────────────────────────────
-- Disable built-in netrw. nvim-tree 本身延迟到 <leader>e 首次触发时再 setup
-- (见 §3 的 keymap)。
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- ─── 11. Git Signs (gitsigns) ─────────────────────────────────────────────────
safe("gitsigns", function(m)
  m.setup({
    signs = {
      add          = { text = "▎" },
      change       = { text = "▎" },
      delete       = { text = "" },
      topdelete    = { text = "" },
      changedelete = { text = "▎" },
    },
    on_attach = function(buf)
      local gs = package.loaded.gitsigns
      local function bmap(l, r, desc)
        vim.keymap.set("n", l, r, { buffer = buf, desc = desc })
      end
      bmap("]g",         gs.next_hunk,    "Next hunk")
      bmap("[g",         gs.prev_hunk,    "Prev hunk")
      bmap("<leader>hs", gs.stage_hunk,   "Stage hunk")
      bmap("<leader>hr", gs.reset_hunk,   "Reset hunk")
      bmap("<leader>hp", gs.preview_hunk, "Preview hunk")
      bmap("<leader>gb", gs.blame_line,   "Git blame")
    end,
  })
end)

-- ─── 12. Auto Pairs (nvim-autopairs) ──────────────────────────────────────────
-- 已与 §7 合并到 InsertEnter once 回调里。

-- ─── 13. Comments ─────────────────────────────────────────────────────────────
-- nvim 0.10+ ships built-in comment operators: gcc (toggle line),
-- gc{motion} (toggle region), gbc (block comment). No plugin needed.

-- ─── 14. Indent Guides (indent-blankline) ─────────────────────────────────────
safe("ibl", function(m)
  m.setup({
    indent = { char = "│" },
    scope  = { enabled = true },
  })
end)

-- ─── 15. Diagnostics List (Trouble) ───────────────────────────────────────────
-- 推迟到 <leader>x* 首次触发时 setup（见 §3 keymap）。

-- ─── 15a. Telescope ───────────────────────────────────────────────────────────
-- 推迟到 <leader>f* 首次触发时 setup + load_extension("fzf")（见 §3 keymap）。
-- pcall 处理 libfzf.so 构建失败的情形。

-- ─── 16. Autocommands ─────────────────────────────────────────────────────────
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Strip trailing whitespace on save
-- Skipped for filetypes where trailing whitespace is significant:
--   markdown — two trailing spaces = hard line break
--   gitcommit / mail / diff / patch — payload integrity
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

-- Enter insert mode automatically when opening a terminal
autocmd("TermOpen", {
  group    = augroup("TermInsert", { clear = true }),
  callback = function() vim.cmd("startinsert") end,
})

-- 2-space indent for certain file types
autocmd("FileType", {
  group   = augroup("IndentOverride", { clear = true }),
  pattern = { "lua", "javascript", "typescript", "html", "css", "json", "yaml" },
  callback = function()
    vim.opt_local.tabstop    = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- Briefly highlight yanked text
autocmd("TextYankPost", {
  group    = augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})
