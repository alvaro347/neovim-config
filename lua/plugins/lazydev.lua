-- lazydev: lua_ls types for the Neovim runtime and plugins, and for Hyprland's Lua config.
-- Loaded for lua files.
local pack = require("config.pack")
pack.lazy({ "folke/lazydev.nvim" }, { ft = "lua", cmd = "LazyDev" }, function()
  require("lazydev").setup({
    library = {
      { path = "snacks.nvim", words = { "Snacks" } },
      -- Hyprland's `hl` API, only for a workspace with a buffer named hyprland.lua
      { path = "/usr/share/hypr/stubs", files = { "hyprland.lua" } },
    },
  })
end)
