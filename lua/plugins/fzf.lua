-- fzf-lua: the picker (files, grep, buffers, LSP symbols, git, ...) and vim.ui.select.
-- Pickers rooted at the project root use require("config.util").pick; <leader>fF etc. use the cwd.
local pack = require("config.pack")
pack.add({ "ibhagwan/fzf-lua" })

local util = require("config.util")
local pick = util.pick

-- LSP symbol kinds shown by <leader>ss / <leader>sS (LazyVim's kind_filter)
local kind_filter = {
  default = {
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
  },
  markdown = false,
  help = false,
  lua = {
    "Class",
    "Constructor",
    "Enum",
    "Field",
    "Function",
    "Interface",
    "Method",
    "Module",
    "Namespace",
    "Property",
    "Struct",
    "Trait",
  },
}
local function symbols_filter(entry, ctx)
  if ctx.symbols_filter == nil then
    local ft = vim.bo[ctx.bufnr].filetype
    local f = kind_filter[ft]
    ctx.symbols_filter = (f == nil and kind_filter.default) or f
  end
  if ctx.symbols_filter == false then
    return true
  end
  return vim.tbl_contains(ctx.symbols_filter, entry.kind)
end

local fzf = require("fzf-lua")
local config = fzf.config
local actions = fzf.actions

-- Quickfix
config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
config.defaults.keymap.fzf["ctrl-x"] = "jump"
config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"

-- Trouble: <c-t> sends the results to a trouble list (needs trouble.lua loaded and set up first)
if pcall(require, "plugins.trouble") then
  config.defaults.actions.files["ctrl-t"] = require("trouble.sources.fzf").actions.open
end

-- Toggle root dir / cwd
config.defaults.actions.files["ctrl-r"] = function(_, ctx)
  local o = vim.deepcopy(ctx.__call_opts)
  o.root = o.root == false
  o.cwd = nil
  o.buf = ctx.__CTX.bufnr
  util.pick_open(ctx.__INFO.cmd, o)
end
config.defaults.actions.files["alt-c"] = config.defaults.actions.files["ctrl-r"]
config.set_action_helpstr(config.defaults.actions.files["ctrl-r"], "toggle-root-dir")

local img_previewer ---@type string[]?
for _, v in ipairs({
  { cmd = "ueberzug", args = {} },
  { cmd = "chafa", args = { "{file}", "--format=symbols" } },
  { cmd = "viu", args = { "-b" } },
}) do
  if vim.fn.executable(v.cmd) == 1 then
    img_previewer = vim.list_extend({ v.cmd }, v.args)
    break
  end
end

-- vim.ui.select sizing
local function ui_select(fzf_opts, items)
  return vim.tbl_deep_extend("force", fzf_opts, {
    prompt = " ",
    winopts = {
      title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
      title_pos = "center",
    },
  }, fzf_opts.kind == "codeaction" and {
    winopts = {
      layout = "vertical",
      -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
      height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 4) + 0.5) + 16,
      width = 0.5,
      preview = not vim.tbl_isempty(vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })) and {
        layout = "vertical",
        vertical = "down:15,border-top",
        hidden = "hidden",
      } or {
        layout = "vertical",
        vertical = "down:15,border-top",
      },
    },
  } or {
    winopts = {
      width = 0.5,
      -- height is number of items, with a max of 80% screen height
      height = math.floor(math.min(vim.o.lines * 0.8, #items + 4) + 0.5),
    },
  })
end

local opts = {
  fzf_colors = true,
  fzf_opts = {
    ["--no-scrollbar"] = true,
  },
  defaults = {
    -- formatter = "path.filename_first",
    formatter = "path.dirname_first",
  },
  previewers = {
    builtin = {
      extensions = {
        ["png"] = img_previewer,
        ["jpg"] = img_previewer,
        ["jpeg"] = img_previewer,
        ["gif"] = img_previewer,
        ["webp"] = img_previewer,
      },
      ueberzug_scaler = "fit_contain",
    },
  },
  winopts = {
    width = 0.8,
    height = 0.8,
    row = 0.5,
    col = 0.5,
    preview = {
      scrollchars = { "┃", "" },
    },
  },
  files = {
    cwd_prompt = false,
    actions = {
      ["alt-i"] = { actions.toggle_ignore },
      ["alt-h"] = { actions.toggle_hidden },
    },
  },
  grep = {
    actions = {
      ["alt-i"] = { actions.toggle_ignore },
      ["alt-h"] = { actions.toggle_hidden },
    },
  },
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
    code_actions = {
      previewer = vim.fn.executable("delta") == 1 and "codeaction_native" or nil,
    },
  },
}

-- Base everything on the "default-title" profile, with the same (empty) prompt everywhere
local function fix(t)
  t.prompt = t.prompt ~= nil and " " or nil
  for _, v in pairs(t) do
    if type(v) == "table" then
      fix(v)
    end
  end
  return t
end
opts = vim.tbl_deep_extend("force", fix(require("fzf-lua.profiles.default-title")), opts)
fzf.setup(opts)
fzf.register_ui_select(ui_select)

local map = vim.keymap.set
-- stylua: ignore start
map("t", "<c-j>", "<c-j>", { nowait = true }) -- keep <c-j>/<c-k> in the fzf terminal window
map("t", "<c-k>", "<c-k>", { nowait = true })
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
map("n", "<leader>fR", pick("oldfiles", { cwd = vim.uv.cwd() }), { desc = "Recent (cwd)" })
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
