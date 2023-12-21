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
}

local footer = {
  "",
  "",
  "🚀 Done is better than perfect",
  "",
  "",
}

M.config = function()
  require("dashboard").setup {
    theme = "hyper",
    config = {
      header = header,
      footer = footer,
      week_header = {
        enable = false,
      },
      shortcut = {
        { desc = "󰊳 Update", group = "@property", action = "Lazy update", key = "u" },
        {
          icon = " ",
          icon_hl = "@variable",
          desc = "Files",
          group = "Label",
          action = "Telescope find_files",
          key = "f",
        },
        {
          desc = "󱇚 Workspaces",
          group = "DiagnosticHint",
          action = "Telescope workspaces",
          key = "w",
        },
        {
          desc = " Filetree",
          group = "DiagnosticHint",
          action = "Neotree toggle .",
          key = "e",
        },
        {
          desc = "󰗼 quit",
          group = "Number",
          action = "quit",
          key = "q",
        },
      },
    },
  }
end

return M
