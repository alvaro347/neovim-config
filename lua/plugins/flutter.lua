-- flutter-tools: Flutter/Dart tooling, loaded on the first dart buffer (the dart/flutter SDKs
-- are not installed everywhere). vim.ui.select/input come from fzf-lua and snacks.
local pack = require("config.pack")
pack.add({ "nvim-lua/plenary.nvim" })
pack.lazy({ "nvim-flutter/flutter-tools.nvim" }, { ft = "dart" }, function()
  require("flutter-tools").setup({})
  -- BufEnter (starts flutter-tools) and FileType (its ftplugin/dart/, which attaches the LSP) already ran
  -- without the plugin for the buffer that triggered the load: run them again for it
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_exec_autocmds("BufEnter", { group = "FlutterToolsGroup", buf = buf })
  if vim.bo[buf].filetype == "dart" then
    vim.cmd.doautocmd({ "filetypeplugin", "FileType", "dart" })
  end
end)

local map = vim.keymap.set

map("n", "<leader>fuh", "<cmd>FlutterReload<CR>", { desc = "Flutter Hot Reload" })
map("n", "<leader>fuR", "<cmd>FlutterRun -d winddows<CR>", { desc = "Flutter Run" })
map("n", "<leader>ful", "<cmd>FlutterLogToggle<CR>", { desc = "Flutter Log Toggle" })
map("n", "<leader>fur", "<cmd>FlutterRestart<CR>", { desc = "Flutter Hot Restart" })
map("n", "<leader>fuq", "<cmd>FlutterQuit<CR>", { desc = "Flutter Quit" })
map("n", "<leader>fud", "<cmd>FlutterOpenDevTools<CR>", { desc = "Flutter Dev Tools" })
map("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Flutter/LSP Code Action" })
