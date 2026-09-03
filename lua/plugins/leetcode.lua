-- leetcode.nvim: solve leetcode problems inside neovim (`nvim leetcode.nvim`, :Leet).
-- Needs the html treesitter parser (in plugins/treesitter.lua ensure_installed).
local pack = require("config.pack")
pack.add({
  "nvim-lua/plenary.nvim",
  "MunifTanjim/nui.nvim",
  "kawre/leetcode.nvim",
})

require("leetcode").setup({
  -- configuration goes here
})
