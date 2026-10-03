-- noice: nicer LSP docs/messages UI. cmdline and messages views are kept classic (disabled).
local pack = require("config.pack")
pack.add({ "MunifTanjim/nui.nvim", "folke/noice.nvim" })

pack.later(function()
  require("noice").setup({
    -- classic cmdline and messages
    cmdline = {
      enabled = false,
    },
    messages = {
      enabled = false,
    },
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
          },
        },
        view = "mini",
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
    },
  })
end)

local map = vim.keymap.set
-- stylua: ignore start
map("c", "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, { desc = "Redirect Cmdline" })
map("n", "<leader>snl", function() require("noice").cmd("last") end, { desc = "Noice Last Message" })
map("n", "<leader>snh", function() require("noice").cmd("history") end, { desc = "Noice History" })
map("n", "<leader>sna", function() require("noice").cmd("all") end, { desc = "Noice All" })
map("n", "<leader>snd", function() require("noice").cmd("dismiss") end, { desc = "Dismiss All" })
map("n", "<leader>snt", function() require("noice").cmd("pick") end, { desc = "Noice Picker (FzfLua)" })
-- scroll LSP docs; only insert/select mode because <C-f> in normal mode is tmux-sessionizer (keymaps.lua)
map({ "i", "s" }, "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, { silent = true, expr = true, desc = "Scroll Forward" })
map({ "i", "s" }, "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, { silent = true, expr = true, desc = "Scroll Backward" })
-- stylua: ignore end
