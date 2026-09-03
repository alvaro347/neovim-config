-- lazydev: lua_ls completion/types for your Neovim config and plugins. Loaded for lua files.
local pack = require("config.pack")
pack.lazy({ "folke/lazydev.nvim" }, { ft = "lua", cmd = "LazyDev" }, function()
  require("lazydev").setup({
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "snacks.nvim", words = { "Snacks" } },
      { path = "nvim-lspconfig", words = { "lspconfig.settings" } },
    },
  })

  -- completion source for blink.cmp (plugins/blink.lua), shown above LSP results
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    blink.add_source_provider("lazydev", {
      name = "LazyDev",
      module = "lazydev.integrations.blink",
      score_offset = 100,
    })
    blink.add_filetype_source("lua", "lazydev")
  end
end)
