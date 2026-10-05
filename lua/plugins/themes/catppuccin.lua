-- catppuccin (:colorscheme catppuccin / catppuccin-mocha ...). Plugin integrations are auto-detected.
local pack = require("config.pack")
pack.lazy({ { "catppuccin/nvim", name = "catppuccin" } }, {}, function()
  require("catppuccin").setup({
    transparent_background = true,
    float = { transparent = true },
  })
end)
