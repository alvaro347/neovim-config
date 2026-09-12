local colors_name = "onebones"
vim.g.colors_name = colors_name -- Required when defining a colorscheme

local lush = require("lush")
local hsluv = lush.hsluv -- Human-friendly hsl
local util = require("zenbones.util")

-- Dark only: there is no light counterpart for this palette, so ignore `&background`.
local bg = "dark"

-- Based on onedark.nvim's `warm` style with the blue cast taken out of the backgrounds
-- https://github.com/navarasu/onedark.nvim/blob/master/lua/onedark/palette.lua
-- bg_stark/bg_warm are the `warmer` bg0 / `warm` bg1 surfaces, so
-- `vim.g.onebones = { darkness = "stark" | "warm" }` keeps working.
local palette = util.palette_extend({
  bg = hsluv("#2c2c2c"), -- warm bg0 #2c2d30, neutralized
  bg_stark = hsluv("#232323"), -- warmer bg0 #232326, neutralized
  bg_warm = hsluv("#353535"), -- warm bg1 #35373b, neutralized
  fg = hsluv(64, 16, 84), -- warm cream: onedark warm's bg_yellow #e6cfa1 hue, desaturated; its own fg #b1b4b9 is a cool gray
  rose = hsluv("#e16d77"),
  leaf = hsluv("#99bc80"),
  wood = hsluv("#dfbe81"),
  water = hsluv("#68aee8"),
  blossom = hsluv("#c27fd7"),
  sky = hsluv("#5fafb9"),
  orange = hsluv("#c99a6e"), -- numbers
}, bg)

-- Generate the lush specs using the generator util
local generator = require("zenbones.specs")

-- zenbones reads options from `vim.g.<colors_name>`; default transparency on here,
-- still overridable with `vim.g.onebones_transparent_background = false`.
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
    Statement({ base_specs.Statement, fg = palette.blossom }), -- purple keywords, bold
    Function({ fg = palette.water }), -- onedark's blue functions
    Type({ fg = palette.wood }), -- yellow types
    Number({ fg = palette.orange }),
    Special({ fg = palette.sky }), -- builtins, escapes, tags
    sym("@markup.raw")({ fg = palette.leaf }), -- inline code and code blocks (onedark uses its green); @markup.raw.block follows
    sym("@markup.raw.markdown")({ fg = palette.leaf }),
    markdownCode({ fg = palette.leaf }),
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
