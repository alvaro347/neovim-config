return {
  {
    "EdenEast/nightfox.nvim",
    options = {
      -- Compiled file's destination location
      compile_path = vim.fn.stdpath("cache") .. "/nightfox",
      compile_file_suffix = "_compiled", -- Compiled file suffix
      transparent = true, -- Disable setting background
      terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
      dim_inactive = false, -- Non focused panes set to alternative background
      module_default = true, -- Default enable value for modules
      colorblind = {
        enable = false, -- Enable colorblind support
        simulate_only = false, -- Only show simulated colorblind colors and not diff shifted
        severity = {
          protan = 0, -- Severity [0,1] for protan (red)
          deutan = 0, -- Severity [0,1] for deutan (green)
          tritan = 0, -- Severity [0,1] for tritan (blue)
        },
      },
      styles = { -- Style to be applied to different syntax groups
        comments = "NONE", -- Value is any valid attr-list value `:help attr-list`
        conditionals = "NONE",
        constants = "NONE",
        functions = "NONE",
        keywords = "NONE",
        numbers = "NONE",
        operators = "NONE",
        strings = "NONE",
        types = "NONE",
        variables = "NONE",
      },
      inverse = { -- Inverse highlight for different types
        match_paren = false,
        visual = false,
        search = false,
      },
      modules = { -- List of various plugins and additional options
        -- ...
      },
    },
    -- palettes = {
    --   -- Everything defined under `all` will be applied to each style.
    --   all = {
    --     -- Each palette defines these colors:
    --     --   black, red, green, yellow, blue, magenta, cyan, white, orange, pink
    --     --
    --     -- These colors have 3 shades: base, bright, and dim
    --     --
    --     -- Defining just a color defines it's base color
    --     red = "#ff0000",
    --   },
    --   nightfox = {
    --     -- A specific style's value will be used over the `all`'s value
    --     red = "#c94f6d",
    --   },
    --   dayfox = {
    --     -- Defining multiple shades is done by passing a table
    --     blue = { base = "#4d688e", bright = "#4e75aa", dim = "#485e7d" },
    --   },
    --   nordfox = {
    --     -- A palette also defines the following:
    --     --   bg0, bg1, bg2, bg3, bg4, fg0, fg1, fg2, fg3, sel0, sel1, comment
    --     --
    --     -- These are the different foreground and background shades used by the theme.
    --     -- The base bg and fg is 1, 0 is normally the dark alternative. The others are
    --     -- incrementally lighter versions.
    --     bg1 = "#2e3440",
    --
    --     -- sel is different types of selection colors.
    --     sel0 = "#3e4a5b", -- Popup bg, visual selection bg
    --     sel1 = "#4f6074", -- Popup sel bg, search bg
    --
    --     -- comment is the definition of the comment color.
    --     comment = "#60728a",
    --   },
    -- },
    -- specs = {
    --   -- As with palettes, the values defined under `all` will be applied to every style.
    --   all = {
    --     syntax = {
    --       -- Specs allow you to define a value using either a color or template. If the string does
    --       -- start with `#` the string will be used as the path of the palette table. Defining just
    --       -- a color uses the base version of that color.
    --       keyword = "magenta",
    --
    --       -- Adding either `.bright` or `.dim` will change the value
    --       conditional = "magenta.bright",
    --       number = "orange.dim",
    --     },
    --     git = {
    --       -- A color define can also be used
    --       changed = "#f4a261",
    --     },
    --   },
    --   nightfox = {
    --     syntax = {
    --       -- As with palettes, a specific style's value will be used over the `all`'s value.
    --       operator = "orange",
    --     },
    --   },
    -- },
    -- groups = {
    --   -- As with specs and palettes, the values defined under `all` will be applied to every style.
    --   all = {
    --     -- If `link` is defined it will be applied over any other values defined
    --     Whitespace = { link = "Comment" },
    --
    --     -- Specs are used for the template. Specs have their palette's as a field that can be accessed
    --     IncSearch = { bg = "palette.cyan" },
    --   },
    --   nightfox = {
    --     -- As with specs and palettes, a specific style's value will be used over the `all`'s value.
    --     PmenuSel = { bg = "#73daca", fg = "bg0" },
    --   },
    -- },
  },
}
