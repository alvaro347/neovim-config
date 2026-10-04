-- grug-far: search and replace across files (<leader>sr, :GrugFar). Loaded on first use.
local pack = require("config.pack")
pack.lazy({ "MagicDuck/grug-far.nvim" }, { cmd = { "GrugFar", "GrugFarWithin" } })

vim.keymap.set({ "n", "x" }, "<leader>sr", function()
  pack.load("grug-far.nvim")
  local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  require("grug-far").open({
    transient = true,
    prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
  })
end, { desc = "Search and Replace" })
