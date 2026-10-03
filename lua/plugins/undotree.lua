-- undotree: visualize the undo history (<leader>uu; <leader>u is the UI toggles group).
local pack = require("config.pack")
pack.add({ "mbbill/undotree" })

vim.keymap.set("n", "<leader>uu", vim.cmd.UndotreeToggle, { desc = "Undotree" })
