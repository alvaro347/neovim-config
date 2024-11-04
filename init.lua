-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Plug Package Manager
local vim = vim
local Plug = vim.fn["plug#"]

vim.call("plug#begin")

Plug("mfussenegger/nvim-jdtls")
Plug("tpope/vim-fugitive")

vim.call("plug#end")
