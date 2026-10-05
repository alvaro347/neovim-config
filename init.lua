-- Neovim 0.12 config on the built-in plugin manager (:h vim.pack).
--   lua/config/options.lua      options (loaded first)
--   lua/config/languages.lua    per-language settings: indentation, wrapping, spelling
--   lua/config/pack.lua         helper around vim.pack (add/lazy/later/load_dir, :Pack* commands)
--   lua/config/lazy_colors.lua  loads a theme plugin on its first :colorscheme
--   lua/config/keymaps.lua      general keymaps (plugin keymaps live with the plugin)
--   lua/config/autocmds.lua     autocmds
--   lua/config/completion.lua   native completion (LSP and buffer words while typing)
--   lua/config/lsp_servers.lua  LSP servers to enable + their mason packages
--   lua/plugins/*.lua           one file per plugin
--   lua/plugins/themes/*.lua    colorschemes (zenbones is applied below)
--   colors/*.lua                own *bones colorschemes
-- vim.pack maintains the lockfile nvim-pack-lock.json; keep it in git.
vim.loader.enable()

vim.g.mapleader = " "

require("config.options")
require("config.languages")

local pack = require("config.pack")
require("config.lazy_colors")

-- Colorschemes first so UI plugins pick up the right highlight groups
pack.load_dir("plugins/themes")
if not pcall(vim.cmd.colorscheme, "zenbones") then
  vim.cmd.colorscheme("habamax")
end

-- snacks first: it defines the global `Snacks` used by other plugin files
require("plugins.snacks")
require("plugins.miniicons") -- icons (and a nvim-web-devicons shim) for the plugins below
pack.load_dir("plugins")

require("config.keymaps")
require("config.autocmds")
require("config.completion")
