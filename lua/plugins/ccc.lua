-- ccc: color picker / highlighter (<leader>cp -> :CccPick, see keymaps.lua).
local pack = require("config.pack")
pack.add({ "uga-rosa/ccc.nvim" })

-- Set up eagerly: auto_enable only hooks future BufEnter events, so a deferred setup
-- would miss the buffer opened at startup
require("ccc").setup({
  highlighter = {
    auto_enable = true,
    lsp = true,
  },
})
