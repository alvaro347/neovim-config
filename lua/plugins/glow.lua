-- glow: markdown preview in a floating window (:Glow). Loaded on first use.
local pack = require("config.pack")
pack.lazy({ "ellisonleao/glow.nvim" }, { cmd = "Glow" }, function()
  require("glow").setup({})
end)
