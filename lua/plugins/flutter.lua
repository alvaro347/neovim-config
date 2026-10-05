-- flutter-tools: Flutter/Dart tooling, loaded on the first dart buffer (the dart/flutter SDKs
-- are not installed everywhere). vim.ui.select/input come from fzf-lua and snacks.
local pack = require("config.pack")
pack.add({ "nvim-lua/plenary.nvim" })
pack.lazy({ "nvim-flutter/flutter-tools.nvim" }, { ft = "dart" }, function()
  -- dartls formats dart on save (conform's LSP fallback). Its line width, used when the repo's
  -- analysis_options.yaml sets no formatter page_width: very wide, so long lines are never split.
  -- dart format still joins code that fits (Dart 3.7+ also drops trailing commas).
  require("flutter-tools").setup({ lsp = { settings = { lineLength = 1000 } } })
  -- BufEnter (starts flutter-tools) and FileType (its ftplugin/dart/, which attaches the LSP) already ran
  -- without the plugin for the buffer that triggered the load: run them again for it
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_exec_autocmds("BufEnter", { group = "FlutterToolsGroup", buf = buf })
  if vim.bo[buf].filetype == "dart" then
    vim.cmd.doautocmd({ "filetypeplugin", "FileType", "dart" })
  end
end)
