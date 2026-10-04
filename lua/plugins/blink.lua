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
    menu = { draw = { treesitter = { "lsp" } } },
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text = { enabled = true },
  },
  signature = { enabled = true }, -- shown automatically while typing arguments
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
