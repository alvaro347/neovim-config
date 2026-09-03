-- vscode2026: your own theme, developed locally (:colorscheme vscode2026).
-- A local directory is not managed by vim.pack; it is added to the runtimepath directly.
local dir = "/home/alvaro/Nextcloud/Programming/VSCode2026/vscode2026.nvim"
if vim.uv.fs_stat(dir) then
  vim.opt.rtp:prepend(dir)
  require("vscode2026").setup({
    transparent = false,
    theme = "dark",
  })
end
