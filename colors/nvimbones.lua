local colors_name = "nvimbones"
vim.g.colors_name = colors_name -- Required when defining a colorscheme

local lush = require("lush")
local hsluv = lush.hsluv -- Human-friendly hsl
local util = require("zenbones.util")

local bg = vim.o.background

-- Define a palette. Use `palette_extend` to fill unspecified colors
-- Based on Neovim's default colorscheme (the Nvim{Dark,Light}* colors, :h nvim-defaults).
-- The default theme is nearly monochrome with three accents: cyan for functions/specials,
-- green for strings, blue for identifiers (fields), and contrast by bold rather than italic.
-- The blue is zenbones' own: the Nvim blues are within a few L of the text on either background.
-- `grey4` carries the default theme's gray Visual/MatchParen.
--
-- Dark `bg` is NvimDarkGrey2's hue lifted from L7 to L9 so the derived UI chrome clears a dark
-- terminal when running transparent; the real Grey2 is kept as bg_stark and Grey3 as bg_warm
-- (`vim.g.nvimbones = { darkness = "stark" | "warm" }`, `{ lightness = "bright" | "dim" }`).
local palette
if bg == "light" then
  palette = util.palette_extend({
    bg = hsluv("#e0e2ea"), -- NvimLightGrey2
    bg_bright = hsluv("#eef1f8"), -- NvimLightGrey1
    bg_dim = hsluv("#c4c6cd"), -- NvimLightGrey3
    fg = hsluv(253, 8, 22), -- NvimDarkGrey2 #14161b is (253, 17, 7); lifted to zenbones' light fg, near gray
    rose = hsluv("#590008"), -- NvimDarkRed
    leaf = hsluv("#005523"), -- NvimDarkGreen
    wood = hsluv("#6b5300"), -- NvimDarkYellow
    water = hsluv(236, 84, 40), -- zenbones' blue; NvimDarkBlue #004c73 sits too close to the text
    blossom = hsluv("#470045"), -- NvimDarkMagenta
    sky = hsluv("#007373"), -- NvimDarkCyan
    grey4 = hsluv("#9b9ea4"), -- NvimLightGrey4
  }, bg)
else
  palette = util.palette_extend({
    bg = hsluv("#17191f"), -- NvimDarkGrey2 #14161b, lifted to L9
    bg_stark = hsluv("#14161b"), -- NvimDarkGrey2
    bg_warm = hsluv("#2c2e33"), -- NvimDarkGrey3
    fg = hsluv(257, 10, 90), -- NvimLightGrey2 #e0e2ea is (257, 26, 90); same lightness, most of the tint removed
    rose = hsluv("#ffc0b9"), -- NvimLightRed
    leaf = hsluv("#b3f6c0"), -- NvimLightGreen
    wood = hsluv("#fce094"), -- NvimLightYellow
    water = hsluv(236, 64, 61), -- zenbones' blue; NvimLightBlue #a6dbff sits too close to the text
    blossom = hsluv("#ffcaff"), -- NvimLightMagenta
    sky = hsluv("#8cf8f7"), -- NvimLightCyan
    grey4 = hsluv("#4f5258"), -- NvimDarkGrey4
  }, bg)
end

-- Generate the lush specs using the generator util
local generator = require("zenbones.specs")

-- zenbones reads options from `vim.g.<colors_name>`. Defaults set here to follow the default
-- theme: transparent, no italics (bold/non-bold only), comments and the cursorline lighter than
-- zenbones' own (NvimLightGrey4 comments sit at L65, the cursorline at Grey3). Each is still
-- overridable, e.g. `vim.g.nvimbones_italic_comments = true`.
local config = generator.get_global_config(colors_name, bg)
local defaults = {
  transparent_background = true,
  italic_strings = false,
  italic_comments = false,
  lighten_comments = 55,
  lighten_cursor_line = 11,
  darken_comments = 50,
  darken_cursor_line = 8,
}
for key, value in pairs(defaults) do
  if config[key] == nil then
    config[key] = value
  end
end

local base_specs = generator.generate(palette, bg, config)

-- Optionally extend specs using Lush: the default theme's accents on top of the zenbones
-- hierarchy (bold statements, dimmed identifiers, gray types/delimiters, dim comments).
-- Treesitter and LSP captures chain off these legacy groups; `@variable` is pinned back to the
-- plain dimmed identifier so only fields, properties and constants take the blue, as in the
-- default theme. The UI groups below take the color out of every match highlight (zenbones
-- paints them magenta), keep diagnostics and spelling from recoloring the text, and put the
-- diagnostic signs on the default hues.
local specs = lush.extends({ base_specs }).with(function(injected)
  local sym = injected.sym
  return {
    Function({ fg = palette.sky }), -- cyan functions
    Special({ fg = palette.sky }), -- cyan builtins, escapes, tags
    String({ base_specs.String, fg = palette.leaf }), -- green strings
    Identifier({ fg = palette.water }), -- blue fields, properties, constants
    sym("@variable")({ fg = base_specs.Identifier.fg }), -- plain variables keep the dimmed fg
    sym("@markup.raw")({ fg = palette.sky }), -- inline code and code blocks, cyan like the default theme
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
