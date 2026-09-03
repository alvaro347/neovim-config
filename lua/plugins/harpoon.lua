-- harpoon2: quick file marks (<leader>a menu, <leader>A add, <leader>1..5 jump).
local pack = require("config.pack")
pack.add({
  "nvim-lua/plenary.nvim",
  { "ThePrimeagen/harpoon", version = "harpoon2" },
})

local harpoon = require("harpoon")
harpoon:setup({}) -- initialize with defaults

-- Helper to simplify key mapping
local function map(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end

-- Add current file to Harpoon list
map("<leader>A", function()
  harpoon:list():add()
end, "Harpoon: add file")

-- Toggle the quick‐menu
map("<leader>a", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, "Harpoon: quick menu")

-- Jump to specific files
for i = 1, 5 do
  map("<leader>" .. i, function()
    harpoon:list():select(i)
  end, "Harpoon: go to file " .. i)
end
