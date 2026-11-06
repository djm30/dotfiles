-- snacks.nvim replaces: dashboard-nvim, indent-blankline, bufdelete, dressing, and the toggleterm lazygit terminal
local header = [[
  ██╗    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗        ██╗    ██╗  
 ██╔╝    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║       ██╔╝    ╚██╗ 
██╔╝     ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║      ██╔╝      ╚██╗
╚██╗     ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║     ██╔╝       ██╔╝
 ╚██╗    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║    ██╔╝       ██╔╝ 
  ╚═╝    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝    ╚═╝        ╚═╝  ]]

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      {
        "<C-c>",
        function()
          Snacks.bufdelete()
        end,
        desc = "Close buffer (keep window)",
      },
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "Open Lazygit",
      },
    },
    opts = {
      dashboard = {
        preset = {
          header = header,
          keys = {
            { icon = "󰊳 ", key = "u", desc = "Update", action = ":Lazy update" },
            { icon = " ", key = "f", desc = "Files", action = ":Telescope find_files" },
            { icon = " ", key = "e", desc = "Filetree", action = ":Oil" },
            { icon = "󰗼 ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "header", padding = 2 },
          { section = "keys", gap = 1, padding = 2 },
          { text = { "🚀 Done is better than perfect", hl = "SnacksDashboardFooter" }, align = "center" },
        },
      },
      indent = {
        indent = { char = "│" },
        scope = { enabled = false }, -- old ibl setup drew scope in the same colour, i.e. no visible scope
        animate = { enabled = false },
        filter = function(buf)
          local excluded = { help = true, oil = true, ["neo-tree"] = true, lazy = true, mason = true, toggleterm = true, trouble = true }
          return vim.bo[buf].buftype == "" and not excluded[vim.bo[buf].filetype] and vim.g.snacks_indent ~= false
        end,
      },
      input = { enabled = true }, -- vim.ui.input
      picker = { enabled = true, ui_select = true }, -- vim.ui.select (legendary, code actions, etc.)
      bufdelete = { enabled = true },
      lazygit = { enabled = true },
    },
  },
}
