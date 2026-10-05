-- Project-root helpers for pickers, terminals and the statusline (what LazyVim.root/pick did).
local M = {}

local markers = { ".git", "lua" }

--- Project root of a buffer: LSP root dir (if the file is inside it), else nearest marker, else cwd.
---@param buf? integer
---@return string
function M.root(buf)
  buf = buf or 0
  local file = vim.api.nvim_buf_get_name(buf)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    local dir = client.root_dir
    if dir and (file == dir or vim.startswith(file, (dir:gsub("/$", "")) .. "/")) then
      return dir
    end
  end
  return vim.fs.root(buf, markers) or assert(vim.uv.cwd()) -- non-file buffers: from the cwd
end

--- Git root of the current project root (falls back to the project root).
---@return string
function M.git()
  local root = M.root()
  return vim.fs.root(root, ".git") or root
end

--- Open an fzf-lua picker rooted at the project root.
--- `opts.root = false` uses the cwd instead; an explicit `opts.cwd` always wins.
---@param cmd string   fzf-lua function name ("files", "live_grep", ...)
---@param opts? table
function M.pick_open(cmd, opts)
  local o = vim.deepcopy(opts or {})
  if o.cwd == nil and o.root ~= false then
    o.cwd = M.root(o.buf)
  end
  o.root, o.buf = nil, nil
  require("fzf-lua")[cmd](o)
end

--- Same as pick_open, but returns a function (handy for keymaps and the dashboard).
function M.pick(cmd, opts)
  return function()
    M.pick_open(cmd, opts)
  end
end

return M
