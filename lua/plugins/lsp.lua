-- LSP: diagnostics, per-server settings and buffer keymaps. The servers are listed (and enabled) in
-- lua/config/lsp_servers.lua; base server configs come from nvim-lspconfig's lsp/ files.
local pack = require("config.pack")
pack.add({ "neovim/nvim-lspconfig" })
require("config.lsp_servers")

local icons = require("config.icons")

vim.diagnostic.config({
  virtual_text = { source = "if_many", prefix = "●" },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
    },
  },
  -- every jump (native ]d [d ]D [D, keymaps.lua's ]e [e ]w [w) shows the diagnostic it lands on
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
    end,
  },
})

-- No LSP document colours: ccc.lua is the only colorizer
vim.lsp.document_color.enable(false)

-- All servers: announce file-rename support so <leader>cR (Snacks.rename) can update imports.
vim.lsp.config("*", {
  capabilities = { workspace = { fileOperations = { didRename = true, willRename = true } } },
})

-- nvim-lspconfig already turns lua_ls inlay hints on (without semicolons)
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      completion = { callSnippet = "Replace" },
      doc = { privateName = { "^_" } },
      hint = { paramName = "Disable", arrayIndex = "Disable" },
    },
  },
})

-- ts_ls only returns inlay hints when these preferences are set
local ts_hints = {
  includeInlayParameterNameHints = "literals",
  includeInlayFunctionParameterTypeHints = true,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}
vim.lsp.config("ts_ls", {
  settings = { typescript = { inlayHints = ts_hints }, javascript = { inlayHints = ts_hints } },
})

-- nvim-lspconfig also lists yaml.docker-compose/.gitlab/.helm-values, which nothing sets (:checkhealth warns)
vim.lsp.config("yamlls", { filetypes = { "yaml" } })

-- Buffer-local keymaps for what the attached server supports. Neovim already maps K (hover) and
-- gra/gri/grn/grr/grt (:h lsp-defaults); grr is replaced below by the fzf-lua picker.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end
    local buf = ev.buf
    local function has(method)
      return client:supports_method("textDocument/" .. method, buf)
    end
    local function map(lhs, rhs, desc, mode)
      vim.keymap.set(mode or "n", lhs, rhs, { buf = buf, desc = desc, silent = true })
    end

    -- stylua: ignore start
    map("<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "Lsp Info")
    map("gd", "<cmd>FzfLua lsp_definitions     jump1=true ignore_current_line=true<cr>", "Goto Definition")
    map("grr", "<cmd>FzfLua lsp_references     jump1=true ignore_current_line=true<cr>", "References")
    map("gI", "<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>", "Goto Implementation")
    map("gy", "<cmd>FzfLua lsp_typedefs        jump1=true ignore_current_line=true<cr>", "Goto T[y]pe Definition")
    map("gD", vim.lsp.buf.declaration, "Goto Declaration")
    if has("signatureHelp") then
      map("gK", vim.lsp.buf.signature_help, "Signature Help")
      map("<C-k>", function() -- toggles; stays in Insert mode
        local win = vim.b.lsp_floating_preview
        if win and vim.api.nvim_win_is_valid(win) and vim.w[win]["textDocument/signatureHelp"] then
          return vim.api.nvim_win_close(win, true)
        end
        vim.lsp.buf.signature_help({ focus = false })
      end, "Signature Help", "i")
    end
    if has("codeAction") then
      map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
      map("<leader>cA", function()
        vim.lsp.buf.code_action({ apply = true, context = { only = { "source" }, diagnostics = {} } })
      end, "Source Action")
      map("<leader>co", function()
        vim.lsp.buf.code_action({ apply = true, context = { only = { "source.organizeImports" }, diagnostics = {} } })
      end, "Organize Imports")
    end
    if has("rename") then
      map("<leader>cr", vim.lsp.buf.rename, "Rename")
    end
    if client:supports_method("workspace/willRenameFiles", buf) or client:supports_method("workspace/didRenameFiles", buf) then
      map("<leader>cR", function() Snacks.rename.rename_file() end, "Rename File")
    end
    if has("documentHighlight") then -- snacks.words reference jumps
      map("]]", function() Snacks.words.jump(vim.v.count1) end, "Next Reference")
      map("[[", function() Snacks.words.jump(-vim.v.count1) end, "Prev Reference")
      map("<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, "Next Reference")
      map("<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, "Prev Reference")
    end
    -- stylua: ignore end

    if has("inlayHint") and vim.bo[buf].buftype == "" then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
    end
  end,
})
