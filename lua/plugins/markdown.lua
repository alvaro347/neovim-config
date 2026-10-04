-- render-markdown: inline markdown rendering, off until :RenderMarkdown toggle. Needs nvim-treesitter
-- (plugins/treesitter.lua) and mini.icons. Its plugin/ file runs setup() with this table on load, so
-- the file opened at startup is not concealed either; latex is off (no latex parser/converter here).
vim.g.render_markdown_config = { enabled = false, latex = { enabled = false } }
local pack = require("config.pack")
pack.add({ "nvim-mini/mini.nvim", "MeanderingProgrammer/render-markdown.nvim" })
