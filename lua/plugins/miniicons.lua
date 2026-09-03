-- mini.icons (from mini.nvim): file/filetype icons for fzf-lua, neo-tree, bufferline, lualine.
-- Loaded early from init.lua. Plugins asking for nvim-web-devicons get mini.icons instead.
local pack = require("config.pack")
pack.add({ "nvim-mini/mini.nvim" })

package.preload["nvim-web-devicons"] = function()
  require("mini.icons").mock_nvim_web_devicons()
  return package.loaded["nvim-web-devicons"]
end

require("mini.icons").setup({
  file = {
    [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
    ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
  },
  filetype = {
    dotenv = { glyph = "", hl = "MiniIconsYellow" },
  },
})
