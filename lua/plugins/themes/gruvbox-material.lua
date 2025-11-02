return {
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      -- Enable true colors
      vim.opt.termguicolors = true

      -- Use dark background (you can change to 'light' if you prefer)
      vim.opt.background = "dark"

      -- Gruvbox Material options
      vim.g.gruvbox_material_background = "medium" -- can be 'hard', 'medium', or 'soft'
      vim.g.gruvbox_material_foreground = "mix" -- can be 'material', 'mix' or 'original'
      -- vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_transparent_background = 1 -- transparent background
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_diagnostic_text_highlight = 0
      vim.g.gruvbox_material_diagnostic_line_highlight = 1
      vim.g.gruvbox_material_diagnostic_virtual_text = 0

      -- Create autocmd to customize highlights after colorscheme loads
      -- vim.api.nvim_create_autocmd("ColorScheme", {
      --   group = vim.api.nvim_create_augroup("custom_highlights_gruvboxmaterial", {}),
      --   pattern = "gruvbox-material",
      --   callback = function()
      --     local config = vim.fn["gruvbox_material#get_configuration"]()
      --     local palette =
      --       vim.fn["gruvbox_material#get_palette"](config.background, config.foreground, config.colors_override)
      --
      --     -- Override LSP reference highlights with subtle background only
      --     -- Using actual hex colors instead of palette to work with transparent mode
      --     vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#3a3735" })
      --     vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#3a3735" })
      --     vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#3a3735" })
      --
      --     -- Change yank highlight to orange (uses IncSearch highlight group)
      --     vim.api.nvim_set_hl(0, "IncSearch", { bg = "#d65d0e", fg = "#282828" })
      --   end,
      -- })
    end,
  },
}
