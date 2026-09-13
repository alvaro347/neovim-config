local colors_name = "moonbones3"
vim.g.colors_name = colors_name -- Required when defining a colorscheme

local lush = require("lush")
local hsluv = lush.hsluv -- Human-friendly hsl
local util = require("zenbones.util")

-- Dark only: an amber console has no light mode.
local bg = "dark"

-- Retro-future, own pick: an amber-phosphor console read by moonlight. Amber (the P3 tube, the
-- Nostromo, every 70s mission panel) is the machine: keywords, operators, imports, builtins,
-- escapes, code samples, search. Function names are moonlight ice blue, types a dusty lilac in
-- italic, and the text is warm ivory on warm black, like a printed mission manual; strings and
-- comments keep zenbones' italics, since this one is typeset rather than a tube.
--
-- The theme runs transparent by default, so `bg` only drives the derived UI chrome, which
-- inherits the warm cast (cursorline, statusline, popups, line numbers, comments, diff). It
-- sits at L9 so the chrome stays visible over a dark terminal; a truer black is kept as
-- bg_stark (`vim.g.moonbones3 = { darkness = "stark" }`).
local amber = hsluv(52, 100, 78) -- #fdb300
local ice = hsluv(228, 70, 82) -- #9ed3f0
local palette = util.palette_extend({
  bg = hsluv(50, 18, 9), -- #1c1916, warm black
  bg_stark = hsluv(50, 18, 5), -- #13100e
  bg_warm = hsluv(50, 20, 14), -- #28231f
  fg = hsluv(60, 18, 89), -- #e6dfd5, warm ivory
  rose = hsluv(12, 85, 62), -- #f4696a, alert red: errors, deletions
  leaf = hsluv(137, 40, 70), -- #84b791, sage: additions, ok
  wood = amber, -- Statement, Special, code, warnings
  water = ice, -- Function, changes, info
  blossom = amber, -- Search, matches
  sky = ice,
  lilac = hsluv(285, 45, 76), -- #c6b4db: Type, hints
}, bg)

-- Generate the lush specs using the generator util
local generator = require("zenbones.specs")

-- zenbones reads options from `vim.g.<colors_name>`; default transparency on here,
-- still overridable with `vim.g.moonbones3_transparent_background = false`.
local config = generator.get_global_config(colors_name, bg)
if config.transparent_background == nil then
  config.transparent_background = true
end

local base_specs = generator.generate(palette, bg, config)

-- Optionally extend specs using Lush. zenbones keeps syntax monochrome (bold statements,
-- italic strings, dimmed identifiers, gray types/delimiters); like the official variants,
-- only a handful of legacy groups get an accent. Treesitter and LSP captures chain off these:
-- PreProc and @operator inherit Statement, so imports and operators share the keyword amber.
local specs = lush.extends({ base_specs }).with(function(injected)
  local sym = injected.sym
  return {
    Statement({ base_specs.Statement, fg = palette.wood }), -- amber bold keywords
    Function({ fg = palette.water }), -- ice-blue functions
    Type({ fg = palette.lilac, gui = "italic" }), -- lilac types
    Special({ fg = palette.wood }), -- amber builtins, escapes, tags (plain, against the bold keywords)
    sym("@markup.raw")({ fg = palette.wood }), -- inline code and code blocks; @markup.raw.block follows
    sym("@markup.raw.markdown")({ fg = palette.wood }),
    markdownCode({ fg = palette.wood }),
    DiagnosticHint({ fg = palette.lilac }), -- zenbones paints hints blossom, the warning amber here
    MatchParen({ bg = base_specs.Visual.bg, gui = "bold" }), -- neutral pair highlight; zenbones links it to Search
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
