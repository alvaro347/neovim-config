local colors_name = "ayubones"
vim.g.colors_name = colors_name -- Required when defining a colorscheme

local lush = require("lush")
local hsluv = lush.hsluv -- Human-friendly hsl
local util = require("zenbones.util")

-- Dark only: there is no light counterpart for this palette, so ignore `&background`.
local bg = "dark"

-- Based on ayu Dark with the blue cast taken out of the backgrounds
-- https://github.com/Shatur/neovim-ayu/blob/master/lua/ayu/colors.lua
--
-- The theme runs transparent by default, so `bg` only drives the derived UI chrome
-- (cursorline, statusline, popups, line numbers, diff). It sits at the same lightness as
-- zenbones' own background so that chrome stays visible over a dark terminal; ayu's real
-- near-black is kept as bg_stark (`vim.g.ayubones = { darkness = "stark" }`) and the
-- Mirage background as bg_warm.
local palette = util.palette_extend({
  bg = hsluv("#1a1a1a"), -- neutral gray
  bg_stark = hsluv("#101010"), -- ayu bg #0b0e14, neutralized
  bg_warm = hsluv("#222222"), -- mirage bg #1f2430, neutralized
  fg = hsluv(75, 18, 86), -- ayu fg #bfbdb6 is (75, 7, 77); warmed and lifted like the official palettes
  rose = hsluv("#f07178"), -- markup
  leaf = hsluv("#aad94c"), -- string
  wood = hsluv("#ff8f40"), -- keyword (also ayu's warning color)
  water = hsluv("#59c2ff"), -- entity
  blossom = hsluv("#d2a6ff"), -- constant
  sky = hsluv("#39bae6"), -- tag
  sky1 = hsluv("#95e6cb"), -- regexp
  gold = hsluv("#ffb454"), -- func
}, bg)

-- Generate the lush specs using the generator util
local generator = require("zenbones.specs")

-- zenbones reads options from `vim.g.<colors_name>`; default transparency on here,
-- still overridable with `vim.g.ayubones_transparent_background = false`.
local config = generator.get_global_config(colors_name, bg)
if config.transparent_background == nil then
  config.transparent_background = true
end

local base_specs = generator.generate(palette, bg, config)

-- Optionally extend specs using Lush. zenbones keeps syntax monochrome (bold statements,
-- italic strings, dimmed identifiers, gray types/delimiters); like the official variants,
-- only a handful of legacy groups get an accent. Treesitter and LSP captures chain off these.
local specs = lush.extends({ base_specs }).with(function(injected)
  local sym = injected.sym
  return {
    Statement({ base_specs.Statement, fg = palette.wood }), -- orange keywords, bold
    Function({ fg = palette.gold }), -- ayu's gold functions
    Type({ fg = palette.water }), -- entity blue
    Number({ fg = palette.blossom }), -- purple constants
    Special({ fg = palette.sky1 }), -- teal regexp, escapes, builtins, tags
    sym("@markup.raw")({ fg = palette.gold }), -- inline code and code blocks (ayu uses its tan `special`; gold is the nearest palette color); @markup.raw.block follows
    sym("@markup.raw.markdown")({ fg = palette.gold }),
    markdownCode({ fg = palette.gold }),
    -- Diagnostics and spelling never recolor the text: underline/strikethrough only (zenbones
    -- paints misspelled words rose and unused code yellow)
    SpellBad({ gui = "undercurl", sp = palette.rose }),
    SpellCap({ gui = "undercurl", sp = palette.rose.da(10) }),
    SpellLocal({ gui = "undercurl", sp = palette.rose.da(10) }),
    SpellRare({ gui = "undercurl", sp = palette.wood }),
    DiagnosticUnnecessary({ base_specs.Comment }),
    DiagnosticDeprecated({ gui = "strikethrough", sp = palette.wood }),
  }
end)

-- Pass the specs to lush to apply
lush(specs)

-- Optionally set term colors
require("zenbones.term").apply_colors(palette)
