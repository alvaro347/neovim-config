-- fzf-lua: the picker (files, grep, buffers, LSP symbols, git, ...) and vim.ui.select.
-- Pickers rooted at the project root use require("config.util").pick; <leader>fF etc. use the cwd.
local pack = require("config.pack")
pack.add({ "ibhagwan/fzf-lua" })

local util = require("config.util")
local pick = util.pick

-- LSP symbol kinds shown by <leader>ss / <leader>sS; false shows every kind
local kinds = {
  "Class",
  "Constructor",
  "Enum",
  "Field",
  "Function",
  "Interface",
  "Method",
  "Module",
  "Namespace",
  "Package",
  "Property",
  "Struct",
  "Trait",
}
local kind_filter = {
  markdown = false,
  help = false,
  -- lua_ls uses Package for control flow structures
  lua = vim.tbl_filter(function(k)
    return k ~= "Package"
  end, kinds),
}
local function symbols_filter(entry, ctx)
  if ctx.symbols_filter == nil then
    local f = kind_filter[vim.bo[ctx.bufnr].filetype]
    ctx.symbols_filter = f == nil and kinds or f
  end
  return ctx.symbols_filter == false or vim.tbl_contains(ctx.symbols_filter, entry.kind)
end

local fzf = require("fzf-lua")
local config = fzf.config
local actions = fzf.actions

-- <c-q> all to quickfix, <c-u>/<c-d> half page, <c-x> jump labels, <c-f>/<c-b> scroll the preview
config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
config.defaults.keymap.fzf["ctrl-x"] = "jump"
config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"

-- <c-t> sends the results to a Trouble list (needs trouble.lua loaded and set up first)
if pcall(require, "plugins.trouble") then
  config.defaults.actions.files["ctrl-t"] = require("trouble.sources.fzf").actions.open
end

-- <c-r> / <a-c> toggle between the project root and the cwd
config.defaults.actions.files["ctrl-r"] = function(_, ctx)
  local o = vim.deepcopy(ctx.__call_opts)
  o.root = o.root == false
  o.cwd = nil
  o.buf = ctx.__CTX.bufnr
  util.pick_open(ctx.__INFO.cmd, o)
end
config.defaults.actions.files["alt-c"] = config.defaults.actions.files["ctrl-r"]
config.set_action_helpstr(config.defaults.actions.files["ctrl-r"], "toggle-root-dir")

-- vim.ui.select: prompt as the title, sized to the items; code actions get a diff preview below
local function ui_select(fzf_opts, items)
  return vim.tbl_deep_extend("force", fzf_opts, {
    prompt = " ",
    winopts = { title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " " },
  }, fzf_opts.kind == "codeaction" and {
    winopts = {
      -- items plus 15 lines of preview, at most 80% of the screen
      height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 4) + 0.5) + 16,
      width = 0.5,
      preview = { layout = "vertical", vertical = "down:15,border-top" },
    },
  } or {
    winopts = {
      width = 0.5,
      -- number of items, at most 80% of the screen
      height = math.floor(math.min(vim.o.lines * 0.8, #items + 4) + 0.5),
    },
  })
end

-- fzf-lua's "default" profile (titles, fused borders, <Esc> hides for :FzfLua resume) sits underneath
fzf.setup({
  fzf_colors = true,
  fzf_opts = { ["--no-scrollbar"] = true },
  defaults = { formatter = "path.dirname_first" },
  winopts = { height = 0.8, row = 0.5, col = 0.5 },
  -- alt-i/alt-h are fzf-lua defaults too; listing them here shows them in the picker header
  files = {
    cwd_prompt = false,
    actions = { ["alt-i"] = { actions.toggle_ignore }, ["alt-h"] = { actions.toggle_hidden } },
  },
  grep = { actions = { ["alt-i"] = { actions.toggle_ignore }, ["alt-h"] = { actions.toggle_hidden } } },
  lsp = {
    symbols = {
      symbol_hl = function(s)
        return "TroubleIcon" .. s
      end,
      symbol_fmt = function(s)
        return s:lower() .. "\t"
      end,
      child_prefix = false,
    },
  },
})
fzf.register_ui_select(ui_select)

local map = vim.keymap.set
-- stylua: ignore start
map("n", "<leader>,", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", { desc = "Switch Buffer" })
map("n", "<leader>/", pick("live_grep"), { desc = "Grep (Root Dir)" })
map("n", "<leader>:", "<cmd>FzfLua command_history<cr>", { desc = "Command History" })
map("n", "<leader><space>", pick("files"), { desc = "Find Files (Root Dir)" })
-- find
map("n", "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", { desc = "Buffers" })
map("n", "<leader>fB", "<cmd>FzfLua buffers<cr>", { desc = "Buffers (all)" })
map("n", "<leader>fc", pick("files", { cwd = vim.fn.stdpath("config") }), { desc = "Find Config File" })
map("n", "<leader>ff", pick("files"), { desc = "Find Files (Root Dir)" })
map("n", "<leader>fF", pick("files", { root = false }), { desc = "Find Files (cwd)" })
map("n", "<leader>fg", "<cmd>FzfLua git_files<cr>", { desc = "Find Files (git-files)" })
map("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Recent" })
map("n", "<leader>fR", pick("oldfiles", { root = false, cwd_only = true }), { desc = "Recent (cwd)" })
-- git
map("n", "<leader>gc", "<cmd>FzfLua git_commits<CR>", { desc = "Commits" })
map("n", "<leader>gd", "<cmd>FzfLua git_diff<cr>", { desc = "Git Diff (files)" })
map("n", "<leader>gl", "<cmd>FzfLua git_commits<CR>", { desc = "Commits" })
map("n", "<leader>gs", "<cmd>FzfLua git_status<CR>", { desc = "Status" })
map("n", "<leader>gS", "<cmd>FzfLua git_stash<cr>", { desc = "Git Stash" })
-- search
map("n", '<leader>s"', "<cmd>FzfLua registers<cr>", { desc = "Registers" })
map("n", "<leader>s/", "<cmd>FzfLua search_history<cr>", { desc = "Search History" })
map("n", "<leader>sa", "<cmd>FzfLua autocmds<cr>", { desc = "Auto Commands" })
map("n", "<leader>sb", "<cmd>FzfLua lines<cr>", { desc = "Buffer Lines" })
map("n", "<leader>sc", "<cmd>FzfLua command_history<cr>", { desc = "Command History" })
map("n", "<leader>sC", "<cmd>FzfLua commands<cr>", { desc = "Commands" })
map("n", "<leader>sd", "<cmd>FzfLua diagnostics_workspace<cr>", { desc = "Diagnostics" })
map("n", "<leader>sD", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Buffer Diagnostics" })
map("n", "<leader>sg", pick("live_grep"), { desc = "Grep (Root Dir)" })
map("n", "<leader>sG", pick("live_grep", { root = false }), { desc = "Grep (cwd)" })
map("n", "<leader>sh", "<cmd>FzfLua help_tags<cr>", { desc = "Help Pages" })
map("n", "<leader>sH", "<cmd>FzfLua highlights<cr>", { desc = "Search Highlight Groups" })
map("n", "<leader>sj", "<cmd>FzfLua jumps<cr>", { desc = "Jumplist" })
map("n", "<leader>sk", "<cmd>FzfLua keymaps<cr>", { desc = "Key Maps" })
map("n", "<leader>sl", "<cmd>FzfLua loclist<cr>", { desc = "Location List" })
map("n", "<leader>sM", "<cmd>FzfLua man_pages<cr>", { desc = "Man Pages" })
map("n", "<leader>sm", "<cmd>FzfLua marks<cr>", { desc = "Jump to Mark" })
map("n", "<leader>sR", "<cmd>FzfLua resume<cr>", { desc = "Resume" })
map("n", "<leader>sq", "<cmd>FzfLua quickfix<cr>", { desc = "Quickfix List" })
map("n", "<leader>sw", pick("grep_cword"), { desc = "Word (Root Dir)" })
map("n", "<leader>sW", pick("grep_cword", { root = false }), { desc = "Word (cwd)" })
map("x", "<leader>sw", pick("grep_visual"), { desc = "Selection (Root Dir)" })
map("x", "<leader>sW", pick("grep_visual", { root = false }), { desc = "Selection (cwd)" })
map("n", "<leader>uC", pick("colorschemes"), { desc = "Colorscheme with Preview" })
map("n", "<leader>ss", function() fzf.lsp_document_symbols({ regex_filter = symbols_filter }) end, { desc = "Goto Symbol" })
map("n", "<leader>sS", function() fzf.lsp_live_workspace_symbols({ regex_filter = symbols_filter }) end, { desc = "Goto Symbol (Workspace)" })
-- stylua: ignore end
