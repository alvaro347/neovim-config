-- nvim-treesitter-textobjects (main branch), in buffers whose language has textobjects queries:
-- ]f/[f function, ]c/[c class, ]a/[a argument moves, and af/if, ac/ic, aa/ia selections (x, o).
-- The other a/i textobjects are Neovim's own (aw, ap, a(, a", at, an/in, ...).
local pack = require("config.pack")
pack.add({ { "nvim-treesitter/nvim-treesitter-textobjects", version = "main" } })

local moves = {
  goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
  goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
  goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
  goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
}
local selects = {
  af = "@function.outer",
  ["if"] = "@function.inner",
  ac = "@class.outer",
  ic = "@class.inner",
  aa = "@parameter.outer",
  ia = "@parameter.inner",
}

pack.later(function()
  require("nvim-treesitter-textobjects").setup({ move = { set_jumps = true } })

  local function attach(buf)
    local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
    if not lang then
      return
    end
    -- language.add() *returns* nil when the parser is missing; get_files() checks for the query
    -- without compiling it (that waits until the first move)
    local ok, added = pcall(vim.treesitter.language.add, lang)
    if not ok or not added or #vim.treesitter.query.get_files(lang, "textobjects") == 0 then
      return
    end
    for method, keys in pairs(moves) do
      for lhs, query in pairs(keys) do
        local desc = query:gsub("@", ""):gsub("%..*", "")
        desc = (lhs:sub(1, 1) == "[" and "Prev " or "Next ") .. desc:sub(1, 1):upper() .. desc:sub(2)
        desc = desc .. (lhs:sub(2, 2) == lhs:sub(2, 2):upper() and " End" or " Start")
        vim.keymap.set({ "n", "x", "o" }, lhs, function()
          -- in diff mode ]c/[c keep their native meaning (next/previous change)
          if vim.wo.diff and lhs:find("[cC]") then
            return vim.cmd("normal! " .. lhs)
          end
          require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
        end, { buf = buf, desc = desc, silent = true })
      end
    end
    for lhs, query in pairs(selects) do
      local object, part = query:match("^@(%a+)%.(%a+)$")
      vim.keymap.set({ "x", "o" }, lhs, function()
        require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
      end, { buf = buf, desc = object .. " (" .. part .. ")", silent = true })
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
