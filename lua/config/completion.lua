-- Native completion (Neovim 0.12):
--   LSP buffers    vim.lsp.completion: the menu opens while typing a word and on the servers' trigger
--                  characters, docs come from "completionItem/resolve" in the 'completeopt' popup, accepted
--                  snippets expand with vim.snippet (<Tab>/<S-Tab> jump: Neovim's default maps)
--   other buffers  'autocomplete': words from this buffer, other windows and listed buffers
-- Keys: <C-Space> complete, <CR> accepts the selected item (else mini.pairs' <CR>), <C-y> accepts the selected or
-- the first item, <C-n>/<C-p> insert and <Up>/<Down> select an item, <C-e> cancels, <C-x><C-f> file names.
-- Signature help: <C-k> (plugins/lsp.lua). No automatic menu where vim.b.completion = false (snacks bigfile,
-- Snacks.input), in prompt buffers or in macros.
local kinds = require("config.icons").kinds

local group = vim.api.nvim_create_augroup("user_completion", { clear = true })
local map = vim.keymap.set

vim.o.autocomplete = true -- set per buffer on InsertEnter, see below
vim.o.complete = ".,w,b"
vim.o.completeopt = "menuone,noselect,popup,fuzzy"
vim.o.completeitemalign = "kind,abbr,menu" -- kind icon first
vim.o.pumborder = vim.o.winborder
vim.o.pummaxwidth = 80

-- yamlls completes nothing without a schema: words there
local words_first = { yaml = true }

---@param buf integer
local function lsp_completes(buf)
  return not words_first[vim.bo[buf].filetype]
    and #vim.lsp.get_clients({ bufnr = buf, method = "textDocument/completion" }) > 0
end

---@param buf integer
local function paused(buf)
  return vim.b[buf].completion == false or vim.fn.reg_recording() ~= "" or vim.fn.reg_executing() ~= ""
end

-- 'autocomplete' only where no server fills the menu (both at once block each other), never in prompt buffers
vim.api.nvim_create_autocmd("InsertEnter", {
  group = group,
  callback = function(ev)
    vim.bo[ev.buf].autocomplete = vim.go.autocomplete
      and not paused(ev.buf)
      and vim.bo[ev.buf].buftype ~= "prompt"
      and not lsp_completes(ev.buf)
  end,
})

-- Menu columns: kind icon (coloured like mini.icons' LSP icons), label, labelDetails.description
---@param item lsp.CompletionItem
local function convert(item)
  local kind = vim.lsp.protocol.CompletionItemKind[item.kind]
  local fields = { menu = vim.tbl_get(item, "labelDetails", "description") or "" }
  if kind and kind ~= "Color" then -- colour items keep Neovim's swatch
    fields.kind = vim.trim(kinds[kind] or kind)
    fields.kind_hlgroup = _G.MiniIcons and select(2, MiniIcons.get("lsp", kind))
  end
  return fields
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local buf, client = ev.buf, vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or not client:supports_method("textDocument/completion", buf) then
      return
    end
    -- whitespace never opens the menu (lua_ls lists " ", "\t" and "\n")
    local provider = client.server_capabilities.completionProvider
    if type(provider) == "table" then
      provider.triggerCharacters = vim.tbl_filter(function(c)
        return not c:find("^%s$")
      end, provider.triggerCharacters or {})
    end
    -- autotrigger: the servers' trigger characters, and refreshing incomplete lists while typing
    vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true, convert = convert })
    if lsp_completes(buf) then
      vim.bo[buf].autocomplete = false -- also when the server attaches during an Insert session
    end
    if #vim.api.nvim_get_autocmds({ group = group, buf = buf, event = "InsertCharPre" }) > 0 then
      return -- once per buffer
    end
    -- autotrigger only knows trigger characters (:h lsp-autocompletion): ask on every keyword character too.
    -- state("m"): not while more typed keys are pending, only for the last of them.
    vim.api.nvim_create_autocmd("InsertCharPre", {
      group = group,
      buf = buf,
      callback = function()
        if
          vim.fn.pumvisible() == 0
          and vim.fn.state("m") == ""
          and vim.fn.match(vim.v.char, [[\k]]) == 0
          and not paused(buf)
          and lsp_completes(buf)
        then
          vim.schedule(vim.lsp.completion.get)
        end
      end,
    })
  end,
})

-- <CR>: accept the selected item (with its edits and snippet, like <C-y>), else mini.pairs' <CR>
map("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= -1 then
    return vim.keycode("<C-y>")
  end
  return _G.MiniPairs and MiniPairs.cr() or vim.keycode("<CR>")
end, { expr = true, replace_keycodes = false, desc = "Accept Completion / New Line" })

-- <C-y>: accept the selected item, or the first one when none is
map("i", "<C-y>", function()
  local none = vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected == -1
  return none and "<C-n><C-y>" or "<C-y>"
end, { expr = true, desc = "Accept Completion" })

-- <C-Space>: open the menu: the servers', else words (the native <C-n>)
map("i", "<C-Space>", function()
  if vim.fn.pumvisible() == 1 then
    return ""
  end
  return lsp_completes(vim.api.nvim_get_current_buf()) and "<Cmd>lua vim.lsp.completion.get()<CR>" or "<C-n>"
end, { expr = true, desc = "Complete" })
