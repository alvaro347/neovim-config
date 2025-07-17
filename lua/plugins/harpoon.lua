return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
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
    end,
    keys = {
      { "<leader>A", desc = "Harpoon: add file" },
      { "<leader>a", desc = "Harpoon: quick menu" },
      { "<leader>1", desc = "Harpoon: go to file 1" },
      { "<leader>2", desc = "Harpoon: go to file 2" },
      { "<leader>3", desc = "Harpoon: go to file 3" },
      { "<leader>4", desc = "Harpoon: go to file 4" },
      { "<leader>5", desc = "Harpoon: go to file 5" },
    },
  },
}
