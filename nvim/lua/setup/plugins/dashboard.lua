local M = {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  dependencies = { { "nvim-tree/nvim-web-devicons" } },
}

local header = {
  " ",
  "",
  "  ██╗    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗        ██╗    ██╗  ",
  " ██╔╝    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║       ██╔╝    ╚██╗ ",
  "██╔╝     ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║      ██╔╝      ╚██╗",
  "╚██╗     ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║     ██╔╝       ██╔╝",
  " ╚██╗    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║    ██╔╝       ██╔╝ ",
  "  ╚═╝    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝    ╚═╝        ╚═╝  ",
  "                                                                               ",
  "",
  "",
  "",
  "",
}

local footer = {
  "",
  "",
  "",
  "",
  "🚀 Done is better than perfect",
  "",
  "",
  "",
  "",
}

local key_format = "      %s"
M.config = function()
  require("dashboard").setup {
    theme = "doom",
    config = {
      header = header,
      footer = footer,
      -- week_header = {
      --   enable = false,
      -- },
      center = {
        {
          icon = "󰊳 ",
          desc = "Update",
          action = "Lazy update",
          key = "u",
          icon_hl = "DiagnosticWarn",
          desc_hl = "DiagnosticInfo",
          key_hl = "DiagnosticHint",
          key_format = key_format,
        },
        {
          icon = " ",
          desc = "Files",
          action = "Telescope find_files",
          key = "f",
          icon_hl = "DiagnosticWarn",
          desc_hl = "DiagnosticInfo",
          key_hl = "DiagnosticHint",
          key_format = key_format,
        },
        {
          icon = "󱇚 ",
          desc = "Workspaces",
          action = "Telescope workspaces",
          key = "w",
          icon_hl = "DiagnosticWarn",
          desc_hl = "DiagnosticInfo",
          key_hl = "DiagnosticHint",
          key_format = key_format,
        },
        {
          icon = " ",
          desc = "Filetree",
          action = "Neotree toggle .",
          key = "e",
          icon_hl = "DiagnosticWarn",
          desc_hl = "DiagnosticInfo",
          key_hl = "DiagnosticHint",
          key_format = key_format,
        },
        {
          icon = "󰗼 ",
          desc = "quit",
          action = "quit",
          key = "q",
          icon_hl = "DiagnosticError",
          desc_hl = "DiagnosticInfo",
          key_hl = "DiagnosticHint",
          key_format = key_format,
        },
      },
    },
  }
end

return M
