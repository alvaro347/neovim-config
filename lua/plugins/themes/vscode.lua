-- vscode.nvim (:colorscheme vscode)
local pack = require("config.pack")
pack.add({ "Mofiqul/vscode.nvim" })

require("vscode").setup({
  transparent = true,
})
