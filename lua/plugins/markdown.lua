-- render-markdown: inline markdown rendering, off until <leader>um or :RenderMarkdown (a bare one turns it
-- on), which also load it. Needs nvim-treesitter (plugins/treesitter.lua) and mini.icons. Its plugin/ file
-- runs setup() with this table on load; latex is off (no latex parser/converter here).
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

Snacks.toggle({
  name = "Render Markdown",
  get = function()
    return package.loaded["render-markdown"] ~= nil and require("render-markdown").get()
  end,
  set = function(state)
    pack.load("render-markdown.nvim")
    require("render-markdown").set(state)
  end,
}):map("<leader>um")
