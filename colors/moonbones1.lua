local colors_name = "moonbones1"
vim.g.colors_name = colors_name -- Required when defining a colorscheme

local lush = require("lush")
local hsluv = lush.hsluv -- Human-friendly hsl
local util = require("zenbones.util")

-- Dark only: a black-and-white terminal with one phosphor accent has no light counterpart.
local bg = "dark"

-- Retro-future moon terminal, nvimbones edition: Neovim's default structure (accents on
-- functions/specials, strings and fields; contrast by bold, never italic) with the spring-green
-- phosphor of rgb(0,235,121) as the main color where the default theme has cyan. Strings take
-- a dusty mint, fields a cold moonlight silver; everything else is white on black.
--
-- The theme runs transparent by default, so `bg` only drives the derived UI chrome (cursorline,
-- statusline, popups, line numbers, diff). It sits at L9, with a trace of the green, so the
-- chrome stays visible over a dark terminal; a truer black is kept as bg_stark
-- (`vim.g.moonbones1 = { darkness = "stark" }`). `grey4` carries the default theme's gray
-- Visual/MatchParen.
local moon = hsluv(137, 100, 82) -- #00ea76, the phosphor
local palette = util.palette_extend({
  bg = hsluv(137, 10, 9), -- #181a18
  bg_stark = hsluv(137, 10, 5), -- #0f1110
  bg_warm = hsluv(137, 12, 15), -- #232724
  fg = hsluv(137, 8, 90), -- #dbe5dd, white with a trace of phosphor
  rose = hsluv(12, 60, 74), -- #e6a6a6, muted alert red: errors, deletions
  leaf = hsluv(137, 45, 76), -- #8bc99c, dusty mint: String, additions, ok
  wood = hsluv(60, 60, 82), -- #edc781, muted amber: warnings
  water = hsluv(245, 35, 72), -- #9fb2cd, moonlight silver: Identifier, changes, hints
  blossom = moon, -- matches (the defaults below take the color out of them anyway)
  sky = moon, -- Function, Special, code, info
  grey4 = hsluv(137, 10, 33), -- #494f4b, Visual / MatchParen
}, bg)

-- Generate the lush specs using the generator util
local generator = require("zenbones.specs")

-- zenbones reads options from `vim.g.<colors_name>`. Defaults set here to follow the default
-- theme, like nvimbones: transparent, no italics (bold/non-bold only), comments and the
-- cursorline lighter than zenbones' own. Each is still overridable, e.g.
-- `vim.g.moonbones1_italic_comments = true`.
local config = generator.get_global_config(colors_name, bg)
local defaults = {
  transparent_background = true,
  italic_strings = false,
  italic_comments = false,
  lighten_comments = 55,
  lighten_cursor_line = 11,
}
for key, value in pairs(defaults) do
  if config[key] == nil then
    config[key] = value
  end
end

local base_specs = generator.generate(palette, bg, config)

-- Optionally extend specs using Lush: the default theme's accent structure on top of the
-- zenbones hierarchy (bold statements, dimmed identifiers, gray types/delimiters, dim comments).
-- Treesitter and LSP captures chain off these legacy groups; `@variable` is pinned back to the
-- plain dimmed identifier so only fields and properties take the moonlight, as in the default
-- theme. The UI groups below take the color out of every match highlight (zenbones paints them
-- with the blossom), keep diagnostics and spelling from recoloring the text, and put the
-- diagnostic signs on the theme's hues.
local specs = lush.extends({ base_specs }).with(function(injected)
  local sym = injected.sym
  return {
    Function({ fg = palette.sky }), -- phosphor functions
    Special({ fg = palette.sky }), -- phosphor builtins, escapes, tags
    String({ base_specs.String, fg = palette.leaf }), -- mint strings
    Identifier({ fg = palette.water }), -- moonlight fields and properties
    sym("@variable")({ fg = base_specs.Identifier.fg }), -- plain variables keep the dimmed fg
    Constant({ fg = base_specs.Constant.fg }), -- zenbones italicizes constants and booleans; bold-only here
    Boolean({ fg = palette.fg }),
    sym("@markup.raw")({ fg = palette.sky }), -- inline code and code blocks; @markup.raw.block follows
    sym("@markup.raw.markdown")({ fg = palette.sky }),
    markdownCode({ fg = palette.sky }),

    Visual({ bg = palette.grey4 }),
    MatchParen({ bg = palette.grey4, gui = "bold" }),
    Search({ bg = palette.grey4.li(12), fg = palette.fg }), -- a step above Visual, no hue
    IncSearch({ bg = palette.fg, fg = palette.bg, gui = "bold" }), -- reversed text; CurSearch follows
    WildMenu({ bg = palette.grey4, fg = palette.fg, gui = "bold" }),
    SnacksPickerMatch({ fg = palette.fg, gui = "bold" }),
    BlinkCmpLabelMatch({ fg = palette.fg, gui = "bold" }),
    TelescopeMatching({ fg = palette.fg, gui = "bold" }),
    FzfLuaFzfMatch({ fg = palette.fg, gui = "bold" }),

    SpellBad({ gui = "undercurl", sp = palette.rose }),
    SpellCap({ gui = "undercurl", sp = palette.wood }),
    SpellLocal({ gui = "undercurl", sp = palette.leaf }),
    SpellRare({ gui = "undercurl", sp = palette.sky }),
    DiagnosticUnnecessary({ base_specs.Comment }),
    DiagnosticDeprecated({ gui = "strikethrough", sp = palette.rose }),
    Directory({ fg = palette.sky, gui = "bold" }),
    DiagnosticInfo({ fg = palette.sky }),
    DiagnosticHint({ fg = palette.water }),
  }
end)

-- Pass the specs to lush to apply
lush(specs)

-- Optionally set term colors
require("zenbones.term").apply_colors(palette)
