-- persistence: automatic session save/restore per directory (<leader>qs/qS/ql/qd, dashboard "s").
local pack = require("config.pack")
pack.add({ "folke/persistence.nvim" })

pack.later(function()
  require("persistence").setup({})
end)

local map = vim.keymap.set
-- stylua: ignore start
map("n", "<leader>qs", function() require("persistence").load() end, { desc = "Restore Session" })
map("n", "<leader>qS", function() require("persistence").select() end, { desc = "Select Session" })
map("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Restore Last Session" })
map("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Don't Save Current Session" })
-- stylua: ignore end
