-- outline: symbols sidebar (<leader>o / :Outline). Loaded on first use.
local pack = require("config.pack")
pack.lazy({ "hedyhli/outline.nvim" }, { cmd = { "Outline", "OutlineOpen" } }, function()
  require("outline").setup({
    -- Your setup opts here
  })
end)

vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle outline" })
