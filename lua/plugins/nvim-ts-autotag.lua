-- nvim-ts-autotag: auto close/rename html, xml and jsx tags. Its plugin/ file does nothing on
-- nvim-treesitter main, so setup() is what enables it, on the first buffer of these filetypes.
local pack = require("config.pack")
local filetypes =
  { "html", "xml", "markdown", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" }
pack.lazy({ "windwp/nvim-ts-autotag" }, { ft = filetypes }, function()
  require("nvim-ts-autotag").setup({})
  -- setup() attaches on FileType, which already fired for the buffer that triggered the load
  vim.api.nvim_exec_autocmds("FileType", { group = "nvim_ts_xmltag", buf = vim.api.nvim_get_current_buf() })
end)
