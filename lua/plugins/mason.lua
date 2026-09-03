-- mason: installs LSP servers and tools into ~/.local/share/nvim/mason (:Mason).
-- mason-lspconfig enables every installed server through vim.lsp.enable().
local pack = require("config.pack")
pack.add({ "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim", "neovim/nvim-lspconfig" })

require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {},
  -- enable every installed server, except tools that only masquerade as one
  automatic_enable = {
    exclude = { "stylua" }, -- stylua is a formatter (used by conform), not an LSP
  },
})

vim.keymap.set("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason" })

-- Non-LSP tools that should always be installed (used by conform.nvim)
local ensure_installed = { "stylua", "shfmt" }
pack.later(function()
  local mr = require("mason-registry")
  mr.refresh(function()
    for _, tool in ipairs(ensure_installed) do
      local ok, p = pcall(mr.get_package, tool)
      if ok and not p:is_installed() then
        p:install()
      end
    end
  end)
end)
