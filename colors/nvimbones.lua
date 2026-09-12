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
    fg = hsluv("#14161b"), -- NvimDarkGrey2
    rose = hsluv("#590008"), -- NvimDarkRed
    leaf = hsluv("#005523"), -- NvimDarkGreen
    wood = hsluv("#6b5300"), -- NvimDarkYellow
    water = hsluv(236, 84, 40), -- zenbones' blue; NvimDarkBlue #004c73 sits too close to the text
    blossom = hsluv("#470045"), -- NvimDarkMagenta
    sky = hsluv("#007373"), -- NvimDarkCyan
  }, bg)
else
  palette = util.palette_extend({
    bg = hsluv("#17191f"), -- NvimDarkGrey2 #14161b, lifted to L9
    bg_stark = hsluv("#14161b"), -- NvimDarkGrey2
    bg_warm = hsluv("#2c2e33"), -- NvimDarkGrey3
    fg = hsluv("#e0e2ea"), -- NvimLightGrey2
    rose = hsluv("#ffc0b9"), -- NvimLightRed
    leaf = hsluv("#b3f6c0"), -- NvimLightGreen
    wood = hsluv("#fce094"), -- NvimLightYellow
    water = hsluv(236, 64, 61), -- zenbones' blue; NvimLightBlue #a6dbff sits too close to the text
    blossom = hsluv("#ffcaff"), -- NvimLightMagenta
    sky = hsluv("#8cf8f7"), -- NvimLightCyan
  }, bg)
end

-- Generate the lush specs using the generator util
local generator = require("zenbones.specs")

-- zenbones reads options from `vim.g.<colors_name>`; default transparency on and italic
-- strings off here (the default theme uses bold/non-bold, never italics), both still
-- overridable with `vim.g.nvimbones_transparent_background = false` /
-- `vim.g.nvimbones_italic_strings = true`.
local config = generator.get_global_config(colors_name, bg)
if config.transparent_background == nil then
  config.transparent_background = true
end
if config.italic_strings == nil then
  config.italic_strings = false
end

local base_specs = generator.generate(palette, bg, config)

-- Optionally extend specs using Lush: the default theme's accents on top of the zenbones
-- hierarchy (bold statements, dimmed identifiers, gray types/delimiters, dim comments).
-- Treesitter and LSP captures chain off these legacy groups; `@variable` is pinned back to the
-- plain dimmed identifier so only fields, properties and constants take the blue, as in the
-- default theme.
local specs = lush.extends({ base_specs }).with(function(injected)
  local sym = injected.sym
  return {
    Function({ fg = palette.sky }), -- cyan functions
    Special({ fg = palette.sky }), -- cyan builtins, escapes, tags
    String({ base_specs.String, fg = palette.leaf }), -- green strings
    Identifier({ fg = palette.water }), -- blue fields, properties, constants
    sym("@variable")({ fg = base_specs.Identifier.fg }), -- plain variables keep the dimmed fg
  }
end)

-- Pass the specs to lush to apply
lush(specs)

-- Optionally set term colors
require("zenbones.term").apply_colors(palette)
