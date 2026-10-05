-- mason: installs LSP servers and tools into stdpath("data")/mason (:Mason, <leader>cm) and puts
-- them on PATH. The servers are listed in lua/config/lsp_servers.lua (enabled by plugins/lsp.lua).
local pack = require("config.pack")
pack.add({ "mason-org/mason.nvim" })

require("mason").setup()
vim.keymap.set("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason" })

-- mason package names: the servers, conform's formatters, and the tree-sitter CLI that
-- nvim-treesitter needs to build parsers
local tools = { "stylua", "shfmt", "tree-sitter-cli" }
vim.list_extend(tools, vim.tbl_values(require("config.lsp_servers")))

-- Install missing tools after startup. Usually just a few stat calls: the registry (which may
-- download an update) is only refreshed when something is missing.
pack.later(function()
  local root = vim.fn.stdpath("data") .. "/mason/packages/"
  local missing = vim.tbl_filter(function(tool)
    return not vim.uv.fs_stat(root .. tool)
  end, tools)
  if #missing == 0 then
    return
  end
  local registry = require("mason-registry")
  registry.refresh(function()
    for _, tool in ipairs(missing) do
      local ok, p = pcall(registry.get_package, tool)
      if ok and not p:is_installed() then
        p:install()
      end
    end
  end)
end)
