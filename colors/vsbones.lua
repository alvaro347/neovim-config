local colors_name = "vsbones"
vim.g.colors_name = colors_name -- Required when defining a colorscheme

local lush = require("lush")
local hsluv = lush.hsluv -- Human-friendly hsl
local util = require("zenbones.util")

-- Dark only: there is no light counterpart for this palette, so ignore `&background`.
local bg = "dark"

-- Based on VSCode "Dark Modern 2026" as ported by D0nw0r/dark2026.nvim: red-forward, with
-- red keywords, operators and control flow, purple functions, teal types, blue numbers.
--
-- The theme runs transparent by default, so `bg` only drives the derived UI chrome
-- (cursorline, statusline, popups, line numbers, diff). It uses VSCode's panel/statusbar
-- surface, which sits at the same lightness as zenbones' own background so that chrome stays
-- visible over a dark terminal; the near-black editor background is kept as bg_stark
-- (`vim.g.vsbones = { darkness = "stark" }`) and the widget surface as bg_warm.
local palette = util.palette_extend({
  bg = hsluv("#191a1b"), -- sideBar / statusBar / panel.background
  bg_stark = hsluv("#121314"), -- editor.background
  bg_warm = hsluv("#202122"), -- editorWidget.background
  fg = hsluv(230, 6, 84), -- editor.foreground #bbbebf lifted from L77 to L84, faintly cool, near neutral
  rose = hsluv("#ff7b72"), -- keyword / storage
  leaf = hsluv("#7ee787"), -- entity.name.tag / regexp
  wood = hsluv("#ffa657"), -- variable / parameter
  water = hsluv("#79c0ff"), -- constant / support
  blossom = hsluv("#d2a8ff"), -- entity.name.function
  sky = hsluv("#4ec9b0"), -- entity.name.type
}, bg)

-- Generate the lush specs using the generator util
local generator = require("zenbones.specs")

-- zenbones reads options from `vim.g.<colors_name>`; default transparency on here,
-- still overridable with `vim.g.vsbones_transparent_background = false`.
local config = generator.get_global_config(colors_name, bg)
if config.transparent_background == nil then
  config.transparent_background = true
end

local base_specs = generator.generate(palette, bg, config)

-- Optionally extend specs using Lush. zenbones keeps syntax monochrome (bold statements,
-- italic strings, dimmed identifiers, gray types/delimiters); like the official variants,
-- only a handful of legacy groups get an accent. Treesitter and LSP captures chain off these:
-- PreProc and @operator inherit Statement, which gives dark2026's red import/return/operators.
local specs = lush.extends({ base_specs }).with(function(injected)
  local sym = injected.sym
  return {
    Statement({ base_specs.Statement, fg = palette.rose }), -- red keywords, bold
    Function({ fg = palette.blossom }), -- purple functions
    Type({ fg = palette.sky }), -- teal types
    Number({ fg = palette.water }), -- blue numbers
    Special({ fg = palette.leaf }), -- green tags, regexp, escapes, builtins
    sym("@markup.raw")({ fg = palette.water }), -- inline code and code blocks (dark2026 uses the string/constant blue); @markup.raw.block follows
    sym("@markup.raw.markdown")({ fg = palette.water }),
    markdownCode({ fg = palette.water }),
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
