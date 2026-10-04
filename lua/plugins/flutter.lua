-- flutter-tools: Flutter/Dart tooling, loaded on the first dart buffer (the dart/flutter SDKs
-- are not installed everywhere). vim.ui.select/input come from fzf-lua and snacks.
local pack = require("config.pack")
pack.add({ "nvim-lua/plenary.nvim" })
pack.lazy({ "nvim-flutter/flutter-tools.nvim" }, { ft = "dart" }, function()
  require("flutter-tools").setup({})
  -- flutter-tools starts on BufEnter, which already fired for the buffer that triggered the load
  -- (its ftplugin, which attaches the LSP, is sourced for that buffer by pack.lazy)
  vim.api.nvim_exec_autocmds("BufEnter", { group = "FlutterToolsGroup", buf = vim.api.nvim_get_current_buf() })
end)
