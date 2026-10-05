-- Per-language editor settings: indentation, wrapping, spelling. Formatting: plugins/conform.lua.
-- Indent precedence when a file is opened: a repo's .editorconfig > this file > runtime ftplugins >
-- the default below. The buffer's indent also reaches stylua (without a repo stylua.toml), shfmt and
-- LSP formatting; prettier uses the project's config and dart format always indents 2.

-- Indent: 4 spaces by default, 2 for the filetypes below. Filetypes not listed keep what their
-- runtime ftplugin sets (Go: tabs).
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.tabstop = 4
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

-- Wrap and spell-check prose
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_wrap_spell", { clear = true }),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
