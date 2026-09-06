-- lualine: statusline. Component helpers (pretty_path, root_dir) are ported from LazyVim.
local pack = require("config.pack")
pack.add({ "nvim-lualine/lualine.nvim" })

local icons = require("config.icons")
local util = require("config.util")

-- PERF: we don't need lualine's require madness
local lualine_require = require("lualine_require")
lualine_require.require = require

--- Format `text` with the colors of `hl_group` inside a lualine component
local function format(component, text, hl_group)
  text = text:gsub("%%", "%%%%")
  if not hl_group or hl_group == "" then
    return text
  end
  component.hl_cache = component.hl_cache or {}
  local lualine_hl_group = component.hl_cache[hl_group]
  if not lualine_hl_group then
    local utils = require("lualine.utils.utils")
    local gui = vim.tbl_filter(function(x)
      return x
    end, {
      utils.extract_highlight_colors(hl_group, "bold") and "bold",
      utils.extract_highlight_colors(hl_group, "italic") and "italic",
    })
    lualine_hl_group = component:create_hl({
      fg = utils.extract_highlight_colors(hl_group, "fg"),
      gui = #gui > 0 and table.concat(gui, ",") or nil,
    }, "LV_" .. hl_group)
    component.hl_cache[hl_group] = lualine_hl_group
  end
  return component:format_hl(lualine_hl_group) .. text .. component:get_default_hl()
end

--- Path relative to cwd (or root), shortened to `length` parts, filename highlighted
local function pretty_path(opts)
  opts = vim.tbl_extend("force", {
    relative = "cwd",
    modified_hl = "MatchParen",
    directory_hl = "",
    filename_hl = "Bold",
    readonly_icon = " 󰌾 ",
    length = 3,
  }, opts or {})

  return function(self)
    local path = vim.fn.expand("%:p") --[[@as string]]
    if path == "" then
      return ""
    end
    path = vim.fs.normalize(path)
    local root = vim.fs.normalize(util.root())
    local cwd = vim.fs.normalize(assert(vim.uv.cwd()))

    if opts.relative == "cwd" and path:find(cwd, 1, true) == 1 then
      path = path:sub(#cwd + 2)
    elseif path:find(root, 1, true) == 1 then
      path = path:sub(#root + 2)
    end

    local sep = package.config:sub(1, 1)
    local parts = vim.split(path, "[\\/]")
    if opts.length > 0 and #parts > opts.length then
      parts = { parts[1], "…", unpack(parts, #parts - opts.length + 2, #parts) }
    end

    if opts.modified_hl and vim.bo.modified then
      parts[#parts] = format(self, parts[#parts], opts.modified_hl)
    else
      parts[#parts] = format(self, parts[#parts], opts.filename_hl)
    end

    local dir = ""
    if #parts > 1 then
      dir = table.concat({ unpack(parts, 1, #parts - 1) }, sep)
      dir = format(self, dir .. sep, opts.directory_hl)
    end

    local readonly = ""
    if vim.bo.readonly then
      readonly = format(self, opts.readonly_icon, opts.modified_hl)
    end
    return dir .. parts[#parts] .. readonly
  end
end

--- Name of the project root when it differs from the cwd
local function root_dir(opts)
  opts = vim.tbl_extend("force", {
    cwd = false,
    subdirectory = true,
    parent = true,
    other = true,
    icon = "󱉭 ",
    color = function()
      return { fg = Snacks.util.color("Special") }
    end,
  }, opts or {})

  local function get()
    local cwd = vim.fs.normalize(assert(vim.uv.cwd()))
    local root = vim.fs.normalize(util.root())
    local name = vim.fs.basename(root)
    if root == cwd then
      return opts.cwd and name -- root is cwd
    elseif root:find(cwd, 1, true) == 1 then
      return opts.subdirectory and name -- root is subdirectory of cwd
    elseif cwd:find(root, 1, true) == 1 then
      return opts.parent and name -- root is parent directory of cwd
    else
      return opts.other and name -- root and cwd are not related
    end
  end

  return {
    function()
      return (opts.icon or "") .. get()
    end,
    cond = function()
      return type(get()) == "string"
    end,
    color = opts.color,
  }
end

--- Statusline theme derived from the current colorscheme, filled with the cursorline bg.
--- lualine's built-in "auto" theme is not enough here: it returns a colorscheme-shipped
--- lualine theme whenever one exists (zenbones ships one), and otherwise builds its
--- sections from the `Normal` and `StatusLine` backgrounds — which the transparent themes
--- here leave unset, so it falls back to `#000000` and paints a solid black strip. Build
--- the theme instead: the mode accent keeps the outside blocks, and every other section
--- takes the background of the selected line (`CursorLine`), a group colorschemes fill
--- even in transparent mode, so the bar reads as one surface in the same tone as the
--- cursorline instead of letting the terminal show through mid-statusline.
local function statusline_theme()
  local utils = require("lualine.utils.utils")
  --- First `fg` among `groups`, or `fallback`
  local function fg(groups, fallback)
    return utils.extract_color_from_hllist("fg", groups, fallback)
  end
  --- Perceived brightness of `#rrggbb`, 0..1
  local function brightness(hex)
    local r, g, b = hex:match("^#(%x%x)(%x%x)(%x%x)$")
    if not r then
      return 0
    end
    return (tonumber(r, 16) * 2 + tonumber(g, 16) * 3 + tonumber(b, 16)) / 6 / 255
  end

  local text = fg({ "Normal", "StatusLine" }, "#cccccc")
  local dim = fg({ "Comment", "NonText" }, text)
  -- the background for the whole bar: the selected line, from a group the colorscheme
  -- fills even in transparent mode (`Normal`/`StatusLine` have no bg there)
  local block = utils.extract_color_from_hllist("bg", { "CursorLine", "ColorColumn", "Visual" }, "#1c1c1c")
  --- Readable text on an accent-coloured block
  local function on_accent(accent)
    return brightness(accent) > 0.5 and block or text
  end

  -- One accent per mode, first candidate group that resolves to a colour no earlier
  -- mode already took (themes reuse one colour for several groups — gruvbox-material
  -- paints both `Function` and `String` green, which would make normal and insert
  -- indistinguishable)
  local candidates = {
    { "normal", { "Function", "Directory", "Identifier", "Type" } },
    { "insert", { "String", "MoreMsg", "Constant" } },
    { "visual", { "Special", "Boolean", "Constant", "Type" } },
    { "replace", { "Number", "Type", "Special" } },
    { "command", { "Statement", "Keyword", "Identifier" } },
  }
  local accents, taken = {}, {}
  for _, entry in ipairs(candidates) do
    local mode, groups = entry[1], entry[2]
    local accent, first
    for _, group in ipairs(groups) do
      local color = fg({ group })
      first = first or color
      if color and not taken[color] then
        accent = color
        break
      end
    end
    accent = accent or first or text
    taken[accent] = true
    accents[mode] = accent
  end
  accents.terminal = accents.insert

  local theme = {}
  for mode, accent in pairs(accents) do
    theme[mode] = {
      a = { bg = accent, fg = on_accent(accent), gui = "bold" }, -- mode / the clock
      b = { bg = block, fg = accent }, -- branch / progress + location
      c = { bg = block, fg = text }, -- the fill: path, diagnostics, diff, noice
    }
  end
  theme.inactive = {
    a = { bg = block, fg = dim, gui = "bold" },
    b = { bg = block, fg = dim },
    c = { bg = block, fg = dim },
  }
  return theme
end

local opts = {
  options = {
    -- a function, so lualine re-derives it on every `:colorscheme`
    theme = statusline_theme,
    globalstatus = vim.o.laststatus == 3,
    disabled_filetypes = { statusline = { "snacks_dashboard" } },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },

    lualine_c = {
      root_dir(),
      {
        "diagnostics",
        symbols = {
          error = icons.diagnostics.Error,
          warn = icons.diagnostics.Warn,
          info = icons.diagnostics.Info,
          hint = icons.diagnostics.Hint,
        },
      },
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      { pretty_path() },
    },
    lualine_x = {
      Snacks.profiler.status(),
      -- stylua: ignore
      {
        function() return require("noice").api.status.command.get() end,
        cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
        color = function() return { fg = Snacks.util.color("Statement") } end,
      },
      -- stylua: ignore
      {
        function() return require("noice").api.status.mode.get() end,
        cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
        color = function() return { fg = Snacks.util.color("Constant") } end,
      },
      {
        "diff",
        symbols = {
          added = icons.git.added,
          modified = icons.git.modified,
          removed = icons.git.removed,
        },
        source = function()
          local gitsigns = vim.b.gitsigns_status_dict
          if gitsigns then
            return {
              added = gitsigns.added,
              modified = gitsigns.changed,
              removed = gitsigns.removed,
            }
          end
        end,
      },
    },
    lualine_y = {
      { "progress", separator = " ", padding = { left = 1, right = 0 } },
      { "location", padding = { left = 0, right = 1 } },
    },
    lualine_z = {
      function()
        return " " .. os.date("%R")
      end,
    },
  },
  extensions = { "neo-tree", "fzf" },
}

-- Show the current LSP symbol path (via trouble.nvim) in the statusline
pack.later(function()
  local ok, trouble = pcall(require, "trouble")
  if not ok then
    return
  end
  local symbols = trouble.statusline({
    mode = "symbols",
    groups = {},
    title = false,
    filter = { range = true },
    format = "{kind_icon}{symbol.name:Normal}",
    hl_group = "lualine_c_normal",
  })
  table.insert(opts.sections.lualine_c, {
    symbols.get,
    cond = function()
      return vim.b.trouble_lualine ~= false and symbols.has()
    end,
  })
  require("lualine").setup(opts)
end)

require("lualine").setup(opts)
