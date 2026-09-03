-- undotree: visualize the undo history (<leader>u).
local pack = require("config.pack")
pack.add({ "mbbill/undotree" })

vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undotree" })
