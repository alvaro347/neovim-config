-- Neovim >= 0.12 configuration using the built-in plugin manager (:h vim.pack).
--
-- Layout
--   lua/config/options.lua      options (LazyVim defaults + own)
--   lua/config/keymaps.lua      general keymaps (plugin keymaps live with the plugin)
--   lua/config/autocmds.lua     autocmds
--   lua/config/pack.lua         small helper around vim.pack (see the file header)
--   lua/plugins/*.lua           one file per plugin
--   lua/plugins/lazyvim/*.lua   plugins inherited from LazyVim, still to be reviewed
--   lua/plugins/themes/*.lua    colorschemes (only gruvbox-material is applied below)
--   lua/plugins/_old/*.lua_OLD  disabled plugins (not loaded)
--
-- Manage plugins with :PackUpdate, :PackStatus and :PackClean.
-- The lockfile nvim-pack-lock.json is maintained by vim.pack; keep it in git.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")

local pack = require("config.pack")
pack.setup() -- hooks + :Pack* commands; must run before the first pack.add()

-- Colorschemes first so UI plugins pick up the right highlight groups
pack.load_dir("plugins/themes")
if not pcall(vim.cmd.colorscheme, "zenbones") then
  vim.cmd.colorscheme("habamax")
end

-- snacks.nvim first: it defines the global `Snacks` used by other plugin files
pcall(require, "plugins.snacks")
pcall(require, "plugins.miniicons") -- provides icons (and a nvim-web-devicons shim) for the plugins below
pack.load_dir("plugins")
pack.load_dir("plugins/lazyvim")

require("config.keymaps")
require("config.autocmds")
