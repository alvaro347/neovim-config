-- render-markdown: inline markdown rendering. Installed but disabled (enabled = false);
-- toggle with :RenderMarkdown toggle. Needs nvim-treesitter (plugins/treesitter.lua) and mini.icons.
local pack = require("config.pack")
pack.add({ "nvim-mini/mini.nvim", "MeanderingProgrammer/render-markdown.nvim" })

pack.later(function()
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  require("render-markdown").setup({
    enabled = false,
  })
end)
