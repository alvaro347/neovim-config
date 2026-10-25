-- todo-comments: highlight and search TODO/FIX/HACK/... comments (]t/[t, <leader>st, <leader>xt).
local pack = require("config.pack")
pack.add({ "nvim-lua/plenary.nvim", "folke/todo-comments.nvim" })

pack.later(function()
  require("todo-comments").setup({})
end)

-- <leader>xT / <leader>sT: TODO + the FIX family (FIX's default aliases). Trouble filters on the resolved
-- keyword (FIX), the fzf search needs the literal words.
local todo_fix = { "TODO", "FIX", "FIXME", "BUG", "FIXIT", "ISSUE" }
local map = vim.keymap.set
-- stylua: ignore start
map("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next Todo Comment" })
map("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous Todo Comment" })
map("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "Todo (Trouble)" })
map("n", "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX}}<cr>", { desc = "Todo/Fix/Fixme (Trouble)" })
map("n", "<leader>st", function() require("todo-comments.fzf").todo() end, { desc = "Todo" })
map("n", "<leader>sT", function() require("todo-comments.fzf").todo({ keywords = todo_fix }) end, { desc = "Todo/Fix/Fixme" })
-- stylua: ignore end
