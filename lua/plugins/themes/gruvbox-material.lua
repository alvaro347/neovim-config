-- gruvbox-material (:colorscheme gruvbox-material). Options are vim.g.* variables read by its colors file.
local pack = require("config.pack")
pack.lazy({ "sainnhe/gruvbox-material" }, {}, function()
  vim.g.gruvbox_material_foreground = "mix"
  vim.g.gruvbox_material_enable_italic = 1
  vim.g.gruvbox_material_transparent_background = 1
  vim.g.gruvbox_material_better_performance = 1
  vim.g.gruvbox_material_diagnostic_line_highlight = 1
  vim.g.gruvbox_material_diagnostic_virtual_text = "highlighted"

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("custom_highlights_gruvboxmaterial", {}),
    pattern = "gruvbox-material",
    callback = function()
      -- Subtle LSP references; hex colours so they also work with the transparent background
      for _, group in ipairs({ "LspReferenceText", "LspReferenceRead", "LspReferenceWrite" }) do
        vim.api.nvim_set_hl(0, group, { bg = "#3a3735" })
      end
      vim.api.nvim_set_hl(0, "IncSearch", { bg = "#d65d0e", fg = "#282828" }) -- orange yank highlight
    end,
  })
end)
