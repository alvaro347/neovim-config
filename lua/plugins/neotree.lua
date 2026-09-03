-- neo-tree: file explorer (<leader>e / <leader>fe). Needs nui + plenary; icons come from mini.icons.
local pack = require("config.pack")
pack.add({ "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim", "nvim-neo-tree/neo-tree.nvim" })

local util = require("config.util")

local opts = {
  sources = { "filesystem", "buffers", "git_status" },
  open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
  filesystem = {
    bind_to_cwd = false,
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
  },
  window = {
    mappings = {
      ["l"] = "open",
      ["h"] = "close_node",
      ["<space>"] = "none",
      ["Y"] = {
        function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          vim.fn.setreg("+", path, "c")
        end,
        desc = "Copy Path to Clipboard",
      },
      ["O"] = {
        function(state)
          vim.ui.open(state.tree:get_node().path)
        end,
        desc = "Open with System Application",
      },
      ["P"] = { "toggle_preview", config = { use_float = false } },
    },
  },
  default_component_configs = {
    indent = {
      with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
    },
    git_status = {
      symbols = {
        unstaged = "󰄱",
        staged = "󰄱",
      },
    },
  },
}

local done = false
local function setup()
  if done then
    return
  end
  done = true
  local function on_move(data)
    Snacks.rename.on_rename_file(data.source, data.destination)
  end
  local events = require("neo-tree.events")
  opts.event_handlers = opts.event_handlers or {}
  vim.list_extend(opts.event_handlers, {
    { event = events.FILE_MOVED, handler = on_move },
    { event = events.FILE_RENAMED, handler = on_move },
  })
  require("neo-tree").setup(opts)
  vim.api.nvim_create_autocmd("TermClose", {
    pattern = "*lazygit",
    callback = function()
      if package.loaded["neo-tree.sources.git_status"] then
        require("neo-tree.sources.git_status").refresh()
      end
    end,
  })
end
pack.later(setup)

-- `nvim <dir>` opens the tree
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
  desc = "Start Neo-tree with directory",
  once = true,
  callback = function()
    if package.loaded["neo-tree"] then
      return
    end
    local stats = vim.uv.fs_stat(vim.fn.argv(0))
    if stats and stats.type == "directory" then
      setup()
      require("neo-tree")
    end
  end,
})

local function execute(args)
  return function()
    setup()
    require("neo-tree.command").execute(args())
  end
end
-- stylua: ignore start
vim.keymap.set("n", "<leader>fe", execute(function() return { toggle = true, dir = util.root() } end), { desc = "Explorer NeoTree (Root Dir)" })
vim.keymap.set("n", "<leader>fE", execute(function() return { toggle = true, dir = vim.uv.cwd() } end), { desc = "Explorer NeoTree (cwd)" })
vim.keymap.set("n", "<leader>e", "<leader>fe", { desc = "Explorer NeoTree (Root Dir)", remap = true })
vim.keymap.set("n", "<leader>E", "<leader>fE", { desc = "Explorer NeoTree (cwd)", remap = true })
vim.keymap.set("n", "<leader>ge", execute(function() return { source = "git_status", toggle = true } end), { desc = "Git Explorer" })
vim.keymap.set("n", "<leader>be", execute(function() return { source = "buffers", toggle = true } end), { desc = "Buffer Explorer" })
-- stylua: ignore end
