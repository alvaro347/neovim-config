-- tokyonight (:colorscheme tokyonight / tokyonight-moon ...). `tokyonight` alone is the moon style.
local pack = require("config.pack")
pack.lazy({ "folke/tokyonight.nvim" }, {}, function()
  require("tokyonight").setup({ transparent = true })
end)
