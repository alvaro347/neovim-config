-- zenbones (:colorscheme zenbones / zenwritten / zenburned / kanagawabones / ...)
local pack = require("config.pack")
pack.add({ "rktjmp/lush.nvim", "zenbones-theme/zenbones.nvim" })

-- No setup(): `require("zenbones")` returns the lush spec itself. Options are read
-- from `vim.g.<flavor>` when `:colorscheme` runs (init.lua, after this file).
vim.g.zenbones = {
  transparent_background = true,
}
