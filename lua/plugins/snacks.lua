-- snacks.nvim: dashboard, notifier, bufdelete, terminal, toggles, words, indent guides, ...
-- Loaded first from init.lua because it defines the global `Snacks` other plugin files use.
local pack = require("config.pack")
pack.add({ "folke/snacks.nvim" })

local util = require("config.util")

-- <C-h/j/k/l> in a floating terminal are passed through, in a split they switch windows
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

require("snacks").setup({
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true }, -- animations are off via vim.g.snacks_animate (options.lua)
  statuscolumn = { enabled = false }, -- set through vim.o.statuscolumn below
  words = { enabled = true },
  toggle = { map = vim.keymap.set },
  terminal = {
    win = {
      keys = {
        nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
        nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
        nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
        nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
        hide_slash = { "<C-/>", "hide", desc = "Hide Terminal", mode = "t" },
        hide_underscore = { "<c-_>", "hide", desc = "which_key_ignore", mode = "t" },
      },
    },
  },
  dashboard = {
    preset = {
      pick = function(cmd, opts)
        return util.pick_open(cmd, opts)
      end,
      header = [[

███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
                                                  
]],
      -- stylua: ignore
      ---@type snacks.dashboard.Item[]
      keys = {
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { icon = " ", key = "s", desc = "Restore Session", section = "session" },
        { icon = "󰒲 ", key = "l", desc = "Plugins", action = ":PackStatus" },
        { icon = "󰒲 ", key = "u", desc = "Update Plugins", action = ":PackUpdate" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 0, padding = 2 },
      { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 2 },
      -- { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 2 },
      -- { section = "startup" },
    },
  },
})

vim.o.statuscolumn = "%!v:lua.require'snacks.statuscolumn'.get()"

local map = vim.keymap.set
-- stylua: ignore start
map("n", "<leader>n", function()
  if Snacks.config.picker and Snacks.config.picker.enabled then Snacks.picker.notifications() else Snacks.notifier.show_history() end
end, { desc = "Notification History" })
map("n", "<leader>un", function() Snacks.notifier.hide() end, { desc = "Dismiss All Notifications" })
map("n", "<leader>.", function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
map("n", "<leader>S", function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer" })
map("n", "<leader>dps", function() Snacks.profiler.scratch() end, { desc = "Profiler Scratch Buffer" })

-- buffers
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Delete Other Buffers" })
map("n", "<leader>bi", function() Snacks.bufdelete.invisible() end, { desc = "Delete Invisible Buffers" })

-- toggle options
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }):map("<leader>uc")
Snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }):map("<leader>uA")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
Snacks.toggle.dim():map("<leader>uD")
Snacks.toggle.animate():map("<leader>ua")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.scroll():map("<leader>uS")
Snacks.toggle.profiler():map("<leader>dpp")
Snacks.toggle.profiler_highlights():map("<leader>dph")
Snacks.toggle.inlay_hints():map("<leader>uh")
Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
Snacks.toggle.zen():map("<leader>uz")

-- git
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function() Snacks.lazygit({ cwd = util.git() }) end, { desc = "Lazygit (Root Dir)" })
  map("n", "<leader>gG", function() Snacks.lazygit() end, { desc = "Lazygit (cwd)" })
end
map("n", "<leader>gL", function() Snacks.picker.git_log() end, { desc = "Git Log (cwd)" })
map("n", "<leader>gb", function() Snacks.picker.git_log_line() end, { desc = "Git Blame Line" })
map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Current File History" })
map({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse (open)" })
map({ "n", "x" }, "<leader>gY", function()
  Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
end, { desc = "Git Browse (copy)" })

-- floating terminal
map("n", "<leader>fT", function() Snacks.terminal() end, { desc = "Terminal (cwd)" })
map("n", "<leader>ft", function() Snacks.terminal(nil, { cwd = util.root() }) end, { desc = "Terminal (Root Dir)" })
map({ "n", "t" }, "<c-/>", function() Snacks.terminal.focus(nil, { cwd = util.root() }) end, { desc = "Terminal (Root Dir)" })
map({ "n", "t" }, "<c-_>", function() Snacks.terminal.focus(nil, { cwd = util.root() }) end, { desc = "which_key_ignore" })

-- lua
map({ "n", "x" }, "<localleader>r", function() Snacks.debug.run() end, { desc = "Run Lua" })
-- stylua: ignore end
