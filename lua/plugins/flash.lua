-- flash: jump anywhere with `s` + label, treesitter selection with `S`, enhanced f/t/search.
local pack = require("config.pack")
pack.add({ "folke/flash.nvim" })

pack.later(function()
  require("flash").setup({})
end)

local map = vim.keymap.set
-- stylua: ignore start
map({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash" })
map({ "n", "o", "x" }, "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
map("o", "r", function() require("flash").remote() end, { desc = "Remote Flash" })
map({ "o", "x" }, "R", function() require("flash").treesitter_search() end, { desc = "Treesitter Search" })
map("c", "<c-s>", function() require("flash").toggle() end, { desc = "Toggle Flash Search" })
-- Simulate nvim-treesitter incremental selection
map({ "n", "o", "x" }, "<c-space>", function()
  require("flash").treesitter({ actions = { ["<c-space>"] = "next", ["<BS>"] = "prev" } })
end, { desc = "Treesitter Incremental Selection" })
-- stylua: ignore end
