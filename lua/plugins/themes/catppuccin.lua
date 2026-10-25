-- catppuccin (:colorscheme catppuccin / catppuccin-mocha ...). Plugin integrations are auto-detected.
local pack = require("config.pack")
pack.lazy({ { "catppuccin/nvim", name = "catppuccin" } }, {}, function()
  require("catppuccin").setup({
    transparent_background = true,
    float = { transparent = true },
    -- "bordered" gives the blink menu border a mantle bg (pumblend > 0) around a menu that
    -- options.lua makes see-through; "solid" leaves the border to blink (Pmenu, as before)
    integrations = { blink_cmp = { style = "solid" } },
  })
end)
