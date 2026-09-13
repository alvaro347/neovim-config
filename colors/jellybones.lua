local colors_name = "jellybones"
vim.g.colors_name = colors_name -- Required when defining a colorscheme

local lush = require("lush")
local hsluv = lush.hsluv -- Human-friendly hsl
local util = require("zenbones.util")

-- Dark only: there is no light counterpart for this palette, so ignore `&background`.
local bg = "dark"

-- Based on jellybeans (nanotech/jellybeans.vim, and the metalelf0/jellybeans-nvim lush port):
-- ship-cove blue keywords, goldenrod functions, koromiko types, raw-sienna constants,
-- green-smoke strings and wewak-pink search matches.
--
-- The theme runs transparent by default, so `bg` only drives the derived UI chrome
-- (cursorline, statusline, popups, line numbers, diff). It uses jellybeans' even indent-guide
-- shade, which sits at the same lightness as zenbones' own background so that chrome stays
-- visible over a dark terminal; jellybeans' real near-black is kept as bg_stark
-- (`vim.g.jellybones = { darkness = "stark" }`) and the odd indent-guide shade as bg_warm.
local palette = util.palette_extend({
  bg = hsluv("#1b1b1b"), -- IndentGuidesEven
  bg_stark = hsluv("#151515"), -- Normal bg
  bg_warm = hsluv("#232323"), -- IndentGuidesOdd
  fg = hsluv("#e8e8d3"), -- Normal fg, jellybeans' own warm cream
  rose = hsluv("#cf6a4c"), -- raw sienna: Constant (jellybeans has no true red)
  leaf = hsluv("#99ad6a"), -- green smoke: String
  wood = hsluv("#ffb964"), -- koromiko: Type (also the port's warning color)
  water = hsluv("#8197bf"), -- ship cove: Statement
  blossom = hsluv("#f0a0c0"), -- wewak: Search / MatchParen
  sky = hsluv("#8fbfdc"), -- morning glory: PreProc / Structure
  gold = hsluv("#fad07a"), -- goldenrod: Function
  highland = hsluv("#799d6a"), -- highland: Special
}, bg)

-- Generate the lush specs using the generator util
local generator = require("zenbones.specs")

-- zenbones reads options from `vim.g.<colors_name>`; default transparency on here,
-- still overridable with `vim.g.jellybones_transparent_background = false`.
local config = generator.get_global_config(colors_name, bg)
if config.transparent_background == nil then
  config.transparent_background = true
end

local base_specs = generator.generate(palette, bg, config)

-- Optionally extend specs using Lush. zenbones keeps syntax monochrome (bold statements,
-- italic strings, dimmed identifiers, gray types/delimiters); like the official variants,
-- only a handful of legacy groups get an accent. Treesitter and LSP captures chain off these:
-- PreProc and @operator inherit Statement, so imports and operators share the keyword blue.
local specs = lush.extends({ base_specs }).with(function(injected)
  local sym = injected.sym
  return {
    Statement({ base_specs.Statement, fg = palette.water }), -- ship-cove keywords, bold
    Function({ fg = palette.gold }), -- goldenrod functions
    Type({ fg = palette.wood, gui = "italic" }), -- koromiko types, italic like the lush port
    Number({ fg = palette.rose }), -- raw-sienna numbers
    Special({ fg = palette.highland }), -- muted green escapes, regexp, builtins, tags
    sym("@markup.raw")({ fg = palette.leaf }), -- inline code and code blocks (jellybeans leaves them unstyled; borrow the string green like gruvbox); @markup.raw.block follows
    sym("@markup.raw.markdown")({ fg = palette.leaf }),
    markdownCode({ fg = palette.leaf }),
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
