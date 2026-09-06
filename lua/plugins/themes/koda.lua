local pack = require("config.pack")
pack.add({ "oskarnurm/koda.nvim" })

require("koda").setup({
  transparent = true,

  -- Moss tints every surface with green (`line` = #182325), which clashes with the
  -- neutral terminal background showing through (ghostty Srcery, #1c1b19). Overriding
  -- `line` neutralizes CursorLine, CursorColumn, ColorColumn, PmenuSel and TabLineSel
  -- in one place instead of patching each group below.
  colors = {
    moss = { line = "#282828" },
  },

  on_highlights = function(hl, c)
    -- Selection: desaturated steel blue. Warm hues turn brown at the low lightness a
    -- selection needs; blue keeps its hue when dark, and reads clearly against both the
    -- background and the neutral CursorLine above.
    hl.Visual = { bg = "#2b4257" }
    -- Search links to Visual by default. Keep matches in the warm family instead, so they
    -- never read as a selection: dim amber for all matches, and CurSearch (-> DiffChange)
    -- stays bright orange for the one under the cursor.
    hl.Search = { bg = "#4a3a1e", fg = c.fg }
  end,
})
