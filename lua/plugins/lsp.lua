-- LSP: nvim-lspconfig server definitions + diagnostics + buffer keymaps.
-- Servers are installed with mason (lua/plugins/mason.lua) and enabled by mason-lspconfig.
local pack = require("config.pack")
pack.add({ "neovim/nvim-lspconfig" })

local icons = require("config.icons")

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●",
  },
  virtual_lines = false,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
    },
  },
})

-- Base config for every server. blink.cmp merges its completion capabilities on top
-- (see blink.cmp/plugin/blink-cmp.lua).
vim.lsp.config("*", {
  capabilities = {
    workspace = {
      fileOperations = { didRename = true, willRename = true },
    },
  },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      codeLens = { enable = true },
      completion = { callSnippet = "Replace" },
      doc = { privateName = { "^_" } },
      hint = {
        enable = true,
        setType = false,
        paramType = true,
        paramName = "Disable",
        semicolon = "Disable",
        arrayIndex = "Disable",
      },
    },
  },
})

-- Buffer-local keymaps, only for what the attached server supports
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
    local function map(lhs, rhs, desc, mode, extra)
      vim.keymap.set(
        mode or "n",
        lhs,
        rhs,
        vim.tbl_extend("force", { buffer = buf, desc = desc, silent = true }, extra or {})
      )
    end

    -- stylua: ignore start
    map("<leader>cl", function() Snacks.picker.lsp_config() end, "Lsp Info")
    map("gd", "<cmd>FzfLua lsp_definitions     jump1=true ignore_current_line=true<cr>", "Goto Definition")
    map("gr", "<cmd>FzfLua lsp_references      jump1=true ignore_current_line=true<cr>", "References", "n", { nowait = true })
    map("gI", "<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>", "Goto Implementation")
    map("gy", "<cmd>FzfLua lsp_typedefs        jump1=true ignore_current_line=true<cr>", "Goto T[y]pe Definition")
    map("gD", vim.lsp.buf.declaration, "Goto Declaration")
    map("K", function() return vim.lsp.buf.hover() end, "Hover")
    if has("signatureHelp") then
      map("gK", function() return vim.lsp.buf.signature_help() end, "Signature Help")
      map("<c-k>", function() return vim.lsp.buf.signature_help() end, "Signature Help", "i")
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
    if has("documentHighlight") then
      map("]]", function() Snacks.words.jump(vim.v.count1) end, "Next Reference")
      map("[[", function() Snacks.words.jump(-vim.v.count1) end, "Prev Reference")
      map("<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, "Next Reference")
      map("<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, "Prev Reference")
    end
    -- stylua: ignore end

    -- inlay hints
    if has("inlayHint") and vim.bo[buf].buftype == "" then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
    end
  end,
})
