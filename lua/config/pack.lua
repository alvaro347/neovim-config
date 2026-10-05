-- Thin layer over the built-in plugin manager (:h vim.pack). A plugin is "owner/repo" (GitHub) or
-- { "owner/repo", version = "main", name = "dir" }; the first spec of a name wins, in any file.
--   pack.add(list)              install + load now
--   pack.lazy(list, on, setup)  install now; load + setup on the first on.cmd / on.ft, or pack.load(name)
--   pack.later(fn)              run fn once startup has finished
--   pack.load_dir("plugins")    require() every lua/plugins/*.lua
-- Drop a plugin: delete its file (or rename it to *.lua_OLD), restart, :PackClean.
-- Commands: :PackUpdate [names], :PackStatus (offline), :PackClean.
local M = {}

local seen = {} ---@type table<string, true>     names already given to vim.pack.add()
local pending = {} ---@type table<string, true>  declared by pack.lazy() only, not on 'runtimepath' yet
local loaders = {} ---@type table<string, fun()> name -> load + setup of its pack.lazy() call

--- Report an error of fn(...) instead of raising it.
local function try(what, fn, ...)
  local ok, err = pcall(fn, ...)
  if not ok then
    vim.schedule(function()
      vim.notify(("%s:\n%s"):format(what, err), vim.log.levels.ERROR)
    end)
  end
end

--- vim.pack.add() the specs of `list` not seen yet (a re-add would still write its `version` to the
--- lockfile). Returns all of them, normalized.
local function add(list, load)
  local specs, fresh = {}, {}
  for i, s in ipairs(list) do
    s = type(s) == "string" and { s } or s
    specs[i] = { src = "https://github.com/" .. s[1], name = s.name or s[1]:match("[^/]+$"), version = s.version }
    fresh[#fresh + 1] = not seen[specs[i].name] and specs[i] or nil
    seen[specs[i].name] = true
  end
  if #fresh > 0 then
    vim.pack.add(fresh, { confirm = false, load = load })
  end
  return specs
end

--- :packadd a plugin only pack.lazy() declared so far (`packadd!` during init.lua, like vim.pack).
local function load_now(name)
  if pending[name] then
    pending[name] = nil
    vim.cmd.packadd({ vim.fn.escape(name, " "), bang = vim.v.vim_did_init == 0, magic = { file = false } })
  end
end

--- Install (if missing) and load now, also a plugin that an earlier pack.lazy() declared (lush).
function M.add(list)
  for _, s in ipairs(add(list)) do
    load_now(s.name)
  end
end

--- Force-load a plugin declared with pack.lazy() (runs its setup once).
function M.load(name)
  return (loaders[name] or load_now)(name)
end

--- Install now, but only load + run `setup` on the first :Cmd or filetype (or on pack.load(name)).
--- FileType already ran for the buffer that triggers the load: setup() re-runs what the plugin needs there.
---@param on { cmd?: string|string[], ft?: string|string[], complete?: table<string, string> }
function M.lazy(list, on, setup)
  local specs = add(list, function(p) -- vim.pack calls this instead of :packadd for plugins not loaded yet
    pending[p.spec.name] = true
  end)
  local cmds = type(on.cmd) == "table" and on.cmd or { on.cmd }
  local done = false
  local function load()
    if done then
      return
    end
    done = true
    for _, cmd in ipairs(cmds) do
      pcall(vim.api.nvim_del_user_command, cmd) -- the stub below, before the plugin defines the real one
    end
    for _, s in ipairs(specs) do
      load_now(s.name)
    end
    if setup then
      setup()
    end
  end
  for _, s in ipairs(specs) do
    loaders[s.name] = load
  end

  -- :Cmd loads the plugin and runs the real command as typed; so does completing its arguments, unless
  -- on.complete = { Cmd = "file" } gives static completion (other commands of the call get none).
  local function complete(_, line)
    load()
    return vim.fn.getcompletion(line, "cmdline")
  end
  for _, cmd in ipairs(cmds) do
    vim.api.nvim_create_user_command(cmd, function(a)
      load()
      local range = a.range == 2 and a.line1 .. "," .. a.line2 or a.range == 1 and a.line1 or ""
      vim.cmd(("%s %s%s%s %s"):format(a.mods, range, cmd, a.bang and "!" or "", a.args))
    end, { nargs = "*", bang = true, range = true, complete = on.complete == nil and complete or on.complete[cmd] })
  end
  if on.ft then
    vim.api.nvim_create_autocmd("FileType", { once = true, pattern = on.ft, callback = load })
  end
end

--- Run `fn` once startup has finished (lazy.nvim's "VeryLazy"), in call order.
function M.later(fn)
  local function run()
    try("pack.later", fn)
  end
  if vim.v.vim_did_enter == 1 then
    vim.schedule(run)
  else
    vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = vim.schedule_wrap(run) })
  end
end

--- require() every lua/<rel>/*.lua in sorted order (not *.lua_OLD, not subdirectories); a broken file
--- is reported and the others still load.
function M.load_dir(rel)
  local files = vim.fn.glob(vim.fn.stdpath("config") .. "/lua/" .. rel .. "/*.lua", true, true)
  table.sort(files)
  for _, f in ipairs(files) do
    local mod = rel:gsub("/", ".") .. "." .. vim.fn.fnamemodify(f, ":t:r")
    try("Error loading " .. mod, require, mod)
  end
end

vim.api.nvim_create_user_command("PackUpdate", function(a)
  vim.pack.update(#a.fargs > 0 and a.fargs or nil)
end, { nargs = "*", desc = "Fetch plugin updates and review them" })
vim.api.nvim_create_user_command("PackStatus", function()
  vim.pack.update(nil, { offline = true })
end, { desc = "Show installed plugins and revisions (offline)" })
vim.api.nvim_create_user_command("PackClean", function()
  local unused = {}
  for _, p in ipairs(vim.pack.get(nil, { info = false })) do
    unused[#unused + 1] = not p.active and p.spec.name or nil
  end
  if #unused == 0 then
    return vim.notify("vim.pack: nothing to clean")
  end
  if vim.fn.confirm("Delete:\n" .. table.concat(unused, "\n"), "&Yes\n&No", 2) == 1 then
    vim.pack.del(unused)
  end
end, { desc = "Delete plugins that are no longer declared" })

return M
