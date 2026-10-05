-- mini.pairs (from mini.nvim): auto close brackets and quotes, also in the cmdline. Toggle: <leader>up.
-- neigh_pattern is matched against the two characters around the cursor ("\r" = line start, "\n" = line end):
-- no pair after a backslash (mini's default) or before a word character; ' also not after a letter (mini's default).
local pack = require("config.pack")
pack.add({ "nvim-mini/mini.nvim" })

pack.later(function()
  Snacks.toggle({
    name = "Mini Pairs",
    get = function()
      return not vim.g.minipairs_disable
    end,
    set = function(state)
      vim.g.minipairs_disable = not state
    end,
  }):map("<leader>up")

  -- `.*` steps over the rest of a multibyte character before the cursor
  local not_before_word = "^[^\\].*[^%w_]$"
  require("mini.pairs").setup({
    modes = { command = true },
    mappings = {
      ["("] = { neigh_pattern = not_before_word },
      ["["] = { neigh_pattern = not_before_word },
      ["{"] = { neigh_pattern = not_before_word },
      ['"'] = { neigh_pattern = not_before_word },
      ["`"] = { neigh_pattern = not_before_word },
      ["'"] = { neigh_pattern = "^[^%a\\].*[^%w_]$" },
    },
  })
end)
