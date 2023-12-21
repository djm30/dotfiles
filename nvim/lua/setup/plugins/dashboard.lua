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

M.config = function()
  require("dashboard").setup {
    theme = "hyper",
    config = {
      header = header,
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
