local colors_name = "moonbones2"
vim.g.colors_name = colors_name -- Required when defining a colorscheme

local lush = require("lush")
local hsluv = lush.hsluv -- Human-friendly hsl
local util = require("zenbones.util")

-- Dark only: a CRT has no light mode.
local bg = "dark"

-- Retro-future moon-base terminal: a green-phosphor CRT. The console's own color (the spring
-- green of rgb(0,235,121), deepened a touch toward the tube) marks the machine's side of the
-- conversation: commands (keywords, operators, imports), builtins, code samples, directories,
-- titles, the cursor's line number, and search matches in reverse video. Readouts (numbers,
-- booleans) glow amber like a P3 tube, alerts are red, and everything else is the tube's white:
-- a phosphor-cast off-white on green-black glass. No italics; a CRT has bold and reverse only.
--
-- The theme runs transparent by default, so `bg` only drives the derived UI chrome, which
-- inherits the green cast (cursorline, statusline, popups, line numbers, comments, diff). It
-- sits at L9 so the chrome stays visible over a dark terminal; the dark tube is kept as
-- bg_stark (`vim.g.moonbones2 = { darkness = "stark" }`).
local green = hsluv(137, 100, 80) -- #00e473, the phosphor
local palette = util.palette_extend({
  bg = hsluv(137, 20, 9), -- #161b17
  bg_stark = hsluv(137, 20, 5), -- #0e120f
  bg_warm = hsluv(137, 22, 14), -- #1e2520
  fg = hsluv(137, 14, 88), -- #cde2d2, phosphor white
  rose = hsluv(12, 80, 64), -- #f07676, alert red: errors, deletions
  leaf = green, -- additions, ok
  wood = hsluv(50, 100, 77), -- #fdaf00, amber readouts: Number, Boolean, warnings
  water = hsluv(245, 35, 72), -- #9fb2cd, moonlight silver: changes, info (a second green would make DiffChange identical to DiffAdd)
  blossom = green, -- Search (reverse video), matches, hints
  sky = green, -- Statement, Special, code, titles
}, bg)

-- Generate the lush specs using the generator util
local generator = require("zenbones.specs")

-- zenbones reads options from `vim.g.<colors_name>`; defaults set here: transparent and no
-- italics, each still overridable, e.g. `vim.g.moonbones2 = { transparent_background = false }`.
local config = generator.get_global_config(colors_name, bg)
local defaults = {
  transparent_background = true,
  italic_strings = false,
  italic_comments = false,
}
for key, value in pairs(defaults) do
  if config[key] == nil then
    config[key] = value
  end
end

local base_specs = generator.generate(palette, bg, config)

-- Optionally extend specs using Lush. zenbones keeps syntax monochrome (bold statements,
-- dimmed identifiers, gray types/delimiters); like the official variants, only a handful of
-- legacy groups get an accent. Treesitter and LSP captures chain off these: PreProc and
-- @operator inherit Statement, so imports and operators share the command green.
local specs = lush.extends({ base_specs }).with(function(injected)
  local sym = injected.sym
  return {
    Statement({ base_specs.Statement, fg = palette.sky }), -- green bold commands
    Special({ base_specs.Special, fg = palette.sky }), -- green bold builtins, escapes, tags
    Number({ fg = palette.wood }), -- amber readouts
    Boolean({ fg = palette.wood }), -- amber readouts, and no italic
    Constant({ fg = base_specs.Constant.fg }), -- zenbones italicizes constants; a CRT cannot
    sym("@markup.raw")({ fg = palette.sky }), -- inline code and code blocks; @markup.raw.block follows
    sym("@markup.raw.markdown")({ fg = palette.sky }),
    markdownCode({ fg = palette.sky }),
    Title({ fg = palette.sky, gui = "bold" }),
    Directory({ fg = palette.sky, gui = "bold" }),
    CursorLineNr({ base_specs.CursorLineNr, fg = palette.sky }), -- the cursor's line number glows
    MatchParen({ bg = base_specs.Visual.bg, gui = "bold" }), -- neutral pair highlight; zenbones links it to Search
    -- Diagnostics and spelling never recolor the text: underline/strikethrough only (zenbones
    -- paints misspelled words rose and unused code yellow)
    SpellBad({ gui = "undercurl", sp = palette.rose }),
    SpellCap({ gui = "undercurl", sp = palette.wood }),
    SpellLocal({ gui = "undercurl", sp = palette.wood }),
    SpellRare({ gui = "undercurl", sp = palette.sky }),
    DiagnosticUnnecessary({ base_specs.Comment }),
    DiagnosticDeprecated({ gui = "strikethrough", sp = palette.rose }),
  }
end)

-- Pass the specs to lush to apply
lush(specs)

-- Optionally set term colors
require("zenbones.term").apply_colors(palette)
