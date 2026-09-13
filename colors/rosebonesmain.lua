local colors_name = "rosebonesmain"
vim.g.colors_name = colors_name -- Required when defining a colorscheme

local lush = require("lush")
local hsluv = lush.hsluv -- Human-friendly hsl
local util = require("zenbones.util")

-- Dark only: this is Rosé Pine Main; Dawn would be a light theme of its own, so ignore `&background`.
local bg = "dark"

-- Based on Rosé Pine Main with its real palette (rose-pine/neovim lua/rose-pine/palette.lua):
-- pine keywords, rose functions, foam types, gold numbers; love and iris stay UI colors
-- (errors, hints, search, matches). Unlike zenbones' own rosebones, the text color is Rosé
-- Pine's lavender `text`, not a rose-tinted gray.
--
-- The theme runs transparent by default, so `bg` only drives the derived UI chrome
-- (cursorline, statusline, popups, line numbers, diff). Main's base sits at the same lightness as zenbones' own
-- background, so chrome stays visible over a dark terminal (cursorline lands on Rosé Pine's
-- highlight_low); `_nc` is bg_stark (`vim.g.rosebonesmain = { darkness = "stark" }`) and
-- surface is bg_warm.
local palette = util.palette_extend({
  bg = hsluv("#191724"), -- base
  bg_stark = hsluv("#16141f"), -- _nc (non-current window)
  bg_warm = hsluv("#1f1d2e"), -- surface
  fg = hsluv("#e0def4"), -- text
  rose = hsluv("#eb6f92"), -- love: errors, deletions
  leaf = hsluv("#95b1ac"), -- leaf: additions, ok
  wood = hsluv("#f6c177"), -- gold: numbers, strings in Rosé Pine, warnings
  water = hsluv("#9ccfd8"), -- foam: types, info
  blossom = hsluv("#c4a7e7"), -- iris: hints, search, matches
  sky = hsluv("#31748f"), -- pine: keywords
  blush = hsluv("#ebbcba"), -- Rosé Pine's own `rose`: functions
}, bg)

-- Generate the lush specs using the generator util
local generator = require("zenbones.specs")

-- zenbones reads options from `vim.g.<colors_name>`; default transparency on here,
-- still overridable with `vim.g.rosebonesmain_transparent_background = false`.
local config = generator.get_global_config(colors_name, bg)
if config.transparent_background == nil then
  config.transparent_background = true
end

local base_specs = generator.generate(palette, bg, config)

-- Optionally extend specs using Lush. zenbones keeps syntax monochrome (bold statements,
-- italic strings, dimmed identifiers, gray types/delimiters); like the official variants,
-- only a handful of legacy groups get an accent. Treesitter and LSP captures chain off these.
-- Accepted deviations from Rosé Pine: PreProc and @operator inherit Statement (pine), and
-- String/Constant stay mono instead of gold.
local specs = lush.extends({ base_specs }).with(function(injected)
  local sym = injected.sym
  return {
    Statement({ base_specs.Statement, fg = palette.sky }), -- pine keywords, bold
    Function({ fg = palette.blush }), -- rose functions
    Type({ fg = palette.water }), -- foam types
    Number({ fg = palette.wood }), -- gold numbers
    Special({ fg = palette.blush }), -- builtins, escapes, tags follow functions (Rosé Pine paints @function.builtin rose)
    sym("@markup.raw")({ fg = palette.wood }), -- inline code and code blocks (Rosé Pine's transparent mode paints inline code gold); @markup.raw.block follows
    sym("@markup.raw.markdown")({ fg = palette.wood }),
    markdownCode({ fg = palette.wood }),
    MatchParen({ bg = base_specs.Visual.bg, gui = "bold" }), -- neutral pair highlight; zenbones links it to the blossom-tinted Search
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
