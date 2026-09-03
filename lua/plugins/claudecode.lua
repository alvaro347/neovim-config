-- claudecode: Claude Code integration (<leader>ci*). Loaded on first command/keymap so the
-- websocket server only starts when used.
local pack = require("config.pack")
pack.add({ "folke/snacks.nvim" }) -- dependency
pack.lazy({ "coder/claudecode.nvim" }, {
  cmd = {
    "ClaudeCode",
    "ClaudeCodeAdd",
    "ClaudeCodeClose",
    "ClaudeCodeCloseAllDiffs",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
    "ClaudeCodeFocus",
    "ClaudeCodeOpen",
    "ClaudeCodeSelectModel",
    "ClaudeCodeSend",
    "ClaudeCodeSendText",
    "ClaudeCodeStart",
    "ClaudeCodeStatus",
    "ClaudeCodeStop",
    "ClaudeCodeTreeAdd",
  },
}, function()
  require("claudecode").setup({})
end)

local map = vim.keymap.set
map("n", "<leader>cic", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
-- map("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
-- map("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" })
-- map("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude" })
-- map("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Select Claude model" })
-- map("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer" })
map("v", "<leader>cis", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
-- Diff management
map("n", "<leader>cia", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
map("n", "<leader>cid", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })

-- In file explorers <leader>ci adds the file under the cursor
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_claudecode_tree", { clear = true }),
  pattern = { "NvimTree", "neo-tree", "oil", "minifiles" },
  callback = function(ev)
    vim.keymap.set("n", "<leader>ci", "<cmd>ClaudeCodeTreeAdd<cr>", { buffer = ev.buf, desc = "Add file" })
  end,
})
