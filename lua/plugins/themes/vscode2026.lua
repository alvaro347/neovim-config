-- vscode2026: your own theme, developed locally (:colorscheme vscode2026). Not a vim.pack plugin:
-- appended to 'runtimepath' (after your config) so completion finds it, set up on first use.
local dir = "/home/alvaro/Nextcloud/Programming/VSCode2026/vscode2026.nvim"
if vim.uv.fs_stat(dir) then
  vim.opt.rtp:append(dir)
  vim.api.nvim_create_autocmd("ColorSchemePre", {
    pattern = "vscode2026*",
    once = true,
    callback = function()
      require("vscode2026").setup({ theme = "dark" })
    end,
  })
end
