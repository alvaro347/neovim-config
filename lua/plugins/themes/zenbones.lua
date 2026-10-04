-- zenbones (:colorscheme zenbones / zenwritten / zenburned / kanagawabones / neobones / ...)
-- Loaded eagerly: it is the startup scheme, and colors/*bones.lua build on lush + zenbones.
-- No setup(): options are read from `vim.g.<flavor>` when `:colorscheme` runs. Each official
-- flavor has its own prefix; the custom *bones in colors/ default to transparent on their own.
local pack = require("config.pack")
pack.add({ "rktjmp/lush.nvim", "zenbones-theme/zenbones.nvim" })

local transparent = {
  "zenbones",
  "zenwritten",
  "zenburned",
  "neobones",
  "rosebones",
  "tokyobones",
  "kanagawabones",
  "duckbones",
  "forestbones",
  "seoulbones",
  "vimbones",
  "nordbones",
}
for _, flavor in ipairs(transparent) do
  vim.g[flavor] = { transparent_background = true }
end
