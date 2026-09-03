-- conform: formatting (format on save, <leader>cf). Formatters come from mason (stylua, shfmt)
-- or fall back to the LSP. Toggle autoformat with <leader>uf (global) / <leader>uF (buffer).
local pack = require("config.pack")
pack.add({ "stevearc/conform.nvim" })

local function autoformat_enabled(buf)
  local b = vim.b[buf].autoformat
  if b ~= nil then
    return b
  end
  return vim.g.autoformat ~= false
end

require("conform").setup({
  default_format_opts = {
    timeout_ms = 3000,
    async = false, -- not recommended to change
    quiet = false, -- not recommended to change
    lsp_format = "fallback", -- not recommended to change
  },
  formatters_by_ft = {
    lua = { "stylua" },
    fish = { "fish_indent" },
    sh = { "shfmt" },
  },
  -- The options you set here will be merged with the builtin formatters.
  -- You can also define any custom formatters here.
  formatters = {
    injected = { options = { ignore_errors = true } },
    -- # Example of using shfmt with extra args
    -- shfmt = {
    --   prepend_args = { "-i", "2", "-ci" },
    -- },
  },
  format_on_save = function(buf)
    if not autoformat_enabled(buf) then
      return
    end
    return {} -- use default_format_opts
  end,
})

local map = vim.keymap.set
map({ "n", "x" }, "<leader>cf", function()
  require("conform").format()
end, { desc = "Format" })
map({ "n", "x" }, "<leader>cF", function()
  require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
end, { desc = "Format Injected Langs" })

Snacks.toggle({
  name = "Auto Format (Global)",
  get = function()
    return vim.g.autoformat ~= false
  end,
  set = function(state)
    vim.g.autoformat = state
  end,
}):map("<leader>uf")
Snacks.toggle({
  name = "Auto Format (Buffer)",
  get = function()
    return autoformat_enabled(0)
  end,
  set = function(state)
    vim.b.autoformat = state
  end,
}):map("<leader>uF")
