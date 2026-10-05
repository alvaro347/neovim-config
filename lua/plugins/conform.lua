-- conform: formats on save and with <leader>cf; the only thing that formats on save. Per buffer it runs the
-- formatters below or, when none is available, the LSP server's formatting (e.g. dartls via flutter-tools).
-- Project config wins: prettierd only where the project configures prettier, stylua uses a repo's
-- stylua.toml, dartls takes the line width from analysis_options.yaml (formatter: page_width, else 80).
-- stylua/shfmt/prettierd come from mason. Indentation per language: lua/config/languages.lua.
local pack = require("config.pack")
pack.add({ "stevearc/conform.nvim" })

-- Per-language formatting ------------------------------------------------------------------------------

-- prettierd only where the project configures prettier (require_cwd below); elsewhere the LSP formats
local web = { "prettierd" }

local formatters_by_ft = {
  lua = { "stylua" },
  sh = { "shfmt" },
  css = web,
  html = web,
  javascript = web,
  javascriptreact = web,
  json = web,
  jsonc = web,
  less = web,
  markdown = web,
  scss = web,
  typescript = web,
  typescriptreact = web,
  yaml = web,
}
-- dart: no entry; dartls (started by flutter-tools) formats it through the LSP fallback

-- Not formatted on save unless <leader>uF turns it on for the buffer; <leader>cf still formats them
local no_save = { sh = true, yaml = true, proto = true }

-- conform ----------------------------------------------------------------------------------------------

-- Format on save is on by default. <leader>uf turns it off everywhere for this session and wins over
-- <leader>uF, which shows and flips only the buffer's own setting.
local function buffer_enabled(buf)
  local b = vim.b[buf].autoformat
  if b == nil then
    return not no_save[vim.bo[buf].filetype]
  end
  return b
end

require("conform").setup({
  default_format_opts = { timeout_ms = 3000, lsp_format = "fallback" },
  notify_no_formatters = false,
  formatters_by_ft = formatters_by_ft,
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
    if vim.g.autoformat ~= false and buffer_enabled(buf) then
      return {} -- default_format_opts
    end
  end,
})

-- gq: conform's where it has a formatter for the file; elsewhere Neovim's default (the LSP's gq, or plain
-- text formatting). Decided when the file opens: after adding a .prettierrc, :e the file.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_conform_gq", { clear = true }),
  pattern = vim.tbl_keys(formatters_by_ft),
  callback = function(ev)
    if #require("conform").list_formatters(ev.buf) > 0 then
      vim.bo[ev.buf].formatexpr = "v:lua.require'conform'.formatexpr()"
    end
  end,
})

local map = vim.keymap.set
map({ "n", "x" }, "<leader>cf", function()
  require("conform").format()
end, { desc = "Format" })
map({ "n", "x" }, "<leader>cF", function()
  -- never falls back to LSP-formatting the whole buffer (injected needs a treesitter parser)
  require("conform").format({ formatters = { "injected" }, lsp_format = "never" })
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
    return buffer_enabled(0)
  end,
  set = function(state)
    vim.b.autoformat = state
  end,
}):map("<leader>uF")
