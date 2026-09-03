-- kanagawa (:colorscheme kanagawa / kanagawa-wave / -dragon / -lotus)
local pack = require("config.pack")
pack.add({ "rebelot/kanagawa.nvim" })

require("kanagawa").setup({
  transparent = false,
  colors = {
    theme = {
      all = {
        ui = {
          bg_gutter = "none",
        },
      },
    },
  },
})
