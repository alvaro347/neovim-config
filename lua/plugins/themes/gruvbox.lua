return {
  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      terminal_colors = true,
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
      },
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = true,
      contrast = "soft",
      palette_overrides = {},
      overrides = {
        -- Override LSP reference highlighting
        LspReferenceText = { bg = "#4d4d46" }, -- Slightly darker background
        LspReferenceRead = { bg = "#3c3836" },
        LspReferenceWrite = { bg = "#3c3836" },
      },
      dim_inactive = false,
      transparent_mode = true,
    },
  },
}
