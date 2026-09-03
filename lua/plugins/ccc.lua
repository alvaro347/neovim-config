-- ccc: color picker / highlighter (<leader>cp -> :CccPick, see keymaps.lua).
local pack = require("config.pack")
pack.add({ "uga-rosa/ccc.nvim" })

pack.later(function()
  require("ccc").setup({
    highlighter = {
      auto_enable = true,
      lsp = true,
    },
  })
end)
