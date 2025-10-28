-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Sets default file explorer to leader pv
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>pr", vim.cmd.Rex)

-- Move selected lines up and down with J and K
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor position when appending line with J
vim.keymap.set("n", "J", "mzJ`z")

-- Keep cursor in the middle when jumping half page
if vim.fn.has("macunix") then
  vim.keymap.set("n", "<D-d>", "<C-d>zz")
  vim.keymap.set("n", "<D-u>", "<C-u>zz")
else
  vim.keymap.set("n", "<C-d>", "<C-d>zz")
  vim.keymap.set("n", "<C-u>", "<C-u>zz")
end

-- Keep cursor in the middle when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Yank to clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Preserve yank after pasting
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Color picker
vim.keymap.set("n", "<leader>cp", vim.cmd.CccPick)

-- Rename type / symbol
vim.keymap.set("n", "<leader>R", vim.lsp.buf.rename, { desc = "LSP Rename" })

-- Move between projects
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- -- Tabs
-- vim.keymap.set("n", "<leader>bd", ":bd<CR>", { desc = "Buffer: Close current buffer" })

-- Ripgrep for searching inside files
local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<leader>fa", ":lua require('fzf-lua').grep()<CR>", opts)
