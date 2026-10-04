-- gruvbox.nvim (:colorscheme gruvbox)
local pack = require("config.pack")
pack.lazy({ "ellisonleao/gruvbox.nvim" }, {}, function()
  require("gruvbox").setup({
    contrast = "soft",
    transparent_mode = true,
    overrides = {
      LspReferenceText = { bg = "#4d4d46" }, -- subtler LSP reference highlighting
      LspReferenceRead = { bg = "#3c3836" },
      LspReferenceWrite = { bg = "#3c3836" },
    },
  })
end)
