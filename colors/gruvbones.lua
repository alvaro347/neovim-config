local colors_name = "gruvbones"
vim.g.colors_name = colors_name -- Required when defining a colorscheme

local lush = require("lush")
local hsluv = lush.hsluv -- Human-friendly hsl
local util = require("zenbones.util")

local bg = vim.o.background

-- Define a palette. Use `palette_extend` to fill unspecified colors
-- Based on https://github.com/gruvbox-community/gruvbox#palette
-- The hard/soft contrast backgrounds are wired to zenbones' `lightness`/`darkness` options:
-- `vim.g.gruvbones = { lightness = "bright" | "dim" }` / `{ darkness = "stark" | "warm" }`.
local palette
if bg == "light" then
  palette = util.palette_extend({
    bg = hsluv("#fbf1c7"),
    bg_bright = hsluv("#f9f5d7"), -- hard
    bg_dim = hsluv("#f2e5bc"), -- soft
    fg = hsluv("#3c3836"),
    rose = hsluv("#9d0006"),
    leaf = hsluv("#79740e"),
    wood = hsluv("#b57614"),
    water = hsluv("#076678"),
    blossom = hsluv("#8f3f71"),
    sky = hsluv("#427b58"),
  }, bg)
else
  palette = util.palette_extend({
    bg = hsluv("#282828"),
    bg_stark = hsluv("#1d2021"), -- hard
    bg_warm = hsluv("#32302f"), -- soft
    fg = hsluv("#ebdbb2"),
    rose = hsluv("#fb4934"),
    leaf = hsluv("#b8bb26"),
    wood = hsluv("#fabd2f"),
    water = hsluv("#83a598"),
    blossom = hsluv("#d3869b"),
    sky = hsluv("#83c07c"),
  }, bg)
end

-- Generate the lush specs using the generator util
local generator = require("zenbones.specs")

-- zenbones reads options from `vim.g.<colors_name>`; default transparency on here,
-- still overridable with `vim.g.gruvbones_transparent_background = false`.
local config = generator.get_global_config(colors_name, bg)
if config.transparent_background == nil then
  config.transparent_background = true
end

local base_specs = generator.generate(palette, bg, config)

-- Optionally extend specs using Lush: the three accents from the zenbones docs. Everything
-- else keeps the zenbones hierarchy (bold statements, italic strings, dimmed identifiers,
-- gray delimiters); treesitter and LSP captures chain off these legacy groups.
local specs = lush.extends({ base_specs }).with(function()
  return {
    Statement({ base_specs.Statement, fg = palette.rose }),
    Special({ fg = palette.water }),
    Type({ fg = palette.sky, gui = "italic" }),
  }
end)

-- Pass the specs to lush to apply
lush(specs)

-- Optionally set term colors
require("zenbones.term").apply_colors(palette)
