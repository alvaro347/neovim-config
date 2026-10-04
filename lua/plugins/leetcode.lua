-- leetcode.nvim: solve leetcode problems inside neovim (`nvim leetcode.nvim`, :Leet).
-- Needs the html treesitter parser (in plugins/treesitter.lua ensure_installed).
local pack = require("config.pack")
local plugins = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "kawre/leetcode.nvim" }
local function setup()
  require("leetcode").setup({})
end

-- `nvim leetcode.nvim` needs it at startup; otherwise load on the first :Leet
if vim.fn.argv(0, -1) == "leetcode.nvim" then
  pack.add(plugins)
  setup()
else
  pack.lazy(plugins, { cmd = "Leet" }, setup)
end
