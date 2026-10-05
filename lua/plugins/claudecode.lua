-- claudecode: Claude Code integration (<leader>ci*). Loaded on first command/keymap so the
-- websocket server only starts when used.
local pack = require("config.pack")
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
  -- static completion: loading claudecode while typing `:ClaudeCode ` would start its websocket server
  complete = { ClaudeCodeAdd = "file" },
}, function()
  require("claudecode").setup({})
end)

local map = vim.keymap.set
map("n", "<leader>cic", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
map("x", "<leader>cis", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
map("n", "<leader>cia", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
map("n", "<leader>cid", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })

-- In neo-tree <leader>cI adds the file under the cursor
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_claudecode_tree", { clear = true }),
  pattern = "neo-tree",
  callback = function(ev)
    vim.keymap.set("n", "<leader>cI", "<cmd>ClaudeCodeTreeAdd<cr>", { buf = ev.buf, desc = "Add file" })
  end,
})
