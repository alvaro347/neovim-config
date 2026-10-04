-- todo-comments: highlight and search TODO/FIX/HACK/... comments (]t/[t, <leader>st, <leader>xt).
local pack = require("config.pack")
pack.add({ "nvim-lua/plenary.nvim", "folke/todo-comments.nvim" })

-- The full keyword list (merge_keywords = false): every alias belongs to exactly one keyword, or
-- it would resolve to a random one per session. FIX covers ERROR; INFO is its own (blue) keyword.
pack.later(function()
  require("todo-comments").setup({
    merge_keywords = false,
    keywords = {
      FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "ERROR" } },
      TODO = { icon = " ", color = "info" },
      HACK = { icon = " ", color = "warning" },
      WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
      PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      NOTE = { icon = " ", color = "hint", alt = { "HINT" } },
      TEST = { icon = "⏲ ", color = "default", alt = { "TESTING", "PASSED", "FAILED" } },
      INFO = { icon = " ", color = "info" },
    },
    highlight = { multiline = false },
    -- fixed colours instead of the theme's Diagnostic* groups
    colors = {
      error = "#DC2626",
      warning = "#FBBF24",
      info = "#2563EB",
      hint = "#10B981",
      default = "#7C3AED",
      test = "#FF00FF",
    },
  })
end)

-- <leader>xT / <leader>sT: TODO + the FIX family. Trouble filters on the resolved keyword (FIX),
-- the fzf search needs the literal words.
local todo_fix = { "TODO", "FIX", "FIXME", "BUG", "FIXIT", "ISSUE", "ERROR" }
local map = vim.keymap.set
-- stylua: ignore start
map("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next Todo Comment" })
map("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous Todo Comment" })
map("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "Todo (Trouble)" })
map("n", "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX}}<cr>", { desc = "Todo/Fix/Fixme (Trouble)" })
map("n", "<leader>st", function() require("todo-comments.fzf").todo() end, { desc = "Todo" })
map("n", "<leader>sT", function() require("todo-comments.fzf").todo({ keywords = todo_fix }) end, { desc = "Todo/Fix/Fixme" })
-- stylua: ignore end
