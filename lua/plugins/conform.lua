-- conform: format on save and <leader>cf / gq. stylua/shfmt/prettierd come from mason (prettierd runs the
-- project's own prettier when it has one); other filetypes fall back to the LSP. Toggle with <leader>uf (global) / <leader>uF.
local pack = require("config.pack")
pack.add({ "stevearc/conform.nvim" })

local function autoformat_enabled(buf)
  local b = vim.b[buf].autoformat
  if b ~= nil then
    return b
  end
  return vim.g.autoformat ~= false
end

-- prettierd only runs where the project configures prettier (require_cwd below); elsewhere the LSP formats
local web = { "prettierd" }

-- Not formatted on save (like plain Neovim); <leader>cf and gq still format them
local no_save = { sh = true, yaml = true, proto = true }

require("conform").setup({
  default_format_opts = { timeout_ms = 3000, lsp_format = "fallback" },
  notify_no_formatters = false,
  formatters_by_ft = {
    lua = { "stylua" },
    sh = { "shfmt" },
    javascript = web,
    javascriptreact = web,
    typescript = web,
    typescriptreact = web,
    css = web,
    scss = web,
    yaml = web,
  },
  formatters = {
    injected = { options = { ignore_errors = true } },
    prettierd = { require_cwd = true },
    -- Indentation comes from the buffer (lua/config/languages.lua, or a repo's .editorconfig), so typing
    -- and formatting agree. A repo's own stylua.toml wins: no overrides are passed then.
    stylua = {
      prepend_args = function(_, ctx)
        if vim.fs.root(ctx.dirname, { "stylua.toml", ".stylua.toml" }) then
          return {}
        end
        local style = vim.bo[ctx.buf].expandtab and "Spaces" or "Tabs"
        return { "--indent-type", style, "--indent-width", tostring(ctx.shiftwidth) }
      end,
    },
  },
  format_on_save = function(buf)
    if autoformat_enabled(buf) and not no_save[vim.bo[buf].filetype] then
      return {} -- default_format_opts
    end
  end,
})

-- gq formats with conform too (the LSP only sets 'formatexpr' where it is empty)
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

local map = vim.keymap.set
map({ "n", "x" }, "<leader>cf", function()
  require("conform").format()
end, { desc = "Format" })
map({ "n", "x" }, "<leader>cF", function()
  require("conform").format({ formatters = { "injected" } })
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
