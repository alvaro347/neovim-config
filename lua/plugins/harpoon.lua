-- harpoon2: quick file marks (<leader>a menu, <leader>A add, <leader>1..5 jump).
-- Set up on the first key: require("harpoon") writes a data file for the cwd.
local pack = require("config.pack")
pack.add({
  "nvim-lua/plenary.nvim",
  { "ThePrimeagen/harpoon", version = "harpoon2" },
})

local h
local function harpoon()
  if not h then
    h = require("harpoon")
    h:setup({})
  end
  return h
end

local map = vim.keymap.set
-- stylua: ignore start
map("n", "<leader>A", function() harpoon():list():add() end, { desc = "Harpoon: add file" })
map("n", "<leader>a", function() harpoon().ui:toggle_quick_menu(harpoon():list()) end, { desc = "Harpoon: quick menu" })
for i = 1, 5 do
  map("n", "<leader>" .. i, function() harpoon():list():select(i) end, { desc = "Harpoon: go to file " .. i })
end
-- stylua: ignore end
