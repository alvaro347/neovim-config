-- zenbones (:colorscheme zenbones / zenwritten / zenburned / kanagawabones / neobones / ...)
local pack = require("config.pack")
pack.add({ "rktjmp/lush.nvim", "zenbones-theme/zenbones.nvim" })

-- No setup(): `require("zenbones")` returns the lush spec itself. Options are read
-- from `vim.g.<flavor>` when `:colorscheme` runs (init.lua, after this file).
-- Each official flavor has its own prefix; the custom *bones in colors/ default to
-- transparent on their own.
vim.g.zenbones = {
  transparent_background = true,
}
vim.g.neobones = {
  transparent_background = true,
}
vim.g.rosebones = {
  transparent_background = true,
}
vim.g.tokyobones = {
  transparent_background = true,
}
vim.g.kanagawabones = {
  transparent_background = true,
}
vim.g.duckbones = {
  transparent_background = true,
}
vim.g.forestbones = {
  transparent_background = true,
}
vim.g.seoulbones = {
  transparent_background = true,
}
vim.g.vimbones = {
  transparent_background = true,
}
vim.g.nordbones = {
  transparent_background = true,
}
