-- grug-far: search and replace across files (<leader>sr, :GrugFar). Loaded on first use.
local pack = require("config.pack")
pack.lazy({ "MagicDuck/grug-far.nvim" }, { cmd = { "GrugFar", "GrugFarWithin" } }, function()
  require("grug-far").setup({ headerMaxWidth = 80 })
end)

vim.keymap.set({ "n", "x" }, "<leader>sr", function()
  pack.load("grug-far.nvim")
  local grug = require("grug-far")
  local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  grug.open({
    transient = true,
    prefills = {
      filesFilter = ext and ext ~= "" and "*." .. ext or nil,
    },
  })
end, { desc = "Search and Replace" })
