-- ts-comments: better commentstring per treesitter language (e.g. jsx, lua nested comments).
local pack = require("config.pack")
pack.add({ "folke/ts-comments.nvim" })

pack.later(function()
  require("ts-comments").setup({})
end)
