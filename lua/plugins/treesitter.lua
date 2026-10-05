-- nvim-treesitter (main branch): installs parsers into stdpath("data")/site/parser (:TSInstall <lang>,
-- :TSUpdate). Highlighting, indentation and folds are Neovim's own, enabled per buffer below.
local pack = require("config.pack")
pack.add({ "nvim-treesitter/nvim-treesitter" })

local ensure_installed = {
  "bash",
  "c",
  "css",
  "dart",
  "diff",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "printf",
  "proto",
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
  "zsh",
}

-- Install missing parsers after startup (needs the tree-sitter CLI from mason, a C compiler, curl, tar)
pack.later(function()
  local TS = require("nvim-treesitter")
  local have = TS.get_installed("parsers")
  local missing = vim.tbl_filter(function(lang)
    return not vim.list_contains(have, lang)
  end, ensure_installed)
  if #missing > 0 then
    TS.install(missing, { summary = true })
  end
end)

local group = vim.api.nvim_create_augroup("user_treesitter", { clear = true })

-- :PackUpdate changed nvim-treesitter: rebuild the parsers whose revision changed (lazy.nvim's
-- `build = ":TSUpdate"`). update() rereads the parser list from disk and runs async.
vim.api.nvim_create_autocmd("PackChanged", {
  group = group,
  callback = function(ev)
    if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
      require("nvim-treesitter").update(nil, { summary = true })
    end
  end,
})

local function expr_folds(win)
  vim.wo[win][0].foldmethod = "expr"
  vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
end

-- Enable treesitter features for buffers whose language has a parser
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not lang then
      return
    end
    -- language.add() *returns* nil + message when the parser is missing, it does not raise
    local ok, added = pcall(vim.treesitter.language.add, lang)
    if not ok or not added then
      return
    end
    -- get_files() only checks that a query exists; it is compiled on first use
    local function has(query)
      return #vim.treesitter.query.get_files(lang, query) > 0
    end

    if has("highlights") then
      pcall(vim.treesitter.start, ev.buf, lang)
    end
    if has("indents") then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
    if has("folds") then
      local shown = false
      for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
        if vim.fn.win_gettype(win) ~= "autocmd" then
          shown = true
          expr_folds(win)
        end
      end
      -- loaded hidden (bufload, :badd): no window has fold options for it yet, see BufWinEnter
      vim.b[ev.buf].ts_folds_pending = not shown or nil
    end
  end,
})

-- Folds are window options. A buffer loaded hidden gets them when it is first shown; after that
-- Neovim carries them to other windows with the buffer. A modeline's foldmethod is kept, and so
-- is a later :setlocal foldmethod when the buffer comes back to a window.
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = group,
  callback = function(ev)
    -- normal windows only: bufload() also fires BufWinEnter, in its hidden autocommand window
    if vim.b[ev.buf].ts_folds_pending and vim.fn.win_gettype() == "" then
      vim.b[ev.buf].ts_folds_pending = nil
      if vim.wo.foldmethod == vim.go.foldmethod then
        expr_folds(0)
      end
    end
  end,
})
