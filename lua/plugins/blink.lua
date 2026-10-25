-- blink.cmp: completion (LSP, path, snippets, buffer) with friendly-snippets and signature help.
-- Pinned to the latest 1.x release so the prebuilt fuzzy-matcher binary is downloaded
-- (no Rust toolchain needed). Change to version = "main" + `cargo build --release` otherwise.
local pack = require("config.pack")
pack.add({
  "rafamadriz/friendly-snippets",
  { "saghen/blink.cmp", version = vim.version.range("1") },
})

require("blink.cmp").setup({
  appearance = { kind_icons = require("config.icons").kinds },
  completion = {
    -- icon | label + labelDetails | kind name
    menu = {
      draw = {
        treesitter = { "lsp" },
        columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" } },
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      window = { max_width = 80, max_height = 20 },
    },
    ghost_text = { enabled = true },
  },
  signature = { enabled = true }, -- shown automatically while typing arguments; <C-k> toggles
  -- the "lazydev" source for lua files is added by lua/plugins/lazydev.lua
  cmdline = {
    keymap = { ["<Right>"] = false, ["<Left>"] = false },
    completion = {
      list = { selection = { preselect = false } },
      menu = {
        auto_show = function()
          return vim.fn.getcmdtype() == ":"
        end,
      },
    },
  },
  keymap = {
    preset = "enter",
    ["<C-y>"] = { "select_and_accept", "fallback" },
  },
})
