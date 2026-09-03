-- blink.cmp: completion (LSP, path, snippets, buffer) + friendly-snippets.
-- Pinned to the latest 1.x release so the prebuilt fuzzy-matcher binary is downloaded
-- (no Rust toolchain needed). Change to version = "main" + `cargo build --release` otherwise.
local pack = require("config.pack")
pack.add({
  "rafamadriz/friendly-snippets",
  { "saghen/blink.cmp", version = vim.version.range("1") },
})

local icons = require("config.icons")

require("blink.cmp").setup({
  snippets = { preset = "default" },

  appearance = {
    -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- adjusts spacing to ensure icons are aligned
    nerd_font_variant = "mono",
    kind_icons = icons.kinds,
  },

  completion = {
    accept = {
      -- experimental auto-brackets support
      auto_brackets = { enabled = true },
    },
    menu = {
      draw = { treesitter = { "lsp" } },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
    ghost_text = { enabled = true },
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    -- the "lazydev" source for lua files is added by lua/plugins/lazyvim/lazydev.lua
  },

  cmdline = {
    enabled = true,
    keymap = {
      preset = "cmdline",
      ["<Right>"] = false,
      ["<Left>"] = false,
    },
    completion = {
      list = { selection = { preselect = false } },
      menu = {
        auto_show = function()
          return vim.fn.getcmdtype() == ":"
        end,
      },
      ghost_text = { enabled = true },
    },
  },

  keymap = {
    preset = "enter",
    ["<C-y>"] = { "select_and_accept" },
    ["<Tab>"] = { "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "fallback" },
  },
})
