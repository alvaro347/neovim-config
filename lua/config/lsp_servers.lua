-- LSP servers: Neovim's built-in client starts them (vim.lsp.enable, 0.11+), nvim-lspconfig provides
-- each server's defaults (its lsp/<name>.lua) and mason installs the binaries (plugins/mason.lua).
-- To add a language: install its server in :Mason and add one line here.
local servers = { -- nvim-lspconfig name = mason package
  cssls = "css-lsp",
  jdtls = "jdtls",
  lua_ls = "lua-language-server",
  protols = "protols",
  pyright = "pyright",
  ts_ls = "typescript-language-server",
  yamlls = "yaml-language-server",
}

local names = vim.tbl_keys(servers)
table.sort(names)
vim.lsp.enable(names)

return servers
