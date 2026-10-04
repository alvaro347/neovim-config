-- lualine: statusline. format/pretty_path/root_name are trimmed ports of LazyVim's helpers.
local pack = require("config.pack")
pack.add({ "nvim-lualine/lualine.nvim" })

local icons = require("config.icons")
local util = require("config.util")

-- PERF: lualine dofile()s its own modules; plain require goes through the vim.loader cache
require("lualine_require").require = require

--- `text` in `hl_group`'s fg/bold/italic inside a lualine component (no group: only escaped)
local function format(component, text, hl_group)
  text = text:gsub("%%", "%%%%")
  if not hl_group then
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

--- File path relative to the cwd (else the project root), shortened to 3 parts. The name is
--- bold, or MatchParen-coloured when modified; a lock follows when the buffer is readonly.
local function pretty_path(self)
  local path = vim.fn.expand("%:p") --[[@as string]]
  if path == "" then
    return ""
  end
  path = vim.fs.normalize(path)
  local cwd = vim.fs.normalize(assert(vim.uv.cwd()))
  local root = vim.fs.normalize(util.root())
  if path:find(cwd, 1, true) == 1 then
    path = path:sub(#cwd + 2)
  elseif path:find(root, 1, true) == 1 then
    path = path:sub(#root + 2)
  end
  local parts = vim.split(path, "/", { plain = true })
  if #parts > 3 then
    parts = { parts[1], "…", parts[#parts - 1], parts[#parts] }
  end
  local name = format(self, table.remove(parts), vim.bo.modified and "MatchParen" or "Bold")
  local dir = #parts > 0 and format(self, table.concat(parts, "/") .. "/") or ""
  local readonly = vim.bo.readonly and format(self, " 󰌾 ", "MatchParen") or ""
  return dir .. name .. readonly
end

--- Name of the project root, or nil when the root is the cwd
local function root_name()
  local root = vim.fs.normalize(util.root())
  return root ~= vim.fs.normalize(assert(vim.uv.cwd())) and vim.fs.basename(root) or nil
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
      c = { bg = block, fg = text }, -- the fill: path, diagnostics, diff
    }
  end
  theme.inactive = {
    a = { bg = block, fg = dim, gui = "bold" },
    b = { bg = block, fg = dim },
    c = { bg = block, fg = dim },
  }
  return theme
end

-- LSP symbol path under the cursor (trouble.nvim), created once trouble is loaded
local symbols
local trouble_symbols = {
  function()
    return symbols.get()
  end,
  cond = function()
    if not symbols and package.loaded.trouble then
      symbols = require("trouble").statusline({
        mode = "symbols",
        groups = {},
        title = false,
        filter = { range = true },
        format = "{kind_icon}{symbol.name:Normal}",
        hl_group = "lualine_c_normal",
      })
    end
    return symbols ~= nil and symbols.has()
  end,
}

require("lualine").setup({
  options = {
    theme = statusline_theme, -- a function, so lualine re-derives it on every `:colorscheme`
    disabled_filetypes = { statusline = { "snacks_dashboard" } },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = {
      {
        function()
          return "󱉭 " .. root_name()
        end,
        cond = function()
          return root_name() ~= nil
        end,
        color = function()
          return { fg = Snacks.util.color("Special") }
        end,
      },
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
      { pretty_path },
      trouble_symbols,
    },
    lualine_x = {
      Snacks.profiler.status(),
      {
        "diff",
        symbols = { added = icons.git.added, modified = icons.git.modified, removed = icons.git.removed },
        -- counts from gitsigns instead of running git diff
        source = function()
          local gs = vim.b.gitsigns_status_dict
          return gs and { added = gs.added, modified = gs.changed, removed = gs.removed }
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
})
