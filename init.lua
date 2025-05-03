-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Plug Package Manager
local vim = vim
local Plug = vim.fn["plug#"]

-- VSCode Handling
if vim.g.vscode then
  -- VSCode extension
  require("config.lazy")
else
  -- ordinary Neovim
  require("config.lazy")
end

vim.call("plug#begin")

-- Plug("mfussenegger/nvim-jdtls")
Plug("ThePrimeagen/vim-be-good")
Plug("tpope/vim-fugitive")
-- Plug("tpope/vim-surround")
-- Plug("mg979/vim-visual-multi")
-- Plug("YacineDo/mc.nvim")

vim.call("plug#end")

vim.opt.guifont = "MesloLGM Nerd Font"
