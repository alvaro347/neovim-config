-- Small helpers that replace LazyVim.root and LazyVim.pick.
local M = {}

local markers = { ".git", "lua" }

--- Project root of a buffer: LSP root dir, else nearest marker, else cwd.
---@param buf? integer
---@return string
function M.root(buf)
  buf = buf or 0
  local file = vim.api.nvim_buf_get_name(buf)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    local dir = client.root_dir
    if dir and file:find(dir, 1, true) == 1 then
      return dir
    end
  end
  local root = vim.fs.root(file ~= "" and file or buf, markers)
  return root or assert(vim.uv.cwd())
end

--- Git root of the current project root (falls back to the project root).
---@return string
function M.git()
  local root = M.root()
  return vim.fs.root(root, ".git") or root
end

--- Open an fzf-lua picker rooted at the project root.
--- `opts.root = false` uses the cwd instead; an explicit `opts.cwd` always wins.
---@param cmd string   fzf-lua function name ("files", "live_grep", ...); "auto" means "files"
---@param opts? table
function M.pick_open(cmd, opts)
  local o = vim.deepcopy(opts or {})
  if o.cwd == nil and o.root ~= false then
    o.cwd = M.root(o.buf)
  end
  o.root, o.buf = nil, nil
  if cmd == "git_files" and o.show_untracked and o.cmd == nil then
    o.cmd = "git ls-files --exclude-standard --cached --others"
  end
  require("fzf-lua")[cmd == "auto" and "files" or cmd](o)
end

--- Same as pick_open, but returns a function (handy for keymaps and the dashboard).
function M.pick(cmd, opts)
  return function()
    M.pick_open(cmd, opts)
  end
end

return M
