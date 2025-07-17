-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Map Leader
vim.g.mapleader = " "

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

vim.g.snacks_animate = false

-- LSP (Disagnostics) config
vim.diagnostic.config({
  -- Use the default configuration
  virtual_lines = false,

  -- Alternatively, customize specific options
  -- virtual_lines = {
  --   -- Only show virtual line diagnostics for the current cursor line
  --   current_line = false,
  -- },
})

-- Enable true color
vim.opt.termguicolors = true
