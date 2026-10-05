-- Icons shared by lsp, lualine, bufferline (diagnostics, git) and config/completion.lua (LSP kinds).
local M = {
  diagnostics = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " ",
  },
  git = {
    added = " ",
    modified = " ",
    removed = " ",
  },
  kinds = {
    Class = " ",
    Color = " ",
    Constant = "󰏿 ",
    Constructor = " ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = "󰊕 ",
    Interface = " ",
    Keyword = " ",
    Method = "󰊕 ",
    Module = " ",
    Operator = " ",
    Property = " ",
    Reference = " ",
    Snippet = "󱄽 ",
    Struct = "󰆼 ",
    Text = " ",
    TypeParameter = " ",
    Unit = " ",
    Value = " ",
    Variable = "󰀫 ",
  },
}

return M
