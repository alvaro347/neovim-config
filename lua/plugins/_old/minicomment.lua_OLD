-- mini.comment (from mini.nvim): gc/gcc comments, <leader>cc comments the current line.
-- Uses nvim-ts-context-commentstring (plugins/tscontextcommentstring.lua) for embedded languages.
local pack = require("config.pack")
pack.add({ "nvim-mini/mini.nvim" })

pack.later(function()
  require("mini.comment").setup({
    options = {
      custom_commentstring = function()
        return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
      end,
    },
    mappings = {
      comment_line = " cc",
    },
  })
end)
