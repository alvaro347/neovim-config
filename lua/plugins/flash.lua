-- flash: jump anywhere with `s` + label, treesitter selection with `S`, enhanced f/t/search.
-- <c-space>/<bs> grow/shrink the selection by treesitter node (Neovim's own `an`/`in`).
local pack = require("config.pack")
pack.add({ "folke/flash.nvim" })

pack.later(function()
  require("flash").setup({})
end)

local map = vim.keymap.set
-- stylua: ignore start
map({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash" })
-- no "x": visual S belongs to vim-surround (surround the selection)
map({ "n", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
map("o", "r", function() require("flash").remote() end, { desc = "Remote Flash" })
map({ "o", "x" }, "R", function() require("flash").treesitter_search() end, { desc = "Treesitter Search" })
map("c", "<c-s>", function() require("flash").toggle() end, { desc = "Toggle Flash Search" })
-- stylua: ignore end

-- only with a parser: elsewhere `an`/`in` fall back to LSP selectionRange and warn
local function has_parser()
  return vim.treesitter.get_parser(nil, nil, { error = false }) ~= nil
end
map("n", "<c-space>", function()
  local count = vim.v.count1 -- :normal resets v:count
  if has_parser() then
    vim.cmd("normal! v")
    vim.treesitter.select("parent", count) -- = `v[count]an`
  end
end, { desc = "Start Selection" })
map({ "x", "o" }, "<c-space>", function()
  if has_parser() then
    vim.treesitter.select("parent", vim.v.count1) -- = `an`
  end
end, { desc = "Grow Selection" })
map("x", "<bs>", function()
  if has_parser() then
    return vim.treesitter.select("child", vim.v.count1) -- = `in`
  end
  vim.api.nvim_feedkeys(vim.v.count1 .. vim.keycode("<bs>"), "n", false) -- Visual <BS>: left
end, { desc = "Shrink Selection" })
