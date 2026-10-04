-- Temporary key-usage logger: counts the mappings and Ex commands you use, so unused ones can go later.
-- On: touch ~/.local/state/nvim/keylog.enabled (init.lua then runs start() before any map exists). Off: rm it.
-- :KeylogReport (while off: :lua require("config.keylog").report()). Counts: ~/.local/state/nvim/keylog.json
-- Each map is re-set with mapset() as a counting copy (Lua callback wrapped; string rhs -> expr callback returning
-- the same keys; string <expr> rhs -> v:lua prefix). maparg()/nvim_[buf_]get_keymap() still show the original.
local M = {}
local uv, api = vim.uv, vim.api
local FILE, ROOT = vim.fn.stdpath("state") .. "/keylog.json", vim.fn.stdpath("config") .. "/"
local MARK, MARK_PAT = "v:lua.require'config.keylog'.hit(", "^v:lua%.require'config%.keylog'%.hit%((%d+)%) %.%. %("
local SELF = debug.getinfo(1, "S").source
local VISUAL = { v = "x", V = "x", ["\22"] = "x", S = "s", ["\19"] = "s", R = "i" }
local MODES = { [""] = "nxo", [" "] = "nxo", v = "x", ["!"] = "ic" } -- for "never used" (Select mode is rare)
local raw, metas, defs, wrapped = {}, {}, {}, setmetatable({}, { __mode = "k" })
local delta, saved, busy, from_map = { maps = {}, cmds = {} }, false, false, false

local function warn(err)
  vim.notify("keylog: " .. tostring(err), vim.log.levels.WARN)
end
local function bind(f, x) -- f(x, ...)
  return function(...)
    return f(x, ...)
  end
end
local function quiet(fn) -- fn(...) without raising and without a return value (true would delete an autocmd)
  return function(...)
    pcall(fn, ...)
  end
end

local function src_of(path) -- "plugins/lsp.lua" (config file), "plugin:<name>" or "nvim"
  local name = path:match("/pack/[^/]+/[^/]+/([^/]+)/")
  return vim.startswith(path, ROOT) and (path:sub(#ROOT + 1):gsub("^lua/", "")) or name and "plugin:" .. name or "nvim"
end
local function is_user(src)
  return src ~= "nvim" and not vim.startswith(src, "plugin:")
end

local function caller_src() -- the first config file on the stack, else the first plugin file
  local plugin = "nvim"
  for level = 3, 40 do
    local s = (debug.getinfo(level, "S") or {}).source or ""
    local src = s:sub(1, 1) == "@" and s ~= SELF and src_of(s:sub(2)) or "nvim"
    if is_user(src) then
      return src
    end
    plugin = plugin == "nvim" and src or plugin
  end
  return plugin
end

local function count(meta) -- key: mode (a multi-mode map: the mode it fired in), lhs, buffer-local flag, source
  local m = api.nvim_get_mode().mode
  m = meta.mode or (m:find("^no") and "o") or VISUAL[m:sub(1, 1)] or m:sub(1, 1)
  local key = table.concat({ m, meta.lhs, meta.scope, meta.src }, "\t")
  local e = delta.maps[key] or { n = 0 }
  delta.maps[key], e.n, e.last, e.desc, busy = e, e.n + 1, os.time(), meta.desc, true -- busy until SafeState
end

function M.hit(id) -- called from the rhs of counted string <expr> maps
  pcall(count, metas[id])
  return ""
end

local function wrap(meta, fn) -- fn: the original callback, or the keys of a string rhs
  local w = function(...)
    pcall(count, meta)
    return type(fn) == "string" and fn or fn(...)
  end
  wrapped[w] = meta
  return w
end

local function meta_of(d)
  local id = type(d.rhs) == "string" and d.rhs:match(MARK_PAT)
  return wrapped[d.callback or 0] or id and metas[tonumber(id)] or nil
end

local function skip(d) -- left alone: counted maps, lmaps, <Plug>/<SNR> lhs, <Nop>, <SID> from Lua, which-key's
  local l, r = d.lhs:lower(), d.callback == nil and (d.rhs or ""):lower() or "-"
  local other = meta_of(d) or d.mode == "l" or tostring(d.desc):find("which-key-trigger", 1, true)
  return other or l:find("^<plug>") or l:find("^<snr>") or r == "" or r == "<nop>" or r:find("<sid>") ~= nil
end

-- Re-set map d (a maparg() dict) as its counting copy. mapset() keeps sid, so <SID> and s: still resolve.
local function rewrap(d, src, buf)
  local o, tc = vim.deepcopy(d, true), api.nvim_replace_termcodes
  d.api = d.rhs and (vim.fn.keytrans(tc(d.rhs, true, true, true)):gsub("<Space>", " ")) -- rhs as :map shows it
  local meta = { id = #metas + 1, mode = d.mode:match("^[nxsoict]$"), lhs = vim.fn.keytrans(d.lhsraw or d.lhs) }
  meta.scope, meta.src, meta.desc, meta.orig, metas[meta.id] = buf and "b" or "g", src, d.desc or d.api, d, meta
  for m in (is_user(src) and (MODES[d.mode] or d.mode) or ""):gmatch(".") do
    defs[table.concat({ m, meta.lhs, meta.scope, src }, "\t")] = meta.desc or ""
  end
  if d.callback then
    o.callback = wrap(meta, d.callback)
  elseif d.expr == 1 then
    o.rhs = MARK .. meta.id .. ") .. (" .. d.rhs .. ")"
  else
    o.rhs, o.expr, o.replace_keycodes, o.callback = nil, 1, 1, wrap(meta, d.rhs)
  end
  api.nvim_buf_call(buf or 0, bind(vim.fn.mapset, o)) -- a buffer-local map goes into its own buffer
end

local function set(buf, ...) -- the original call (same effect, same errors), then its counting copy
  local a, r = { ... }, (buf and raw.buf_set or raw.set)(...)
  local b, mode, lhs = buf and a[1], unpack(a, buf and 2 or 1)
  local ok, d = pcall(api.nvim_buf_call, b or 0, function()
    return not mode:find("a$") and raw.maparg(lhs, mode, false, true) or {} -- abbreviations are not maps
  end)
  local _ = ok and d.buffer == (b and 1 or 0) and not skip(d) and pcall(rewrap, d, caller_src(), b)
  return r
end

local function unwrap(d, compat) -- show a keymap dict's original definition (compat: maparg's form of the rhs)
  local meta = type(d) == "table" and meta_of(d)
  if meta then
    local o = meta.orig
    d.callback, d.expr, d.replace_keycodes, d.rhs = o.callback, o.expr, o.replace_keycodes, compat and o.rhs or o.api
  end
  return d
end

local function unwrapped(get, ...) -- a getter's result showing the original maps (maparg: its own rhs form)
  local r = get(...)
  return type(r) ~= "table" and r or r.lhs and unwrap(r, true) or vim.tbl_map(unwrap, r)
end

local function rescan() -- global maps that skipped the API: runtime defaults and Vimscript plugins
  for _, mode in ipairs({ "n", "x", "s", "o", "i", "c", "t" }) do
    for _, d in ipairs(raw.get(mode)) do -- a multi-mode map shows up again, already counted (skip)
      local info = not skip(d) and ((d.sid or 0) > 0 and vim.fn.getscriptinfo({ sid = d.sid })[1] or {})
      local _ = info and pcall(rewrap, d, info.name and src_of(info.name) or "nvim")
    end
  end
end

local function count_cmd() -- an Ex command you typed (aborted ones and those typed by a map's rhs are skipped)
  local line = vim.fn.getcmdline()
  if vim.v.event.cmdtype == ":" and not vim.v.event.abort and not from_map and line:find("%S") then
    local ok, p = pcall(api.nvim_parse_cmd, line, {})
    local name = ok and p.cmd or line:match("^[%s:]*[%d%s,;.$%%'<>+-]*(%a%w*!?)") or "?"
    delta.cmds[name] = (delta.cmds[name] or 0) + 1
  end
end

local function load() -- keylog.json plus the counts not saved yet
  local f = io.open(FILE)
  local ok, data = pcall(vim.json.decode, f and f:read("*a") or "{}")
  local _ = f and f:close()
  if not ok or type(data) ~= "table" then
    os.rename(FILE, FILE .. ".corrupt." .. os.time()) -- keep it, start over
    data = {}
  end
  data.maps, data.cmds = data.maps or {}, data.cmds or {}
  for k, desc in pairs(defs) do -- your maps are listed even when never used
    data.maps[k] = data.maps[k] or { n = 0, desc = desc }
  end
  for k, v in pairs(delta.maps) do
    local e = data.maps[k] or {}
    data.maps[k], e.n, e.last, e.desc = e, (tonumber(e.n) or 0) + v.n, v.last, v.desc or e.desc
  end
  for k, n in pairs(delta.cmds) do
    data.cmds[k] = (tonumber(data.cmds[k]) or 0) + n
  end
  return data
end

--- Merge the counts into keylog.json. Returns false if that failed (the counts are kept for the next try).
function M.flush(final)
  local lock = FILE .. ".lock" -- mkdir is atomic: one Neovim at a time
  for _ = 1, final and 50 or 1 do
    local st = uv.fs_stat(lock)
    local _ = st and os.time() - st.mtime.sec > 30 and uv.fs_rmdir(lock) -- left behind by a crash
    if pcall(vim.fn.mkdir, vim.fs.dirname(FILE), "p") and uv.fs_mkdir(lock, 448) then
      local ok = pcall(function()
        local data, tmp = load(), FILE .. ".tmp" .. uv.os_getpid()
        data.since, data.sessions = data.since or os.date("%F %R"), (tonumber(data.sessions) or 0) + (saved and 0 or 1)
        local f = assert(io.open(tmp, "w"))
        assert(f:write(vim.json.encode(data)) and f:close() and os.rename(tmp, FILE))
        saved, delta = true, { maps = {}, cmds = {} }
      end)
      uv.fs_rmdir(lock)
      return ok
    end
    uv.sleep(20)
  end
  return false
end

local function by_count(a, b)
  return a[1] > b[1] or a[1] == b[1] and a[2] < b[2]
end

--- :KeylogReport: every map by use (most used first; your least and never used maps last), then Ex commands
function M.report()
  local ok, err = pcall(function()
    local data, maps, cmds = load(), {}, {}
    for k, e in pairs(data.maps) do
      local mode, lhs, scope, src = k:match("^(.-)\t(.-)\t(.-)\t(.*)$")
      lhs = (vim.g.mapleader == " " and lhs:gsub("^<Space>", "<leader>") or lhs) .. (scope == "b" and " *" or "")
      maps[#maps + 1] =
        { tonumber(e.n) or 0, ("%-3s %-26s %-40s %s"):format(mode, lhs, tostring(e.desc or ""):sub(1, 40), src) }
    end
    for name, n in pairs(data.cmds) do
      cmds[#cmds + 1] = { tonumber(n) or 0, ":" .. name }
    end
    table.sort(maps, by_count)
    table.sort(cmds, by_count)
    local lines = { ("%s: %s sessions since %s, * = buffer-local"):format(FILE, data.sessions or 0, data.since or "") }
    for _, r in ipairs(vim.list_extend(vim.list_extend(maps, { { "" } }), cmds)) do
      lines[#lines + 1] = r[2] and ("%7d  %s"):format(r[1], r[2]) or ""
    end
    vim.cmd.tabnew()
    vim.bo.buftype, vim.bo.bufhidden, vim.bo.swapfile = "nofile", "wipe", false
    api.nvim_buf_set_lines(0, 0, -1, false, lines)
  end)
  local _ = ok or warn(err)
end

--- Start counting. Called from init.lua before anything defines a mapping.
function M.start()
  local ok, err = pcall(function()
    assert(not raw.set, "already started")
    raw.set, raw.buf_set, raw.get = api.nvim_set_keymap, api.nvim_buf_set_keymap, api.nvim_get_keymap
    raw.buf_get, raw.maparg = api.nvim_buf_get_keymap, vim.fn.maparg
    api.nvim_set_keymap, api.nvim_buf_set_keymap = bind(set, false), bind(set, true)
    api.nvim_get_keymap, api.nvim_buf_get_keymap = bind(unwrapped, raw.get), bind(unwrapped, raw.buf_get)
    vim.fn.maparg = bind(unwrapped, raw.maparg)
    local group = api.nvim_create_augroup("user_keylog", { clear = true })
    for event, fn in pairs({
      VimEnter = function() -- after the pack.later() setups
        vim.defer_fn(quiet(rescan), 1500)
      end,
      SafeState = function() -- idle, waiting for you to type: what follows is not from a map's rhs
        busy = false
      end,
      CmdlineEnter = function() -- `:` typed by you, or by a mapping's rhs / a macro?
        from_map = busy or vim.fn.reg_executing() ~= ""
      end,
      CmdlineLeave = count_cmd,
      VimLeavePre = bind(M.flush, true),
    }) do
      api.nvim_create_autocmd(event, { group = group, callback = quiet(fn) })
    end
    uv.new_timer():start(300000, 300000, vim.schedule_wrap(quiet(M.flush)))
    api.nvim_create_user_command("KeylogReport", M.report, { desc = "Key usage counts (keylog)" })
  end)
  local _ = ok or vim.schedule(bind(warn, err))
end

return M
