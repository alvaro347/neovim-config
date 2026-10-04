-- mini.pairs (from mini.nvim): auto close brackets and quotes, also in the cmdline. Toggle: <leader>up.
-- The `open` wrapper (from LazyVim) skips pairing before a word character or one of %'[".`$, inside
-- strings, and when the line has more closing than opening brackets; it completes ``` in markdown.
local pack = require("config.pack")
pack.add({ "nvim-mini/mini.nvim" })

pack.later(function()
  Snacks.toggle({
    name = "Mini Pairs",
    get = function()
      return not vim.g.minipairs_disable
    end,
    set = function(state)
      vim.g.minipairs_disable = not state
    end,
  }):map("<leader>up")

  local pairs = require("mini.pairs")
  pairs.setup({ modes = { command = true } })
  local open = pairs.open
  pairs.open = function(pair, neigh_pattern)
    if vim.fn.getcmdline() ~= "" then
      return open(pair, neigh_pattern)
    end
    local o, c = pair:sub(1, 1), pair:sub(2, 2)
    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local next = line:sub(cursor[2] + 1, cursor[2] + 1)
    local before = line:sub(1, cursor[2])
    if o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``") then
      return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
    end
    if next ~= "" and next:match([=[[%w%%%'%[%"%.%`%$]]=]) then
      return o
    end
    local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
    for _, capture in ipairs(ok and captures or {}) do
      if capture.capture == "string" then
        return o
      end
    end
    if next == c and c ~= o then
      local _, n_open = line:gsub(vim.pesc(o), "")
      local _, n_close = line:gsub(vim.pesc(c), "")
      if n_close > n_open then
        return o
      end
    end
    return open(pair, neigh_pattern)
  end
end)
