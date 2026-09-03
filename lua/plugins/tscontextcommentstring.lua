-- nvim-ts-context-commentstring: correct commentstring inside embedded languages (jsx, vue, ...).
-- Used by mini.comment (plugins/minicomment.lua).
vim.g.skip_ts_context_commentstring_module = true

local pack = require("config.pack")
pack.add({ "JoosepAlviste/nvim-ts-context-commentstring" })

pack.later(function()
  require("ts_context_commentstring").setup({
    enable_autocmd = false,
  })
end)
