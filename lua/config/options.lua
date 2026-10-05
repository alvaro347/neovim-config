-- Options, loaded first from init.lua. Only values that differ from Neovim 0.12's defaults.

-- Built-in plugins and remote-plugin providers that are never used
vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
for _, p in ipairs({ "python3", "node", "perl", "ruby" }) do
  vim.g["loaded_" .. p .. "_provider"] = 0
end

local opt = vim.opt
opt.autowrite = true
opt.clipboard = "unnamedplus"
opt.confirm = true -- ask to save instead of failing on :q with changes
opt.cursorline = true
opt.fillchars = { fold = " ", diff = "╱", eob = " " } -- fold signs: snacks.statuscolumn
opt.foldlevel = 99 -- foldmethod stays "manual"; plugins/treesitter.lua sets "expr" where a parser has folds
opt.foldtext = ""
opt.formatoptions = "jcroqlnt"
opt.grepprg = "rg --vimgrep" -- the default adds -uu; this one respects .gitignore
opt.ignorecase = true
opt.jumpoptions = "clean,view"
opt.laststatus = 3 -- global statusline
opt.linebreak = true
opt.list = true
opt.mouse = "a"
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.ruler = false -- laststatus=0 screens (snacks dashboard) would show it in the command line
opt.scrolloff = 8
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "folds" }
opt.shiftround = true
opt.shortmess:append({ W = true, I = true, c = true })
opt.showmode = false -- lualine shows the mode
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.smartcase = true
opt.smoothscroll = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.timeoutlen = 300 -- which-key pops up sooner
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- CursorHold and swap writes
opt.virtualedit = "block"
opt.wildmode = "longest:full,full"
opt.winborder = "single"
opt.winminwidth = 5
opt.wrap = false
-- 'statuscolumn' is set in plugins/snacks.lua

-- Indent: 4 spaces by default, 2 for the filetypes below. Runtime ftplugins still apply on top
-- (Go keeps tabs). conform passes these values to stylua, and a repo's .editorconfig overrides them.
opt.expandtab = true
opt.shiftwidth = 4
opt.softtabstop = 4
opt.tabstop = 4
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_indent", { clear = true }),
  pattern = {
    "css",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "jsonc",
    "less",
    "lua",
    "scss",
    "typescript",
    "typescriptreact",
    "yaml",
  },
  callback = function(ev)
    local bo = vim.bo[ev.buf]
    bo.expandtab, bo.shiftwidth, bo.softtabstop, bo.tabstop = true, 2, 2, 2
  end,
})

-- 'smartindent' only for rofi .rasi and hypr*.conf: `{ }` blocks and no indent script or parser.
-- Elsewhere it moved `#` to column 0 and made `>>` skip `#` lines (R9).
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_smartindent", { clear = true }),
  pattern = { "hyprlang", "rasi" },
  callback = function(ev)
    vim.bo[ev.buf].smartindent = true
  end,
})

-- Transparent themes (Normal has no bg): make floats and menus transparent too. update = true
-- keeps the theme's fg and border colours; opaque themes keep their own floats.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("transparent_floats", { clear = true }),
  callback = function()
    if vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg then
      return
    end
    for _, group in ipairs({ "NormalFloat", "FloatBorder", "Pmenu" }) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE", update = true })
    end
  end,
})
