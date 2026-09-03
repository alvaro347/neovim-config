-- Options. Loaded first from init.lua (before any plugin).
-- The first block is what LazyVim used to set for us; the second block is our own.

-- mapleader is set in init.lua before this file is loaded.

-- Disable builtin plugins we never use (lazy.nvim's performance.rtp.disabled_plugins)
vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_tutor_mode_plugin = 1

-- Plugin globals
vim.g.autoformat = true -- conform.nvim format on save (toggle with <leader>uf)
vim.g.snacks_animate = false -- no snacks animations
vim.g.markdown_recommended_style = 0 -- fix markdown indentation settings

---------------------------------------------------------------------------
-- Defaults inherited from LazyVim
---------------------------------------------------------------------------
local opt = vim.opt

opt.autowrite = true -- Enable auto write
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.foldlevel = 99
opt.foldmethod = "indent" -- treesitter switches this to "expr" per buffer
opt.foldtext = ""
opt.formatexpr = "v:lua.require'conform'.formatexpr()"
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.jumpoptions = "view"
opt.laststatus = 3 -- global statusline
opt.linebreak = true -- Wrap lines at convenient points
opt.list = true -- Show some invisible characters (tabs...)
opt.mouse = "a" -- Enable mouse mode
opt.number = true -- Print line number
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true -- Relative line numbers
opt.ruler = false -- Disable the default ruler
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- Round indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smoothscroll = true
opt.spelllang = { "en" }
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current
-- statuscolumn is set in lua/plugins/snacks.lua (needs snacks on the runtimepath)
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- Lower than default (1000) to quickly trigger which-key
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap

---------------------------------------------------------------------------
-- Own settings
---------------------------------------------------------------------------

-- Font
vim.opt.guifont = "MesloLGM Nerd Font"

-- Tabs and indentation
local indent = vim.api.nvim_create_augroup("FileTypeIndent", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = indent,
  pattern = { "javascript", "typescript", "jsx", "tsx", "html", "css", "json", "yaml" },
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = indent,
  pattern = { "python", "lua", "xml", "markdown" },
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = indent,
  pattern = { "c", "cpp", "java", "go" },
  callback = function()
    vim.bo.expandtab = true -- or false if you prefer actual tabs
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

-- Optional: Default indent (when no FileType matches)
vim.o.tabstop = 4 -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.shiftwidth = 4 -- Number of spaces inserted when indenting
vim.o.softtabstop = 4 -- Number of spaces inserted instead of a TAB character

vim.opt.smartindent = true

-- Window Scroll
vim.opt.scrolloff = 8

vim.opt.clipboard = "unnamedplus"

vim.o.conceallevel = 0

-- METHOD 1: Global setting for all floating windows (simplest for Neovim 0.11+)
vim.o.winborder = "single" -- or use your custom border table

-- Enable true color
vim.opt.termguicolors = true

-- Clear floating window backgrounds for transparency
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })

-- COMPLETION MENU TRANSPARENCY
-- These are the highlight groups for the popup/completion menu
vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE" }) -- Popup menu normal item
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "NONE" }) -- Popup menu selected item (you may want to keep this visible)
vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "NONE" }) -- Popup menu scrollbar
vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "NONE" }) -- Popup menu scrollbar thumb

-- Ensure transparency persists after colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("transparent_floats", { clear = true }),
  pattern = "*",
  callback = function()
    -- Floating windows
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })

    -- Completion menu
    vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "NONE" })
  end,
})
