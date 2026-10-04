-- Lazy colorschemes: `:colorscheme <name>` first loads the opt plugin that ships colors/<name>, which
-- also runs its pack.lazy() setup. Theme plugins cost nothing at startup, and completion and the
-- colorscheme pickers still list them because :colorscheme also searches 'packpath'.
local pack = require("config.pack")

vim.api.nvim_create_autocmd("ColorSchemePre", {
  group = vim.api.nvim_create_augroup("user_lazy_colors", { clear = true }),
  callback = function(ev)
    local glob = "pack/*/opt/*/colors/" .. ev.match .. ".{vim,lua}"
    for _, file in ipairs(vim.fn.globpath(vim.o.packpath, glob, false, true)) do
      local dir = file:match("^(.*)/colors/")
      local was_loaded = vim.tbl_contains(vim.api.nvim_list_runtime_paths(), dir)
      pack.load(vim.fs.basename(dir))
      -- Theme after/queries (catppuccin, luna, vscode, jellybeans): :packadd does not fire OptionSet,
      -- so treesitter keeps the queries it cached without them. Drop the cache, restart highlighters.
      if not was_loaded and vim.uv.fs_stat(dir .. "/after/queries") then
        pcall(vim.api.nvim_exec_autocmds, "OptionSet", {
          group = "nvim.treesitter.query_cache_reset",
          pattern = "runtimepath",
        })
        for buf, highlighter in pairs(vim.treesitter.highlighter.active) do
          local lang = highlighter.tree:lang()
          vim.schedule(function()
            if vim.treesitter.highlighter.active[buf] == highlighter then -- not stopped or wiped since
              vim.treesitter.stop(buf)
              vim.treesitter.start(buf, lang)
            end
          end)
        end
      end
    end
  end,
})
