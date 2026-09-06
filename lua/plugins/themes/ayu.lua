local pack = require("config.pack")
pack.add({ "shatur/neovim-ayu" })

require("ayu").setup({
  -- overrides = {
  --   Normal = { bg = "None" },
  --   NormalFloat = { bg = "none" },
  --   ColorColumn = { bg = "None" },
  --   SignColumn = { bg = "None" },
  --   Folded = { bg = "None" },
  --   FoldColumn = { bg = "None" },
  --   CursorLine = { bg = "None" },
  --   CursorColumn = { bg = "None" },
  --   VertSplit = { bg = "None" },
  -- },
})
