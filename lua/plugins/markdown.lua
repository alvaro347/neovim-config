-- render-markdown: inline markdown rendering, loaded on the first :RenderMarkdown (a bare one turns it on).
-- Needs nvim-treesitter (plugins/treesitter.lua) and mini.icons. Its plugin/ file runs setup() with this
-- table on load; latex is off (no latex parser/converter here).
vim.g.render_markdown_config = { enabled = false, latex = { enabled = false } }
local pack = require("config.pack")
pack.lazy({ "MeanderingProgrammer/render-markdown.nvim" }, { cmd = "RenderMarkdown" }, function()
  -- its plugin/ file attaches only the current buffer: attach the markdown buffers opened before too
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      vim.api.nvim_exec_autocmds("FileType", { group = "RenderMarkdown", buffer = buf })
    end
  end
end)
