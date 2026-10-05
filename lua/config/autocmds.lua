-- Autocmds that are not tied to a plugin (plugin autocmds live in the plugin's file).

local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- Reload files changed by a terminal job such as lazygit ('autoread'; Neovim checks on FocusGained itself)
vim.api.nvim_create_autocmd({ "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Equalize splits in every tab when the terminal is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Reopen a file at the last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(ev)
    local buf = ev.buf
    if vim.bo[buf].filetype == "gitcommit" or vim.b[buf].user_last_loc then
      return
    end
    vim.b[buf].user_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close helper buffers with q and delete them (checkhealth's own q leaves health:// listed; man has its own q)
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "checkhealth", "gitsigns-blame", "grug-far", "help", "qf" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        pcall(vim.cmd.close) -- E444 in the last window: the buffer still goes
        pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
      end, { buf = ev.buf, silent = true, desc = "Quit buffer" })
    end)
  end,
})

-- Keep man pages opened inline out of the buffer list
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = "man",
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
  end,
})

-- Create missing parent directories on save, not for URLs such as scp:// (:h ++p)
vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(ev)
    if not ev.match:find("://", 1, true) then
      vim.fn.mkdir(vim.fn.fnamemodify(ev.match, ":p:h"), "p")
    end
  end,
})
