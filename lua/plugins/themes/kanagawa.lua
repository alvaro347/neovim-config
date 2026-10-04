-- kanagawa (:colorscheme kanagawa / kanagawa-wave / -dragon / -lotus)
local pack = require("config.pack")
pack.lazy({ "rebelot/kanagawa.nvim" }, {}, function()
  require("kanagawa").setup({
    colors = { theme = { all = { ui = { bg_gutter = "none" } } } }, -- sign/number columns without their own bg
  })
end)
