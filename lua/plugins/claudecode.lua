return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  keys = {
    { "<leader>ci", nil, desc = "AI/Claude Code" },
    { "<leader>cic", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    -- { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    -- { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    -- { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    -- { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    -- { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>cis", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>ci",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
    },
    -- Diff management
    { "<leader>cia", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>cid", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
