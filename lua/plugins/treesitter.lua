-- nvim-treesitter (main branch): parser management. Highlighting, indentation and folds are
-- provided by Neovim itself and enabled per buffer below.
-- Parsers are installed into ~/.local/share/nvim/site/parser (:TSInstall <lang>, :TSUpdate).
local pack = require("config.pack")
pack.add({ { "nvim-treesitter/nvim-treesitter", version = "main" } })

local ensure_installed = {
  "bash",
  "c",
  "css",
  "diff",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "jsonc",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "printf",
  "python",
  "query",
  "regex",
  "scss",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

local TS = require("nvim-treesitter")
TS.setup({})

-- Install missing parsers after startup (needs the tree-sitter CLI from mason, a C compiler, curl, tar)
pack.later(function()
  local have = TS.get_installed("parsers")
  local missing = vim.tbl_filter(function(lang)
    return not vim.list_contains(have, lang)
  end, ensure_installed)
  if #missing > 0 then
    TS.install(missing, { summary = true })
  end
end)

-- Enable treesitter features for buffers whose language has a parser
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not lang then
      return
    end
    -- language.add() *returns* nil + message when the parser is missing, it does not raise,
    -- so pcall() alone is not a guard: check the return value or query.get() below throws.
    local ok, added = pcall(vim.treesitter.language.add, lang)
    if not ok or not added then
      return
    end
    local function query(name)
      return vim.treesitter.query.get(lang, name) ~= nil
    end

    if query("highlights") then
      pcall(vim.treesitter.start, ev.buf, lang)
    end
    if query("indents") then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
    if query("folds") then
      vim.wo[0][0].foldmethod = "expr"
      vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})
