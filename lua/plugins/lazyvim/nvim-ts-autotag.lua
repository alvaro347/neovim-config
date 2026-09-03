-- nvim-ts-autotag: auto close/rename html/jsx tags.
local pack = require("config.pack")
pack.add({ "windwp/nvim-ts-autotag" })

pack.later(function()
  require("nvim-ts-autotag").setup({})
end)
