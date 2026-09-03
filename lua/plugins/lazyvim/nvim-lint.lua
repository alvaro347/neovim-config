-- nvim-lint: async linters reporting through vim.diagnostic.
-- Only `fish` is configured (LazyVim's default); add linters to `linters_by_ft` or drop the plugin.
local pack = require("config.pack")
pack.add({ "mfussenegger/nvim-lint" })

local opts = {
  -- Event to trigger linters
  events = { "BufWritePost", "BufReadPost", "InsertLeave" },
  linters_by_ft = {
    fish = { "fish" },
    -- Use the "*" filetype to run linters on all filetypes.
    -- ['*'] = { 'global linter' },
    -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
    -- ['_'] = { 'fallback linter' },
    -- ["*"] = { "typos" },
  },
  -- Easily override linter options or add custom linters.
  -- `condition` (a function receiving { filename, dirname }) enables a linter dynamically.
  ---@type table<string,table>
  linters = {
    -- selene = {
    --   condition = function(ctx)
    --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
    --   end,
    -- },
  },
}

pack.later(function()
  local lint = require("lint")
  for name, linter in pairs(opts.linters) do
    if type(linter) == "table" and type(lint.linters[name]) == "table" then
      lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
      if type(linter.prepend_args) == "table" then
        lint.linters[name].args = lint.linters[name].args or {}
        vim.list_extend(lint.linters[name].args, linter.prepend_args)
      end
    else
      lint.linters[name] = linter
    end
  end
  lint.linters_by_ft = opts.linters_by_ft

  local function debounce(ms, fn)
    local timer = vim.uv.new_timer()
    return function(...)
      local argv = { ... }
      timer:start(ms, 0, function()
        timer:stop()
        vim.schedule_wrap(fn)(unpack(argv))
      end)
    end
  end

  local function run()
    -- Use nvim-lint's logic first:
    -- * checks if linters exist for the full filetype first
    -- * otherwise will split filetype by "." and add all those linters
    local names = lint._resolve_linter_by_ft(vim.bo.filetype)
    names = vim.list_extend({}, names)

    -- Add fallback linters.
    if #names == 0 then
      vim.list_extend(names, lint.linters_by_ft["_"] or {})
    end

    -- Add global linters.
    vim.list_extend(names, lint.linters_by_ft["*"] or {})

    -- Filter out linters that don't exist or don't match the condition.
    local ctx = { filename = vim.api.nvim_buf_get_name(0) }
    ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
    names = vim.tbl_filter(function(name)
      local linter = lint.linters[name]
      if not linter then
        vim.notify("Linter not found: " .. name, vim.log.levels.WARN, { title = "nvim-lint" })
      end
      return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
    end, names)

    if #names > 0 then
      lint.try_lint(names)
    end
  end

  vim.api.nvim_create_autocmd(opts.events, {
    group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
    callback = debounce(100, run),
  })
end)
