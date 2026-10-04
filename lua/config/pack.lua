-- Thin layer over the built-in plugin manager (:h vim.pack, Neovim 0.12+).
--   pack.add({ "owner/repo", { "owner/repo", version = "main" } })  install + load now
--   pack.lazy({ "owner/repo" }, { cmd = "Foo", ft = "bar" }, setup)  install now, load + setup on first use
--   pack.lazy(list, {}, setup)  load only through pack.load(name) (themes: config/lazy_colors.lua)
--   pack.later(fn)              run fn once startup has finished
--   pack.load_dir("plugins")    require() every lua/plugins/*.lua
-- To drop a plugin: delete its file (or rename it to *.lua_OLD), restart, then :PackClean.
-- Commands: :PackUpdate [names], :PackStatus (offline), :PackClean.
local M = {}

local OPT_DIR = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt")
local specs = {} ---@type table<string, vim.pack.Spec>  name -> spec (first declaration wins)
local loaded = {} ---@type table<string, true>           name -> already on 'runtimepath'
local loaders = {} ---@type table<string, fun()>         name -> loader for lazy plugins

---@param s string|table  "owner/repo" | { "owner/repo", version=, name= } | { src=, ... }
---@return vim.pack.Spec
local function norm(s)
  s = type(s) == "string" and { s } or s
  local src = s.src or s[1]
  if not src:find("://", 1, true) and not src:find("^git@") then
    src = "https://github.com/" .. src
  end
  local name = s.name or src:gsub("%.git$", ""):match("[^/]+$")
  return { src = src, name = name, version = s.version, data = s.data }
end

--- Put a registered plugin on 'runtimepath' (mirrors what vim.pack does itself).
local function load_now(name)
  if loaded[name] then
    return
  end
  loaded[name] = true
  -- During init.lua use `packadd!`: Neovim sources plugin/ files itself right after.
  local during_init = vim.v.vim_did_init == 0
  vim.cmd.packadd({ vim.fn.escape(name, " "), bang = during_init, magic = { file = false } })
  -- `:packadd` never sources after/plugin; startup does, later we have to.
  if vim.v.vim_did_enter == 1 then
    for _, f in ipairs(vim.fn.glob(OPT_DIR .. "/" .. name .. "/after/plugin/**/*.{vim,lua}", true, true)) do
      vim.cmd.source({ f, magic = { file = false } })
    end
  end
end

--- Register specs; return the ones vim.pack has not been told about yet.
local function register(list)
  local fresh = {}
  for _, s in ipairs(list) do
    s = norm(s)
    if not specs[s.name] then
      specs[s.name] = s
      fresh[#fresh + 1] = s
    end
  end
  return fresh
end

--- Install (if missing) and load now. Naming the same plugin in several files is fine.
---@param list (string|table)[]
function M.add(list)
  local fresh = register(list)
  if #fresh > 0 then
    vim.pack.add(fresh, { confirm = false })
    for _, s in ipairs(fresh) do
      loaded[s.name] = true
    end
  end
  for _, s in ipairs(list) do
    load_now(norm(s).name)
  end
end

--- Force-load a plugin declared with pack.lazy() (runs its setup once).
function M.load(name)
  if loaders[name] then
    loaders[name]()
  else
    load_now(name)
  end
end

--- Install now, but only load + run `setup` on the first :Cmd or filetype (or on pack.load(name)).
---@param list (string|table)[]
---@param on { cmd?: string|string[], ft?: string|string[], complete?: table<string, string> }
---@param setup? fun()
function M.lazy(list, on, setup)
  assert(not (on.keys or on.event), "pack.lazy: only cmd and ft triggers are supported")
  local fresh = register(list)
  if #fresh > 0 then
    vim.pack.add(fresh, { confirm = false, load = function() end })
  end
  local names = vim.tbl_map(function(s)
    return norm(s).name
  end, list)
  local function as_list(x)
    return type(x) == "table" and x or { x }
  end

  local done = false
  local function load()
    if done then
      return
    end
    done = true
    for _, n in ipairs(names) do
      load_now(n)
    end
    if setup then
      setup()
    end
  end
  for _, n in ipairs(names) do
    loaders[n] = load
  end

  -- :Cmd (or completing its arguments) -> load, then hand over to the real command.
  -- on.complete = { Cmd = "file" } gives static completion instead, which does not load the plugin
  -- (commands of that call without an entry get no completion).
  for _, cmd in ipairs(as_list(on.cmd or {})) do
    local function swap()
      pcall(vim.api.nvim_del_user_command, cmd)
      load()
    end
    local complete = on.complete and on.complete[cmd]
    if not on.complete then
      complete = function(_, line)
        swap()
        return vim.fn.getcompletion(line, "cmdline")
      end
    end
    vim.api.nvim_create_user_command(cmd, function(a)
      swap()
      local nargs = (vim.api.nvim_get_commands({})[cmd] or {}).nargs
      vim.cmd({
        cmd = cmd,
        -- nargs=? and nargs=1 take the whole argument string as one argument
        args = (nargs == "?" or nargs == "1") and a.args ~= "" and { a.args } or a.fargs,
        bang = a.bang,
        mods = a.smods,
        range = a.range == 2 and { a.line1, a.line2 } or a.range == 1 and { a.line1 } or nil,
      })
    end, {
      nargs = "*",
      bang = true,
      range = true,
      complete = complete,
    })
  end

  -- filetype -> load. FileType already ran ftplugin/ and indent/ for this buffer while the plugin was not
  -- on 'runtimepath': run them again for it, now in 'runtimepath' order (the plugin's files before
  -- $VIMRUNTIME's, as for every later buffer). Plugins without such files skip this.
  if on.ft then
    vim.api.nvim_create_autocmd("FileType", {
      once = true,
      pattern = as_list(on.ft),
      callback = function(ev)
        if done then
          return
        end
        load()
        local rerun = false
        for _, n in ipairs(names) do
          for _, dir in ipairs({ "ftplugin", "indent" }) do
            local base = vim.fs.joinpath(OPT_DIR, n, dir, ev.match)
            local files = vim.fn.glob(base .. "{.,_*.}{vim,lua}", true, true)
            vim.list_extend(files, vim.fn.glob(base .. "/*.{vim,lua}", true, true))
            rerun = rerun or #files > 0
          end
        end
        if rerun then
          vim.api.nvim_buf_call(ev.buf, function()
            for _, group in ipairs({ "filetypeplugin", "filetypeindent" }) do
              if vim.fn.exists("#" .. group .. "#FileType") == 1 then
                vim.cmd.doautocmd({ group, "FileType", ev.match })
              end
            end
          end)
        end
      end,
    })
  end
end

local later_queue = {} ---@type fun()[]?
local function run(fn)
  local ok, err = pcall(fn)
  if not ok then
    vim.notify(("pack.later:\n%s"):format(err), vim.log.levels.ERROR)
  end
end

--- Run `fn` once startup has finished (lazy.nvim's "VeryLazy").
function M.later(fn)
  if later_queue then
    later_queue[#later_queue + 1] = fn
  else
    vim.schedule(function()
      run(fn)
    end)
  end
end

--- require() every lua/<rel>/*.lua in sorted order. Other extensions (*.lua_OLD) and
--- subdirectories are ignored. One broken file is reported, the rest keep loading.
function M.load_dir(rel)
  local files = vim.fn.glob(vim.fn.stdpath("config") .. "/lua/" .. rel .. "/*.lua", true, true)
  table.sort(files)
  local prefix = rel:gsub("/", ".") .. "."
  for _, f in ipairs(files) do
    local mod = prefix .. vim.fn.fnamemodify(f, ":t:r")
    local ok, err = pcall(require, mod)
    if not ok then
      vim.schedule(function()
        vim.notify(("Error loading %s:\n%s"):format(mod, err), vim.log.levels.ERROR)
      end)
    end
  end
end

--- Call once, before the first pack.add(): lockfile-driven installs fire PackChanged there.
function M.setup()
  -- Post-update hooks (lazy.nvim's `build`). They run inside vim.pack's async runner: keep them short.
  vim.api.nvim_create_autocmd("PackChanged", {
    group = vim.api.nvim_create_augroup("user_pack_hooks", { clear = true }),
    callback = function(ev)
      -- Recompile treesitter parsers after an update (a reinstall reuses site/parser)
      if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
        if not ev.data.active then
          vim.cmd.packadd("nvim-treesitter")
        end
        require("nvim-treesitter").update(nil, { summary = true })
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.schedule(function()
        local queue = later_queue or {}
        later_queue = nil
        for _, fn in ipairs(queue) do
          run(fn)
        end
      end)
    end,
  })

  local function complete(lead)
    return vim.tbl_filter(function(n)
      return vim.startswith(n, lead)
    end, vim.tbl_keys(specs))
  end
  vim.api.nvim_create_user_command("PackUpdate", function(a)
    vim.pack.update(#a.fargs > 0 and a.fargs or nil)
  end, { nargs = "*", complete = complete, desc = "Fetch plugin updates and review them" })
  vim.api.nvim_create_user_command("PackStatus", function()
    vim.pack.update(nil, { offline = true })
  end, { desc = "Show installed plugins and revisions (offline)" })
  vim.api.nvim_create_user_command("PackClean", function()
    local unused = {}
    for _, p in ipairs(vim.pack.get(nil, { info = false })) do
      if not p.active then
        unused[#unused + 1] = p.spec.name
      end
    end
    if #unused == 0 then
      return vim.notify("vim.pack: nothing to clean")
    end
    if vim.fn.confirm("Delete:\n" .. table.concat(unused, "\n"), "&Yes\n&No", 2) == 1 then
      vim.pack.del(unused)
    end
  end, { desc = "Delete plugins that are no longer declared" })
end

return M
