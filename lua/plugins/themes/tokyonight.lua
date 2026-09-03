-- tokyonight (:colorscheme tokyonight / tokyonight-moon ...)
local pack = require("config.pack")
pack.add({ "folke/tokyonight.nvim" })

require("tokyonight").setup({
  style = "moon", -- storm, moon, night, day
  transparent = true,
})
