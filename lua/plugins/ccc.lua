-- ccc: color picker / highlighter (<leader>cp -> :CccPick, see keymaps.lua).
local pack = require("config.pack")
pack.add({ "uga-rosa/ccc.nvim" })

-- Set up eagerly: auto_enable only hooks future BufEnter events, so a deferred setup
-- would miss the buffer opened at startup. lsp = false: ccc's documentColor requests re-ran
-- on every edit; ccc colours what its pickers match (#rrggbb, rgb(), hsl(), ...) and Neovim's
-- own LSP colours are off (plugins/lsp.lua), so there is one colorizer.
require("ccc").setup({
  lsp = false,
  highlighter = {
    auto_enable = true,
    lsp = false,
  },
})
