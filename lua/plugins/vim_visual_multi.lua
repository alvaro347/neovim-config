-- vim-visual-multi: multiple cursors (successor of vim-multiple-cursors). <C-n> selects the word /
-- next match, \\A selects all matches. Add-cursor up/down live on <M-C-Up>/<M-C-Down> because
-- <C-Up>/<C-Down> resize windows (keymaps.lua); VM's in-mode "Select Cursor" (default on those
-- keys) is disabled so they always add a cursor.
vim.g.VM_maps = {
  ["Add Cursor Up"] = "<M-C-Up>",
  ["Add Cursor Down"] = "<M-C-Down>",
  ["Select Cursor Up"] = "",
  ["Select Cursor Down"] = "",
}

local pack = require("config.pack")
pack.add({ "mg979/vim-visual-multi" })
