-- Keymaps, loaded from init.lua after all plugins; plugin keymaps live next to the plugin in
-- lua/plugins/<plugin>.lua. The first block is LazyVim's layout, the second block is our own.

local map = vim.keymap.set

---------------------------------------------------------------------------
-- Defaults inherited from LazyVim
---------------------------------------------------------------------------

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines ("x", not "v": in Select mode typed keys must replace the selection)
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("x", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("x", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- buffers (<S-h>/<S-l>/[b/]b and <leader>bd/bo/bi are defined by bufferline.lua / snacks.lua)
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bD", "<cmd>bd<cr>", { desc = "Delete Buffer and Window" })

-- Clear search and stop snippet on escape
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  vim.snippet.stop()
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- Clear search, diff update and redraw (Neovim's default <C-l>, which moves windows here)
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / Clear hlsearch / Diff Update" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
-- (also keeps the cursor in the middle of the screen)
map("n", "n", "'Nn'[v:searchforward].'zzzv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zzzv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

--keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- better indenting
map("x", "<", "<gv", { desc = "Indent Left" })
map("x", ">", ">gv", { desc = "Indent Right" })

-- commenting (native gc/gcc; ts-comments supplies commentstrings for embedded languages)
map("n", "<leader>cc", "gcc", { remap = true, desc = "Comment Line" })
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- plugin manager (was <leader>l -> :Lazy)
map("n", "<leader>l", "<cmd>PackStatus<cr>", { desc = "Plugins (vim.pack)" })
map("n", "<leader>L", "<cmd>PackUpdate<cr>", { desc = "Update Plugins (vim.pack)" })

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- location list
map("n", "<leader>xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location List" })

-- quickfix list
map("n", "<leader>xq", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix List" })

-- [q / ]q are defined by trouble.lua (fall back to cprev/cnext when trouble is closed)

-- diagnostic: ]d/[d are Neovim's defaults; plugins/lsp.lua opens the float after every jump
local function diagnostic_goto(next, severity)
  return function()
    vim.diagnostic.jump({ count = (next and 1 or -1) * vim.v.count1, severity = vim.diagnostic.severity[severity] })
  end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input("I")
end, { desc = "Inspect Tree" })

-- windows
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

---------------------------------------------------------------------------
-- Own keymaps
---------------------------------------------------------------------------

-- netrw (neo-tree owns <leader>e): opens the current file's directory; inside netrw it goes back to the buffer
-- netrw was entered from, else to an empty buffer. Buffers by number: unnamed, help and terminal buffers work too.
local function netrw_return_ok(buf)
  return buf ~= nil
    and buf > 0
    and vim.api.nvim_buf_is_valid(buf)
    and vim.bo[buf].filetype ~= "netrw"
    and vim.fn.isdirectory(vim.api.nvim_buf_get_name(buf)) == 0
end
-- w:pv_origin: the last such buffer the window left, however netrw was entered (<leader>pv, :e <dir>, gf)
local group = vim.api.nvim_create_augroup("netrw_toggle", { clear = true })
vim.api.nvim_create_autocmd("BufLeave", {
  group = group,
  callback = function(ev)
    if netrw_return_ok(ev.buf) then
      vim.w.pv_origin = ev.buf
    end
  end,
})
-- `nvim <dir>`, :e <dir> and gf leave a listed buffer named after the directory next to netrw's own (unlisted)
-- listing: unlist it, or bufferline shows it
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "netrw",
  callback = function()
    local alt = vim.fn.bufnr("#")
    if alt > 0 and vim.bo[alt].buflisted and vim.fn.isdirectory(vim.api.nvim_buf_get_name(alt)) == 1 then
      vim.bo[alt].buflisted = false
    end
  end,
})
map("n", "<leader>pv", function()
  if vim.bo.filetype ~= "netrw" then
    return vim.cmd.Explore()
  end
  -- "#" is where :Explore was run from until netrw changes directory; then it is the previous listing. After a
  -- first :e <dir> or gf it is the directory's own buffer, which would reopen netrw: w:pv_origin is used then.
  local alt, origin = vim.fn.bufnr("#"), vim.w.pv_origin
  vim.w.pv_origin = nil
  if netrw_return_ok(alt) then
    vim.cmd.buffer(alt)
  elseif netrw_return_ok(origin) then
    vim.cmd.buffer(origin)
  else
    vim.cmd.enew()
  end
end, { desc = "Netrw Toggle" })

-- Move selected lines up and down with J and K
map("x", "J", ":m '>+1<CR>gv=gv", { desc = "Move Selection Down" })
map("x", "K", ":m '<-2<CR>gv=gv", { desc = "Move Selection Up" })

-- J joins lines without moving the cursor ([count] still joins that many lines)
map("n", "J", function()
  local view = vim.fn.winsaveview()
  local ok, err = pcall(vim.cmd.normal, { math.max(vim.v.count, 2) .. "J", bang = true })
  vim.fn.winrestview(view)
  if not ok then -- e.g. E21 in a help buffer: show it like the built-in J does, without a Lua traceback
    vim.api.nvim_echo({ { (tostring(err):gsub("^.-(E%d+:)", "%1")) } }, true, { err = true })
  end
end, { desc = "Join Lines (keep cursor)" })

-- Keep cursor in the middle when jumping half page
if vim.fn.has("macunix") == 1 then
  map("n", "<D-d>", "<C-d>zz", { desc = "Half Page Down (centered)" })
  map("n", "<D-u>", "<C-u>zz", { desc = "Half Page Up (centered)" })
else
  map("n", "<C-d>", "<C-d>zz", { desc = "Half Page Down (centered)" })
  map("n", "<C-u>", "<C-u>zz", { desc = "Half Page Up (centered)" })
end

-- Yank to clipboard (plain y does the same while 'clipboard' is unnamedplus)
map({ "n", "x" }, "<leader>y", [["+y]], { desc = "Yank to Clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank Line to Clipboard" })

-- Paste over a selection without yanking it (native visual P; "_dP misplaced it at end of line)
map("x", "<leader>p", "P", { desc = "Paste without Yanking" })

-- Color picker (ccc.nvim)
map("n", "<leader>cp", vim.cmd.CccPick, { desc = "Color Picker" })

-- Rename type / symbol
map("n", "<leader>R", vim.lsp.buf.rename, { desc = "LSP Rename" })

-- Ripgrep for searching inside files
map("n", "<leader>fa", function()
  require("fzf-lua").grep()
end, { desc = "Grep (prompt)", silent = true })
