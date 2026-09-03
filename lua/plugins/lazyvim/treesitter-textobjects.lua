-- nvim-treesitter-textobjects (main branch): ]f/[f function, ]c/[c class, ]a/[a argument moves.
-- Selection textobjects (af/if, ac/ic, ...) are provided by mini.ai (plugins/miniai.lua).
local pack = require("config.pack")
pack.add({ { "nvim-treesitter/nvim-treesitter-textobjects", version = "main" } })

local moves = {
  goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
  goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
  goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
  goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
}

pack.later(function()
  require("nvim-treesitter-textobjects").setup({ move = { set_jumps = true } })

  local function attach(buf)
    local ft = vim.bo[buf].filetype
    local lang = vim.treesitter.language.get_lang(ft)
    if
      not lang
      or not pcall(vim.treesitter.language.add, lang)
      or not vim.treesitter.query.get(lang, "textobjects")
    then
      return
    end
    for method, keys in pairs(moves) do
      for lhs, query in pairs(keys) do
        local desc = query:gsub("@", ""):gsub("%..*", "")
        desc = (lhs:sub(1, 1) == "[" and "Prev " or "Next ") .. desc:sub(1, 1):upper() .. desc:sub(2)
        desc = desc .. (lhs:sub(2, 2) == lhs:sub(2, 2):upper() and " End" or " Start")
        vim.keymap.set({ "n", "x", "o" }, lhs, function()
          -- don't use treesitter if in diff mode and the key is one of the c/C keys
          if vim.wo.diff and lhs:find("[cC]") then
            return vim.cmd("normal! " .. lhs)
          end
          require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
        end, { buffer = buf, desc = desc, silent = true })
      end
    end
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("user_treesitter_textobjects", { clear = true }),
    callback = function(ev)
      attach(ev.buf)
    end,
  })
  vim.tbl_map(attach, vim.api.nvim_list_bufs())
end)
